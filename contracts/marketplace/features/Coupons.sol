pragma solidity ^0.5.0;

import '../../ein/token/ERC721/SnowflakeERC721.sol';
import '../../ein/token/ERC721/SnowflakeERC721Burnable.sol';
import '../../ein/token/ERC721/SnowflakeERC721Mintable.sol';

import '../../ein/token/ERC721/address/AddressSnowflakeERC721.sol';
import '../../ein/token/ERC721/address/AddressSnowflakeERC721Burnable.sol';
import '../../ein/token/ERC721/address/AddressSnowflakeERC721Mintable.sol';


import '../../interfaces/marketplace/CouponInterface.sol';

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





