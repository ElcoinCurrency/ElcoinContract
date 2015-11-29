contract MultiSignedRecoverableAccount {
    // structs
    struct MultiSigAccount {
        address recovered;
        mapping(address => bool) holders;
        uint8 holdersCount;
        uint8 signaturesRequired;
        uint balance;
        uint nonce;
    }

    // events
    event MultiSigCheckFailed(address caller);

    // methods
    function isValidMultiSig(bytes32 hash, uint time, MultiSigAccount storage account, bytes32[] signRSs, uint8[] signVs) internal returns (bool isValid) {
        if(account.nonce >= time) {
            MultiSigCheckFailed(tx.origin);
            return false;
        }

        if(account.holdersCount <= 1) {
            MultiSigCheckFailed(tx.origin);

            return false;
        }

        if(account.recovered != 0x0) {
            MultiSigCheckFailed(tx.origin);

            return false;
        }

        if(signRSs.length / 2 < account.signaturesRequired ||
                (signVs.length < account.signaturesRequired && signRSs.length / 2 != signVs.length)) {

            MultiSigCheckFailed(tx.origin);

            return false;
        }

        if(signRSs.length > 512) {
            MultiSigCheckFailed(tx.origin);

            return false;
        }

        mapping(address => bool) foundAddresses;
        uint8 signsFound = 0;

        for(uint8 i = 0; i < signRSs.length; i+=2) {
            uint8 v = signVs[i];

            address signAddress = ecrecover(hash, v, signRSs[i], signRSs[i + 1]);

            if(foundAddresses[signAddress]) {
                MultiSigCheckFailed(tx.origin);

                return false;
            }

            if(account.holders[signAddress]) {
                foundAddresses[signAddress] = true;
                ++signsFound;
            }
            else {
                // unknown address
                MultiSigCheckFailed(tx.origin);

                return false;
            }
        }

        if(signsFound >= account.signaturesRequired) {
            account.nonce = time;

            return true;
        }

        MultiSigCheckFailed(tx.origin);

        return false;
    }

    // management methods
    function _addAccountHolder(MultiSigAccount storage account, address holder) internal returns (bool _success) {
        if(account.holders[holder]) {
            return false;
        }

        account.holders[holder] = true;

        ++ account.holdersCount;

        return true;
    }

    function _removeAccountHolder(MultiSigAccount storage account, address holder) internal returns (bool _success) {
        if(!account.holders[holder]) {
            return false;
        }

        if(account.holdersCount == account.signaturesRequired) {
            return false;
        }

        delete account.holders[holder];

        -- account.holdersCount;

        return true;
    }

    function _changeAccountSignaturesRequired(MultiSigAccount storage account, uint8 signaturesRequired) internal returns (bool _success) {
        if(account.holdersCount < signaturesRequired || signaturesRequired == 0) {
            return false;
        }

        account.signaturesRequired = signaturesRequired;

        return true;
    }

    function _recoverAccount(MultiSigAccount storage account, address newAccountAddress) internal returns (bool _success) {
        account.recovered = newAccountAddress;

        return true;
    }
}