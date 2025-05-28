import { Asset, conStr, integer, MeshTxBuilder, resolveScriptHash } from "@meshsdk/core"
import { blockchainProvider, createWallet, instantiateOracleContract, lovelaceAssetIn, oracleTokenAsset, paymentKeyHashForWallet, removeUtxoForCollateralFrom, scriptAddressFor, walletBaseAddress } from "./common.js"


export async function updateOracle(new_merkle_root: number, oracle_token_name: string) {
    const wallet = await createWallet()
    const walletAddr = walletBaseAddress(wallet)
    const paymentKeyHash = paymentKeyHashForWallet(wallet)

    const scriptCbor = instantiateOracleContract(wallet)
    const scriptAddr = scriptAddressFor(scriptCbor)
    const policyId = resolveScriptHash(scriptCbor, "V3");

    const oracleDatum = conStr(0, [integer(new_merkle_root)]);

    const wallet_utxos = await wallet.getUtxos()
    const { collateralUtxo, walletUtxosExcludingCollateral} = removeUtxoForCollateralFrom(wallet_utxos)

    const oracleRedeemer = integer(0);
    const outputOracleValue: Asset[] = [
          { unit: "lovelace", quantity: "5000000" },
          { unit: policyId + oracle_token_name, quantity: "1" },
        ];

    const txBuilder = new MeshTxBuilder({
          fetcher: blockchainProvider,
          evaluator: blockchainProvider,
          verbose: true,
    })

    async function oracleTokenUtxoFrom(scriptAddress: string, policyId: string) {
          const utxosWithOracleToken = await blockchainProvider.fetchAddressUTxOs(
                scriptAddress,
                oracleTokenAsset(policyId, oracle_token_name).unit
          );
          return utxosWithOracleToken[0]
    }

    const oracleTokenUtxo = await oracleTokenUtxoFrom(scriptAddr, policyId)

    const unsignedMintTx = await txBuilder
          .setNetwork("preprod")
          .spendingPlutusScriptV3()
          .txIn(oracleTokenUtxo.input.txHash, oracleTokenUtxo.input.outputIndex)
          .txInInlineDatumPresent()
          .txInScript(scriptCbor)
          .txInRedeemerValue(oracleRedeemer, "JSON")
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
    process.exit(0)

    // Obtener el código del validador

    // Generar Datum (Definir a 1)
}
