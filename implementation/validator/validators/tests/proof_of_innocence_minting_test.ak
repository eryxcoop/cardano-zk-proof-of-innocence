use proof_of_innocence.{Create}
use test_objects.{
  arbitrary_signature, minting_transaction_with, policy_id, transaction_output, validator_address,
  value_with_number_of_tokens, verification_key_hash,
}

test test_proof_of_innocence_validator_permits_a_valid_minting_transaction() {
  let value = value_with_number_of_tokens(1)
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
  let value = value_with_number_of_tokens(1)
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
