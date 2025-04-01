pragma circom 2.0.0;


include "merkle_tree/merkle_tree_checker.circom";
include "path_indices_checker.circom";
include "hash_checker.circom";


template ProofOfInnocence(levels) {
    // Public inputs
    signal input root;
    signal input leafIndexHash;

    // Private inputs
    signal input pathElements[levels];
    signal input pathIndices[levels];
    signal input leafIndex;

    component merkle_tree_checker = MerkleTreeChecker(levels);
    merkle_tree_checker.leaf <== 0;
    merkle_tree_checker.root <== root;
    for(var i=0; i<levels; i++) {
        merkle_tree_checker.pathElements[i] <== pathElements[i];
        merkle_tree_checker.pathIndices[i] <== pathIndices[i];
    }
    
    component pathIndicesChecker = PathIndicesChecker(levels);
    pathIndicesChecker.leafIndex <== leafIndex;
    pathIndicesChecker.pathIndexes <== pathIndices;

    component leafHashChecker = HashChecker();
    leafHashChecker.preImage <== leafIndex;
    leafHashChecker.hashedValue <== leafIndexHash;
}

component main = ProofOfInnocence(2);
