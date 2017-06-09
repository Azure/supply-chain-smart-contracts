pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ProofOfProduceQuality.sol";

contract TestProofOfProduceQuality{

  function testStoringProof() {
    ProofOfProduceQuality proof = ProofOfProduceQuality(DeployedAddresses.ProofOfProduceQuality());
    var expectedEncrypted = new bytes(2);
    expectedEncrypted[0] = 0x12;
    expectedEncrypted[1] = 0x14;
    var expectedPublic = "testproof";

    proof.storeProof("test_id", expectedEncrypted, expectedPublic);
    proof.getEncryptedProof("test_id");
    proof.getPublicProof("test_id");
    proof.getProof("test_id");
    // Assert.equal(proof.getProof("test_id").publicProof, expectedPublic, "proof should be available");
  }
}
