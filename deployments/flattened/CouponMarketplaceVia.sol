
// File: contracts/zeppelin/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/
contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
    * @return the address of the owner.
    */
    function owner() public view returns(address) {
        return _owner;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
    * @return true if `msg.sender` is the owner of the contract.
    */
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }

    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/interfaces/SnowflakeViaInterface.sol

pragma solidity ^0.5.0;

interface SnowflakeViaInterface {
    function snowflakeCall(address resolver, uint einFrom, uint einTo, uint amount, bytes calldata snowflakeCallBytes)
        external;
    function snowflakeCall(
        address resolver, uint einFrom, address payable to, uint amount, bytes calldata snowflakeCallBytes
    ) external;
    function snowflakeCall(address resolver, uint einTo, uint amount, bytes calldata snowflakeCallBytes) external;
    function snowflakeCall(address resolver, address payable to, uint amount, bytes calldata snowflakeCallBytes)
        external;
}

// File: contracts/SnowflakeVia.sol

pragma solidity ^0.5.0;



contract SnowflakeVia is Ownable {
    address public snowflakeAddress;

    constructor(address _snowflakeAddress) public {
        setSnowflakeAddress(_snowflakeAddress);
    }

    modifier senderIsSnowflake() {
        require(msg.sender == snowflakeAddress, "Did not originate from Snowflake.");
        _;
    }

    // this can be overriden to initialize other variables, such as e.g. an ERC20 object to wrap the HYDRO token
    function setSnowflakeAddress(address _snowflakeAddress) public onlyOwner {
        snowflakeAddress = _snowflakeAddress;
    }

    // all snowflakeCall functions **must** use the senderIsSnowflake modifier, because otherwise there is no guarantee
    // that HYDRO tokens were actually sent to this smart contract prior to the snowflakeCall. Further accounting checks
    // of course make this possible to check, but since this is tedious and a low value-add,
    // it's officially not recommended
    function snowflakeCall(address resolver, uint einFrom, uint einTo, uint amount, bytes memory snowflakeCallBytes)
        public;
    function snowflakeCall(
        address resolver, uint einFrom, address payable to, uint amount, bytes memory snowflakeCallBytes
    ) public;
    function snowflakeCall(address resolver, uint einTo, uint amount, bytes memory snowflakeCallBytes) public;
    function snowflakeCall(address resolver, address payable to, uint amount, bytes memory snowflakeCallBytes) public;
}

// File: contracts/interfaces/SnowflakeResolverInterface.sol

pragma solidity ^0.5.0;

interface SnowflakeResolverInterface {
    function callOnAddition() external view returns (bool);
    function callOnRemoval() external view returns (bool);
    function onAddition(uint ein, uint allowance, bytes calldata extraData) external returns (bool);
    function onRemoval(uint ein, bytes calldata extraData) external returns (bool);
}

// File: contracts/zeppelin/math/SafeMath.sol

pragma solidity ^0.5.0;

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

// File: contracts/interfaces/CouponMarketplaceResolverInterface.sol

pragma solidity ^0.5.0;

interface CouponMarketplaceResolverInterface {

    enum ItemType { DIGITAL, PHYSICAL }
    
    enum ItemStatus { ACTIVE, INACTIVE }
    enum ItemCondition { NEW, LIKE_NEW, VERY_GOOD, GOOD, ACCEPTABLE }
    enum CouponType { AMOUNT_OFF, PERCENTAGE_OFF, BUY_X_QTY_GET_Y_FREE, BUY_X_QTY_FOR_Y_AMNT }

   
    function getItem(uint id) external view returns (uint uuid, uint quantity, ItemType itemType, ItemStatus status, ItemCondition condition, string memory title, string memory description, uint256 price, uint returnPolicy);

    function getItemDelivery(uint id, uint index) external view returns (uint);
    function getItemTag(uint id, uint index) external view returns (uint);

    //Returns delivery method at mapping ID (i.e. Fedex)
    function getDeliveryMethod(uint id) external view returns (string memory method);
    
    function getReturnPolicy(uint id) external view returns (bool returnsAccepted, uint timeLimit);
    function getCoupon(uint id) external view returns (CouponType couponType, string memory title, string memory description, uint256 amountOff, uint expirationDate);
    function getCouponItemApplicable(uint id, uint index) external view returns (uint);

    function isUserCouponOwner(uint ein, uint couponID) external view returns (bool isValid);



}

// File: contracts/interfaces/SnowflakeInterface.sol

pragma solidity ^0.5.0;

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

// File: contracts/ein/util/EINOwnable.sol

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

// File: contracts/interfaces/IdentityRegistryInterface.sol

pragma solidity ^0.5.0;

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

// File: contracts/snowflake_custom/SnowflakeReader.sol

pragma solidity ^0.5.0;



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

// File: contracts/ein/util/SnowflakeEINOwnable.sol

pragma solidity ^0.5.0;



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

// File: contracts/marketplace/features/ItemTags.sol

pragma solidity ^0.5.0;


contract ItemTags {


    //ID    
    uint public nextItemTagsID;

    //Struct
    mapping(uint => string) public itemTags;

/*    
    constructor() public {
        _constructItemTags();
    }
*/
    function _constructItemTags() internal {
        nextItemTagsID = 1;
    }


/*
==============================
ItemTags add/update/delete
==============================
*/

    function _addItemTag(string memory itemTag) internal returns (bool) {
        //Add to deliveryMethods
        itemTags[nextItemTagsID] = itemTag;
        //Advance delivery method by one
        nextItemTagsID++;

        return true;
    }

    function _updateItemTag(uint id, string memory itemTag) internal returns (bool) {
        //Update deliveryMethods by ID
        itemTags[id] = itemTag;
        return true;
    }

    function _deleteItemTag(uint id) internal returns (bool) {

        //Delete itemListing identified by ID
        delete itemTags[id];
        return true;
    }




}

