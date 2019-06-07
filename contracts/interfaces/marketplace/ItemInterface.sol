pragma solidity ^0.5.0;

interface ItemInterface {

//A simple interface for Coupon.sol

    enum ItemType { DIGITAL, PHYSICAL }

    enum ItemStatus { ACTIVE, INACTIVE }
    enum ItemCondition { NEW, LIKE_NEW, VERY_GOOD, GOOD, ACCEPTABLE }

    function getItem(uint id) external view returns (
        uint uuid,
        uint quantity,
        ItemType itemType,
        ItemStatus status,
        ItemCondition condition,
        string memory title,
        string memory description,
        uint256 price,
        uint returnPolicy
    );
 
    //For convenience, so as not to return the whole tuple
    function getItemPrice(uint id) external view returns (uint256);

    function getItemDelivery(uint id) external view returns (uint[] memory);
    function getItemTags(uint id) external view returns (uint[] memory); 

}
