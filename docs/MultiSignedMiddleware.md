# Contract MultiSignedMiddleware
This contract inherits `MultiSignedRecoverableAccount` contract to get base methods of operating on account.

## States
`mapping (address => MultiSigAccount) public accounts` - mapping of accounts addresses to structs that holds all info about account.
`bool public middlewareInitialized` - checking that Middleware initialized. This variable is marked as true only by initMiddleware method.

## Events
##### event Transaction(address from, address to, uint time, uint amount);
Transaction event is fired on every transaction done.

##### event AccountHolderIsAdded(address accountAddress, address holder);
Event fired on successful account holder adding.

##### event AccountHolderIsRemoved(address accountAddress, address holder);
Event fired on successful account holder removing.

##### event AccountHoldersSignaturesRequirementIsChanged(address accountAddress, uint8 signatures);
Event fired on change of required number signatures.

##### event AccountIsRecovered(address accountAddress, address newAccountAddress, uint transferredBalance);
Event fired on recovering account.

##### event OneSigCheckFailed(address);
Event fired on one sig verification failed.

##### event OperationOnRecoveredAccountForbidden(address accountAddress);
Event fired if account recovering failed.

## Methods
##### function initMiddleware(address preminedAccount, uint amount) internal returns(bool _success)
This method should be called in constructor of inherited contract.
Access:
This method can be accessed only from contract.
Params:
* preminedAccount - address of account, where premined asset will be places
* amount - premined amount
Returns:
* _success - true if check succeed, otherwise false


##### function addAccountHolder(address accountAddress, uint32 time, bytes32[] signRSs, uint8[] signVs, address holder)
This method should be called to add new account holder to account. This method requires multi signature signing. The hash that should be signed is equal to sha3("addAccountHolder", accountAddress, time, holder).
Access:
This method is publicly available.
Params:
* accountAddress - address of account
* time - time of operation
* signRSs - array of R and S components of ECDSA signature
* signVs - array of V components of ECDSA signature
* holder - holder address that should be added to client account

##### function removeAccountHolder(address accountAddress, uint32 time,  bytes32[] signRSs, uint8[] signVs, address holder)
This method should be called to add remove account holder from account. This method requires multi signature signing. The hash that should be signed is equal to sha3("removeAccountHolder", accountAddress, time, holder).
Access:
This method is publicly available.
Params:
* accountAddress - address of account
* time - time of operation
* signRSs - array of R and S components of ECDSA signature
* signVs - array of V components of ECDSA signature
* holder - holder address that should be added to client account

##### function changeAccountSignaturesRequired(address accountAddress, uint32 time,  bytes32[] signRSs, uint8[] signVs, uint8 signaturesRequired)
This method should be called to change number of required signatures. This method requires multi signature signing. The hash that should be signed is equal to sha3("changeAccountsignaturesRequired", accountAddress, time, signaturesRequired).
Access:
This method is publicly available.
Params:
* accountAddress - address of account
* time - time of operation
* signRSs - array of R and S components of ECDSA signature
* signVs - array of V components of ECDSA signature
* signaturesRequired - number of signatures required

##### function recoverAccount(address accountAddress, uint32 time,  bytes32[] signRSs, uint8[] signVs, address recoveredAddress)
This method should be called to recover account by transfering all balance to another account. This method requires multi signature signing. The hash that should be signed is equal to sha3("recoverAccount", accountAddress, time, recoveredAddress), time, signRSs, signVs).
Access:
This method is publicly available.
Params:
* accountAddress - address of account
* time - time of operation
* signRSs - array of R and S components of ECDSA signature
* signVs - array of V components of ECDSA signature
* recoveredAddress - new account address

##### function transfer(address accountAddress, uint32 time,  bytes32[] signRSs, uint8[] signVs, address destination, uint amount)
This method should be called to transfer from one account to another. This method requires multi signature signing. The hash that should be signed is equal to sha3("transfer", accountAddress, time, destination, amount).
Access:
This method is publicly available.
Params:
* accountAddress - address of account
* time - time of operation
* signRSs - array of R and S components of ECDSA signature
* signVs - array of V components of ECDSA signature
* destination - receiver account address
* amount - amount of asset
Returns: true if operation succeed, otherwise fail

##### getAccountBalance(address accountAddress) constant returns(uint balance)
This method should be called to get balance of account.
Access:
This method is publicly available.
Params:
* accountAddress - address of account
Returns: account balance

##### function transfer(address destination, uint amount) returns (bool _success)
Before transfering assets this method checks that msg.sender has account in mapping, it is not recovered, receiver is not recovered.
Access:
This method is publicly available.
Params:
* destination - address of receiver
Returns: account balance

##### function _transfer(address accountAddress, address destination, uint amount) internal returns (bool _success)
This method implements the transfer logic. It is used by by `transfer` methods, and if you want to override `transfer` method BL than it is the best place to do it.
Access:
This method is invoked only from contract.
Params:
* accountAddress - account address
* destination - receiver address
* amount - amount of asset to be transfered
Returns: true if transfer succeed, false if account address doesn't not have enough asset amount
