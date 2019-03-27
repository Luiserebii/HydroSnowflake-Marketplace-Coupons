pragma solidity ^0.5.2;

/**
 * @title EINRoles
 * @dev Library for managing EINs assigned to a Role.
 */
library EINRoles {
    struct EINRole {
        mapping (uint256 => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(EINRole storage role, uint256 account) internal {
        require(account != 0);
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(EINRole storage role, uint256 account) internal {
        require(account != 0);
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(EINRole storage role, uint256 account) internal view returns (bool) {
        require(account != 0);
        return role.bearer[account];
    }
}

