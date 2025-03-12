pragma circom 2.0.0;


// This component verifies that the path indexes 
// are the binary representation of the leaf index.
template PathIndicesChecker(levels) {
    signal input leafIndex;
    signal input pathIndexes[levels];

    var indexSubtotal;
    indexSubtotal = 0;
    for (var i = levels - 1; i >= 0; i--) {
        indexSubtotal = 2 * indexSubtotal + pathIndexes[i];
    }
    leafIndex === indexSubtotal;
}
