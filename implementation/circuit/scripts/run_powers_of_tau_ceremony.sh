#!/bin/bash

echo "[Trusted setup](1/7): Start a new powers of tau ceremony"
snarkjs powersoftau new bls12-381 15 ${PTAU_FILE_PREFIX}0000.ptau -v

echo "[Trusted setup](2/7): Contribute to the ceremony"
snarkjs powersoftau contribute ${PTAU_FILE_PREFIX}0000.ptau ${PTAU_FILE_PREFIX}0001.ptau --name="First contribution" -v

echo "[Trusted setup](3/7): Provide a second contribution"
snarkjs powersoftau contribute ${PTAU_FILE_PREFIX}0001.ptau ${PTAU_FILE_PREFIX}0002.ptau --name="Second contribution" -v

echo "[Trusted setup](4/7): Verify the protocol so far"
snarkjs powersoftau verify ${PTAU_FILE_PREFIX}0002.ptau

echo "[Trusted setup](5/7): Apply a random beacon"
snarkjs powersoftau beacon ${PTAU_FILE_PREFIX}0002.ptau ${PTAU_FILE_PREFIX}beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon"

echo "[Trusted setup](6/7): Prepare phase 2"
snarkjs powersoftau prepare phase2 ${PTAU_FILE_PREFIX}beacon.ptau ${PTAU_FILE_PREFIX}final.ptau -v

echo "[Trusted setup](7/7): Verify the final ptau"
snarkjs powersoftau verify ${FINAL_PTAU_FILE}
