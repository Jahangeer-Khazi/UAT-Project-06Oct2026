/*
Author : 
Date : 
Description : LeadTriggerHandlerTest
    #CH01# Added #22-06-2022# Document Model changes - HC
    #CH03# AITOGRAM OMAR 20/04/2026 Tests for checkBlacklistedAndClosedAccounts
*/
@isTest(seeAllData = true)
private class LeadTriggerHandlerTest
{
    static testMethod void testTriggerHandler(){
        User thisUser = [Select id from User where id =: UserInfo.getUserId() limit 1];
        User thisUser1 = [Select id from User where profile.name ='RMT' and isActive = true limit 1];
        system.runAs(thisUser){
        
            List<Lead> leadList = new List<Lead>();
            Lead ld1 = new Lead();
            ld1.LastName = 'Lead Lastname';
            ld1.Email = 'lead@test.t1';
            ld1.MobilePhone = '8767887456';
            ld1.Proof_of_Address_ID_Number__c = '353110012';
            ld1.Birthdate__c = Date.parse('12/12/2000');
            ld1.ID_Number__c = '353110012';
            ld1.ID_Expiry_Date__c = Date.parse('12/12/2028');
            ld1.Address_ID_Expiry_Date__c = Date.parse('12/12/2028');
            ld1.Residency__c = 'BH';
            ld1.Region_Flag__c = 'Bahrain';
            leadList.add(ld1);
            
            Lead ld2 = new Lead();
            ld2.LastName = 'testLead Lastname';
            ld2.Email = 'lead12@test.t1';
            ld2.MobilePhone = '353110012';
            ld2.Proof_of_Address_ID_Number__c = '353000012';
            ld2.ID_Number__c = '353000012';
            ld2.Birthdate__c = Date.parse('12/12/2000');
            ld2.Residency__c = 'BH';
            ld2.ID_Expiry_Date__c = Date.parse('12/12/2028');
            ld2.Address_ID_Expiry_Date__c = Date.parse('12/12/2028');
            ld2.Region_Flag__c = 'Bahrain';
            leadList.add(ld2);
            
            insert leadList;
            
            Content__c objCon = new Content__c();
            objCon.Lead__c = ld1.id;
            objCon.Scan_Type__c = 'POA';
            objCon.Upload_Type__c = 'Manual';
            objCon.Document_Type__c = 'CPR Extract';
            objCon.Region_Flag__c = 'Bahrain';
            objCon.has_Attachment__c = true;
            objCon.Document_Model__c='ila'; // #CH01#
            insert objCon;
            
            ld1.Status = 'Data Validation - Checker';
            ld1.Lead_Maker__c = thisUser1.id;
            update ld1;
            
            ld1.Convert_Lead_to_Prospect__c = true;
            update ld1;
            
            Test.setMock(HttpCalloutMock.class, new RestMock());
        }
    }
    
