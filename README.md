# ibera-smart-contracts

## Dependencies

### truffle
install [truffle](https://github.com/trufflesuite/truffle)

On Windows: before you install truffle ensure you install windows-build-tools
```
npm install --global --production windows-build-tools
npm install -g truffle
```

### test-rpc
install [testrpc](https://github.com/ethereumjs/testrpc) as your local geth-rpc or use the Docker image

## build and test

start test-rpc:
```
docker run -d -p 8545:8545 ethereumjs/testrpc:latest -a 10
```
or in attached mode to see the transactions:
```
docker run -p 8545:8545 ethereumjs/testrpc:latest -a 10
```

Then just compile, deploy and test the contracts
```
truffle compile
truffle migrate --reset
truffle test
```