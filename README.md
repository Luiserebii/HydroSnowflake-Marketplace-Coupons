# Hydro Snowflake - Marketplace Coupons
![GitHub package.json version](https://img.shields.io/github/package-json/v/Luiserebii/HydroSnowflake-Marketplace-Coupons?color=g)
[![Build Status](https://travis-ci.org/Luiserebii/HydroSnowflake-Marketplace-Coupons.svg?branch=master)](https://travis-ci.org/Luiserebii/HydroSnowflake-Marketplace-Coupons)
[![Coverage Status](https://coveralls.io/repos/github/Luiserebii/HydroSnowflake-Marketplace-Coupons/badge.svg?branch=master)](https://coveralls.io/github/Luiserebii/HydroSnowflake-Marketplace-Coupons?branch=master)
[![Language grade: JavaScript](https://img.shields.io/lgtm/grade/javascript/g/Luiserebii/HydroSnowflake-Marketplace-Coupons.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/Luiserebii/HydroSnowflake-Marketplace-Coupons/context:javascript)
[![Total alerts](https://img.shields.io/lgtm/alerts/g/Luiserebii/HydroSnowflake-Marketplace-Coupons.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/Luiserebii/HydroSnowflake-Marketplace-Coupons/alerts/)
[![Known Vulnerabilities](https://snyk.io/test/github/Luiserebii/HydroSnowflake-Marketplace-Coupons/badge.svg)](https://snyk.io/test/github/Luiserebii/HydroSnowflake-Marketplace-Coupons)

## Introduction
Snowflake is an [ERC-1484 `Provider`](https://erc1484.org/) that provides on-/off-chain identity management. For more details, see [the whitepaper](https://github.com/hydrogen-dev/hydro-docs/tree/master/Snowflake).

This project is essentially a chain of smart contracts built on top of the Hydro Snowflake protocol, aiming to provide a marketplace platform for sellers to launch their own stores and sell to users. Coupons are also featured, allowing users to use globally defined coupons guaranteed to expire within a certain time period, or assigning coupons per Snowflake EIN, manageable via multiple addresses.

The marketplace itself is a Snowflake Resolver contract, which interacts with a Snowflake Via contract to handle the transaction (and thus coupon discount) logic. 

This project is still under development, and dramatic changes will likely occur quickly. The full scope of the prospective completed project [can be viewed here](https://github.com/HydroBlockchain/hcdp/issues/255)

##
[Try the Snowflake Dashboard demo front-end (requires Metamask)](https://hydroblockchain.github.io/snowflake-dashboard/)!

## Testing With Truffle
- This folder has a suite of tests created through [Truffle](https://github.com/trufflesuite/truffle).
- To run these tests:
  - Clone this repo: `git clone https://github.com/Luiserebii/HydroSnowflake-Marketplace-Coupons`
  - Run `npm install`
  - Build dependencies with `npm run build`
  - Spin up a development blockchain: `npm run chain`
  - In another terminal tab, run the test suite: `npm test`

## Mirror
A mirror of this repository is available at: https://serebii.io:2501/Luiserebii/HydroSnowflake-Marketplace-Coupons

## Copyright & License
© The Hydrogen Technology Corporation 2018, under the GNU General Public License v3.0.
