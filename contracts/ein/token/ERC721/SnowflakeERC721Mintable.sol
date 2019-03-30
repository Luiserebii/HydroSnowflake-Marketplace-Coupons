pragma solidity ^0.5.2;

import "./SnowflakeERC721.sol";
import "../../access/roles/SnowflakeMinterRole.sol";

/**
 * @title SnowflakeERC721Mintable
 * @dev Snowflake ERC721 minting logic
 */
contract SnowflakeERC721Mintable is SnowflakeERC721, SnowflakeMinterRole {

/*    constructor (address _snowflakeAddress) public {
        _constructSnowflakeERC721Mintable(_snowflakeAddress);
    }
*/
    function _constructSnowflakeERC721Mintable(address _snowflakeAddress) internal {
        _constructSnowflakeERC721(_snowflakeAddress);
        _constructSnowflakeMinterRole(_snowflakeAddress);
    }

    /**
     * @dev Function to mint tokens
     * @param to The EIN that will receive the minted tokens.
     * @param tokenId The token id to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(uint256 to, uint256 tokenId) public onlySnowflakeMinter returns (bool) {
        _mint(to, tokenId);
        return true;
    }
}
