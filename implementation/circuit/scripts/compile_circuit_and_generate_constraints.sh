#!/bin/bash

echo "[Circuit compilation](1/4): Compile the circuit"
circom $CIRCUIT_FILE --r1cs --wasm --sym -p bls12381 -o ${OUTPUT_PATH}

echo "[Circuit compilation](2/4): View information about the circuit"
snarkjs r1cs info ${OUTPUT_PATH}${CIRCUIT_NAME}.r1cs

echo "[Circuit compilation](3/4): Print the constraints"
snarkjs r1cs print ${OUTPUT_PATH}${CIRCUIT_NAME}.r1cs ${OUTPUT_PATH}${CIRCUIT_NAME}.sym

echo "[Circuit compilation](4/4): Export r1cs to json"
snarkjs r1cs export json ${OUTPUT_PATH}${CIRCUIT_NAME}.r1cs ${OUTPUT_PATH}${CIRCUIT_NAME}.r1cs.json
