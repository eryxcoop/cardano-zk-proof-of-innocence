const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;
const crypto = require("crypto");


const assert = chai.assert;
const expect = chai.expect;

// The example tree is:
// (1, 1) (0, 1)
//    (10, 7)
//     (79)

// The dummy "hash" function is H(a,b) = 3a+7b

describe("ProofOfInnocence", function () {
  this.timeout(10000);
  it("should not validate incorrect witness", async function () {
    try {
      const circuit = await wasm_tester(
        path.join(__dirname, "../circuit/proof_of_innocence.circom"),
        {}
      );

      const w = await circuit.calculateWitness({
        root: 85,
        pathElements: [1, 10],
        pathIndices: [0, 1],
      });
      await circuit.checkConstraints(w);
      assert.fail();
    } catch (e) {
      console.log(e);
      assert.instanceOf(e, Error);
      assert.notInstanceOf(e, chai.AssertionError);
    }
  });
  it("should validate correct witness", async function () {
    try {
      const circuit = await wasm_tester(
        path.join(__dirname, "../circuit/proof_of_innocence.circom"),
        {}
      );

      const w = await circuit.calculateWitness({
        root: 79,
        pathElements: [1, 10],
        pathIndices: [0, 1],
      });

      await circuit.checkConstraints(w);
    } catch (e) {
      assert.fail();
    }
  });
});