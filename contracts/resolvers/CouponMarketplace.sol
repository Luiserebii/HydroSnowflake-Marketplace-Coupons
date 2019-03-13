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

    /*-----------------------------------*/



    /*
     * =============
     * Constructor:
     * =============
     *
     * Intialize EIN of owner and SnowflakeResolver vars
     *
     *
     */
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
        nextDeliveryMethodsID = 0;
        nextItemListingsID = 0;
        nextItemTagsID = 0;
        nextReturnPoliciesID = 0;
        nextAvailableCouponsID = 0;

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
    function getCoupon(uint id) public view returns (uint256 amountOff, uint expirationDate);
    function getCouponItemApplicable(uint id, uint index) public view returns (uint);



    Many of these getters may not be needed; check web3
*/




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

    function getCoupon(uint id) public view returns (uint256 amountOff, uint expirationDate){

        Coupon memory c = availableCoupons[id];
        return (c.amountOff, c.expirationDate);
    }

    function getCouponItemApplicable(uint id, uint index) public view returns (uint) { return availableCoupons[id].itemsApplicable[index]; }




/*
===============================================================================================================================
    	END OF PUBLIC GETTER FUNCTIONS
===============================================================================================================================
*/


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
        uint256 amountOff,
        uint[] memory itemsApplicable,
        uint expirationDate

    ) public onlyEINOwner returns (bool) {
        //Add to avaliableCoupons
        availableCoupons[nextAvailableCouponsID] = Coupon(amountOff, itemsApplicable, expirationDate);
        //Advance nextAvailableCouponID by 1
        nextAvailableCouponsID++;

        return true;
    }

    function updateAvailableCoupon(
        uint id,
        uint256 amountOff,
        uint[] memory itemsApplicable,
        uint expirationDate

    ) public onlyEINOwner returns (bool) {
        //Add to avaliableCoupons
        availableCoupons[id] = Coupon(amountOff, itemsApplicable, expirationDate);

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



}

 

