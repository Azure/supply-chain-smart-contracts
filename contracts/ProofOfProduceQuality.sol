pragma solidity ^0.4.4;

contract ProofOfProduceQuality {
  struct ProofEntry {
    address owner;
    string encryptedProof;
    string publicProof;
    string previousTrackingId;
  }

  // map of trackingId to proofEntry
  mapping (string => ProofEntry) private proofs;

  // map of trackingId to addresses to check if a trackingId can be use as a previousTrackingId 
  mapping (string => mapping (address => bool )) private isTransfered;


  event StoreProofCompleted(
    address from,
    string trackingId,
    string previousTrackingId
  );

  event TransferCompleted(
    address from,
    address to,
    string trackingId
  );


  function ProofOfProduceQuality() {

  }

  // add a proof to an existing tracking - requires that
  // the previousOwner transfered the ownership 
  function storeProof(string trackingId, string previousTrackingId, string encryptedProof, string publicProof) returns(bool success) {
    
    // if we don't already have this trackingId
    if (hasProof(trackingId)) {
      // already exists- return
      return false;
    }

    // if previous tracking Id was provided
    if (sha3(previousTrackingId) != sha3("root")) {
      
      // if the caller is not the owner of the previousId and 
      // he didn't transfer it to the caller, return
      // this will terminate the tx if the previous tracking id doesn't exist
      ProofEntry memory pe = getProofInternal(previousTrackingId);
      if (msg.sender != pe.owner && !isTransfered[previousTrackingId][msg.sender]) {
        // no rights to use previousTrackingId. Owner need to transfer the trackingId first
        return false;
      }

    }

    proofs[trackingId] = ProofEntry(msg.sender, encryptedProof, publicProof, previousTrackingId);
    StoreProofCompleted(msg.sender, trackingId, previousTrackingId);
    return true;
  }

  function transfer(string trackingId, address newOwner) returns(bool success) {
    
    if (hasProof(trackingId)) {
      ProofEntry memory pe = getProofInternal(trackingId);
      if (msg.sender == pe.owner) {

        // TODO: ask Beat- why not just change the owner in the ProofEntry? why do we need the isTransfered mapping?
        // in this case, there might be multiple owners. Is this what we want?
        isTransfered[trackingId][newOwner] = true;
        TransferCompleted(msg.sender, newOwner, trackingId);
      }

      // TODO: ask Beat- why do we want to return true if the tx sender is not the owner? 
      // we didn't really transfer the ownership in this case...
      return true;
    }
        
    return false;
  }

  // returns true if proof is stored
  function hasProof(string trackingId) constant internal returns(bool exists) {
    return proofs[trackingId].owner != address(0);
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
