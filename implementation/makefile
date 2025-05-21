include circuit/scripts/.env
export $(shell sed 's/=.*//' $(SCRIPTS_PATH).env)

create_output_path:
	if [ ! -d $(OUTPUT_PATH) ]; then \
		mkdir -p $(OUTPUT_PATH); \
	fi

# Powers of Tau Ceremony – Universal trusted setup phase that generates reusable parameters.
run_powers_of_tau_ceremony: create_output_path $(SCRIPTS_PATH)run_powers_of_tau_ceremony.sh
	if [ ! -f $(FINAL_PTAU_FILE) ]; then \
		bash $(SCRIPTS_PATH)run_powers_of_tau_ceremony.sh; \
	fi

# Circuit Compilation and Constraint System Generation – Compiles the circuit into R1CS and generates the required constraints.
compile_circuit_and_generate_constraints: run_powers_of_tau_ceremony $(SCRIPTS_PATH)compile_circuit_and_generate_constraints.sh $(CIRCUIT_FILE)
	bash $(SCRIPTS_PATH)compile_circuit_and_generate_constraints.sh

# Witness Generation and Validation – Computes a witness based on the user inputs and verifies its correctness against the circuit constraints.
generate_and_validate_witnesses: compile_circuit_and_generate_constraints $(SCRIPTS_PATH)generate_and_validate_witnesses.sh $(COMPILED_CIRCUIT_CONSTRAINTS_FILE) $(CIRCUIT_INPUT_FILE)
	bash $(SCRIPTS_PATH)generate_and_validate_witnesses.sh

# Groth16 Setup – Uses the final Powers of Tau output to generate proving and verification keys for the specific circuit.
generate_groth_16_keys: generate_and_validate_witnesses $(SCRIPTS_PATH)generate_groth_16_keys.sh $(COMPILED_CIRCUIT_CONSTRAINTS_FILE) $(FINAL_PTAU_FILE)
	bash $(SCRIPTS_PATH)generate_groth_16_keys.sh

# Proof Generation and Verification – Uses the proving key and witness to generate the proof, then verifies it.
generate_and_verify_proof: generate_groth_16_keys $(SCRIPTS_PATH)generate_and_verify_proof.sh $(FINAL_ZKEY_FILE) $(WITNESS_FILE) $(VERIFICATION_KEY_FILE)
	bash $(SCRIPTS_PATH)generate_and_verify_proof.sh


### Testing
test_circuit:
	npx mocha -pr ts-node/register tests/*.js

test_merkle_tree:
	npx vitest


.PHONY: compile_circuit_and_generate_constraints generate_and_validate_witnesses generate_groth_16_keys generate_and_verify_proof
