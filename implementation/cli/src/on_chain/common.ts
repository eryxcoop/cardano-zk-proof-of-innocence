
import dotenv from 'dotenv';
import { integer, BlockfrostProvider, MeshWallet, serializePlutusScript, conStr, MeshTxBuilder, resolveScriptHash, Asset} from '@meshsdk/core';
import { applyParamsToScript, skeyToPubKeyHash, toPlutusData, deserializeAddress } from "@meshsdk/core-csl";
import { Address, Int } from '@emurgo/cardano-serialization-lib-nodejs';
import { Dict, UTxO } from "@meshsdk/common"
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

function cborOfValidatorWith(name: string, purpose: string) {
      const blueprint = JSON.parse(fs.readFileSync("../validator/plutus.json", "utf-8"));
      // TODO: define the type for the parameter
      const validatorWithName = blueprint.validators.find((validator: any) => {
            const title = name + "." + name + "." + purpose;
            return validator.title == title;
      })
      return validatorWithName;
}

function instantiateContract(wallet: MeshWallet, name: string) {
      const paymentKeyHash = paymentKeyHashForWallet(wallet)
      const paymentKeyHashData = (Buffer.from(paymentKeyHash!.to_bytes()).toString('hex'));
      const validator = cborOfValidatorWith(name, "spend");
      const scriptCbor =  applyParamsToScript(validator.compiledCode, [paymentKeyHashData]);
      return scriptCbor
}

export function instantiateOracleContract(wallet: MeshWallet) {
      return instantiateContract(wallet, "oracle");
}

export function instantiatePoIContract(wallet: MeshWallet) {
      return instantiateContract(wallet, "proof_of_innocence");
}

export function oracleTokenAsset(policyId: string, assetName: string) {
      return { unit: policyId + assetName, quantity: "1" }
}

export function textToHex(text: string): string {
      return Array.from(text)
          .map(character => character.charCodeAt(0).toString(16).padStart(2, '0'))
          .join('');
}

