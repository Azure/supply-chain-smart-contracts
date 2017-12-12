# supply-chain-smart-contracts

### install test-rpc locally
install [testrpc](https://github.com/ethereumjs/testrpc) as your local geth-rpc or use the Docker image - if you run into problems building the image on Windows, simply build it in the Ubuntu subsystem on Windows. Here a [description](https://blog.jayway.com/2017/04/19/running-docker-on-bash-on-windows/) how to use the windows docker daemon from within the Linux subsystem. 

### install geth locally 
follow these [instructions to install geth](https://github.com/ethereum/go-ethereum/wiki/Building-Ethereum)

### deploy geth as Ubuntu VM on Azure
simply deploy the follwoing arm template:
https://github.com/Azure/azure-quickstart-templates/tree/master/go-ethereum-on-ubuntu

Once the resource has been deployed, create a VPN to ensure the VM is isn't publicly accessible. Add a the geth-rpc port 8545 as an inbound security rule to the Nnewtwork security group (in addition to ssh). Also allow outbound traffic on all ports (or the geth peer network port only (which is ????)) to ensure that geth can connect to it's peers.

To create the VPN, it might be best to first deploy the [services](https://github.com/cloudbeatsch/supply-chain-services) and create the VPN including the gateway through the WebApp's Networking settings. This will allow to create a VPN which includes the vpn gateway.

## Dependencies

### truffle
install [truffle](https://github.com/trufflesuite/truffle)

```
sudo apt-get update && sudo apt-get -y upgrade
sudo apt-get -y install curl git vim build-essential

curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -global express

sudo npm install -global truffle
```

On Windows: before you install truffle ensure you install windows-build-tools
```
npm install -global --production windows-build-tools
npm install -global truffle
```

## Test using testrpc

start test-rpc:
```
docker run -d -p 8545:8545 ethereumjs/testrpc:latest -a 10 -u0 -u1
```
or in attached mode to see the transactions:
```
docker run -p 8545:8545 ethereumjs/testrpc:latest -a 10 -u0 -u1
```

## Test in Testnet mode
Ensure that the VM is accessible from a private network only. To ssh into it, a jumperBox vm can be used (a vm that acts which provides public ssh but is part of the VPN).

Setup your Rinkeby Testnet by following this [article](https://gist.github.com/cryptogoth/10a98e8078cfd69f7ca892ddbdcf26bc)
NOte: ensure that you start geth by enabling `rpc` and `web3`: 

```
geth ... --rpc --rpcport=8545 --rpcaddr=0.0.0.0 --rpcapi="personal,admin,eth,net,web3"
```

you can check the accessability of your `geth rpc` endpoint within your private network using the following `curl` command:
```
curl -X POST --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}' http://10.0.0.4:8545
```

Before we can deploy the contract, geth needs to be fully synched with he the blockchain. We can check the progress through the console: 

```
> eth.syncing
{
  currentBlock: 484548,
  highestBlock: 1140339,
  knownStates: 338331,
  pulledStates: 148121,
  startingBlock: 440322
}
```
Once we're finished with syncing `eth.blockNumber` returns a the number of the latest block. While syncing, it returns `0` 

unlock your account:
```
personal.unlockAccount(web3.eth.coinbase, "password", 15000)
```
in your `truffle.js` add a property for your network:

```
  networks: {
    testnet: {
      host: "10.0.0.4",
      port: 8545,
      network_id: "4" 
    }
  }
```

deploy the contract from your jumperBox:

```
truffle migrate --reset --network testnet
```

## Deploy the contract to the network

Set the hostname in `truffle.js" to your deployed geth rpc instance - e.g. 10.0.0.4

Just compile and deploy the contracts

```
truffle compile
truffle migrate --reset
```
Once the block containing the contract has been added to the chain, we can test it:
```
truffle test
```

## Use the deploy.js script
Make sure you have Node.js version 7.6.0 and above.
Run the following command to deploy the script to any RPC endpoint:

```
node deploy.js <CONTRACT_NAME> <RPC_ENDPOINT> <COINBASE_PASSWORD>
```

Example:

```
node deploy ProofOfProduceQuality http://40.68.224.232:8545 MyPassword
```

In case of an error, the process will be terminated with an error exit code and the last output line will be a json containing an `error` member with the details of the error:

```json
{"error":"the error details"}
```

In case of a successful execution, the process will be terminated with a success exit code (0) and the last output line will be a json containing the account address (the coinbase) and the deployed contract instance address:

```json
{"accountAddress":"0x6290feb5d6155bb8ca4551bae08564afb636a974","contractAddress":"0x44D89F52f93D1bF9A0F47330B5726B0d82cD8176"}
```

