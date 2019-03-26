pragma solidity ^0.5.0;

//import "./features/CouponFeature.sol";
//import "./features/ItemFeature.sol";
import "./features/ItemTags.sol";
import "./features/Delivery.sol";
import "./features/ReturnPolicies.sol";

contract Marketplace is ItemTags, Delivery, ReturnPolicies {

    address private _paymentAddress;
    address public CouponFeatureAddress;
    address public ItemFeatureAddress;
  

    //EIN to Coupon UUID mapping
    // EIN => (couponID => bool)
    mapping(uint => mapping(uint => bool)) public userCoupons;


    constructor(address paymentAddress, address _CouponFeatureAddress, address _ItemFeatureAddress, address _snowflakeAddress) public { 
        _constructMarketplace(paymentAddress, _CouponFeatureAddress, _ItemFeatureAddress, _snowflakeAddress);
    }

    function _constructMarketplace(address paymentAddress, address _CouponFeatureAddress, address _ItemFeatureAddress, address _snowflakeAddress) internal {
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







//EXTRA MARKETPLACE:


    struct DeliveryDetails {
        uint method;
        uint handlingTime;
        string trackingNumber;
    }





}
