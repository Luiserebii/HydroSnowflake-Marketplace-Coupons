pragma solidity ^0.5.0;

import "../interfaces/SnowflakeInterface.sol";
import "../interfaces/IdentityRegistryInterface.sol";

/**
* @title SnowflakeReader
* @dev Intended to provide a simple thing for contracts to extend and do things such as read EINs. For now, this is its only function, but this is needed for design purposes, IMO
*
*/
contract SnowflakeReader {
    address public snowflakeAddress;

/*    constructor(address _snowflakeAddress) public {
        _constructSnowflakeReader(_snowflakeAddress);
    }
*/
    //Function to avoid double-constructor in inheriting, sort of a work-around
    function _constructSnowflakeReader(address _snowflakeAddress) internal {
        snowflakeAddress = _snowflakeAddress;
    }

    function getEIN(address einAddress) internal returns (uint256 ein) {
        //Grab an instance of IdentityRegistry to work with as defined in Snowflake
        SnowflakeInterface si = SnowflakeInterface(snowflakeAddress);
        address iAdd = si.identityRegistryAddress();

        IdentityRegistryInterface identityRegistry = IdentityRegistryInterface(iAdd);
        //Ensure the address exists within the registry
        require(identityRegistry.hasIdentity(einAddress), "Address non-existent in IdentityRegistry");

        return identityRegistry.getEIN(einAddress);
    }


}

