pragma solidity ^0.5.0;

import "./SnowflakeVia.sol";
import "./interfaces/SnowflakeResolverInterface.sol";
import "./zeppelin/math/SafeMath.sol";
import "./interfaces/CouponMarketplaceResolverInterface.sol";
import "./interfaces/SnowflakeInterface.sol";
import "./resolvers/CouponMarketplaceResolver.sol";
import "./ein/util/SnowflakeEINOwnable.sol";
import "./interfaces/HydroInterface.sol";

import "./interfaces/marketplace/CouponInterface.sol";
import "./interfaces/marketplace/ItemInterface.sol";

import "./marketplace/features/CouponFeature.sol";
import "./marketplace/features/ItemFeature.sol";


contract CouponMarketplaceVia is SnowflakeVia, SnowflakeEINOwnable {


    //We may need to define this in a seperate file... uncertain if this will quite work being in two different locations

//   This is now defined within the CouponMarketplaceResolverInterface.sol, let's test this...
//    enum CouponType { AMOUNT_OFF, PERCENTAGE_OFF, BUY_X_QTY_GET_Y_FREE , BUY_X_QTY_FOR_Y_AMNT }
    
    using SafeMath for uint256;

    address public CouponMarketplaceResolverAddress;

    constructor(address _snowflakeAddress) SnowflakeVia(_snowflakeAddress) public {
        //Constructing parents
        _constructSnowflakeEINOwnable(_snowflakeAddress);
 
        //Regular constructor
        //setSnowflakeAddress(_snowflakeAddress);
        
    }

    // end recipient is an EIN
    function snowflakeCall(
        address /* resolver */,
        uint /* einFrom */,
        uint /* einTo */,
        uint /* amount */,
        bytes memory snowflakeCallBytes 
    ) public senderIsSnowflake {


//        (bool success, bytes memory returnData) = address(this).call(snowflakeCallBytes);
//        require(success, ".call() to snowflakeCallBytes failed!");

        (/*bytes4 selector, */uint itemID, uint einBuyer, uint einSeller, uint amount, uint couponID) = abi.decode(snowflakeCallBytes, (/*bytes4, */uint256, uint256, uint256, uint256, uint256));
        processTransaction(itemID, einBuyer, einSeller, amount, couponID);
        

    }


    //Name of this function is perhaps a little misleading, since amount has already been transferred, we're just calcing coupon here
    //TODO: Should we have the NeoCouponMarketplaceResolverAddress exist, or just take the address resolver passed here? Completely forgot we were give this, and now this param is being unused
    //***NOTE***: Removed modifier for testing purposes; very dangerous!!!
    function processTransaction(/*address resolver, */uint itemID, uint einBuyer, uint einSeller, uint amount, uint couponID) internal /*senderIsSnowflake*/ returns (bool) {

        //Initialize NeoCouponMarketplaceResolverAddress
        CouponMarketplaceResolver mktResolver = CouponMarketplaceResolver(CouponMarketplaceResolverAddress);
 
        ItemFeature itemFeature = ItemFeature(mktResolver.ItemFeatureAddress());
 
        //Initialize Snowflake
        SnowflakeInterface snowflake = SnowflakeInterface(snowflakeAddress);

        //Declare our total
        uint total = amount;
 
        //Since couponID == 0 means we do not have a coupon, we check this first
        if(couponID != 0){

            uint amountRefund;
            //TODO: Break this out into its own function thingie

            //Get coupon info from our coupon feature contract
            CouponFeature couponFeature = CouponFeature(mktResolver.CouponFeatureAddress());

            (total, amountRefund) = _processCoupon(couponFeature, couponID);

            //Send coupon to burner address
            couponFeature.burnAddress(couponID);

            //Send item to buyer
            itemFeature.transferFromAddress(einSeller, einBuyer, itemID);

            //Send our total charged to buyer addr via snowflake
            snowflake.transferSnowflakeBalance(einSeller, total);
      
            //Finally, let's return their amount... (for security reasons, we follow Checks-Effect-Interaction pattern and modify state last...)
            snowflake.transferSnowflakeBalance(einBuyer, amountRefund);
        } else {

            //Send item to buyer
            itemFeature.transferFromAddress(einSeller, einBuyer, itemID);

            //Send our total charged to buyer addr via snowflake
//            snowflake.transferSnowflakeBalance(einSeller, total);
            
            //We will send it to the seller payment address, actually...
            HydroInterface hydro = HydroInterface(snowflake.hydroTokenAddress());
            hydro.transfer(mktResolver.paymentAddress(), total);
            
            //Actually, I think the Resolver has HYDRO sent to address directly to this contract, so it may just be a regular send, check later

        }
    }

    function _processCoupon(CouponFeature couponFeature, uint256 couponID) internal returns (uint256 /*total*/, uint256 /*amountRefund*/) {

        uint256 total;
        uint256 amountRefund;
        
        //Get coupon info from our coupon feature contract
        //CouponFeature couponFeature = CouponFeature(mktResolver.CouponFeatureAddress());

        (CouponInterface.CouponType couponType, uint256 amountOff, uint expirationDate) = couponFeature.getCouponSimple(couponID);

        //Ensure coupon is not expired
        require(now < expirationDate, "Coupon is expired!");

        //If couponType is amountOff...
        if(couponType == CouponInterface.CouponType.AMOUNT_OFF){
            total = _applyCouponAmountOff(total, amountOff);
            amountRefund = amountOff;
        }

        //In an event, let's push the transaction or something
        emit CouponProcessed(total, amountRefund, couponType, amountOff, expirationDate);

        return (total, amountRefund);
    }


    function _applyCouponAmountOff(uint256 total, uint256 amountOff) pure private returns (uint256) {
        require(total >= amountOff, "Coupon amount is higher than total");
        uint256 newTotal = total.sub(amountOff);
        return newTotal;
    }

    // end recipient is an EIN, no from field
    function snowflakeCall(
        address /* resolver */,
        uint /* einTo */,
        uint /* amount */,
        bytes memory /* snowflakeCallBytes */
    ) public senderIsSnowflake {
        revert("Not Implemented.");
    }

    // end recipient is an address
    function snowflakeCall(
        address /* resolver */,
        uint /* einFrom */,
        address payable /* to */,
        uint /* amount */,
        bytes memory /* snowflakeCallBytes */
    ) public senderIsSnowflake {
        revert("Not Implemented.");
    }

    // end recipient is an address, no from field
    function snowflakeCall(
        address /* resolver */,
        address payable /* to */,
        uint /* amount */,
        bytes memory /* snowflakeCallBytes */
    ) public senderIsSnowflake {
        revert("Not Implemented.");
    }

    function setCouponMarketplaceResolverAddress(address _CouponMarketplaceResolverAddress) public onlyEINOwner returns (bool) {
        CouponMarketplaceResolverAddress = _CouponMarketplaceResolverAddress;
        return true;
}

    
    event CouponProcessed(uint total, uint amountRefunded, CouponInterface.CouponType couponType, uint256 amountOff, uint expirationDate);




}

