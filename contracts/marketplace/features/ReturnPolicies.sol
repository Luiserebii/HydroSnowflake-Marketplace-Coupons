pragma solidity ^0.5.0;


contract ReturnPolicies {


    //ID    
    uint public nextReturnPoliciesID;

    //Struct
    mapping(uint => ReturnPolicy) public returnPolicies;

/*    
    constructor() public {
        _constructReturnPolicies();
    }
*/
    function _constructReturnPolicies() internal {
        nextReturnPoliciesID = 1;
    }


    struct ReturnPolicy {
        bool returnsAccepted;
        uint timeLimit;
    }


    function getReturnPolicy(uint id) public view returns (bool returnsAccepted, uint timeLimit){

        ReturnPolicy memory rp = returnPolicies[id];
        return (rp.returnsAccepted, rp.timeLimit);
    }


/*
==============================
ReturnPolicy add/update/delete
==============================
*/

    function _addReturnPolicy(bool returnsAccepted, uint timeLimit) internal returns (bool) {
        //Add to returnPolicies
        returnPolicies[nextReturnPoliciesID] = ReturnPolicy(returnsAccepted, timeLimit);
        //Advance return policy ID by one
        nextReturnPoliciesID++;

        return true;
    }

    function _updateReturnPolicy(uint id, bool returnsAccepted, uint timeLimit) internal returns (bool) {
        //Update returnPolicies by ID
        returnPolicies[id] = ReturnPolicy(returnsAccepted, timeLimit);
        return true;
    }

    function _deleteReturnPolicy(uint id) internal returns (bool) {
        //Delete Return Policy identified by ID
        delete returnPolicies[id];
        return true;
    }


}
