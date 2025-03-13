use aiken/crypto.{VerificationKeyHash}
use cardano/transaction.{Input, Output, OutputReference, Transaction}
use proof_of_innocence.{Create, POIDatum, Update, ValidateProof}
use test_objects.{
  arbitrary_address, arbitrary_signature, minting_transaction_with, policy_id,
  spending_transaction_with, transaction_id, transaction_output,
  transaction_value, validator_address, value_with_number_of_tokens,
  verification_key_hash,
}

test test_proof_of_innocence_validator_permits_a_valid_spending_transaction() {
  let value = value_with_number_of_tokens(2)
  let address = validator_address()
  let output = transaction_output(address, value)

  let utxo = OutputReference { transaction_id, output_index: 0 }

  let input = Input { output_reference: utxo, output }
  let datum =
    POIDatum {
      verification_key_output_reference: utxo,
      oracle_token_policy_id: policy_id,
    }

  let transaction =
    spending_transaction_with(verification_key_hash, input, output)

  proof_of_innocence.proof_of_innocence.spend(
    verification_key_hash,
    Some(datum),
    Update,
    utxo,
    transaction,
  )
}
