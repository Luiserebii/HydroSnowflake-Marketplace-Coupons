pragma solidity ^0.5.0;

import '../ein/token/ERC721/SnowflakeERC721.sol';
import '../ein/token/ERC721/SnowflakeERC721Burnable.sol';
import '../ein/token/ERC721/SnowflakeERC721Mintable.sol';
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


contract Coupons is SnowflakeERC721, SnowflakeERC721Burnable, SnowflakeERC721Mintable, CouponInterface {

    //ID, starting at 1, connecting the mappings
    uint public nextAvailableCouponsID;

    //Mapping connecting ERC721 coupons to actual struct objects
    mapping(uint => Coupon) public availableCoupons;

    constructor(address _snowflakeAddress) SnowflakeERC721Burnable(_snowflakeAddress) SnowflakeERC721Mintable(_snowflakeAddress) public {
        //stuff here
        nextAvailableCouponsID = 1;
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



/*
===================================
AvailableCoupons add/update/delete
===================================
*/

    function addAvailableCoupon(
        CouponType couponType,
        string memory title,
        string memory description,
        uint256 amountOff,
        uint[] memory itemsApplicable,
        uint expirationDate

    ) public onlyEINOwner returns (bool) {
        //Add to avaliableCoupons
        availableCoupons[nextAvailableCouponsID] = Coupon(couponType, title, description, amountOff, itemsApplicable, expirationDate);
        //Advance nextAvailableCouponID by 1
        nextAvailableCouponsID++;

        return true;
    }

    function updateAvailableCoupon(
        uint id,
        CouponType couponType,
        string memory title,
        string memory description,
        uint256 amountOff,
        uint[] memory itemsApplicable,
        uint expirationDate

    ) public onlyEINOwner returns (bool) {
        //Add to avaliableCoupons
        availableCoupons[id] = Coupon(couponType, title, description, amountOff, itemsApplicable, expirationDate);

        return true;
    }


    function deleteAvailableCoupon(uint id) public onlyEINOwner returns (bool) {

        //Delete availableCoupon by ID
        delete availableCoupons[id];
        return true;

    }








}





