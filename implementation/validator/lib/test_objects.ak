use aiken/primitive/bytearray
use cardano/address.{Address, from_script}
use cardano/assets.{Value, from_asset}
use cardano/transaction.{NoDatum, Output}

pub const unused_redeemer = None

pub const unused_datum = NoDatum

pub const policy_id = bytearray.from_string(@"policy_id")

pub const verification_key_hash =
  bytearray.from_string(@"verification_key_hash")

pub const asset_name = bytearray.from_string(@"assset_name")

pub const arbitrary_signature = bytearray.from_string(@"arbitrary_signature")

pub fn value_with_number_of_tokens(number_of_tokens: Int) {
  from_asset(policy_id, asset_name: asset_name, quantity: number_of_tokens)
}

pub fn validator_address() {
  from_script(policy_id)
}

pub fn arbitrary_address() {
  let arbitrary_script = bytearray.from_string(@"arbitrary_script")
  from_script(arbitrary_script)
}

pub fn transaction_output(address: Address, value: Value) -> Output {
  Output {
    address,
    value,
    datum: unused_datum,
    // The datum should technically have the root hash in our use case.
    reference_script: None,
  }
}
