use aiken/crypto.{VerificationKeyHash}
use cardano/assets.{Value}
use cardano/transaction.{Output, Transaction}
use oracle
use test_objects.{
  arbitrary_address, arbitrary_signature, policy_id, transaction_output,
  unused_redeemer, validator_address, value_with_number_of_tokens,
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

test test_oracle_permits_a_valid_minting_transaction() {
  let value = value_with_number_of_tokens(1)
  let address = validator_address()
  let output = transaction_output(address, value)

  let transaction =
    minting_transaction_with(verification_key_hash, value, output)

  oracle.oracle.mint(
    verification_key_hash,
    unused_redeemer,
    policy_id,
    transaction,
  )
}

test test_oracle_forbids_a_minting_transaction_with_an_arbitrary_signature() fail {
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

  oracle.oracle.mint(
    verification_key_hash,
    unused_redeemer,
    policy_id,
    transaction,
  )
}

test test_oracle_forbids_a_minting_transaction_with_more_than_one_minted_token() fail {
  let value = value_with_number_of_tokens(2)
  let address = validator_address()
  let output = transaction_output(address, value)

  let transaction =
    minting_transaction_with(verification_key_hash, value, output)

  oracle.oracle.mint(
    verification_key_hash,
    unused_redeemer,
    policy_id,
    transaction,
  )
}

test test_oracle_forbids_a_minting_transaction_with_no_minted_tokens() fail {
  let value = value_with_number_of_tokens(0)
  let address = validator_address()
  let output = transaction_output(address, value)

  let transaction =
    minting_transaction_with(verification_key_hash, value, output)

  oracle.oracle.mint(
    verification_key_hash,
    unused_redeemer,
    policy_id,
    transaction,
  )
}

test test_oracle_forbids_a_minting_transaction_sending_tokens_to_an_arbitrary_address() fail {
  let value = value_with_number_of_tokens(1)
  let address = arbitrary_address()
  let output = transaction_output(address, value)

  let transaction =
    minting_transaction_with(verification_key_hash, value, output)

  oracle.oracle.mint(
    verification_key_hash,
    unused_redeemer,
    policy_id,
    transaction,
  )
}

test test_oracle_forbids_a_minting_transaction_sending_a_quantity_other_than_one_token_to_validator_address() fail {
  let minting_value = value_with_number_of_tokens(1)
  let output_value = value_with_number_of_tokens(2)
  let address = validator_address()
  let output = transaction_output(address, output_value)

  let transaction =
    minting_transaction_with(verification_key_hash, minting_value, output)

  oracle.oracle.mint(
    verification_key_hash,
    unused_redeemer,
    policy_id,
    transaction,
  )
}
