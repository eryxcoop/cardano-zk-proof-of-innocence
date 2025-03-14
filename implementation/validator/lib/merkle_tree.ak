use aiken/collection/list.{concat, length, slice}
use common.{value_at}
use dummy_hash.{Hash, dummy_hash_pair, dummy_hash_single}

// We assume vectors to have a length that is a power of two

pub type MerkleTreeLeafElement =
  Int

pub type MerkleTreeLeafIndex =
  Int

pub fn merkle_tree_root_for(vector: List<MerkleTreeLeafElement>) -> Hash {
  let length = length(vector)

  when length is {
    0 -> fail
    1 -> {
      let value = value_at(vector, 0)
      dummy_hash_single(value)
    }
    _ -> {
      let half_length = length / 2

      let left_vector = slice(vector, from: 0, to: half_length - 1)
      let right_vector = slice(vector, from: half_length, to: length)

      let left_hash = merkle_tree_root_for(left_vector)
      let right_hash = merkle_tree_root_for(right_vector)
      dummy_hash_pair(left_hash, right_hash)
    }
  }
}

pub fn merkle_tree_authentication_path_for(
  vector: List<MerkleTreeLeafElement>,
  index: MerkleTreeLeafIndex,
) -> List<Hash> {
  let length = length(vector)

  if length == 1 {
    []
  } else {
    let half_length = length / 2

    let left_vector = slice(vector, from: 0, to: half_length - 1)
    let right_vector = slice(vector, from: half_length, to: length)

    if index < half_length {
      let left_vector_authentication_path =
        merkle_tree_authentication_path_for(left_vector, index)
      let right_hash = merkle_tree_root_for(right_vector)

      concat(left_vector_authentication_path, [right_hash])
    } else {
      let left_hash = merkle_tree_root_for(left_vector)
      let right_vector_authentication_path =
        merkle_tree_authentication_path_for(right_vector, index)

      concat([left_hash], right_vector_authentication_path)
    }
  }
}
