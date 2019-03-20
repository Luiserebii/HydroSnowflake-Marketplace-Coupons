pragma solidity ^0.5.0;

interface ItemInterface {

//A simple interface for Coupon.sol

    enum ItemType { DIGITAL, PHYSICAL }

    enum ItemStatus { ACTIVE, INACTIVE }
    enum ItemCondition { NEW, LIKE_NEW, VERY_GOOD, GOOD, ACCEPTABLE }

    function getItem(uint id) public view returns (
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

    function getItemDelivery(uint id, uint index) public view returns (uint);
    function getItemTag(uint id, uint index) public view returns (uint); 




}
