use common.{hex_to_dec}

pub type Hash =
  Int

pub fn dummy_hash_pair(left: Hash, right: Hash) -> Hash {
  3 * left + 7 * right
}

pub fn dummy_hash_single(element: Int) -> Hash {
  2 * element + 5
}

pub fn dummy_hash_transaction_id(id: ByteArray) -> Hash {
  let integer = hex_to_dec(id)
  dummy_hash_single(integer)
}
