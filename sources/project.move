module MyModule::DrugExpirationTracking {

    use aptos_framework::signer;
    use aptos_framework::timestamp;

    /// Struct representing a drug with its expiration information.
    struct Drug has store, key {
        name: vector<u8>,           // Drug name stored as bytes
        batch_number: vector<u8>,   // Batch number for identification
        expiration_timestamp: u64,  // Expiration date as Unix timestamp
        manufacturer: address,      // Address of the manufacturer
        is_expired: bool,          // Current expiration status
    }

    /// Error codes
    const E_DRUG_NOT_FOUND: u64 = 1;
    const E_INVALID_EXPIRATION_DATE: u64 = 2;

    /// Function to register a new drug with expiration information.
    /// @param owner: The signer registering the drug (manufacturer/pharmacy)
    /// @param name: Name of the drug as bytes
    /// @param batch_number: Batch number for identification
    /// @param expiration_timestamp: Unix timestamp when drug expires
    public fun register_drug(
        owner: &signer, 
        name: vector<u8>, 
        batch_number: vector<u8>, 
        expiration_timestamp: u64
    ) {
        // Validate that expiration date is in the future
        let current_time = timestamp::now_seconds();
        assert!(expiration_timestamp > current_time, E_INVALID_EXPIRATION_DATE);

        let drug = Drug {
            name,
            batch_number,
            expiration_timestamp,
            manufacturer: signer::address_of(owner),
            is_expired: false,
        };
        
        move_to(owner, drug);
    }

    /// Function to check and update the expiration status of a drug.
    /// @param drug_owner: Address where the drug is stored
    /// @return: Returns true if drug is expired, false otherwise
    public fun check_expiration(drug_owner: address): bool acquires Drug {
        assert!(exists<Drug>(drug_owner), E_DRUG_NOT_FOUND);
        
        let drug = borrow_global_mut<Drug>(drug_owner);
        let current_time = timestamp::now_seconds();
        
        // Update expiration status based on current time
        if (current_time >= drug.expiration_timestamp) {
            drug.is_expired = true;
        };
        
        drug.is_expired
    }
}