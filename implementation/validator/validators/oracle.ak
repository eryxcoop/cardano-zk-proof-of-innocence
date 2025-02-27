use aiken/collection/dict.{Dict, get, keys, size}
use aiken/collection/list.{any, at, has}
use aiken/crypto.{VerificationKeyHash}
use cardano/address.{from_script}
use cardano/assets.{AssetName, PolicyId, quantity_of, tokens, without_lovelace}
use cardano/transaction.{Datum, OutputReference, Transaction, find_input}

validator oracle(verification_key_hash: ByteArray) {
  mint(_redeemer: void, policy_id: PolicyId, self: Transaction) {
    // The transaction signature matches with the verification key hash.
    let vkh: VerificationKeyHash = verification_key_hash
    let transaction_includes_verification_key_hash: Bool =
      has(self.extra_signatories, vkh)

    // The number of minted tokens is exactly 1.
    let number_of_mints_per_asset: Dict<AssetName, Int> =
      tokens(self.mint, policy_id)
    if size(number_of_mints_per_asset) != 1 {
      False
    } else {
      expect Some(asset) = at(keys(number_of_mints_per_asset), 0)
      expect Some(number_of_minted_tokens) =
        get(number_of_mints_per_asset, asset)
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
  }

  spend(
    _datum: Option<Datum>,
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
