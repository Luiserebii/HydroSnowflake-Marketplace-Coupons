pragma solidity ^0.5.0;


contract Delivery {


    //ID    
    uint public nextDeliveryMethodsID;

    //Struct
    mapping(uint => string) public deliveryMethods;

    constructor() public {
        nextDeliveryMethodsID = 1;
    }


    function getDeliveryMethod(uint id) public view returns (string memory method){
        return (deliveryMethods[id]);
    }


/*
==================================
DeliveryMethods add/update/delete
==================================
*/

    function addDeliveryMethod(string memory deliveryMethod) public onlyEINOwner returns (bool) {
        //Add to deliveryMethods
        deliveryMethods[nextDeliveryMethodsID] = deliveryMethod;
        //Advance delivery method by one
        nextDeliveryMethodsID++;

        return true;
    }

    function updateDeliveryMethod(uint id, string memory deliveryMethod) public onlyEINOwner returns (bool) {
        //Update deliveryMethods by ID
        deliveryMethods[id] = deliveryMethod;
        return true;
    }

    function deleteDeliveryMethod(uint id) public onlyEINOwner returns (bool) {

        //Delete itemListing identified by ID
        delete deliveryMethods[id];
        return true;
    }


}
