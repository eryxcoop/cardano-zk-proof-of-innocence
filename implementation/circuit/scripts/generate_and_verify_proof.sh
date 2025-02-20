#!/bin/bash

echo "[Proof](21/22): Create the proof"
snarkjs groth16 prove ${FINAL_ZKEY_FILE} ${WITNESS_FILE} ${OUTPUT_PATH}proof.json ${OUTPUT_PATH}public.json

echo "[Verification](22/22): Verify the proof"
snarkjs groth16 verify ${VERIFICATION_KEY_FILE} ${OUTPUT_PATH}public.json ${OUTPUT_PATH}proof.json
