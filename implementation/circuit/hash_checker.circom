pragma circom 2.0.0;


template HashChecker() {
    signal input preImage;
    signal input hashedValue;

    // Hash with a dummy function
    hashedValue === preImage * 2 + 5;
}
