export function isPowerOfTwo(value: number): boolean {
    return value > 0 && (value & (value - 1)) === 0;
}
