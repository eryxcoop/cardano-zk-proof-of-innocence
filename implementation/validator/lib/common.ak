use aiken/builtin.{and_bytearray}
use aiken/collection/list.{at}
use aiken/primitive/bytearray.{from_int_big_endian}

pub type OracleDatum {
  merkle_tree_root_hash: Int,
}

pub fn value_at(vector: List<a>, index: Int) -> a {
  expect Some(value) = at(vector, index)
  value
}

pub fn is_power_of_two(number: Int) {
  let number_is_positive = number > 0

  let size_in_bytes = 8
  let bitwise_number = from_int_big_endian(number, size_in_bytes)
  let bitwise_number_minus_one = from_int_big_endian(number - 1, size_in_bytes)
  let bitwise_and_between_number_and_predecessor =
    and_bytearray(False, bitwise_number, bitwise_number_minus_one)
  let number_has_exactly_one_bit_set_to_one =
    bitwise_and_between_number_and_predecessor == from_int_big_endian(
      0,
      size_in_bytes,
    )

  and {
    number_is_positive,
    number_has_exactly_one_bit_set_to_one,
  }
}
