pragma solidity ^0.5.0;

import "../SnowflakeResolver.sol";
import "./SnowflakeEINOwnable.sol";
import "../interfaces/IdentityRegistryInterface.sol";
import "../interfaces/SnowflakeInterface.sol";

contract CouponMarketplace is SnowflakeResolver, SnowflakeEINOwnable {

/*

Simple Marketplace
-------------------

-Contract owner = seller
-Contract owner = EIN
-Items
-Coupons
  -[uint ---> Coupon]
     -Coupon = [Amount off, items applied to]

*/

    mapping(uint => string) public deliveryMethods;
    mapping(uint => Item) public itemListings;
    mapping(uint => string) public itemTags;
    mapping(uint => ReturnPolicy) public returnPolicies;

    mapping(uint => Coupon) public avaliableCoupons;

    //uints to track next avaliable "ID" added to mappings
    //Reasoning on next > latest; avoiding writing if() statement to check if [0] has already been set
    uint public nextDeliveryMethodID,
                nextItemListingsID,
                nextItemTagsID,
                nextReturnPoliciesID,
                nextReturnPolicitsID;

    struct Item {
        uint uuid;
        uint quantity;
        ItemType type;
        ItemStatus status;
        ItemCondition condition;
        string title;
        string description;
        uint256 price;
        uint[] delivery; //Simply holds the ID for the delivery method, done for saving space
        uint[] tags;
        uint returnPolicy;

    }

    enum ItemType { DIGITAL, PHYSICAL }
    
    enum ItemStatus { ACTIVE, AWAITING_PAYMENT, COMPLETE }
    enum ItemCondition { NEW, LIKE_NEW, VERY_GOOD, GOOD, ACCEPTABLE }
    

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
        uint256 amountOff;
        uint[] itemsApplicable;
        uint expirationDate;
    }

    constructor(
        uint ein,
        string memory _snowflakeName, string memory _snowflakeDescription,
        address _snowflakeAddress,
        bool _callOnAddition, bool _callOnRemoval
    ) SnowflakeEINOwnable (
        ein
    ) SnowflakeResolver (
        _snowflakeName, _snowflakeDescription,
        _snowflakeAddress,
        _callOnAddition, _callOnRemoval
    ) public {

        //Initialize "latestID" vars
        latestDeliveryMethodID = 0;
        latestItemListingsID = 0;
        latestItemTagsID,
        latestReturnPoliciesID,
        latestReturnPolicitsID;

    }

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
    function onAddition(uint ein, uint allowance, bytes memory extraData) public returns (bool) {
        return true;
    }

    // if callOnRemoval is true, onRemoval is called every time a user removes the contract as a resolver
    // this function **must** use the senderIsSnowflake modifier
    // returning false soft prevents users from removing the contract as a resolver
    // however, note that they can force remove the resolver, bypassing onRemoval
    function onRemoval(uint ein, bytes memory extraData) public returns (bool){
       return true;
    }


/*
    Many of these getters may not be needed; check web3
*/

    function getItem(uint id) public view returns (
        uint uuid,
        uint quantity,
        ItemType type,
        ItemStatus status,
        ItemCondition condition,
        string memory title,    
        string memory description,
        uint256 price,
        uint returnPolicy
    ){

        Item item = itemListings[id];      
        return (item.uuid, item.quantity, item.type, item.status, item.condition, item.title, item.description, item.price, item.returnPolicy);
    }

    function getItemDelivery(uint id, uint index) public view returns (uint) { return itemListings[id].delivery[index]; }
    function getItemTag(uint id, uint index) public view returns (uint) { return itemListings[id].tags[index]; }


    function getDeliveryMethod(uint id) public view returns (
        string method
    ){
        return (deliveryMethods[id]);   
    }

    function getReturnPolicy(uint id) public view returns (
        bool returnsAccepted,
        uint timeLimit
    ){

        ReturnPolicy rp = returnPolicies[id];
        return (rp.returnsAccepted, rp.timeLimit);
    } 

    function getCoupon(uint id) public view returns (
        uint256 amountOff,
        uint expirationDate
    ){

        Coupon c = avaliableCoupons[id];
        return (c.amountOff, c.expirationDate);
    }

    function getCouponItemApplicable(uint id, uint index) public view returns (uint) { return avaliableCoupons[id].tags[index]; }

/*
===============================================================================================================================
    	END OF PUBLIC GETTER FUNCTIONS
===============================================================================================================================
*/

/*


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

*/









}
 

