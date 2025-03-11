pragma circom 2.0.0;

template ProofOfInnocence () {
 signal input a;
 signal input b;

 b === 2 * a;
}

component main = ProofOfInnocence();
