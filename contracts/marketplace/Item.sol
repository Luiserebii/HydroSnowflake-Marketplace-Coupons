pragma solidity ^0.5.0;

import '../zeppelin/token/ERC721/ERC721Full.sol';
import '../interfaces/marketplace/ItemInterface.sol';

/*

ERC 721 ---> Coupon Interface ---> Coupon contract (w/ data + function implementations)
        ---> Item Interface ---> Item contract (w/data + function implementations)


//Use addresses to represent other ownership states; unlimited/claimable once

*/


contract Item is ERC721Full, ItemInterface {


    //Mapping connecting ERC721 items to actual struct objects
    mapping(uint => Item) public itemListings;

    constructor(string memory name, string memory symbol) public ERC721Full(name, symbol){
        //stuff here
    }


   struct Item {
        uint uuid;
        uint quantity;
        ItemType itemType;
        ItemStatus status;
        ItemCondition condition;
        string title;
        string description;
        uint256 price;
        uint[] delivery; //Simply holds the ID for the delivery method, done for saving space
        uint[] tags;
        uint returnPolicy;

    }

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
    ){

        Item memory item = itemListings[id];
        return (item.uuid, item.quantity, item.itemType, item.status, item.condition, item.title, item.description, item.price, item.returnPolicy);
    }

    function getItemDelivery(uint id, uint index) public view returns (uint) { 
        return itemListings[id].delivery[index]; 
    }

    function getItemTag(uint id, uint index) public view returns (uint) {
        return itemListings[id].tags[index];
    }



}



