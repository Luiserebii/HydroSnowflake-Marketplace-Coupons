pragma solidity ^0.5.0;

import "./SnowflakeResolver.sol";

contract MyResolver is SnowflakeResolver {
    constructor (address snowflakeAddress)
        SnowflakeResolver("resolverName", "resolverDescription.", snowflakeAddress, true, true) public
    {
        // setSnowflakeAddress(snowflakeAddress);
    }

    // optionally, override the setSnowflakeAddress function of SnowflakeResolver to...
    // function setSnowflakeAddress(address snowflakeAddress) public onlyOwner() {
    //     super.setSnowflakeAddress(snowflakeAddress);
    //     // ...initialize varaiables based on addresses derived from snowflake
    // }

    function onAddition(uint /* ein */, uint /* allowance */, bytes memory /* extraData */) public senderIsSnowflake() returns (bool) {
        // implement function here, or set the _callOnAddition flag to false in the SnowflakeResolver constructor
        return true;
    }

    function onRemoval(uint /* ein */, bytes memory /* extraData */) public senderIsSnowflake() returns (bool) {
        // implement function here, or set the _callOnRemoval flag to false in the SnowflakeResolver constructor
        return true;
    }
}
