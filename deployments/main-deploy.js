/////////////////////////////////////////////////////

//DEPLOYMENT:

const SolidityDeploy = require('solidity-deploy');
const config = require('./config');

const Logger = SolidityDeploy.logging.Logger;
const defaultState = Logger.state.NORMAL;
const log = new Logger(defaultState);

const solidityDeploy = new SolidityDeploy(defaultState);

/*
const Compiler = require('./compile/compiler');
const compiler = SolidityDeploy.createDeployer
const Deployer = require('./deploy/deployer');
const deployutil = require('./deploy/deploy-util');
const DeployUtil = new deployutil();
const Flattener = require('./compile/flattener');
const flattener = new Flattener(defaultState);*/
const compiler = solidityDeploy.createCompiler();
const flattener = solidityDeploy.createFlattener();
const DeployUtil = new SolidityDeploy.deploy.DeployUtil();

//const inquirer = require('inquirer');
const logutil = new SolidityDeploy.logging.LogUtil();
const pp = new SolidityDeploy.styling.PrettyPrint();

const path = require('path');
const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const util = require('util');

console.log(config);

const minimist = require('minimist');
//!!! It seems it is necessary to explicitly named these arguments in order to be treated as strings, unfortunately. Darn.
const args = minimist(process.argv.slice(2), { 
  'string': [ 
    'CouponMarketplaceViaAddress',
    'CouponFeatureAddress',
    'ItemFeatureAddress',
    'CouponMarketplaceResolverAddress',
    'CouponDistributionAddress'
  ]
});
console.log("Arguments as defined in process.argv: ");
console.log(util.inspect(process.argv));
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
};

const snowflakeAddress = '0xB0D5a36733886a4c5597849a05B315626aF5222E';
const instances = {};

let accounts;

//Set up "settings"
const seller = {};
 
//Total compiled material, for ABI usage
const compiled = compiler.compileDirectory(config.root);
 

//===========|MAIN|============//
run();
//=============================//

