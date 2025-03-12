pragma circom 2.0.0;

template Double () {
 signal input a;
 signal input b;

 b === 2 * a;
}

component main = Double();
