pragma solidity ^0.5.0;

import "../SnowflakeResolver.sol";
import "./SnowflakeEINOwnable.sol";
import "../interfaces/IdentityRegistryInterface.sol";
import "../interfaces/SnowflakeInterface.sol";
import "../interfaces/SnowflakeViaInterface.sol";
import "../interfaces/CouponMarketplaceResolverInterface.sol";

contract CouponMarketplaceResolver is SnowflakeResolver, SnowflakeEINOwnable, CouponMarketplaceResolverInterface {

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


==================
TODO: Add events
==================

-----------------------------------------------------------------

Index:
--------

   -Struct/Mapping defnitions and declarations
   -Constructor
   -Inheritance function overrides
   -Public getter functions
   -Add/Update/Delete functions


*/


   struct Item {
        uint uuid;
        uint quantity;
        ItemType itemType;
        ItemStatus status;
        ItemCondition condition;
        string title;
        string description;
        uint256 price;
        uint[] delivery; //Simply holds the ID for the delivery method, done for saving space
        uint[] tags;
        uint returnPolicy;

    }

/*    enum ItemType { DIGITAL, PHYSICAL }
    
    enum ItemStatus { ACTIVE, INACTIVE }
    enum ItemCondition { NEW, LIKE_NEW, VERY_GOOD, GOOD, ACCEPTABLE }
*/    

    struct DeliveryDetails {
        uint method;
        uint handlingTime;
        string trackingNumber;
    }

    struct ReturnPolicy {
        bool returnsAccepted;
        uint timeLimit;
    }

    struct Coupon {
        CouponType couponType;
        string title;
        string description;
        uint256 amountOff;
        uint[] itemsApplicable;
        uint expirationDate;
    }

    //percentage off not implemented, but here for future design convenience
/*
    enum CouponType { AMOUNT_OFF, PERCENTAGE_OFF, BUY_X_QTY_GET_Y_FREE , BUY_X_QTY_FOR_Y_AMNT }
*/
    address private _paymentAddress;
    address private _MarketplaceCouponViaAddress;

    /* Mappings and ID uints */

    mapping(uint => Item) public itemListings;
    mapping(uint => string) public itemTags;
    mapping(uint => string) public deliveryMethods;  
    mapping(uint => ReturnPolicy) public returnPolicies;
    mapping(uint => Coupon) public availableCoupons;

    //uints to track next avaliable "ID" added to mappings
    //Reasoning on next > latest; avoiding writing if() statement to check if [0] has already been set
    uint public nextDeliveryMethodsID;
    uint public nextItemListingsID;
    uint public nextItemTagsID;
    uint public nextReturnPoliciesID;
    uint public nextAvailableCouponsID;


    //EIN to Coupon UUID mapping
    // EIN => (couponID => bool)
    mapping(uint => mapping(uint => bool)) public userCoupons;


    /*-----------------------------------*/



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
        uint ein,
        string memory _snowflakeName, string memory _snowflakeDescription,
        address _snowflakeAddress,
        bool _callOnAddition, bool _callOnRemoval,
        address paymentAddress,
        address MarketplaceCouponViaAddress
    ) SnowflakeEINOwnable (
        ein
    ) SnowflakeResolver (
        _snowflakeName, _snowflakeDescription,
        _snowflakeAddress,
        _callOnAddition, _callOnRemoval
    ) public {

        //Initialize "latestID" vars
        nextDeliveryMethodsID = 1;
        nextItemListingsID = 1;
        nextItemTagsID = 1;
        nextReturnPoliciesID = 1;
        //In order to satisfy logic of "If a user passes 0 as the uuid for the coupon, the via should just conduct a transfer as normal as if no coupon were present.", we put this at 1
        nextAvailableCouponsID = 1;

        //Set contract-specific private/internal vars
        _paymentAddress = paymentAddress;
        _MarketplaceCouponViaAddress = MarketplaceCouponViaAddress;

    }


/* ======================================
    Functions overridden via inheritance  
   ======================================
*/


    function isEINOwner() public returns(bool){
        //Grab an instance of IdentityRegistry to work with as defined in Snowflake
        SnowflakeInterface si = SnowflakeInterface(snowflakeAddress);
        address iAdd = si.identityRegistryAddress();

        IdentityRegistryInterface identityRegistry = IdentityRegistryInterface(iAdd);
        //Ensure the address exists within the registry
        require(identityRegistry.hasIdentity(msg.sender), "Address non-existent in IdentityRegistry");

        return identityRegistry.getEIN(msg.sender) == ownerEIN();
    }


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
    =================
     Public Getters:
    =================

    Functions which simply take indicies and return their value; convenience functions for mapping/arrays




    function getItem(uint id) public view returns (uint uuid, uint quantity, ItemType itemType, ItemStatus status, ItemCondition condition, string memory title, string memory description, uint256 price, uint returnPolicy);

    function getItemDelivery(uint id, uint index) public view returns (uint);
    function getItemTag(uint id, uint index) public view returns (uint);

    //Returns delivery method at mapping ID (i.e. Fedex)
    function getDeliveryMethod(uint id) public view returns (string memory method);
    
    function getReturnPolicy(uint id) public view returns (bool returnsAccepted, uint timeLimit);
    function getCoupon(uint id) public view returns (CouponType couponType, string title, string description, uint256 amountOff, uint expirationDate);
    function getCouponItemApplicable(uint id, uint index) public view returns (uint);

    function isUserCouponOwner(uint id) public view returns (bool isValid);


    Many of these getters may not be needed; check web3
