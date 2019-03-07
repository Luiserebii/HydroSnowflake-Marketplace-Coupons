const path = require('path');
const fs = require('fs');
const solc = require('solc');


const contracts = {

   'MyResolver.sol': [ 'contracts' ],
   'SnowflakeResolver.sol': [ 'contracts' ],

   'Ownable.sol': [ 'contracts', 'zeppelin', 'ownership' ],

   'HydroInterface.sol': [ 'contracts', 'interfaces' ],
   'SnowflakeInterface.sol': [ 'contracts', 'interfaces' ],
   'SnowflakeResolverInterface.sol': [ 'contracts', 'interfaces' ]

}

//Maybe move this to some sort of personal util file?
function generateContractSources(contractInput) {
   
   let sources = {};
   
   for(var name in contractInput){
      
      let pathArguments = contractInput[name];
      //These functions are unfortunately not-chainable
      pathArguments.push(name);
      pathArguments.splice(0, 0, __dirname);

      //Pass path.resolve params via array by apply()
      let contractPath = path.resolve.apply(null, pathArguments);
      console.log(contractPath);
      let contractSource = fs.readFileSync(contractPath, 'utf8');
      
      //Finally, add it to our sources object!
      sources[name] = contractSource;
      
   }
   return sources;

}


const input = {
   sources: generateContractSources(contracts)
};
console.log(generateContractSources(contracts));

compileOutput = solc.compile(input, 1);
console.log(compileOutput);

module.exports = compileOutput.contracts;
