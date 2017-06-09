pragma solidity ^0.4.4;

contract ProofOfProduceQuality {
   struct ProofEntry {
       bool exists;
       address owner;
       bytes encryptedProof;
       string publicProof;
       address previousOwner;
   }
  
  address private rootOwner;
   // map of an keyId and a proofEntry
  mapping (string => ProofEntry) private proofs;

  function ProofOfProduceQuality() {
    rootOwner = "0x0000000000000000000000000000000000000000";
  }
  
  // store a proof of quality in the contract state
  function storeProof(string keyId, bytes encryptedProof, string publicProof) returns(bool success) {
   // check if keyId already exists
   if (hasProof(keyId) == false) {
      proofs[keyId] = ProofEntry(
        { 
          exists : true, 
          owner : msg.sender,
          encryptedProof : encryptedProof,
          publicProof : publicProof,
          previousOwner : rootOwner
        });
      return true;
    }
    else {
      // a proof with this keyId already exists
      return false;
    }
  }
 
  function transfer(string keyId, address newOwner) {
    if (hasProof(keyId) == true) {
      ProofEntry memory pe = getProofInternal(keyId);
      if (msg.sender == pe.owner) {
        proofs[keyId].previousOwner = msg.sender;
      }
    }
    else {
      throw;
    }
  }
  // returns true if proof is stored
  function hasProof(string keyId) constant internal returns(bool exists) {
    return proofs[keyId].exists;
  }


  // returns the proof
  function getProofInternal(string keyId) constant internal returns(ProofEntry proof) {
    if (hasProof(keyId) == true) {
      return proofs[keyId];
    }
    else {
      throw;
    }
  }

  function getProof(string keyId) constant returns(address owner, bytes encryptedProof, string publicProof) {
    if (hasProof(keyId) == true) {
       ProofEntry memory pe = getProofInternal(keyId);
       owner = pe.owner;
       encryptedProof = pe.encryptedProof;
       publicProof = pe.publicProof;
    }
    else {
      throw;
    }
  }
  // returns the encrypted part of the proof
  function getEncryptedProof(string keyId) constant returns(bytes encryptedProof) {
    if (hasProof(keyId) == true) {
      return getProofInternal(keyId).encryptedProof;
    }
    else {
      throw;
    }
  }

      // returns the public part of the proof
  function getPublicProof(string keyId) constant returns(string publicProof) {
    if (hasProof(keyId) == true) {
      return getProofInternal(keyId).publicProof;
    }
    else {
      throw;
    }
  }

  function getOwner(string keyId) constant returns(address owner) {
    if (hasProof(keyId) == true) {
      return getProofInternal(keyId).owner;
    }
    else {
      throw;
    }
  }
}
