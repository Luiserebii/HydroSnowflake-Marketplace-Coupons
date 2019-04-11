/*

const AddressSet = artifacts.require('./_testing/AddressSet/AddressSet.sol')
const IdentityRegistry = artifacts.require('./_testing/IdentityRegistry.sol')

const HydroToken = artifacts.require('./_testing/HydroToken.sol')

const SafeMath = artifacts.require('./zeppelin/math/SafeMath.sol')
const Snowflake = artifacts.require('./Snowflake.sol')

const StringUtils = artifacts.require('./resolvers/ClientRaindrop/StringUtils.sol')
const ClientRaindrop = artifacts.require('./resolvers/ClientRaindrop/ClientRaindrop.sol')
const OldClientRaindrop = artifacts.require('./_testing/OldClientRaindrop.sol')
*/
//const mapi = require('../test/marketplace/marketplace-api')
//const MarketplaceAPI = new mapi()



//Settings



const seller = {
  address: '0xC38076718C883C776700514C8554Dda7558A16bd',
  paymentAddress: '0x6FA229c69Ee78577dd74cCeEb3a91c9d78b04374'
}

const snowflakeAddress = '0xB0D5a36733886a4c5597849a05B315626aF5222E';
const instances = {};



module.exports = async function (deployer, network, accounts) {

  const Snowflake = artifacts.require('Snowflake')

  //Grab Snowflake contract deployed at this address
  instances.Snowflake = await Snowflake.at(snowflakeAddress)

  //Get IdentityRegistryAddress
  const identityRegistryAddress = await instances.Snowflake.identityRegistryAddress.call()

  console.log(identityRegistryAddress)

console.log("Neat, we ran!")
//console.log(web3);


/* describe('Testing Coupon Marketplace', async () => {

    let seller = users[0]

    it('add seller identity to Identity Registry', async function () {
      await MarketplaceAPI.addToIdentityRegistry(seller, instances.IdentityRegistry, instances.Snowflake, instances.ClientRaindrop);
    })


    it('deploy ItemFeature contract', async function () {
      instances.ItemFeature = await ItemFeature.new(instances.Snowflake.address, { from: seller.address })
      //Let's assert that this is loaded in
      //Truthiness of null/undefined is false
      assert.ok(instances.ItemFeature)
    })

    it('deploy CouponFeature contract', async function () {
      instances.CouponFeature = await CouponFeature.new(instances.Snowflake.address, { from: seller.address })
      assert.ok(instances.CouponFeature)
    })


    it('deploy Coupon Marketplace Via contract', async function () {
      instances.CouponMarketplaceVia = await common.deploy.couponMarketplaceVia(seller.address, instances.Snowflake.address)
      assert.ok(instances.CouponMarketplaceVia)
    })


    it('deploy Coupon Marketplace Resolver contract', async function () {
//      let ein = await instances.IdentityRegistry.getEIN(seller.address)

      instances.CouponMarketplaceResolver = await CouponMarketplaceResolver.new(
        "Test-Marketplace-Resolver",
        "A test Coupon Marketplace Resolver built on top of Hydro Snowflake",
        instances.Snowflake.address,
        false, false,
        seller.paymentAddress,
        instances.CouponMarketplaceVia.address,
        instances.CouponFeature.address,
        instances.ItemFeature.address
      )
      assert.ok(instances.CouponMarketplaceResolver)
    })

    it('set CouponMarketplaceResolver address within Coupon Marketplace Via', async function () {
      assert.ok(instances.CouponMarketplaceVia.setCouponMarketplaceResolverAddress(instances.CouponMarketplaceResolver.address, {from: seller.address }));

    })


    it('deploy Coupon Distribution contract', async function () {
      instances.CouponDistribution = await CouponDistribution.new(
        instances.CouponMarketplaceResolver.address,
        instances.Snowflake.address
      )
      assert.ok(instances.CouponDistribution)
    })

    it('set Coupon Distribution address within SnowflakeEINMarketplace contract (i.e. the Resolver)', async function () {
      assert.ok(instances.CouponMarketplaceResolver.setCouponDistributionAddress(instances.CouponDistribution.address, { from: seller.address }))
    })

*/


}



  async function addToIdentityRegistry(userIdentity, IdentityRegistryInstance, SnowflakeInstance, ClientRaindropInstance){

    const timestamp = Math.round(new Date() / 1000) - 1
    const permissionString = web3.utils.soliditySha3(
      '0x19', '0x00', IdentityRegistryInstance.address,
      'I authorize the creation of an Identity on my behalf.',
      userIdentity.recoveryAddress,
      userIdentity.address,
      { t: 'address[]', v: [SnowflakeInstance.address] },
      { t: 'address[]', v: [] },
      timestamp
    )

    const permission = await sign(permissionString, userIdentity.address, userIdentity.private)

    await SnowflakeInstance.createIdentityDelegated(
      userIdentity.recoveryAddress, userIdentity.address, [], userIdentity.hydroID, permission.v, permission.r, permission.s, timestamp
    )
    //console.log("EIN:    " + userIdentity.ein)
    userIdentity.identity = web3.utils.toBN(userIdentity.ein)

    await verifyIdentity(userIdentity.identity, IdentityRegistryInstance, {
      recoveryAddress:     userIdentity.recoveryAddress,
      associatedAddresses: [userIdentity.address],
      providers:           [SnowflakeInstance.address],
      resolvers:           [ClientRaindropInstance.address]
   })

  }

