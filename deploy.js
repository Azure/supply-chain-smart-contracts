
const fs = require('fs');
var util = require('util');
const solc = require('solc');
const Web3 = require('web3');


const web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8545"));

// generic function to wrap async functions with a Promise to use with the async/await pattern
async function callAsyncFunc(obj, func) {
   return new Promise((resolve, reject) => {
    
    // callback for the function invoked
    var cb = (err, result) => {
      if (err) {
        console.error(`error executing function '${func}' with params: ${util.inspect(arguments)}: ${err.message}`);
        return reject(err);
      }
      
      console.log(`function '${func}' completed successfully with result: ${util.inspect(result)}`);
      return resolve({ result });
    };

    var params = Array.prototype.slice.call(arguments, 2);
    params.push(cb);

    return obj[func].apply(obj, params);
  });
}

async function sleep(timeSecs) {
  return new Promise(resolve => setTimeout(() => resolve(), timeSecs * 1000));
}

var deployContract = async () => {

  console.log(`deploying contract`);

  try {
   
    const contractName = 'ProofOfProduceQuality';
    const input = fs.readFileSync(`contracts/${contractName}.sol`);
    const output = solc.compile(input.toString(), 1);
    var compiledContract = output.contracts[`:${contractName}`];
    const bytecode = compiledContract.bytecode;
    const abi = JSON.parse(compiledContract.interface);

    var getCoinbaseRequest = await callAsyncFunc(web3.eth, 'getCoinbase');
    var coinbase = getCoinbaseRequest.result;

    const contract = new web3.eth.Contract(abi);

    var deployResult = contract.deploy({
      data: '0x' + bytecode,
      from: coinbase,
      gas: 90000*2
    });

    var estimateGasRequest = await callAsyncFunc(deployResult, 'estimateGas');
    var estimateGas = estimateGasRequest.result;

    var unlockRes = await callAsyncFunc(web3.eth.personal, 'unlockAccount', coinbase, 'Pa$$word1');
    if (!unlockRes.result) {
      throw new Error(`error unlocking account: ${coinbase}`);
    }

    var sendRequest = await callAsyncFunc(deployResult, 'send', {
      from: coinbase,
      gas: estimateGas
    });
    var txHash = sendRequest.result;
    
    var lockRes = await callAsyncFunc(web3.eth.personal, 'lockAccount', coinbase, 'Pa$$word1');
    if (!lockRes) {
      throw new Error(`error locking account: ${opts.config.from}`);
    }
    
    var receipt;
    while (!receipt)
    {
        await sleep(5);
        var receiptRequest = await callAsyncFunc(web3.eth, 'getTransactionReceipt', txHash);
        receipt = receiptRequest.result;
    }

    var contractAddress = receipt.contractAddress;
    console.log(`contract deployed on address: ${contractAddress}`);

  }
  catch(err) {
    console.error(`error deploying contract: ${err.message}`);
  }

}


process.nextTick(async () => {

  await deployContract();

});




/*
  .then(result => {
    console.log(`result: ${util.inspect(result)}`);
  })
  .catch(err => console.error(`error deploying contract: ${err.message}`));


  /*
, {
    data: '0x' + bytecode,
    from: web3.eth.coinbase,
    gas: 90000*2
  }, 
  (err, res) => {
    if (err) return console.log(err);

    // Log the tx, you can explore status with eth.getTransaction()
    console.log(res.transactionHash);

    // If we have an address property, the contract was deployed
    if (res.address) {
      console.log('Contract address: ' + res.address);
      // Let's test the deployed contract
      //testContract(res.address);
    }
});

*/

/*

    var senderAddress = "0x12890d2cce102216644c59daE5baed380d84830c";
    var password = "password";
    var abi = @"[{""constant"":false,""inputs"":[{""name"":""val"",""type"":""int256""}],""name"":""multiply"",""outputs"":[{""name"":""d"",""type"":""int256""}],""type"":""function""},{""inputs"":[{""name"":""multiplier"",""type"":""int256""}],""type"":""constructor""}]";
    var byteCode =
        "0x60606040526040516020806052833950608060405251600081905550602b8060276000396000f3606060405260e060020a60003504631df4f1448114601a575b005b600054600435026060908152602090f3";

    var multiplier = 7;

    var web3 = new Web3.Web3();
    var unlockAccountResult =
        await web3.Personal.UnlockAccount.SendRequestAsync(senderAddress, password, 120);
    Assert.True(unlockAccountResult);

    var transactionHash =
        await web3.Eth.DeployContract.SendRequestAsync(abi, byteCode, senderAddress, multiplier);

    var mineResult = await web3.Miner.Start.SendRequestAsync(6);

    Assert.True(mineResult);

    var receipt = await web3.Eth.Transactions.GetTransactionReceipt.SendRequestAsync(transactionHash);

    while (receipt == null)
    {
        Thread.Sleep(5000);
        receipt = await web3.Eth.Transactions.GetTransactionReceipt.SendRequestAsync(transactionHash);
    }

    mineResult = await web3.Miner.Stop.SendRequestAsync();
    Assert.True(mineResult);

    var contractAddress = receipt.ContractAddress;

    var contract = web3.Eth.GetContract(abi, contractAddress);

    var multiplyFunction = contract.GetFunction("multiply");

  //  var result = await multiplyFunction.CallAsync<int>(7);

    Assert.Equal(49, result);

    */