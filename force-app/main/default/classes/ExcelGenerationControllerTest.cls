/********************************************************************************************
* @name                 ExcelGenerationControllerTest
* @description          The test class is responsible for code coverage of ExcelGenerationController.
* @date                 23/09/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           23/09/2025     Initial Version
*********************************************************************************************
*/

@isTest
public class ExcelGenerationControllerTest {

    @testSetup
    static void setupTestData(){
    	
        createAccountAndContact();
    }
    
    @isTest
    static void generateExcelForAccountStatementTest(){
        
        Account acc = [Select Id,Region_Flag__c,CIF__pc FROM Account LIMIT 1];
        
        PageReference pageRef = Page.AccountTransactionExcel;
        Test.setCurrentPage(pageRef);
        
        String jsonBody = '{"fromDate": "2025-06-24","toDate": "2025-09-25","debitCreditIndicator": "ALL","cardAccountIndicator": "ALL","offset": 1,"pageSize": 20,"status": "ALL"}';
        
        
        final TransactionDetailsCalloutMock mock = new TransactionDetailsCalloutMock();
        mock.testBody = '{"meta": { "code": "10009", "message":"Transaction Details for Account Id has been retrieved successfully." },'+
                        '"data": {'+
                                '"transactions":[{"id":"xxxxxx","transactionDate":"2020-06-18T10:51:00","valueDate":"2020-06-18","transactionType":"ACTD","transactionCurrency":{"code":"BHD","decimalPlaces":"3"},"accountCurrency":{"code":"BHD","decimalPlaces":"3"},"transactionDescription1":"From Prashant Mohite","transactionDescription2":"xxxxxxxxxxxxx","transactionDescription3":"PERSONAL TRANSFER BHD","transactionDescription4":"","transactionDescription5":"","transactionDescription6":"","amount":75.000,"originalAmount":75.000000,"reference":"820043210000","previousBalance":0.000,"currentBalance":75.000,"generateAdvice":true,"status":"Completed"}]}}'+
                            '}'+
                        '}';
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        Blob cif = Blob.valueOf(acc.CIF__pc);
        Blob region = Blob.valueOf(acc.Region_Flag__c);
        Blob filter = Blob.valueOf(jsonBody);
        Blob datePopulated = Blob.valueOf('Y');
        Blob accountNumber = Blob.valueOf('123456789');
        Blob productName = Blob.valueOf('BHD Accoun Test');
        pageRef.getParameters().put('cifno', EncodingUtil.base64Encode(cif));	
        pageRef.getParameters().put('region', EncodingUtil.base64Encode(region));
        //pageRef.getParameters().put('filter', EncodingUtil.base64Encode(filter));
        pageRef.getParameters().put('filter', jsonBody);
        pageRef.getParameters().put('datePopulated', EncodingUtil.base64Encode(datePopulated));
        pageRef.getParameters().put('accountNumber', EncodingUtil.base64Encode(accountNumber));
        pageRef.getParameters().put('productName', EncodingUtil.base64Encode(productName));
        ExcelGenerationController obj = new ExcelGenerationController();
        Test.stopTest();
    }
    
