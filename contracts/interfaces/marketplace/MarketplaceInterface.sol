pragma solidity ^0.5.0;

interface MarketplaceInterface {

    function paymentAddress() external view returns (address);
    function isUserCouponOwner(uint ein, uint couponID) external view returns (bool);

}



