pragma solidity ^0.5.2;

import "../../../zeppelin/introspection/IERC165.sol";

/**
 * @title Snowflake ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
//ISnowflakeEINERC721 vs. SnowflakeEINERC721Interface; for the sake of consistency, we will keep this probably terrible naming
//Making it SnowflakeERC721Interface for concision
//TODO: This will likely conflict with "ownerEIN" naming in SnowflakeEINOwnable, if we use einOwner; correct down the line
contract SnowflakeERC721Interface is IERC165 {
    event Transfer(uint256 indexed einFrom, uint256 indexed einTo, uint256 indexed tokenId);
    event Approval(uint256 indexed einOwner, uint256 indexed einApproved, uint256 indexed tokenId);
    event ApprovalForAll(uint256 indexed einOwner, uint256 indexed einOperator, bool approved);

    function balanceOf(uint einOwner) public view returns (uint256 balance);
    function ownerOf(uint256 tokenId) public view returns (uint256 einOwner);

    function approve(uint256 einTo, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (uint256 einOperator);

    function setApprovalForAll(uint256 einOperator, bool _approved) public;
    function isApprovedForAll(uint256 einOwner, uint256 einOperator) public view returns (bool);

    function transferFrom(uint256 einFrom, uint256 einTo, uint256 tokenId) public;
    function safeTransferFrom(uint256 einFrom, uint256 einTo, uint256 tokenId) public;

    function safeTransferFrom(uint256 einFrom, uint256 einTo, uint256 tokenId, bytes memory data) public;
}
