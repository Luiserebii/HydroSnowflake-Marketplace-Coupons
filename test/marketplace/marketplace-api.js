/*
 * =================== 
 *   Marketplace API - a general compilation of functions that will ideally ease the writing process. Refactoring will go here
 * ===================
 *
 * 
 */

const common = require('../common.js')
const { sign, verifyIdentity } = require('../utilities')

const TestData = require('./test-data.js')

const util = require('util')

const BN = web3.utils.BN
const allEnums = require('../../enum_mappings/enums.js')
const enums = allEnums.CouponMarketPlaceResolverInterface;


class MarketplaceAPI {


  /*static*/ async assertSolidityRevert(run, expectedErr = null) {
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
    =======================
      Identity Registry 
    =======================
  */

  
  //Convenience function, assumes instances is set with loaded contracts
  /*static*/ /*async addToIdentityRegistrySimple(userIdentity) {
    await this.addToIdentityRegistry(userIdentity, instances.IdentityRegistry, instances.Snowflake, instances.ClientRaindrop)
  }*/

  //"Lower-level" convenience function
  /*static*/ async addToIdentityRegistry(userIdentity, IdentityRegistryInstance, SnowflakeInstance, ClientRaindropInstance){

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




  // Idea is to provide a nice function to determine equality
  // between returned struct from web3, and ours;
  // Since the returned object contains a strange
  // mixture where values are represented as both
  // '1': __, '2': __, __:__, __:__ (as in, keys are shown alongside values, and numerical mapping to values; values are repeated)
  //[] values are ignored, since arrays will not appear in returned structs
  /*static*/ structIsEqual(intObj, retObj) {
    for(let key in intObj) {
      //[] == [] is false, so we try this as a hack workaround
      if(typeof intObj[key] != "object"){
        assert.equal(intObj[key], retObj[key], `Key: ${key} used to compare values (Internal Obj) ${intObj[key]} and (Returned Obj) ${retObj[key]} `);
      }
    }
  }

  /*
    =========================
      Item Listings to Args
    =========================

  */

  //Actually, to convert to args:
  //
  //  ...Object.values(myObj)
  //  As values() should return an array of the object

  /*
    ===========================
      Return Policies to Args
    ===========================

  */

  /*
    =============================
      Available Coupons to Args
    ============================

  */





}

module.exports = MarketplaceAPI;
