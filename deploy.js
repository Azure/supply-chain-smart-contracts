
const fs = require('fs');
var util = require('util');
const solc = require('solc');
const Web3 = require('web3');

var utils = require('./utils');
var callAsyncFunc = utils.callAsyncFunc;

const SUCCESS_EXIT_CODE = 0;
const MISSING_ARGUMENT_EXIT_CODE = 1;
const GENERAL_ERROR_EXIT_CODE = 2;

var deployContract = async (opts) => {
  try {

    var contractName = opts.contractName;
    var rpcEndpoint = opts.rpcEndpoint;
    var accountPassword = opts.accountPassword;

    console.log(`deploying contract on ${rpcEndpoint}`);
    const web3 = new Web3(new Web3.providers.HttpProvider(rpcEndpoint));

    // compile contract
    const input = fs.readFileSync(`contracts/${contractName}.sol`);
    const output = solc.compile(input.toString(), 1);
    var compiledContract = output.contracts[`:${contractName}`];
    const bytecode = '0x' + compiledContract.bytecode;
    const abi = JSON.parse(compiledContract.interface);
    const contract = web3.eth.contract(abi);

    // get coinbase address
    var getCoinbaseRequest = await callAsyncFunc(web3.eth, 'getCoinbase');
    var accountAddress = getCoinbaseRequest.result;

    // unlock the account
    var unlockRes = await callAsyncFunc(web3.personal, 'unlockAccount', accountAddress, accountPassword);
    if (!unlockRes.result) {
      throw new Error(`error unlocking account: ${accountAddress}`);
    }

    // deploy contract
    var deployResult = contract.new(accountAddress, { 
      from: accountAddress, 
      password: accountPassword,
      data: bytecode, 
      gas: 2000000 });

    var txHash = deployResult.transactionHash;
    
    // lock the account
    var lockRes = await callAsyncFunc(web3.personal, 'lockAccount', accountAddress, accountPassword);
    if (!lockRes) {
      throw new Error(`error locking account: ${opts.config.from}`);
    }
    
    // wait until the contract is mined
    var receipt;
    while (!receipt)
    {
        console.log(`waiting for contract to be mined...`);
        await utils.sleep(5);
        var receiptRequest = await callAsyncFunc(web3.eth, 'getTransactionReceipt', txHash);
        receipt = receiptRequest.result;
    }

    // get contract address
    var contractAddress = receipt.contractAddress;
    console.log(`contract deployed on address: ${contractAddress}`);

    // success exit and send result to output
    return exit(SUCCESS_EXIT_CODE, {
      accountAddress,
      contractAddress
    });

  }
  catch(err) {
    return exit(GENERAL_ERROR_EXIT_CODE, {
      error: `error deploying contract: ${err.message}`
    });
  }
}

function exit(exitCode, obj) {
  var logLevel = exitCode ? 'error' : 'info';
  console[logLevel](JSON.stringify(obj));
  process.nextTick(() => process.exit(exitCode));
}

var contractName = process.argv[2];
var rpcEndpoint = process.argv[3];
var accountPassword = process.argv[4];
if (!contractName || !rpcEndpoint || !accountPassword) {
  return exit(MISSING_ARGUMENT_EXIT_CODE, {
    error: `missing arguments, command line usage: node deploy.js <CONTRACT_NAME> <RPC_ENDPOINT> <COINBASE_PASSWORD>`
  });
}

deployContract({
  contractName,
  rpcEndpoint,
  accountPassword
});

