var ProofOfProduceQuality = artifacts.require("./ProofOfProduceQuality.sol");

contract('ProofOfProduceQuality', function(accounts) {
  it("creates new proof", function() {
    var proofValue1 = "publicProof1";
    var proofValue2 = "publicProof2";
    return ProofOfProduceQuality.deployed().then(function(instance) {
      return instance.startTracking("t1", "0x1234", proofValue1).then(function(value){
      if (value.valueOf()) {
          instance.getPublicProof.call("t1").then(function(value) {
            assert.equal(value.valueOf(), proofValue1, "public Proof 1");
            instance.getPreviousTrackingId.call("t1").then(function(value) {
              assert.equal(value.valueOf(), "root", "Previous Tracking Id -root");
            });
            instance.transfer("t1", accounts[0]).then(function(value){
              instance.storeProof("t2", "t1", "0x1234", proofValue2).then(function(value){
                instance.getPublicProof.call("t2").then(function(value) {
                  assert.equal(value.valueOf(), proofValue2, "public Proof 2");
                });
                instance.getPreviousTrackingId.call("t2").then(function(value) {
                  assert.equal(value.valueOf(), "t1", "Previous Tracking Id - t1");
                });
              });
            });
            instance.startTracking("t1", "0x1234", proofValue2).then(function(value){
              instance.getPublicProof.call("t1").then(function(value) {
                assert.equal(value.valueOf(), proofValue1, "additional startTracking is not changing the proof");
              });
            });
          });
       }
      });
    });
  });
});
