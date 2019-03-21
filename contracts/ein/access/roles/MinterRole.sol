pragma solidity ^0.5.2;

import "../Roles.sol";
import "../../../snowflake_custom/SnowflakeReader.sol";


/*
 * =========================
 * NOTE ABOUT THIS CONTRACT: This is a more of a "SnowflakeMinterRole" contract
 * =========================
 */

contract MinterRole is SnowflakeReader {
    using Roles for Roles.Role;

    event MinterAdded(uint256 indexed account);
    event MinterRemoved(uint256 indexed account);

    Roles.Role private _minters;

    //TODO: Merge in msg.sender idea somehow in a good way; Identity Registry link, perhaps?

    constructor (address _snowflakeAddress) SnowflakeReader(_snowflakeAddress) public {
        _addMinter(getEIN(msg.sender));
    }

    modifier onlyMinter() {
        require(isMinter(getEIN(msg.sender)));
        _;
    }

    function isMinter(uint256 account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(uint256 account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(getEIN(msg.sender));
    }

    function _addMinter(uint256 account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(uint256 account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}
