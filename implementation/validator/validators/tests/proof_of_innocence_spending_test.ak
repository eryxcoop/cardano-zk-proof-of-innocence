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

test groth_verify_1() {
  let proof = Proof {
    piA: #"b06ea459ebddaffc88fd520a2d88373e3b5bd0429b28765541485058d709941d8e40535263f1a0f13bd1632eac8ab8c6",
    piB: #"b099258ba29e8951213a2f4f0c2740a82ab5c0976d344d73846d787cea76fbe438dc95bfedd3f7a894a4c455552642fa1125125fefc45738f00c945684f89062120c305aa2be468a345be1cc5063b30da90677996a05cabf353d7b23133fa3e3",
    piC: #"b6afada8f98b26d6a028b811ed0e7d89c3e71d0cec315c0eb933d99bd8f4061f94c135ab3561c14c4dda5570ed39e702",
  }

  let vk: SnarkVerificationKey = SnarkVerificationKey {
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

  groth_verify(vk, proof, [79, 9])
}

test groth_verify_2() {
  let proof = Proof {
    piA: #"8d41aa700e446d8531e0d940c6f50d16ea1a61aa76808db14fb14dbc7ed69ae7f11e6df20d62cee01320faf9886cea00",
    piB: #"85be8727d145667fde977a0d1463d750a50ab6a9f5006ca4bc49c979f4c752046274365733f80ea2409369b4e510dfd30e78b6b94621969df6fa21fd17a9068040d863c2a8bebe3e52491391a28b16f44bc60eeb95d62be29eb4ca803ecd84e0",
    piC: #"822a1af322bee8cf78843ef13118889ec90d047e5aacb6d811b1e1f528f16cea4cc5068b2e923dc05e331a712f65e1e2",
  }

  let vk: SnarkVerificationKey = SnarkVerificationKey {
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

  groth_verify(vk, proof, [79, 9])
}

test groth_verify_3() {
  let proof = Proof {
    piA: #"83965444cb17e432e7b9d1991e4db327806339602072e1a9c6fa09037e12fd7c0d74f609ac4edaf20319762299ce3010",
    piB: #"8fa9cebe1b2b30203b1ff9201764b45d7bc69f24b3e3c65a8f28dcf5e70fd8eb440f3d69e264e2dca1451614f4261e9507eb4147795bbc4e160989becda496fe2a75186632f48dc80698b935381d883c0e6bf03fe3ef1f59f8efb90873084049",
    piC: #"b5a61ee647de62c096369c62e6e5ba773ac37a27d7a43aab0524f54ee33a6349d0851c2933b1367f4d2baae428a38907",
  }

  let vk: SnarkVerificationKey = SnarkVerificationKey {
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

  groth_verify(vk, proof, [79, 9])
}

test groth_verify_4() {
  let proof = Proof {
    piA: #"aa4bf2c5c7e50be140c72078ac93d146b5b7655c32402ddd5da6c0eb4056a726b9eb72560a0ee38eab37dc23c42387d1",
    piB: #"a374a087d4f780a76383ab4da50883ed9965059735eeeaaad2ef831bb24e621a5919d463a8d9aa43638f7a4cc228f1720f2742c83bca796f3c7288152de0a442a90d969050e7fc1386057e6e2bcfaa83968d369c43508e6e13f10608170c9369",
    piC: #"9437e46cdf7baea1658efaac148473e0eb027914d8444fab4db6da42ab0f56c80e13d4f82f7d0f6c2d4e63fc0c4ab003",
  }

  let vk: SnarkVerificationKey = SnarkVerificationKey {
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

  groth_verify(vk, proof, [79, 9])
}

