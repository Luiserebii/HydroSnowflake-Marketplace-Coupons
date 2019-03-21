pragma solidity ^0.5.2;

import "./SnowflakeERC721.sol";

/**
 * @title Snowflake ERC721 Burnable Token
 * @dev Snowflake ERC721 Token that can be irreversibly burned (destroyed).
 */
contract SnowflakeERC721Burnable is SnowflakeERC721 {
    /**
     * @dev Burns a specific Snowflake ERC721 token.
     * @param tokenId uint256 id of the Snowflake ERC721 token to be burned.
     */
    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId));
        _burn(tokenId);
    }
}
