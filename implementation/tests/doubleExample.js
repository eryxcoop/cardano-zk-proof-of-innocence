const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;
const crypto = require("crypto");


const assert = chai.assert;
const expect = chai.expect;

describe("double", function () {
  this.timeout(10000);
  it("should not validate incorrect witness", async function () {
    try {
      const circuit = await wasm_tester(
        path.join(__dirname, "../circuit/double.circom"),
        {}
      );

      const w = await circuit.calculateWitness({
        a: 2,
        b: 3,
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
        path.join(__dirname, "../circuit/double.circom"),
        {}
      );

      const w = await circuit.calculateWitness({
        a: 2,
        b: 4,
      });

      await circuit.checkConstraints(w);
    } catch (e) {
      assert.fail();
    }
  });
});