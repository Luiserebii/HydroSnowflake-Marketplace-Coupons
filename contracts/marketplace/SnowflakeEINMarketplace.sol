pragma solidity ^0.5.0;

import "../ein/util/SnowflakeEINOwnable.sol";
import "./Marketplace.sol";
import "../interfaces/marketplace/SnowflakeEINMarketplaceInterface.sol";
import "../interfaces/marketplace/CouponInterface.sol";
import "../interfaces/marketplace/features/coupon_distribution/CouponDistributionInterface.sol";

contract SnowflakeEINMarketplace is Marketplace, SnowflakeEINOwnable, SnowflakeEINMarketplaceInterface {

/*
    constructor(address paymentAddress, address _CouponFeatureAddress, address _ItemFeatureAddress, address _snowflakeAddress) public {
        _constructSnowflakeEINMarketplace(paymentAddress, _CouponFeatureAddress, _ItemFeatureAddress, _snowflakeAddress);
    
    }    
*/
    function _constructSnowflakeEINMarketplace(address paymentAddress, address _CouponFeatureAddress, address _ItemFeatureAddress, address _snowflakeAddress) internal {
        _constructMarketplace(paymentAddress, _CouponFeatureAddress, _ItemFeatureAddress/*,_snowflakeAddress*/);
        _constructSnowflakeEINOwnable(_snowflakeAddress);
    }

    function setPaymentAddress(address paymentAddress) public onlyEINOwner returns (bool) {
        return _setPaymentAddress(paymentAddress);
    }


    function distributeCoupon(uint id) public onlyEINOwner returns (bool) {
        //We only need to read from the Coupons, so CouponsInterface is appropriate here
        CouponInterface coupons = CouponInterface(CouponFeatureAddress);
        //Grab our distribution address, as defined within the coupon, and access it
        address distributionAddress = coupons.getCouponDistributionAddress(id);
        CouponDistributionInterface couponDistribution = CouponDistributionInterface(distributionAddress);
        //Call the distribute coupon function it has with our coupon ID, and let it execute!
        couponDistribution.distributeCoupon(id); 
    }

    //Here, we expose the functionality of _giveUserCoupon() and force a CouponDistribution contract to be the only one to actually use this function and give a user a coupon
    function giveUserCoupon(uint ein, uint couponID) public onlyCouponDistribution returns (bool) {
        return _giveUserCoupon(ein, couponID);
    }


    //Exposing functions to work with onlyEINOwner to set CouponFeatureAddress
    function setCouponFeatureAddress(address _CouponFeatureAddress) public onlyEINOwner returns (bool) {
        return _setCouponFeatureAddress(_CouponFeatureAddress);
    }

    function setItemFeatureAddress(address _ItemFeatureAddress) public onlyEINOwner returns (bool) {
        return _setItemFeatureAddress(_ItemFeatureAddress);
    }

    function setCouponDistributionAddress(address _CouponDistributionAddress) public onlyEINOwner returns (bool) {
        return _setCouponDistributionAddress(_CouponDistributionAddress);
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
