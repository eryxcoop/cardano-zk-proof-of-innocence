import { describe, expect, test } from 'vitest'
import { hash, hashSingleValue, hashPair } from '../dummyHash.js'
import { MerkleTree } from '../MerkleTree.js'

describe("Merkle tree", () => {
    const list = [1,2,3,4]
    const v1 = hashSingleValue(list[0])
    const v2 = hashSingleValue(list[1])
    const v3 = hashSingleValue(list[2])
    const v4 = hashSingleValue(list[3])
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

        const expectedRoot = hashSingleValue(1)

        expect(root).toEqual(expectedRoot)

    })

    test("Can calculate the root hash for a list with many elements", () => {
        const mkt = new MerkleTree(list)
        const root = mkt.root() 
        expect(root).toEqual(v1234)
    })

    test("Can calculate the authentication path for a list with one element", () => {
        const merkleTree = new MerkleTree([1])

        const authenticationPath = merkleTree.authenticationPathFor(0)

        const expectedAuthenticationPath: hash[] = []

        expect(authenticationPath).toEqual(expectedAuthenticationPath)
    })

    test("Can calculate the authentication path for a list with many elements", () => {
        const mkt = new MerkleTree(list)
        const authenticationPath = mkt.authenticationPathFor(1)

        const expectedAuthenticationPath = [v1,v34]
        expect(authenticationPath).toEqual(expectedAuthenticationPath)
    })
})
