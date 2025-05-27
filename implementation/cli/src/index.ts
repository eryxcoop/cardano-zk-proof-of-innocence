#!/usr/bin/env node
//import { intro } from './intro.js';
import * as fs from "fs"
import { hashSingleValue } from "./common/dummyHash.js"
import { MerkleTree } from "./common/MerkleTree.js"
import { buildPoi } from "./off_chain/buildPoi.js"
import { setVerificationKey } from "./on_chain/setVerificationKey.js"
import { instantiateOracle } from "./on_chain/instantiateOracle.js"
import { instantiatePoi } from "./on_chain/instantiatePoi.js"
import { updateOracle } from "./on_chain/updateOracle.js"
import { textToHex } from "./on_chain/common.js"


const cliInputsFilePath = "./cli_input.json";
const cliInputs = JSON.parse(fs.readFileSync(cliInputsFilePath, "utf-8"));

// CLI Inputs
const treeList = cliInputs.tree_list as number[]
const leafIndex: number = cliInputs.leaf_index as number
const oracleTokenName = textToHex(cliInputs.oracle_thread_token_name)
const poiTokenName = textToHex(cliInputs.poi_thread_token_name)
const oracleOutputReference = [cliInputs.oracle_tx_id, cliInputs.oracle_tx_index]
const verifificationOutputReference = [cliInputs.verification_key_tx_id, cliInputs.verification_key_tx_index]

// Proof Inputs

const merkleTree = new MerkleTree(treeList)
const oracleMerkleTreeRootHash = merkleTree.root()
const pathElements = merkleTree.authenticationPathElementsFor(leafIndex)
const pathIndices = merkleTree.authenticationPathIndicesFor(leafIndex)
const leafIndexHash = hashSingleValue(leafIndex)


//process.exit(0)


import { Command } from "commander";
import chalk from "chalk";
import { Integer } from "@meshsdk/core"

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
                  instantiateOracle(oracleMerkleTreeRootHash, oracleTokenName)
                  console.log(chalk.green(`Creating an instance of the PoI Oracle`));
            } else if (contract == "poi") {
                  instantiatePoi(poiTokenName, verifificationOutputReference[0], verifificationOutputReference[1])
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
                  updateOracle(oracleMerkleTreeRootHash, oracleTokenName)
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
            buildPoi(oracleMerkleTreeRootHash, leafIndexHash, pathElements, pathIndices, leafIndex, poiTokenName, oracleOutputReference[0], oracleOutputReference[1], verifificationOutputReference[0], verifificationOutputReference[1]);
      });

program
      .command("set-verification-key")
      .description("Set the verification key")
      //.argument("contract", "Name of the contract")
      .action(() => {
            console.log(chalk.green(`Setting the verification key.`));
            setVerificationKey();
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
      - Attaddr_test1qr5cplxtu4xe7pm50ldavtvg9p650m6m6nefwzctq7mhhj4kekym3jnzus8zguzfcxy4natchu0836ka2dq32hxggh2qk573kpaches the redeemer.
*/

// Update the Datum of the PoI validator.
/*
1. Define an updated Datum
2. Define Redeemer Update.
3. Define a Tx that:
      - Sends this token again to script.
      - Attachs the new Datum.
      - Attaches theand Redeemer.
*

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




