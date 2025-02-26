use cardano/address.{from_script}
use cardano/assets.{from_asset}
use cardano/transaction.{NoDatum}
use aiken/primitive/bytearray

pub const unused_redeemer = None

pub const unused_datum = NoDatum

pub const policy_id = bytearray.from_string(@"policy_id")

pub const verification_key_hash = bytearray.from_string(@"verification_key_hash")

pub const asset_name = bytearray.from_string(@"assset_name")

pub const invalid_byte_array = bytearray.from_string(@"invalid_byte_array")

pub const arbitrary_signature = bytearray.from_string(@"arbitrary_signature")

pub fn value_with_number_of_tokens(number_of_tokens: Int) {
  from_asset(policy_id, asset_name: asset_name, quantity: number_of_tokens)
}

pub fn validator_address() {
  from_script(policy_id)
}

pub fn arbitrary_address() {
  from_script(invalid_byte_array)
}
