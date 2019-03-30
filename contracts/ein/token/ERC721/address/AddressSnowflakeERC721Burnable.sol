pragma solidity ^0.5.2;

import "./AddressSnowflakeERC721.sol";

/**
 * @title Snowflake ERC721 Burnable Token
 * @dev Snowflake ERC721 Token that can be irreversibly burned (destroyed).
 */
contract AddressSnowflakeERC721Burnable is AddressSnowflakeERC721 {

/*    constructor(address _snowflakeAddress) public {
        _constructAddressSnowflakeERC721Burnable(_snowflakeAddress);
    }
  */
    function _constructAddressSnowflakeERC721Burnable(address _snowflakeAddress) internal {
        _constructAddressSnowflakeERC721(_snowflakeAddress);
    }

    /**
     * @dev Burns a specific Snowflake ERC721 token.
     * @param tokenId uint256 id of the Snowflake ERC721 token to be burned.
     */
    function burnAddress(uint256 tokenId) public {
        require(_isApprovedAddress(msg.sender, tokenId));
        _burn(tokenId);
    }
}
