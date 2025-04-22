#!/usr/bin/env node
//import { intro } from './intro.js';
import { instantiateOracle } from "./blockchain/instantiateOracle.js"
import { updateOracle } from "./blockchain/updateOracle.js"


//instantiateOracle()
updateOracle()




// =================================== Preliminaries ===================================

/*
1. Create sk.
2. Create Provider.
3. Create wallet.
4. Import the Oracle script.
5. Import the PoI script.
*/



// Update the Oracle
/*
1. Recompute a new MKT.
2. Update the new MKT root at the script address.
3. Define a Tx that which:
      - Creates an UTXO with the NEW root hash of banned Txs.
      - Sends this token again to script.
*/


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
