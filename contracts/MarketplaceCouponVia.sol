pragma solidity ^0.5.0;

import "./SnowflakeVia.sol";
import "./interfaces/SnowflakeResolverInterface.sol";
import "./zeppelin/math/SafeMath.sol";
import "./interfaces/CouponMarketplaceResolverInterface.sol";

contract CouponMarketplaceVia is SnowflakeVia {


    //We may need to define this in a seperate file... uncertain if this will quite work being in two different locations

//   This is now defined within the CouponMarketplaceResolverInterface.sol, let's test this...
//    enum CouponType { AMOUNT_OFF, PERCENTAGE_OFF, BUY_X_QTY_GET_Y_FREE , BUY_X_QTY_FOR_Y_AMNT }
    
    using SafeMath for uint256;

    // end recipient is an EIN
    function snowflakeCall(
        address /* resolver */,
        uint /* einFrom */,
        uint /* einTo */,
        uint /* amount */,
        bytes memory /* snowflakeCallBytes */
    ) public senderIsSnowflake() {
        address(this).call(snowflakeCallBytes)
    }


    //Name of this function is perhaps a little misleading, since amount has already been transferred, we're just calcing coupon here
    function processTransaction(address resolver, uint einSeller, uint einUser, uint amount, uint couponID) returns (bool) public senderIsSnowflake() {

        //Declare our total
        uint total = amount;

        //Since couponID == 0 means we do not have a coupon, we check this first
        if(couponID != 0){

            uint amountRefund;
            //TODO: Break this out into its own function thingie

            //Get coupon info from our coupon marketplace resolver
            CouponMarketplaceResolverInterface couponMarketplace = CouponMarketplaceResolverInterface(resolver);

            (CouponMarketplaceResolverInterface.CouponType couponType, string title, string description, uint256 amountOff, uint expirationDate) = couponMarketplace.getCoupon(couponID); 

            //Ensure coupon is not expired
            require(now < expirationDate);

            //If couponType is amountOff...
            if(couponType == CouponMarketplaceResolverInterface.CouponType.AMOUNT_OFF){
                total = _applyCouponAmountOff(total, amountOff);
                amountRefund = amountOff;
            }

            //In an event, let's push the transaction or something
            emit CouponProcessed(uint total, uint amountRefund, CouponType couponType, string title, string description, uint256 amountOff, uint expirationDate);
       
            //Finally, let's return their amount... (for security reasons, we follow Checks-Effect-Interaction pattern and modify state last...)
            

        }

   }

    function _applyCouponAmountOff(uint256 total, uint256 amountOff) returns (uint256) private {
        require(total >= amountOff, "Coupon amount is higher than total");
        uint256 newTotal = total.sub(amountOff);
    }

    // end recipient is an EIN, no from field
    function snowflakeCall(
        address /* resolver */,
        uint /* einTo */,
        uint /* amount */,
        bytes memory /* snowflakeCallBytes */
    ) public senderIsSnowflake() {
        revert("Not Implemented.");
    }

    // end recipient is an address
    function snowflakeCall(
        address /* resolver */,
        uint /* einFrom */,
        address payable /* to */,
        uint /* amount */,
        bytes memory /* snowflakeCallBytes */
    ) public senderIsSnowflake() {
        revert("Not Implemented.");
    }

    // end recipient is an address, no from field
    function snowflakeCall(
        address /* resolver */,
        address payable /* to */,
        uint /* amount */,
        bytes memory /* snowflakeCallBytes */
    ) public senderIsSnowflake() {
        revert("Not Implemented.");
    }

    
    event CouponProcessed(uint total, uint amountRefunded, CouponType couponType, string title, string description, uint256 amountOff, uint expirationDate);




}

