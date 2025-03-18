import { expect, test } from 'vitest'

class MerkleTree {
    constructor(list: number[]) {
        if (list.length == 0) {
            throw new Error("List must not be empty")
        }
    }
}

test ("Cannot calculate root hash from an empty list", () => {
    expect (
        () => new MerkleTree([])     
    ).toThrow("List must not be empty")
})

