pragma solidity ^0.5.0;


contract ItemTags {


    //ID    
    uint public nextItemTagsID;

    //Struct
    mapping(uint => string) public itemTags;

    
    constructor() public {
        nextItemTagsID = 1;
    }


/*
==============================
ItemTags add/update/delete
==============================
*/

    function addItemTag(string memory itemTag) public onlyEINOwner returns (bool) {
        //Add to deliveryMethods
        itemTags[nextItemTagsID] = itemTag;
        //Advance delivery method by one
        nextItemTagsID++;

        return true;
    }

    function updateItemTag(uint id, string memory itemTag) public onlyEINOwner returns (bool) {
        //Update deliveryMethods by ID
        itemTags[id] = itemTag;
        return true;
    }

    function deleteItemTag(uint id) public onlyEINOwner returns (bool) {

        //Delete itemListing identified by ID
        delete itemTags[id];
        return true;
    }




}
