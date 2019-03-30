pragma solidity ^0.5.0;

import "../../ein/util/SnowflakeEINOwnable.sol";
import "./Items.sol";


contract ItemFeature is Items, SnowflakeEINOwnable {


    constructor(address _snowflakeAddress) public {
        _constructItemFeature(_snowflakeAddress);
    
    }    

    function _constructItemFeature(address _snowflakeAddress) internal {
        _constructItems(_snowflakeAddress);
        _constructSnowflakeEINOwnable(_snowflakeAddress);
    }

/*
==============================
ItemListing add/update/delete
==============================
*/


    function addItemListing (
        uint256 ein, //The EIN to mint to (ERC721 mint(to, ___))
        uint uuid,
        uint quantity,
        ItemType itemType,
        ItemStatus status,
        ItemCondition condition,
        string memory title,
        string memory description,
        uint256 price,
        uint[] memory delivery,
        uint[] memory tags,
        uint returnPolicy
    ) public onlyEINOwner returns (bool) {
       return _addItemListing(ein, uuid, quantity, itemType, status, condition, title, description, price, delivery, tags, returnPolicy);
    }


    function updateItemListing (
        uint id,
        uint uuid,
        uint quantity,
        ItemType itemType,
        ItemStatus status,
        ItemCondition condition,
        string memory title,
        string memory description,
        uint256 price,
        uint[] memory delivery,
        uint[] memory tags,
        uint returnPolicy
    ) public onlyEINOwner returns (bool) {
       return _updateItemListing(id, uuid, quantity, itemType, status, condition, title, description, price, delivery, tags, returnPolicy);
    }

    function deleteItemListing(uint id) public onlyEINOwner returns (bool) {
        return _deleteItemListing(id);
    }



/* ====================================================

       END OF ADD/UPDATE/DELETE FUNCTIONS

   ====================================================
*/











}
