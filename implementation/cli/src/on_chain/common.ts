
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

export function lovelaceAmountIn(utxo: UTxO): number {
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

export function instantiatePoIContract(wallet: MeshWallet) {
      const paymentKeyHash = paymentKeyHashForWallet(wallet)
      const paymentKeyHashData = (Buffer.from(paymentKeyHash!.to_bytes()).toString('hex'));
      const blueprint = JSON.parse(fs.readFileSync("../validator/plutus.json", "utf-8"));
      const scriptCbor =  applyParamsToScript(blueprint.validators[3].compiledCode, [paymentKeyHashData]);
      return scriptCbor
}

export function oracleTokenAsset(policyId: string, assetName: string) {
      return { unit: policyId + assetName, quantity: "1" }
}

