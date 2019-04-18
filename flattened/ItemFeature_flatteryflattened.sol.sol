pragma solidity ^0.5.0;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
// input  /home/luiserebii/github/HydroSnowflake-Marketplace-Coupons/contracts/marketplace/features/ItemFeature.sol
// flattened :  Thursday, 18-Apr-19 01:28:20 UTC
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

