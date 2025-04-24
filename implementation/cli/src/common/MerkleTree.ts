import { hash, hashSingleValue, hashPair } from './dummyHash.js';

function isPowerOfTwo(value: number): boolean {
    return value > 0 && (value & (value - 1)) === 0;
}

type merkleTreeLeafElement = number;
type merkleTreeLeafIndex = number;
export class MerkleTree {
    private list: merkleTreeLeafElement[];

    constructor(list: merkleTreeLeafElement[]) {
        if (list.length == 0) {
            throw new Error(MerkleTree.emptyListErrorMessage());
        } else if (!isPowerOfTwo(list.length)) {
            throw new Error(MerkleTree.listSizeErrorMessage());
        }

        this.list = list;
    }

    root(): hash {
        if (this.size() == 1) {
            return hashSingleValue(this.list[0]);
        } else {
            return hashPair(this.left().root(), this.right().root());
        }
    }

    authenticationPathElementsFor(index: merkleTreeLeafIndex): hash[] {
        if (this.size() == 1) {
            return [];
        } else {
            if (index < this.halfIndex()) {
                return this.left().authenticationPathElementsFor(index)
                    .concat([this.right().root()]);
            } else {
                return [this.left().root()]
                    .concat(this.right().authenticationPathElementsFor(index));
            }
        }
    }

    authenticationPathIndicesFor(index: merkleTreeLeafIndex): hash[] {
        if (this.size() == 1) {
            return [];
        } else {
            if (index < this.halfIndex()) {
                return this.left().authenticationPathIndicesFor(index)
                    .concat([1]);
            } else {
                return [0]
                    .concat(this.right().authenticationPathIndicesFor(index));
            }
        }
    }

    left() {
        return new MerkleTree(
            this.list.slice(0, this.halfIndex())
        );
    }

    right() {
        return new MerkleTree(
            this.list.slice(this.halfIndex(), this.size())
        );
    }

    halfIndex() {
        return this.list.length / 2;
    }

    size() {
        return this.list.length;
    }

    static emptyListErrorMessage() {
        return "List must not be empty";
    }

    static listSizeErrorMessage() {
        return "List size must be a power of 2";
    }
}
