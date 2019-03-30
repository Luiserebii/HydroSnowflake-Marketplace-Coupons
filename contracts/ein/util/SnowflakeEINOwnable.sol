pragma solidity ^0.5.0;

import "./EINOwnable.sol";
import "../../snowflake_custom/SnowflakeReader.sol";

/**
* @title SnowflakeEINOwnable
* @dev The SnowflakeEINOwnable contract has an owner EIN, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*
* This extends the EINOwnable contract and provides the EIN authentication used through Snowflake (uses the abstraction Snowflake provides; the minor disadvantage is that this is indirectly connected to the IdentityRegistry, but could arugably be good design)
*/
contract SnowflakeEINOwnable is EINOwnable, SnowflakeReader {

    /**
    * @dev The SnowflakeEINOwnable constructor sets the original `owner` of the contract to the sender
    * account.
    */
/*    constructor(address _snowflakeAddress) public {
        _constructSnowflakeEINOwnable(_snowflakeAddress);
    }
*/
    function _constructSnowflakeEINOwnable(address _snowflakeAddress) internal {
       _constructSnowflakeReader(_snowflakeAddress);       
       _constructEINOwnable(constructorEINOwnable(msg.sender));
    }

    /**
    * @return true if address resolves to owner of the contract.
    */
    function isEINOwner() public returns(bool){
        return _isEINOwner();
    }

    function _isEINOwner() internal returns(bool) {
        return getEIN(msg.sender) == ownerEIN();
    }


    /*==========================================================================
     * Function reserved for modifying parent constructor input for EINOwnable
     *==========================================================================
     */

    function constructorEINOwnable(address sender) private returns (uint256 ein) {
        return getEIN(sender);
    }

}