async function run() {
 
  log.print(Logger.state.SUPER, "Building deployer...");
  let deployer = await solidityDeploy.createDeployer(web3, compiled);
  accounts = deployer.accounts;

  seller.address = accounts[0];
  seller.paymentAddress = accounts[1];
  seller.recoveryAddress = accounts[1];

  const stage = args['stage'];

  switch(stage) {
    case Stage.INIT: 

      await init();
      process.exit(0);
      break;

    case Stage.ITEM_FEATURE:
      await itemfeature(snowflakeAddress);
      process.exit(0);
      break;
 
    case Stage.COUPON_FEATURE: 
      await couponfeature(snowflakeAddress);
      process.exit(0);
      break;
      
    case Stage.COUPON_MARKETPLACE_VIA:
      await couponmarketplacevia(snowflakeAddress);
      process.exit(0);
      break;

    case Stage.COUPON_MARKETPLACE_RESOLVER:{
      let couponMarketplaceViaAddress = args['CouponMarketplaceViaAddress'];
      let couponFeatureAddress = args['CouponFeatureAddress'];
      let itemFeatureAddress = args['ItemFeatureAddress'];
      log.print(Logger.state.NORMAL, 
        pp.miniheadline('\nArguments passed:'),
        pp.arrow('CouponMarketplaceViaAddress: ' + couponMarketplaceViaAddress),
        pp.arrow('CouponFeatureAddress: ' + couponFeatureAddress),
        pp.arrow('ItemFeatureAddress: ' + itemFeatureAddress)
      );
      couponMarketplaceViaAddress = await logutil.promptExistence('CouponMarketplaceViaAddress', couponMarketplaceViaAddress);
      couponFeatureAddress = await logutil.promptExistence('CouponFeatureAddress', couponFeatureAddress);
      itemFeatureAddress = await logutil.promptExistence('ItemFeatureAddress', itemFeatureAddress);

      await couponmarketplaceresolver(snowflakeAddress, seller.paymentAddress, couponMarketplaceViaAddress, couponFeatureAddress, itemFeatureAddress);
      process.exit(0);}
      break;
 
    case Stage.SET_1: {
      let couponMarketplaceViaAddress = args['CouponMarketplaceViaAddress'];
      let couponMarketplaceResolverAddress = args['CouponMarketplaceResolverAddress'];
      log.print(Logger.state.NORMAL,
        pp.miniheadline('\nArguments passed:'),
        pp.arrow('CouponMarketplaceViaAddress: ' + couponMarketplaceViaAddress),
        pp.arrow('CouponMarketplaceResolverAddress: ' + couponMarketplaceResolverAddress)
      );
      couponMarketplaceViaAddress = await logutil.promptExistence('CouponMarketplaceViaAddress', couponMarketplaceViaAddress);
      couponMarketplaceResolverAddress = await logutil.promptExistence('CouponMarketplaceResolverAddress', couponMarketplaceResolverAddress);

      await set1(couponMarketplaceViaAddress, couponMarketplaceResolverAddress);
      process.exit(0);}
      break;
 
    case Stage.COUPON_DISTRIBUTION: {
      let couponMarketplaceResolverAddress = args['CouponMarketplaceResolverAddress'];
      log.print(Logger.state.NORMAL,
        pp.miniheadline('\nArguments passed:'),
        pp.arrow('CouponMarketplaceResolverAddress: ' + couponMarketplaceResolverAddress)
      );

      couponMarketplaceResolverAddress = await logutil.promptExistence('CouponMarketplaceResolverAddress', couponMarketplaceResolverAddress);
      await coupondistribution(couponMarketplaceResolverAddress, snowflakeAddress);
      process.exit(0);}
      break;

    case Stage.FINISH:
      let couponMarketplaceResolverAddress = args['CouponMarketplaceResolverAddress'];
      let couponDistributionAddress = args['CouponDistributionAddress'];
      log.print(Logger.state.NORMAL,
        pp.miniheadline('\nArguments passed:'),
        pp.arrow('CouponMarketplaceResolverAddress: ' + couponMarketplaceResolverAddress),
        pp.arrow('CouponDistributionAddress: ' + couponDistributionAddress)
      );

      await finish(couponMarketplaceResolverAddress, couponDistributionAddress);
      process.exit(0);
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
  let deployerItemFeature = await solidityDeploy.createDeployer(web3, compiledItemFeature);
  await deployerItemFeature.deploy("ItemFeature", [snowflakeAddress], { from: seller.address });
  console.log("End of Stage ITEM_FEATURE")

  return true; 

}


async function couponfeature(snowflakeAddress) {

  let compiledCouponFeature = await flattener.flattenAndCompile(path.resolve('../contracts', 'marketplace', 'features', 'CouponFeature.sol'), true);
  let deployerCouponFeature = await solidityDeploy.createDeployer(web3, compiledCouponFeature);
  await deployerCouponFeature.deploy("CouponFeature", [snowflakeAddress], { from: seller.address });
  console.log("End of Stage COUPON_FEATURE")

  return true; 

}

async function couponmarketplacevia(snowflakeAddress) {

  let compiledCMV = await flattener.flattenAndCompile(path.resolve('../contracts', 'CouponMarketplaceVia.sol'), true);
  let deployerCMV = await solidityDeploy.createDeployer(web3, compiledCMV);
  await deployerCMV.deploy("CouponMarketplaceVia", [snowflakeAddress], { from: seller.address });
  console.log("End of Stage COUPON_MARKETPLACE_VIA")

  return true;   

}

async function couponmarketplaceresolver(snowflakeAddress, paymentAddress, couponMarketplaceViaAddress, couponFeatureAddress, itemFeatureAddress) {

  let compiledCMR = await flattener.flattenAndCompile(path.resolve('../contracts/', 'resolvers', 'CouponMarketplaceResolver.sol'), true);
  let deployerCMR = await solidityDeploy.createDeployer(web3, compiledCMR);
  await deployerCMR.deploy("CouponMarketplaceResolver", ["Coupon-Marketplace-Resolver", "A test Coupon Marketplace Resolver built on top of Hydro Snowflake", snowflakeAddress, false, false, paymentAddress, couponMarketplaceViaAddress, couponFeatureAddress, itemFeatureAddress], { from: seller.address });
  console.log("End of Stage COUPON_MARKETPLACE_RESOLVER")

}

async function set1(couponMarketplaceViaAddress, couponMarketplaceResolverAddress) {

  const ABI = DeployUtil.extractContract(compiled, "CouponMarketplaceVia").abi;
  instances.CouponMarketplaceVia = new web3.eth.Contract(ABI, couponMarketplaceViaAddress);

  await instances.CouponMarketplaceVia.methods.setCouponMarketplaceResolverAddress(couponMarketplaceResolverAddress).send({ from: seller.address });
  console.log("End of Stage SET_1");
}

async function coupondistribution(couponMarketplaceResolverAddress, snowflakeAddress) {

  let compiledCouponDistribution = await flattener.flattenAndCompile(path.resolve('../contracts', 'marketplace', 'features', 'coupon_distribution', 'CouponDistribution.sol'), true);
  let deployerCouponDistribution = await solidityDeploy.createDeployer(web3, compiledCouponDistribution);
  await deployerCouponDistribution.deploy("CouponDistribution", [couponMarketplaceResolverAddress, snowflakeAddress], { from: seller.address });
  console.log("End of Stage COUPON_DISTRIBUTION")
}

async function finish(couponMarketplaceResolverAddress, couponDistributionAddress) {
  
  const ABI = DeployUtil.extractContract(compiled, "CouponMarketplaceResolver").abi;
  instances.CouponMarketplaceResolver = new web3.eth.Contract(ABI, couponMarketplaceResolverAddress);

  await instances.CouponMarketplaceResolver.methods.setCouponDistributionAddress(couponDistributionAddress).send({ from: seller.address });
  console.log("End of Stage FINISH");  

}










