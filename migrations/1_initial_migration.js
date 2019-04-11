/*
 *==============
 * Migrations - Written specifically for deploying CouponMarketplaceResolver and related contracts to Rinkeby.
 *==============
 *
 */



//Settings

const snowflakeAddress = '0xB0D5a36733886a4c5597849a05B315626aF5222E';
const instances = {};


module.exports = async function (deployer, network, accounts) {


  //Set up "settings"
  const seller = {
    address: accounts[0],
    paymentAddress: accounts[1],
    recoveryAddress: accounts[1]
  }


  //Import contract artifacts
  const Snowflake = artifacts.require('Snowflake')
  const IdentityRegistry = artifacts.require('IdentityRegistry')
  const ItemFeature = artifacts.require('ItemFeature')
  const CouponFeature = artifacts.require('CouponFeature')
  const CouponMarketplaceVia = artifacts.require('CouponMarketplaceVia')
  const CouponMarketplaceResolver = artifacts.require('CouponMarketplaceResolver')
  const CouponDistribution = artifacts.require('CouponDistribution')




  //Grab Snowflake contract deployed at this address
  instances.Snowflake = await Snowflake.at(snowflakeAddress)

  //Get IdentityRegistryAddress
  const identityRegistryAddress = await instances.Snowflake.identityRegistryAddress.call()

  //Grab IdentityRegistry
  instances.IdentityRegistry = await IdentityRegistry.at(identityRegistryAddress)

  //If we need to, register seller to IdentityRegistry
  if(!(await instances.IdentityRegistry.hasIdentity(seller.address))){

    await instances.IdentityRegistry.createAddress(seller.recoveryAddress, null, null)

    //ensure we have an identity, else, throw
    if(!(await instances.IdentityRegistry.hasIdentity(seller.address))){
      throw "Adding identity to IdentityRegistry failed, despite createAddress line running";
    }
  }
  

  //Deploy ItemFeature, CouponFeature, CouponMarketplaceVia, CouponMarketplaceResolver
  deployer.deploy(ItemFeature, instances.Snowflake.address, { from: seller.address })
  deployer.deploy(CouponFeature, instances.Snowflake.address, { from: seller.address })
  deployer.deploy(CouponMarketplaceVia, seller.address, instances.Snowflake.address, { from: seller.address })
  deployer.deploy(
        CouponMarketplaceResolver, 
        "Coupon-Marketplace-Resolver",
        "A test Coupon Marketplace Resolver built on top of Hydro Snowflake",
        instances.Snowflake.address,
        false, false,
        seller.paymentAddress,
        CouponMarketplaceVia.address, //According to the docs, the regular "imports" should have this populated by the "deployer"
        CouponFeature.address,
        ItemFeature.address
)

  //Set CouponMarketplaceResolver address within Coupon Marketplace Via
  instances.CouponMarketplaceVia = CouponMarketplaceVia.at(CouponMarketplaceVia.address)
  instances.CouponMarketplaceVia.setCouponMarketplaceResolverAddress(CouponMarketplaceResolver.address, { from: seller.address })

  //Deploy Coupon Distribution contract
  deployer.deploy(CouponDistribution, CouponMarketplaceResolver.address, instances.Snowflake.address, { from: seller.address })

  //Set Coupon Distribution address within SnowflakeEINMarketplace contract (i.e. the Resolver)
  instances.CouponMarketplaceResolver.setCouponDistributionAddress(CouponDistribution.address, { from: seller.address })


console.log("Neat, we ran!")

}

