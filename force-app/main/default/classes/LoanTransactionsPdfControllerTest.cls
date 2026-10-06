@isTest
private class LoanTransactionsPdfControllerTest {
 @testSetup
    static void setup() {
        Case testCase = createTestCase();
    }

    private static Case createTestCase() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456', CustomerStatus__c=null, Archived__pc=false, Region_Flag__c = 'Bahrain' ,Subscription_Model__pc = 'ila'), 'TestFactoryDefaults.AccountDefaults', true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId=acRecordTypeId, ContactId=testAccount.PersonContactId, AccountId=testAccount.Id), 'TestFactoryDefaults.CaseDefaults', true);
        return testCase;
    }
    @isTest
    static void testConstructor() {
        Case testCase = [SELECT Id, Customer_CIF__c, Account.Name FROM Case LIMIT 1];
        String accountName = testCase.Account.Name;
        String customerId = testCase.Customer_CIF__c;
        String filters = '{"id":"1234","offSet":0,"pageSize":100,"debitCreditIndicator":"all","fromDate":"2024-06-24","toDate":"2024-09-24","status":"completed"}';
        String regionName = 'Bahrain';
        PageReference pageRef = Page.loanTransactionsVF; 
        Test.setCurrentPage(pageRef);
 
        pageRef.getParameters().put('accName', EncodingUtil.base64Encode(Blob.valueOf(accountName)));
        pageRef.getParameters().put('customerId', EncodingUtil.base64Encode(Blob.valueOf(customerId)));
         pageRef.getParameters().put('stngifyFilters', filters);
        pageRef.getParameters().put('selLoanId', EncodingUtil.base64Encode(Blob.valueOf('1234')));
        pageRef.getParameters().put('regionName', EncodingUtil.base64Encode(Blob.valueOf(regionName)));
 
        loanTransactionsPdfController controller = new loanTransactionsPdfController();
 
        System.debug('Decoded Account Name: ' + controller.decodedaccName);
        System.debug('Decoded Customer ID: ' + controller.decodedcustomerId);
        System.debug('Search Parameters JSON: ' + controller.searchParametersJson);
        System.debug('Decoded Selected Loan ID: ' + controller.decodedselLoanId);
        System.debug('Decoded Region Name: ' + controller.decodedregionName);
         
        System.assertEquals('TestIla TestIla', controller.decodedaccName);
        System.assertEquals('123456', controller.decodedcustomerId);
        System.assertEquals('1234', controller.decodedselLoanId);
        System.assertEquals('Bahrain', controller.decodedregionName);
        // Covering TransactionData and CurrencyData classes
        loanTransactionsPdfController.TransactionData transactionData = new loanTransactionsPdfController.TransactionData();
        transactionData.transactionDate = '2024-06-24';
        transactionData.transactionType = 'Type';
        transactionData.status = 'Status';
        transactionData.originalAmount = '100.00';
        loanTransactionsPdfController.CurrencyData currencyData = new loanTransactionsPdfController.CurrencyData();
        currencyData.decimalPlaces = 2;
        currencyData.code = 'USD';
        transactionData.accountCurrency = currencyData;
        transactionData.transactionDescription1 = 'Description1';
        transactionData.transactionDescription2 = 'Description2';
        transactionData.reference = 'Ref123';

        // Assert TransactionData properties
        System.assertEquals('2024-06-24', transactionData.transactionDate);
        System.assertEquals('Type', transactionData.transactionType);
        System.assertEquals('Status', transactionData.status);
        System.assertEquals('100.00', transactionData.originalAmount);
        System.assertEquals(currencyData, transactionData.accountCurrency);
        System.assertEquals('Description1', transactionData.transactionDescription1);
        System.assertEquals('Description2', transactionData.transactionDescription2);
        System.assertEquals('Ref123', transactionData.reference);
    }

     
    
   

    
 }