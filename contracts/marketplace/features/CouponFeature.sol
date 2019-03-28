pragma solidity ^0.5.0;

import "../../ein/util/SnowflakeEINOwnable.sol";
import "./Coupons.sol";


contract CouponFeature is Coupons, SnowflakeEINOwnable {


    constructor(address _snowflakeAddress) public {
        _constructCouponFeature(_snowflakeAddress);
    
    }    

    function _constructCouponFeature(address _snowflakeAddress) internal {
        _constructCoupons(_snowflakeAddress);
        _constructSnowflakeEINOwnable(_snowflakeAddress);
    }

/*
===================================
AvailableCoupons add/update/delete
===================================
*/



   function addAvailableCoupon(
        uint256 ein,
        CouponType couponType,
        string memory title,
        string memory description,
        uint256 amountOff,
        uint[] memory itemsApplicable,
        uint expirationDate,
        address couponDistribution

    ) public onlyEINOwner returns (bool) {
        return _addAvailableCoupon(ein, couponType, title, description, amountOff, itemsApplicable, expirationDate, couponDistribution);
    }


    function updateAvailableCoupon(
        uint id,
        CouponType couponType,
        string memory title,
        string memory description,
        uint256 amountOff,
        uint[] memory itemsApplicable,
        uint expirationDate,
        address couponDistribution

    ) public onlyEINOwner returns (bool) {
        return _updateAvailableCoupon(id, couponType, title, description, amountOff, itemsApplicable, expirationDate, couponDistribution);
    }


    function deleteAvailableCoupon(uint id) public onlyEINOwner returns (bool) {
       return _deleteAvailableCoupon(id);
    }


/* ====================================================

       END OF ADD/UPDATE/DELETE FUNCTIONS

   ====================================================
*/










}
