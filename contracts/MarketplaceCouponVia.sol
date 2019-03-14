pragma solidity ^0.5.0;

import "./SnowflakeVia.sol";
import "./interfaces/SnowflakeResolverInterface.sol";
import "./zeppelin/math/SafeMath.sol";

contract CouponMarketplaceVia is SnowflakeVia {
    
    using SafeMath for uint256;

    // end recipient is an EIN
    function snowflakeCall(
        address /* resolver */,
        uint /* einFrom */,
        uint /* einTo */,
        uint /* amount */,
        bytes memory /* snowflakeCallBytes */
    ) public senderIsSnowflake() {
        revert("Not Implemented.");
    }

    function _applyCoupon(uint256 total, uint256 amountOff) returns (uint256) private {
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



}

