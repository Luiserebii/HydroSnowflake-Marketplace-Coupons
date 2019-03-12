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

    it('deploy CouponMarketplace contract', async function () {
      instances.CouponMarketplace = await common.deploy.couponMarketplace(users[0].address)
    })

    it('add seller identity to Identity Registry', async function () {

      user = users[0]
      const timestamp = Math.round(new Date() / 1000) - 1
      const permissionString = web3.utils.soliditySha3(
        '0x19', '0x00', instances.IdentityRegistry.address,
        'I authorize the creation of an Identity on my behalf.',
        user.recoveryAddress,
        user.address,
        { t: 'address[]', v: [instances.Snowflake.address] },
        { t: 'address[]', v: [] },
        timestamp
      )

      const permission = await sign(permissionString, user.address, user.private)

      await instances.Snowflake.createIdentityDelegated(
        user.recoveryAddress, user.address, [], user.hydroID, permission.v, permission.r, permission.s, timestamp
      )

      user.identity = web3.utils.toBN(1)

      await verifyIdentity(user.identity, instances.IdentityRegistry, {
        recoveryAddress:     user.recoveryAddress,
        associatedAddresses: [user.address],
        providers:           [instances.Snowflake.address],
        resolvers:           [instances.ClientRaindrop.address]
      })
   })


    it('Deployer is EIN Owner', async function () {

//      let isEINOwner = await instances.CouponMarketplace.CouponMarketplace.isEINOwner({ from: accounts[0] })

//        console.log(instances.CouponMarketplace)
  //    assert.equal(isEINOwner, true);
    })
  
  })



})
