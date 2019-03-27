pragma solidity ^0.5.0;

interface CouponDistributionInterface {

    //Very minimal interface, just needs to implement distribution for both cases, and that's it!

    //! calldata is a new keyword, it seems for data location in ^0.5.0; interesting!
    function distributeCoupon(uint256 couponID, bytes calldata data) external returns (bool);
    function distributeCoupon(uint256 couponID) external returns (bool);

}