*/




    function paymentAddress() public view returns (address) {
        return _paymentAddress;
    }

    function MarketplaceCouponViaAddress() public view returns (address) {
        return _MarketplaceCouponViaAddress;
    }

    function getItem(uint id) public view returns (
        uint uuid,
        uint quantity,
        ItemType itemType,
        ItemStatus status,
        ItemCondition condition,
        string memory title,    
        string memory description,
        uint256 price,
        uint returnPolicy
    ){

        Item memory item = itemListings[id];      
        return (item.uuid, item.quantity, item.itemType, item.status, item.condition, item.title, item.description, item.price, item.returnPolicy);
    }

    function getItemDelivery(uint id, uint index) public view returns (uint) { return itemListings[id].delivery[index]; }

    function getItemTag(uint id, uint index) public view returns (uint) { return itemListings[id].tags[index]; }


    function getDeliveryMethod(uint id) public view returns (string memory method){
        return (deliveryMethods[id]);   
    }

    function getReturnPolicy(uint id) public view returns (bool returnsAccepted, uint timeLimit){

        ReturnPolicy memory rp = returnPolicies[id];
        return (rp.returnsAccepted, rp.timeLimit);
    } 

    function getCoupon(uint id) public view returns (CouponType couponType, string memory title, string memory description, uint256 amountOff, uint expirationDate){

        Coupon memory c = availableCoupons[id];
        return (c.couponType, c.title, c.description, c.amountOff, c.expirationDate);
    }

    function getCouponItemApplicable(uint id, uint index) public view returns (uint) { return availableCoupons[id].itemsApplicable[index]; }

    function isUserCouponOwner(uint ein, uint couponID) public view returns (bool isValid) {
        return userCoupons[ein][couponID];
    }





/*
===============================================================================================================================
    	END OF PUBLIC GETTER FUNCTIONS
===============================================================================================================================
*/





/*
========================
Only EIN Owner setters
========================


*/



//TODO: Add event here
function setPaymentAddress(address addr) public onlyEINOwner returns (bool) {
    _paymentAddress = addr;
    return true;
}





/* =================================================

    ADD/UPDATE/DELETE FUNCTIONS FOR:
   ----------------------------------- 
      -itemListings
      -itemTags
      -deliveryMethods
      -returnPolicies
      -availableCoupons

   =================================================
*/



/*
==============================
ItemListing add/update/delete
==============================
*/


    function addItemListing (
        uint uuid,
        uint quantity,
        ItemType itemType,
        ItemStatus status,
        ItemCondition condition,
        string memory title,
        string memory description,
        uint256 price,
        uint[] memory delivery, 
        uint[] memory tags,
        uint returnPolicy
    ) public onlyEINOwner returns (bool) {

        //Add to itemListings
        itemListings[nextItemListingsID] = Item(uuid, quantity, itemType, status, condition, title, description, price, delivery, tags, returnPolicy);
        //advance item by one
        nextItemListingsID++;

        return true;
    }


    //NOTE: This can be changed in a way that does not re-create an entirely new item on every call, but more complex that perhaps needed

    function updateItemListing (
        uint id,
        uint uuid,
        uint quantity,
        ItemType itemType,
        ItemStatus status,
        ItemCondition condition,
        string memory title,
        string memory description,
        uint256 price,
        uint[] memory delivery, 
        uint[] memory tags,
        uint returnPolicy
    ) public onlyEINOwner returns (bool) {

        //Update itemListing identified by ID
        itemListings[id] = Item(uuid, quantity, itemType, status, condition, title, description, price, delivery, tags, returnPolicy);
        return true;
    }

    function deleteItemListing(uint id) public onlyEINOwner returns (bool) {
        //Delete itemListing identified by ID
        delete itemListings[id];
        return true;
    }


/*
==================================
DeliveryMethods add/update/delete
==================================
*/

    function addDeliveryMethod(string memory deliveryMethod) public onlyEINOwner returns (bool) {
        //Add to deliveryMethods
        deliveryMethods[nextDeliveryMethodsID] = deliveryMethod;
        //Advance delivery method by one
        nextDeliveryMethodsID++;

        return true;
    }

    function updateDeliveryMethod(uint id, string memory deliveryMethod) public onlyEINOwner returns (bool) {
        //Update deliveryMethods by ID
        deliveryMethods[id] = deliveryMethod;
        return true;
    }

    function deleteDeliveryMethod(uint id) public onlyEINOwner returns (bool) {

        //Delete itemListing identified by ID
        delete deliveryMethods[id];
        return true;
    }


