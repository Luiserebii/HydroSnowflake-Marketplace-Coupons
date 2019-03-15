pragma solidity ^0.5.0;

contract CouponMarketplaceResolverInterface {

    enum ItemType { DIGITAL, PHYSICAL }
    
    enum ItemStatus { ACTIVE, INACTIVE }
    enum ItemCondition { NEW, LIKE_NEW, VERY_GOOD, GOOD, ACCEPTABLE }
    enum CouponType { AMOUNT_OFF, PERCENTAGE_OFF, BUY_X_QTY_GET_Y_FREE, BUY_X_QTY_FOR_Y_AMNT }

   
    function getItem(uint id) public view returns (uint uuid, uint quantity, ItemType itemType, ItemStatus status, ItemCondition condition, string memory title, string memory description, uint256 price, uint returnPolicy);

    function getItemDelivery(uint id, uint index) public view returns (uint);
    function getItemTag(uint id, uint index) public view returns (uint);

    //Returns delivery method at mapping ID (i.e. Fedex)
    function getDeliveryMethod(uint id) public view returns (string memory method);
    
    function getReturnPolicy(uint id) public view returns (bool returnsAccepted, uint timeLimit);
    function getCoupon(uint id) public view returns (CouponType couponType, string memory title, string memory description, uint256 amountOff, uint expirationDate);
    function getCouponItemApplicable(uint id, uint index) public view returns (uint);

    function isUserCouponOwner(uint id) public view returns (bool isValid);



}
