pragma solidity ^0.5.0;

import "../../../ein/util/SnowflakeEINOwnable.sol";

contract CouponDistribution is SnowflakeEINOwnable {

/*

Coupon generation function should take the following parameters:

    Item type - the type of item for which this coupon applies
    Discount rate - the percentage discount the coupon offers
    Distribution address - defines the logic for how coupons are distributed; must follow a standard interface with a function that can be called from the coupon-generation function to define the initial distribution of coupons once generated.
    Each coupon should have a uuid

*/    
    
    address public CouponFeatureAddress;


    constructor(address _CouponFeatureAddress, address _snowflakeAddress) public {
        _constructCouponDistribution(_CouponFeatureAddress, _snowflakeAddress);
    }

    function _constructCouponDistribution(address _CouponFeatureAddress, address _snowflakeAddress) internal returns (bool) {

        _constructSnowflakeEINOwnable(_snowflakeAddress);

        //Actual internal construction
        CouponFeatureAddress = _CouponFeatureAddress;
    }

    //Function for the owner to switch the address of the CouponFeature, which is why this contract is SnowflakeEINOwnable
    function setCouponFeatureAddress(address _CouponFeatureAddress) public onlyEINOwner returns (bool) {
        CouponFeatureAddress = _CouponFeatureAddress;
    }


    function distributeCoupons() public returns (bool) {
        return _distributeCoupons();
    }
    
    function _distributeCoupons() internal returns (bool) {
        
        
    }   
    

    
    modifier onlyCouponFeature() {
        require(msg.sender == CouponFeatureAddress);
        _;
    }
    
    
    
}
