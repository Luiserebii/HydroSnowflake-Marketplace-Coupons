const IdentityRegistry = artifacts.require('./_testing/IdentityRegistry.sol')
const HydroToken = artifacts.require('./_testing/HydroToken.sol')
const Snowflake = artifacts.require('./Snowflake.sol')
const ClientRaindrop = artifacts.require('./resolvers/ClientRaindrop/ClientRaindrop.sol')
const OldClientRaindrop = artifacts.require('./_testing/OldClientRaindrop.sol')

const NeoCouponMarketplaceResolver = artifacts.require('./resolvers/NeoCouponMarketplaceResolver.sol')
const CouponMarketplaceVia = artifacts.require('./CouponMarketplaceVia.sol')

const ItemFeature = artifacts.require('./marketplace/features/ItemFeature.sol')
const CouponFeature = artifacts.require('./marketplace/features/CouponFeature.sol')
const CouponDistribution = artifacts.require('./marketplace/features/coupon_distribution/CouponDistribution.sol')



async function initialize (owner, users) {
  const instances = {}

  instances.HydroToken = await HydroToken.new({ from: owner })
  for (let i = 0; i < users.length; i++) {
    await instances.HydroToken.transfer(
      users[i].address,
      web3.utils.toBN(1000).mul(web3.utils.toBN(1e18)),
      { from: owner }
    )
  }

  instances.IdentityRegistry = await IdentityRegistry.new({ from: owner })

  instances.Snowflake = await Snowflake.new(
    instances.IdentityRegistry.address, instances.HydroToken.address, { from: owner }
  )

  instances.OldClientRaindrop = await OldClientRaindrop.new({ from: owner })

  instances.ClientRaindrop = await ClientRaindrop.new(
    instances.Snowflake.address, instances.OldClientRaindrop.address, 0, 0, { from: owner }
  )
  await instances.Snowflake.setClientRaindropAddress(instances.ClientRaindrop.address, { from: owner })


  /*instances.CouponMarketplace = await CouponMarketplace.new(1, "Test_Name", "Test_Desc", instances.Snowflake.address, false, false, {from: owner })*/

  return instances
}


async function deployCouponMarketplaceResolver (owner, snowflakeAddress, snowflakeName = "Test_Name", snowflakeDescription = "Test_Desc", callOnAddition = false, callOnRemoval = false, paymentAddress = owner, CouponMarketplaceViaAddress = "0xcD01CD6B160D2BCbeE75b59c393D0017e6BBF427") {

  let cmprContract = await CouponMarketplaceResolver.new(snowflakeName, snowflakeDescription, snowflakeAddress, callOnAddition, callOnRemoval, paymentAddress, CouponMarketplaceViaAddress, {from: owner })
  return cmprContract

}

async function deployCouponMarketplaceVia (owner, snowflakeAddress) {
  let cmpvContract = await CouponMarketplaceVia.new(snowflakeAddress, { from: owner })
  return cmpvContract
}


module.exports = {
  initialize: initialize,
  deploy: {
    couponMarketplaceResolver: deployCouponMarketplaceResolver,
    couponMarketplaceVia: deployCouponMarketplaceVia
  },
  'ItemFeature': ItemFeature,
  'CouponFeature': CouponFeature,
  'NeoCouponMarketplaceResolver': NeoCouponMarketplaceResolver,
  'CouponDistribution': CouponDistribution
}
