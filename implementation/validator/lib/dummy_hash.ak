pub type Hash =
  Int

pub fn dummy_hash_pair(left: Hash, right: Hash) -> Hash {
  3 * left + 7 * right
}

pub fn dummy_hash_single(element: Hash) -> Hash {
  2 * element + 5
}
