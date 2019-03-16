const common = require('./common.js')
const { sign, verifyIdentity } = require('./utilities')
const util = require('util')

let user
let instances
contract('Testing Coupon Marketplace', function (accounts) {
  const users = [
    {
      hydroID: 'sellerabc',
      address: accounts[0],
      paymentAddress: accounts[0],
      recoveryAddress: accounts[0],
      private: '0x2665671af93f210ddb5d5ffa16c77fcf961d52796f2b2d7afd32cc5d886350a8'
    },
    {
      hydroID: 'abc',
      address: accounts[1],
      recoveryAddress: accounts[1],
      private: '0x6bf410ff825d07346c110c5836b33ec76e7d1ee051283937392180b732aa3aff'
    },
    {
      hydroID: 'xyz',
      address: accounts[2],
      recoveryAddress: accounts[2],
      private: '0xccc3c84f02b038a5d60d93977ab11eb57005f368b5f62dad29486edeb4566954'
    },
    {
      public: accounts[3]
    },
    {
      public: accounts[4]
    }
  ]

  it('common contracts deployed', async () => {
    instances = await common.initialize(accounts[0], [])
  })

  describe('Testing Coupon Marketplace', async () => {

    let seller = users[0]

    it('add seller identity to Identity Registry', async function () {

      const timestamp = Math.round(new Date() / 1000) - 1
      const permissionString = web3.utils.soliditySha3(
        '0x19', '0x00', instances.IdentityRegistry.address,
        'I authorize the creation of an Identity on my behalf.',
        seller.recoveryAddress,
        seller.address,
        { t: 'address[]', v: [instances.Snowflake.address] },
        { t: 'address[]', v: [] },
        timestamp
      )

      const permission = await sign(permissionString, seller.address, seller.private)

      await instances.Snowflake.createIdentityDelegated(
        seller.recoveryAddress, seller.address, [], seller.hydroID, permission.v, permission.r, permission.s, timestamp
      )

      seller.identity = web3.utils.toBN(1)

      await verifyIdentity(seller.identity, instances.IdentityRegistry, {
        recoveryAddress:     seller.recoveryAddress,
        associatedAddresses: [seller.address],
        providers:           [instances.Snowflake.address],
        resolvers:           [instances.ClientRaindrop.address]
      })
    })


    it('deploy Coupon Marketplace Via contract', async function () {
      instances.CouponMarketplaceVia = await common.deploy.couponMarketplaceVia(seller.address, instances.Snowflake.address)
      console.log(instances.CouponMarketplaceVia)
    })


    it('deploy Coupon Marketplace Resolver contract', async function () {
      let ein = instances.IdentityRegistry.getEIN(seller.address)

      instances.CouponMarketplaceResolver = await common.deploy.couponMarketplaceResolver(
        seller.address,
        instances.Snowflake.address,
        ein,
        "Test-Marketplace-Resolver",
        "A test Coupon Marketplace Resolver build on top of Hydro Snowflake", 
        false, false,
        seller.paymentAddress,
        instances.CouponMarketplaceVia.address
      )
    })


    it('Deployer is EIN Owner', async function () {
      let isEINOwner = await instances.CouponMarketplaceResolver.isEINOwner({ from: accounts[0], gas: '3000000' })

    })

  
  })



})
