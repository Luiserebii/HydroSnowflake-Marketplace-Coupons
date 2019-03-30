pragma solidity ^0.5.0;

import "./features/ItemTags.sol";
import "./features/Delivery.sol";
import "./features/ReturnPolicies.sol";
import "../interfaces/marketplace/MarketplaceInterface.sol";

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
