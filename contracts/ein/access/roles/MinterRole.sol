pragma solidity ^0.5.2;

import "../Roles.sol";

contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(uint256 indexed account);
    event MinterRemoved(uint256 indexed account);

    Roles.Role private _minters;

    //TODO: Merge in msg.sender idea somehow in a good way; Identity Registry link, perhaps?

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(uint256 account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(uint256 account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
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
