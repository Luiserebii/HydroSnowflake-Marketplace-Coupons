pragma solidity ^0.5.0;

import "../marketplace/features/Coupons.sol";
import "../marketplace/features/Items.sol";
import "../marketplace/features/ItemTags.sol";
import "../marketplace/features/Delivery.sol";
import "../marketplace/features/ReturnPolicies.sol";


interface NeoCouponMarketplaceResolverInterface {

    function getItem(uint id) external view returns (uint uuid, uint quantity, ItemType itemType, ItemStatus status, ItemCondition condition, string memory title, string memory description, uint256 price, uint returnPolicy);

    function getItemDelivery(uint id, uint index) external view returns (uint);
    function getItemTag(uint id, uint index) external view returns (uint);

    //Returns delivery method at mapping ID (i.e. Fedex)
    function getDeliveryMethod(uint id) external view returns (string memory method);
    
    function getReturnPolicy(uint id) external view returns (bool returnsAccepted, uint timeLimit);
    function getCoupon(uint id) external view returns (CouponType couponType, string memory title, string memory description, uint256 amountOff, uint expirationDate);
    function getCouponItemApplicable(uint id, uint index) external view returns (uint);

    function isUserCouponOwner(uint ein, uint couponID) external view returns (bool isValid);

}
