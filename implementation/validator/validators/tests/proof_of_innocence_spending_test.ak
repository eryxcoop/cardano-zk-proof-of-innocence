use ak_381/groth16.{Proof, SnarkVerificationKey, groth_verify}
use cardano/address.{from_script}
use cardano/assets.{from_asset, zero}
use cardano/transaction.{
  InlineDatum, Input, Output, OutputReference, Transaction,
}
use common.{OracleDatum}
use dummy_hash.{dummy_hash_transaction_id}
use merkle_tree.{merkle_tree_root_for}
use proof_of_innocence.{Create, POIDatum, Update, ValidateProof}
use test_objects.{
  arbitrary_address, arbitrary_script, arbitrary_signature, asset_name,
  policy_id, spending_transaction_with, transaction_id, transaction_output,
  validator_address, value_with_number_of_script_tokens, verification_key_hash,
}

const verification_key_policy_id = #"00"

const verification_key_transaction_id = #"01"

const innocent_transaction_id = #"02"

const innocent_transaction_id_hash =
  dummy_hash_transaction_id(innocent_transaction_id)

const sparse_merkle_tree = [1, 1, 0, 1]

const merkle_tree_root_hash = merkle_tree_root_for(sparse_merkle_tree)

const proof_verification_inputs =
  [merkle_tree_root_hash, innocent_transaction_id_hash]

const altered_merkle_tree_root_hash = merkle_tree_root_hash + 1

const oracle_datum = OracleDatum { merkle_tree_root_hash }

const output_reference_for_script =
  OutputReference { transaction_id, output_index: 0 }

const oracle_output_reference =
  OutputReference { transaction_id: innocent_transaction_id, output_index: 0 }

const oracle_output =
  Output {
    address: from_script(arbitrary_script()),
    value: from_asset(policy_id, asset_name, 1),
    datum: InlineDatum(oracle_datum),
    reference_script: None,
  }

const valid_proof_of_innocence =
  Proof {
    piA: #"8d41aa700e446d8531e0d940c6f50d16ea1a61aa76808db14fb14dbc7ed69ae7f11e6df20d62cee01320faf9886cea00",
    piB: #"85be8727d145667fde977a0d1463d750a50ab6a9f5006ca4bc49c979f4c752046274365733f80ea2409369b4e510dfd30e78b6b94621969df6fa21fd17a9068040d863c2a8bebe3e52491391a28b16f44bc60eeb95d62be29eb4ca803ecd84e0",
    piC: #"822a1af322bee8cf78843ef13118889ec90d047e5aacb6d811b1e1f528f16cea4cc5068b2e923dc05e331a712f65e1e2",
  }

const validate_proof_redeemer =
  ValidateProof(valid_proof_of_innocence, innocent_transaction_id_hash)

const vk: SnarkVerificationKey =
  SnarkVerificationKey {
    nPublic: 2,
    vkAlpha: #"87002aed4b240e827686f8264e0ae9db2e83d8569b78fc692f225c93d28dcd34eb9f42429af31fa06bc7401b060066a8",
    vkBeta: #"94c9685c9dbcdaa39134046a7fd8b16072d37114fd6f5c79e0466298d03e8ead9dfa5d19cabe79726f9459aabe95651d0c088f712df38523b8f64e03fb1692a4666505d1e184e2ec6cba995f2bf465889c3df2a2620c670ca99cce35c2d57a06",
    vkGamma: #"93e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb8",
    vkDelta: #"899fbed0bd154fa173072b3353a00b36b7cb1b7b91f43465af249c7be70d255b3f2d10f69bd19d50495e27abb5ba39ed00da5021dedc58019bcbf7107486d527eae8c0507c5bf741ab73a430f4db0d3ccd21b695bb08e99a6886ea9d575b2950",
    vkAlphaBeta: [
      #"d6574d88ab7cd30d8670887b8c97a3da2f51ada024d599b86c65c7d2efeea2400b8360a087648e0131548c90b31e9daf04f1bf384716c752626636317ea3c4613c5827e784954c1123b6833d134fff94aaee2ff6628d0154cbe4ef610ce0e90e",
      #"d8be55d6446c83a271c36cc331d000f5916862e23d57b34dea72bb8500e379a60ba6bb8af76d1d1582208b71e5a568c10e5213e7c9535d3fc782474f8715635d1ed358257409f4dc825b67b35add9a1b1d5330b900ef29ddd32933d6e14bfca4",
    ],
    vkIC: [
      #"a5b0bbeda9d342ec2cfa598db21d585818bd4139db4089868ebcd178361f42414fc4fd4b2964ea690ff207435cd026b6",
      #"b0220209c8d3100a3119cf0528fc265bff7ce8d14d5f4b8ae4e955beb681ead788fc17a122a7478cce57f5c9a7c09d65",
      #"824dd1f45ae01b97a1c9fdac10de473a2a9e2e32ec1758d2d180d48e4c95e3e14cbdc6b9e713f7d624b449142524f7d7",
    ],
  }

