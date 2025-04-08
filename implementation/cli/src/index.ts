#!/usr/bin/env node
//import { intro } from './intro.js';
import dotenv from 'dotenv';
import { BlockfrostProvider, MeshWallet, serializePlutusScript} from '@meshsdk/core';
import { applyParamsToScript, skeyToPubKeyHash, toPlutusData, deserializeAddress } from "@meshsdk/core-csl";
import { Address } from '@emurgo/cardano-serialization-lib-nodejs';
import {  } from "@meshsdk/common"
import fs, { read } from 'fs';
import { error } from 'console';


//const privatekey = MeshWallet.brew(true);
//console.log(privatekey);


// Display intro
//console.log(intro);

// Create enviroment variables

dotenv.config();
const secretKey: string = process.env.WALLET_SECREY_KEY || "nothing";
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
      type: 'root',
      bech32: secretKey,
    },
});



async function initializeWallet(wallet: MeshWallet) {
      await wallet.init()
      console.log(wallet.getAddresses())
      const balance = await wallet.getBalance()
      console.log(balance)
}



async function instantiateOracle(wallet: MeshWallet) {
      await initializeWallet(wallet)
      const walletAddr = wallet_1.getAddresses().baseAddressBech32
      //if (walletAddr == undefined) throw new Error("Can't find bech32 wallet address")
      //const pubKeyHash = deserializeAddress(walletAddr!)
      const pubKeyHash = Address.from_bech32(walletAddr!);

      const paymentKeyHash = pubKeyHash!.payment_cred()!.to_keyhash();
      console.log(Buffer.from(paymentKeyHash!.to_bytes()).toString('hex'));
      

      const blueprint = JSON.parse(fs.readFileSync("../validator/plutus.json", "utf-8"));
      const scriptCbor = applyParamsToScript(blueprint.validators[0].compiledCode, paymentKeyHash);
      //const scriptAddr = serializePlutusScript(
      //      { code: scriptCbor, version: "V3" },
      //      undefined,
      //      0
      //).address;
      //console.log(scriptAddr);     
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
