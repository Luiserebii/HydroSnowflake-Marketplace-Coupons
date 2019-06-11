/**
 *
 * Configuration for solidity-deploy's options. Please copy, replace, and rename to "config.js"!
 *
 * Values to replace are marked by []s.
 * 
 */

const path = require('path');

const deploymentConfig = {

  root: "[PATH-TO-REPO]/HydroSnowflake-Marketplace-Coupons/contracts",
  mnemonic: "[12-WORD-WALLET-MNEMONIC]",
  infuraKey: "[INFURA-API-KEY]",

  etherscan: {
    url: "https://api-rinkeby.etherscan.io/api",
    apiKey: "[ETHERSCAN-API-KEY]" //Not required, feel free to ignore this field
  },

  flatten: {
    writeLocation: "[PATH-TO-REPO]/HydroSnowflake-Marketplace-Coupons/flattened"
  }, deployment: { confirmations: 2 }

};

module.exports = deploymentConfig;