/*
==============================
ItemTags add/update/delete
==============================
*/

    function addItemTag(string memory itemTag) public onlyEINOwner returns (bool) {
        //Add to deliveryMethods
        itemTags[nextItemTagsID] = itemTag;
        //Advance delivery method by one
        nextItemTagsID++;

        return true;
    }

    function updateItemTag(uint id, string memory itemTag) public onlyEINOwner returns (bool) {
        //Update deliveryMethods by ID
        itemTags[id] = itemTag;
        return true;
    }

    function deleteItemTag(uint id) public onlyEINOwner returns (bool) {

        //Delete itemListing identified by ID
        delete itemTags[id];
        return true;
    }

/*
==============================
ReturnPolicy add/update/delete
==============================
*/

    function addReturnPolicy(bool returnsAccepted, uint timeLimit) public onlyEINOwner returns (bool) {
        //Add to returnPolicies
        returnPolicies[nextReturnPoliciesID] = ReturnPolicy(returnsAccepted, timeLimit);
        //Advance return policy ID by one
        nextReturnPoliciesID++;

        return true;
    }

    function updateReturnPolicy(uint id, bool returnsAccepted, uint timeLimit) public onlyEINOwner returns (bool) {
        //Update returnPolicies by ID
        returnPolicies[id] = ReturnPolicy(returnsAccepted, timeLimit);
        return true;
    }

    function deleteReturnPolicy(uint id) public onlyEINOwner returns (bool) {
        //Delete Return Policy identified by ID
        delete returnPolicies[id];
        return true;
    }


/*
===================================
AvailableCoupons add/update/delete
===================================
*/

    function addAvailableCoupon(
        CouponType couponType,
        string memory title,
        string memory description,
        uint256 amountOff,
        uint[] memory itemsApplicable,
        uint expirationDate

    ) public onlyEINOwner returns (bool) {
        //Add to avaliableCoupons
        availableCoupons[nextAvailableCouponsID] = Coupon(couponType, title, description, amountOff, itemsApplicable, expirationDate);
        //Advance nextAvailableCouponID by 1
        nextAvailableCouponsID++;

        return true;
    }

    function updateAvailableCoupon(
        uint id,
        CouponType couponType,
        string memory title,
        string memory description,
        uint256 amountOff,
        uint[] memory itemsApplicable,
        uint expirationDate

    ) public onlyEINOwner returns (bool) {
        //Add to avaliableCoupons
        availableCoupons[id] = Coupon(couponType, title, description, amountOff, itemsApplicable, expirationDate);

        return true;
    }

   
    function deleteAvailableCoupon(uint id) public onlyEINOwner returns (bool) {
    
        //Delete availableCoupon by ID
        delete availableCoupons[id];
        return true;

    }


/* ====================================================

       END OF ADD/UPDATE/DELETE FUNCTIONS

   ====================================================
*/


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

        //Ensure the item exists, and that there is a price
        require(itemListings[id].price > 0, 'item does not exist, or has a price below 0. The price in question is: ');

        //Initialize Snowflake
        SnowflakeInterface snowflake = SnowflakeInterface(snowflakeAddress);

        
        //allowAndCallDelegated for the user
        // - Take a destination address, an amount, data, an approving address, and three signature fields (v,r,s)
        //snowflake.allowAndCallDelegated(_paymentAddress, itemListings[id].price, data, approvingAddress, v, r, s);
     
        //using transferSnowflakeBalanceFromVia() instead


/* Take an EIN (from), an address (via), an EIN (to), an amount, and data

  -handleAllowance() and pass the EIN (from), and an amount
  -_withdraw() and pass the EIN (from), the address (via), and amount
  -Call snowflakeCall() from the via contract through the SnowflakeViaInterface, passing msg.sender, the EIN (from), the EIN (to), amount, and data
*/

        //Get EIN of user
        IdentityRegistryInterface identityRegistry = IdentityRegistryInterface(snowflake.identityRegistryAddress());
        //Logic is einFrom, since this is the buyer from which funds will head to our via contract
//        uint einFrom = identityRegistry.getEIN(approvingAddress);
//        uint einTo = ownerEIN(); //The seller

        //bytes data; set snowflakeCall stuff
        bytes memory snowflakeCallData;
        string memory functionSignature = "function processTransaction(address, uint, uint, uint, uint)";
        snowflakeCallData = abi.encodeWithSelector(bytes4(keccak256(bytes(functionSignature))), address(this), identityRegistry.getEIN(approvingAddress), ownerEIN(), itemListings[id].price, couponID);


// function transferSnowflakeBalanceFromVia(uint einFrom, address via, uint einTo, uint amount, bytes memory _bytes)

        snowflake.transferSnowflakeBalanceFromVia(identityRegistry.getEIN(approvingAddress), _MarketplaceCouponViaAddress, ownerEIN(), itemListings[id].price, snowflakeCallData);

        //Transfers ownership of the item to the buyer (!)

    }



}

 

