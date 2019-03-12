const common = require('./common.js')
const { sign, verifyIdentity } = require('./utilities')

let user
let instances
contract('Testing Coupon Marketplace', function (accounts) {
  const users = [
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

      instances = await common.initialize(accounts[0], [])
      user = {hydroID: 'testabc', address: accounts[0], recoveryAddress: accounts[0], private: '0x6bf410ff825d07346c110c5836b33ec76e7d1ee051283937392180b732aa3eff'}
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



    it('Deployer is EIN Owner', async function () {
      let isEINOwner = await instances.CouponMarketplace.isEINOwner({ from: accounts[0] })
      assert.equal(isEINOwner, true);
    })
  
  })



})
