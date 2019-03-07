const path = require('path');
const fs = require('fs');
const solc = require('solc');


const contracts = {

   'MyResolver.sol': 'contracts',
   'SnowflakeResolver.sol': 'contracts',

   'Ownable.sol': [ 'contracts', 'zeppelin', 'ownership' ],

   'HydroInterface.sol': [ 'contracts', 'interfaces' ],
   'SnowflakeInterface.sol': [ 'contracts', 'interfaces' ],
   'SnowflakeResolverInterface.sol': [ 'contracts', 'interfaces' ]

}



const calcPath = path.resolve(__dirname, 'contracts', 'Calculator.sol');


const input = {

   sources: {
      'Calculator.sol': fs.readFileSync(calcPath, 'utf8')
   }

};


compileOutput = solc.compile(input, 1);
//console.log(compileOutput) 

module.exports = compileOutput.contracts;
