use cardano/transaction.{Transaction, OutputReference}
use cardano/script_context.{ScriptContext}

validator proofOfInnocence {

  spend(_datum: Option<Data>, _redeemer: Data, _utxo: OutputReference, _self: Transaction) {
    True
  }

  else(_ctx: ScriptContext) {
    False
  }
}