    @isTest
    static void generateExcelForSavingPotStatementTest(){
        Account acc = [Select Id,Region_Flag__c,CIF__pc FROM Account LIMIT 1];
        
        PageReference pageRef = Page.SavingPotTransactionExcel;
        Test.setCurrentPage(pageRef);
        String jsonBody = '{"fromDate": "2025-06-24","toDate": "2025-09-25","debitCreditIndicator": "ALL","cardAccountIndicator": "ALL","offset": 1,"pageSize": 20,"status": "ALL"}';
        
        
        final TransactionDetailsCalloutMock mock = new TransactionDetailsCalloutMock();
        mock.testBody = '{"meta":{"code":"SPOT-1006","message":"List of transactions for Savings Pot has been retrieved successfully."},'+
                        '"data":{"potId":3001,"name":"Bcgxy","description":"Hcyfy","icon":"06","type":"regular","potAccountId":"BH62ABCO11814409124801","linkedAccountId":"BH37ABCO11814409101001","earnInterest":true,"status":"new",'+
                        '"transactions":['+
                            '{'+
                                '"id": "1309825",'+
                                '"transactionDate": "2020-06-08T11:14:06",'+
                                '"valueDate": "2020-06-08",'+
                                '"transactionType": "",'+
                                '"transactionCurrency": {'+
                                '"code": "BHD",'+
                                    '"decimalPlaces": "3"'+
                                    '},'+
                                '"accountCurrency": {'+
                                '"code": "BHD",'+
                                    '"decimalPlaces": "3"'+
                                    '},'+
                                '"transactionDescription1": "TRANSFERRED TO 116215191011 BHD",'+
                                '"transactionDescription2": "",'+
                                '"transactionDescription3": "",'+
                                '"transactionDescription4": "",'+
                                '"transactionDescription5": "",'+
                                '"transactionDescription6": "",'+
                                '"amount": -1000001.000,'+
                                '"originalAmount": -1000001.000000,'+
                                '"reference": "",'+
                                '"previousBalance": 1000001.000,'+
                                '"currentBalance": 0.000,'+
                                '"generateAdvice": true,'+
                                '"status": "Completed"'+
                                '}'+
                        ']}}';
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        Blob cif = Blob.valueOf(acc.CIF__pc);
        Blob region = Blob.valueOf(acc.Region_Flag__c);
        //Blob filter = Blob.valueOf(jsonBody);
        Blob potId = Blob.valueOf('potId_XXXX');
        Blob potName = Blob.valueOf('potName Test');
        Blob datePopulated = Blob.valueOf('Y');
        Blob accountNumber = Blob.valueOf('123456789');
        Blob productName = Blob.valueOf('BHD Accoun Test');
        Blob earnInterest = Blob.valueOf('true');
        Blob monthlyDepositAmount = Blob.valueOf('543.222');
        Blob goalAmount = Blob.valueOf('123.343');
        
        pageRef.getParameters().put('cifno', EncodingUtil.base64Encode(cif));	
        pageRef.getParameters().put('region', EncodingUtil.base64Encode(region));
        //pageRef.getParameters().put('filter', EncodingUtil.base64Encode(filter));
        pageRef.getParameters().put('filter', jsonBody);
        pageRef.getParameters().put('potId', EncodingUtil.base64Encode(potId));
        pageRef.getParameters().put('potName', EncodingUtil.base64Encode(potName));
        pageRef.getParameters().put('datePopulated', EncodingUtil.base64Encode(datePopulated));
        pageRef.getParameters().put('accountNumber', EncodingUtil.base64Encode(accountNumber));
        pageRef.getParameters().put('productName', EncodingUtil.base64Encode(productName));
        pageRef.getParameters().put('earnInterest', EncodingUtil.base64Encode(earnInterest));
        pageRef.getParameters().put('monthlyDepositAmount', EncodingUtil.base64Encode(monthlyDepositAmount));
        pageRef.getParameters().put('goalAmount', EncodingUtil.base64Encode(goalAmount));
        
        ExcelGenerationController obj = new ExcelGenerationController();
        Test.stopTest();
    }
    
    public static void createAccountAndContact(){
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2_creditcard_fcr@ilatest.com';
        acc.ID_Number__pc = '851000000';
        acc.Nationality__pc = 'BH';
        acc.PersonMailingCity = 'Muharraq';
        acc.PersonMailingCountry = 'BH ';
        acc.CIF__pc = '64098';
        acc.PersonMailingState = 'Muharraq';
        acc.Region_Flag__c = 'Bahrain';
        acc.PersonMailingStreet = 'Villa 2 Bldg 111 Road 222';
        acc.PersonMailingPostalCode = '455';
        insert acc;
    }
    
    public class TransactionDetailsCalloutMock implements HttpCalloutMock {
        public String testBody;
        public Integer testStatusCode = 200;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(testStatusCode);
            if (null != testBody) {
                res.setBody(testBody);
            }
            return res;
        }
    }
}