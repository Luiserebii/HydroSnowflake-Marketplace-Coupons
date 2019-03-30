/*
 *
 * Test Data - simply meant to contain testing inputs for convenience
 * 
 *
 */
const common = require('../common.js')

const allEnums = require('../../enum_mappings/enums.js')
const enums = allEnums.CouponMarketPlaceResolverInterface;


const TestData = {

  'itemTags': [
    [
      "TestTagA",
      "TestTagB",
      "TestTagC",
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
