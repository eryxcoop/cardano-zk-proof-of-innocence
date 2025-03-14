use aiken/collection/list.{length, slice}
use common.{value_at}
use dummy_hash.{Hash, dummy_hash_pair, dummy_hash_single}

pub type MerkleTreeLeafPresence =
  Int

pub type MerkleTreeLeafIndex =
  Int

pub fn merkle_tree_root_for(vector) -> Hash {
  // We assume vectors to have a length that is a power of two
  let length = length(vector)

  if length == 1 {
    let value = value_at(vector, 0)
    dummy_hash_single(value)
  } else {
    let half_length = length / 2
    let left_vector = slice(vector, from: 0, to: half_length - 1)
    let right_vector = slice(vector, from: half_length, to: length)
    let left_hash = merkle_tree_root_for(left_vector)
    let right_hash = merkle_tree_root_for(right_vector)
    dummy_hash_pair(left_hash, right_hash)
  }
}
