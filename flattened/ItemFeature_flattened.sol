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


interface SnowflakeInterface {
    function deposits(uint) external view returns (uint);
    function resolverAllowances(uint, address) external view returns (uint);

    function identityRegistryAddress() external returns (address);
    function hydroTokenAddress() external returns (address);
    function clientRaindropAddress() external returns (address);

    function setAddresses(address _identityRegistryAddress, address _hydroTokenAddress) external;
    function setClientRaindropAddress(address _clientRaindropAddress) external;

    function createIdentityDelegated(
        address recoveryAddress, address associatedAddress, address[] calldata providers, string calldata casedHydroId,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external returns (uint ein);
    function addProvidersFor(
        address approvingAddress, address[] calldata providers, uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;
    function removeProvidersFor(
        address approvingAddress, address[] calldata providers, uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;
    function upgradeProvidersFor(
        address approvingAddress, address[] calldata newProviders, address[] calldata oldProviders,
        uint8[2] calldata v, bytes32[2] calldata r, bytes32[2] calldata s, uint[2] calldata timestamp
    ) external;
    function addResolver(address resolver, bool isSnowflake, uint withdrawAllowance, bytes calldata extraData) external;
    function addResolverAsProvider(
        uint ein, address resolver, bool isSnowflake, uint withdrawAllowance, bytes calldata extraData
    ) external;
    function addResolverFor(
        address approvingAddress, address resolver, bool isSnowflake, uint withdrawAllowance, bytes calldata extraData,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;
    function changeResolverAllowances(address[] calldata resolvers, uint[] calldata withdrawAllowances) external;
    function changeResolverAllowancesDelegated(
        address approvingAddress, address[] calldata resolvers, uint[] calldata withdrawAllowances,
        uint8 v, bytes32 r, bytes32 s
    ) external;
    function removeResolver(address resolver, bool isSnowflake, bytes calldata extraData) external;
    function removeResolverFor(
        address approvingAddress, address resolver, bool isSnowflake, bytes calldata extraData,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;

    function triggerRecoveryAddressChangeFor(
        address approvingAddress, address newRecoveryAddress, uint8 v, bytes32 r, bytes32 s
    ) external;

    function transferSnowflakeBalance(uint einTo, uint amount) external;
    function withdrawSnowflakeBalance(address to, uint amount) external;
    function transferSnowflakeBalanceFrom(uint einFrom, uint einTo, uint amount) external;
    function withdrawSnowflakeBalanceFrom(uint einFrom, address to, uint amount) external;
    function transferSnowflakeBalanceFromVia(uint einFrom, address via, uint einTo, uint amount, bytes calldata _bytes)
        external;
    function withdrawSnowflakeBalanceFromVia(uint einFrom, address via, address to, uint amount, bytes calldata _bytes)
        external;
}

interface IdentityRegistryInterface {
    function isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
        external pure returns (bool);

    // Identity View Functions /////////////////////////////////////////////////////////////////////////////////////////
    function identityExists(uint ein) external view returns (bool);
    function hasIdentity(address _address) external view returns (bool);
    function getEIN(address _address) external view returns (uint ein);
    function isAssociatedAddressFor(uint ein, address _address) external view returns (bool);
    function isProviderFor(uint ein, address provider) external view returns (bool);
    function isResolverFor(uint ein, address resolver) external view returns (bool);
    function getIdentity(uint ein) external view returns (
        address recoveryAddress,
        address[] memory associatedAddresses, address[] memory providers, address[] memory resolvers
    );

    // Identity Management Functions ///////////////////////////////////////////////////////////////////////////////////
    function createIdentity(address recoveryAddress, address[] calldata providers, address[] calldata resolvers)
        external returns (uint ein);
    function createIdentityDelegated(
        address recoveryAddress, address associatedAddress, address[] calldata providers, address[] calldata resolvers,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external returns (uint ein);
    function addAssociatedAddress(
        address approvingAddress, address addressToAdd, uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;
    function addAssociatedAddressDelegated(
        address approvingAddress, address addressToAdd,
        uint8[2] calldata v, bytes32[2] calldata r, bytes32[2] calldata s, uint[2] calldata timestamp
    ) external;
    function removeAssociatedAddress() external;
    function removeAssociatedAddressDelegated(address addressToRemove, uint8 v, bytes32 r, bytes32 s, uint timestamp)
        external;
    function addProviders(address[] calldata providers) external;
    function addProvidersFor(uint ein, address[] calldata providers) external;
    function removeProviders(address[] calldata providers) external;
    function removeProvidersFor(uint ein, address[] calldata providers) external;
    function addResolvers(address[] calldata resolvers) external;
    function addResolversFor(uint ein, address[] calldata resolvers) external;
    function removeResolvers(address[] calldata resolvers) external;
    function removeResolversFor(uint ein, address[] calldata resolvers) external;

    // Recovery Management Functions ///////////////////////////////////////////////////////////////////////////////////
    function triggerRecoveryAddressChange(address newRecoveryAddress) external;
    function triggerRecoveryAddressChangeFor(uint ein, address newRecoveryAddress) external;
    function triggerRecovery(uint ein, address newAssociatedAddress, uint8 v, bytes32 r, bytes32 s, uint timestamp)
        external;
    function triggerDestruction(
        uint ein, address[] calldata firstChunk, address[] calldata lastChunk, bool resetResolvers
    ) external;
}

/**
* @title SnowflakeReader
* @dev Intended to provide a simple thing for contracts to extend and do things such as read EINs. For now, this is its only function, but this is needed for design purposes, IMO
*
*/
contract SnowflakeReader {
    address public snowflakeAddress;

/*    constructor(address _snowflakeAddress) public {
        _constructSnowflakeReader(_snowflakeAddress);
    }
*/
    //Function to avoid double-constructor in inheriting, sort of a work-around
    function _constructSnowflakeReader(address _snowflakeAddress) internal {
        snowflakeAddress = _snowflakeAddress;
    }

    function getEIN(address einAddress) internal returns (uint256 ein) {
        //Grab an instance of IdentityRegistry to work with as defined in Snowflake
        SnowflakeInterface si = SnowflakeInterface(snowflakeAddress);
        address iAdd = si.identityRegistryAddress();

        IdentityRegistryInterface identityRegistry = IdentityRegistryInterface(iAdd);
        //Ensure the address exists within the registry
        require(identityRegistry.hasIdentity(einAddress), "Address non-existent in IdentityRegistry");

        return identityRegistry.getEIN(einAddress);
    }


}


/**
* @title SnowflakeEINOwnable
* @dev The SnowflakeEINOwnable contract has an owner EIN, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*
* This extends the EINOwnable contract and provides the EIN authentication used through Snowflake (uses the abstraction Snowflake provides; the minor disadvantage is that this is indirectly connected to the IdentityRegistry, but could arugably be good design)
*/
contract SnowflakeEINOwnable is EINOwnable, SnowflakeReader {

    /**
    * @dev The SnowflakeEINOwnable constructor sets the original `owner` of the contract to the sender
    * account.
    */
/*    constructor(address _snowflakeAddress) public {
        _constructSnowflakeEINOwnable(_snowflakeAddress);
    }
*/
    function _constructSnowflakeEINOwnable(address _snowflakeAddress) internal {
       _constructSnowflakeReader(_snowflakeAddress);       
       _constructEINOwnable(constructorEINOwnable(msg.sender));
    }

    /**
    * @return true if address resolves to owner of the contract.
    */
    function isEINOwner() public returns(bool){
        return _isEINOwner();
    }

    function _isEINOwner() internal returns(bool) {
        return getEIN(msg.sender) == ownerEIN();
    }


    /*==========================================================================
     * Function reserved for modifying parent constructor input for EINOwnable
     *==========================================================================
     */

    function constructorEINOwnable(address sender) private returns (uint256 ein) {
        return getEIN(sender);
    }

}




/**
 * @title IERC165
 * @dev https://eips.ethereum.org/EIPS/eip-165
 */
interface IERC165 {
    /**
     * @notice Query if a contract implements an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @dev Interface identification is specified in ERC-165. This function
     * uses less than 30,000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

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

/**
 * @title Snowflake ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from Snowflake ERC721 asset contracts.
 */
contract SnowflakeERC721ReceiverInterface {
    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     * after a `safeTransfer`. This function MUST return the function selector,
     * otherwise the caller will revert the transaction. The selector to be
     * returned can be obtained as `this.onERC721Received.selector`. This
     * function MAY throw to revert and reject the transfer.
     * Note: the ERC721 contract address is always the message sender.
     * @param einOperator The EIN which called `safeTransferFrom` function
     * @param einFrom The EIN which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(uint256 einOperator, uint256 einFrom, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}

/**
* @title SafeMath
* @dev Math operations with safety checks that revert on error
*/
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the SafeMath
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */
library Counters {
    using SafeMath for uint256;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}


/**
 * @title ERC165
 * @author Matt Condon (@shrugs)
 * @dev Implements ERC165 using a lookup table.
 */
contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    /*
     * 0x01ffc9a7 ===
     *     bytes4(keccak256('supportsInterface(bytes4)'))
     */

    /**
     * @dev a mapping of interface id to whether or not it's supported
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    /**
     * @dev A contract implementing SupportsInterfaceWithLookup
     * implement ERC165 itself
     */
    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev implement supportsInterface(bytes4) using a lookup table
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev internal method for registering an interface
     */
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}

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


/**
 * @title Snowflake ERC721 Burnable Token
 * @dev Snowflake ERC721 Token that can be irreversibly burned (destroyed).
 */
contract SnowflakeERC721Burnable is SnowflakeERC721 {
/*
    constructor(address _snowflakeAddress) public {
        _constructSnowflakeERC721Burnable(_snowflakeAddress);
    }
  */
    function _constructSnowflakeERC721Burnable(address _snowflakeAddress) internal {
        _constructSnowflakeERC721(_snowflakeAddress);
    }

    /**
     * @dev Burns a specific Snowflake ERC721 token.
     * @param tokenId uint256 id of the Snowflake ERC721 token to be burned.
     */
    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(getEIN(msg.sender), tokenId));
        _burn(tokenId);
    }
}



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



/*
 * =========================
 * NOTE ABOUT THIS CONTRACT: This is a more of a "SnowflakeMinterRole" contract
 * =========================
 */

contract SnowflakeMinterRole is SnowflakeReader {
    using EINRoles for EINRoles.EINRole;

    event SnowflakeMinterAdded(uint256 indexed account);
    event SnowflakeMinterRemoved(uint256 indexed account);

    EINRoles.EINRole private _einMinters;

    //TODO: Merge in msg.sender idea somehow in a good way; Identity Registry link, perhaps?
/*
    constructor (address _snowflakeAddress) public {
        _constructSnowflakeMinterRole(_snowflakeAddress);
    }
*/
    function _constructSnowflakeMinterRole(address _snowflakeAddress) internal {
        _constructSnowflakeReader(_snowflakeAddress);
        _addSnowflakeMinter(getEIN(msg.sender));
    }

    modifier onlySnowflakeMinter() {
        require(isSnowflakeMinter(getEIN(msg.sender)));
        _;
    }

    function isSnowflakeMinter(uint256 account) public view returns (bool) {
        return _einMinters.has(account);
    }

    function addSnowflakeMinter(uint256 account) public onlySnowflakeMinter {
        _addSnowflakeMinter(account);
    }

    function renounceSnowflakeMinter() public {
        _removeSnowflakeMinter(getEIN(msg.sender));
    }

    function _addSnowflakeMinter(uint256 account) internal {
        _einMinters.add(account);
        emit SnowflakeMinterAdded(account);
    }

    function _removeSnowflakeMinter(uint256 account) internal {
        _einMinters.remove(account);
        emit SnowflakeMinterRemoved(account);
    }
}

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

interface ItemInterface {

//A simple interface for Coupon.sol

    enum ItemType { DIGITAL, PHYSICAL }

    enum ItemStatus { ACTIVE, INACTIVE }
    enum ItemCondition { NEW, LIKE_NEW, VERY_GOOD, GOOD, ACCEPTABLE }

    function getItem(uint id) external view returns (
        uint uuid,
        uint quantity,
        ItemType itemType,
        ItemStatus status,
        ItemCondition condition,
        string memory title,
        string memory description,
        uint256 price,
        uint returnPolicy
    );
 
    //For convenience, so as not to return the whole tuple
    function getItemPrice(uint id) external view returns (uint256);

    function getItemDelivery(uint id, uint index) external view returns (uint);
    function getItemTag(uint id, uint index) external view returns (uint); 

}

/*

ERC 721 ---> Coupon Interface ---> Coupon contract (w/ data + function implementations)
        ---> Item Interface ---> Item contract (w/data + function implementations)


//Use addresses to represent other ownership states; unlimited/claimable once

*/


contract Items is SnowflakeERC721, SnowflakeERC721Burnable, SnowflakeERC721Mintable, AddressSnowflakeERC721, ItemInterface {

    //ID, starting at 1
    uint public nextItemListingsID;

    //Mapping connecting ERC721 items to actual struct objects
    mapping(uint => Item) public itemListings;
/*
    constructor(address _snowflakeAddress) public {
        _constructItems(_snowflakeAddress);
    }
*/
    function _constructItems(address _snowflakeAddress) internal {

        _constructSnowflakeERC721(_snowflakeAddress);
        _constructSnowflakeERC721Burnable(_snowflakeAddress);
        _constructSnowflakeERC721Mintable(_snowflakeAddress);
        _constructAddressSnowflakeERC721(_snowflakeAddress);

        //Actual Item constructing
        nextItemListingsID = 1;
    }

    struct Item {
        uint uuid;
        uint quantity;
        ItemType itemType;
        ItemStatus status;
        ItemCondition condition;
        string title;
        string description;
        uint256 price;
        uint[] delivery; //Simply holds the ID for the delivery method, done for saving space
        uint[] tags;
        uint returnPolicy;

    }

    function getItem(uint id) public view returns (
        uint uuid,
        uint quantity,
        ItemType itemType,
        ItemStatus status,
        ItemCondition condition,
        string memory title,
        string memory description,
        uint256 price,
        uint returnPolicy
    ){

        Item memory item = itemListings[id];
        return (item.uuid, item.quantity, item.itemType, item.status, item.condition, item.title, item.description, item.price, item.returnPolicy);
    }

    //This is simply more for convenience than not
    function getItemPrice(uint id) public view returns (uint256) {
        return itemListings[id].price;
    }

    //Arguably, these functions below could be refactored via enums, but probably overkill

    function getItemDelivery(uint id, uint index) public view returns (uint) { 
        return itemListings[id].delivery[index]; 
    }

    function getItemTag(uint id, uint index) public view returns (uint) {
        return itemListings[id].tags[index];
    }

    function getItemDeliveryLength(uint id) public view returns (uint) {
        return itemListings[id].delivery.length;
    }

    function getItemTagsLength(uint id) public view returns (uint) {
        return itemListings[id].tags.length;
    }



/*
==============================
ItemListing add/update/delete
==============================
*/


    function _addItemListing (
        uint256 ein,
        uint uuid,
        uint quantity,
        ItemType itemType,
        ItemStatus status,
        ItemCondition condition,
        string memory title,
        string memory description,
        uint256 price,
        uint[] memory delivery,
        uint[] memory tags,
        uint returnPolicy
    ) internal returns (bool) {

        //Mint it as an ERC721 owned by the creator
        _mint(ein, nextItemListingsID);

        //Add to itemListings
        itemListings[nextItemListingsID] = Item(uuid, quantity, itemType, status, condition, title, description, price, delivery, tags, returnPolicy);
        //advance item by one
        nextItemListingsID++;

        return true;
    }


    //NOTE: This can be changed in a way that does not re-create an entirely new item on every call, but more complex that perhaps needed

    function _updateItemListing (
        uint id,
        uint uuid,
        uint quantity,
        ItemType itemType,
        ItemStatus status,
        ItemCondition condition,
        string memory title,
        string memory description,
        uint256 price,
        uint[] memory delivery,
        uint[] memory tags,
        uint returnPolicy
    ) internal returns (bool) {

        //Update itemListing identified by ID
        itemListings[id] = Item(uuid, quantity, itemType, status, condition, title, description, price, delivery, tags, returnPolicy);
        return true;
    }


    function _deleteItemListing(uint id) internal returns (bool) {
        //Delete itemListing identified by ID
        delete itemListings[id];

        //Finally, burn it
        _burn(id);

        return true;
    }




}





contract ItemFeature is Items, SnowflakeEINOwnable {


    constructor(address _snowflakeAddress) public {
        _constructItemFeature(_snowflakeAddress);
    
    }    

    function _constructItemFeature(address _snowflakeAddress) internal {
        _constructItems(_snowflakeAddress);
        _constructSnowflakeEINOwnable(_snowflakeAddress);
    }

/*
==============================
ItemListing add/update/delete
==============================
*/


    function addItemListing (
        uint256 ein, //The EIN to mint to (ERC721 mint(to, ___))
        uint uuid,
        uint quantity,
        ItemType itemType,
        ItemStatus status,
        ItemCondition condition,
        string memory title,
        string memory description,
        uint256 price,
        uint[] memory delivery,
        uint[] memory tags,
        uint returnPolicy
    ) public onlyEINOwner returns (bool) {
       return _addItemListing(ein, uuid, quantity, itemType, status, condition, title, description, price, delivery, tags, returnPolicy);
    }


    function updateItemListing (
        uint id,
        uint uuid,
        uint quantity,
        ItemType itemType,
        ItemStatus status,
        ItemCondition condition,
        string memory title,
        string memory description,
        uint256 price,
        uint[] memory delivery,
        uint[] memory tags,
        uint returnPolicy
    ) public onlyEINOwner returns (bool) {
       return _updateItemListing(id, uuid, quantity, itemType, status, condition, title, description, price, delivery, tags, returnPolicy);
    }

    function deleteItemListing(uint id) public onlyEINOwner returns (bool) {
        return _deleteItemListing(id);
    }



/* ====================================================

       END OF ADD/UPDATE/DELETE FUNCTIONS

   ====================================================
*/











}
