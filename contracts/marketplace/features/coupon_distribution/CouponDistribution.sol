pragma solidity ^0.5.0;

import "../../../ein/util/SnowflakeEINOwnable.sol";
import "../../../interfaces/marketplace/features/coupon_distribution/CouponDistributionInterface.sol";
import "../CouponFeature.sol";
import "../../../interfaces/marketplace/SnowflakeEINMarketplaceInterface.sol";

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
    
    address public SnowflakeEINMarketplaceAddress;


    constructor(address _SnowflakeEINMarketplaceAddress, address _snowflakeAddress) public {
        _constructCouponDistribution(_SnowflakeEINMarketplaceAddress, _snowflakeAddress);
    }

    function _constructCouponDistribution(address _SnowflakeEINMarketplaceAddress, address _snowflakeAddress) internal returns (bool) {

        _constructSnowflakeEINOwnable(_snowflakeAddress);

        //Actual internal construction
        SnowflakeEINMarketplaceAddress = _SnowflakeEINMarketplaceAddress;
    }

    //Function for the owner to switch the address of the CouponFeature, which is why this contract is SnowflakeEINOwnable
    function setSnowflakeEINMarketplaceAddress(address _SnowflakeEINMarketplaceAddress) public onlyEINOwner returns (bool) {
        SnowflakeEINMarketplaceAddress = _SnowflakeEINMarketplaceAddress;
    }

    /*==== Distribution Logic ====*/

    //For manual logic here, perhaps we should add an optional bytes data parameter? 
    //This would just be ABI-encoded params
    function distributeCoupon(uint256 couponID, bytes memory data) public onlySnowflakeEINMarketplace returns (bool) {
        return _distributeCoupon(couponID, data);
    }
    
    function _distributeCoupon(uint256 couponID, bytes memory /*/data*/) internal returns (bool) {
        SnowflakeEINMarketplaceInterface marketplace = SnowflakeEINMarketplaceInterface(SnowflakeEINMarketplaceAddress);
        //sample distribution of coupon to EIN 10
        uint256 arbitraryEIN = 10;
        marketplace.giveUserCoupon(arbitraryEIN, couponID);
        return true; 
   }   

    //Same set of functions as above, simply without data param    
    function distributeCoupon(uint256 couponID) public onlySnowflakeEINMarketplace returns (bool) {
        return _distributeCoupon(couponID);
    }
    
    function _distributeCoupon(uint256 couponID) internal returns (bool) {
        SnowflakeEINMarketplaceInterface marketplace = SnowflakeEINMarketplaceInterface(SnowflakeEINMarketplaceAddress);
        //sample distribution of coupon to EINs 1-5
        for(uint i = 0; i < 5; i++){
            marketplace.giveUserCoupon(i+1, couponID);
        }
        return true; 
        
    }   
    


    
    modifier onlySnowflakeEINMarketplace() {
        require(msg.sender == SnowflakeEINMarketplaceAddress, "Error [CouponDistribution.sol]: Sender is not SnowflakeEINMarketplace address, as defined within the contract");
        _;
    }
    
    
    
}
