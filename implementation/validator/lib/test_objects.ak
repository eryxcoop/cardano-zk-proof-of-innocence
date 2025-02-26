use cardano/address.{from_script}
use cardano/assets.{from_asset}
use cardano/transaction.{NoDatum}

pub const unused_redeemer = None

pub const unused_datum = NoDatum

pub const policy_id = #"0001"

pub const verification_key_hash = #"0002"

pub const asset_name = #"0003"

pub const invalid_byte_array = #"ffff"

pub const invalid_signature = invalid_byte_array

pub fn value_with_number_of_tokens(number_of_tokens: Int) {
  from_asset(policy_id, asset_name: asset_name, quantity: number_of_tokens)
}

pub fn validator_address() {
  from_script(policy_id)
}

pub fn arbitrary_address() {
  from_script(invalid_byte_array)
}