const verification_key_output_reference =
  OutputReference {
    transaction_id: verification_key_transaction_id,
    output_index: 0,
  }

const verification_key_output =
  Output {
    address: from_script(verification_key_policy_id),
    value: zero,
    datum: InlineDatum(vk),
    reference_script: None,
  }

const input_verification_key =
  Input {
    output_reference: verification_key_output_reference,
    output: verification_key_output,
  }

// Valid update of POI script.
test valid_update() {
  let value = value_with_number_of_script_tokens(1)
  let output = transaction_output(validator_address(), value)
  let input = Input { output_reference: output_reference_for_script, output }
  let datum =
    POIDatum {
      verification_key_output_reference: output_reference_for_script,
      oracle_token_policy_id: policy_id,
    }

  let transaction =
    spending_transaction_with(verification_key_hash, input, output)

  proof_of_innocence.proof_of_innocence.spend(
    verification_key_hash,
    Some(datum),
    Update,
    output_reference_for_script,
    transaction,
  )
}

// Invalid PoI update using an incorrect signature.
test invalid_update_due_to_wrong_vk() fail {
  let value = value_with_number_of_script_tokens(1)
  let output = transaction_output(validator_address(), value)
  let input = Input { output_reference: output_reference_for_script, output }
  let datum =
    POIDatum {
      verification_key_output_reference: output_reference_for_script,
      oracle_token_policy_id: policy_id,
    }

  let signature_different_from_verification_key_hash = arbitrary_signature
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
    output_reference_for_script,
    transaction,
  )
}

// Invalid PoI update - Send funds to a different address than the script adress.
test invalid_update_due_wrong_address_destination() fail {
  let value = value_with_number_of_script_tokens(1)
  let previous_transaction_output =
    transaction_output(validator_address(), value)
  let transaction_otuput_address = arbitrary_address()
  let transaction_output = transaction_output(transaction_otuput_address, value)

  let input =
    Input {
      output_reference: output_reference_for_script,
      output: previous_transaction_output,
    }

  let datum =
    POIDatum {
      verification_key_output_reference: output_reference_for_script,
      oracle_token_policy_id: policy_id,
    }

  let transaction =
    spending_transaction_with(verification_key_hash, input, transaction_output)

  proof_of_innocence.proof_of_innocence.spend(
    verification_key_hash,
    Some(datum),
    Update,
    output_reference_for_script,
    transaction,
  )
}

// Tries to spend the validator invoking the minting part of the script.
// Revisor: Similarly, to the spending Oracle test, we need to check this out further.
test invalid_spend_due_to_wrong_redeemer() fail {
  let value = value_with_number_of_script_tokens(1)
  let output = transaction_output(validator_address(), value)

  let input = Input { output_reference: output_reference_for_script, output }

  let datum =
    POIDatum {
      verification_key_output_reference: output_reference_for_script,
      oracle_token_policy_id: policy_id,
    }

  let transaction =
    spending_transaction_with(verification_key_hash, input, output)

  proof_of_innocence.proof_of_innocence.spend(
    verification_key_hash,
    Some(datum),
    Create,
    output_reference_for_script,
    transaction,
  )
}

// Zero-Knowledge proofs

test zk_verify_1() {
  groth_verify(vk, valid_proof_of_innocence, proof_verification_inputs)
}

test zk_verify_2() {
  let proof =
    Proof {
      piA: #"b06ea459ebddaffc88fd520a2d88373e3b5bd0429b28765541485058d709941d8e40535263f1a0f13bd1632eac8ab8c6",
      piB: #"b099258ba29e8951213a2f4f0c2740a82ab5c0976d344d73846d787cea76fbe438dc95bfedd3f7a894a4c455552642fa1125125fefc45738f00c945684f89062120c305aa2be468a345be1cc5063b30da90677996a05cabf353d7b23133fa3e3",
      piC: #"b6afada8f98b26d6a028b811ed0e7d89c3e71d0cec315c0eb933d99bd8f4061f94c135ab3561c14c4dda5570ed39e702",
    }
  groth_verify(vk, proof, proof_verification_inputs)
}

