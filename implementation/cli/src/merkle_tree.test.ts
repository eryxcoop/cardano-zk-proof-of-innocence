import { expect, test } from 'vitest'

function hashSingleValue(value: number) {
    return value
}

class MerkleTree {
    private list: number[]

    constructor(list: number[]) {
        if (list.length == 0) {
            throw new Error("List must not be empty")
        }

        this.list = list
    }

    root() {
        return hashSingleValue(this.list[0])
    }
}

test ("Cannot calculate root hash from an empty list", () => {
    expect (
        () => new MerkleTree([])     
    ).toThrow("List must not be empty")
})

test ("Can calculate root hash for a list with one element", () => {
    const merkleTree = new MerkleTree([1])

    const root = merkleTree.root()

    const expectedRoot = hashSingleValue(1)

    expect (root).toEqual(expectedRoot)    

})

