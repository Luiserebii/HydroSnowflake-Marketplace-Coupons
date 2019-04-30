/////////////////////////////////////////////////////

//DEPLOYMENT:

const Compiler = require('./compile/compiler');
const compiler = new Compiler();
const Deployer = require('./deploy/deployer');
const Logger = require('./logging/logger');
const Flattener = require('./flatten/flattener');
const flattener = new Flattener(Logger.state.MASTER);
const defaultConfig = require('./config/default-config');

const fs = require('fs');
const path = require('path');
const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const util = require('util');

const config = require('./config/deploy-config');
console.log(config);

const minimist = require('minimist');
const args = minimist(process.argv.slice(2));



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

//Set up "settings"
const seller = {
  address: accounts[0],
  paymentAddress: accounts[1],
  recoveryAddress: accounts[1]
}

//Total compiled material, for ABI usage
const compiled = config.root ? compiler.compileDirectory(config.root) : compiler.compileDirectory(defaultConfig.root);
 

//===========|MAIN|============//
run();
//=============================//


async function run() {

  
 //const deployer = await Deployer.build(web3, compiled);

  const stage = args['stage'];

  switch(stage) {
    case Stage.INIT: 

      await init();


      break;
   /* case Stage.:

      break;
    case Stage.:
  
      break;
*/
  }

}

async function init() {


/*

  //Grab Snowflake contract deployed at this address
  instances.Snowflake = await Snowflake.at(snowflakeAddress)

  //Get IdentityRegistryAddress
  const identityRegistryAddress = await instances.Snowflake.identityRegistryAddress.call()

  //Grab IdentityRegistry
  instances.IdentityRegistry = await IdentityRegistry.at(identityRegistryAddress)

  //If we need to, register seller to IdentityRegistry
  if(!(await instances.IdentityRegistry.hasIdentity(seller.address))){
    console.log("Seller has no identity; attempting to create one")
    await instances.IdentityRegistry.createIdentity(seller.recoveryAddress, [], [], { from: seller.address })
    //ensure we have an identity, else, throw
    if(!(await instances.IdentityRegistry.hasIdentity(seller.address))){
      throw "Adding identity to IdentityRegistry failed, despite createAddress line running"
    }
  }

*/
      const SnowflakeABI = compiler.compile()
      const compiled = await flattener.flattenAndCompile('../contracts/main-contracts/Number.sol', true);
      await deployer.deploy("Calculator");

}










