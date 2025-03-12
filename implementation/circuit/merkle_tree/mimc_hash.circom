pragma circom 2.0.0;


include "../../node_modules/circomlib/circuits/mimcsponge.circom";


// Computes MiMC([left, right])
template MiMCHashLeftRight() {
    signal input left;
    signal input right;
    signal output hash;

    component hasher = MiMCSponge(2, 220, 1);
    hasher.ins[0] <== left;
    hasher.ins[1] <== right;
    hasher.k <== 0;
    hash <== hasher.outs[0];
}
