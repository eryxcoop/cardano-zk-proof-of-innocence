# Zero-Knowledge Proof of Innocence in Cardano

This repository features a proof of concept demonstrating the implementation of a Proof of Innocence protocol on Cardano.

It is done in the context of [this proposal](https://milestones.projectcatalyst.io/projects/1300197/milestones) from [Project Catalyst](https://projectcatalyst.io/)'s [Fund 13](https://projectcatalyst.io/funds/13).

For details on the design and specification of the protocol, please refer to the Research and Preliminary Specification document.

## Setup

1. Install NPM.
   1. In Debian-based systems, via `sudo apt install npm`.
   2. In MacOS, via `brew install npm`.
2. Enter the `implementation/` directory with `cd implementation`.
3. Install Aiken following the official [installation instructions](https://aiken-lang.org/installation-instructions).
   - Make sure to install the version specified in the `implementation/validator/aiken.toml` file.
   - For instance, if trying to install version `v1.1.11` via `aikup`, do it by using `aikup install v1.1.11`.

4. Install Circom following the official [installation instructions](https://docs.circom.io/getting-started/installation/).
5. Install SnarkJS following the official installations instructions in [their repository](https://github.com/iden3/snarkjs).

## Generate and verify the proof from the prover's side

1. Enter the `implementation/` directory with `cd implementation`.
2. Run `make generate_and_verify_proof`.

All relevant files generated in the process will be in the `implementation/setup` directory.

## Running validator tests

1. Enter the `implementation/validator` directory.
2. Run `aiken check`.

## Running cricuit tests
The circuit tests are run using `circom_tester`. There are a few inconveniences though.

To run the tests you must have `chai`, `mocha` and `circom_tester` installed. Since they're listed in the package.json, you can install them using `npm install`.

For some reason, `circom_tester` tries to use the version of circom that is present in the `node_modules` folder. This is a very older version that was frozen according to the circom website (version 0.45 instead of 2.0 or 2.1).

The workaround we found for this is ugly for now, until we find a way to pass the terminal context to Javascript or that we make a PR to `circom_tester` to be able to send a custom route to circom as a parameter. You have to edit the file `node_modules/circom_tester/wasm/tester.js` so that all calls to `circom` are replaced with `$HOME/.cargo/bin/circom` (because this is the directory in which the setup instructions put circom 2.1, if you installed it somewhere else this may vary). In this version this happens in two places: function `compiler_above_version` (around line 240) and function `compile` (around line 87). We intend to fix this in some neater way.

When you're back from that, you can run any test file in the `tests` folder with `npx mocha -pr ts-node/register tests/proofOfInnocence.js`. To run all tests, use `make test_circuit` from the `implementation` folder.
