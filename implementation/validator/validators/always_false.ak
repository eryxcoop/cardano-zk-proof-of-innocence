use cardano/transaction.{Datum, OutputReference, Transaction}

validator always_false() {
    spend(
        _datum: Option<Datum>,
        _redeemer: Int,
        _utxo: OutputReference,
        _self: Transaction) {
        False
    }
}
