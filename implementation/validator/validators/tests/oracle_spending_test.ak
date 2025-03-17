use cardano/transaction.{Input, OutputReference}
use oracle
use test_objects.{
  arbitrary_address, arbitrary_signature, spending_transaction_with,
  transaction_id, transaction_output, unused_redeemer, validator_address,
  value_with_number_of_tokens, verification_key_hash,
}

// A successfull transaction. Usually done to update the Oracle State.
test test_oracle_permits_a_valid_spending_transaction() {
  let value = value_with_number_of_tokens(1)
  let address = validator_address()
  let output = transaction_output(address, value)

  let utxo = OutputReference { transaction_id, output_index: 0 }

  let input = Input { output_reference: utxo, output }

  let transaction =
    spending_transaction_with(verification_key_hash, input, output)

  oracle.oracle.spend(
    verification_key_hash,
    None,
    unused_redeemer,
    utxo,
    transaction,
  )
}

// Try to withdraw the token with the wrong VK.
test test_oracle_forbids_a_spending_transaction_with_an_arbitrary_signature() fail {
  let value = value_with_number_of_tokens(1)
  let address = validator_address()
  let output = transaction_output(address, value)
  let signature_different_from_verification_key_hash = arbitrary_signature

  let utxo = OutputReference { transaction_id, output_index: 0 }

  let input = Input { output_reference: utxo, output }

  let transaction =
    spending_transaction_with(
      signature_different_from_verification_key_hash,
      input,
      output,
    )

  oracle.oracle.spend(
    verification_key_hash,
    None,
    unused_redeemer,
    utxo,
    transaction,
  )
}

// The transaction maker doesn't return tokens to the correct script address.
test test_oracle_forbids_a_spending_transaction_sending_tokens_to_an_arbitrary_address() fail {
  let value = value_with_number_of_tokens(2)
  let transaction_input_address = validator_address()
  let previous_transaction_output =
    transaction_output(transaction_input_address, value)
  let transaction_otuput_address = arbitrary_address()
  let transaction_output = transaction_output(transaction_otuput_address, value)

  let utxo = OutputReference { transaction_id, output_index: 0 }

  let input =
    Input { output_reference: utxo, output: previous_transaction_output }

  let transaction =
    spending_transaction_with(verification_key_hash, input, transaction_output)

  oracle.oracle.spend(
    verification_key_hash,
    None,
    unused_redeemer,
    utxo,
    transaction,
  )
}