// File: contracts/marketplace/features/Delivery.sol

pragma solidity ^0.5.0;


contract Delivery {


    //ID    
    uint public nextDeliveryMethodsID;

    //Struct
    mapping(uint => string) public deliveryMethods;
/*
    constructor() public {
        _constructDelivery();
    }
*/
    function _constructDelivery() internal {
        nextDeliveryMethodsID = 1;
    }

    function getDeliveryMethod(uint id) public view returns (string memory method){
        return (deliveryMethods[id]);
    }


/*
==================================
DeliveryMethods add/update/delete
==================================
*/

    function _addDeliveryMethod(string memory deliveryMethod) internal returns (bool) {
        //Add to deliveryMethods
        deliveryMethods[nextDeliveryMethodsID] = deliveryMethod;
        //Advance delivery method by one
        nextDeliveryMethodsID++;

        return true;
    }

    function _updateDeliveryMethod(uint id, string memory deliveryMethod) internal returns (bool) {
        //Update deliveryMethods by ID
        deliveryMethods[id] = deliveryMethod;
        return true;
    }

    function _deleteDeliveryMethod(uint id) internal returns (bool) {

        //Delete itemListing identified by ID
        delete deliveryMethods[id];
        return true;
    }


}

// File: contracts/marketplace/features/ReturnPolicies.sol

pragma solidity ^0.5.0;


contract ReturnPolicies {


    //ID    
    uint public nextReturnPoliciesID;

    //Struct
    mapping(uint => ReturnPolicy) public returnPolicies;

/*    
    constructor() public {
        _constructReturnPolicies();
    }
*/
    function _constructReturnPolicies() internal {
        nextReturnPoliciesID = 1;
    }


    struct ReturnPolicy {
        bool returnsAccepted;
        uint timeLimit;
    }


    function getReturnPolicy(uint id) public view returns (bool returnsAccepted, uint timeLimit){

        ReturnPolicy memory rp = returnPolicies[id];
        return (rp.returnsAccepted, rp.timeLimit);
    }


/*
==============================
ReturnPolicy add/update/delete
==============================
*/

    function _addReturnPolicy(bool returnsAccepted, uint timeLimit) internal returns (bool) {
        //Add to returnPolicies
        returnPolicies[nextReturnPoliciesID] = ReturnPolicy(returnsAccepted, timeLimit);
        //Advance return policy ID by one
        nextReturnPoliciesID++;

        return true;
    }

    function _updateReturnPolicy(uint id, bool returnsAccepted, uint timeLimit) internal returns (bool) {
        //Update returnPolicies by ID
        returnPolicies[id] = ReturnPolicy(returnsAccepted, timeLimit);
        return true;
    }

    function _deleteReturnPolicy(uint id) internal returns (bool) {
        //Delete Return Policy identified by ID
        delete returnPolicies[id];
        return true;
    }


}

// File: contracts/interfaces/marketplace/MarketplaceInterface.sol

pragma solidity ^0.5.0;

interface MarketplaceInterface {

    function paymentAddress() external view returns (address);
    function isUserCouponOwner(uint ein, uint couponID) external view returns (bool);

}

// File: contracts/marketplace/Marketplace.sol

pragma solidity ^0.5.0;





contract Marketplace is ItemTags, Delivery, ReturnPolicies, MarketplaceInterface {

    address private _paymentAddress;
    address public CouponFeatureAddress;
    address public ItemFeatureAddress;
    address public CouponDistributionAddress;
  

    //EIN to Coupon UUID mapping
    // EIN => (couponID => bool)
    mapping(uint => mapping(uint => bool)) public userCoupons;

/*
    constructor(address paymentAddress, address _CouponFeatureAddress, address _ItemFeatureAddress) public { 
        _constructMarketplace(paymentAddress, _CouponFeatureAddress, _ItemFeatureAddress);
    }
*/
    function _constructMarketplace(address paymentAddress, address _CouponFeatureAddress, address _ItemFeatureAddress/*, address _snowflakeAddress*/) internal {
        //Constructing parent contracts
        _constructItemTags();
        _constructDelivery();
        _constructReturnPolicies();

        //Set contract-specific private/internal vars
        _paymentAddress = paymentAddress;
        CouponFeatureAddress = _CouponFeatureAddress;
        ItemFeatureAddress = _ItemFeatureAddress;
        
    }


    function paymentAddress() public view returns (address) {
        return _paymentAddress;
    }

    function isUserCouponOwner(uint ein, uint couponID) public view returns (bool isValid) {
        return userCoupons[ein][couponID];
    }



    function _giveUserCoupon(uint ein, uint couponID) internal returns (bool) {
        userCoupons[ein][couponID] = true;
        return true;
    }
     

    //TODO: Add event here
    function _setPaymentAddress(address addr) internal returns (bool) {
        _paymentAddress = addr;
        return true;
    }

    function _setCouponFeatureAddress(address _CouponFeatureAddress) internal returns (bool) {
        CouponFeatureAddress = _CouponFeatureAddress;
        return true;
    }

    function _setItemFeatureAddress(address _ItemFeatureAddress) internal returns (bool) {
        ItemFeatureAddress = _ItemFeatureAddress;
        return true;
    }

    function _setCouponDistributionAddress(address _CouponDistributionAddress) internal returns (bool) {
        CouponDistributionAddress = _CouponDistributionAddress;
        return true;
    }


    modifier onlyCouponDistribution() {
        require(msg.sender == CouponDistributionAddress);
        _;
    }




//EXTRA MARKETPLACE:


    struct DeliveryDetails {
        uint method;
        uint handlingTime;
        string trackingNumber;
    }





}

