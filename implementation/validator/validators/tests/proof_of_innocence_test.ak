use cardano/transaction.{OutputReference, placeholder}
use proof_of_innocence.{spend}

test testSpendProofOfInnocence() {
  let datum = None
  let redeemer = None
  let utxo = OutputReference {
    transaction_id: #"aa",
    output_index: 0,
  }
  let tx = placeholder

  spend(datum, redeemer, utxo, tx)
}