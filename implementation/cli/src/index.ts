#!/usr/bin/env node

import { intro } from './intro.js';
import { BlockfrostProvider, MeshWallet } from '@meshsdk/core';


// Display intro
console.log(intro);



const blockchainProvider = new BlockfrostProvider('mainnetUL5mZhjwzx74yL1FU4FaSMfXNmSz8oFy');

const sk_1 = "xprv1zp6frpv9hu5y8nvcdz3umv9z4wang0f5k433rzyvj7xlefxmy3f20hg30jsnwyvazz87e80fzngd9tgcdmut62n80ve3cq8c7px7lg6tc4vtaqxrg8nkqtx4jxkqm4sgt0as4hc70q29xkxrzzmk64f38yr2ns3p"



const wallet_1 = new MeshWallet({
    networkId: 1, 
    fetcher: blockchainProvider,
    submitter: blockchainProvider,
    key: {
      type: 'root',
      bech32: sk_1,
    },
});

console.log(wallet_1);


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
