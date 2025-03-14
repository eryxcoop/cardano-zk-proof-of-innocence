use aiken/collection/list.{at}

pub type OracleDatum {
  merkle_tree_root_hash: Int,
}

pub fn value_at(vector: List<a>, index: Int) -> a {
  expect Some(value) = at(vector, index)
  value
}
