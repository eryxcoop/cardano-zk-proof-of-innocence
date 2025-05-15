import { Asset, conStr, integer, MeshTxBuilder, resolveScriptHash } from "@meshsdk/core"
import { blockchainProvider, createWallet, instantiateOracleContract, lovelaceAssetIn, oracleTokenAsset, paymentKeyHashForWallet, removeUtxoForCollateralFrom, scriptAddressFor, walletBaseAddress } from "./common.js"

export async function instantiateOracle() {
    const wallet = await createWallet()

    const walletAddr = walletBaseAddress(wallet)
    const paymentKeyHash = paymentKeyHashForWallet(wallet)

    const scriptCbor = instantiateOracleContract(wallet)
    const scriptAddr = scriptAddressFor(scriptCbor)

    // console.log("Script Address: " + scriptAddr); 


    // Todo: Right now we'll use a dummy value hash to define the datum, but in the future we will need to create a roothash and make it an integer compatible with ak_381.grothverify() function.
    const oracleDatum = conStr(0, [integer(79)]);
    const policyId = resolveScriptHash(scriptCbor, "V3");
    console.log("Script policyId: " + policyId);

    const oracleRedeemer = integer(0);

    const txBuilder = new MeshTxBuilder({
          fetcher: blockchainProvider,
          evaluator: blockchainProvider,
          verbose: true,
    })

    const wallet_utxos = await wallet.getUtxos()
    console.log(wallet_utxos)

   
    const mint_oracle_value: Asset[] = [
          { unit: "lovelace", quantity: "5000000" },
          oracleTokenAsset(policyId, "7465737431"),
        ];

    const { collateralUtxo, walletUtxosExcludingCollateral} = removeUtxoForCollateralFrom(wallet_utxos)

    const unsignedMintTx = await txBuilder
          .setNetwork("preprod")
          .mintPlutusScriptV3()
          .mint("1", policyId, "7465737431")
          .mintingScript(scriptCbor)
          .mintRedeemerValue(oracleRedeemer, "JSON")
          .selectUtxosFrom(walletUtxosExcludingCollateral)
          .txInCollateral(collateralUtxo.input.txHash, collateralUtxo.input.outputIndex, [lovelaceAssetIn(collateralUtxo)], walletAddr)
          .txOut(scriptAddr, mint_oracle_value)
          .txOutInlineDatumValue(oracleDatum, "JSON")
          .changeAddress(walletAddr!)
          .requiredSignerHash(paymentKeyHash!.to_hex())
          .complete()

    const signedTx =  await wallet.signTx(unsignedMintTx, true);
    const txHash = await wallet.submitTx(signedTx);
    console.log(txHash);
}
