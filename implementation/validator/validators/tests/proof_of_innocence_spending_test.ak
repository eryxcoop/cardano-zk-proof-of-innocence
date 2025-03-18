use cardano/transaction.{Input, OutputReference}
use proof_of_innocence.{Create, POIDatum, Update}
use test_objects.{
  arbitrary_address, arbitrary_signature, policy_id, spending_transaction_with,
  transaction_id, transaction_output, validator_address,
  value_with_number_of_script_tokens, verification_key_hash,
}

// Valid update of POI script.
test test_proof_of_innocence_validator_permits_a_valid_spending_update_transaction() {
  let value = value_with_number_of_script_tokens(1)
  let address = validator_address()
  let output = transaction_output(address, value)

  let oref = OutputReference { transaction_id, output_index: 0 }

  let input = Input { output_reference: oref, output }

  let datum =
    POIDatum {
      verification_key_output_reference: oref,
      oracle_token_policy_id: policy_id,
    }

  let transaction =
    spending_transaction_with(verification_key_hash, input, output)

  proof_of_innocence.proof_of_innocence.spend(
    verification_key_hash,
    Some(datum),
    Update,
    oref,
    transaction,
  )
}

// Invalid PoI update using an incorrect signature.
test test_proof_of_innocence_forbids_a_spending_update_transaction_with_an_arbitrary_signature() fail {
  let value = value_with_number_of_script_tokens(1)
  let address = validator_address()
  let output = transaction_output(address, value)
  let signature_different_from_verification_key_hash = arbitrary_signature

  let oref = OutputReference { transaction_id, output_index: 0 }

  let input = Input { output_reference: oref, output }

  let datum =
    POIDatum {
      verification_key_output_reference: oref,
      oracle_token_policy_id: policy_id,
    }

  let transaction =
    spending_transaction_with(
      signature_different_from_verification_key_hash,
      input,
      output,
    )

  proof_of_innocence.proof_of_innocence.spend(
    verification_key_hash,
    Some(datum),
    Update,
    oref,
    transaction,
  )
}

// Invalid PoI update - Send funds to a different address than the script adress.
test test_oracle_forbids_a_spending_update_transaction_sending_tokens_to_an_arbitrary_address() fail {
  let value = value_with_number_of_script_tokens(1)
  let transaction_input_address = validator_address()
  let previous_transaction_output =
    transaction_output(transaction_input_address, value)
  let transaction_otuput_address = arbitrary_address()
  let transaction_output = transaction_output(transaction_otuput_address, value)

  let oref = OutputReference { transaction_id, output_index: 0 }

  let input =
    Input { output_reference: oref, output: previous_transaction_output }

  let datum =
    POIDatum {
      verification_key_output_reference: oref,
      oracle_token_policy_id: policy_id,
    }

  let transaction =
    spending_transaction_with(verification_key_hash, input, transaction_output)

  proof_of_innocence.proof_of_innocence.spend(
    verification_key_hash,
    Some(datum),
    Update,
    oref,
    transaction,
  )
}

// Tries to spend the validator invoking the minting part of the script.
// Revisor: Similarly, to the spending Oracle test, we need to check this out further.
test test_proof_of_innocence_validator_forbids_a_spending_transaction_that_is_not_updating_or_validating_a_proof() fail {
  let value = value_with_number_of_script_tokens(1)
  let address = validator_address()
  let output = transaction_output(address, value)

  let oref = OutputReference { transaction_id, output_index: 0 }

  let input = Input { output_reference: oref, output }

  let datum =
    POIDatum {
      verification_key_output_reference: oref,
      oracle_token_policy_id: policy_id,
    }

  let transaction =
    spending_transaction_with(verification_key_hash, input, output)

  proof_of_innocence.proof_of_innocence.spend(
    verification_key_hash,
    Some(datum),
    Create,
    oref,
    transaction,
  )
}
// TODO: Test the actual PoI functionality (ValidateProof)
