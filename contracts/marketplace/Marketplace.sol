pragma solidity ^0.5.0;

contract Marketplace {



    address private _paymentAddress;


    //EIN to Coupon UUID mapping
    // EIN => (couponID => bool)
    mapping(uint => mapping(uint => bool)) public userCoupons;


    function paymentAddress() public view returns (address) {
        return _paymentAddress;
    }








//EXTRA MARKETPLACE:



    uint public nextDeliveryMethodsID;

    struct DeliveryDetails {
        uint method;
        uint handlingTime;
        string trackingNumber;
    }

    mapping(uint => string) public deliveryMethods;




}
