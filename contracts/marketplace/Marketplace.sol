pragma solidity ^0.5.0;

import "./features/Coupons.sol";
import "./features/Items.sol";
import "./features/ItemTags.sol";
import "./features/Delivery.sol";
import "./features/ReturnPolicies.sol";

contract Marketplace is Coupons, Items, ItemTags, Delivery, ReturnPolicies {


    address private _paymentAddress;

    //EIN to Coupon UUID mapping
    // EIN => (couponID => bool)
    mapping(uint => mapping(uint => bool)) public userCoupons;


    constructor(address paymentAddress, address _snowflakeAddress) public { 
        _constructMarketplace(paymentAddress, _snowflakeAddress);
    }

    function _constructMarketplace(address paymentAddress, address _snowflakeAddress) internal {
        //Constructing parent contracts
        _constructCoupons(_snowflakeAddress);
        _constructItems(_snowflakeAddress);
        _constructItemTags();
        _constructDelivery();
        _constructReturnPolicies();

        //Set contract-specific private/internal vars
        _paymentAddress = paymentAddress;
    }


    function paymentAddress() public view returns (address) {
        return _paymentAddress;
    }

    function isUserCouponOwner(uint ein, uint couponID) public view returns (bool isValid) {
        return userCoupons[ein][couponID];
    }


    //TODO: Add event here
    function _setPaymentAddress(address addr) internal  returns (bool) {
        _paymentAddress = addr;
        return true;
    }








//EXTRA MARKETPLACE:


    struct DeliveryDetails {
        uint method;
        uint handlingTime;
        string trackingNumber;
    }





}
