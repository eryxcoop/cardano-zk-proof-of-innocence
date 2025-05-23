import { Asset, byteString, conStr, integer, MeshTxBuilder, resolveScriptHash } from "@meshsdk/core"
import { blockchainProvider, createWallet, instantiatePoIContract, instantiateOracleContract, lovelaceAssetIn, oracleTokenAsset, paymentKeyHashForWallet, removeUtxoForCollateralFrom, scriptAddressFor, walletBaseAddress } from "./common.js"



export async function instantiatePoi(poi_token_name: string, verification_key_tx_id: string, verification_key_tx_index: number) {
    const wallet = await createWallet()

    const walletAddr = walletBaseAddress(wallet)
    const paymentKeyHash = paymentKeyHashForWallet(wallet)

    const scriptCbor = instantiatePoIContract(wallet)
    const scriptAddr = scriptAddressFor(scriptCbor)

    const oracleScriptCbor = instantiateOracleContract(wallet)
    const oraclePolicyId = resolveScriptHash(oracleScriptCbor, "V3");


    // Todo: Right now we'll use a dummy value hash to define the datum, but in the future we will need to create a roothash and make it an integer compatible with ak_381.grothverify() function.
    const poiDatum = conStr(0, [conStr(0, [byteString(verification_key_tx_id), integer(verification_key_tx_index)]), byteString(oraclePolicyId)]);
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
          oracleTokenAsset(policyId, poi_token_name),
    ];

    const { collateralUtxo, walletUtxosExcludingCollateral} = removeUtxoForCollateralFrom(wallet_utxos)

    const unsignedMintTx = await txBuilder
          .setNetwork("preprod")
          .mintPlutusScriptV3()
          .mint("1", policyId, poi_token_name)
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