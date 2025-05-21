import { poseidon1, poseidon2 } from "poseidon-bls12381";

export type hash = bigint

export function identity(value: number) {
    return BigInt(value);
}
export function hashSingleValue(value: number) {
    return poseidon1([BigInt(value)]);
}
export function hashPair(left: hash, right: hash) {
    return poseidon2([left, right]);
}
