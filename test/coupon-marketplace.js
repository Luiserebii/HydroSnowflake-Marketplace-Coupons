const common = require('./common.js')
const { sign, verifyIdentity } = require('./utilities')
const util = require('util')

const BN = web3.utils.BN
const allEnums = require('../enum_mappings/enums.js')
const enums = allEnums.CouponMarketPlaceResolverInterface;


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
/*
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
      })*/
      await addToIdentityRegistry(seller);

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
      let itemLID;
  
      it('get nextItemListingID', async function () {
        itemLID = parseInt(await instances.CouponMarketplaceResolver.nextItemListingsID.call(), 10)
      })

      it('can add', async function () {

        let newItemL = {
          uuid: 7329140802,
          quantity: 1,
          itemType: enums.ItemType.DIGITAL,
          status: enums.ItemStatus.INACTIVE,
          condition: enums.ItemCondition.GOOD,
          title: "Test Item",
          description: "An item you should probably buy",
          price: 8000,
          delivery: [], deliveryExpected: undefined,
          tags: [], tagsExpected: undefined,
          returnPolicy: 0
        }

        //Add it
        await instances.CouponMarketplaceResolver.addItemListing(
          newItemL.uuid,
          newItemL.quantity,
          newItemL.itemType,
          newItemL.status,
          newItemL.condition,
          newItemL.title,
          newItemL.description,
          newItemL.price,
          newItemL.delivery,
          newItemL.tags,
          newItemL.returnPolicy
        )

        //Ensure ID has advanced
        let currID = await instances.CouponMarketplaceResolver.nextItemListingsID.call()
        assert.equal(itemLID + 1, currID)

        //Ensure it exists 
        let itemLExisting = await instances.CouponMarketplaceResolver.itemListings.call(itemLID);

        //Check over properties for equality:
        assert.equal(newItemL.uuid, itemLExisting.uuid);
        assert.equal(newItemL.quantity, itemLExisting.quantity);
        assert.equal(newItemL.itemType, itemLExisting.itemType);
        assert.equal(newItemL.status, itemLExisting.status);
        assert.equal(newItemL.condition, itemLExisting.condition);
        assert.equal(newItemL.title, itemLExisting.title);
        assert.equal(newItemL.description, itemLExisting.description);
        assert.equal(newItemL.price, itemLExisting.price);
        assert.equal(newItemL.deliveryExpected, itemLExisting.delivery);
        assert.equal(newItemL.tagsExpected, itemLExisting.tags);
        assert.equal(newItemL.returnPolicy, itemLExisting.returnPolicy);

      })

      it('can update', async function () {

        let newItemL = {
          uuid: 7329140802,
          quantity: 10,
          itemType: enums.ItemType.DIGITAL,
          status: enums.ItemStatus.ACTIVE,
          condition: enums.ItemCondition.NEW,
          title: "Test IMPROVED Item",
          description: "An item you should ***DEFINITELY*** buy",
          price: 10000,
          delivery: [], deliveryExpected: undefined,
          tags: [], tagsExpected: undefined,
          returnPolicy: 1
        }

        //Update
        await instances.CouponMarketplaceResolver.updateItemListing(
          itemLID,
          newItemL.uuid,
          newItemL.quantity,
          newItemL.itemType,
          newItemL.status,
          newItemL.condition,
          newItemL.title,
          newItemL.description,
          newItemL.price,
          newItemL.delivery,
          newItemL.tags,
          newItemL.returnPolicy
        )

        //Get current
        let itemLExisting = await instances.CouponMarketplaceResolver.itemListings.call(itemLID);

        //Check over properties for equality
        assert.equal(newItemL.uuid, itemLExisting.uuid);
        assert.equal(newItemL.quantity, itemLExisting.quantity);
        assert.equal(newItemL.itemType, itemLExisting.itemType);
        assert.equal(newItemL.status, itemLExisting.status);
        assert.equal(newItemL.condition, itemLExisting.condition);
        assert.equal(newItemL.title, itemLExisting.title);
        assert.equal(newItemL.description, itemLExisting.description);
        assert.equal(newItemL.price, itemLExisting.price);
        assert.equal(newItemL.deliveryExpected, itemLExisting.delivery);
        assert.equal(newItemL.tagsExpected, itemLExisting.tags);
        assert.equal(newItemL.returnPolicy, itemLExisting.returnPolicy);


      })
      it('can remove', async function () {

        //Delete
        await instances.CouponMarketplaceResolver.deleteItemListing(itemLID)

        //Grab
        let itemLExisting = await instances.CouponMarketplaceResolver.itemListings.call(itemLID);

        //Check
        assert.equal(0, itemLExisting.uuid);
        assert.equal(0, itemLExisting.quantity);
        assert.equal(0, itemLExisting.itemType);
        assert.equal(0, itemLExisting.status);
        assert.equal(0, itemLExisting.condition);
        assert.equal('', itemLExisting.title);
        assert.equal('', itemLExisting.description);
        assert.equal(0, itemLExisting.price);
        assert.equal(undefined, itemLExisting.delivery);
        assert.equal(undefined, itemLExisting.tags);
        assert.equal(0, itemLExisting.returnPolicy);

      })
      
      
    })
    describe('ReturnPolicies', async function () {
      let returnPolicyID;

      it('can add', async function () {
        returnPolicyID = parseInt(await instances.CouponMarketplaceResolver.nextReturnPoliciesID.call(), 10)
        let newReturnPolicy = { returnsAccepted: true, timeLimit: 20000 };
        //Add it
        await instances.CouponMarketplaceResolver.addReturnPolicy(newReturnPolicy.returnsAccepted, newReturnPolicy.timeLimit, {from: seller.address})
        //Ensure ID has advanced
        let postAdditionID = parseInt(await instances.CouponMarketplaceResolver.nextReturnPoliciesID.call(), 10)
        assert.equal(returnPolicyID + 1, postAdditionID)
        //Ensure it exists
        let returnPolicyExisting = await instances.CouponMarketplaceResolver.returnPolicies.call(returnPolicyID);

        //Check over properties for equality:
        assert.equal(newReturnPolicy.returnsAccepted, returnPolicyExisting[0])
        assert.equal(newReturnPolicy.timeLimit, returnPolicyExisting[1])

      })

      it('can update', async function () {

        let newReturnPolicy = { returnsAccepted: false, timeLimit: 50 }; 
        let returnPolicy = await instances.CouponMarketplaceResolver.returnPolicies.call(returnPolicyID)
        //Update the item tag at listingID
        await instances.CouponMarketplaceResolver.updateReturnPolicy(returnPolicyID, newReturnPolicy.returnsAccepted, newReturnPolicy.timeLimit, {from: seller.address})
        
        let currReturnPolicy = await instances.CouponMarketplaceResolver.returnPolicies.call(returnPolicyID)
        assert.equal(newReturnPolicy.returnsAccepted, currReturnPolicy[0])
        assert.equal(newReturnPolicy.timeLimit, currReturnPolicy[1])
 
      })
      it('can remove', async function () {

        await instances.CouponMarketplaceResolver.deleteReturnPolicy(returnPolicyID, {from: seller.address})
        let currReturnPolicy = await instances.CouponMarketplaceResolver.returnPolicies.call(returnPolicyID)

        //Test to see that this doesn't exist (i.e. returns default, since mapping)

        //check over properties for equality:
        assert.equal(false, currReturnPolicy[0]);
        assert.isTrue(currReturnPolicy[1].eq(new BN(0)));
       
      })
      
      
    })
    describe('AvailableCoupons', async function () {
      let acID;

      it('can add', async function () {
        acID = parseInt(await instances.CouponMarketplaceResolver.nextAvailableCouponsID.call(), 10)
        let newAC = { 
          couponType: enums.CouponType.AMOUNT_OFF,
          title: '50 HYDRO Test Discount!' ,
          description: 'A small little discount for you to cherish for a while during its highly transient existence',
          amountOff: 50,
          itemsApplicable: [], itemsApplicableExpected: undefined,
          expirationDate: 1571312124
        }
        //Add it
        await instances.CouponMarketplaceResolver.addAvailableCoupon(
          newAC.couponType,
          newAC.title,
          newAC.description,
          newAC.amountOff,
          newAC.itemsApplicable,
          newAC.expirationDate,
          {from: seller.address}
        );

        //Ensure ID has advanced
        let postAdditionID = parseInt(await instances.CouponMarketplaceResolver.nextAvailableCouponsID.call(), 10)
        assert.equal(acID + 1, postAdditionID)

        //Ensure it exists
        let acExisting = await instances.CouponMarketplaceResolver.availableCoupons.call(acID);

        //Check over vals
        //TODO: I wonder if it is a good idea to place these property titles into an array and sort of do a template literal loop magic here...? Hmm...
        assert.equal(newAC.couponType, acExisting.couponType);
        assert.equal(newAC.title, acExisting.title);
        assert.equal(newAC.description, acExisting.description);
        assert.equal(newAC.amountOff, acExisting.amountOff);
        /*=======
           NOTE:
          =======

          A blank input array will work in passing [], however when being read, will returned undefined; therefore, we cannot simply check it against our initially set []. I added a little "expected" value set to undefined to keep the syntax/design consistent, but this exception is incredibly important to note, took me a while to figure out!

        */
        assert.equal(newAC.itemsApplicableExpected, acExisting.itemsApplicable);
        assert.equal(newAC.expirationDate, acExisting.expirationDate);
      })

      it('can update', async function () {

        let newAC = { 
          couponType: enums.CouponType.PERCENTAGE_OFF,
          title: '20% OFF Test Discount!' ,
          description: 'A HUGE LITTLE discount for you to cherish for a while during its highly transient existence',
          amountOff: 20,
          itemsApplicable: [1,2,3], itemsApplicableExpected: [1,2,3],
          expirationDate: 1591312124
        }

        //Update
        await instances.CouponMarketplaceResolver.updateAvailableCoupon(
          acID,
          newAC.couponType,
          newAC.title,
          newAC.description,
          newAC.amountOff,
          newAC.itemsApplicable,
          newAC.expirationDate,
          {from: seller.address}
        );

        //Get current
        let acExisting = await instances.CouponMarketplaceResolver.availableCoupons.call(acID);

//console.log(util.inspect(acExisting))

        //Check over properties for equality
        assert.equal(newAC.couponType, acExisting.couponType);
        assert.equal(newAC.title, acExisting.title);
        assert.equal(newAC.description, acExisting.description);
        assert.equal(newAC.amountOff, acExisting.amountOff);
        assert.equal(newAC.itemsApplicableExpected, acExisting.itemsApplicable);
        assert.equal(newAC.expirationDate, acExisting.expirationDate);
 
      })
      it('can remove', async function () {

        //Delete
        await instances.CouponMarketplaceResolver.deleteAvailableCoupon(acID, {from: seller.address});

        //Grab
        let acExisting = await instances.CouponMarketplaceResolver.availableCoupons.call(acID);

        //Check for default/equality
        assert.equal(0, acExisting.couponType);
        assert.equal('', acExisting.title);
        assert.equal('', acExisting.description);
        assert.equal(0, acExisting.amountOff);
        assert.equal(undefined, acExisting.itemsApplicable);
        assert.equal(0, acExisting.expirationDate);
 
      })
            
    })

    describe('Purchase Item', async function () {

      let buyer = users[1]

      it('add buyer to IdentityRegistry', async function () {
        addToIdentityRegistry(buyer)
      })




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


//Convenience function, assumes instances is set with loaded contracts
async function addToIdentityRegistry(let userIdentity) {
  await addToIdentityRegistry(userIdentity, instances.IdentityRegistry, instances.Snowflake, instances.ClientRaindrop)
}

//"Lower-level" convenience function
async function addToIdentityRegistry(let userIdentity, let IdentityRegistryInstance, let SnowflakeInstance, let ClientRaindropInstance){

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

      userIdentity.identity = web3.utils.toBN(1)

      await verifyIdentity(userIdentity.identity, IdentityRegistryInstance, {
        recoveryAddress:     userIdentity.recoveryAddress,
        associatedAddresses: [userIdentity.address],
        providers:           [SnowflakeInstance.address],
        resolvers:           [ClientRaindropInstance.address]
      })

}


