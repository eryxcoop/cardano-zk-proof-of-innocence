use aiken/crypto.{VerificationKeyHash}
use cardano/address.{Address, from_script}
use cardano/assets.{Value, from_asset}
use cardano/transaction.{NoDatum, Output, Transaction}
use oracle

const unused_redeemer = None

const policy_id = #"0001"

const verification_key_hash = #"0002"

fn value_with_one_minted_token() {
  from_asset(policy_id, asset_name: #"0003", quantity: 1)
}

fn validator_address() {
  from_script(policy_id)
}

fn transaction_output(address: Address, value: Value) -> Output {
  Output {
    address,
    value,
    datum: NoDatum,
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

test test_oracle_permits_a_valid_minting_transaction() {
  let value = value_with_one_minted_token()
  let address = validator_address()
  let output = transaction_output(address, value)

  let transaction: Transaction =
    minting_transaction_with(verification_key_hash, value, output)

  oracle.oracle.mint(
    verification_key_hash,
    unused_redeemer,
    policy_id,
    transaction,
  )
}

test test_oracle_forbids_a_minting_transaction_with_an_invalid_signature() {
  let value = value_with_one_minted_token()
  let address = validator_address()
  let output = transaction_output(address, value)
  let signature_different_from_verification_key_hash = #"ffff"

  let transaction: Transaction =
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
