use common.{hex_to_dec}

pub type Hash =
  Int

pub fn dummy_hash_pair(left: Hash, right: Hash) -> Hash {
  3 * left + 7 * right
}

pub fn dummy_hash_single(element: ByteArray) -> Hash {
  let integer = hex_to_dec(element)
  2 * integer + 5
}
