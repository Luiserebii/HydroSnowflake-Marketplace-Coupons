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

interface MarketplaceInterface {

    function paymentAddress() external view returns (address);
    function isUserCouponOwner(uint ein, uint couponID) external view returns (bool);

}




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

interface SnowflakeEINMarketplaceInterface {

    function setPaymentAddress(address paymentAddress) external returns (bool);
    function setCouponDistributionAddress(address _CouponDistributionAddress) external returns (bool);
    function giveUserCoupon(uint ein, uint couponID) external returns (bool);

}




interface CouponInterface {

//A simple interface for Coupon.sol


    enum CouponType { AMOUNT_OFF, PERCENTAGE_OFF, BUY_X_QTY_GET_Y_FREE, BUY_X_QTY_FOR_Y_AMNT }
/*
    function getCoupon(uint id) external view returns (CouponType couponType, string memory title, string memory description, uint256 amountOff, uint expirationDate);*/
    function getCouponItemApplicable(uint id, uint index) external view returns (uint);
    function getCouponDistributionAddress(uint id) external view returns (address);

}

interface CouponDistributionInterface {

    //Very minimal interface, just needs to implement distribution for both cases, and that's it!

    //! calldata is a new keyword, it seems for data location in ^0.5.0; interesting!
    function distributeCoupon(uint256 couponID, bytes calldata data) external returns (bool);
    function distributeCoupon(uint256 couponID) external returns (bool);

}

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
