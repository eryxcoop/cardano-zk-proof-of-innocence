use common.{value_at}
use dummy_hash.{Hash, dummy_hash_pair, dummy_hash_single}
use merkle_tree.{merkle_tree_authentication_path_for, merkle_tree_root_for}

const vector = [1, 2, 3, 4]

fn hash_1() -> Hash {
  dummy_hash_single(value_at(vector, 0))
}

fn hash_2() -> Hash {
  dummy_hash_single(value_at(vector, 1))
}

fn hash_3() -> Hash {
  dummy_hash_single(value_at(vector, 2))
}

fn hash_4() -> Hash {
  dummy_hash_single(value_at(vector, 3))
}

fn hash_12() -> Hash {
  dummy_hash_pair(hash_1(), hash_2())
}

fn hash_34() -> Hash {
  dummy_hash_pair(hash_3(), hash_4())
}

fn hash_1234() -> Hash {
  dummy_hash_pair(hash_12(), hash_34())
}

test test_correctly_calculate_merkle_tree_root() {
  let root = merkle_tree_root_for(vector)

  let expected_root = hash_1234()
  root == expected_root
}

test test_correctly_calculate_merkle_tree_authentication_path_for_index() {
  let index = 0
  let authentication_path = merkle_tree_authentication_path_for(vector, index)

  let expected_authentication_path = [hash_2(), hash_34()]
  authentication_path == expected_authentication_path
}
