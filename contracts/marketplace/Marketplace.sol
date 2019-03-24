pragma solidity ^0.5.0;

contract Marketplace {



    address private _paymentAddress;


    //EIN to Coupon UUID mapping
    // EIN => (couponID => bool)
    mapping(uint => mapping(uint => bool)) public userCoupons;













//EXTRA MARKETPLACE:



    struct DeliveryDetails {
        uint method;
        uint handlingTime;
        string trackingNumber;
    }

    struct ReturnPolicy {
        bool returnsAccepted;
        uint timeLimit;
    }
    mapping(uint => string) public itemTags;
    mapping(uint => string) public deliveryMethods;
    mapping(uint => ReturnPolicy) public returnPolicies;




}
