#!/bin/bash

echo "[Circuit compilation](1/4): Compile the circuit"
circom $CIRCUIT_FILE --r1cs --wasm --sym -p bls12381 -o ${OUTPUT_PATH}

echo "[Circuit compilation](2/4): View information about the circuit"
snarkjs r1cs info ${COMPILED_CIRCUIT_CONSTRAINTS_FILE}

echo "[Circuit compilation](3/4): Print the constraints"
snarkjs r1cs print ${COMPILED_CIRCUIT_CONSTRAINTS_FILE} ${CIRCUIT_OUTPUT_FILES_PREFIX}.sym

echo "[Circuit compilation](4/4): Export r1cs to json"
snarkjs r1cs export json ${COMPILED_CIRCUIT_CONSTRAINTS_FILE} ${COMPILED_CIRCUIT_CONSTRAINTS_FILE}.json
