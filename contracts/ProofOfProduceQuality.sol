pragma solidity ^0.4.4;

contract ProofOfProduceQuality {
  struct ProofEntry {
    bool exists; 
    address owner;
    string encryptedProof;
    string publicProof;
    string previousTrackingId;
  }

  // map of trackingId to proofEntry
  mapping (string => ProofEntry) private proofs;

  // map of trackingId to addresses to check if a trackingId can be use as a previousTrackingId 
  mapping (string => mapping (address => bool )) private isTransfered;

  function ProofOfProduceQuality() {

  }

  // create a new tracking and store the inital proof
  function startTracking(string trackingId, string encryptedProof, string publicProof) returns(bool success) {
    
    // if we don't already have this trackingId- add it
    if (!hasProof(trackingId)) {
      proofs[trackingId] = ProofEntry(true, msg.sender, encryptedProof, publicProof, "root");
      return true;
    }
    
    // we already have this trackingId
    return false;
  }

  // add a proof to an existing tracking - requires that the previousOwner transfered the ownership 
  function storeProof(string trackingId, string previousTrackingId, string encryptedProof, string publicProof) returns(bool success) {
    
    // if we don't already have this trackingId
    if (!hasProof(trackingId)) {
      if (isTransfered[previousTrackingId][msg.sender] == false) {
        // no rights to use previousTrackingId. Owner need to transfer the trackingId first
        return false;
      }

      proofs[trackingId] = ProofEntry(true, msg.sender, encryptedProof, publicProof, previousTrackingId);
      return true;
    }

    return false;
  }

  function transfer(string trackingId, address newOwner) returns(bool success) {
    
    if (hasProof(trackingId)) {
      ProofEntry memory pe = getProofInternal(trackingId);
      if (msg.sender == pe.owner) {

        // TODO: ask Beat- why not just change the owner in the ProofEntry? why do we need the isTransfered mapping?
        // in this case, there might be multiple owners. Is this what we want?
        isTransfered[trackingId][newOwner] = true;
      }

      // TODO: ask Beat- why do we want to return true if the tx sender is not the owner? 
      // we didn't really transfer the ownership in this case...
      return true;
    }
        
    return false;
  }

  // returns true if proof is stored
  function hasProof(string trackingId) constant internal returns(bool exists) {
    return proofs[trackingId].exists;
  }


  // returns the proof
  function getProofInternal(string trackingId) constant internal returns(ProofEntry proof) {
    if (hasProof(trackingId)) {
      return proofs[trackingId];
    }

    // proof doesn't exist, throw and terminate transaction
    throw;
  }

  function getProof(string trackingId) constant returns(address owner, string encryptedProof, string publicProof, string previousTrackingId) {
    if (hasProof(trackingId)) {
      ProofEntry memory pe = getProofInternal(trackingId);
      owner = pe.owner;
      encryptedProof = pe.encryptedProof;
      publicProof = pe.publicProof;
      previousTrackingId = pe.previousTrackingId;
    }
  }

  // returns the encrypted part of the proof
  function getEncryptedProof(string trackingId) constant returns(string encryptedProof) {
    if (hasProof(trackingId)) {
      return getProofInternal(trackingId).encryptedProof;
    }
  }

  // returns the public part of the proof
  function getPublicProof(string trackingId) constant returns(string publicProof) {
    if (hasProof(trackingId)) {
      return getProofInternal(trackingId).publicProof;
    }
  }

  function getOwner(string trackingId) constant returns(address owner) {
    if (hasProof(trackingId)) {
      return getProofInternal(trackingId).owner;
    }
  }

  function getPreviousTrackingId(string trackingId) constant returns(string previousTrackingId) {
    if (hasProof(trackingId)) {
      return getProofInternal(trackingId).previousTrackingId;
    }
  }
}
