use cardano/script_context.{ScriptContext}
use cardano/transaction.{OutputReference, Transaction, placeholder}

validator proofOfInnocence {
  spend(
    _datum: Option<Data>,
    _redeemer: Data,
    _utxo: OutputReference,
    _self: Transaction,
  ) {
    True
  }

  else(_ctx: ScriptContext) {
    False
  }
}

test testSpendProofOfInnocence() {
  let datum = None
  let redeemer = None
  let utxo = OutputReference { transaction_id: #"aa", output_index: 0 }
  let tx = placeholder

  proofOfInnocence.spend(datum, redeemer, utxo, tx)
}
