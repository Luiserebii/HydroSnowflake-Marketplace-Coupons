pragma solidity ^0.5.0;

import "../ein/util/SnowflakeEINOwnable.sol";
import "./Marketplace.sol";


contract SnowflakeEINMarketplace is Marketplace, SnowflakeEINOwnable {


    constructor(address paymentAddress, address _CouponFeatureAddress, address _ItemFeatureAddress, address _snowflakeAddress) public {
        _constructSnowflakeEINMarketplace(paymentAddress, _CouponFeatureAddress, _ItemFeatureAddress, _snowflakeAddress);
    
    }    

    function _constructSnowflakeEINMarketplace(address paymentAddress, address _CouponFeatureAddress, address _ItemFeatureAddress, address _snowflakeAddress) internal {
        _constructMarketplace(paymentAddress, _CouponFeatureAddress, _ItemFeatureAddress,_snowflakeAddress);
        _constructSnowflakeEINOwnable(_snowflakeAddress);
    }

    function setPaymentAddress(address paymentAddress) public onlyEINOwner returns (bool) {
        return _setPaymentAddress(paymentAddress);
    }

    //Exposing functions to work with onlyEINOwner to set CouponFeatureAddress
    function setCouponFeatureAddress(address _CouponFeatureAddress) public onlyEINOwner returns (bool) {
        return _setCouponFeatureAddress(_CouponFeatureAddress);
    }

    function setItemFeatureAddress(address _ItemFeatureAddress) public onlyEINOwner returns (bool) {
        return _setItemFeatureAddress(_ItemFeatureAddress);
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



/* ====================================================

       END OF ADD/UPDATE/DELETE FUNCTIONS

   ====================================================
*/
















}
