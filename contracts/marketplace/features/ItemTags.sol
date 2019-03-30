pragma solidity ^0.5.0;


contract ItemTags {


    //ID    
    uint public nextItemTagsID;

    //Struct
    mapping(uint => string) public itemTags;

/*    
    constructor() public {
        _constructItemTags();
    }
*/
    function _constructItemTags() internal {
        nextItemTagsID = 1;
    }


/*
==============================
ItemTags add/update/delete
==============================
*/

    function _addItemTag(string memory itemTag) internal returns (bool) {
        //Add to deliveryMethods
        itemTags[nextItemTagsID] = itemTag;
        //Advance delivery method by one
        nextItemTagsID++;

        return true;
    }

    function _updateItemTag(uint id, string memory itemTag) internal returns (bool) {
        //Update deliveryMethods by ID
        itemTags[id] = itemTag;
        return true;
    }

    function _deleteItemTag(uint id) internal returns (bool) {

        //Delete itemListing identified by ID
        delete itemTags[id];
        return true;
    }




}
