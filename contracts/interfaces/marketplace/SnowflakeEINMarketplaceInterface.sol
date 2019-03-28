pragma solidity ^0.5.0;

interface SnowflakeEINMarketplaceInterface {

    function setPaymentAddress(address paymentAddress) external returns (bool);
    function setCouponDistributionAddress(address _CouponDistributionAddress) external returns (bool);
    function giveUserCoupon(uint ein, uint couponID) external returns (bool);

}



