#!/usr/bin/env node
//import { intro } from './intro.js';
import { hashSingleValue } from "./common/dummyHash.js"
import { MerkleTree } from "./common/MerkleTree.js"
import { buldPoi } from "./off_chain/buildPoi.js"
import { instantiateOracle } from "./on_chain/instantiateOracle.js"
import { instantiatePoi } from "./on_chain/instantiatePoi.js"
import { updateOracle } from "./on_chain/updateOracle.js"


//instantiateOracle()
//updateOracle()
//instantiatePoi()

const list = [1, 1, 0, 1]
const merkleTree = new MerkleTree(list)
const leafIndex = 2
const oracleMerkleTreeRootHash = merkleTree.root()
const pathElements = merkleTree.authenticationPathElementsFor(leafIndex)
const pathIndices = merkleTree.authenticationPathIndicesFor(leafIndex)
const leafIndexHash = hashSingleValue(leafIndex)

//await buldPoi(oracleMerkleTreeRootHash, leafIndexHash, pathElements, pathIndices, leafIndex)

//process.exit(0)


import { Command } from "commander";
import chalk from "chalk";

const program = new Command();

program
  .name("poi-cli")
  .description("A simple cli for testing PoI in Cardano")
  .version("0.1");

  program.addHelpText('beforeAll', `
      General description:
        This cli program allows you to run transactions related to a PoI application on the Cardano network. You can create an instance of a PoI contract and verify it on-chain. Also you can manage the Oracle needed to verify the PoI proof. 
      `);

   program.addHelpText('afterAll', `
      examples:
          $ poi-cli create oracle
          $ poi-cli create poi
          $ poi-cli update oracle
      `);

  program
    .command("create")
    .description("Creating an instance of a contract")
    .argument("contract", "Name of the contract")
    .action((contract) => {
      if (contract == "oracle") {
            instantiateOracle()
            console.log(chalk.green(`Creating an instance of the PoI Oracle`));
      } else if (contract == "poi") {
            instantiatePoi()
            console.log(chalk.green(`Creating an instance of the PoI contract.`));
      } else {
            console.log(chalk.red(`Error: "${contract}" contract doesn't exist.`));
      }
    });

    program
    .command("update")
    .description("Updating the data of a concract")
    .argument("contract", "Name of the contract")
    .action((contract) => {
      if (contract == "oracle") {
            updateOracle()
            console.log(chalk.green(`Updating the PoI Oracle`));
      } else if (contract == "poi") {
            //updatePoi()
            console.log(chalk.green(`Updating the PoI contract.`));
      } else {
            console.log(chalk.red(`Error: "${contract}" contract doesn't exist.`));
      }
    });

    program
    .command("verify")
    .description("Verify the PoI proof")
    //.argument("contract", "Name of the contract")
    .action(() => {
      console.log(chalk.green(`Verifying the PoI proof.`));
      // spendPoI()
    });




  program.parse(process.argv);


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




