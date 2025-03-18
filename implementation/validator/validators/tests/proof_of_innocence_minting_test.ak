use proof_of_innocence.{Create, Update}
use test_objects.{
  arbitrary_address, arbitrary_signature, minting_transaction_with, policy_id,
  transaction_output, validator_address, value_with_number_of_script_tokens,
  verification_key_hash,
}

// Mints a PoI token and send it to the script adress.
test test_proof_of_innocence_validator_permits_a_valid_minting_transaction() {
  let value = value_with_number_of_script_tokens(1)
  let address = validator_address()
  let output = transaction_output(address, value)

  let transaction =
    minting_transaction_with(verification_key_hash, value, output)

  proof_of_innocence.proof_of_innocence.mint(
    verification_key_hash,
    Create,
    policy_id,
    transaction,
  )
}

// Tries to create a PoI token with an incorrect vk.
test test_proof_of_innocence_forbids_a_minting_transaction_with_an_arbitrary_signature() fail {
  let value = value_with_number_of_script_tokens(1)
  let address = validator_address()
  let output = transaction_output(address, value)
  let signature_different_from_verification_key_hash = arbitrary_signature

  let transaction =
    minting_transaction_with(
      signature_different_from_verification_key_hash,
      value,
      output,
    )

  proof_of_innocence.proof_of_innocence.mint(
    verification_key_hash,
    Create,
    policy_id,
    transaction,
  )
}

// Tries to create a PoI token with an incorrect script address (different than the actual script).
test test_proof_of_innocence_forbids_a_minting_transaction_sending_tokens_to_an_arbitrary_address() fail {
  let value = value_with_number_of_script_tokens(1)
  let address = arbitrary_address()
  let output = transaction_output(address, value)

  let transaction =
    minting_transaction_with(verification_key_hash, value, output)

  proof_of_innocence.proof_of_innocence.mint(
    verification_key_hash,
    Create,
    policy_id,
    transaction,
  )
}

// Tries to create a PoI token with an incorrect Redeemer type.
// We need to check this out again testing by creating actual Tx.
test test_proof_of_innocence_forbids_a_minting_transaction_with_a_redeemer_that_is_not_creating() fail {
  let value = value_with_number_of_script_tokens(1)
  let address = validator_address()
  let output = transaction_output(address, value)

  let transaction =
    minting_transaction_with(verification_key_hash, value, output)

  proof_of_innocence.proof_of_innocence.mint(
    verification_key_hash,
    Update,
    policy_id,
    transaction,
  )
}
