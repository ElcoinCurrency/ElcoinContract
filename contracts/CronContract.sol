contract CronContract is MultiSignedRecoverableAccount {
    // states
    MultiSigAccount cron;

    // events
    event CronAddressIsAdded(address cronAddress);
    event CronAddressIsRemoved(address cronAddress);
    event CronMultiSigCheckFailed(address origin);
    event NumberOfCronSignaturesIsChanged(uint8 signsRequired);

    // modifiers
    modifier checkCronMultiSigForAccount(bytes32 hash, uint time, bytes32[] signRSs, uint8[] signVs) {
        if(isValidMultiSig(hash, time, cron, signRSs, signVs)) {
            _
        }
        else {
            CronMultiSigCheckFailed(msg.sender);

            return;
        }
    }
}