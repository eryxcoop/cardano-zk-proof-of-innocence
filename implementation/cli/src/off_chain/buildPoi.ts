import { hash } from "../common/dummyHash.js";
// @ts-ignore
import * as snarkjs from "snarkjs";
import { convertProofToUncompressed } from "../common/conversion.js"
import { Asset, conStr, integer, MeshTxBuilder, resolveScriptHash, byteString } from "@meshsdk/core"
import { blockchainProvider, createWallet, instantiatePoIContract, lovelaceAssetIn, oracleTokenAsset, paymentKeyHashForWallet, removeUtxoForCollateralFrom, scriptAddressFor, walletBaseAddress } from "../on_chain/common.js"

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

    // ===== Proof Section =====

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

    // ===== Transaction Section ===== 

    const wallet = await createWallet()
    const walletAddr = walletBaseAddress(wallet)
    const paymentKeyHash = paymentKeyHashForWallet(wallet)

    const scriptCbor = instantiatePoIContract(wallet)
    const scriptAddr = scriptAddressFor(scriptCbor)
    const policyId = resolveScriptHash(scriptCbor, "V3");

    // Todo: Must contain the same datum as the previous utxo. Maybe we can create a function that checks that. 
    const oracleDatum = conStr(0, [conStr(0, [byteString("aabb"), integer(0)]), byteString("aabb")]);

    const wallet_utxos = await wallet.getUtxos()
    const { collateralUtxo, walletUtxosExcludingCollateral} = removeUtxoForCollateralFrom(wallet_utxos)

    // Check: What variable is the transaction ID hash.
    const poiRedeemer = conStr(2, [conStr(0,[ byteString(proof.pi_a.toString()), byteString(proof.pi_b.toString()), byteString(proof.pi_c.toString()) ]), integer(leafIndexHash)])
    

    const outputOracleValue: Asset[] = [
          { unit: "lovelace", quantity: "5000000" },
          { unit: policyId + "6d6173746572", quantity: "1" },
        ];

    const txBuilder = new MeshTxBuilder({
          fetcher: blockchainProvider,
          evaluator: blockchainProvider,
          verbose: true,
    })

    async function poiTokenUtxoFrom(scriptAddress: string, policyId: string) {
          const utxosWithOracleToken = await blockchainProvider.fetchAddressUTxOs(
                scriptAddress,
                oracleTokenAsset(policyId).unit
          );
          return utxosWithOracleToken[0]
    }

    const poiTokenUtxo = await poiTokenUtxoFrom(scriptAddr, policyId)

    const unsignedMintTx = await txBuilder
          .setNetwork("preprod")
          .spendingPlutusScriptV3()
          .txIn(poiTokenUtxo.input.txHash, poiTokenUtxo.input.outputIndex)
          .txInInlineDatumPresent()
          .txInScript(scriptCbor)
          .txInRedeemerValue(poiRedeemer, "JSON")
          .spendingTxInReference("6521fdd0bce90a3dd4b4e90a7d71641faebc03a4ac470109c0fd58593364c233", 0)
          .spendingTxInReference("6521fdd0bce90a3dd4b4e90a7d71641faebc03a4ac470109c0fd58593364c233", 0) // Oracle Merkle Tree Reference Input.
          .selectUtxosFrom(walletUtxosExcludingCollateral)
          .txInCollateral(collateralUtxo.input.txHash, collateralUtxo.input.outputIndex, [lovelaceAssetIn(collateralUtxo)], walletAddr)
          .txOut(scriptAddr, outputOracleValue)
          .txOutInlineDatumValue(oracleDatum, "JSON")
          .changeAddress(walletAddr!)
          .requiredSignerHash(paymentKeyHash!.to_hex())
          .complete()
          

    const signedTx =  await wallet.signTx(unsignedMintTx, true);
    const txHash = await wallet.submitTx(signedTx);
    console.log(txHash);


