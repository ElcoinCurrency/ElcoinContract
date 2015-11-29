# Contract CronContract
This contract provides special registry of addresses that can invoke specific methods of contract.

## States
`MultiSigAccount cron` - registry of addresses.

## Events
event CronAddressIsAdded(address cronAddress)
Event fired on additional cron addresses added.

event CronAddressIsRemoved(address cronAddress)
Event fired on successful cron address removal.

##### event CronMultiSigCheckFailed(address origin)
Event fired if cron authentication fails.

##### event NumberOfCronSignaturesIsChanged(uint8 signsRequired)
Event fired on change of required number signatures.

## Modifiers
##### modifier checkCronMultiSigForAccount(bytes32 hash, uint time, bytes32[] signRSs, uint8[] signVs)
Use this modifier to validate access to specific methods, that should be invoked by cron addresses.
Params:
* hash - hash that was signed
* time - time of operation
* signRSs - array of R and S components of ECDSA signature
* signVs - array of V components of ECDSA signature