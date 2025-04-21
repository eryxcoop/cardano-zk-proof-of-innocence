#!/usr/bin/env node
//import { intro } from './intro.js';
import dotenv from 'dotenv';
import { integer, BlockfrostProvider, MeshWallet, serializePlutusScript, conStr, MeshTxBuilder, resolveScriptHash, Asset,} from '@meshsdk/core';
import { applyParamsToScript, skeyToPubKeyHash, toPlutusData, deserializeAddress } from "@meshsdk/core-csl";
import { Address, Int } from '@emurgo/cardano-serialization-lib-nodejs';
import { UTxO } from "@meshsdk/common"
import fs, { read } from 'fs';
import { error } from 'console';


//const privatekey = MeshWallet.brew(true);
//console.log(privatekey);


// Display intro
//console.log(intro);

// Create enviroment variables

dotenv.config();
const secretKey: string = process.env.WALLET_SECREY_KEY || "nothing";
const mnemonic =  secretKey.split(" ");
console.log(mnemonic)
const apiKey: string = process.env.API_KEY || "nothing";


// =================================== Preliminaries ===================================

/*
1. Create sk.
2. Create Provider.
3. Create wallet.
4. Import the Oracle script.
5. Import the PoI script.
*/


const blockchainProvider = new BlockfrostProvider(apiKey);


const wallet_1 = new MeshWallet({
    networkId: 0, 
    fetcher: blockchainProvider,
    submitter: blockchainProvider,
    key: {
      type: 'mnemonic',
      words: mnemonic,
    },
});



async function initializeWallet(wallet: MeshWallet) {
      await wallet.init()
      console.log(wallet.getAddresses())
      const balance = await wallet.getUtxos()
      console.log(balance)
}

function lovelaceAmountIn(utxo: UTxO): number {
      const lovelaceAsset = lovelaceAssetIn(utxo)
      return Number(lovelaceAsset.quantity)
}

function lovelaceAssetIn(utxo: UTxO): Asset {
      const assets: Asset[] = utxo.output.amount
      return assets.find(
            (asset) => asset.unit == "lovelace"
      )!
}

function removeUtxoForCollateralFrom(utxoList: UTxO[]) {
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
      
      const utxoListExcludingCollateral = utxoList.filter( 
            (utxo) => utxo !== selectedUtxo
      )
      
      return {
            collateralUtxo: selectedUtxo,
            utxoListExcludingCollateral
      } 
}



async function instantiateOracle(wallet: MeshWallet) {
      await initializeWallet(wallet)

      const walletAddr = wallet.getAddresses().baseAddressBech32
      const pubKeyHash = Address.from_bech32(walletAddr!);
      const paymentKeyHash = pubKeyHash!.payment_cred()!.to_keyhash();

      const paymentKeyHashData = (Buffer.from(paymentKeyHash!.to_bytes()).toString('hex'));
      
      const blueprint = JSON.parse(fs.readFileSync("../validator/plutus.json", "utf-8"));
      //console.log(blueprint.validators[0])
      const scriptCbor = applyParamsToScript(blueprint.validators[0].compiledCode, [paymentKeyHashData]);
      console.log(scriptCbor)
      const scriptAddr = serializePlutusScript(
            { code: scriptCbor, version: "V3" },
            undefined,
            0
      ).address;

      console.log("Script Address: " + scriptAddr);     


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
            { unit: policyId + "6d6173746572", quantity: "1" },
          ];

      const { collateralUtxo, utxoListExcludingCollateral} = removeUtxoForCollateralFrom(wallet_utxos)

      const unsignedMintTx = await txBuilder
            .setNetwork("preprod")
            .mintPlutusScriptV3()
            .mint("1", policyId, "6d6173746572")
            .mintingScript(scriptCbor)
            .mintRedeemerValue(oracleRedeemer, "JSON")
            .selectUtxosFrom(utxoListExcludingCollateral)
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

instantiateOracle(wallet_1)














// =================================== Program CLI ===================================

// Set VK.
/*
Create a Tx that sends an UTXO with the wk to an always false script.
*/


// Generate an Oracle.
/*      - Creates an UTXO with the NEW root hash of banned Txs.
      - Sends this token again to script.
A command that let's you create an Oracle.

1. We need to import merkle tree functions.
2. Import the Oracle scipt and apply a vk
3. Define a Tx that which:
      - Creates an UTXO with the root hash of banned Txs.
      - Mint a single token.
*/

// Update the Oracle
/*
1. Recompute a new MKT.
2. Update the new MKT root at the script address.
3. Define a Tx that which:
      - Creates an UTXO with the NEW root hash of banned Txs.
      - Sends this token again to script.
*/


// Create an instance of a PoI validator.
/*
1. Apply the parameter (vk) to the contract.
2. Define the Datum with the oref and the Oracle's token policy Id.
3. Define a Reedmer Create.
4.. Define a Tx that:
      - Mints a single POI token and sends it to script address.
      - Attaches the datum.
      - Attaches the redeemer.
*/

// Update the Datum of the PoI validator.
/*
1. Define an updated Datum
2. Define Redeemer Update.
3. Define a Tx that:
      - Sends this token again to script.
      - Attachs the new Datum.
      - Attaches theand Redeemer.
*/

// Execute a proof of innocence.
/* 
1. Create the ZK proof (snarkjs)
2. Define Redeemer VerifyProof()
3. Define a Tx that:
  - Has the reference input of the Oracle.
  - Has the reference input of the vk.
  - Appends the proof inside the redeemer.
  - Spends the UTXO and create a new one in the script address. Sends the PoI token again to validator.
*/



// ClI commands bootsrap.

//import { Command } from "commander";
//import chalk from "chalk";
//
//const program = new Command();
//
//program
//  .name("mi-cli")
//  .description("Una CLI de ejemplo con TypeScript")
//  .version("1.0.0");
//
//program
//  .command("saludar")
//  .description("Muestra un saludo personalizado")
//  .argument("<nombre>", "Nombre de la persona a saludar")
//  .action((nombre) => {
//    console.log(chalk.green(`¡Hola, ${nombre}! Bienvenido a mi CLI.`));
//  });
//
//program.parse(process.argv);
