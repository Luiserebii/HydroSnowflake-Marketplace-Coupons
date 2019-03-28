pragma solidity ^0.5.0;

import "../../../ein/util/SnowflakeEINOwnable.sol";
import "../../../interfaces/marketplace/features/coupon_distribution/CouponDistributionInterface.sol";
import "../CouponFeature.sol";
import "../../../interfaces/marketplace/MarketplaceInterface.sol";

contract CouponDistribution is CouponDistributionInterface, SnowflakeEINOwnable {

/*

Coupon generation function should take the following parameters:

    Item type - the type of item for which this coupon applies
    Discount rate - the percentage discount the coupon offers
    Distribution address - defines the logic for how coupons are distributed; must follow a standard interface with a function that can be called from the coupon-generation function to define the initial distribution of coupons once generated.
    Each coupon should have a uuid

    I think this contract could be call an external function like:
    "giveUserCoupon" from the Marketplace

*/    
    
    address public MarketplaceAddress;


    constructor(address _MarketplaceAddress, address _snowflakeAddress) public {
        _constructCouponDistribution(_MarketplaceAddress, _snowflakeAddress);
    }

    function _constructCouponDistribution(address _MarketplaceAddress, address _snowflakeAddress) internal returns (bool) {

        _constructSnowflakeEINOwnable(_snowflakeAddress);

        //Actual internal construction
        MarketplaceAddress = _MarketplaceAddress;
    }

    //Function for the owner to switch the address of the CouponFeature, which is why this contract is SnowflakeEINOwnable
    function setCouponFeatureAddress(address _CouponFeatureAddress) public onlyEINOwner returns (bool) {
        CouponFeatureAddress = _CouponFeatureAddress;
    }

    /*==== Distribution Logic ====*/

    //For manual logic here, perhaps we should add an optional bytes data parameter? 
    //This would just be ABI-encoded params
    function distributeCoupon(uint256 couponID, bytes memory data) public onlyCouponFeature returns (bool) {
        return _distributeCoupon(couponID, data);
    }
    
    function _distributeCoupon(uint256 couponID, bytes memory /*/data*/) internal returns (bool) {
        Marketplace marketplace = MarketplaceInterface(MarketplaceAddress);
        //sample distribution of coupon to EIN 10
        uint256 arbitraryEIN = 10;
        marketplace.giveUserCoupon(arbitraryEIN, couponID);
        return true; 
   }   

    //Same set of functions as above, simply without data param    
    function distributeCoupon(uint256 couponID) public onlyCouponFeature returns (bool) {
        return _distributeCoupon(couponID);
    }
    
    function _distributeCoupon(uint256 couponID) internal returns (bool) {
        return false;
    }   
    


    
    modifier onlyCouponFeature() {
        require(msg.sender == CouponFeatureAddress, "Error [CouponDistribution.sol]: Sender is not CouponFeature contract");
        _;
    }
    
    
    
}
