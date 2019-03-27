pragma solidity ^0.5.2;

import "../Roles.sol";
import "../../../snowflake_custom/SnowflakeReader.sol";


/*
 * =========================
 * NOTE ABOUT THIS CONTRACT: This is a more of a "SnowflakeMinterRole" contract
 * =========================
 */

contract SnowflakeMinterRole is SnowflakeReader {
    using Roles for Roles.Role;

    event MinterAdded(uint256 indexed account);
    event MinterRemoved(uint256 indexed account);

    Roles.Role private _einMinters;

    //TODO: Merge in msg.sender idea somehow in a good way; Identity Registry link, perhaps?

    constructor (address _snowflakeAddress) public {
        _constructMinterRole(_snowflakeAddress);
    }
  
    function _constructMinterRole(address _snowflakeAddress) internal {
        _constructSnowflakeReader(_snowflakeAddress);
        _addMinter(getEIN(msg.sender));
    }

    modifier onlyMinter() {
        require(isMinter(getEIN(msg.sender)));
        _;
    }

    function isMinter(uint256 account) public view returns (bool) {
        return _einMinters.has(account);
    }

    function addMinter(uint256 account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(getEIN(msg.sender));
    }

    function _addMinter(uint256 account) internal {
        _einMinters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(uint256 account) internal {
        _einMinters.remove(account);
        emit MinterRemoved(account);
    }
}
