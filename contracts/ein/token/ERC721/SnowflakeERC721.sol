pragma solidity ^0.5.2;

import "./SnowflakeERC721Interface.sol";
import "./SnowflakeERC721ReceiverInterface.sol";
import "../../../zeppelin/math/SafeMath.sol";
import "../../../zeppelin/drafts/Counters.sol";
import "../../../zeppelin/introspection/ERC165.sol";
import "../../../snowflake_custom/SnowflakeReader.sol";

/**
 * @title Snowflake ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract SnowflakeERC721 is ERC165, SnowflakeERC721Interface, SnowflakeReader {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`

    //*EDITED TO*: onERC721Received(uint256,uint256,uint256,bytes) 

    bytes4 private constant _ERC721_RECEIVED = 0x494114c2;

    // Mapping from token ID to owner
    mapping (uint256 => uint256) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => uint256) private _tokenApprovals;

    // Mapping from owner to number of owned token
    mapping (uint256 => Counters.Counter) private _ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping (uint256 => mapping (uint256 => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x4872420e;
    //This *NEW* value calculated under this logic: https://gist.github.com/Luiserebii/28c0e9c6bf2a8257868e1a1bcc030c4d
    /*NOTE: ALL OF THIS IS INVALIDATED DUE TO CHANGES:
     * 0x80ac58cd ===
     *     bytes4(keccak256('balanceOf(address)')) ^
     *     bytes4(keccak256('ownerOf(uint256)')) ^
     *     bytes4(keccak256('approve(address,uint256)')) ^
     *     bytes4(keccak256('getApproved(uint256)')) ^
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) ^
     *     bytes4(keccak256('isApprovedForAll(address,address)')) ^
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) ^
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))
     *  =========================================== END OF EVAL
     */
/*
    constructor (address _snowflakeAddress) public {
        _constructSnowflakeERC721(_snowflakeAddress);
    }
*/
    function _constructSnowflakeERC721(address _snowflakeAddress) internal {
        _constructSnowflakeReader(_snowflakeAddress);

         // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);       
    }

    /**
     * @dev Gets the balance of the specified address
     * @param owner uint256 to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(uint256 owner) public view returns (uint256) {
        require(owner != 0);
        return _ownedTokensCount[owner].current();
    }

    /**
     * @dev Gets the owner of the specified token ID
     * @param tokenId uint256 ID of the token to query the owner of
     * @return uint256 currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 tokenId) public view returns (uint256) {
        uint256 owner = _tokenOwner[tokenId];
        require(owner != 0);
        return owner;
    }

    /**
     * @dev Approves another EIN to transfer the given token ID
     * The zero EIN indicates there is no approved EIN.
     * There can only be one approved EIN per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param to uint256 to be approved for the given token ID
     * @param tokenId uint256 ID of the token to be approved
     */
    function approve(uint256 to, uint256 tokenId) public {
        uint256 owner = ownerOf(tokenId);
        uint256 sender = getEIN(msg.sender);
        require(to != owner);
        require(sender == owner || isApprovedForAll(owner, sender));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev Gets the approved EIN for a token ID, or zero if no EIN set
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to query the approval of
     * @return EIN currently approved for the given token ID
     */
    function getApproved(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf
     * @param to operator EIN to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(uint256 to, bool approved) public {
        uint256 sender = getEIN(msg.sender);
        require(to != sender);
        _operatorApprovals[sender][to] = approved;
        emit ApprovalForAll(sender, to, approved);
    }

    /**
     * @dev Tells whether an operator is approved by a given owner
     * @param owner owner EIN which you want to query the approval of
     * @param operator operator EIN which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function isApprovedForAll(uint256 owner, uint256 operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address
     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function transferFrom(uint256 from, uint256 to, uint256 tokenId) public {
        require(_isApprovedOrOwner(getEIN(msg.sender), tokenId));

        _transferFrom(from, to, tokenId);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another EIN
     * If the target EIN is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from uint256 current owner of the token
     * @param to uint256 to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function safeTransferFrom(uint256 from, uint256 to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another EIN
     * If the target EIN is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to uint256 to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(uint256 from, uint256 to, uint256 tokenId, bytes memory _data) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }

    /**
     * @dev Returns whether the specified token exists
     * @param tokenId uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        uint256 owner = _tokenOwner[tokenId];
        return owner != 0;
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID
     * @param spender uint256 of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(uint256 spender, uint256 tokenId) internal view returns (bool) {
        uint256 owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Internal function to mint a new token
     * Reverts if the given token ID already exists
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(uint256 to, uint256 tokenId) internal {
        require(to != 0);
        require(!_exists(tokenId));

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(0, to, tokenId);
    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * Deprecated, use _burn(uint256) instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(uint256 owner, uint256 tokenId) internal {
        require(ownerOf(tokenId) == owner);

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = 0;

        emit Transfer(owner, 0, tokenId);
    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(uint256 tokenId) internal {
        _burn(ownerOf(tokenId), tokenId);
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to transferFrom, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to uint256 to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transferFrom(uint256 from, uint256 to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from);
        require(to != 0);

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Internal function to invoke `onERC721Received` on a target EIN
     * The call is not executed if the target address is not a contract
     * @param from uint256 representing the previous owner of the given token ID
     * @param to target uint256 that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(uint256 from, uint256 to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {
/*        if (!to.isContract()) {
            return true;
        }
*/
        bytes4 retval = SnowflakeERC721ReceiverInterface(to).onERC721Received(getEIN(msg.sender), from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    /**
     * @dev Private function to clear current approval of a given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != 0) {
            _tokenApprovals[tokenId] = 0;
        }
    }
}
