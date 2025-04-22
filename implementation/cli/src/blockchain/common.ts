
import dotenv from 'dotenv';
import { integer, BlockfrostProvider, MeshWallet, serializePlutusScript, conStr, MeshTxBuilder, resolveScriptHash, Asset} from '@meshsdk/core';
import { applyParamsToScript, skeyToPubKeyHash, toPlutusData, deserializeAddress } from "@meshsdk/core-csl";
import { Address, Int } from '@emurgo/cardano-serialization-lib-nodejs';
import { UTxO } from "@meshsdk/common"
import fs, { read } from 'fs';
import { error } from 'console';

// Create enviroment variables

dotenv.config();
const secretKey: string = process.env.WALLET_SECREY_KEY || "nothing";
const mnemonic =  secretKey.split(" ");
const apiKey: string = process.env.API_KEY || "nothing";

export const blockchainProvider = new BlockfrostProvider(apiKey);

export async function createWallet() {
      const wallet =  new MeshWallet({
            networkId: 0, 
            fetcher: blockchainProvider,
            submitter: blockchainProvider,
            key: {
              type: 'mnemonic',
              words: mnemonic,
            },
      });  

      await wallet.init()
      return wallet
}

export function walletBaseAddress(wallet: MeshWallet) {
      return wallet.getAddresses().baseAddressBech32
}

export function paymentKeyHashForWallet(wallet: MeshWallet) {
      const walletAddr = walletBaseAddress(wallet)
      const pubKeyHash = Address.from_bech32(walletAddr!);
      return pubKeyHash!.payment_cred()!.to_keyhash();
}

export function scriptAddressFor(sciptCbor: string) {
      return serializePlutusScript(
            { code: sciptCbor, version: "V3" },
            undefined,
            0
      ).address;
}

export function removeUtxoForCollateralFrom(utxoList: UTxO[]) {
      const collateralValueThreshold = 5000000
      let selectedUtxo = utxoList[0]
      let selectedUtxoValue = lovelaceAmountIn(selectedUtxo)

      for (let index = 1; index < utxoList.length; index++) {
            const utxo = utxoList[index]   
            const value = lovelaceAmountIn(utxo)
            if (value >= collateralValueThreshold && value <= selectedUtxoValue) {
                  selectedUtxo = utxo
                  selectedUtxoValue = value
            }
      } 
      
      const walletUtxosExcludingCollateral = utxoList.filter( 
            (utxo) => utxo !== selectedUtxo
      )
      
      return {
            collateralUtxo: selectedUtxo,
            walletUtxosExcludingCollateral
      } 
}

export function lovelaceAssetIn(utxo: UTxO): Asset {
      const assets: Asset[] = utxo.output.amount
      return assets.find(
            (asset) => asset.unit == "lovelace"
      )!
}

function lovelaceAmountIn(utxo: UTxO): number {
      const lovelaceAsset = lovelaceAssetIn(utxo)
      return Number(lovelaceAsset.quantity)
}

/* Oracle */

export function instantiateOracleContract(wallet: MeshWallet) {
      const paymentKeyHash = paymentKeyHashForWallet(wallet)
      const paymentKeyHashData = (Buffer.from(paymentKeyHash!.to_bytes()).toString('hex'));
      const blueprint = JSON.parse(fs.readFileSync("../validator/plutus.json", "utf-8"));
      const scriptCbor =  applyParamsToScript(blueprint.validators[0].compiledCode, [paymentKeyHashData]);
      return scriptCbor
}

export function oracleTokenAsset(policyId: string) {
      return { unit: policyId + "6d6173746572", quantity: "1" }
}

/***********************/

async function instantiateOracle() {
      const wallet = await createWallet()

      const walletAddr = walletBaseAddress(wallet)
      const paymentKeyHash = paymentKeyHashForWallet(wallet)

      const scriptCbor = instantiateOracleContract(wallet)
      const scriptAddr = scriptAddressFor(scriptCbor)

      // console.log("Script Address: " + scriptAddr); 


      // Todo: Right now we'll use a dummy value hash to define the datum, but in the future we will need to create a roothash and make it an integer compatible with ak_381.grothverify() function.
      const oracleDatum = conStr(0, [integer(0)]);
      const policyId = resolveScriptHash(scriptCbor, "V3");
      console.log("Script policyId: " + policyId);

      const oracleRedeemer = integer(0);

      const txBuilder = new MeshTxBuilder({
            fetcher: blockchainProvider,
            evaluator: blockchainProvider,
            verbose: true,
      })

      const wallet_utxos = await wallet.getUtxos()

     
      const mint_oracle_value: Asset[] = [
            { unit: "lovelace", quantity: "5000000" },
            oracleTokenAsset(policyId),
          ];

      const { collateralUtxo, walletUtxosExcludingCollateral} = removeUtxoForCollateralFrom(wallet_utxos)

      const unsignedMintTx = await txBuilder
            .setNetwork("preprod")
            .mintPlutusScriptV3()
            .mint("1", policyId, "6d6173746572")
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


