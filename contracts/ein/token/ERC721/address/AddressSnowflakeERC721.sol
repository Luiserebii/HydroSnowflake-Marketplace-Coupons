pragma solidity ^0.5.2;

import "../SnowflakeERC721.sol";

/**
 * @title Address Snowflake ERC721; Non-Fungible Token Standard basic implementation, but with address owning
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract AddressSnowflakeERC721 is SnowflakeERC721 {



    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovalsAddress;

/*    constructor (address _snowflakeAddress) public {
        _constructAddressSnowflakeERC721(_snowflakeAddress);
    }
*/
    function _constructAddressSnowflakeERC721(address _snowflakeAddress) internal {
        _constructSnowflakeERC721(_snowflakeAddress);
    }


    /**
     * @dev Approves an address to transfer the given token ID
     * The zero address indicates there is no approved EIN.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param to address to be approved for the given token ID
     * @param tokenId uint256 ID of the token to be approved
     */
    function approveAddress(address to, uint256 tokenId) public {
        uint256 owner = ownerOf(tokenId);
        uint256 sender = getEIN(msg.sender);
        //require(to != owner);  <--- We likely don't need this, let's just let any address be a potential approved one
        require(sender == owner || isApprovedForAll(owner, sender), 'Sender is not owner, or fails to pass isApprovedForAll(owner, sender)');

        _tokenApprovalsAddress[tokenId] = to;
        emit ApprovalAddress(owner, to, tokenId);
    }

    /**
     * @dev Gets the approved address for a token ID, or zero if no EIN set
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to query the approval of
     * @return address currently approved for the given token ID
     */
    function getApprovedAddress(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId));
        return _tokenApprovalsAddress[tokenId];
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address
     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function transferFromAddress(uint256 from, uint256 to, uint256 tokenId) public {
        require(_isApprovedAddress(msg.sender, tokenId));

        _transferFromAddress(from, to, tokenId);
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
    function safeTransferFromAddress(uint256 from, uint256 to, uint256 tokenId) public {
        safeTransferFromAddress(from, to, tokenId, "");
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another EIN
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to uint256 to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFromAddress(uint256 from, uint256 to, uint256 tokenId, bytes memory _data) public {
        transferFromAddress(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isApprovedAddress(address spender, uint256 tokenId) internal view returns (bool) {
        /*uint256 owner = ownerOf(tokenId);*/
        return (getApprovedAddress(tokenId) == spender /*|| isApprovedForAll(owner, spender)*/);
    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * Overriding the regular _burn to also ensure to clear any addresses that happen to be approved
     * Deprecated, use _burn(uint256) instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned
     */
    function _burnAddress(uint256 owner, uint256 tokenId) internal {

        //The way this is written, this is technically done twice, not sure if this is the best design?
        require(ownerOf(tokenId) == owner);

//        _clearApproval(tokenId);
        _clearApprovalAddress(tokenId);
/*
        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = 0;

        emit Transfer(owner, 0, tokenId);*/
        _burn(owner, tokenId);

    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * @param tokenId uint256 ID of the token being burned
     */
    function _burnAddress(uint256 tokenId) internal {
        _burnAddress(ownerOf(tokenId), tokenId);
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to transferFrom, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to uint256 to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transferFromAddress(uint256 from, uint256 to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from);
        require(to != 0);

        _clearApprovalAddress(tokenId);
/*
        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);*/
        _transferFrom(from, to, tokenId);

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
/*    function _checkOnERC721Received(uint256 from, uint256 to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = SnowflakeERC721ReceiverInterface(to).onERC721Received(getEIN(msg.sender), from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }
*/
    /**
     * @dev Private function to clear current approval of a given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _clearApprovalAddress(uint256 tokenId) private {
        if (_tokenApprovalsAddress[tokenId] != address(0)) {
            _tokenApprovalsAddress[tokenId] = address(0);
        }
    }

    //Move this to an interface
    event ApprovalAddress(uint256 owner, address to, uint256 tokenId);

}
