import "CommissionMiddleware"
import "CronContract"
import "CurrencyOwner"

contract ElcoinMiddleware is CommissionMiddleware, CronContract, CurrencyOwner {
    // states
    uint public createdAt;
    uint lastRunOfAnnualAccrualAt;
    bool public annualIsOver;

    // PoS
    mapping (address => AnnualAccountBalance) annualInterestAccounts;
    address [] annualInterestAddresses;

    // PoT
    uint transactionsCount;
    TransactionData[] lastTenTransactions;

    // structs
    struct AnnualAccountBalance {
        bool created;
        uint balance;
    }

    struct TransactionData {
        address origin;
        address destination;

        uint amount;

        uint createdAt;
    }

    //events
    event AnnualInterestAccrualFailed(address origin);
    event AnnualInterestEarned(address accountAddress, uint amountEarned);
    event TxPrizeWined(address accountAddress, uint amountEarned);
    event FailedToRegisterMultiSig(address accountAddress, string desc);
    event SucceedMultiSigAddessRegister(address accountAddress);

    //public methods
    function ElcoinMiddleware(address preminedAddress, uint amount) {
        initCommissionMiddleware();
        initMiddleware(preminedAddress, amount);
        initCurrencyOwner(preminedAddress);

        createdAt = now;
        lastRunOfAnnualAccrualAt = now + 10 days;
    }

    function initWallet4MultiSig(address accountAddress, uint32 time,  bytes32[] signRSs, uint8[] signVs, address holderAddress1, address holderAddress2, address holderAddress3) returns (bool _success) {
        MultiSigAccount account = accounts[accountAddress];

        if(account.holdersCount > 0) {
            FailedToRegisterMultiSig(accountAddress, "holders more than 0");

            return false;
        }

        account.holdersCount = 1;
        account.holders[accountAddress] = true;

        bytes32 hash = sha3("initWallet4MultiSig", accountAddress, time, holderAddress1, holderAddress2, holderAddress3);

        if(isValidMultiSig(hash, time, account, signRSs, signVs)) {
            account.holders[holderAddress1] = true;
            account.holders[holderAddress2] = true;
            account.holders[holderAddress3] = true;
            account.holdersCount = 4;
            account.signaturesRequired = 3;

            SucceedMultiSigAddessRegister(accountAddress);

            return true;
        }

        FailedToRegisterMultiSig(accountAddress, "hash sign is incorrect");

        return false;
    }

    function annualInterest() returns (bool _success) {
        if(lastRunOfAnnualAccrualAt + 864000 > now) {
            AnnualInterestAccrualFailed(msg.sender);

            return false;
        }

        uint daysAfterStart = (now - createdAt) / 86400;

        uint interestRate;

        if(daysAfterStart <= 90) {
            interestRate = 50;
        }
        else if(daysAfterStart <= 180) {
            interestRate = 40;
        }
        else if(daysAfterStart <= 270) {
            interestRate = 30;
        }
        else if(daysAfterStart <= 360) {
            interestRate = 20;
        }
        else if(daysAfterStart <= 2190) {
            interestRate = 10;
        }
        else {
            annualIsOver = true;

            return false;
        }

        // interest rate * 100 / year * period (10 days)
        interestRate = interestRate * 100 / 365 * 10;

        uint i;

        for(i = 0; i < annualInterestAddresses.length; i++) {
            address accountAddress = annualInterestAddresses[i];

            MultiSigAccount account = accounts[accountAddress];

            if(account.recovered != 0x0) {
                continue;
            }

            AnnualAccountBalance annualInterestAccount = annualInterestAccounts[accountAddress];

            if(annualInterestAccount.balance > 0) {
                uint earned = annualInterestAccount.balance * 100 / interestRate;

                account.balance = account.balance + earned;

                AnnualInterestEarned(accountAddress, earned);
            }

            delete annualInterestAccounts[accountAddress];
        }

        delete annualInterestAddresses;
    }

    function _transfer(address accountAddress, address destination, uint amount) internal returns (bool _success) {
        if(CommissionMiddleware._transfer(accountAddress, destination, amount) == false) {
            return false;
        }

        ++ transactionsCount;

        if(transactionsCount == 100001) {
            transactionsCount = 0;

            uint maxTxAmount;
            address[10] memory maxTxOrigins;

            //@TODO: should we increase number of prize if the same origin generated max TXs
            for(uint8 i = 0; i < lastTenTransactions.length; i++) {
                if(accounts[lastTenTransactions[i].origin].recovered != 0) {
                    continue;
                }

                if(lastTenTransactions[i].amount > maxTxAmount) {
                    maxTxAmount = lastTenTransactions[i].amount;

                    for(uint8 j = 0; j <= i; j++) {
                        maxTxOrigins[j] = 0;
                    }

                    maxTxOrigins[i] = lastTenTransactions[i].origin;
                }
                else if(lastTenTransactions[i].amount == maxTxAmount) {
                    maxTxOrigins[i] = lastTenTransactions[i].origin;
                }
            }

            if(maxTxOrigins.length > 0) {
                uint prize = 200 / maxTxOrigins.length;

                for(i = 0; i < maxTxOrigins.length; i++) {
                    accounts[maxTxOrigins[i]].balance += prize;

                    TxPrizeWined(maxTxOrigins[i], prize);
                }
            }
        }

        if(transactionsCount > 99990) {
            TransactionData memory transactionData;

            transactionData.origin = accountAddress;
            transactionData.destination = destination;
            transactionData.amount = amount;
            transactionData.createdAt = now;

            if(amount > 10) {
                lastTenTransactions.push(transactionData);
            }
        }

        if(!annualIsOver) {
            if(annualInterestAccounts[accountAddress].created) {
                if(accounts[accountAddress].balance < annualInterestAccounts[accountAddress].balance) {
                    annualInterestAccounts[accountAddress].balance = accounts[accountAddress].balance;
                }
            }
            else {
                annualInterestAddresses.push(accountAddress);

                annualInterestAccounts[accountAddress].created = true;
                annualInterestAccounts[accountAddress].balance = accounts[accountAddress].balance;
            }
        }

        return true;
    }

    // currency owner methods
    function addCron(uint32 time, bytes32[] signRSs, uint8[] signVs, address newCronAddress)
        checkCurrencyOwnerMultiSig(sha3("addCron", time, newCronAddress), time, signRSs, signVs)
        currencyOwnerChangesAllowed
    {
        _addAccountHolder(cron, newCronAddress);

        ++currencyOwnersTodayChanges;
        currencyOwnerLastChangeDoneAt = now;

        CronAddressIsAdded(newCronAddress);
    }

    function removeCron(uint32 time, bytes32[] signRSs, uint8[] signVs, address cronAddress)
        checkCurrencyOwnerMultiSig(sha3("removeCron", time, cronAddress), time, signRSs, signVs)
        currencyOwnerChangesAllowed
    {
        _removeAccountHolder(cron, cronAddress);

        ++currencyOwnersTodayChanges;
        currencyOwnerLastChangeDoneAt = now;

        CronAddressIsRemoved(cronAddress);
    }

    function changeCronSignatures(uint32 time, bytes32[] signRSs, uint8[] signVs, uint8 cronSignsRequired)
        checkCurrencyOwnerMultiSig(sha3("changeCronSignatures", time, cronSignsRequired), time, signRSs, signVs)
        currencyOwnerChangesAllowed
    {
        _changeAccountSignaturesRequired(cron, cronSignsRequired);

        ++currencyOwnersTodayChanges;
        currencyOwnerLastChangeDoneAt = now;

        NumberOfCronSignaturesIsChanged(cronSignsRequired);
    }

    // cron methods
    function changeCommissionStructure(uint32 time, bytes32[] signRSs, uint8[] signVs, uint absMinCommission, uint pctCommission, uint absMaxCommission)
        checkCronMultiSigForAccount(sha3("changeCommissionStructure", time, absMinCommission, pctCommission, absMaxCommission), time, signRSs, signVs)
    {
        _changeCommissionStructure(absMinCommission, pctCommission, absMaxCommission);
    }
}