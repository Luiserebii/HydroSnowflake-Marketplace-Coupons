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

const snowflakeAddress = '0xB0D5a36733886a4c5597849a05B315626aF5222E';
const instances = {};

let deployer;
let accounts;
//Set up "settings"
const seller = {};


const compiled = config.root ? compiler.compileDirectory(config.root) : compiler.compileDirectory(defaultConfig.root);

//===========|MAIN|============//
run();
//=============================//


async function run() {

  log.print(Logger.state.SUPER, "Building deployer...")
  deployer = await Deployer.build(web3, compiled);
  accounts = deployer.accounts;

  seller.address = accounts[0];
  seller.paymentAddress = accounts[1];
  seller.recoveryAddress = accounts[1];


//  const deployer = await Deployer.build(web3, compiled);

  const stage = args['stage'];

  switch(stage) {
    case Stage.INIT: 
      //await deployer.deploy("Calculator");

      await init();

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


async function init() {

  //Grab Snowflake contract deployed at this address
  const SnowflakeABI = DeployUtil.extractContract(compiled, "Snowflake").abi;
  instances.Snowflake = new web3.eth.Contract(SnowflakeABI, snowflakeAddress);

  //Get IdentityRegistryAddress
  const identityRegistryAddress = await instances.Snowflake.methods.identityRegistryAddress().call();
  console.log("============================================")
  console.log(identityRegistryAddress)

  //Grab IdentityRegistry
  const identityRegistryABI = DeployUtil.extractContract(compiled, "IdentityRegistry").abi;
  instances.IdentityRegistry = new web3.eth.Contract(identityRegistryABI, identityRegistryAddress);

  //If we need to, register seller to IdentityRegistry
  log.print(Logger.state.SUPER, "Checking to see if our seller has an identity...")
  if(!(await instances.IdentityRegistry.methods.hasIdentity(seller.address).call())){
    log.print(Logger.state.NORMAL, "Seller has no identity; attempting to create one");
    await instances.IdentityRegistry.methods.createIdentity(seller.recoveryAddress, [], []).send({ from: seller.address });
    //ensure we have an identity, else, throw
    if(!(await instances.IdentityRegistry.methods.hasIdentity(seller.address).call())){
      throw "Adding identity to IdentityRegistry failed, despite createAddress line running"
    }
  } else {
    log.print(Logger.state.NORMAL, "Seller has identity registered! Proceeding...");
  }

  console.log("End of Stage INIT")

  return true;
}

async function itemfeature(snowflakeAddress) {

  let compiledItemFeature = await flattener.flattenAndCompile(path.resolve('../contracts', 'marketplace', 'features', 'ItemFeature.sol'), true);
  let deployerItemFeature = await Deployer.build(web3, compiledItemFeature);
  await deployerItemFeature.deploy("ItemFeature", [snowflakeAddress], { from: seller.address });
  console.log("End of Stage ITEM_FEATURE")

  return true; 

}




