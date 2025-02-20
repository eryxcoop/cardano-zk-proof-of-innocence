#!/bin/bash

echo "[Groth16 setup](14/22): Setup"
snarkjs groth16 setup ${COMPILED_CIRCUIT_CONSTRAINTS_FILE} ${FINAL_PTAU_FILE} ${CIRCUIT_OUTPUT_FILES_PREFIX}_0000.zkey

echo "[Groth16 setup](15/22): Contribute to the phase 2 ceremony"
snarkjs zkey contribute ${CIRCUIT_OUTPUT_FILES_PREFIX}_0000.zkey ${CIRCUIT_OUTPUT_FILES_PREFIX}_0001.zkey --name="1st Contributor Name" -v

echo "[Groth16 setup](16/22): Provide a second contribution"
snarkjs zkey contribute ${CIRCUIT_OUTPUT_FILES_PREFIX}_0001.zkey ${CIRCUIT_OUTPUT_FILES_PREFIX}_0002.zkey --name="Second contribution Name" -v

echo "[Groth16 setup](17/22): Verify the latest zkey"
snarkjs zkey verify ${COMPILED_CIRCUIT_CONSTRAINTS_FILE} ${FINAL_PTAU_FILE} ${CIRCUIT_OUTPUT_FILES_PREFIX}_0002.zkey

echo "[Groth16 setup](18/22): Apply a random beacon"
snarkjs zkey beacon ${CIRCUIT_OUTPUT_FILES_PREFIX}_0002.zkey ${FINAL_ZKEY_FILE} 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon phase2"

echo "[Groth16 setup](19/22): Verify the final zkey"
snarkjs zkey verify ${COMPILED_CIRCUIT_CONSTRAINTS_FILE} ${FINAL_PTAU_FILE} ${FINAL_ZKEY_FILE}

echo "[Groth16 setup](20/22): Export the verification key"
snarkjs zkey export verificationkey ${FINAL_ZKEY_FILE} ${VERIFICATION_KEY_FILE}