// File: contracts/interfaces/marketplace/SnowflakeEINMarketplaceInterface.sol

pragma solidity ^0.5.0;

interface SnowflakeEINMarketplaceInterface {

    function setPaymentAddress(address paymentAddress) external returns (bool);
    function setCouponDistributionAddress(address _CouponDistributionAddress) external returns (bool);
    function giveUserCoupon(uint ein, uint couponID) external returns (bool);

}

// File: contracts/interfaces/marketplace/CouponInterface.sol

pragma solidity ^0.5.0;

interface CouponInterface {

//A simple interface for Coupon.sol


    enum CouponType { AMOUNT_OFF, PERCENTAGE_OFF, BUY_X_QTY_GET_Y_FREE, BUY_X_QTY_FOR_Y_AMNT }
/*
    function getCoupon(uint id) external view returns (CouponType couponType, string memory title, string memory description, uint256 amountOff, uint expirationDate);*/
    function getCouponItemsApplicable(uint id) external view returns (uint[] memory);
    function getCouponDistributionAddress(uint id) external view returns (address);

}

// File: contracts/interfaces/marketplace/features/coupon_distribution/CouponDistributionInterface.sol

pragma solidity ^0.5.0;

interface CouponDistributionInterface {

    //Very minimal interface, just needs to implement distribution for both cases, and that's it!

    //! calldata is a new keyword, it seems for data location in ^0.5.0; interesting!
    function distributeCoupon(uint256 couponID, bytes calldata data) external returns (bool);
    function distributeCoupon(uint256 couponID) external returns (bool);

}

// File: contracts/marketplace/SnowflakeEINMarketplace.sol

pragma solidity ^0.5.0;






contract SnowflakeEINMarketplace is Marketplace, SnowflakeEINOwnable, SnowflakeEINMarketplaceInterface {

/*
    constructor(address paymentAddress, address _CouponFeatureAddress, address _ItemFeatureAddress, address _snowflakeAddress) public {
        _constructSnowflakeEINMarketplace(paymentAddress, _CouponFeatureAddress, _ItemFeatureAddress, _snowflakeAddress);
    
    }    
*/
    function _constructSnowflakeEINMarketplace(address paymentAddress, address _CouponFeatureAddress, address _ItemFeatureAddress, address _snowflakeAddress) internal {
        _constructMarketplace(paymentAddress, _CouponFeatureAddress, _ItemFeatureAddress/*,_snowflakeAddress*/);
        _constructSnowflakeEINOwnable(_snowflakeAddress);
    }

    function setPaymentAddress(address paymentAddress) public onlyEINOwner returns (bool) {
        return _setPaymentAddress(paymentAddress);
    }


    function distributeCoupon(uint id) public onlyEINOwner returns (bool) {
        //We only need to read from the Coupons, so CouponsInterface is appropriate here
        CouponInterface coupons = CouponInterface(CouponFeatureAddress);
        //Grab our distribution address, as defined within the coupon, and access it
        address distributionAddress = coupons.getCouponDistributionAddress(id);
        CouponDistributionInterface couponDistribution = CouponDistributionInterface(distributionAddress);
        //Call the distribute coupon function it has with our coupon ID, and let it execute!
        couponDistribution.distributeCoupon(id); 
    }

    //Here, we expose the functionality of _giveUserCoupon() and force a CouponDistribution contract to be the only one to actually use this function and give a user a coupon
    function giveUserCoupon(uint ein, uint couponID) public onlyCouponDistribution returns (bool) {
        return _giveUserCoupon(ein, couponID);
    }


    //Exposing functions to work with onlyEINOwner to set CouponFeatureAddress
    function setCouponFeatureAddress(address _CouponFeatureAddress) public onlyEINOwner returns (bool) {
        return _setCouponFeatureAddress(_CouponFeatureAddress);
    }

    function setItemFeatureAddress(address _ItemFeatureAddress) public onlyEINOwner returns (bool) {
        return _setItemFeatureAddress(_ItemFeatureAddress);
    }

    function setCouponDistributionAddress(address _CouponDistributionAddress) public onlyEINOwner returns (bool) {
        return _setCouponDistributionAddress(_CouponDistributionAddress);
    }



/*
==================================
DeliveryMethods add/update/delete
==================================
*/

    function addDeliveryMethod(string memory deliveryMethod) public onlyEINOwner returns (bool) {
        return _addDeliveryMethod(deliveryMethod);
    }

    function updateDeliveryMethod(uint id, string memory deliveryMethod) public onlyEINOwner returns (bool) {
        return _updateDeliveryMethod(id, deliveryMethod);
    }

    function deleteDeliveryMethod(uint id) public onlyEINOwner returns (bool) {
        return _deleteDeliveryMethod(id);
    }


/*
==============================
ItemTags add/update/delete
==============================
*/

    function addItemTag(string memory itemTag) public onlyEINOwner returns (bool) {
        return _addItemTag(itemTag);
    }

    function updateItemTag(uint id, string memory itemTag) public onlyEINOwner returns (bool) {
        return _updateItemTag(id, itemTag);
    }

    function deleteItemTag(uint id) public onlyEINOwner returns (bool) {
        return _deleteItemTag(id);
    }

/*
==============================
ReturnPolicy add/update/delete
==============================
*/

    function addReturnPolicy(bool returnsAccepted, uint timeLimit) public onlyEINOwner returns (bool) {
        return _addReturnPolicy(returnsAccepted, timeLimit);
    }

    function updateReturnPolicy(uint id, bool returnsAccepted, uint timeLimit) public onlyEINOwner returns (bool) {
        return _updateReturnPolicy(id, returnsAccepted, timeLimit);
    }

    function deleteReturnPolicy(uint id) public onlyEINOwner returns (bool) {
        return _deleteReturnPolicy(id);
    }



/* ====================================================

       END OF ADD/UPDATE/DELETE FUNCTIONS

   ====================================================
*/
















}

