import * as fs from "fs"

import { Asset, conStr, integer, byteString, list, MeshTxBuilder, resolveScriptHash } from "@meshsdk/core"
import { blockchainProvider, createWallet, instantiateOracleContract, lovelaceAssetIn, oracleTokenAsset, paymentKeyHashForWallet, removeUtxoForCollateralFrom, scriptAddressFor, walletBaseAddress } from "./common.js"
import { convertVerificationKeyToUncompressed } from "../common/conversion.js"


async function buildVerificationKeyDatum() {
    const verificationKeyFilePath = "../circuit/setup/verification_key.json";
    const verificationKey = JSON.parse(fs.readFileSync(verificationKeyFilePath, "utf-8"));

    const convertedVerificationKey = await convertVerificationKeyToUncompressed(verificationKey);
    console.log(convertedVerificationKey)
    
    const datum = conStr(0, [
        integer(2),
        byteString(convertedVerificationKey.vk_alpha_1),
        byteString(convertedVerificationKey.vk_beta_2),
        byteString(convertedVerificationKey.vk_gamma_2),
        byteString(convertedVerificationKey.vk_delta_2),
        list([
            byteString(convertedVerificationKey.vk_alphabeta_12[0]),
            byteString(convertedVerificationKey.vk_alphabeta_12[1]),
        ]),
        list([
            byteString(convertedVerificationKey.IC[0]),
            byteString(convertedVerificationKey.IC[1]),
            byteString(convertedVerificationKey.IC[2]),
        ])
    ]);
    return datum;
}


export async function setVerificationKey () {
    const wallet = await createWallet()
    const walletAddr = walletBaseAddress(wallet)
    const paymentKeyHash = paymentKeyHashForWallet(wallet)

    const verificationKeyDatum = await buildVerificationKeyDatum();

    const wallet_utxos = await wallet.getUtxos()
    const { collateralUtxo, walletUtxosExcludingCollateral} = removeUtxoForCollateralFrom(wallet_utxos)

    const outputVerificationKeyValue: Asset[] = [
          { unit: "lovelace", quantity: "5000000" },
        ];

    const alwaysFalseValidatorAddress = "addr_test1wqvfyy230lq6aet8uq4k3yypn8cglnp8rjuczxgew46halqe5j95m";

    const txBuilder = new MeshTxBuilder({
          fetcher: blockchainProvider,
          evaluator: blockchainProvider,
          verbose: true,
    })

    
    const unsignedTx = await txBuilder
        .setNetwork("preprod")
        .selectUtxosFrom(walletUtxosExcludingCollateral)
        .txInCollateral(collateralUtxo.input.txHash, collateralUtxo.input.outputIndex, [lovelaceAssetIn(collateralUtxo)], walletAddr)
        .txOut(alwaysFalseValidatorAddress, outputVerificationKeyValue)
        .txOutInlineDatumValue(verificationKeyDatum, "JSON")
        .changeAddress(walletAddr!)
        .complete()
          

    const signedTx = await wallet.signTx(unsignedTx, true);
    const txHash = await wallet.submitTx(signedTx);
    console.log("Success! Here's the transaction hash to paste in the verification_key_tx_id value:")
    console.log(txHash);
    process.exit(0)

    //const cliStatus = fs.readFileSync("../../cli_input.json", 'utf-8');
    //const cliStatusObj = JSON.parse(cliStatus);
//
    //cliStatusObj.verification_key_tx_id = txHash;
    //cliStatusObj.verification_key_tx_index = 0;
    //fs.writeFileSync('data.json', JSON.stringify(cliStatusObj, null, 2), 'utf-8');
}