import { merkleTreeLeafElement, hash } from './tests/merkle_tree.test.ts';

export function hashSingleValue(value: merkleTreeLeafElement | hash) {
    return value;
}
export function hashPair(left: hash, right: hash) {
    return 3 * left + 7 * right;
}
