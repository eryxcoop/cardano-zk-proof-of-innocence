use proof_of_innocence.{Create, Update}
use test_objects.{
  arbitrary_address, arbitrary_signature, minting_transaction_with, policy_id,
  transaction_output, transaction_value, validator_address,
  verification_key_hash,
}

test test_proof_of_innocence_validator_permits_a_valid_minting_transaction() {
  let value = transaction_value()
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

test test_proof_of_innocence_forbids_a_minting_transaction_with_an_arbitrary_signature() fail {
  let value = transaction_value()
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

test test_proof_of_innocence_forbids_a_minting_transaction_sending_tokens_to_an_arbitrary_address() fail {
  let value = transaction_value()
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

test test_proof_of_innocence_forbids_a_minting_transaction_with_a_redeemer_that_is_not_creating() fail {
  let value = transaction_value()
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
