/*

General file to define enums within contracts; utility for working with values passed/returned by web3 that utilize enums. There could be a way to automate this, should this be one solution to go with; there are likely better ones, but I will utilize this for the moment.

*/

const cmprI = {};

cmprI.ItemType = { DIGITAL: 0, PHYSICAL: 1 }
cmprI.ItemStatus = { ACTIVE: 0, INACTIVE: 1 }
cmprI.ItemCondition = { NEW: 0, LIKE_NEW: 1, VERY_GOOD: 2, GOOD: 3, ACCEPTABLE: 4 }
cmprI.CouponType = { AMOUNT_OFF: 0, PERCENTAGE_OFF: 1, BUY_X_QTY_GET_Y_FREE: 2, BUY_X_QTY_FOR_Y_AMNT: 3 }


const enums = {

  CouponMarketPlaceResolverInterface: cmprI

}

module.exports = enums;
