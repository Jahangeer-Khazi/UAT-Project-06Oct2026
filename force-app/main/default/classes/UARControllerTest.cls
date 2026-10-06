@IsTest
private class UARControllerTest {
    @TestSetup
    static void setupTestData() {
        
        // Create test data
        Account testAccount = new Account();
        testAccount.FirstName = 'TestIla';
        testAccount.LastName = 'TestIla';
        testAccount.PersonEmail = 'testclass@ilatest123.com';
        testAccount.Region_Flag__c = 'Bahrain';
        testAccount.Region_Flag__pc = 'Bahrain';
        insert testAccount;
        
        // Create test UAR record
        UAR__c testUAR = new UAR__c(
            Account__c = testAccount.Id,
            Case_Model__c = 'ila',
            Type__c = 'ATM',
            Sub_Type__c = 'ATM Withdrawal',
            Transaction_Amount__c = 100.000,
            Subject__c = 'Testing',
            Description__c = 'Testing',
            Typology__c = 'Funneling;Charity front;Identity Theft;Cash Smurfing;3rd party use;Fraud;Fraud Peer-to-Peer / pooling funds;	Fraud Investment middleman;Business Use;Gambling;Others',
            MLRO_decision__c = 'Submit an STR',
            Withdrawal_Channels__c = 'ATM',
            Deposit_Channels__c = 'ATM',
            Declared_source_of_funds_del__c = 'Source;Source2',
            Transaction_Date__c = Date.today()
        );
        insert testUAR;
        
        // Create test suspicious transactions
        List<Suspicious_Transaction__c> testTransactions = new List<Suspicious_Transaction__c>();
        for (Integer i = 0; i < 3; i++) {
            testTransactions.add(new Suspicious_Transaction__c(
                Transaction_Amount__c = 1000 + (i * 500),
                Transaction_Date__c = Date.today().addDays(-i),
                UAR__c = testUAR.Id
            ));
        }
        insert testTransactions;
    }
    
    @IsTest
    static void testCreateSuspiciousTransactions() {
        // Get test UAR
        UAR__c testUAR = [SELECT Id FROM UAR__c LIMIT 1];
        
        // Create test data
        List<Suspicious_Transaction__c> newTransactions = new List<Suspicious_Transaction__c>();
        newTransactions.add(new Suspicious_Transaction__c(
            Transaction_Amount__c = 2000,
            Transaction_Date__c = Date.today(),
            UAR__c = testUAR.Id
        ));
        
        // Test with valid data
        Test.startTest();
        UARController.createSuspiciousTransactions(newTransactions);
        Test.stopTest();
        
        // Test with empty list
        UARController.createSuspiciousTransactions(new List<Suspicious_Transaction__c>());
    }
    
    @IsTest
    static void testGetTransactions() {
        // Get test UAR
        UAR__c testUAR = [SELECT Id FROM UAR__c LIMIT 1];
        
        Test.startTest();
        List<Suspicious_Transaction__c> transactions = UARController.getTransactions(testUAR.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void testDeleteTransactions() {
        // Get existing transactions
        List<Suspicious_Transaction__c> existingTransactions = [SELECT Id FROM Suspicious_Transaction__c];
        List<Id> transactionIds = new List<Id>();
        for (Suspicious_Transaction__c trans : existingTransactions) {
            transactionIds.add(trans.Id);
        }
        
        Test.startTest();
        UARController.deleteTransactions(transactionIds);
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateTransactions() {
        // Get existing transactions
        List<Suspicious_Transaction__c> existingTransactions = [SELECT Id, Transaction_Amount__c FROM Suspicious_Transaction__c];
        
        // Modify existing transactions and add a new one
        List<Suspicious_Transaction__c> transactionsToUpdate = new List<Suspicious_Transaction__c>();
        
        for (Suspicious_Transaction__c trans : existingTransactions) {
            trans.Transaction_Amount__c += 100;
            transactionsToUpdate.add(trans);
        }
        
        // Add a new transaction
        UAR__c testUAR = [SELECT Id FROM UAR__c LIMIT 1];
        transactionsToUpdate.add(new Suspicious_Transaction__c(
            Transaction_Amount__c = 3000,
            Transaction_Date__c = Date.today(),
            UAR__c = testUAR.Id
        ));
        
        Test.startTest();
        UARController.updateTransactions(transactionsToUpdate);
        Test.stopTest();
    }
    
    @IsTest
    static void testErrorHandling() {
        // Test error handling for create (pass null)
        try {
            UARController.createSuspiciousTransactions(null);
        } catch (Exception e) {}
        
        // Test error handling for delete (pass empty list)
        try {
            UARController.deleteTransactions(new List<Id>());
        } catch (Exception e) {}
        
        // Test error handling for update (pass null)
        try {
            UARController.updateTransactions(null);
        } catch (Exception e) {}
    }
}