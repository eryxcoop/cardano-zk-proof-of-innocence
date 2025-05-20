use aiken/collection/dict.{is_empty}
use aiken/collection/list.{all, filter, has}
use aiken/crypto.{VerificationKeyHash}
use ak_381/groth16.{Proof, SnarkVerificationKey, groth_verify}
use cardano/address.{Address, Script, from_script}
use cardano/assets.{PolicyId, policies, tokens}
use cardano/transaction.{InlineDatum, OutputReference, Transaction, find_input}
use common.{OracleDatum}

pub type TransactionIDHash =
  Int

pub type POIDatum {
  verification_key_output_reference: OutputReference,
  oracle_token_policy_id: PolicyId,
}

pub type POIRedeemer {
  Create
  Update
  ValidateProof(Proof, TransactionIDHash)
}

validator proof_of_innocence(verification_key_hash: ByteArray) {
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
        let address_of_this_validator: Address =
          proof_of_innocence_input.output.address
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
        let spent_tokens_are_sent_to_validator_address: Bool =
          all(
            proof_of_innocence_outputs,
            fn(output) { output.address == address_of_this_validator },
          )

        and {
          transaction_includes_verification_key_hash,
          spent_tokens_are_sent_to_validator_address,
        }
      }

      ValidateProof(proof, transaction_id_hash) -> {
        expect Some(poi_datum) = datum

        // A reference input is included, with the output reference of the verification key.
        expect [reference_input_with_verification_key] =
          filter(
            self.reference_inputs,
            fn(reference_input) {
              reference_input.output_reference == poi_datum.verification_key_output_reference
            },
          )
        expect InlineDatum(reference_input_datum) =
          reference_input_with_verification_key.output.datum
        expect snark_verification_key: SnarkVerificationKey =
          reference_input_datum

        // A reference input is included, with a merkle tree root hash, paired with a token from the designated oracle.
        expect [reference_input_with_merkle_tree_root_hash] =
          filter(
            self.reference_inputs,
            fn(reference_input) {
              let value_policies = policies(reference_input.output.value)
              has(value_policies, poi_datum.oracle_token_policy_id)
            },
          )
        expect InlineDatum(oracle_datum) =
          reference_input_with_merkle_tree_root_hash.output.datum
        expect merkle_tree_root_hash: OracleDatum = oracle_datum

        // The included ZK proof is correct with respect to the verification key and the redeemer's public data.
        let is_zk_proof_valid: Bool =
          groth_verify(
            snark_verification_key,
            proof,
            [merkle_tree_root_hash.merkle_tree_root_hash, transaction_id_hash],
          )

        // The spent tokens are sent to the validator address (policy_id).
        expect Some(proof_of_innocence_input) = find_input(self.inputs, utxo)
        let address_of_this_validator: Address =
          proof_of_innocence_input.output.address
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
        expect [proof_of_innocence_output] = proof_of_innocence_outputs
        let spent_tokens_are_sent_to_validator_address: Bool =
          proof_of_innocence_output.address == address_of_this_validator

        // The datum from the spent token is unchanged.
        let datum_is_unchanged: Bool =
          proof_of_innocence_input.output.datum == proof_of_innocence_output.datum

        and {
          is_zk_proof_valid,
          spent_tokens_are_sent_to_validator_address,
          datum_is_unchanged,
        }
      }
      _ -> False
    }
  }

  else(_) {
    fail
  }
}
