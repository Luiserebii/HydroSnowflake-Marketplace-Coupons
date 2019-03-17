const common = require('./common.js')
const { sign, verifyIdentity } = require('./utilities')
const util = require('util')

let user
let instances


/*

1. Make CouponMarketPlaceVia (_snowflakeAddress)
2. Make CouponMarketplaceResolver

Pass: 
EIN, "SnowflakeName", "Snowflake Description", SnowflakeAddress, false, false, paymentAddress, MarketplaceCouponViaAddress


3. Add CouponMarketplaceResolver as provider for seller


Test:

Only seller can call add/update/delete

Adding a listing
   -Adding a listing (ensure it is correct, and thus readable)
      -ID thing advances
      -Readable post-addition

   -Adding delivery methods
   -Adding tags
   -Adding a return policy
   -Adding an avaliable coupon

   -Updating a tag
   -Updating return policy
   -Updating coupon

   -Removing an item
      -No longer existing (check to see what compiler tells you with this stuff)


   -Attached to listing:
   -Updating listing with delivery methods, tags, return policy
      -Test if expected


-Second listing, third listing?


*/




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
    })


    it('deploy Coupon Marketplace Resolver contract', async function () {
      let ein = await instances.IdentityRegistry.getEIN(seller.address)

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
      let isEINOwner = await instances.CouponMarketplaceResolver.isEINOwner.call({ from: accounts[0]})
      assert.isTrue(isEINOwner);
    })

   
    describe('Only EIN Owner can...', async function () {

      describe('call add/update/delete functions [NOTE: using ItemTag functions]', async function () {
        //An arbitary account
        const nonOwner = accounts[1];

        //addItemTag test for failure
        it('addItemTag', async function () {
          await assertSolidityRevert(
            async function(){ 
              await instances.CouponMarketplaceResolver.addItemTag("Test_Item_Tag", {from: nonOwner}) 
            }
          )
        })

        //updateItemTag test for failure
        it('updateItemTag', async function () {
          await assertSolidityRevert(
            async function(){ 
              await instances.CouponMarketplaceResolver.updateItemTag(1, "Test_Item_Tag", {from: nonOwner}) 
            }
          )
        })

        //deleteItemTag test for failure
        it('deleteItemTag', async function () {
          await assertSolidityRevert(
            async function(){ 
              await instances.CouponMarketplaceResolver.deleteItemTag(1, {from: nonOwner})
            }
          )
        })
        /* NOTE: In order to avoid a sludge of tests, we will make the assumption that all add/update/delete functions have the correct modifier specified; we use several of a few simply for peace-of-mind value, though this may be unnecessary/superfluous to some extent
 
        */
      })
      //End of add/update/delete functions
      
    })
    //End of "Only EIN Owner can..."


    describe('ItemTags', async function () {
      let listingID;
      
      it('can add', async function () {

        //Obtain current listing ID
        listingID = parseInt(await instances.CouponMarketplaceResolver.nextItemTagsID.call(), 10)
        let newItemTag = "TestTagA";

        //Add it
        await instances.CouponMarketplaceResolver.addItemTag(newItemTag, {from: seller.address})
        //Ensure ID has advanced
        let postAdditionID = parseInt(await instances.CouponMarketplaceResolver.nextItemTagsID.call(), 10)
        assert.equal(listingID + 1, postAdditionID)
        //Ensure it exists
        let itemTagExisting = await instances.CouponMarketplaceResolver.itemTags.call(listingID)
        //console.log(newItemTag + "  ----  " + itemTagExisting);
        assert.equal(newItemTag, itemTagExisting);

      })

      it('can update', async function () {

        let newItemTag = "TestTagAAA"
        let itemTag = await instances.CouponMarketplaceResolver.itemTags.call(listingID)
        //Update the item tag at listingID
        await instances.CouponMarketplaceResolver.updateItemTag(listingID, newItemTag, {from: seller.address})
        
        let currItemTag = await instances.CouponMarketplaceResolver.itemTags.call(listingID)
        assert.notEqual(itemTag, currItemTag)
        assert.equal(newItemTag, currItemTag)
      })

      it('can remove', async function () {

        await instances.CouponMarketplaceResolver.deleteItemTag(listingID, {from: seller.address})
        let currItemTag = await instances.CouponMarketplaceResolver.itemTags.call(listingID)
        //Test to see that this doesn't exist (i.e. returns nothing, since mapping)
        assert.equal(currItemTag, "");
      })
       
    })
    describe('ItemListings', async function () {
      
      
    })
    describe('ReturnPolicies', async function () {
      
      
    })
    describe('AvaliableCoupons', async function () {
      
      
    })




  
  })



})


//Simply function to test for Solidity revert errors; optionally takes an "expectedErr" which simply looks for a string within
// This function has limits, however; if a function can potentially return two or more reverts, we can't quite test for each of them through expectedErr and apply if/and/or logic
async function assertSolidityRevert(run, expectedErr = null){
  let err;
  try {
    await run();
  } catch(_e) {
    err = _e.message;
  }
  assert.isTrue(err.includes('VM Exception while processing transaction: revert'));
  if(expectedErr != null) assert.isTrue(err.includes(expectedErr));

  return err;
}