// File: contracts/interfaces/HydroInterface.sol

pragma solidity ^0.5.0;

interface HydroInterface {
    function balances(address) external view returns (uint);
    function allowed(address, address) external view returns (uint);
    function transfer(address _to, uint256 _amount) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function approve(address _spender, uint256 _amount) external returns (bool success);
    function approveAndCall(address _spender, uint256 _value, bytes calldata _extraData)
        external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function totalSupply() external view returns (uint);

    function authenticate(uint _value, uint _challenge, uint _partnerId) external;
}

// File: contracts/SnowflakeResolver.sol

pragma solidity ^0.5.0;





contract SnowflakeResolver is Ownable {
    string public snowflakeName;
    string public snowflakeDescription;

    address public snowflakeAddress;

    bool public callOnAddition;
    bool public callOnRemoval;

    constructor(
        string memory _snowflakeName, string memory _snowflakeDescription,
        address _snowflakeAddress,
        bool _callOnAddition, bool _callOnRemoval
    )
        public
    {
        snowflakeName = _snowflakeName;
        snowflakeDescription = _snowflakeDescription;

        setSnowflakeAddress(_snowflakeAddress);

        callOnAddition = _callOnAddition;
        callOnRemoval = _callOnRemoval;
    }

    modifier senderIsSnowflake() {
        require(msg.sender == snowflakeAddress, "Did not originate from Snowflake.");
        _;
    }

    // this can be overriden to initialize other variables, such as e.g. an ERC20 object to wrap the HYDRO token
    function setSnowflakeAddress(address _snowflakeAddress) public onlyOwner {
        snowflakeAddress = _snowflakeAddress;
    }

    // if callOnAddition is true, onAddition is called every time a user adds the contract as a resolver
    // this implementation **must** use the senderIsSnowflake modifier
    // returning false will disallow users from adding the contract as a resolver
    function onAddition(uint ein, uint allowance, bytes memory extraData) public returns (bool);

    // if callOnRemoval is true, onRemoval is called every time a user removes the contract as a resolver
    // this function **must** use the senderIsSnowflake modifier
    // returning false soft prevents users from removing the contract as a resolver
    // however, note that they can force remove the resolver, bypassing onRemoval
    function onRemoval(uint ein, bytes memory extraData) public returns (bool);

    function transferHydroBalanceTo(uint einTo, uint amount) internal {
        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());
        require(hydro.approveAndCall(snowflakeAddress, amount, abi.encode(einTo)), "Unsuccessful approveAndCall.");
    }

    function withdrawHydroBalanceTo(address to, uint amount) internal {
        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());
        require(hydro.transfer(to, amount), "Unsuccessful transfer.");
    }

    function transferHydroBalanceToVia(address via, uint einTo, uint amount, bytes memory snowflakeCallBytes) internal {
        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());
        require(
            hydro.approveAndCall(
                snowflakeAddress, amount, abi.encode(true, address(this), via, einTo, snowflakeCallBytes)
            ),
            "Unsuccessful approveAndCall."
        );
    }

    function withdrawHydroBalanceToVia(address via, address to, uint amount, bytes memory snowflakeCallBytes) internal {
        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());
        require(
            hydro.approveAndCall(
                snowflakeAddress, amount, abi.encode(false, address(this), via, to, snowflakeCallBytes)
            ),
            "Unsuccessful approveAndCall."
        );
    }
}

// File: contracts/interfaces/marketplace/ItemInterface.sol

pragma solidity ^0.5.0;

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

    function getItemDelivery(uint id) external view returns (uint[] memory);
    function getItemTags(uint id) external view returns (uint[] memory); 

}

// File: contracts/interfaces/NeoCouponMarketplaceResolverInterface.sol

pragma solidity ^0.5.0;



//We may just need to make this an abstract contract instead of an interface to give access to these enums, see: https://gist.github.com/Luiserebii/18a2bed267992dff8bc85703ca8fe3f3

interface NeoCouponMarketplaceResolverInterface {

//This should likely go in their respective feature interfaces
/*
    function getItem(uint id) public view returns (uint uuid, uint quantity, ItemInterface.ItemType itemType, ItemInterface.ItemStatus status, ItemInterface.ItemCondition condition, string memory title, string memory description, uint256 price, uint returnPolicy);

    function getItemDelivery(uint id, uint index) public view returns (uint);
    function getItemTag(uint id, uint index) public view returns (uint);

    //Returns delivery method at mapping ID (i.e. Fedex)
    function getDeliveryMethod(uint id) public view returns (string memory method);
    
    function getReturnPolicy(uint id) public view returns (bool returnsAccepted, uint timeLimit);
    function getCoupon(uint id) public view returns (CouponInterface.CouponType couponType, string memory title, string memory description, uint256 amountOff, uint expirationDate);
    function getCouponItemApplicable(uint id, uint index) public view returns (uint);
*/
    //This should be moved to MarketplaceInterface.sol
    //function isUserCouponOwner(uint ein, uint couponID) public view returns (bool isValid);
    function purchaseItem(uint id, address approvingAddress, uint couponID) external returns (bool);
}

// File: contracts/zeppelin/introspection/IERC165.sol

