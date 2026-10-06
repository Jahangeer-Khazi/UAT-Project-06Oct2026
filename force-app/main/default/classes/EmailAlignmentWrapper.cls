public with sharing class EmailAlignmentWrapper {
    @AuraEnabled public String crmEmail;
    @AuraEnabled public String dbEmail;
    @AuraEnabled public Boolean isAligned;
    @AuraEnabled public Integer mobileChangeCount;
    @AuraEnabled public Integer emailChangeCount;

    @AuraEnabled public String cif;

    public EmailAlignmentWrapper(String crmEmail, String dbEmail, String cif) {
        this.crmEmail = crmEmail;
        this.dbEmail = dbEmail;
        this.cif = cif;
        this.isAligned = (crmEmail == dbEmail);
        this.mobileChangeCount = 0;
        this.emailChangeCount = 0;
    }
}