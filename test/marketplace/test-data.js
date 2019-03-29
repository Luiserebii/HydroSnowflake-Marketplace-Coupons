/*
 *
 * Test Data - simply meant to contain testing inputs for convenience
 * 
 *
 */
const common = require('../common.js')

const allEnums = require('../../enum_mappings/enums.js')
const enums = allEnums.CouponMarketPlaceResolverInterface;
const accounts = web3.eth.getAccounts();

//console.log(web3);
//console.log("ACCOUNTS:" + accounts);
const TestData = {

  'users': [
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
  ],

  'itemTags': [
    [
      "crypto",
      "software",
      "stickers",
      "1st edition",
      "limited edition",
      "shirts",
      "backpacks"
    ]
  ],

  'itemListings': [
    {
      uuid: 7329140802,
      quantity: 1,
      itemType: enums.ItemType.DIGITAL,
      status: enums.ItemStatus.INACTIVE,
      condition: enums.ItemCondition.GOOD,
      title: "Test Item",
      description: "An item you should probably buy",
      price: 8000,
      delivery: [],
      tags: [],
      returnPolicy: 0
    },  
    {
      uuid: 7329140802,
      quantity: 10,
      itemType: enums.ItemType.DIGITAL,
      status: enums.ItemStatus.ACTIVE,
      condition: enums.ItemCondition.NEW,
      title: "Test IMPROVED Item",
      description: "An item you should ***DEFINITELY*** buy",
      price: 10000,
      delivery: [],
      tags: [],
      returnPolicy: 1
    }
  ],

  'returnPolicies': [
    { 
      returnsAccepted: true,
      timeLimit: 20000
    },
    { 
      returnsAccepted: false,
      timeLimit: 50
    }
  ],

  'availableCoupons': [
    { 
      couponType: enums.CouponType.AMOUNT_OFF,
      title: '50 HYDRO Test Discount!' ,
      description: 'A small little discount for you to cherish for a while during its highly transient existence',
      amountOff: 50,
      itemsApplicable: [], itemsApplicableExpected: undefined,
      expirationDate: 1571312124
    }, 
    { 
      couponType: enums.CouponType.PERCENTAGE_OFF,
      title: '20% OFF Test Discount!' ,
      description: 'A HUGE LITTLE discount for you to cherish for a while during its highly transient existence',
      amountOff: 20,
      itemsApplicable: [1,2,3], itemsApplicableExpected: [1,2,3],
      expirationDate: 1591312124
    }
  ]


};


module.exports = TestData;
