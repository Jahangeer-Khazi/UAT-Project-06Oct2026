/*
 * 	Change History:
 * 			#CH01# #Maksud Ali #07-01-2026 - FD Term Deposit, Button Added.
 */ 

@isTest
public class TermDepositControllerTest {
	private class MyCalloutMock implements HttpCalloutMock{
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
    
    public static Account createAccount(){
        Account acc = new Account();
        //acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.LastName = 'LastName new';
        acc.PersonEmail= 'testAcc11@gmail.test';
        acc.Mobile_Country_Code__pc = '973';
        acc.PersonMobilePhone = '645383334000';
        acc.CIF__pc = '1234567';
        acc.Referral_Code__pc='abc1234';
        acc.Segment__pc = 'Regular';
        insert acc;
        
        return acc;
    }
    public static Contact createContact(){
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Last Test';
        c.Email = 'testAcc112@gmail.test';
        c.Region_Flag__c='Bahrain';
        c.Subscription_Model__c='ila';
        insert c;
        return c;
    }
    
    @isTest
    static void unitTest1(){
        Account acc = createAccount();
        test.startTest();
         final MyCalloutMock mock = new MyCalloutMock();
         mock.testBody = '{"meta": { "code": "10009", "displayMessage": "Term deposit list has been retrieved successfully." },'+
                        '"data": {'+
                            '"termDeposits": [ '+
                            '    { '+
                            '        "urbisContractId": "989248099", '+
                            '        "sequence": "12f67bbd-8ace-4412-85bf-49cbc8178271", '+
                            '        "name": "Term Deposit 1", '+
                            '        "accountName": "Main account (BHD)", '+
                            '        "accountIBAN": "BH09ABCO10019560010101", '+
                            '        "progressCode": "ACTIVE", '+
                            '        "statusCode": "CLOSE", '+
                            '        "maskedCardNumber": "123456 **** **** 1234", '+
                            '        "startDate": "21/12/2019", '+
                            '        "matruityDate": "21/12/2019", '+
                            '        "depositAmount": "5000" '+
                            '    } '+ 
                            ' ] ' + 
                            '}'+
                        '}';
        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = TermDepositController.termDepositList(acc.CIF__pc,'Bahrain');
        ApiConnection.Response response1 = TermDepositController.termDepositMatrix(acc.CIF__pc,'Bahrain');
        ApiConnection.Response response2 = TermDepositController.termDepositDetails(acc.CIF__pc,'6453434312','Bahrain');
       test.stopTest();
    }
    
    @isTest
    static void unitTest2(){
        Account acc = createAccount();
        test.startTest();
         final MyCalloutMock mock = new MyCalloutMock();
         mock.testBody = '{"urbisContractId": "67565675756","fileOutputType":"file"}';
        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = TermDepositController.downloadTermDeposit(acc.CIF__pc,'67565675756','Bahrain');
        //TermDepositController.sendEmailWithTermDepositPdf('testabc@mail.com','TestFile');

       test.stopTest();
    }
    
    @isTest
    static void unitTest3(){
        Contact c = createContact();
        EmailTemplate e = new EmailTemplate();
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()]; 
        System.runAs(thisUser){ 
            e = new EmailTemplate (developerName = 'test', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'TermDepositReceiptDetails'); 
            insert e;
        TermDepositController.sendEmailWithTermDepositPdf(c.Email,'TestFile');
        }
    }
    @isTest
    static void unitTest4(){
        Account acc = createAccount();
        Case cs = new Case();
        cs.Subject = 'Test Case';
        cs.Description = 'Test Description';
        cs.Type = 'Term Deposit';
        cs.Status = 'In Progress';
        cs.Priority = 'High';
        cs.Origin = 'Phone';
        //cs.ContactId = acc.PersonContactId;
        cs.AccountId = acc.id;
        insert cs;
        TermDepositController.updateCaseStatus(cs.id,'TestFile');
        TermDepositController.fetchCaseStatus(cs.id);
    }
    
    //CH01 - START
    @isTest
    static void testFDButtonAccess(){
        Boolean canAccess = TermDepositController.canUserViewFDButton();
        System.assertNotEquals(null, canAccess);
    }
    //CH01 - END
    
    @isTest
    static void unitTest5(){
        Account acc = createAccount();
        Case cs = new Case();
        cs.Subject = 'Test Case 2';
        cs.Description = 'Test Description';
        cs.Type = 'Term Deposit';
        cs.Status = 'In Progress';
        cs.Priority = 'High';
        cs.Origin = 'Phone';
        //cs.ContactId = acc.PersonContactId;
        cs.AccountId = acc.id;
        insert cs;
        TermDepositController.closedCaseStatus(cs.id);
    }
}