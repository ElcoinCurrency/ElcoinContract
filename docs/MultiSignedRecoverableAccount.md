# Contract MultiSignedRecoverableAccount

## Structs
### MultiSigAccount
States:
* `address recovered` - if account was marked as recovered with ref to new account address
* `mapping(address => bool) holders` - mapping of address allowed to sign hash to validate operation approval
* `uint8 holdersCount` - number of holders in the mapping
* `uint8 signaturesRequired` - number of required signatures to approve operation
* `uint balance` - client account balance in virtual currency
* `uint nonce` - nonce of account to restrict `double spending` problem

## Events
##### MultiSigCheckFailed(address caller)
MultiSigCheckFailed event would fire every time when multisig authentication fails.

## Methods
##### isValidMultiSig(bytes32 hash, uint time, MultiSigAccount storage account, bytes32[] signRSs, uint8[] signVs) internal returns (bool isValid)
This method tries to recover ECDSA signatures to the signed address and to check if this address is capable to sign this account.
Access:
This method can be accessed only from contract.
Params:
* hash - uniq string that was signed by account holders
* time - nonce
* account - client account
* signRSs - one dimension array, that holds R and S of ECDSA signatures. It is constructed by [R_firstSignature, S_firstSignature, R_secondSignature, S_secondSignature, ...]
* signVs - one dimension array, that holds V of ECDSA signatures.
Returns:
* _success - true if check succeed, otherwise false

##### _addAccountHolder(MultiSigAccount storage account, address holder) internal returns (bool _success)
This method could be used to add new holders to account with extra validation.
Access:
This method can be accessed only from contract.
Params:
* account - client account
* holder - address of new holder
Returns:
* _success - true if adding succeed, otherwise false (on adding the same holder twice it will return false too).

##### _removeAccountHolder(MultiSigAccount storage account, address holder) internal returns (bool _success)
This method could be used to remove holders from account with extra validation.
Access:
This method can be accessed only from contract.
Params:
* account - client account
* holder - holder address to remove
Returns:
* _success - true if removal succeed, otherwise false(if no such holder exists or number of signatures required by account will be greater than number of holders exists).

##### _changeAccountSignaturesRequired(MultiSigAccount storage account, uint8 signaturesRequired) internal returns (bool _success)
This method could be used to change number of signatures required by account with extra validation.
Access:
This method can be invoked only from contract.
Params:
* account - client account
* signaturesRequired - number of signatures required
Returns:
* _success - true if change succeed, otherwise false (if number of holders is less than new number of signatures required by account, or if new number of signatures required equals 0).

##### _recoverAccount(MultiSigAccount storage account, address newAccountAddress) internal returns (bool _success)
This method is used to mark account as recovered.
Access:
This method can be invoked only from contract.
Params:
* account - client account
* newAccountAddress - new client account address
Returns:
* _success - true if change succeed