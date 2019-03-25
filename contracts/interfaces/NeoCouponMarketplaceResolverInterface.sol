pragma solidity ^0.5.0;

import "./marketplace/CouponInterface.sol";
import "./marketplace/ItemInterface.sol";

//We may just need to make this an abstract contract instead of an interface to give access to these enums, see: https://gist.github.com/Luiserebii/18a2bed267992dff8bc85703ca8fe3f3

interface NeoCouponMarketplaceResolverInterface {

//This should likely go in their respective feature interfaces
/*
    function getItem(uint id) public view returns (uint uuid, uint quantity, ItemInterface.ItemType itemType, ItemInterface.ItemStatus status, ItemInterface.ItemCondition condition, string memory title, string memory description, uint256 price, uint returnPolicy);

    function getItemDelivery(uint id, uint index) public view returns (uint);
    function getItemTag(uint id, uint index) public view returns (uint);

    //Returns delivery method at mapping ID (i.e. Fedex)
    function getDeliveryMethod(uint id) public view returns (string memory method);
    
    function getReturnPolicy(uint id) public view returns (bool returnsAccepted, uint timeLimit);
    function getCoupon(uint id) public view returns (CouponInterface.CouponType couponType, string memory title, string memory description, uint256 amountOff, uint expirationDate);
    function getCouponItemApplicable(uint id, uint index) public view returns (uint);
*/
    //This should be moved to MarketplaceInterface.sol
    //function isUserCouponOwner(uint ein, uint couponID) public view returns (bool isValid);
    function purchaseItem(uint id, address approvingAddress, uint couponID) external returns (bool);
}
