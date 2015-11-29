import "MultiSignedRecoverableAccount";

contract MultiSignedMiddleware is MultiSignedRecoverableAccount {
    // states
    mapping (address => MultiSigAccount) public accounts;
    bool public middlewareInitialized;

    // events
    event Transaction(address from, address to, uint time, uint amount);
    event AccountHolderIsAdded(address accountAddress, address holder);
    event AccountHolderIsRemoved(address accountAddress, address holder);
    event AccountHoldersSignaturesRequirementIsChanged(address accountAddress, uint8 signatures);
    event AccountIsRecovered(address accountAddress, address newAccountAddress, uint transferredBalance);
    event OneSigCheckFailed(address);
    event OperationOnRecoveredAccountForbidden(address accountAddress);

    // modifiers
    modifier checkMultiSigForAccount(address accountAddress, bytes32 hash, uint time, bytes32[] signRSs, uint8[] signVs) {
        if(isValidMultiSig(hash, time, accounts[accountAddress], signRSs, signVs)) {
            _
        }
        else {
            MultiSigCheckFailed(msg.sender);

            return;
        }
    }

    modifier notRecoveredAccount(address accountAddress) {
        if(accounts[accountAddress].recovered != 0x0) {
            OperationOnRecoveredAccountForbidden(accountAddress);

            return;
        }
        _
    }

    modifier checkOneSigAccount(address accountAddress) {
        if(accounts[accountAddress].holdersCount == 0) {
            accounts[accountAddress].holdersCount = 1;
            accounts[accountAddress].holders[accountAddress] = true;

            return;
        }

        if(accounts[accountAddress].holdersCount != 1) {
            OneSigCheckFailed(msg.sender);

            return;
        }

        if(! accounts[accountAddress].holders[accountAddress]) {
            OneSigCheckFailed(msg.sender);

            return;
        }

        _
    }

    //constructor
    function initMiddleware(address preminedAccount, uint amount) internal returns(bool _success) {
        if(middlewareInitialized) {
            return false;
        }

        accounts[preminedAccount].balance = amount;

        accounts[preminedAccount].holders[preminedAccount] = true;
        accounts[preminedAccount].holdersCount = 1;
        //@TODO: block this account for general use tx
        accounts[preminedAccount].signaturesRequired = 1;
        accounts[preminedAccount].nonce = now;

        middlewareInitialized = true;

        return true;
    }


    // management methods
    function addAccountHolder(address accountAddress, uint32 time, bytes32[] signRSs, uint8[] signVs, address holder)
        checkMultiSigForAccount(accountAddress, sha3("addAccountHolder", accountAddress, time, holder), time, signRSs, signVs)
        notRecoveredAccount(accountAddress)
    {
        _addAccountHolder(accounts[accountAddress], holder);

        AccountHolderIsAdded(accountAddress, holder);
    }

    function removeAccountHolder(address accountAddress, uint32 time,  bytes32[] signRSs, uint8[] signVs, address holder)
        checkMultiSigForAccount(accountAddress, sha3("removeAccountHolder", accountAddress, time, holder), time, signRSs, signVs)
        notRecoveredAccount(accountAddress)
    {
        if(accountAddress == holder) {
            // operation is not permitted

            return false;
        }

        _removeAccountHolder(accounts[accountAddress], holder);

        AccountHolderIsRemoved(accountAddress, holder);
    }

    function changeAccountSignaturesRequired(address accountAddress, uint32 time,  bytes32[] signRSs, uint8[] signVs, uint8 signaturesRequired)
        checkMultiSigForAccount(accountAddress, sha3("changeAccountsignaturesRequired", accountAddress, time, signaturesRequired), time, signRSs, signVs)
        notRecoveredAccount(accountAddress)
    {
        _changeAccountSignaturesRequired(accounts[accountAddress], signaturesRequired);

        AccountHoldersSignaturesRequirementIsChanged(accountAddress, signaturesRequired);
    }

    function recoverAccount(address accountAddress, uint32 time,  bytes32[] signRSs, uint8[] signVs, address recoveredAddress)
        checkMultiSigForAccount(accountAddress, sha3("recoverAccount", accountAddress, time, recoveredAddress), time, signRSs, signVs)
        notRecoveredAccount(accountAddress)
    {
        uint balance = accounts[accountAddress].balance;

        accounts[recoveredAddress].balance += balance;

        accounts[accountAddress].balance = 0;

        AccountIsRecovered(accountAddress, recoveredAddress, balance);
    }

    function _transfer(address accountAddress, address destination, uint amount) internal returns (bool _success) {
        if(accounts[accountAddress].balance >= amount) {
            accounts[accountAddress].balance = accounts[accountAddress].balance - amount;

            accounts[destination].balance = accounts[destination].balance + amount;

            Transaction(accountAddress, destination, now, amount);

            return true;
        }

        return false;
    }

    // public MULTISIG methods
    function transfer(address accountAddress, uint32 time,  bytes32[] signRSs, uint8[] signVs, address destination, uint amount)
            checkMultiSigForAccount(accountAddress, sha3("transfer", accountAddress, time, destination, amount), time, signRSs, signVs)
            returns (bool _success)
    {
        // Instead of modifiers notRecoveredAccount(accountAddress) notRecoveredAccount(destination)
        // because of Compiler error: Stack too deep, try removing local variables.

        if(accounts[accountAddress].recovered != 0x0) {
            OperationOnRecoveredAccountForbidden(accountAddress);

            return false;
        }

        if(accounts[destination].recovered != 0x0) {
            OperationOnRecoveredAccountForbidden(accountAddress);

            return false;
        }

        return _transfer(accountAddress, destination, amount);
    }

    // public ONESIG methods
    function getAccountBalance(address accountAddress) constant returns(uint balance) {
        return accounts[accountAddress].balance;
    }

    function transfer(address destination, uint amount)
                notRecoveredAccount(tx.origin)
                notRecoveredAccount(destination)
                checkOneSigAccount(tx.origin)
                returns (bool _success)
    {
        return _transfer(tx.origin, destination, amount);
    }
}