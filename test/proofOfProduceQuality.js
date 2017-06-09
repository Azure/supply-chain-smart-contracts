var ProofOfProduceQuality = artifacts.require("./ProofOfProduceQuality.sol");

contract('ProofOfProduceQuality', function(accounts) {
  it("creates new proof", function() {
    var proofValue = "publicProof"
    return ProofOfProduceQuality.deployed().then(function(instance) {
      return instance.storeProof("keyId", [0x12, 0x34], proofValue).then(function(ok){
        if (ok) {
          instance.getPublicProof.call("keyId").then(function(value) {
            assert.equal(value.valueOf(), proofValue, "public Proof");
            instance.getProof.call("keyId").then(function(value) {
              assert.equal(value.valueOf()[2], proofValue, "public Proof retrieved through getProof");
            });
          });
        }
      });
    });
  });
});
