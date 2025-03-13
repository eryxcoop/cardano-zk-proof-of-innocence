use aiken/crypto.{VerificationKeyHash}
use cardano/assets.{Value}
use cardano/transaction.{Output, Transaction}
use proof_of_innocence.{Create}
use test_objects.{
  policy_id, transaction_output, validator_address, value_with_number_of_tokens,
  verification_key_hash,
}

fn minting_transaction_with(
  signature: VerificationKeyHash,
  value: Value,
  output: Output,
) -> Transaction {
  transaction.placeholder
    |> fn(transaction) {
        Transaction {
          ..transaction,
          extra_signatories: [signature],
          mint: value,
          outputs: [output],
        }
      }
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
