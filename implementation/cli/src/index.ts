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




