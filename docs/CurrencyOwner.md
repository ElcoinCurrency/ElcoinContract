# Contract CurrencyOwner
This contract provides special registry of addresses that can invoke specific methods of contract.

## States
`MultiSigAccount currencyOwner` - registry of currency owners.
`uint8 numberOfCurrencyOwnerChangesAllowedPerDay` - number of changes allowed to `MultiSigAccount currencyOwner` or `numberOfCurrencyOwnerChangesAllowedPerDay`
`uint8 currencyOwnersTodayChanges` - number of changes done today
`uint currencyOwnerLastChangeDoneAt` - the timestamp of last action on `currencyOwner` or `numberOfCurrencyOwnerChangesAllowedPerDay`
`bool public currencyOwnerInitialized` - indicates that contract was initialized


## Events
##### event CurrencyOwnerMultiSigCheckFailed()
Event fired on failure of access to method allowed only to currency owner.

##### event CurrencyOwnerHitMaxAllowedOperations()
Event fired if currency owner tries to execute more than allowed number of actions.

##### event CurrencyOwnerHolderIsAdded(address holder)
Event fired if new address added to currency owner.

##### event CurrencyOwnerHolderIsRemoved(address holder)
Event fired if existing address was removed from currency owner.

##### event CurrencyOwnerSignaturesRequirementIsChanged(uint8 signaturesRequired)
Event fired on change of required number signatures.

## Modifiers
##### modifier checkCurrencyOwnerMultiSig(bytes32 hash, uint time, bytes32[] signRSs, uint8[] signVs)
Use this modifier to validate access to specific methods, that should be invoked only by currency owners addresses.
Params:
* hash - hash that was signed
* time - time of operation
* signRSs - array of R and S components of ECDSA signature
* signVs - array of V components of ECDSA signature

##### modifier currencyOwnerChangesAllowed()
Use this modifier to validate that no more than allowed number of actions executed today by currency owners.

## Methods
##### function initCurrencyOwner(address currencyOwnerAddress) internal returns (bool _success)
Initializing of the contract
Access:
This method can be invoked only internally from contract.
Params:
* currencyOwnerAddress - address of base currency owner address
Returns: true if initialization succeed, fails if contract is already initialized

##### function addCurrencyOwnerHolder(uint32 time, bytes32[] signRSs, uint8[] signVs, address holder)
Adding new currency owner to `currencyOwner` state variable. Hash is equal to `sha3("addCurrencyOwnerHolder", time, holder)`
Access:
This method is publicly available.
Params:
* time - time of operation
* signRSs - array of R and S components of ECDSA signature
* signVs - array of V components of ECDSA signature
* holder - address of additinal currency owner

##### function removeCurrencyOwnerHolder(address accountAddress, uint32 time,  bytes32[] signRSs, uint8[] signVs, address holder)
Removing existing currency owner from `currencyOwner` state variable. Hash is equal to `sha3("removeCurrencyOwnerHolder", time, holder)`
Access:
This method is publicly available.
Params:
* time - time of operation
* signRSs - array of R and S components of ECDSA signature
* signVs - array of V components of ECDSA signature
* holder - address of currency owner to remove

##### function changeCurrencyOwnerSignaturesRequired(uint32 time,  bytes32[] signRSs, uint8[] signVs, uint8 signaturesRequired)
Changing number of signatures required to sign hash. Hash is equal to `sha3("changeCurrencyOwnerSignaturesRequired", time, signaturesRequired)`
Access:
This method is publicly available.
Params:
* time - time of operation
* signRSs - array of R and S components of ECDSA signature
* signVs - array of V components of ECDSA signature
* signaturesRequired - new number of required signatures