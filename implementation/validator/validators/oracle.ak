use aiken/collection/list.{any, has}
use aiken/crypto.{VerificationKeyHash}
use cardano/address.{from_script}
use cardano/assets.{
  PolicyId, Value, flatten, from_asset, quantity_of, without_lovelace,
}
use cardano/transaction.{
  NoDatum, Output, OutputReference, Transaction, find_input,
}

validator oracle(verification_key_hash: ByteArray) {
  mint(_redeemer: void, policy_id: PolicyId, self: Transaction) {
    // The transaction signature matches with the verification key hash.
    let vkh: VerificationKeyHash = verification_key_hash
    let transaction_includes_verification_key_hash: Bool =
      has(self.extra_signatories, vkh)

    // The number of minted tokens is exactly 1.
    let minted_assets: Value = self.mint
    expect [(_, asset, number_of_minted_tokens)] = flatten(minted_assets)
    let has_only_one_minted_token: Bool = number_of_minted_tokens == 1

    // The minted tokens are sent to the validator address (policy_id).
    let address = from_script(policy_id)
    // Checking the payment credential.
    let transaction_outputs = self.outputs
    let minted_tokens_are_sent_to_validator_address: Bool =
      any(
        transaction_outputs,
        fn(transaction_output) {
          transaction_output.address == address && quantity_of(
            transaction_output.value,
            policy_id,
            asset,
          ) == 1
        },
      )

    and {
      transaction_includes_verification_key_hash,
      has_only_one_minted_token,
      minted_tokens_are_sent_to_validator_address,
    }
  }

  spend(
    _datum: Option<void>,
    _redeemer: void,
    utxo: OutputReference,
    self: Transaction,
  ) {
    // The transaction signature matches with the verification key hash.
    let vkh: VerificationKeyHash = verification_key_hash
    let transaction_includes_verification_key_hash: Bool =
      has(self.extra_signatories, vkh)

    // The tokens spent are sent to the validator address.
    expect Some(transaction_input) = find_input(self.inputs, utxo)
    let input_value = transaction_input.output.value |> without_lovelace()
    let sent_tokens_are_sent_to_validator_address: Bool =
      any(
        self.outputs,
        fn(transaction_output) {
          transaction_output.address == transaction_input.output.address && (
            transaction_output.value |> without_lovelace()
          ) == input_value
        },
      )
    and {
      transaction_includes_verification_key_hash,
      sent_tokens_are_sent_to_validator_address,
    }
  }

  else(_) {
    fail
  }
}

test test_mint_oracle_happy_path() {
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

  oracle.mint(verification_key_hash, redeemer, policy_id, transaction)
}
