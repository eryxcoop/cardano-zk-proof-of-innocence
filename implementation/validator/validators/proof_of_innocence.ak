use aiken/collection/dict.{is_empty}
use aiken/collection/list.{all, filter, has}
use aiken/crypto.{VerificationKeyHash}
use cardano/address.{Address, from_script}
use cardano/assets.{PolicyId, tokens}
use cardano/script_context.{ScriptContext}
use cardano/transaction.{OutputReference, Transaction, find_input}

use ak_381/groth16.{Proof}

type TransactionIDHash = ByteArray

type POIDatum {
  verification_key_output_reference: OutputReference,
  oracle_token_policy_id: PolicyId,
}

type POIRedeemer {
  Create
  Update
  ValidateProof(Proof, TransactionIDHash)
}

validator proof_of_innocence(verification_key_hash: ByteArray) {
  spend(
    _datum: Option<Data>,
    _redeemer: Data,
    _utxo: OutputReference,
    _self: Transaction,
  ) {
    True
  }

  mint(redeemer: POIRedeemer, policy_id: PolicyId, self: Transaction) {
    when redeemer is {
      Create -> {
        // The transaction signature matches with the verification key hash.
        let vkh: VerificationKeyHash = verification_key_hash
        let transaction_includes_verification_key_hash: Bool =
          has(self.extra_signatories, vkh)

        // The minted tokens are sent to the validator address (policy_id).
        let address_of_this_validator: Address = from_script(policy_id)
        let transaction_outputs = self.outputs
        let proof_of_innocence_outputs =
          filter(
            transaction_outputs,
            fn(transaction_output) {
              let assets = tokens(transaction_output.value, policy_id)
              !is_empty(assets)
            },
          )
        let tokens_are_sent_to_validator_address: Bool =
          all(
            proof_of_innocence_outputs,
            fn(output) { output.address == address_of_this_validator },
          )

        and {
          transaction_includes_verification_key_hash,
          tokens_are_sent_to_validator_address,
        }
      }

      _ -> False
    }
  }

  spend(
    datum: Option<POIDatum>,
    redeemer: POIRedeemer,
    utxo: OutputReference,
    self: Transaction,
  ) {
    when redeemer is {
      Update -> {
        // The transaction signature matches with the verification key hash.
        let vkh: VerificationKeyHash = verification_key_hash
        let transaction_includes_verification_key_hash: Bool =
          has(self.extra_signatories, vkh)

        // The spent tokens are sent to the validator address (policy_id).
        expect Some(proof_of_innocence_input) = find_input(self.inputs, utxo)
        let address_of_this_validator: Address = proof_of_innocence_input.output.address
        expect Script(policy_id) = address_of_this_validator.payment_credential
        let transaction_outputs = self.outputs
        let proof_of_innocence_outputs =
          filter(
            transaction_outputs,
            fn(transaction_output) {
              let assets = tokens(transaction_output.value, policy_id)
              !is_empty(assets)
            },
          )
        let minted_tokens_are_sent_to_validator_address: Bool =
          all(
            proof_of_innocence_outputs,
            fn(output) { output.address == address_of_this_validator },
          )

        and {
          transaction_includes_verification_key_hash,
          minted_tokens_are_sent_to_validator_address,
        }
      }

      ValidateProof -> {
        // A reference input is included, with the output reference of the verification key.

        // A reference input is included, with a merkle tree root hash.

        // The previous root hash is paired with a token from the designated oracle.

        // The included ZK proof is correct with respect to the verification key and the redeemer's public data.

        // The spent tokens are sent to the validator address (policy_id).

        // The datum from the spent token is unchanged. 
      }

      _ -> False
    }
  }

  else(_) {
    fail
  }
}
