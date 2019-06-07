pragma solidity ^0.5.0;

interface CouponInterface {

//A simple interface for Coupon.sol


    enum CouponType { AMOUNT_OFF, PERCENTAGE_OFF, BUY_X_QTY_GET_Y_FREE, BUY_X_QTY_FOR_Y_AMNT }
/*
    function getCoupon(uint id) external view returns (CouponType couponType, string memory title, string memory description, uint256 amountOff, uint expirationDate);*/
    function getCouponItemsApplicable(uint id) external view returns (uint[] memory);
    function getCouponDistributionAddress(uint id) external view returns (address);

}
