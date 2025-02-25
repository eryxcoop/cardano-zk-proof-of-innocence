use cardano/address.{from_script}
use cardano/assets.{from_asset}
use cardano/transaction.{NoDatum, Output, Transaction}
use oracle

test test_oracle_permits_a_valid_minting_transaction() {
  let verification_key_hash = #"0002"

  let redeemer = None
  let policy_id = #"0001"
  let value_with_one_minted_token =
    from_asset(policy_id, asset_name: #"0003", quantity: 1)
  let address = from_script(policy_id)

  let transaction_output =
    Output {
      address,
      value: value_with_one_minted_token,
      datum: NoDatum,
      // It should technically have the root hash in our use case.
      reference_script: None,
    }

  let transaction: Transaction =
    transaction.placeholder
      |> fn(transaction) {
          Transaction {
            ..transaction,
            extra_signatories: [verification_key_hash],
            mint: value_with_one_minted_token,
            outputs: [transaction_output],
          }
        }

  oracle.oracle.mint(verification_key_hash, redeemer, policy_id, transaction)
}

test test_oracle_forbids_a_minting_transaction_with_an_invalid_signature() {
  let verification_key_hash = #"0002"

  let redeemer = None
  let policy_id = #"0001"
  let value_with_one_minted_token =
    from_asset(policy_id, asset_name: #"0003", quantity: 1)
  let address = from_script(policy_id)

  let invalid_verification_key_hash = #"ffff"

  let transaction_output =
    Output {
      address,
      value: value_with_one_minted_token,
      datum: NoDatum,
      // It should technically have the root hash in our use case.
      reference_script: None,
    }

  let transaction: Transaction =
    transaction.placeholder
      |> fn(transaction) {
          Transaction {
            ..transaction,
            extra_signatories: [invalid_verification_key_hash],
            mint: value_with_one_minted_token,
            outputs: [transaction_output],
          }
        }

  !oracle.oracle.mint(verification_key_hash, redeemer, policy_id, transaction)
}
