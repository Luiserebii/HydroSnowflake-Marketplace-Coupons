const path = require('path');
const fs = require('fs');
const solc = require('solc');


const contracts = {

   "MyResolver.sol": [ "contracts" ],
   "SnowflakeResolver.sol": [ "contracts" ],

   "Ownable.sol": [ "contracts", "zeppelin", "ownership" ],

   "HydroInterface.sol": [ "contracts", "interfaces" ],
   "SnowflakeInterface.sol": [ "contracts", "interfaces" ],
   "SnowflakeResolverInterface.sol": [ "contracts", "interfaces" ]

}

//Maybe move this to some sort of personal util file?
function generateContractSources(contractInput) {
   
   let sources = {};
   for(let name in contractInput){
      
      let pathArguments = contractInput[name];
      //These functions are unfortunately not-chainable
      pathArguments.push(name);
      pathArguments.splice(0, 0, __dirname);

      //Pass path.resolve params via array by apply()
      let contractPath = path.resolve.apply(null, pathArguments);
      let contractSource = fs.readFileSync(contractPath, 'utf8');
      
      //Finally, add it to our sources object
       
      sources[name] = { content: contractSource };
      //sources[name] = {  };

   }
   return sources;

}


let sourcesInput = generateContractSources(contracts);

const input = {
   language: "Solidity",
   sources: sourcesInput
};

//console.log(JSON.stringify(input));

compileOutput = solc.compile(JSON.stringify(input));
console.log(compileOutput);

module.exports = compileOutput.contracts;