test zk_verify_3() {
  let proof =
    Proof {
      piA: #"83965444cb17e432e7b9d1991e4db327806339602072e1a9c6fa09037e12fd7c0d74f609ac4edaf20319762299ce3010",
      piB: #"8fa9cebe1b2b30203b1ff9201764b45d7bc69f24b3e3c65a8f28dcf5e70fd8eb440f3d69e264e2dca1451614f4261e9507eb4147795bbc4e160989becda496fe2a75186632f48dc80698b935381d883c0e6bf03fe3ef1f59f8efb90873084049",
      piC: #"b5a61ee647de62c096369c62e6e5ba773ac37a27d7a43aab0524f54ee33a6349d0851c2933b1367f4d2baae428a38907",
    }

  groth_verify(vk, proof, proof_verification_inputs)
}

test zk_verify_4() {
  let proof =
    Proof {
      piA: #"aa4bf2c5c7e50be140c72078ac93d146b5b7655c32402ddd5da6c0eb4056a726b9eb72560a0ee38eab37dc23c42387d1",
      piB: #"a374a087d4f780a76383ab4da50883ed9965059735eeeaaad2ef831bb24e621a5919d463a8d9aa43638f7a4cc228f1720f2742c83bca796f3c7288152de0a442a90d969050e7fc1386057e6e2bcfaa83968d369c43508e6e13f10608170c9369",
      piC: #"9437e46cdf7baea1658efaac148473e0eb027914d8444fab4db6da42ab0f56c80e13d4f82f7d0f6c2d4e63fc0c4ab003",
    }

  groth_verify(vk, proof, proof_verification_inputs)
}

test zk_verify_fail_1() fail {
  let invalid_curve_point =
    #"83965444cb17e432e7b9d1991e4db327806339602072e1a9c6fa09037e12fd7c0d74f609ac4edaf20319762299ce3010"

  let invalid_proof =
    Proof { ..valid_proof_of_innocence, piA: invalid_curve_point }

  groth_verify(vk, invalid_proof, proof_verification_inputs)
}

test zk_verify_fail_2() fail {
  let invalid_verification_inputs =
    [merkle_tree_root_hash, innocent_transaction_id_hash + 1]

  groth_verify(vk, valid_proof_of_innocence, invalid_verification_inputs)
}

