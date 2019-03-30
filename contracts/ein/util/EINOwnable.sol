pragma solidity ^0.5.0;

/**
* @title EINOwnable
* @dev The EINOwnable contract has an owner EIN, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/
contract EINOwnable {
    uint private _ownerEIN;

    event OwnershipTransferred(
        uint indexed previousOwner,
        uint indexed newOwner
    );

    /**
    * @dev The SnowflakeEINOwnable constructor sets the original `owner` of the contract to the sender
    * account.
    */
/*    constructor(uint ein) public {
        _constructEINOwnable(ein);
    }
*/
    function _constructEINOwnable(uint ein) internal {
        _ownerEIN = ein;
        //Since 0 likely represents someone's EIN, it can be confusing to specify 0, so commenting this out in the meantime
        //CORRECTION: 0 is actually guaranteed to be no one's EIN, so this is ok! :D And even better, we can use this fact to use EIN 0 as a null/empty/burner EIN
        emit OwnershipTransferred(0, _ownerEIN);
    }

    /**
    * @return the EIN of the owner.
    */
    function ownerEIN() public view returns(uint) {
        return _ownerEIN;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyEINOwner() {
        require(isEINOwner());
        _;
    }

    /**
    * @return true if address resolves to owner of the contract.
    */
    // Removing pure to solve particular error; TODO: check later
    function isEINOwner() public returns(bool);

    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
    */
    function renounceOwnership() public onlyEINOwner {
        emit OwnershipTransferred(_ownerEIN, 0);
        _ownerEIN = 0;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(uint newOwner) public onlyEINOwner {
        _transferOwnership(newOwner);
    }

    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function _transferOwnership(uint newOwner) internal {
        require(newOwner != 0);
        emit OwnershipTransferred(_ownerEIN, newOwner);
        _ownerEIN = newOwner;
    }
}
