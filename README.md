# ibera-smart-contracts

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

### install test-rpc locally
install [testrpc](https://github.com/ethereumjs/testrpc) as your local geth-rpc or use the Docker image

### install geth locally 
follow these [instructions to install geth](https://github.com/ethereum/go-ethereum/wiki/Building-Ethereum)

### deploy geth as Ubuntu VM on Azure
simply deploy the follwoing arm template:
https://github.com/Azure/azure-quickstart-templates/tree/master/go-ethereum-on-ubuntu

Once the resource has been deployed, create a VPN to ensure the VM is isn't publicly accessible. Add a the geth-rpc port 8545 as an inbound security rule to the Nnewtwork security group (in addition to ssh). Also allow outbound traffic on all ports (or the geth peer network port only (which is ????)) to ensure that geth can connect to it's peers.

To create the VPN, it might be best to first deploy the [services](https://github.com/cloudbeatsch/ibera-services) and create the VPN including the gateway through the WebApp's Networking settings. This will allow to create a VPN which includes the vpn gateway.

## Test using testrpc

start test-rpc:
```
docker run -d -p 8545:8545 ethereumjs/testrpc:latest -a 10
```
or in attached mode to see the transactions:
```
docker run -p 8545:8545 ethereumjs/testrpc:latest -a 10
```

## Test in Testnet mode

run geth in Testnet mode:
```
geth --testnet --rpc console 2>> geth.log
```
You can validate that you run on the test network by checking the hash of the genesis bloc:
```
> eth.getBlock(0).hash
"0x41941023680923e0fe4d74a34bdac8141f2540e3ae90623718e47d66d1ca4a2d"
```
create a new account
```
> personal.newAccount()
"0x42cdcc58df1166c2700c52ca97679e390c5fc30c"
```

Get Ether to your newly created account using [Ethereum Ropsten Faucet](http://faucet.ropsten.be:3001/)
You can check your balance/account [here](https://ropsten.etherscan.io/)

```
> personal.unlockAccount(eth.accounts[0], "mypassword", 24*3600)
true
> eth.getBalance(eth.accounts[0])
1000000000000000000
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
Once we're finnished with syncing `eth.blockNumber` returns a teh number of the latest block. While syncing, it returns `0` 

## Deploy the contract to the network

Just compile and deploy the contracts

```
truffle compile
truffle migrate --reset
```
Once the block containing the contract has been added to the chain, we can test it:
```
truffle test
```