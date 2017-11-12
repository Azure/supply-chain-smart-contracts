
var ProofOfProduceQuality = artifacts.require("../contracts/ProofOfProduceQuality.sol");

contract('ProofOfProduceQuality', function(accounts) {
  it("stores proofs and retreives them", function() {

    var trackingId0 = "root";
    var trackingId1 = "trackingId1";
    var trackingId2 = "trackingId2";

    var proofValue1 = "publicProof1";
    var proofValue2 = "publicProof2";

    return ProofOfProduceQuality.deployed().then(function(instance) {
      return instance.storeProof(trackingId1,trackingId0,proofValue1,proofValue1).then(function(value){
        assert(value);

        instance.storeProof(trackingId2,trackingId1,proofValue2,proofValue2).then(function(value){
          assert(value);

          instance.getProof(trackingId2).then(function(proof2){
            console.log('proof2=' + JSON.stringify(proof2));
            assert.equal(proof2[1],proofValue2);
            assert.equal(proof2[3],trackingId1);
          });
        });
        
        instance.getProof(trackingId1).then(function(proof1){
          console.log('proof1=' + JSON.stringify(proof1));
          assert.equal(proof1[1],proofValue1);
          assert.equal(proof1[3],trackingId0);
        });
      }
    );
    });
  });
});