test proof_of_innocence_success() {
  let value = value_with_number_of_script_tokens(1)
  let output = transaction_output(validator_address(), value)
  let verification_key_output_reference =
    OutputReference { transaction_id: #"01", output_index: 0 }

  let input = Input { output_reference: output_reference_for_script, output }

  let datum =
    POIDatum {
      verification_key_output_reference,
      oracle_token_policy_id: policy_id,
    }

  let transaction =
    spending_transaction_with(verification_key_hash, input, output)

  let input_oracle =
    Input { output_reference: oracle_output_reference, output: oracle_output }

  let transaction_with_reference_input =
    transaction
      |> fn(transaction) {
          Transaction {
            ..transaction,
            reference_inputs: [input_verification_key, input_oracle],
          }
        }

  proof_of_innocence.proof_of_innocence.spend(
    verification_key_hash,
    Some(datum),
    validate_proof_redeemer,
    output_reference_for_script,
    transaction_with_reference_input,
  )
}

// Executes the previous proof_of_innocence_success test with another valid proof.
test proof_of_innocence_success_2() {
  let value = value_with_number_of_script_tokens(1)
  let output = transaction_output(validator_address(), value)

  let input = Input { output_reference: output_reference_for_script, output }

  let datum =
    POIDatum {
      verification_key_output_reference,
      oracle_token_policy_id: policy_id,
    }

  let transaction =
    spending_transaction_with(verification_key_hash, input, output)

  let input_oracle =
    Input { output_reference: oracle_output_reference, output: oracle_output }

  let transaction_with_reference_input =
    transaction
      |> fn(transaction) {
          Transaction {
            ..transaction,
            reference_inputs: [input_verification_key, input_oracle],
          }
        }

  proof_of_innocence.proof_of_innocence.spend(
    verification_key_hash,
    Some(datum),
    validate_proof_redeemer,
    output_reference_for_script,
    transaction_with_reference_input,
  )
}

test proof_of_innocence_fails_due_invalid_vk_oref() fail {
  let value = value_with_number_of_script_tokens(1)
  let output = transaction_output(validator_address(), value)

  let input = Input { output_reference: output_reference_for_script, output }

  let datum =
    POIDatum {
      verification_key_output_reference: OutputReference {
        transaction_id: innocent_transaction_id,
        output_index: 0,
      },
      oracle_token_policy_id: policy_id,
    }

  let transaction =
    spending_transaction_with(verification_key_hash, input, output)

  let input_oracle =
    Input { output_reference: oracle_output_reference, output: oracle_output }

  let transaction_with_reference_input =
    transaction
      |> fn(transaction) {
          Transaction {
            ..transaction,
            reference_inputs: [input_verification_key, input_oracle],
          }
        }

  proof_of_innocence.proof_of_innocence.spend(
    verification_key_hash,
    Some(datum),
    validate_proof_redeemer,
    output_reference_for_script,
    transaction_with_reference_input,
  )
}

// Executes the previous proof_of_innocence_success test with another valid proof.
test proof_of_innocence_fails_due_to_wrong_public_input() fail {
  let value = value_with_number_of_script_tokens(1)
  let output = transaction_output(validator_address(), value)

  let input = Input { output_reference: output_reference_for_script, output }

  let datum =
    POIDatum {
      verification_key_output_reference,
      oracle_token_policy_id: policy_id,
    }

  let transaction =
    spending_transaction_with(verification_key_hash, input, output)

  // Create Oracle reference input
  let altered_oracle_datum =
    OracleDatum { merkle_tree_root_hash: altered_merkle_tree_root_hash }

  let oracle_output =
    Output {
      address: from_script(#"01"),
      value: from_asset(policy_id, #"01", 1),
      datum: InlineDatum(altered_oracle_datum),
      reference_script: None,
    }

  let input_oracle =
    Input { output_reference: oracle_output_reference, output: oracle_output }

  let transaction_with_reference_input =
    transaction
      |> fn(transaction) {
          Transaction {
            ..transaction,
            reference_inputs: [input_verification_key, input_oracle],
          }
        }

  proof_of_innocence.proof_of_innocence.spend(
    verification_key_hash,
    Some(datum),
    validate_proof_redeemer,
    output_reference_for_script,
    transaction_with_reference_input,
  )
}

// Executes the previous proof_of_innocence_success test with another valid proof.
test proof_of_innocence_fails_due_to_wrong_address_destination() fail {
  let value = value_with_number_of_script_tokens(1)
  let other_address = from_script(#"1234")
  let output = transaction_output(other_address, value)

  let input = Input { output_reference: output_reference_for_script, output }

  let datum =
    POIDatum {
      verification_key_output_reference,
      oracle_token_policy_id: policy_id,
    }

  let transaction =
    spending_transaction_with(verification_key_hash, input, output)

  let input_oracle =
    Input { output_reference: oracle_output_reference, output: oracle_output }

  let transaction_with_reference_input =
    transaction
      |> fn(transaction) {
          Transaction {
            ..transaction,
            reference_inputs: [input_verification_key, input_oracle],
          }
        }

  proof_of_innocence.proof_of_innocence.spend(
    verification_key_hash,
    Some(datum),
    validate_proof_redeemer,
    output_reference_for_script,
    transaction_with_reference_input,
  )
}

test proof_of_innocence_fails_due_to_datum_alteration() fail {
  let value = value_with_number_of_script_tokens(1)
  let address = validator_address()
  let output = transaction_output(validator_address(), value)

  let input = Input { output_reference: output_reference_for_script, output }

  let datum =
    POIDatum {
      verification_key_output_reference,
      oracle_token_policy_id: policy_id,
    }

  let modified_datum =
    POIDatum {
      verification_key_output_reference,
      oracle_token_policy_id: #"12",
    }

  let new_output =
    Output {
      address,
      value,
      datum: InlineDatum(modified_datum),
      reference_script: None,
    }

  let transaction =
    spending_transaction_with(verification_key_hash, input, new_output)

  let input_oracle =
    Input { output_reference: oracle_output_reference, output: oracle_output }

  let transaction_with_reference_input =
    transaction
      |> fn(transaction) {
          Transaction {
            ..transaction,
            reference_inputs: [input_verification_key, input_oracle],
          }
        }

  proof_of_innocence.proof_of_innocence.spend(
    verification_key_hash,
    Some(datum),
    validate_proof_redeemer,
    output_reference_for_script,
    transaction_with_reference_input,
  )
}
