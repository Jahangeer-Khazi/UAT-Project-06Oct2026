@IsTest
private class TemporaryCreditHandlerTest {
    
    @IsTest
    static void testGetDocumentType() {
        User ilaRiskUser = [SELECT Id FROM User WHERE Profile.Name = 'ILA Risk' AND IsActive = true LIMIT 1];
        
        System.runAs(ilaRiskUser) {
            Case c = new Case(Subject = 'Test', Region_Flag__c = 'Bahrain');
            insert c;
            insert new CaseAnnex__c(Case__c = c.Id, Document_Type__c = 'Approval Attached');
            
            TemporaryCreditHandler.getDocumentType(c.Id);
        }
    }
    
    @IsTest
    static void testUpdateDocumentType() {
        User ilaRiskUser = [SELECT Id FROM User WHERE Profile.Name = 'ILA Risk' AND IsActive = true LIMIT 1];
        
        System.runAs(ilaRiskUser) {
            Case c = new Case(Subject = 'Test', Region_Flag__c = 'Bahrain');
            insert c;
            
            //TemporaryCreditHandler.updateDocumentType(c.Id, 'Approval Attached');
        }
    }
    
    @IsTest
    static void testGetConsolidatedRoutingDetails() {
        User ilaRiskUser = [SELECT Id FROM User WHERE Profile.Name = 'ila Risk' AND IsActive = true LIMIT 1];
        
        System.runAs(ilaRiskUser) {
            TemporaryCreditHandler.getConsolidatedRoutingDetails();
        }
    }
    
    @IsTest
    static void testHasContentRecords() {
        User ilaRiskUser = [SELECT Id FROM User WHERE Profile.Name = 'ILA Risk' AND IsActive = true LIMIT 1];
        
        System.runAs(ilaRiskUser) {
            Case c = new Case(Subject = 'Test', Region_Flag__c = 'Bahrain');
            insert c;
            //insert new Content__c(Case__c = c.Id, Document_Type__c = 'Temporary Credit Approval');
            
            TemporaryCreditHandler.hasContentRecords(c.Id, 'Temporary Credit Approval');
        }
    }
    
    @IsTest
    static void testTransferToOperationsQueue() {
        User ilaRiskUser = [SELECT Id FROM User WHERE Profile.Name = 'ILA Risk' AND IsActive = true LIMIT 1];
        
        System.runAs(ilaRiskUser) {
            Case c = new Case(Subject = 'Test', Region_Flag__c = 'Bahrain');
            insert c;
            
            TemporaryCreditHandler.transferToOperationsQueue(c.Id);
        }
    }
}