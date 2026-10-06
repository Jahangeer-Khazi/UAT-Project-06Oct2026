@isTest
public with sharing class MoEngageDeleteCustomerTest {
    static Account acc1;
    static Case case1;
    
    @testSetup
    static void setup() {
        // Create test data
        acc1 = (Account)TestDataFactory.createSObject(
            new Account(CIF__pc = '1293779', Region_Flag__c = 'Bahrain', Subscription_Model__pc = 'ila'), 
            'TestFactoryDefaults.AccountDefaults', 
            true
        );
        
        case1 = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Email'
        );
        insert case1;
    }
    
    @isTest
    static void testExecute() {
        // Retrieve test accounts
        List<Account> accounts = [SELECT Id FROM Account LIMIT 5];
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        
        // Create instance of Queueable class
        MoEngageDeleteCustomer queueableJob = new MoEngageDeleteCustomer(accountIds);
        
        // Enqueue job
        Test.startTest();
        System.enqueueJob(queueableJob);
        //MoEngageDeleteCustomer.createSystemAction('test','test','test','post',cases[0].Id,'testst',accounts[0].Id,200,'test','test');
        Test.stopTest();
    }
    
    @isTest
    static void testCreateSystemAction() {
        List<Case> cases = [SELECT Id FROM Case LIMIT 5];
        
        String reqBody = '{"request":"sample"}';
        String resBody = '{"response":"sample"}';
        String path = '/moengage/user';
        String custId = [SELECT Id FROM Case LIMIT 1].Id;
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Integer statCode = 200;
        String method = 'DELETE';
        String strAction = 'MoEngageDeleteCustomer';
        
        Test.startTest();
        MoEngageDeleteCustomer.createSystemAction(reqBody, resBody, path, custId, accId, statCode, method, strAction);
        Test.stopTest();
    }
}