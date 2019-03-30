pragma solidity ^0.5.2;

import "../EINRoles.sol";
import "../../../snowflake_custom/SnowflakeReader.sol";


/*
 * =========================
 * NOTE ABOUT THIS CONTRACT: This is a more of a "SnowflakeMinterRole" contract
 * =========================
 */

contract SnowflakeMinterRole is SnowflakeReader {
    using EINRoles for EINRoles.EINRole;

    event SnowflakeMinterAdded(uint256 indexed account);
    event SnowflakeMinterRemoved(uint256 indexed account);

    EINRoles.EINRole private _einMinters;

    //TODO: Merge in msg.sender idea somehow in a good way; Identity Registry link, perhaps?
/*
    constructor (address _snowflakeAddress) public {
        _constructSnowflakeMinterRole(_snowflakeAddress);
    }
*/
    function _constructSnowflakeMinterRole(address _snowflakeAddress) internal {
        _constructSnowflakeReader(_snowflakeAddress);
        _addSnowflakeMinter(getEIN(msg.sender));
    }

    modifier onlySnowflakeMinter() {
        require(isSnowflakeMinter(getEIN(msg.sender)));
        _;
    }

    function isSnowflakeMinter(uint256 account) public view returns (bool) {
        return _einMinters.has(account);
    }

    function addSnowflakeMinter(uint256 account) public onlySnowflakeMinter {
        _addSnowflakeMinter(account);
    }

    function renounceSnowflakeMinter() public {
        _removeSnowflakeMinter(getEIN(msg.sender));
    }

    function _addSnowflakeMinter(uint256 account) internal {
        _einMinters.add(account);
        emit SnowflakeMinterAdded(account);
    }

    function _removeSnowflakeMinter(uint256 account) internal {
        _einMinters.remove(account);
        emit SnowflakeMinterRemoved(account);
    }
}
