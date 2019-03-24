pragma solidity ^0.5.0;

import "../ein/util/SnowflakeEINOwnable.sol";
import "./Marketplace.sol";


contract SnowflakeEINMarketplace is Marketplace, SnowflakeEINOwnable {


    function setPaymentAddress(address addr) public onlyEINOwner returns (bool) {
        return _setPaymentAddress(addr);
    }

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
       return _addItemListing(uuid, quantity, itemType, status, condition, title, description, price, delivery, tags, returnPolicy);
    }


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
       return _updateItemListing(id, uuid, quantity, itemType, status, condition, title, description, price, delivery, tags, returnPolicy);
    }

    function deleteItemListing(uint id) public onlyEINOwner returns (bool) {
        return _deleteItemListing(id);
    }


/*
==================================
DeliveryMethods add/update/delete
==================================
*/

    function addDeliveryMethod(string memory deliveryMethod) public onlyEINOwner returns (bool) {
        return _addDeliveryMethod(deliveryMethod);
    }

    function updateDeliveryMethod(uint id, string memory deliveryMethod) public onlyEINOwner returns (bool) {
        return _updateDeliveryMethod(id, deliveryMethod);
    }

    function deleteDeliveryMethod(uint id) public onlyEINOwner returns (bool) {
        return _deleteDeliveryMethod(id);
    }


/*
==============================
ItemTags add/update/delete
==============================
*/

    function addItemTag(string memory itemTag) public onlyEINOwner returns (bool) {
        return _addItemTag(itemTag);
    }

    function updateItemTag(uint id, string memory itemTag) public onlyEINOwner returns (bool) {
        return _updateItemTag(id, itemTag);
    }

    function deleteItemTag(uint id) public onlyEINOwner returns (bool) {
        return _deleteItemTag(id);
    }

/*
==============================
ReturnPolicy add/update/delete
==============================
*/

    function addReturnPolicy(bool returnsAccepted, uint timeLimit) public onlyEINOwner returns (bool) {
        return _addReturnPolicy(returnsAccepted, timeLimit);
    }

    function updateReturnPolicy(uint id, bool returnsAccepted, uint timeLimit) public onlyEINOwner returns (bool) {
        return _updateReturnPolicy(id, returnsAccepted, timeLimit);
    }

    function deleteReturnPolicy(uint id) public onlyEINOwner returns (bool) {
        return _deleteReturnPolicy(id);
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
        return _addAvailableCoupon(couponType, title, description, amountOff, itemsApplicable, expirationDate);
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
        return _updateAvailableCoupon(id, couponType, title, description, amountOff, itemsApplicable, expirationDate);
    }


    function deleteAvailableCoupon(uint id) public onlyEINOwner returns (bool) {
       return _deleteAvailableCoupon(id);
    }


/* ====================================================

       END OF ADD/UPDATE/DELETE FUNCTIONS

   ====================================================
*/
















}