pragma solidity ^0.5.2;

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

// File: contracts/ein/token/ERC721/SnowflakeERC721Interface.sol

pragma solidity ^0.5.2;


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

// File: contracts/ein/token/ERC721/SnowflakeERC721ReceiverInterface.sol

pragma solidity ^0.5.2;

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

// File: contracts/zeppelin/drafts/Counters.sol

pragma solidity ^0.5.2;


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

// File: contracts/zeppelin/introspection/ERC165.sol

pragma solidity ^0.5.2;


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

// File: contracts/ein/token/ERC721/SnowflakeERC721.sol

pragma solidity ^0.5.2;







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

// File: contracts/ein/token/ERC721/SnowflakeERC721Burnable.sol

pragma solidity ^0.5.2;


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

// File: contracts/ein/access/EINRoles.sol

pragma solidity ^0.5.2;

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

// File: contracts/ein/access/roles/SnowflakeMinterRole.sol

pragma solidity ^0.5.2;




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

// File: contracts/ein/token/ERC721/SnowflakeERC721Mintable.sol

pragma solidity ^0.5.2;



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

// File: contracts/ein/token/ERC721/address/AddressSnowflakeERC721.sol

pragma solidity ^0.5.2;


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

// File: contracts/ein/token/ERC721/address/AddressSnowflakeERC721Burnable.sol

pragma solidity ^0.5.2;


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

// File: contracts/zeppelin/access/Roles.sol

pragma solidity ^0.5.2;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: contracts/zeppelin/access/roles/MinterRole.sol

pragma solidity ^0.5.2;


contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

// File: contracts/ein/token/ERC721/address/AddressSnowflakeERC721Mintable.sol

pragma solidity ^0.5.2;



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

// File: contracts/marketplace/features/Coupons.sol

pragma solidity ^0.5.0;








/*

ERC 721 ---> Coupon Interface ---> Coupon contract (w/ data + function implementations)
        ---> Item Interface ---> Item contract (w/data + function implementations)


//Use addresses to represent other ownership states; unlimited/claimable once



    Coupons that correspond to a given marketplace are denominated by a coupon-generation function.
    The marketplace admin can generate coupons at-will.
    Coupon generation function should take the following parameters:

        Item type - the type of item for which this coupon applies
        Discount rate - the percentage discount the coupon offers
        Distribution address - defines the logic for how coupons are distributed; must follow a standard interface with a function that can be called from the coupon-generation function to define the initial distribution of coupons once generated.
        Each coupon should have a uuid


*/


contract Coupons is SnowflakeERC721Burnable, SnowflakeERC721Mintable, AddressSnowflakeERC721Burnable, AddressSnowflakeERC721Mintable, CouponInterface {

    //ID, starting at 1, connecting the mappings
    uint public nextAvailableCouponsID;

    //Mapping connecting ERC721 coupons to actual struct objects
    mapping(uint => Coupon) public availableCoupons;
/*
    constructor(address _snowflakeAddress) public {
        _constructCoupons(_snowflakeAddress);
    }
*/
    function _constructCoupons(address _snowflakeAddress) internal {
        //Constructor functions of inherited contracts
        _constructSnowflakeERC721Burnable(_snowflakeAddress);
        _constructSnowflakeERC721Mintable(_snowflakeAddress);
        _constructAddressSnowflakeERC721Burnable(_snowflakeAddress);

        //Actual constructor logic
        nextAvailableCouponsID = 1;

    }


    struct Coupon {
        CouponType couponType;
        string title;
        string description;
        uint256 amountOff;
        uint[] itemsApplicable;
        uint expirationDate;
        address couponDistribution;
    }
    

    function getCoupon(uint id) public view returns (CouponType couponType, string memory title, string memory description, uint256 amountOff, uint expirationDate){

        Coupon memory c = availableCoupons[id];
        return (c.couponType, c.title, c.description, c.amountOff, c.expirationDate);
    }

    function getCouponSimple(uint id) public view returns (CouponType couponType, uint256 amountOff, uint expirationDate){

        Coupon memory c = availableCoupons[id];
        return (c.couponType, c.amountOff, c.expirationDate);
    }


    function getCouponItemsApplicable(uint id) public view returns (uint[] memory) {
        return storageUintArrToMemory(availableCoupons[id].itemsApplicable);
    }

    //Refactor this down the line
    /**
     *====================
     * GENERIC FUNCTION
     *====================
     * 
     * PLEASE REFACTOR!!!!!!!!!!!!
     */
    function storageUintArrToMemory(uint[] storage arr) internal view returns (uint[] memory) {
        uint[] memory memArr = new uint[](arr.length);
        for(uint i = 0; i < arr.length; i++){
            memArr[i] = arr[i];
        }
        return memArr;
    }



    function getCouponDistributionAddress(uint id) public view returns (address) {
        return availableCoupons[id].couponDistribution;
    }



/*
===================================
AvailableCoupons add/update/delete
===================================
*/

    function _addAvailableCoupon(
        uint256 ein,
        CouponType couponType,
        string memory title,
        string memory description,
        uint256 amountOff,
        uint[] memory itemsApplicable,
        uint expirationDate,
        address couponDistribution

    ) internal returns (bool) {

        //Mint it as an ERC721 owned by the creator
        _mint(ein, nextAvailableCouponsID);

        //Add to avaliableCoupons
        availableCoupons[nextAvailableCouponsID] = Coupon(couponType, title, description, amountOff, itemsApplicable, expirationDate, couponDistribution);
        //Advance nextAvailableCouponID by 1
        nextAvailableCouponsID++;

        return true;
    }

    function _updateAvailableCoupon(
        uint id,
        CouponType couponType,
        string memory title,
        string memory description,
        uint256 amountOff,
        uint[] memory itemsApplicable,
        uint expirationDate,
        address couponDistribution

    ) internal returns (bool) {
        //Add to avaliableCoupons
        availableCoupons[id] = Coupon(couponType, title, description, amountOff, itemsApplicable, expirationDate, couponDistribution);

        return true;
    }


    function _deleteAvailableCoupon(uint id) internal returns (bool) {

        //Delete availableCoupon by ID
        delete availableCoupons[id];

        //Finally, burn it
        _burn(id); 

        return true;

    }








}

