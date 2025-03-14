use aiken/collection/list.{concat, length, slice}
use common.{value_at}
use dummy_hash.{Hash, dummy_hash_pair, dummy_hash_single}

// We assume vectors to have a length that is a power of two

pub type MerkleTreeLeafElement =
  Int

pub type MerkleTreeLeafIndex =
  Int

const length_is_zero_error_message = @"Length must be greater than zero"

fn left_part_of(vector: List<a>) -> List<a> {
  let half_length = length(vector) / 2

  slice(vector, from: 0, to: half_length - 1)
}

fn right_part_of(vector: List<a>) -> List<a> {
  let length = length(vector)
  let half_length = length / 2
  
  slice(vector, from: half_length, to: length)
}

pub fn merkle_tree_root_for(vector: List<MerkleTreeLeafElement>) -> Hash {
  let length = length(vector)

  when length is {
    0 -> fail length_is_zero_error_message
    1 -> {
      let value = value_at(vector, 0)
      dummy_hash_single(value)
    }
    _ -> {
      let left_vector = left_part_of(vector)
      let right_vector = right_part_of(vector)

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

  when length is {
    0 -> fail length_is_zero_error_message
    1 -> []
    _ -> {
      let left_vector = left_part_of(vector)
      let right_vector = right_part_of(vector)
      let half_length = length / 2

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
}
