use aiken/crypto.{VerificationKeyHash}
use cardano/address.{Address, from_script}
use cardano/assets.{Value, from_asset}
use cardano/transaction.{Input, NoDatum, Output, OutputReference, Transaction}
use oracle

const unused_redeemer = None

const unused_datum = NoDatum

const policy_id = #"0001"

const verification_key_hash = #"0002"

const asset_name = #"0003"

const invalid_byte_array = #"ffff"

fn value_with_number_of_tokens(number_of_tokens: Int) {
  from_asset(policy_id, asset_name: asset_name, quantity: number_of_tokens)
}

fn validator_address() {
  from_script(policy_id)
}

fn arbitrary_address() {
  from_script(invalid_byte_array)
}

fn transaction_output(address: Address, value: Value) -> Output {
  Output {
    address,
    value,
    datum: unused_datum,
    // The datum should technically have the root hash in our use case.
    reference_script: None,
  }
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

// Minting

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

test test_oracle_forbids_a_minting_transaction_with_an_invalid_signature() {
  let value = value_with_number_of_tokens(1)
  let address = validator_address()
  let output = transaction_output(address, value)
  let signature_different_from_verification_key_hash = invalid_byte_array

  let transaction =
    minting_transaction_with(
      signature_different_from_verification_key_hash,
      value,
      output,
    )

  !oracle.oracle.mint(
    verification_key_hash,
    unused_redeemer,
    policy_id,
    transaction,
  )
}

test test_oracle_forbids_a_minting_transaction_with_more_than_one_minted_token() {
  let value = value_with_number_of_tokens(2)
  let address = validator_address()
  let output = transaction_output(address, value)

  let transaction =
    minting_transaction_with(verification_key_hash, value, output)

  !oracle.oracle.mint(
    verification_key_hash,
    unused_redeemer,
    policy_id,
    transaction,
  )
}

test test_oracle_forbids_a_minting_transaction_with_no_minted_tokens() {
  let value = value_with_number_of_tokens(0)
  let address = validator_address()
  let output = transaction_output(address, value)

  let transaction =
    minting_transaction_with(verification_key_hash, value, output)

  !oracle.oracle.mint(
    verification_key_hash,
    unused_redeemer,
    policy_id,
    transaction,
  )
}

test test_oracle_forbids_a_minting_transaction_sending_tokens_to_an_arbitrary_address() {
  let value = value_with_number_of_tokens(1)
  let address = arbitrary_address()
  let output = transaction_output(address, value)

  let transaction =
    minting_transaction_with(verification_key_hash, value, output)

  !oracle.oracle.mint(
    verification_key_hash,
    unused_redeemer,
    policy_id,
    transaction,
  )
}

test test_oracle_forbids_a_minting_transaction_sending_a_quantity_other_than_one_token_to_validator_address() {
  let minting_value = value_with_number_of_tokens(1)
  let output_value = value_with_number_of_tokens(2)
  let address = validator_address()
  let output = transaction_output(address, output_value)

  let transaction =
    minting_transaction_with(verification_key_hash, minting_value, output)

  !oracle.oracle.mint(
    verification_key_hash,
    unused_redeemer,
    policy_id,
    transaction,
  )
}

// Spending

const transaction_id = #"0004"

fn spending_transaction_with(
  signature: VerificationKeyHash,
  input: Input,
  output: Output,
) -> Transaction {
  transaction.placeholder
    |> fn(transaction) {
        Transaction {
          ..transaction,
          extra_signatories: [signature],
          inputs: [input],
          outputs: [output],
        }
      }
}

test test_oracle_permits_a_valid_spending_transaction() {
  let value = value_with_number_of_tokens(2)
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

test test_oracle_forbids_a_spending_transaction_with_an_invalid_signature() {
  let value = value_with_number_of_tokens(2)
  let address = validator_address()
  let output = transaction_output(address, value)
  let signature_different_from_verification_key_hash = invalid_byte_array

  let utxo = OutputReference { transaction_id, output_index: 0 }

  let input = Input { output_reference: utxo, output }

  let transaction =
    spending_transaction_with(
      signature_different_from_verification_key_hash,
      input,
      output,
    )

  !oracle.oracle.spend(
    verification_key_hash,
    None,
    unused_redeemer,
    utxo,
    transaction,
  )
}

test test_oracle_forbids_a_spending_transaction_sending_tokens_to_an_arbitrary_address() {
  let value = value_with_number_of_tokens(2)
  let transaction_input_address = validator_address()
  let previous_transaction_output =
    transaction_output(transaction_input_address, value)
  let transaction_otuput_address = arbitrary_address()
  let transaction_output = transaction_output(transaction_otuput_address, value)

  let utxo = OutputReference { transaction_id, output_index: 0 }

  let input = Input { output_reference: utxo, output: previous_transaction_output }

  let transaction =
    spending_transaction_with(verification_key_hash, input, transaction_output)

  !oracle.oracle.spend(
    verification_key_hash,
    None,
    unused_redeemer,
    utxo,
    transaction,
  )
}
