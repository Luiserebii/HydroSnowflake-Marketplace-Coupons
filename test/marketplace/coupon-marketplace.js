const common = require('../common')
const mapi = require('./marketplace-api')
const MarketplaceAPI = new mapi()
const Test = require('./test-data')
//console.log(common)
const { sign, verifyIdentity } = require('../utilities')
const util = require('util')

const BN = web3.utils.BN
const allEnums = require('../../enum_mappings/enums.js')
const enums = allEnums.CouponMarketPlaceResolverInterface;

const ItemFeature = common.ItemFeature
const CouponFeature = common.CouponFeature
const CouponDistribution = common.CouponDistribution
const CouponMarketplaceResolver = common.CouponMarketplaceResolver




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
      ein: 1,
      address: accounts[0],
      paymentAddress: accounts[0],
      recoveryAddress: accounts[0],
      private: '0x2665671af93f210ddb5d5ffa16c77fcf961d52796f2b2d7afd32cc5d886350a8'
    },
    {
      hydroID: 'abc',
      ein: 2,
      address: accounts[1],
      recoveryAddress: accounts[1],
      private: '0x6bf410ff825d07346c110c5836b33ec76e7d1ee051283937392180b732aa3aff'
    },
    {
      hydroID: 'xyz',
      ein: 3,
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
    instances = await common.initialize(accounts[0], users.slice(0,3))
  })

  describe('Testing Coupon Marketplace', async () => {

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
        let newItemTag = Test.itemTags[0];

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

        let newItemTag = Test.itemTags[1];
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
        itemLID = parseInt(await instances.ItemFeature.nextItemListingsID.call(), 10)
      })

      it('can add', async function () {

        let newItemL = Test.itemListings[0]; 
        //console.log("newItemL:    \n\n");
        //console.log(util.inspect(newItemL))
        //Add it
        await instances.ItemFeature.addItemListing(
          await instances.ItemFeature.ownerEIN.call(),
          ...Object.values(newItemL),   
          {from: seller.address}
        )

        //Ensure ID has advanced
        let currID = await instances.ItemFeature.nextItemListingsID.call()
        assert.equal(itemLID + 1, currID)

        //Ensure it exists 
        assert.ok(await instances.ItemFeature.itemListings.call(itemLID));

        //Check over properties for equality:
        assert.ok(await MarketplaceAPI.itemStructIsEqual(instances.ItemFeature, itemLID, newItemL));


      })

      it('can update', async function () {

        let newItemL = Test.itemListings[1]; 
        //Update
        await instances.ItemFeature.updateItemListing(
          itemLID,
          ...Object.values(newItemL), 
          {from: seller.address}
        )

        //Check over properties for equality
        assert.ok(await MarketplaceAPI.itemStructIsEqual(instances.ItemFeature, itemLID, newItemL))
      })

      it('can remove', async function () {

        //Delete
        await instances.ItemFeature.deleteItemListing(itemLID)

        //Check if empty
        //TODO: Factor out empty data sets like this elsewhere
        assert.ok(await MarketplaceAPI.itemStructIsEqual(instances.ItemFeature, itemLID,
        {
          uuid: 0,
          quantity: 0,
          itemType: 0,
          status: 0,
          condition: 0,
          title: "",
          description: "",
          price: 0,
          delivery: undefined,
          tags: undefined,
          returnPolicy: 0
        }
        ))



      })
            
    })
    describe('ReturnPolicies', async function () {
      let returnPolicyID;

      it('can add', async function () {
        returnPolicyID = parseInt(await instances.CouponMarketplaceResolver.nextReturnPoliciesID.call(), 10)
        let newReturnPolicy = Test.returnPolicies[0];
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

        let newReturnPolicy = Test.returnPolicies[1]; 
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

        acID = parseInt(await instances.CouponFeature.nextAvailableCouponsID.call(), 10)
        let newAC = Test.availableCoupons[0];
        //Add it
        await instances.CouponFeature.addAvailableCoupon(
          await instances.CouponFeature.ownerEIN.call(),
          ...Object.values(newAC),
          {from: seller.address}
        );

        //Ensure ID has advanced
        let postAdditionID = parseInt(await instances.CouponFeature.nextAvailableCouponsID.call(), 10)
        assert.equal(acID + 1, postAdditionID)

        //Test for equality
        assert.ok(await MarketplaceAPI.couponStructIsEqual(instances.CouponFeature, acID, newAC));
      })

      it('can update', async function () {

        let newAC = Test.availableCoupons[1];
 
        //Update
        await instances.CouponFeature.updateAvailableCoupon(
          acID,
          ...Object.values(newAC),
         {from: seller.address}
        );

        //Check over properties for equality
        assert.ok(await MarketplaceAPI.couponStructIsEqual(instances.CouponFeature, acID, newAC));
 
      })
      it('can remove', async function () {

        //Delete
        await instances.CouponFeature.deleteAvailableCoupon(acID, {from: seller.address});

        //Grab
        let acExisting = await instances.CouponFeature.availableCoupons.call(acID);

        //Check for default/equality
        assert.ok(await MarketplaceAPI.couponStructIsEqual(instances.CouponFeature, acID,
        {
          couponType: 0,
          title: '' ,
          description: '',
          amountOff: 0,
          itemsApplicable: undefined,
          expirationDate: 0
        }
        ))

 
      })
            
    })

    describe('Purchase Item', async function () {

      let buyer = users[1]

      it('add buyer to IdentityRegistry', async function () {
        await MarketplaceAPI.addToIdentityRegistry(buyer, instances.IdentityRegistry, instances.Snowflake, instances.ClientRaindrop)
      })

      it('add allowance for Snowflake address', async function () {

        let allowance = 750;

        //Test if empty
        let snowflakeDepositAmount = await instances.Snowflake.deposits(buyer.ein);
        assert.ok(snowflakeDepositAmount.eq(new BN(0)))

        //Keep track of our balance beforehand   
        let currBal = await instances.HydroToken.balanceOf(buyer.address);


        //Add the allowance
        //  approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        await instances.HydroToken.approveAndCall(instances.Snowflake.address, allowance, "0x", {from: buyer.address})

        //Test to see if allowance is there 
        let snowflakeDepositAmountNew = await instances.Snowflake.deposits(buyer.ein);
        assert.ok(snowflakeDepositAmountNew.eq(new BN(allowance)))

        //Check to see amount of HYDRO removed from our account
        let newBal = await instances.HydroToken.balanceOf(buyer.address);
        assert.ok((currBal.sub(newBal)).eq(new BN(allowance)))

     })

      it('add CouponMarketplaceResolver as resolver for buyer', async function () {

        let resolverAllowance = 200;

        //Check that is empty
        let currResolverAllowance = await instances.Snowflake.resolverAllowances(buyer.ein,instances.CouponMarketplaceResolver.address)
        assert.ok(currResolverAllowance.eq(new BN(0)))

        //Add resolver along with allowance
        await instances.Snowflake.addResolver(
          instances.CouponMarketplaceResolver.address,
          true,
          resolverAllowance,
          "0x00aaff", //arbitrary bytes here
          {from: buyer.address}
        )

        //Test resolver allowance is added
        let newResolverAllowance = await instances.Snowflake.resolverAllowances(buyer.ein,instances.CouponMarketplaceResolver.address)
        assert.ok(newResolverAllowance.eq(new BN(resolverAllowance)))


      })

      it('add item', async function () {
        let newItemL = Test.itemListings[0]; 
        //Add it
        await instances.ItemFeature.addItemListing(
          await instances.ItemFeature.ownerEIN.call(),
          ...Object.values(newItemL),   
          {from: seller.address}
        )
      })

      it('buyer purchases item (no coupon)', async function () {
/*
        function purchaseItem(uint id, bytes memory data, address approvingAddress, uint couponID)

*/
        let itemID = (await instances.ItemFeature.nextItemListingsID()).sub(new BN(1));
        let owner = await instances.ItemFeature.ownerOf(itemID);


        //Approve address for transfer of item
        console.log("APPROVED ADDRESS FOR THIS ITEM: " + await instances.ItemFeature.getApprovedAddress(itemID));
        assert.ok(await instances.ItemFeature.approveAddress(instances.CouponMarketplaceVia.address, itemID, {from: seller.address}))
        console.log("APPROVED ADDRESS FOR THIS ITEM: " + await instances.ItemFeature.getApprovedAddress(itemID));
 

        console.log("OURID:   " + itemID)
        let itemPrice = Test.itemListings[0].price;

        let currSnowflakeDepositAmount = await instances.Snowflake.deposits(buyer.ein);
        let currResolverAllowance = await instances.Snowflake.resolverAllowances(buyer.ein,instances.CouponMarketplaceResolver.address)


        let currSnowflakeDepositAmountSeller = await instances.Snowflake.deposits(seller.ein);
        let currResolverAllowanceSeller = await instances.Snowflake.resolverAllowances(seller.ein,instances.CouponMarketplaceResolver.address)



console.log("THE EIN OF THE PERSON OWNING THIS ITEM IS: " + owner)
console.log("THE EIN OF THE BUYER IS: " + buyer.ein)
console.log("THE EIN OF THE SELLER IS: " + seller.ein)

console.log("THE EIN OF THE BUYER IS: " + await instances.IdentityRegistry.getEIN(buyer.address))
console.log("THE EIN OF THE SELLER IS: " + await instances.IdentityRegistry.getEIN(seller.address))


        //Assert seller's ownership over this item
        assert.ok(owner.eq(new BN(seller.ein)));

        //Purchase the item
        let res = await instances.CouponMarketplaceResolver.purchaseItem(itemID, buyer.address, 0, {from: buyer.address})
//        console.log(util.inspect(res.receipt.logs))
console.log("\n\nPOST-PURCHASE: \n\n\n")


        //Assert our ownership of the item
        owner = await instances.ItemFeature.ownerOf(itemID);
        console.log("THE EIN OF THE PERSON OWNING THIS ITEM IS: " + owner)
        console.log("THE EIN OF THE BUYER IS: " + buyer.ein)
        console.log("THE EIN OF THE SELLER IS: " + seller.ein)
        console.log("APPROVED ADDRESS FOR THIS ITEM (IS IT CLEARED???): " + await instances.ItemFeature.getApprovedAddress(itemID));
 


        //Test for amount spent given
        let postSnowflakeDepositAmount = await instances.Snowflake.deposits(buyer.ein);
        let postResolverAllowance = await instances.Snowflake.resolverAllowances(buyer.ein,instances.CouponMarketplaceResolver.address)

        //Ensure the cost of the item has been subtracted from both of these
        assert.ok((currSnowflakeDepositAmount.sub(postSnowflakeDepositAmount)).eq(new BN(itemPrice)))
        assert.ok((currResolverAllowance.sub(postResolverAllowance)).eq(new BN(itemPrice)))



        let postSnowflakeDepositAmountSeller = await instances.Snowflake.deposits(seller.ein);
        let postResolverAllowanceSeller = await instances.Snowflake.resolverAllowances(seller.ein,instances.CouponMarketplaceResolver.address)

        console.log(currSnowflakeDepositAmountSeller);
        console.log(currResolverAllowanceSeller)

        console.log(postSnowflakeDepositAmountSeller);
        console.log(postResolverAllowanceSeller)

      })

    })


    describe.skip('Purchase Item (with a coupon)', async function () {

      let buyer = users[1]
      let couponID

      it('add coupon', async function () {

        // Grab our next avaiable coupon ID
        couponID = parseInt(await instances.CouponMarketplaceResolver.nextAvailableCouponsID.call(), 10)

/*

  TODO: Listing ideas for refactoring here:

1. Seperate config files for example objects like avaliable coupons, like an array of these
2. refactor the passing of these params by creating helper functions that return the arguments below from an object (e.g. ...addAvaliableCoupon( await parseAvaliableCoupon(newAC) , {from: seller.address} )), something like this
3. Need to find a way to organize "steps", there is disorganization in that some things, such as users being added to IdentityRegistry being done once in a previous test and sort of assumed to carry forward



*/


        let newAC = { 
          couponType: enums.CouponType.AMOUNT_OFF,
          title: '50 HYDRO Test Discount!' ,
          description: 'A small little discount for you to cherish for a while during its highly transient existence',
          amountOff: 50,
          itemsApplicable: [2], itemsApplicableExpected: undefined,
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

       })

      it('buyer purchases item (50 HYDRO)', async function () {
//        function purchaseItem(uint id, bytes memory data, address approvingAddress, uint couponID)
         //TODO: Swap out the hard-coded 2 for something else, read from next ID and go off of therei

        let res = await instances.CouponMarketplaceResolver.purchaseItem(2, buyer.address, couponID, {from: buyer.address})
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

/*
//Convenience function, assumes instances is set with loaded contracts
async function addToIdentityRegistrySimple(userIdentity) {
  await addToIdentityRegistry(userIdentity, instances.IdentityRegistry, instances.Snowflake, instances.ClientRaindrop)
}

//"Lower-level" convenience function
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

*/
