use aiken/collection/list.{any, has}
use aiken/crypto.{VerificationKeyHash}
use cardano/address.{from_script}
use cardano/assets.{PolicyId, Value, flatten, quantity_of}
use cardano/transaction.{Transaction}

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

    // expect 1 = number_of_minted_tokens
    // The minted tokens are sent to the validator address (policy_id).
    let address = from_script(policy_id)
    // Checking the payment credential from the multi validator.
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

  else(_) {
    fail
  }
}
