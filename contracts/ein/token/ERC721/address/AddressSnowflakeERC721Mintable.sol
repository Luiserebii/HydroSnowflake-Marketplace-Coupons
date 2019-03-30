pragma solidity ^0.5.2;

import "./AddressSnowflakeERC721.sol";
import "../../../../zeppelin/access/roles/MinterRole.sol";

/**
 * @title SnowflakeERC721Mintable
 * @dev Snowflake ERC721 minting logic
 */
contract AddressSnowflakeERC721Mintable is AddressSnowflakeERC721, MinterRole {

/*    constructor (address _snowflakeAddress) public {
        _constructAddressSnowflakeERC721Mintable(_snowflakeAddress);
    }
*/
    function _constructAddressSnowflakeERC721Mintable(address _snowflakeAddress) internal {
        _constructAddressSnowflakeERC721(_snowflakeAddress);
    }

    /**
     * @dev Function to mint tokens
     * @param to The EIN that will receive the minted tokens.
     * @param tokenId The token id to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mintAddress(uint256 to, uint256 tokenId) public onlyMinter returns (bool) {
        _mint(to, tokenId);
        return true;
    }
}
