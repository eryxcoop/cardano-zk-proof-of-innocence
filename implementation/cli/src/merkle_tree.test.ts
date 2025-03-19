import { expect, test } from 'vitest'

function hashSingleValue(value: number) {
    return value
}

function hashPair(left: number, right: number) {
    return 3 * left + 7 * right
}

function isPowerOfTwo(value: number): boolean {
    return value > 0 && (value & (value - 1)) === 0
}

class MerkleTree {
    private list: number[]

    constructor(list: number[]) {
        if (list.length == 0) {
            throw new Error(MerkleTree.emptyListErrorMessage())
        } else if (!isPowerOfTwo(list.length)) {
            throw new Error(MerkleTree.listSizeErrorMessage())
        } 

        this.list = list
    }

    root(): number {
        if (this.list.length == 1) {
            return hashSingleValue(this.list[0])
        } else {
            return hashPair(this.left().root(), this.right().root())
        }
    }

    authenticationPathFor(): number[] {
        return []
    }

    left() {
        return new MerkleTree(this.list.slice(0,this.halfIndex()))
    }

    right() {
        return new MerkleTree(this.list.slice(this.halfIndex(), this.list.length))
    }

    halfIndex() {
        return this.list.length / 2
    }
 
    static emptyListErrorMessage() {
        return "List must not be empty"
    }

    static listSizeErrorMessage() {
        return "List size must be a power of 2"
    }
}

test("Cannot create merkle tree from an empty list", () => {
    expect(
        () => new MerkleTree([])
    ).toThrow(MerkleTree.emptyListErrorMessage())
})

test("Can calculate root hash for a list with one element", () => {
    const merkleTree = new MerkleTree([1])

    const root = merkleTree.root()

    const expectedRoot = hashSingleValue(1)

    expect(root).toEqual(expectedRoot)

})

test("Can calculate root hash for a list with many elements", () => {
    const list = [1,2,3,4]
    const v1 = hashSingleValue(list[0])
    const v2 = hashSingleValue(list[1])
    const v3 = hashSingleValue(list[2])
    const v4 = hashSingleValue(list[3])
    const v12 = hashPair(v1,v2) 
    const v34 = hashPair(v3,v4) 
    const v1234 = hashPair(v12,v34)

    const mkt = new MerkleTree(list)
    const root = mkt.root() 
    expect(root).toEqual(v1234)
})

test("Cannot create a MKT from an list with size is not pow of 2", () => {
    expect(
        () => new MerkleTree([1,2,3,4,5,6])
    ).toThrow(MerkleTree.listSizeErrorMessage())
})

test("Can calculate authentication path for a list with one element", () => {
    const merkleTree = new MerkleTree([1])

    const authenticationPath = merkleTree.authenticationPathFor([0])

    const expectedAuthenticationPath = []

    expect(authenticationPath).toEqual(expectedAuthenticationPath)
 })
