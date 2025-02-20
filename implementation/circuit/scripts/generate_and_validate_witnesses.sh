#!/bin/bash

echo "[Witness generation](1/2): Generate witness"
node ${CIRCUIT_OUTPUT_FILES_PREFIX}_js/generate_witness.js ${CIRCUIT_OUTPUT_FILES_PREFIX}_js/${CIRCUIT_NAME}.wasm ${CIRCUIT_INPUT_FILE} ${WITNESS_FILE}

echo "[Witness generation](2/2): Check witness"
snarkjs wtns check ${COMPILED_CIRCUIT_CONSTRAINTS_FILE} ${WITNESS_FILE}
