pragma solidity ^0.4.4;

contract ProofOfProduceQuality {

   struct ProofEntry {
       bool exists;
       // address[] chain;
       string chain;
       bytes encryptedProof;
       string publicProof;
   }

   // map of an keyId and a proofEntry
  mapping (string => ProofEntry) private proofs;

  function ProofOfProduceQuality() {
  }

  // store a proof of quality in the contract state
  function storeProof(string keyId, string chain, bytes encryptedProof, string publicProof) returns(bool success) {
   // check if keyId already exists
   if (hasProof(keyId) == false) {
      proofs[keyId] = ProofEntry(
        { 
          exists : true, 
          chain : chain,
          encryptedProof : encryptedProof,
          publicProof : publicProof
        });
      return true;
    }
    else {
      // a proof with this keyId already exists
      return false;
    }
  }

  // returns true if proof is stored
  function hasProof(string keyId) constant internal returns(bool exists) {
    return proofs[keyId].exists;
  }


  // returns the proof
  function getProof(string keyId) constant internal returns(ProofEntry proof) {
    if (hasProof(keyId) == true) {
      return proofs[keyId];
    }
    else {
      return;
    }
  }

  // returns the encrypted part of the proof
  function getEncryptedProof(string keyId) constant returns(bytes encryptedProof) {
    if (hasProof(keyId) == true) {
      return getProof(keyId).encryptedProof;
    }
    else {
      return;
    }
  }

      // returns the public part of the proof
  function getPublicProof(string keyId) constant returns(string publicProof) {
    if (hasProof(keyId) == true) {
      return getProof(keyId).publicProof;
    }
    else {
      return "undefined";
    }
  }

  function getChain(string keyId) constant returns(string chain) {
    if (hasProof(keyId) == true) {
      return getProof(keyId).chain;
    }
    else {
      return "undefined";
    }
  }
}
