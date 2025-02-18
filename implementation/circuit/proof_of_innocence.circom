template proof_of_innocence () {
 signal input a;
 signal output b;

 b <== 2 * a;
}

component main {public [a]} = proof_of_innocence();