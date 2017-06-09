pragma solidity ^0.4.4;

contract ProofOfProduceQuality {
    struct ProofEntry {
        bool exists;
        address owner;
        bytes encryptedProof;
        string publicProof;
        string previousTrackingId;
    }
  
    // map of an trackingId and a proofEntry
    mapping (string => ProofEntry) private proofs;
    // map of trackingId to addresses to check if an trackingId can be use as a previousTrackingId 
    mapping (string => mapping (address => bool )) private isTransfered;

    function ProofOfProduceQuality() {

    }
  
    // create a new tracking and store the inital proof
    function startTracking(string trackingId, bytes encryptedProof, string publicProof) returns(bool success) {
     // check if trackingId already exists
        if (hasProof(trackingId) == false) {
            proofs[trackingId] = ProofEntry(true, msg.sender, encryptedProof, publicProof, "root");
            return true;
        }
        else {
            return false;
        }
    }

    // add aproof to an existing tracking - requires that the previousOwner transfered the ownership 
    function storeProof(string trackingId, string previousTrackingId, bytes encryptedProof, string publicProof) returns(bool success) {
    // check if trackingId already exists
        if (hasProof(trackingId) == false) {
            if (isTransfered[previousTrackingId][msg.sender] == false) {
                // no rights to use previousTrackingId. Owner need to transfer the trackingId first
                return false;
            }
            proofs[trackingId] = ProofEntry(true, msg.sender, encryptedProof, publicProof, previousTrackingId);
            return true;
        }
        else {
            return false;
        }
    }
 
    function transfer(string trackingId, address newOwner) returns(bool success) {
        if (hasProof(trackingId) == true) {
            ProofEntry memory pe = getProofInternal(trackingId);
            if (msg.sender == pe.owner) {
                isTransfered[trackingId][newOwner] = true;
            }
            return true;
        }
        else {
            return false;
        }
    }

    // returns true if proof is stored
    function hasProof(string trackingId) constant internal returns(bool exists) {
            return proofs[trackingId].exists;
    }


    // returns the proof
    function getProofInternal(string trackingId) constant internal returns(ProofEntry proof) {
        if (hasProof(trackingId) == true) {
            return proofs[trackingId];
        }
        else {
            throw;
        }
    }

    function getProof(string trackingId) constant returns(address owner, bytes encryptedProof, string publicProof, string previousTrackingId) {
        if (hasProof(trackingId) == true) {
            ProofEntry memory pe = getProofInternal(trackingId);
            owner = pe.owner;
            encryptedProof = pe.encryptedProof;
            publicProof = pe.publicProof;
            previousTrackingId = pe.previousTrackingId;
        }
        else {
            throw;
        }
    }

    // returns the encrypted part of the proof
    function getEncryptedProof(string trackingId) constant returns(bytes encryptedProof) {
        if (hasProof(trackingId) == true) {
            return getProofInternal(trackingId).encryptedProof;
        }
        else {
            throw;
        }
    }

    // returns the public part of the proof
    function getPublicProof(string trackingId) constant returns(string publicProof) {
        if (hasProof(trackingId) == true) {
            return getProofInternal(trackingId).publicProof;
        }
        else {
            throw;
        }
    }

    function getOwner(string trackingId) constant returns(address owner) {
        if (hasProof(trackingId) == true) {
            return getProofInternal(trackingId).owner;
        }
        else {
            throw;
        }
    }

    function getPreviousTrackingId(string trackingId) constant returns(string previousTrackingId) {
        if (hasProof(trackingId) == true) {
            return getProofInternal(trackingId).previousTrackingId;
        }
        else {
            throw;
        }
    }
}
