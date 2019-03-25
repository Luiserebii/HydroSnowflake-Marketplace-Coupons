# Hydro Snowflake - Marketplace Coupons - Documentation

## Architecture

This project is essentially a chain of smart contracts built on top of the Hydro Snowflake protocol, aiming to provide a marketplace platform for sellers to launch their own stores and sell to users. Coupons are also featured, allowing users to use globally defined coupons guaranteed to expire within a certain time period, or assigning coupons per Snowflake EIN, manageable via multiple addresses.

The marketplace itself is ultimately a Snowflake Resolver contract, which interacts with a Snowflake Via contract to handle the transaction (and thus coupon discount) logic. 

As an attempt to outline the current/prospective architecture the project will try to shift to, see the image below:

<img src="https://serebii.io/hydro/img/Snowflake%20Coupon%20Marketplace%20-%20Hydro%20Bounty.png"/>


This project is still under development, and dramatic changes will likely occur quickly. The full scope of the prospective completed project [can be viewed here](https://github.com/HydroBlockchain/hcdp/issues/255)
