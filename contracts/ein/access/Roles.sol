pragma solidity ^0.5.2;

/**
 * @title Roles
 * @dev Library for managing EINs assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (uint256 => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, uint256 account) internal {
        require(account != 0);
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, uint256 account) internal {
        require(account != 0);
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, uint256 account) internal view returns (bool) {
        require(account != 0);
        return role.bearer[account];
    }
}
