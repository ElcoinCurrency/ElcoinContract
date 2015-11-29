# Contract CommissionMiddleware
This contract inherits `MultiSignedMiddleware` contract and overrides _transfer method to apply commission.

## States
`bool public commissionMiddlewareInitialized` - checking than Commission middleware is initialized. That method is marked as true only by `initCommissionMiddleware` method.
`uint absMinCommission` - absolute min commission amount that should be applied to asset transfer.
`uint pctCommission` - commission percent.
`uint absMaxCommission` - absolute max commission amount that should be applied to asset transfer.
`address commissionAddress` - address where the commission should be transfered to.

## Events

##### event TransactionWithCommission(address from, address to, uint time, uint amount, uint commission)
Transaction event is fired on every transaction done with commission info.

##### event CommissionStructureIsChanged(uint absMinCommission, uint pctCommission, uint absMaxCommission)
Event fired on successful change of commission structure.

##### event CommissionIsEarned(uint commission)
Event fired on successful earn of commission.

##### event CommissionAddressChanged(address accountAddress, uint8 signatures);
Event fired on change of address where commission is transfered.

## Methods
##### function initCommissionMiddleware() internal returns (bool _success)
This method should be called in constructor of inherited contract.
Access:
This method can be accessed only from contract.
Returns:
* _success - true if check succeed, otherwise false

##### function \_transfer(address accountAddress, address destination, uint amount) internal returns (bool \_success)
This method overrides \_transfer method and applies commission.
Access:
This method is invoked only from contract.
Params:
* accountAddress - address of account
* destination - address of receiver
* amount - amount of asset transfered
Returns: true if transfer succeed, otherwise fail

##### function \_changeCommissionStructure(uint absMinCmsn, uint pctCmsn, uint absMaxCmsn) internal returns (bool _success)
This method should be called to change commission structure.
Access:
This method is invoked only from contract.
Params:
* absMinCommission - absolute min commission amount that should be applied to asset transfer.
* pctCommission - commission percent.
* absMaxCommission - absolute max commission amount that should be applied to 
Returns: true if commission structure is correct, otherwise fail

##### function \_changeCommissionAddress(address newCommissionAddress) internal
This method should be called to change address where commission is transfered.
Access:
This method is invoked only from contract.
Params:
* newCommissionAddress - new commission address

##### function calculateCommission(uint amount) internal returns (uint)
This method calculates what commission should be taken from provided amount.
Access:
This method is invoked only from contract.
Params:
* amount - amount of asset
Returns: amount of commission