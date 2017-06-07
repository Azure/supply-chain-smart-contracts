var ProofOfProduceQuality = artifacts.require("./ProofOfProduceQuality.sol");

contract('ProofOfProduceQuality', function(accounts) {
  it("creates new proof", function() {
    return ProofOfProduceQuality.deployed().then(function(instance) {
      return instance.storeProof("keyId", "pre-chain", [0x12, 0x34], "test").then(function(ok){
        if (ok) {
          return instance.getPublicProof.call("keyId").then(function(value) {
            assert.equal(value.valueOf(), "test", "public Proof");
          });
        }
      });
    });
  });
});
