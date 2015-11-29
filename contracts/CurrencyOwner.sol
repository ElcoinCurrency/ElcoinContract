import "MultiSignedRecoverableAccount"

contract CurrencyOwner is MultiSignedRecoverableAccount {
    // states
    MultiSigAccount currencyOwner;

    uint8 numberOfCurrencyOwnerChangesAllowedPerDay;
    uint8 currencyOwnersTodayChanges;
    uint currencyOwnerLastChangeDoneAt;

    bool public currencyOwnerInitialized;

    // events
    event CurrencyOwnerMultiSigCheckFailed();
    event CurrencyOwnerHitMaxAllowedOperations();
    event CurrencyOwnerHolderIsAdded(address holder);
    event CurrencyOwnerHolderIsRemoved(address holder);
    event CurrencyOwnerSignaturesRequirementIsChanged(uint8 signaturesRequired);

    // modifiers
    modifier checkCurrencyOwnerMultiSig(bytes32 hash, uint time, bytes32[] signRSs, uint8[] signVs) {
        if(isValidMultiSig(hash, time, currencyOwner, signRSs, signVs)) {
            _
        }
        else {
            MultiSigCheckFailed(msg.sender);

            return;
        }
    }

    modifier currencyOwnerChangesAllowed() {
        if(currencyOwnersTodayChanges >= numberOfCurrencyOwnerChangesAllowedPerDay) {
            if(now < (currencyOwnerLastChangeDoneAt + (86400 - currencyOwnerLastChangeDoneAt % 86400))) {
                CurrencyOwnerHitMaxAllowedOperations();

                return;
            }
            else {
                numberOfCurrencyOwnerChangesAllowedPerDay = 0;
            }
        }
        else {
            ++ numberOfCurrencyOwnerChangesAllowedPerDay;
            _
        }
    }

    // constructor

    function initCurrencyOwner(address currencyOwnerAddress) internal returns (bool _success) {
        if(currencyOwnerInitialized) {
            return false;
        }

        currencyOwner.holders[currencyOwnerAddress] = true;
        currencyOwner.holdersCount = 1;
        currencyOwner.signaturesRequired = 1;
        currencyOwner.nonce = now;

        currencyOwnerInitialized = true;
    }

    // management methods

    function addCurrencyOwnerHolder(uint32 time, bytes32[] signRSs, uint8[] signVs, address holder)
        checkCurrencyOwnerMultiSig(sha3("addCurrencyOwnerHolder", time, holder), time, signRSs, signVs)
        currencyOwnerChangesAllowed()
    {
        _addAccountHolder(currencyOwner, holder);

        CurrencyOwnerHolderIsAdded(holder);
    }

    function removeCurrencyOwnerHolder(uint32 time,  bytes32[] signRSs, uint8[] signVs, address holder)
        checkCurrencyOwnerMultiSig(sha3("removeCurrencyOwnerHolder", time, holder), time, signRSs, signVs)
        currencyOwnerChangesAllowed()
    {
        _removeAccountHolder(currencyOwner, holder);

        CurrencyOwnerHolderIsRemoved(holder);
    }

    function changeCurrencyOwnerSignaturesRequired(uint32 time,  bytes32[] signRSs, uint8[] signVs, uint8 signaturesRequired)
        checkCurrencyOwnerMultiSig(sha3("changeCurrencyOwnerSignaturesRequired", time, signaturesRequired), time, signRSs, signVs)
        currencyOwnerChangesAllowed()
    {
        _changeAccountSignaturesRequired(currencyOwner, signaturesRequired);

        CurrencyOwnerSignaturesRequirementIsChanged(signaturesRequired);
    }
}