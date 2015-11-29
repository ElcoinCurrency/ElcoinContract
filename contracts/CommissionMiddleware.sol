import "Middleware"

contract CommissionMiddleware is MultiSignedMiddleware {
    // states
    bool public commissionMiddlewareInitialized;
    uint public absMinCommission;
    uint public pctCommission;
    uint public absMaxCommission;

    address commissionAddress;

    // events
    event CommissionStructureIsChanged(uint absMinCommission, uint pctCommission, uint absMaxCommission);
    event CommissionIsEarned(uint commission);
    event CommissionAddressChanged(address commissionAddress);
    event TransactionWithCommission(address from, address to, uint time, uint amount, uint commission);

    // constructor
    function initCommissionMiddleware() internal returns (bool _success) {
        if(commissionMiddlewareInitialized) {
            return false;
        }

        commissionMiddlewareInitialized = true;
    }

    // internal methods
    function _transfer(address accountAddress, address destination, uint amount) internal returns (bool _success) {
        if(accounts[accountAddress].balance >= amount) {
            accounts[accountAddress].balance = accounts[accountAddress].balance - amount;

            uint commission = calculateCommission(amount);
            uint actualTransferredAmount = amount - commission;

            accounts[destination].balance = accounts[destination].balance + actualTransferredAmount;

            TransactionWithCommission(tx.origin, destination, now, actualTransferredAmount, commission);

            accounts[commissionAddress].balance += commission;

            CommissionIsEarned(commission);

            return true;
        }

        return false;
    }

    function _changeCommissionStructure(uint absMinCmsn, uint pctCmsn, uint absMaxCmsn) internal returns (bool _success) {
        if(absMinCmsn < 0) {
            return false;
        }

        if(pctCmsn < 0 || pctCmsn > 100) {
            return false;
        }

        if(absMaxCmsn < 0 || absMaxCmsn < absMinCmsn) {
            return false;
        }

        absMinCommission = absMinCmsn;
        pctCommission = pctCmsn;
        absMaxCommission = absMaxCmsn;

        CommissionStructureIsChanged(absMinCommission, pctCommission, absMaxCommission);

        return true;
    }

    function _changeCommissionAddress(address newCommissionAddress) internal {
        commissionAddress = newCommissionAddress;

        CommissionAddressChanged(commissionAddress);
    }

    function calculateCommission(uint amount) internal returns (uint amount) {
        uint commission = amount / 100 * pctCommission;

        if(commission < absMinCommission) {
            return absMinCommission;
        }

        if(commission > absMaxCommission) {
            return absMaxCommission;
        }

        return commission;
    }
}