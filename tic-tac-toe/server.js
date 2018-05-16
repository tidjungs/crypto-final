const Web3 = require('web3');
const solc = require('solc');
const fs = require('fs');
const http = require('http');

const provider = new Web3.providers.HttpProvider("http://localhost:8545")
const web3 = new Web3(provider);
const asciiToHex = Web3.utils.asciiToHex;

// const opponent = '0x7EA7dcf57b8c88A07E04696E300CA3602aCb4d0a';
const turnLength = 10;
const p1Commitment = '0x5fe7f977e71dba2ea1a68e21057beebb9be2ac30c6410aa38d4f3fbe41dcffd2';

async function main () {
  const accounts = await web3.eth.getAccounts();
  console.log(accounts);
  const code = fs.readFileSync('../TicTacToe.sol').toString();
  const compiledCode = solc.compile(code);
  const errors = [];
  const warnings = [];
  (compiledCode.errors || []).forEach((err) => {
    if (/\:\s*Warning\:/.test(err)) {
      warnings.push(err);
    } else {
      errors.push(err);
    }
  });

  if (errors.length) {
    throw new Error('solc.compile: ' + errors.join('\n'));
  }
  if (warnings.length) {
    console.warn('solc.compile: ' + warnings.join('\n'));
  }

  const byteCode = compiledCode.contracts[':TicTacToe'].bytecode;
  const abiDefinition = JSON.parse(compiledCode.contracts[':TicTacToe'].interface);
  const TicTacToeContract = new web3.eth.Contract(abiDefinition, 
    {data: byteCode, from: accounts[0], gas: 4700000}
  );

  const deployedContract =  await TicTacToeContract.deploy({arguments: [accounts[1], turnLength, p1Commitment]}).send();
  const curentp = await deployedContract.methods.checkCurrentPlayer().call();
  console.log(curentp);
}

main();