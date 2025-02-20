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
