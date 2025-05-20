import * as fs from "fs"

import { Asset, byteString, conStr, integer, MeshTxBuilder, resolveScriptHash } from "@meshsdk/core"
import { blockchainProvider, createWallet, instantiatePoIContract, lovelaceAssetIn, oracleTokenAsset, paymentKeyHashForWallet, removeUtxoForCollateralFrom, scriptAddressFor, walletBaseAddress } from "./common.js"

export async function instantiatePoi() {
    const wallet = await createWallet()

    const walletAddr = walletBaseAddress(wallet)
    const paymentKeyHash = paymentKeyHashForWallet(wallet)

    const scriptCbor = instantiatePoIContract(wallet)
    const scriptAddr = scriptAddressFor(scriptCbor)

    // console.log("Script Address: " + scriptAddr); 

    // Todo: Right now we'll use a dummy value hash to define the datum, but in the future we will need to create a roothash and make it an integer compatible with ak_381.grothverify() function.
    const poiDatum = conStr(0, [conStr(0, [byteString("6521fdd0bce90a3dd4b4e90a7d71641faebc03a4ac470109c0fd58593364c233"), integer(0)]), byteString("d0b9639d6365a7bad5d1af3c8d59cc902e1c810188ee0d4c34748918")]);
    const policyId = resolveScriptHash(scriptCbor, "V3");
    console.log("Script policyId: " + policyId);

    const poiRedeemer = conStr(0, []);

    const txBuilder = new MeshTxBuilder({
          fetcher: blockchainProvider,
          evaluator: blockchainProvider,
          verbose: true,
    })

    const wallet_utxos = await wallet.getUtxos()

   
    const mint_oracle_value: Asset[] = [
          { unit: "lovelace", quantity: "5000000" },
          oracleTokenAsset(policyId, "746573743"),
    ];

    const { collateralUtxo, walletUtxosExcludingCollateral} = removeUtxoForCollateralFrom(wallet_utxos)

    const unsignedMintTx = await txBuilder
          .setNetwork("preprod")
          .mintPlutusScriptV3()
          .mint("1", policyId, "7465737433")
          .mintingScript(scriptCbor)
          .mintRedeemerValue(poiRedeemer, "JSON")
          .selectUtxosFrom(walletUtxosExcludingCollateral)
          .txInCollateral(collateralUtxo.input.txHash, collateralUtxo.input.outputIndex, [lovelaceAssetIn(collateralUtxo)], walletAddr)
          .txOut(scriptAddr, mint_oracle_value)
          .txOutInlineDatumValue(poiDatum, "JSON")
          .changeAddress(walletAddr!)
          .requiredSignerHash(paymentKeyHash!.to_hex())
          .complete()

    const signedTx =  await wallet.signTx(unsignedMintTx, true);
    const txHash = await wallet.submitTx(signedTx);
    console.log(txHash);         
}