    private class RestMock implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    static testMethod void service_call() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        Test.StopTest();
    }
    
    
    static testMethod void testTriggerHandler1(){
        User thisUser = [Select id from User where id =: UserInfo.getUserId() limit 1];
        system.runAs(thisUser){
        
            Lead ld1 = new Lead();
            ld1.LastName = 'Lead Lastname';
            ld1.Email = 'lead@test.t1';
            ld1.MobilePhone = '8767887456';
            ld1.Proof_of_Address_ID_Number__c = '353110012';
            ld1.Birthdate__c = Date.parse('12/12/2000');
            ld1.ID_Number__c = '353110012';
            ld1.ID_Expiry_Date__c = Date.parse('12/12/2028');
            ld1.Address_ID_Expiry_Date__c = Date.parse('12/12/2028');
            ld1.Residency__c = 'BH';
            ld1.Region_Flag__c = 'Bahrain';
            insert ld1;
            
            LeadTriggerHandler cls = new LeadTriggerHandler();
            LeadTriggerHandler.setOwnerAsQueue(ld1.id);
            LeadTriggerHandler.setMakerQueueAsOwner(ld1.id, 'Test');
            LeadTriggerHandler.setOwnerAsSelf(ld1.id);
        }
    }

    // #CH03# Start - Tests for checkBlacklistedAndClosedAccounts
    @isTest
    static void testBlacklistedAndClosed_blockedLead() {
        Id manualOnboardingRtId = Schema.SObjectType.Lead
            .getRecordTypeInfosByDeveloperName()
            .get('Manual_Onboarding')?.getRecordTypeId();
        if (manualOnboardingRtId == null) return;

        Id customerRtId = Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName()
            .get('Customer')?.getRecordTypeId();
 
        Account blacklistedAcc = new Account();
        blacklistedAcc.LastName = 'BlacklistedJordanCustomer';
        blacklistedAcc.PersonEmail = 'blacklisted.jordan.test@example.com';
        blacklistedAcc.Region_Flag__pc = 'Jordan';
        blacklistedAcc.Blacklisted__c = true;
        blacklistedAcc.CustomerStatus__c = 'Closed';
        if (customerRtId != null) blacklistedAcc.RecordTypeId = customerRtId;
        insert blacklistedAcc;

        // Jordan Manual_Onboarding Lead with the same email — should be rejected
        Lead blockedLead = new Lead();
        blockedLead.LastName = 'BlockedLead';
        blockedLead.Email = 'blacklisted.jordan.test@example.com';
        blockedLead.MobilePhone = '0791234567';
        blockedLead.Region_Flag__c = 'Jordan';
        blockedLead.RecordTypeId = manualOnboardingRtId;
        blockedLead.Birthdate__c = Date.parse('01/01/1990');
        blockedLead.ID_Number__c = 'JO999111';
        blockedLead.ID_Expiry_Date__c = Date.parse('01/01/2030');
        blockedLead.Residency__c = 'JO';
        blockedLead.Place_of_Birth__c = 'AF';

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            insert blockedLead;
        } catch (DmlException e) {
            exceptionThrown = true;
            System.assert(
                e.getMessage().contains('blacklisted and closed'),
                'Expected blacklist error. Got: ' + e.getMessage()
            );
        }
        Test.stopTest();

        
    }

    @isTest
    static void testBlacklistedAndClosed_allowedLead() {
        Id manualOnboardingRtId = Schema.SObjectType.Lead
            .getRecordTypeInfosByDeveloperName()
            .get('Manual_Onboarding')?.getRecordTypeId();
        if (manualOnboardingRtId == null) return;

        // No blacklisted account — lead should insert successfully
        Lead allowedLead = new Lead();
        allowedLead.LastName = 'AllowedLead';
        allowedLead.Email = 'allowed.jordan.unique99@example.com';
        allowedLead.MobilePhone = '0791234568';
        allowedLead.Region_Flag__c = 'Jordan';
        allowedLead.RecordTypeId = manualOnboardingRtId;
        allowedLead.Birthdate__c = Date.parse('01/01/1990');
        allowedLead.ID_Number__c = 'JO888222';
        allowedLead.ID_Expiry_Date__c = Date.parse('01/01/2030');
        allowedLead.Residency__c = 'JO';

        Test.startTest();
        Boolean blacklistErrorThrown = false;
        try {
            insert allowedLead;
        } catch (DmlException e) {
            if (e.getMessage().contains('blacklisted and closed')) {
                blacklistErrorThrown = true;
            }
        }
        Test.stopTest();

        System.assert(!blacklistErrorThrown, 'Jordan lead with no blacklisted account match should not be blocked.');
    }

    @isTest
    static void testBlacklistedAndClosed_nonJordanLeadNotBlocked() {
        Id manualOnboardingRtId = Schema.SObjectType.Lead
            .getRecordTypeInfosByDeveloperName()
            .get('Manual_Onboarding')?.getRecordTypeId();
        if (manualOnboardingRtId == null) return;

        // Bahrain lead — checkBlacklistedAndClosedAccounts should skip (region != Jordan)
        Lead bahrainLead = new Lead();
        bahrainLead.LastName = 'BahrainLead';
        bahrainLead.Email = 'bahrain.unique.test99@example.com';
        bahrainLead.MobilePhone = '0791234569';
        bahrainLead.Region_Flag__c = 'Bahrain';
        bahrainLead.RecordTypeId = manualOnboardingRtId;
        bahrainLead.Birthdate__c = Date.parse('01/01/1990');
        bahrainLead.ID_Number__c = 'BH777333';
        bahrainLead.ID_Expiry_Date__c = Date.parse('01/01/2030');
        bahrainLead.Residency__c = 'BH';

        Test.startTest();
        Boolean blacklistErrorThrown = false;
        try {
            insert bahrainLead;
        } catch (DmlException e) {
            if (e.getMessage().contains('blacklisted and closed')) {
                blacklistErrorThrown = true;
            }
        }
        Test.stopTest();

        System.assert(!blacklistErrorThrown, 'Bahrain region lead should not be blocked by the Jordan blacklist check.');
    }
    // #CH03# End

}