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
