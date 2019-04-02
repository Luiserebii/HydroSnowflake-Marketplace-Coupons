pragma solidity ^0.5.0;

import "../marketplace/SnowflakeEINMarketplace.sol";
import "../SnowflakeResolver.sol";
import "../ein/util/SnowflakeEINOwnable.sol";
import "../interfaces/IdentityRegistryInterface.sol";
import "../interfaces/SnowflakeInterface.sol";
import "../interfaces/SnowflakeViaInterface.sol";
import "../interfaces/NeoCouponMarketplaceResolverInterface.sol";
import "../interfaces/marketplace/ItemInterface.sol";

import "../marketplace/features/CouponFeature.sol";
import "../marketplace/features/ItemFeature.sol";


contract CouponMarketplaceResolver is SnowflakeResolver, SnowflakeEINMarketplace, NeoCouponMarketplaceResolverInterface {

/*

Simple Marketplace
-------------------

-Contract owner = seller
-Contract owner = EIN
-Items
-Coupons
  -[uint ---> Coupon]
     -Coupon = [Amount off, items applied to]

Item Status:
-------------
-For Sale/Active
-Purchased - Awaiting payment (Maybe not needed)
-Complete


Functions:
-----------
-List items
-Remove item listing
-Update item listing
-Read item listing


-Pay for thing
   -Look for EIN in Identity Registry, I suppose?
   -TransferHydroBalanceTo(EIN owner)

-----------------------------------------------------------------

Index:
--------

   -Struct/Mapping defnitions and declarations
   -Constructor
   -Inheritance function overrides
   -Public getter functions
   -Add/Update/Delete functions


*/

    address private _CouponMarketplaceViaAddress;


    /*
     * =============
     * Constructor:
     * =============
     *
     * Initialize EIN of owner and SnowflakeResolver vars
     *
     *
     */
    constructor(
        string memory _snowflakeName, string memory _snowflakeDescription,
        address _snowflakeAddress,
        bool _callOnAddition, bool _callOnRemoval,
        address paymentAddress,
        address CouponMarketplaceViaAddress,
        address _CouponFeatureAddress, address _ItemFeatureAddress
    ) SnowflakeResolver (
        _snowflakeName, _snowflakeDescription,
        _snowflakeAddress,
        _callOnAddition, _callOnRemoval
    ) public {

        //Parent constructing
        _constructSnowflakeEINMarketplace(paymentAddress, _CouponFeatureAddress, _ItemFeatureAddress, _snowflakeAddress);

        //Set contract-specific private/internal vars
        _CouponMarketplaceViaAddress = CouponMarketplaceViaAddress;

    }



    function CouponMarketplaceViaAddress() public view returns (address) {
        return _CouponMarketplaceViaAddress;
    }


/* ======================================
    Functions overridden via inheritance  
   ======================================
*/


    // if callOnAddition is true, onAddition is called every time a user adds the contract as a resolver
    // this implementation **must** use the senderIsSnowflake modifier
    // returning false will disallow users from adding the contract as a resolver
    function onAddition(uint /* ein */, uint /* allowance */, bytes memory /* extraData */) public returns (bool) {
        return true;
    }

    // if callOnRemoval is true, onRemoval is called every time a user removes the contract as a resolver
    // this function **must** use the senderIsSnowflake modifier
    // returning false soft prevents users from removing the contract as a resolver
    // however, note that they can force remove the resolver, bypassing onRemoval
    function onRemoval(uint /* ein */, bytes memory /* extraData*/) public returns (bool){
       return true;
    }


/*

-Pay for thing
   -Look for EIN in Identity Registry, I suppose?
   -TransferHydroBalanceTo(EIN owner)



Buyers can purchase listed items at-price by by sending a transaction that:

    Calls allow-and-call for the user on Snowflake
        Sets an allowance equal to the price
        Draws the corresponding allowance from the user
        Transfers ownership of the item to the buyer
    Transactions should be facilitated through a via contract which must be written as part of this task (instructions below); in most instances, the ‘via’ will do nothing; however, if the user has a “coupon,” the via will apply the coupon as part of the transaction. Coupons work as follows:


Via contract to use coupons:

    When a buyer is buying an item, the transfer function call on Snowflake should include the address of the via contract, and an extraData bytes parameter that will encode a function call. This bytes parameter should include the uuid of the user-owned coupon. The logic of the via contract will draw the apply the discount rate of the coupon to the item, and then transfer the coupon to a burner address. The user’s discount will be refunded to them while the seller receives the rest of the value of the transaction. Finally, ownership of the purchased item should be transferred to the user. All this should be achievable in one synchronous function-call. If a user passes 0 as the uuid for the coupon, the via should just conduct a transfer as normal as if no coupon were present.
    The via contract will need to check to enforce that the user actually has the coupon they are trying to pass.





*/



    function purchaseItem(uint id, /*bytes memory data,*/ address approvingAddress, uint couponID) public returns (bool) {

        //Initialize itemFeature here (as is necessary to check the require as early as possible)   
        ItemFeature itemFeature = ItemFeature(ItemFeatureAddress);
        //CouponFeature couponFeature = CouponFeature(CouponFeatureAddress);

        uint256 price = itemFeature.getItemPrice(id);

        //Ensure the item exists, and that there is a price
        require(price > 0, "item does not exist, or has a price below 0. The price in question is: ");

        //Initialize Snowflake
        SnowflakeInterface snowflake = SnowflakeInterface(snowflakeAddress);


    /* Take an EIN (from), an address (via), an EIN (to), an amount, and data

          -handleAllowance() and pass the EIN (from), and an amount
          -_withdraw() and pass the EIN (from), the address (via), and amount
          -Call snowflakeCall() from the via contract through the SnowflakeViaInterface, passing msg.sender, the EIN (from), the EIN (to), amount, and data
*/

        //Get EIN of user
        //Logic is einFrom, since this is the buyer from which funds will head to our via contract
            //uint einFrom = identityRegistry.getEIN(approvingAddress);
            //uint einTo = ownerEIN(); //The seller


        //bytes data; set snowflakeCall stuff
        bytes memory snowflakeCallData;
        string memory functionSignature = "processTransaction(uint256,uint256,uint256,uint256,uint256)";
        snowflakeCallData = abi.encodeWithSelector(bytes4(keccak256(bytes(functionSignature))), id, getEIN(approvingAddress), ownerEIN(), price, couponID);

        //Allowance for item to CouponMarketplaceVia MUST BE DONE FROM FRONT-END
        //Allowance for coupon to CouponMarketplaceVia MUST BE DONE FROM FRONT-END

        //If there is a coupon,
        //   Grant allowance to Via
        //if(couponID != 0){
            //Ensure coupon is owned
            //(!!!IMPORTANT!!! Ohhh, you know, I don't this is quite possible like this... ownerOf makes it unclear as to which (Coupon, or Item) it'll return, I think... hmmm, darn. Seperate contract? Perhaps create on deployment?)
       //     require(couponFeature.ownerOf(id) == getEIN(approvingAddress), "Approving address is not the owner of this coupon");
            
            
       // }



        // 
        //  function transferSnowflakeBalanceFromVia(uint einFrom, address via, uint einTo, uint amount, bytes memory _bytes)
        //


        snowflake.transferSnowflakeBalanceFromVia(getEIN(approvingAddress), _CouponMarketplaceViaAddress, ownerEIN(), price, snowflakeCallData);

        //Transfers ownership of the item to the buyer (!)

    }



}

 

