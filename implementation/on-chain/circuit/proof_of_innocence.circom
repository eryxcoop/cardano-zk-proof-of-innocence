pragma circom 2.0.0;

include "merkle_tree_checker.circom";

template ProofOfInnocence (levels) {
    signal input root;
    signal input pathElements[levels];
    signal input pathIndices[levels];

    component merkle_tree_checker = MerkleTreeChecker(levels);
    merkle_tree_checker.leaf <== 0;
    merkle_tree_checker.root <== root;
    for(var i=0; i<levels; i++) {
        merkle_tree_checker.pathElements[i] <== pathElements[i];
        merkle_tree_checker.pathIndices[i] <== pathIndices[i];
    }
}

component main = ProofOfInnocence(2);
