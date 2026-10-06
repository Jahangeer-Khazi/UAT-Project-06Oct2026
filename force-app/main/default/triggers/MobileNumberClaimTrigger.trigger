trigger MobileNumberClaimTrigger on Mobile_Number_Claim__c (before insert) {
    new MobileNumberClaimHandler().run();
}