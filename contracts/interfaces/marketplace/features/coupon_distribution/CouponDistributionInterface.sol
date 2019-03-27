pragma solidity ^0.5.0;

interface CouponDistributionInterface {

    //Very minimal interface, just needs to implement distribution for both cases, and that's it!


    function distributeCoupon(uint256 couponID, bytes data) external returns (bool);
    function distributeCoupon(uint256 couponID) external returns (bool);

}
