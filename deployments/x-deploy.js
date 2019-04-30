/////////////////////////////////////////////////////

//DEPLOYMENT:

const Compiler = require('./compile/compiler');
const compiler = new Compiler();
const Deployer = require('./deploy/deployer');
const deployutil = require('./deploy/deploy-util');
const DeployUtil = new deployutil();

const defaultConfig = require('./config/default-config')
const Logger = require('./logging/logger.js')
const log = new Logger(Logger.state.MASTER);

const fs = require('fs');
const path = require('path');
const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const util = require('util');

const config = require('./config/deploy-config');
console.log(config);

const minimist = require('minimist');
const args = minimist(process.argv.slice(2));

const Flattener = require('./compile/flattener')
const flattener = new Flattener(Logger.state.MASTER);


const provider = new HDWalletProvider(
   config.mnemonic, 
   `https://rinkeby.infura.io/v3/${config.infuraKey}`,
   0,
   10
);
const web3 = new Web3(provider);
const Stage = {
  INIT: 1,
  ITEM_FEATURE: 2,
  COUPON_FEATURE: 3,
  COUPON_MARKETPLACE_VIA: 4,
  COUPON_MARKETPLACE_RESOLVER: 5,
  SET_1: 6,
  COUPON_DISTRIBUTION: 7,
  FINISH: 8
}

const compiled = config.root ? compiler.compileDirectory(config.root) : compiler.compileDirectory(defaultConfig.root);
 
//===========|MAIN|============//
run();
//=============================//


async function run() {
  const deployer = await Deployer.build(web3, compiled);

  const stage = args['stage'];

  switch(stage) {
    case Stage.INIT: 
      await deployer.deploy("Calculator");

      break;
    case Stage.ITEM_FEATURE:

      const compiledNumber = await flattener.flattenAndCompile('../contracts/main-contracts/Number.sol', true);
      const numberDeployer = await Deployer.build(web3, compiledNumber);
      await deployer.deploy("Number");

      break;
    case Stage.COUPON_FEATURE:
      const compiledNumberBasic = await flattener.flattenAndCompile('../contracts/main-contracts/NumberBasic.sol', true);
      const numberBasicDeployer = await Deployer.build(web3, compiledNumberBasic);
      await deployer.deploy("NumberBasic", [5]);  
      break;

  }

}

