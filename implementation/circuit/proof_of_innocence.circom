pragma circom 2.0.0;

include "merkle_tree_checker.circom";

template PathIndicesChecker(levels) {
    signal input leafIndex;
    signal input pathIndices[levels];

    var indexSubtotal;
    indexSubtotal = 0;
    for (var i = levels - 1; i >= 0; i--) {
        indexSubtotal = 2 * indexSubtotal + pathIndices[i];
    }
    leafIndex === indexSubtotal;
}

template ProofOfInnocence(levels) {
    signal input root;
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
    pathIndicesChecker.pathIndices <== pathIndices;
}

component main = ProofOfInnocence(2);
