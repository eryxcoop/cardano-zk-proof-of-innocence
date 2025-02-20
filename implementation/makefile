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


.PHONY: compile_circuit_and_generate_constraints
