import { hash } from "../common/dummyHash.js";
// @ts-ignore
import * as snarkjs from "snarkjs";
import { convertProofToUncompressed } from "../common/conversion.js"



export type SnarkJSProof = {
    pi_a: Array<string>;
    pi_b: Array<Array<string>>;
    pi_c: Array<string>;
};

export type CardanoSnarkProof = {
    pi_a: Array<string>;
    pi_b: Array<Array<string>>;
    pi_c: Array<string>;
};


export async function buildPoi(oracleMerkleTreeRootHash: hash, leafIndexHash: hash, pathElements: hash[], pathIndices: number[], leafIndex: number) {
    const levels = 2

    const inputs = {
        // Public inputs
        root: oracleMerkleTreeRootHash,
        leafIndexHash: leafIndexHash,

        // Private inputs
        pathElements: pathElements,
        pathIndices: pathIndices,
        leafIndex: leafIndex,
    }

    const wasmFilePath = `../circuit/setup/proof_of_innocence_js/proof_of_innocence.wasm`
    const privateKeyFilePath = `../circuit/setup/proof_of_innocence_final.zkey`

    const { proof }: { proof: SnarkJSProof } = await snarkjs.groth16.fullProve(
        inputs,
        wasmFilePath,
        privateKeyFilePath
    );

    console.log(proof.pi_a)
    const convertedProof = await convertProofToUncompressed(proof);

    process.exit(0);
}


