pragma solidity ^0.5.0;

import '../zeppelin/token/ERC721/ERC721Full.sol';
import '../interfaces/marketplace/CouponInterface.sol';

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


contract Coupons is ERC721Full, CouponInterface {


    //Mapping connecting ERC721 coupons to actual struct objects
    mapping(uint => Coupon) public availableCoupons;

    constructor(string memory name, string memory symbol) public ERC721Full(name, symbol){
        //stuff here
    }

    struct Coupon {
        CouponType couponType;
        string title;
        string description;
        uint256 amountOff;
        uint[] itemsApplicable;
        uint expirationDate;
    }
    

    function getCoupon(uint id) public view returns (CouponType couponType, string memory title, string memory description, uint256 amountOff, uint expirationDate){

        Coupon memory c = availableCoupons[id];
        return (c.couponType, c.title, c.description, c.amountOff, c.expirationDate);
    }

    function getCouponItemApplicable(uint id, uint index) public view returns (uint) { 
        return availableCoupons[id].itemsApplicable[index]; 
    }



}





