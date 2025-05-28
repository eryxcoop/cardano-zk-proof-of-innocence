import * as fs from "fs"
import { hash } from "../common/dummyHash.js";
// @ts-ignore
import * as snarkjs from "snarkjs";
import { convertProofToUncompressed } from "../common/conversion.js"
import { Asset, conStr, integer, MeshTxBuilder, resolveScriptHash, byteString } from "@meshsdk/core"
import { blockchainProvider, createWallet, instantiatePoIContract, instantiateOracleContract, lovelaceAssetIn, oracleTokenAsset, paymentKeyHashForWallet, removeUtxoForCollateralFrom, scriptAddressFor, walletBaseAddress } from "../on_chain/common.js"
import { verify } from "crypto";
import { UTxO } from "@lucid-evolution/lucid";
//import { console } from "inspector";

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


async function verifyProof(
    verificationKey: any,
    inputs: any,
    proof: any
  ): Promise<boolean> {
    try {
      const isValid = await snarkjs.groth16.verify(
        verificationKey,
        [inputs.root, inputs.leafIndexHash],
        proof
      );
  
      if (isValid) {
        console.log("✅ Prueba verificada correctamente");
        return true;
      } else {
        console.warn("❌ La prueba NO es válida");
        return false;
      }
    } catch (error) {
      console.error("⚠️ Error al verificar la prueba:", error);
      return false;
    }
}


export async function buildPoi(oracleMerkleTreeRootHash: hash, leafIndexHash: hash, pathElements: hash[], pathIndices: number[], leafIndex: number, tokenName: string, oracle_tx_id: string, oracle_tx_index: number, verification_key_tx_id: string, verification_key_tx_index: number ) {

    // ===== Proof Section =====
    console.log("Help")
    const levels = pathElements.length

    const inputs = {
        // Public inputs
        root: oracleMerkleTreeRootHash,
        leafIndexHash: leafIndexHash,
    
        // Private inputs
        pathElements: pathElements,
        pathIndices: pathIndices,
        leafIndex: leafIndex,
    }

    console.log("===================================================================================================***********", inputs.leafIndexHash)

    const wasmFilePath = `../circuit/setup/proof_of_innocence_js/proof_of_innocence.wasm`
    const privateKeyFilePath = `../circuit/setup/proof_of_innocence_final.zkey`

    const { proof }: { proof: SnarkJSProof } = await snarkjs.groth16.fullProve(
        inputs,
        wasmFilePath,
        privateKeyFilePath
    );

    const verificationKeyFilePath = "../circuit/setup/verification_key.json";
    const verificationKey = JSON.parse(fs.readFileSync(verificationKeyFilePath, "utf-8"));

    verifyProof(verificationKey, inputs, proof)

    const convertedProof = await convertProofToUncompressed(proof); 
    console.log(convertedProof)

    // ===== Transaction Section ===== 

    const wallet = await createWallet()
    const walletAddr = walletBaseAddress(wallet)
    const paymentKeyHash = paymentKeyHashForWallet(wallet)

    const scriptCbor = instantiatePoIContract(wallet)
    const scriptAddr = scriptAddressFor(scriptCbor)
    const policyId = resolveScriptHash(scriptCbor, "V3");

    const oracleScriptCbor = instantiateOracleContract(wallet)
    const oraclePolicyId = resolveScriptHash(oracleScriptCbor, "V3");

    // Todo: Must contain the same datum as the previous utxo. Maybe we can create a function that checks that. 
    const poiDatum = conStr(0, [conStr(0, [byteString(verification_key_tx_id), integer(verification_key_tx_index)]), byteString(oraclePolicyId)]);


    const wallet_utxos = await wallet.getUtxos()
    const { collateralUtxo, walletUtxosExcludingCollateral} = removeUtxoForCollateralFrom(wallet_utxos)


    const poiRedeemer = conStr(2, [conStr(0,[ byteString(convertedProof.pi_a.toString()), byteString(convertedProof.pi_b.toString()), byteString(convertedProof.pi_c.toString()) ]), integer(leafIndexHash)])
    

    const outputPoiValue: Asset[] = [
          { unit: "lovelace", quantity: "5000000" },
          { unit: policyId + tokenName, quantity: "1" },
        ];

    const txBuilder = new MeshTxBuilder({
          fetcher: blockchainProvider,
          evaluator: blockchainProvider,
          verbose: true,
    })

    async function poiTokenUtxoFrom(scriptAddress: string, policyId: string) {
          const utxosWithOracleToken = await blockchainProvider.fetchAddressUTxOs(
                scriptAddress,
                oracleTokenAsset(policyId, tokenName).unit
          );
          return utxosWithOracleToken[0]
    }

    const poiTokenUtxo = await poiTokenUtxoFrom(scriptAddr, policyId)
    console.log(poiTokenUtxo)

    const unsignedMintTx = await txBuilder
          .setNetwork("preprod")
          .spendingPlutusScriptV3()
          .txIn(poiTokenUtxo.input.txHash, poiTokenUtxo.input.outputIndex)
          .txInInlineDatumPresent()
          .txInScript(scriptCbor)
          .txInRedeemerValue(poiRedeemer, "JSON")
          .readOnlyTxInReference(verification_key_tx_id, verification_key_tx_index)
          .readOnlyTxInReference(oracle_tx_id, oracle_tx_index)
          .selectUtxosFrom(walletUtxosExcludingCollateral)
          .txInCollateral(collateralUtxo.input.txHash, collateralUtxo.input.outputIndex, [lovelaceAssetIn(collateralUtxo)], walletAddr)
          .txOut(scriptAddr, outputPoiValue)
          .txOutInlineDatumValue(poiDatum, "JSON")
          .changeAddress(walletAddr!)
          .complete()
          

    const signedTx =  await wallet.signTx(unsignedMintTx, true);
    const txHash = await wallet.submitTx(signedTx);
    console.log(txHash);
    process.exit(0)
}

