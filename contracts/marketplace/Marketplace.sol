pragma solidity ^0.5.0;

import "./Coupons.sol";
import "./Items.sol";
import "./ItemTags.sol";
import "./Delivery.sol";
import "./ReturnPolicies.sol";

contract Marketplace is Coupons, Items, ItemTags, Delivery, ReturnPolicies {


    address private _paymentAddress;

    //EIN to Coupon UUID mapping
    // EIN => (couponID => bool)
    mapping(uint => mapping(uint => bool)) public userCoupons;


    constructor(address paymentAddress) public {
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
