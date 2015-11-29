contract Elcoin {
    struct Account {
        mapping(address => bool) holders;
        uint8 signsOfHoldersRequired;
        uint amount;
    }

    struct Sign {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    // events
    //@TODO: define all events
    event OwnerAdded(address newOwner);
    event OwnerRemoved(address oldOwner);
    event Transaction(address from, address to, uint amount, uint commission);
    event CommissionTransaction(address from, address to, uint amount);

    // owners section
    mapping (address => bool) owners;
    uint8 numberOfOwnerSigners;
    uint8 numberOfChangesOwnerAllowedPerDay;
    uint8 ownersTodayChanges;
    uint lastOwnersChangeDoneAt;

    // cron section
    mapping (address => bool) cron;
    uint8 numberOfCronSigners;

    // master wallet section
    address masterWallet;
    uint transactionCommission;

    // next contract version
    address nextContractVersion;

    // account balances section
    mapping (address => Account) public balances;

    // modifiers section

    modifier noNewContractVersion() {
        if(nextContractVersion == 0x0) {
            _
        }
        else {
            throw;
        }
    }

    modifier checkMultiSig(mapping(address => bool) allSigners, uint8 signsRequired, Sign[] signs) {
        if(signs.length < signsRequired) {
            throw;
        }

        if(signs.length > 255) {
            throw;
        }

        mapping(address => bool) foundAddresses;
        uint8 signsFound = 0;

        for(uint8 i = 0; i < signs.length; i++) {
            Sign memory sign = signs[i];

            //@TODO: get rid of this as not suitable. no transaction hash available :(
            address signAddress = ecrecover(sha3(""), sign.v, sign.r, sign.s);

            if(foundAddresses[signAddress]) {
                continue;
            }

            if(allSigners[signAddress]) {
                foundAddresses[signAddress] = true;
                ++signsFound;
            }
            else {
                // unknown address
                throw;
            }
        }

        if(signsFound >= signsRequired) {
            _
        }
        else {
            throw;
        }
    }

    modifier ownerChangesAllowed() {
        //@TODO: define method lookup
    }

    // owner public methods

    function addNewOwner(Sign[] signs, address owner) noNewContractVersion checkMultiSig(owners, numberOfOwnerSigners, signs) ownerChangesAllowed {
        //@TODO: add owner to signs
    }

    function removeOwner(Sign[] signs, address owner) noNewContractVersion checkMultiSig(owners, numberOfOwnerSigners, signs) ownerChangesAllowed {
        //@TODO: remove owner
    }

    function changeMinNumberOfSignsRequired(Sign[] signs, uint8 signsRequired) noNewContractVersion checkMultiSig(owners, numberOfOwnerSigners, signs) ownerChangesAllowed {
        //@TODO: change min number of signs
    }

    function changeMasterWalletAddress(Sign[] signs, address masterWallet) noNewContractVersion checkMultiSig(owners, numberOfOwnerSigners, signs) ownerChangesAllowed {
        //@TODO: change master wallet address
    }

    function changeNumberOfOwnersActions(Sign[] signs) noNewContractVersion checkMultiSig(owners, numberOfOwnerSigners, signs) ownerChangesAllowed {
        //@TODO: implement
    }

    // cron public methods

    function addNewCron(Sign[] signs, address cronAddress) noNewContractVersion checkMultiSig(owners, numberOfOwnerSigners, signs) ownerChangesAllowed {
        //@TODO: add new cron owner
    }

    function removeCron(Sign[] signs, address cronAddress) noNewContractVersion checkMultiSig(owners, numberOfOwnerSigners, signs) ownerChangesAllowed {
        //@TODO: remove cron owner
    }

    function setMinNumberOfCronSigns(Sign[] signs, uint8 minSigns) noNewContractVersion checkMultiSig(owners, numberOfOwnerSigners, signs) ownerChangesAllowed {
        //@TODO: set min number of signs required
    }

    //@TODO: define cron methods
    function changeTransactionCommission(Sign[] signs, uint commission) noNewContractVersion checkMultiSig(cron, numberOfCronSigners, signs) ownerChangesAllowed {
        //@TODO: change transaction commission
    }

    function overchargeAnnualInterestRate() {
        //@TODO: implement
    }

    // account public methods
    //@TODO: create multisig account
    //@TODO: make transaction

    function () {
        throw;
    }
}
