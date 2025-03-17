use aiken/collection/list.{slice}
use common.{value_at}
use dummy_hash.{Hash, dummy_hash_pair, dummy_hash_single}
use merkle_tree.{merkle_tree_authentication_path_for, merkle_tree_root_for}

const vector = [1, 2, 3, 4]

const vector_with_size_that_is_not_power_of_two = [1, 2, 3]

fn vector_with_one_element() {
  slice(vector, from: 0, to: 0)
}

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

test test_merkle_tree_root_cannot_be_calculated_when_list_is_empty() fail {
  let root = merkle_tree_root_for([])

  root == root
  // For the line above to be executed
}

test test_merkle_tree_root_cannot_be_calculated_when_list_size_is_not_a_power_of_two() fail {
  let root = merkle_tree_root_for(vector_with_size_that_is_not_power_of_two)

  root == root
  // For the line above to be executed
}

test test_merkle_tree_root_is_correctly_calculated_for_a_tree_with_one_level() {
  let root = merkle_tree_root_for(vector_with_one_element())

  let expected_root = hash_1()
  root == expected_root
}

test test_merkle_tree_root_is_correctly_calculated_for_a_tree_with_many_levels() {
  let root = merkle_tree_root_for(vector)

  let expected_root = hash_1234()
  root == expected_root
}

test test_merkle_tree_authentication_path_cannot_be_calculated_when_list_is_empty() fail {
  let index = 0
  let authentication_path = merkle_tree_authentication_path_for([], index)

  authentication_path == authentication_path
  // For the line above to be executed
}

test test_merkle_tree_authentication_path_is_correctly_calculated_for_a_tree_with_one_level() {
  let index = 0
  let authentication_path =
    merkle_tree_authentication_path_for(vector_with_one_element(), index)

  let expected_authentication_path = []
  authentication_path == expected_authentication_path
}

test test_merkle_tree_authentication_path_is_correctly_calculated_for_a_tree_with_many_levels() {
  let index = 0
  let authentication_path = merkle_tree_authentication_path_for(vector, index)

  let expected_authentication_path = [hash_2(), hash_34()]
  authentication_path == expected_authentication_path
}
