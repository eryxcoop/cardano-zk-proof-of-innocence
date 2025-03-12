pragma circom 2.0.0;


// Computes DummyHash([left, right]) which is an arbitrary hash function for testing purposes
template DummyHashLeftRight() {
    signal input left;
    signal input right;
    signal output hash;

    hash <== 3 * left + 7 * right;
}
