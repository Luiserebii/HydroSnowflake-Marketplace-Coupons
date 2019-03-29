/*
 * =================== 
 *   Marketplace API - a general compilation of functions that will ideally ease the writing process. Refactoring will go here
 * ===================
 *
 * 
 */

const testdata = require('./test-data.js')
const util = require('util')

const BN = web3.utils.BN
const allEnums = require('../../enum_mappings/enums.js')
const enums = allEnums.CouponMarketPlaceResolverInterface;


class MarketplaceAPI {


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


}

module.exports = MarketplaceAPI;
