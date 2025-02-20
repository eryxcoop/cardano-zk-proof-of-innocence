include circuit/scripts/.env
export $(shell sed 's/=.*//' $(SCRIPTS_PATH).env)

create_output_path:
	if [ ! -d $(OUTPUT_PATH) ]; then \
		mkdir -p $(OUTPUT_PATH); \
	fi

# Powers of Tau Ceremony – Universal trusted setup phase that generates reusable parameters.
run_powers_of_tau_ceremony: create_output_path
	if [ ! -f $(FINAL_PTAU_FILE) ]; then \
		bash $(SCRIPTS_PATH)run_powers_of_tau_ceremony.sh; \
	fi
