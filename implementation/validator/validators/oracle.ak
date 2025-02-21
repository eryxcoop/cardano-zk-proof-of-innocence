use aiken/collection/list.{has}

validator(verification_key){
    mint(redeemer: MyMintRedeemer, policy_id: PolicyId, self: Transaction) {

        // The transaction signature matches with the verification key.
        let transaction_includes_verification_key: Bool = has(self.extra_signatories, verification_key)

        if transaction_includes_verification_key is True {
            return True
        }

        // The amount of minted tokens is exactly 1.
        // The minted tokens are sent to the validator address (policy_id).
    }
}
