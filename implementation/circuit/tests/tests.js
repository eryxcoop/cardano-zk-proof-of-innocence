const chai = import("chai");
const path = require("path");
const wasm_tester = require("../../node_modules/circom_tester/wasm/tester.js");

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

const assert = chai.assert;

describe("Simple test", function () {
    this.timeout(100000);

    it("Checking the compilation of a simple circuit generating wasm", async function () {
        const circuit = await wasm_tester(path.join(__dirname, "..", "proof_of_innocence.circom"));
        const w = await circuit.calculateWitness({a: 2});
        await circuit.checkConstraints(w);
    });
});