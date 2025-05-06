use ak_381/groth16.{Proof, SnarkVerificationKey, groth_verify}
use cardano/transaction.{Input, OutputReference, Output, InlineDatum, Transaction}
use cardano/address.{from_script}
use cardano/assets.{zero, from_asset}
use proof_of_innocence.{Create, POIDatum, Update, ValidateProof}
use test_objects.{
  arbitrary_address, arbitrary_signature, policy_id, spending_transaction_with,
  transaction_id, transaction_output, validator_address,
  value_with_number_of_script_tokens, verification_key_hash,
}
use common.{OracleDatum}


// Valid update of POI script.
test test_proof_of_innocence_validator_permits_a_valid_spending_update_transaction() {
  let value = value_with_number_of_script_tokens(1)
  let address = validator_address()
  let output = transaction_output(address, value)

  let oref = OutputReference { transaction_id, output_index: 0 }

  let input = Input { output_reference: oref, output }

  let datum =
    POIDatum {
      verification_key_output_reference: oref,
      oracle_token_policy_id: policy_id,
    }

  let transaction =
    spending_transaction_with(verification_key_hash, input, output)

  proof_of_innocence.proof_of_innocence.spend(
    verification_key_hash,
    Some(datum),
    Update,
    oref,
    transaction,
  )
}

// Invalid PoI update using an incorrect signature.
test test_proof_of_innocence_forbids_a_spending_update_transaction_with_an_arbitrary_signature() fail {
  let value = value_with_number_of_script_tokens(1)
  let address = validator_address()
  let output = transaction_output(address, value)
  let signature_different_from_verification_key_hash = arbitrary_signature

  let oref = OutputReference { transaction_id, output_index: 0 }

  let input = Input { output_reference: oref, output }

  let datum =
    POIDatum {
      verification_key_output_reference: oref,
      oracle_token_policy_id: policy_id,
    }

  let transaction =
    spending_transaction_with(
      signature_different_from_verification_key_hash,
      input,
      output,
    )

  proof_of_innocence.proof_of_innocence.spend(
    verification_key_hash,
    Some(datum),
    Update,
    oref,
    transaction,
  )
}

// Invalid PoI update - Send funds to a different address than the script adress.
test test_oracle_forbids_a_spending_update_transaction_sending_tokens_to_an_arbitrary_address() fail {
  let value = value_with_number_of_script_tokens(1)
  let transaction_input_address = validator_address()
  let previous_transaction_output =
    transaction_output(transaction_input_address, value)
  let transaction_otuput_address = arbitrary_address()
  let transaction_output = transaction_output(transaction_otuput_address, value)

  let oref = OutputReference { transaction_id, output_index: 0 }

  let input =
    Input { output_reference: oref, output: previous_transaction_output }

  let datum =
    POIDatum {
      verification_key_output_reference: oref,
      oracle_token_policy_id: policy_id,
    }

  let transaction =
    spending_transaction_with(verification_key_hash, input, transaction_output)

  proof_of_innocence.proof_of_innocence.spend(
    verification_key_hash,
    Some(datum),
    Update,
    oref,
    transaction,
  )
}

// Tries to spend the validator invoking the minting part of the script.
// Revisor: Similarly, to the spending Oracle test, we need to check this out further.
test test_proof_of_innocence_validator_forbids_a_spending_transaction_that_is_not_updating_or_validating_a_proof() fail {
  let value = value_with_number_of_script_tokens(1)
  let address = validator_address()
  let output = transaction_output(address, value)

  let oref = OutputReference { transaction_id, output_index: 0 }

  let input = Input { output_reference: oref, output }

  let datum =
    POIDatum {
      verification_key_output_reference: oref,
      oracle_token_policy_id: policy_id,
    }

  let transaction =
    spending_transaction_with(verification_key_hash, input, output)

  proof_of_innocence.proof_of_innocence.spend(
    verification_key_hash,
    Some(datum),
    Create,
    oref,
    transaction,
  )
}

