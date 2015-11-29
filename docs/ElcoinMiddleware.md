# Contract ElcoinMiddleware
This contract inherits `CommissionMiddleware`, `CronContract`, `CurrencyOwner` contracts.

## States
`uint public createdAt` - timestamp of creation date.
`uint lastRunOfAnnualAccrualAt` - last run of check to annual accrual.
`bool public annualIsOver` - PoS state, annual accural is stopped and will never happen again.
`mapping (address => AnnualAccountBalance) annualInterestAccounts` - PoS state, list of minimal account balances to accrual annualy.
`address [] annualInterestAddresses` - PoS state, addresses that did transactions in the period.
`uint transactionsCount` - PoT state, number of transactions.
`TransactionData[] lastTenTransactions` - PoT state, last ten transactions of 100001.

## Events

##### event AnnualInterestAccrualFailed(address origin)
Event if annual acrual failed, because the period is not over to make next annual accrual.

##### event AnnualInterestEarned(address accountAddress, uint amountEarned)
Event is fired on annual accrual by specific account.

##### event TxPrizeWined(address accountAddress, uint amountEarned)
Event is fired to indicate who won the PoT.

##### event FailedToRegisterMultiSig(address accountAddress, string desc)
Event is fired if wallet4 registration failed.

##### event SucceedMultiSigAddessRegister(address accountAddress);
Event is fired if wallet4 registraton succeed.

## Constructor
#####  function ElcoinMiddleware(address preminedAddress, uint amount)
Constructor accept address where premined amount should be transfered and premined amount. This method invokes `CommissionContract.initCommissionMiddleware`, `MultiSigMiddleware.initMiddleware(preminedAddress, amount)`, `CurrencyOwner.initCurrencyOwner(preminedAddress)`, also it specifies `lastRunOfAnnualAccrualAt` to 10 days since today.
Access:
This method is publicly available.
Params:
* preminedAccount - address of account, where premined asset will be places
* amount - premined amount

## Methods
##### function initWallet4MultiSig(address accountAddress, uint32 time,  bytes32[] signRSs, uint8[] signVs, address holderAddress1, address holderAddress2, address holderAddress3) returns (bool \_success)
This method should be called to register wallet4 account.
Access:
This method is publicly available.
Params:
* accountAddress - address of account, that should be marked as wallet4
* time - time of operation
* signRSs - array of R and S components of ECDSA signature
* signVs - array of V components of ECDSA signature
* holderAddress1 - address of additional holder
* holderAddress2 - address of additional holder
* holderAddress3 - address of additional holder
Returns: true if holders addedd successfully, otherwise fail

##### function annualInterest() returns (bool \_success)
This method should be called to run annual accrual. Accrual can be called every 10 days, no more frequently - it is hardcoded that from last accrual should pass 10 days. For first 90 days the annual rate is 50%, for next 90 days - 40%, for next 90 days - 30%, for next 90 days - 20%, for next 1830 days - 10%. Rate is calculated like: annual rate * 100 / 365(1 year) * 10(days).
Access:
This method is publicly available.
Returns: true if annual accrual was successful, otherwise fail.

##### function \_transfer(address accountAddress, address destination, uint amount) internal returns (bool \_success)
Elcoin contract overrides `\_transfer` method to implement PoT mechanism - when every 100001 transaction we take last 10 transactions and check the transaction with max amount and we give the transaction owner prize of 200 elcoins. This method invokes `CommissionContract._transfer` method to make calculation.
Access:
This method is invoked internally.
Params:
* accountAddress - address of account
* destination - address of receiver
* amount - amount of transfer
Returns: return value is taken from `CommissionContract._transfer` method response.

##### function addCron(uint32 time, bytes32[] signRSs, uint8[] signVs, address newCronAddress)
This method should be called by currency owners to add additional address that can invoke specific methods. Hash to sign is equal to `sha3("addCron", time, newCronAddress)`.
Access:
This method is publicly available.
Params:
* time - time of operation
* signRSs - array of R and S components of ECDSA signature
* signVs - array of V components of ECDSA signature
* newCronAddress - new cron address

##### function removeCron(uint32 time, bytes32[] signRSs, uint8[] signVs, address cronAddress)
This method should be called by currency owners to remove cron address. Hash to sign is equal to `sha3("removeCron", time, cronAddress)`.
Access:
This method is publicly available.
Params:
* time - time of operation
* signRSs - array of R and S components of ECDSA signature
* signVs - array of V components of ECDSA signature
* cronAddress - cron address to remove

##### function changeCronSignatures(uint32 time, bytes32[] signRSs, uint8[] signVs, uint8 cronSignsRequired)
This method should be called to specify how many cron signatures are required to validate operation. Hash to sign is equal to `sha3("changeCronSignatures", time, cronSignsRequired)`.
Access:
This method is publicly available.
Params:
* time - time of operation
* signRSs - array of R and S components of ECDSA signature
* signVs - array of V components of ECDSA signature
* cronSignsRequired - number of signatures required

##### changeCommissionStructure(uint32 time, bytes32[] signRSs, uint8[] signVs, uint absMinCommission, uint pctCommission, uint absMaxCommission)
This method should be called by cron addresses to change commission structure. Hash to sign is equal to `sha3("changeCommissionStructure", time, absMinCommission, pctCommission, absMaxCommission)`.
Access:
This method is publicly available.
Params:
* time - time of operation
* signRSs - array of R and S components of ECDSA signature
* signVs - array of V components of ECDSA signature
* absMinCommission - absolute minimal amount that should be taken if commission amount is lower than this value.
* pctCommission - percents of amount that generally will be taken from transfer amount to cover transactions cost.
* absMaxCommission - absolute maximum amount that should be taken if commission amount is higher than this value.