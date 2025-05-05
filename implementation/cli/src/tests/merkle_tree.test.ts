import { describe, expect, test } from 'vitest'
import { hash, hashSingleValue, hashPair } from '../common/dummyHash.js'
import { MerkleTree } from '../common/MerkleTree.js'

describe("Merkle tree", () => {
    const list = [1,2,3,4]
    const v1 = list[0]
    const v2 = list[1]
    const v3 = list[2]
    const v4 = list[3]
    const v12 = hashPair(v1,v2) 
    const v34 = hashPair(v3,v4) 
    const v1234 = hashPair(v12,v34)

    test("Cannot create a Merkle tree from an empty list", () => {
        expect(
            () => new MerkleTree([])
        ).toThrow(MerkleTree.emptyListErrorMessage())
    })

    test("Cannot create a Merkle tree from an list with size is not pow of 2", () => {
        expect(
            () => new MerkleTree([1,2,3,4,5,6])
        ).toThrow(MerkleTree.listSizeErrorMessage())
    })

    test("Can calculate the root hash for a list with one element", () => {
        const merkleTree = new MerkleTree([1])

        const root = merkleTree.root()

        const expectedRoot = 1

        expect(root).toEqual(expectedRoot)

    })

    test("Can calculate the root hash for a list with many elements", () => {
        const mkt = new MerkleTree(list)
        const root = mkt.root() 
        expect(root).toEqual(v1234)
    })

    test("Can calculate the authentication path elements for a list with one element", () => {
        const merkleTree = new MerkleTree([1])

        const authenticationPathElements = merkleTree.authenticationPathElementsFor(0)

        const expectedAuthenticationPathElements: hash[] = []

        expect(authenticationPathElements).toEqual(expectedAuthenticationPathElements)
    })

    test("Can calculate the authentication path elements for a list with many elements", () => {
        const mkt = new MerkleTree(list)
        const authenticationPathElements = mkt.authenticationPathElementsFor(1)

        const expectedAuthenticationPathElements = [v1,v34]
        expect(authenticationPathElements).toEqual(expectedAuthenticationPathElements)
    })

    test("Can calculate the authentication path indices for a list with one element", () => {
        const merkleTree = new MerkleTree([1])

        const authenticationPathIndices = merkleTree.authenticationPathIndicesFor(0)

        const expectedAuthenticationPathIndices: hash[] = []

        expect(authenticationPathIndices).toEqual(expectedAuthenticationPathIndices)
    })

    test("Can calculate the authentication path for a list with many elements", () => {
        const mkt = new MerkleTree(list)
        const authenticationPathIndices = mkt.authenticationPathIndicesFor(1)

        const expectedAuthenticationPathIndices = [0, 1]
        expect(authenticationPathIndices).toEqual(expectedAuthenticationPathIndices)
    })
})