// File: contracts/marketplace/features/CouponFeature.sol

pragma solidity ^0.5.0;




contract CouponFeature is Coupons, SnowflakeEINOwnable {


    constructor(address _snowflakeAddress) public {
        _constructCouponFeature(_snowflakeAddress);
    
    }    

    function _constructCouponFeature(address _snowflakeAddress) internal {
        _constructCoupons(_snowflakeAddress);
        _constructSnowflakeEINOwnable(_snowflakeAddress);
    }

/*
===================================
AvailableCoupons add/update/delete
===================================
*/



   function addAvailableCoupon(
        uint256 ein,
        CouponType couponType,
        string memory title,
        string memory description,
        uint256 amountOff,
        uint[] memory itemsApplicable,
        uint expirationDate,
        address couponDistribution

    ) public onlyEINOwner returns (bool) {
        return _addAvailableCoupon(ein, couponType, title, description, amountOff, itemsApplicable, expirationDate, couponDistribution);
    }


    function updateAvailableCoupon(
        uint id,
        CouponType couponType,
        string memory title,
        string memory description,
        uint256 amountOff,
        uint[] memory itemsApplicable,
        uint expirationDate,
        address couponDistribution

    ) public onlyEINOwner returns (bool) {
        return _updateAvailableCoupon(id, couponType, title, description, amountOff, itemsApplicable, expirationDate, couponDistribution);
    }


    function deleteAvailableCoupon(uint id) public onlyEINOwner returns (bool) {
       return _deleteAvailableCoupon(id);
    }


/* ====================================================

       END OF ADD/UPDATE/DELETE FUNCTIONS

   ====================================================
*/










}

// File: contracts/marketplace/features/Items.sol

