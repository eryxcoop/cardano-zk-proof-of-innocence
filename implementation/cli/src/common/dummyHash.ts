export type hash = number

export function hashSingleValue(value: hash) {
    return 2 * value + 5;
}
export function hashPair(left: hash, right: hash) {
    return 3 * left + 7 * right;
}