const happy_path_snark_vk = SnarkVerificationKey {
  nPublic: 8,
  vkAlpha: #"b7c29c886159ce127ef268743fc9dca8888983909c77fa62065f44dc99b3accd876781e47a89b09b492f954ba806b3d3",
  vkBeta: #"8470dee8df0bbfd19e98b780623752ebc94e81bb07c176d1cc7b1b0a00e069f1c9043316f2262a69b2bdd8026bf19a7811b13b04eca7f2aba975d227a1b5489316fcc92372d1724a460071b6b09d13721f3d63b3dede83ef006142f5016207ef",
  vkGamma: #"93e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb8",
  vkDelta: #"90df0b0696b0a7ce5c9959fc28b3371b7f84e6e587448fa735b2e8dcddd6034a8be99ae4e8cf0bc7c2c8f08c165e253d10194c9cc7146701c998bade9e2768ceb262ea8cc7026bf41fadd8d5ac182f014f036244962b07f80de0bfefb45d455d",
  vkAlphaBeta: [
    #"93e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb8",
  ],
  vkIC: [
    #"8320572bc050f9a58f6868c6d521ea91b2db5082b8e07e5abf7a9522876351a676029ea661444a8b0caabfcae5693e70",
  ],
}

const happy_path_proof = Proof {
  piA: #"8d47869bfb8a21556d7fb5e2d08fbcaf074602b3b2b615630a23ecb426ce5aae9a3d1f5ab7a3e91445deca68232bc1ff",
  piB: #"805b96c6c35f56ccbc7708b4d21c5db9f5a64ed961c901b8f6d4ad05496bc8d7350a2f75c60fad1990954ff0300038d80194f0c8c6f7644b1188d7b0cbe88a58a694f86d6e294e5bf242ce30dc1911dc1d8eed21c27785fa73599161e3b55851",
  piC: #"9268315b6ba4561b31850c66b56a1bd65b123104481068d63f3001576421ea01e66d40d437e84f8576613d8929d32e3b",
}

test test_proof_can_be_verified() {
  let snark_vk = happy_path_snark_vk
  let proof = happy_path_proof

  let public_inputs = [1,2,3]
  groth_verify(snark_vk, proof, public_inputs)
}

test test_invalid_proof_cannot_be_verified() fail {
  let snark_vk = happy_path_snark_vk

  let invalid_curve_point = #"00"

  let invalid_proof = Proof { ..happy_path_proof, piA: invalid_curve_point }

  let public_inputs = []
  groth_verify(snark_vk, invalid_proof, public_inputs)
}

test test_proof_of_innocence_validator_permits_a_spending_transaction_that_is_verifying_a_valid_proof() {
  let redeemer = ValidateProof(happy_path_proof, 79)

  let value = value_with_number_of_script_tokens(1)
  let address = validator_address()
  let output = transaction_output(address, value)

   let oref_script = OutputReference { transaction_id, output_index: 0 }
  let oref_vk = OutputReference { transaction_id: #"01", output_index: 0 }

  let input = Input { output_reference: oref_script, output }

  let datum =
    POIDatum {
      verification_key_output_reference: oref_vk,
      oracle_token_policy_id: policy_id,
    }

  let transaction =
    spending_transaction_with(verification_key_hash, input, output)

  // Create VK reference inputs 
  
  let verification_key_output = Output {
    address: from_script(#"00"),
    value: zero,
    datum: InlineDatum(happy_path_snark_vk),
    reference_script: None,
  }

  let input_verification_key = Input { output_reference: oref_vk, output: verification_key_output }

  // Create Oracle reference input

  let oracle_datum = OracleDatum {
    merkle_tree_root_hash: 0,
  }

  let oref_oracle = OutputReference { transaction_id: #"02", output_index: 0 }

  let oracle_output = Output {
    address: from_script(#"01"),
    value: from_asset(policy_id, #"01", 1),
    datum: InlineDatum(oracle_datum),
    reference_script: None,
  }

  let input_oracle = Input { output_reference: oref_oracle, output: oracle_output }


  let transaction_with_reference_input = transaction
    |> fn(transaction) {
        Transaction {
          ..transaction,
          reference_inputs: [input_verification_key, input_oracle]
        }
      }


  // Validator oref

  

  proof_of_innocence.proof_of_innocence.spend(
    verification_key_hash,
    Some(datum),
    redeemer,
    oref_script,
    transaction_with_reference_input,
  )
}
