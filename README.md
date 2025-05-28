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

## CLI application

We developed a CLI application to test the basic functionalities of the development. 

The main interface of the application is the `cli_input.json` file present at `/cardano-zk-proof-of-innocence/implementation/cli`. Here is an example with values that we used to test the functionalities right away.

```JSON
{
    "tree_list": [0, 0, 0, 1],
    "leaf_index": 2,
    "oracle_thread_token_name": "test13",
    "poi_thread_token_name": "test13",
    "oracle_tx_id": "<Paste_the_oracle_utxo_here>",
    "oracle_tx_index": 0,
    "verification_key_tx_id": "d827021060f3c918c7390651905b3ebc19650baf114bd809c9526f434ae68f25",
    "verification_key_tx_index": 0
}
```

* tree_list: The collection of transaction you are working with.
* leaf_index: The index on the list of the target element to proof the exclusion.
* oracle_thread_token_name: An arbitrary token name used to differentiate each oracle instance.
* poi_thread_token_name: An arbitrary token name used to differentiate each poi instance.
* oracle_tx_id. The transaction-id of the UTxO with the root hash of the collection of elements to check the PoI.
* oracle_tx_id. The index of the Oracle's UTxO.
* verification_key_tx_id: The transaction-id with the verification key used to verify the proof.
* verification_key_tx_index: The index of the UTxO with the verification key above.

*Create oracle* 

One can create a instance of the oracle by running this command:

```bash
npx tsx --trace-warnings src/index.ts create oracle
```

The transaction will create a token with the `oracle_thread_token_name` value. And this command will output the following: 

```bash
Copy and paste this value at oracle_tx_id in the cli_input.json file:
a4a473ce531500e6fadc9607a3935e7e06b6d3113953acf0e68f94d96dd8a4d6
```

*Update oracle* 

If one wants to work with a different collection of banned transactions (a different `tree_list` value), the collection could be update the collection with the following command.

```bash
npx tsx --trace-warnings src/index.ts update oracle
```

This will update the merkle root hash published previously. It is important to note that the `oracle_tx_id` value must be updated again.


*Set the verificiation key*

The PoI contract needs a verification key in a reference input to verify the Zero-Knowledge proof. If you are testing the application on prepod you can use the value `verification_key_tx_id` mentioned above. But you can also set your own verification key by running this command and update the value on the `cli_input.json` file.

```bash
npx tsx --trace-warnings src/index.ts set-verification-key
```

The command will ouput something like this:

```bash 
Success! Here's the transaction hash to paste in the verification_key_tx_id value:
98f410d75f3eb6a25c52e9d18752c68a1e069b3a0665173585cf332d2c6fbf3e
```

*Create poi* 

One can create a instance of the poi by running this command:

```bash
npx tsx --trace-warnings src/index.ts create poi
```

*Verify* 

The proof of innocence can be executed running the following command.

```bash
npx tsx --trace-warnings src/index.ts verify
```