pragma solidity ^0.5.0;






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

    function getItemDelivery(uint id) public view returns (uint[] memory) {
        return storageUintArrToMemory(itemListings[id].delivery);
    }
 
    function getItemTags(uint id) public view returns (uint[] memory) {
        return storageUintArrToMemory(itemListings[id].tags);
    }

    //Refactor this down the line
    /**
     *====================
     * GENERIC FUNCTION
     *====================
     * 
     * PLEASE REFACTOR!!!!!!!!!!!!
     */
    function storageUintArrToMemory(uint[] storage arr) internal view returns (uint[] memory) {
        uint[] memory memArr = new uint[](arr.length);
        for(uint i = 0; i < arr.length; i++){
            memArr[i] = arr[i];
        }
        return memArr;
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

// File: contracts/marketplace/features/ItemFeature.sol

pragma solidity ^0.5.0;




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

// File: contracts/resolvers/CouponMarketplaceResolver.sol

pragma solidity ^0.5.0;












contract CouponMarketplaceResolver is SnowflakeResolver, SnowflakeEINMarketplace, NeoCouponMarketplaceResolverInterface {

/*

Simple Marketplace
-------------------

-Contract owner = seller
-Contract owner = EIN
-Items
-Coupons
  -[uint ---> Coupon]
     -Coupon = [Amount off, items applied to]

Item Status:
-------------
-For Sale/Active
-Purchased - Awaiting payment (Maybe not needed)
-Complete


Functions:
-----------
-List items
-Remove item listing
-Update item listing
-Read item listing


-Pay for thing
   -Look for EIN in Identity Registry, I suppose?
   -TransferHydroBalanceTo(EIN owner)

-----------------------------------------------------------------

Index:
--------

   -Struct/Mapping defnitions and declarations
   -Constructor
   -Inheritance function overrides
   -Public getter functions
   -Add/Update/Delete functions


*/

    address private _CouponMarketplaceViaAddress;


    /*
     * =============
     * Constructor:
     * =============
     *
     * Initialize EIN of owner and SnowflakeResolver vars
     *
     *
     */
    constructor(
        string memory _snowflakeName, string memory _snowflakeDescription,
        address _snowflakeAddress,
        bool _callOnAddition, bool _callOnRemoval,
        address paymentAddress,
        address CouponMarketplaceViaAddress,
        address _CouponFeatureAddress, address _ItemFeatureAddress
    ) SnowflakeResolver (
        _snowflakeName, _snowflakeDescription,
        _snowflakeAddress,
        _callOnAddition, _callOnRemoval
    ) public {

        //Parent constructing
        _constructSnowflakeEINMarketplace(paymentAddress, _CouponFeatureAddress, _ItemFeatureAddress, _snowflakeAddress);

        //Set contract-specific private/internal vars
        _CouponMarketplaceViaAddress = CouponMarketplaceViaAddress;

    }



    function CouponMarketplaceViaAddress() public view returns (address) {
        return _CouponMarketplaceViaAddress;
    }


/* ======================================
    Functions overridden via inheritance  
   ======================================
*/


    // if callOnAddition is true, onAddition is called every time a user adds the contract as a resolver
    // this implementation **must** use the senderIsSnowflake modifier
    // returning false will disallow users from adding the contract as a resolver
    function onAddition(uint /* ein */, uint /* allowance */, bytes memory /* extraData */) public returns (bool) {
        return true;
    }

    // if callOnRemoval is true, onRemoval is called every time a user removes the contract as a resolver
    // this function **must** use the senderIsSnowflake modifier
    // returning false soft prevents users from removing the contract as a resolver
    // however, note that they can force remove the resolver, bypassing onRemoval
    function onRemoval(uint /* ein */, bytes memory /* extraData*/) public returns (bool){
       return true;
    }


/*

-Pay for thing
   -Look for EIN in Identity Registry, I suppose?
   -TransferHydroBalanceTo(EIN owner)



Buyers can purchase listed items at-price by by sending a transaction that:

    Calls allow-and-call for the user on Snowflake
        Sets an allowance equal to the price
        Draws the corresponding allowance from the user
        Transfers ownership of the item to the buyer
    Transactions should be facilitated through a via contract which must be written as part of this task (instructions below); in most instances, the ‘via’ will do nothing; however, if the user has a “coupon,” the via will apply the coupon as part of the transaction. Coupons work as follows:


Via contract to use coupons:

    When a buyer is buying an item, the transfer function call on Snowflake should include the address of the via contract, and an extraData bytes parameter that will encode a function call. This bytes parameter should include the uuid of the user-owned coupon. The logic of the via contract will draw the apply the discount rate of the coupon to the item, and then transfer the coupon to a burner address. The user’s discount will be refunded to them while the seller receives the rest of the value of the transaction. Finally, ownership of the purchased item should be transferred to the user. All this should be achievable in one synchronous function-call. If a user passes 0 as the uuid for the coupon, the via should just conduct a transfer as normal as if no coupon were present.
    The via contract will need to check to enforce that the user actually has the coupon they are trying to pass.





*/



    function purchaseItem(uint id, /*bytes memory data,*/ address approvingAddress, uint couponID) public returns (bool) {

        //Initialize itemFeature here (as is necessary to check the require as early as possible)   
        ItemFeature itemFeature = ItemFeature(ItemFeatureAddress);
        //CouponFeature couponFeature = CouponFeature(CouponFeatureAddress);

        uint256 price = itemFeature.getItemPrice(id);

        //Ensure the item exists, and that there is a price
        require(price > 0, "item does not exist, or has a price below 0. The price in question is: ");

        //Initialize Snowflake
        SnowflakeInterface snowflake = SnowflakeInterface(snowflakeAddress);


    /* Take an EIN (from), an address (via), an EIN (to), an amount, and data

          -handleAllowance() and pass the EIN (from), and an amount
          -_withdraw() and pass the EIN (from), the address (via), and amount
          -Call snowflakeCall() from the via contract through the SnowflakeViaInterface, passing msg.sender, the EIN (from), the EIN (to), amount, and data
*/

        //Get EIN of user
        //Logic is einFrom, since this is the buyer from which funds will head to our via contract
            //uint einFrom = identityRegistry.getEIN(approvingAddress);
            //uint einTo = ownerEIN(); //The seller


        //bytes data; set snowflakeCall stuff
        bytes memory snowflakeCallData;
//        string memory functionSignature = "processTransaction(uint256,uint256,uint256,uint256,uint256)";
//        snowflakeCallData = abi.encodeWithSelector(bytes4(keccak256(bytes(functionSignature))), id, getEIN(approvingAddress), ownerEIN(), price, couponID);
        snowflakeCallData = abi.encode(id, getEIN(approvingAddress), ownerEIN(), price, couponID);

        //Allowance for item to CouponMarketplaceVia MUST BE DONE FROM FRONT-END
        //Allowance for coupon to CouponMarketplaceVia MUST BE DONE FROM FRONT-END

        //If there is a coupon,
        //   Grant allowance to Via
        //if(couponID != 0){
            //Ensure coupon is owned
            //(!!!IMPORTANT!!! Ohhh, you know, I don't this is quite possible like this... ownerOf makes it unclear as to which (Coupon, or Item) it'll return, I think... hmmm, darn. Seperate contract? Perhaps create on deployment?)
       //     require(couponFeature.ownerOf(id) == getEIN(approvingAddress), "Approving address is not the owner of this coupon");
            
            
       // }



        // 
        //  function transferSnowflakeBalanceFromVia(uint einFrom, address via, uint einTo, uint amount, bytes memory _bytes)
        //


        snowflake.transferSnowflakeBalanceFromVia(getEIN(approvingAddress), _CouponMarketplaceViaAddress, ownerEIN(), price, snowflakeCallData);

        //Transfers ownership of the item to the buyer (!)

    }



}

// File: contracts/CouponMarketplaceVia.sol

pragma solidity ^0.5.0;














contract CouponMarketplaceVia is SnowflakeVia, SnowflakeEINOwnable {


    //We may need to define this in a seperate file... uncertain if this will quite work being in two different locations

//   This is now defined within the CouponMarketplaceResolverInterface.sol, let's test this...
//    enum CouponType { AMOUNT_OFF, PERCENTAGE_OFF, BUY_X_QTY_GET_Y_FREE , BUY_X_QTY_FOR_Y_AMNT }
    
    using SafeMath for uint256;

    address public CouponMarketplaceResolverAddress;

    constructor(address _snowflakeAddress) SnowflakeVia(_snowflakeAddress) public {
        //Constructing parents
        _constructSnowflakeEINOwnable(_snowflakeAddress);
 
        //Regular constructor
        //setSnowflakeAddress(_snowflakeAddress);
        
    }

    // end recipient is an EIN
    function snowflakeCall(
        address /* resolver */,
        uint /* einFrom */,
        uint /* einTo */,
        uint /* amount */,
        bytes memory snowflakeCallBytes 
    ) public senderIsSnowflake {


//        (bool success, bytes memory returnData) = address(this).call(snowflakeCallBytes);
//        require(success, ".call() to snowflakeCallBytes failed!");

        (/*bytes4 selector, */uint itemID, uint einBuyer, uint einSeller, uint amount, uint couponID) = abi.decode(snowflakeCallBytes, (/*bytes4, */uint256, uint256, uint256, uint256, uint256));
        processTransaction(itemID, einBuyer, einSeller, amount, couponID);
        

    }


    //Name of this function is perhaps a little misleading, since amount has already been transferred, we're just calcing coupon here
    //TODO: Should we have the NeoCouponMarketplaceResolverAddress exist, or just take the address resolver passed here? Completely forgot we were give this, and now this param is being unused
    //***NOTE***: Removed modifier for testing purposes; very dangerous!!!
    function processTransaction(/*address resolver, */uint itemID, uint einBuyer, uint einSeller, uint amount, uint couponID) internal /*senderIsSnowflake*/ returns (bool) {

        //Initialize NeoCouponMarketplaceResolverAddress
        CouponMarketplaceResolver mktResolver = CouponMarketplaceResolver(CouponMarketplaceResolverAddress);
 
        ItemFeature itemFeature = ItemFeature(mktResolver.ItemFeatureAddress());
 
        //Initialize Snowflake
        SnowflakeInterface snowflake = SnowflakeInterface(snowflakeAddress);

        //Declare our total
        uint total = amount;
 
        //Since couponID == 0 means we do not have a coupon, we check this first
        if(couponID != 0){

            uint amountRefund;
            //TODO: Break this out into its own function thingie

            //Get coupon info from our coupon feature contract
            CouponFeature couponFeature = CouponFeature(mktResolver.CouponFeatureAddress());

            (total, amountRefund) = _processCoupon(couponFeature, couponID, total);

            //Send item to buyer
            itemFeature.transferFromAddress(einSeller, einBuyer, itemID);

            //Send to seller payment address
            HydroInterface hydro = HydroInterface(snowflake.hydroTokenAddress());
            hydro.transfer(mktResolver.paymentAddress(), total);     
 
            //Finally, let's return their amount... (for security reasons, we follow Checks-Effect-Interaction pattern and modify state last...)
            //This will result in a SnowflakeDeposit; see receiveApproval() of Snowflake contract
            hydro.approveAndCall(snowflakeAddress, amountRefund, abi.encode(einBuyer));

        } else {

            //Send item to buyer
            itemFeature.transferFromAddress(einSeller, einBuyer, itemID);

            //Send our total charged to buyer addr via snowflake
//            snowflake.transferSnowflakeBalance(einSeller, total);
            
            //We will send it to the seller payment address, actually...
            HydroInterface hydro = HydroInterface(snowflake.hydroTokenAddress());
            hydro.transfer(mktResolver.paymentAddress(), total);
            
            //Actually, I think the Resolver has HYDRO sent to address directly to this contract, so it may just be a regular send, check later

        }
    }

    function _processCoupon(CouponFeature couponFeature, uint256 couponID, uint256 _total) internal returns (uint256 /*total*/, uint256 /*amountRefund*/) {

        uint256 total = _total;
        uint256 amountRefund;
        
        //Get coupon info from our coupon feature contract
        //CouponFeature couponFeature = CouponFeature(mktResolver.CouponFeatureAddress());

        (CouponInterface.CouponType couponType, uint256 amountOff, uint expirationDate) = couponFeature.getCouponSimple(couponID);

        //Ensure coupon is not expired
        require(now < expirationDate, "Coupon is expired!");

        //If couponType is amountOff...
        if(couponType == CouponInterface.CouponType.AMOUNT_OFF){
            total = _applyCouponAmountOff(total, amountOff);
            amountRefund = amountOff;
        }

 
        //Send coupon to burner address
        couponFeature.burnAddress(couponID);

        //NOTE: NEED TO GIVE COUPON ALLOWANCE TO VIA CONTRACT FOR THIS TO WORK

        //In an event, let's push the transaction or something
        emit CouponProcessed(total, amountRefund, couponType, amountOff, expirationDate);

        return (total, amountRefund);
    }


    function _applyCouponAmountOff(uint256 total, uint256 amountOff) pure private returns (uint256) {
        require(total >= amountOff, "Coupon amount is higher than total");
        uint256 newTotal = total.sub(amountOff);
        return newTotal;
    }

    // end recipient is an EIN, no from field
    function snowflakeCall(
        address /* resolver */,
        uint /* einTo */,
        uint /* amount */,
        bytes memory /* snowflakeCallBytes */
    ) public senderIsSnowflake {
        revert("Not Implemented.");
    }

    // end recipient is an address
    function snowflakeCall(
        address /* resolver */,
        uint /* einFrom */,
        address payable /* to */,
        uint /* amount */,
        bytes memory /* snowflakeCallBytes */
    ) public senderIsSnowflake {
        revert("Not Implemented.");
    }

    // end recipient is an address, no from field
    function snowflakeCall(
        address /* resolver */,
        address payable /* to */,
        uint /* amount */,
        bytes memory /* snowflakeCallBytes */
    ) public senderIsSnowflake {
        revert("Not Implemented.");
    }

    function setCouponMarketplaceResolverAddress(address _CouponMarketplaceResolverAddress) public onlyEINOwner returns (bool) {
        CouponMarketplaceResolverAddress = _CouponMarketplaceResolverAddress;
        return true;
}

    
    event CouponProcessed(uint total, uint amountRefunded, CouponInterface.CouponType couponType, uint256 amountOff, uint expirationDate);




}
