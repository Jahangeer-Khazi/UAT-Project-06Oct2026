/********************************************************************************************
* @name                 WaiverApprovalTriggerHandlerTest
* @description          Code coverage for WaiverApprovalTriggerHandler and WaiverApprovalTriggerHelper class.
* @date                 08/01/2026
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           08/01/2026     Initial Version
*********************************************************************************************
*/

@isTest
public class WaiverApprovalTriggerHandlerTest {

    private class AccountMockResponse implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 200;
        public Boolean isAccountAPI = false;
        public AccountMockResponse(Boolean isAccountAPI){
            this.isAccountAPI = isAccountAPI;
        }
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            //res.setBody
            res.setStatusCode(testStatusCode);
            if(isAccountAPI){
            	res.setBody('{"meta":{"code":"PROD-10000","message":"AccountList"},"data":{"totalAmountInLocalCurrency":10582.712,"localCurrency":{"code":"BHD","decimalPlaces":"3"},"accounts":[{"account":{"accountType":"CUSTOMER_ACCOUNT","availableBalance":7902.1,"branch":"BH0030096","creditGlAccount":"","creditGlAccountDescription":"","creditInterestFrequency":"","creditInterestFrequencyCode":"","currency":{"code":"BHD","decimalPlaces":"3"},"debitGlAccount":"","debitGlAccountDescription":"","debitInterestFrequency":"","debitInterestFrequencyCode":"","defaultAccount":true,"holdAmount":0,"iban":"BH04ABCO96003000721939","ledgerBalance":7902.1,"maximumBalance":0,"minimumBalance":0,"number":"3000721939","paymentsAllowed":true,"startDate":"2026-07-30","status":"Active","valueBalance":7902.1},"alias":"BHD Account","category1":"","category2":"","customerId":"6204991","detailsExist":false,"id":"BH04ABCO96003000721939","productName":"BHD Account","productType":"account","debitInterestHY":0,"minimumDepositHY":3000,"hysaRate":0},{"account":{"accountType":"CUSTOMER_ACCOUNT","availableBalance":5275.5,"branch":"BH0030096","creditGlAccount":"","creditGlAccountDescription":"","creditInterestFrequency":"","creditInterestFrequencyCode":"","currency":{"code":"GBP","decimalPlaces":"2"},"debitGlAccount":"","debitGlAccountDescription":"","debitInterestFrequency":"","debitInterestFrequencyCode":"","defaultAccount":false,"holdAmount":0,"iban":"BH79ABCO96003000721947","ledgerBalance":5275.5,"maximumBalance":0,"minimumBalance":0,"number":"3000721947","paymentsAllowed":true,"startDate":"2026-07-30","status":"Active","valueBalance":5275.5},"alias":"GBP alburaq account","category1":"","category2":"","customerId":"6204991","detailsExist":false,"id":"BH79ABCO96003000721947","productName":"GBP Account","productType":"account","debitInterestHY":0,"hysaRate":0}]}}');    
            }
            else {
                res.setBody('{ "meta":{"code":"PROD-10000","message":"AccountList"},"data" : {"isSuccess":true,"responseData":{"transactions":[{"accountCurrency":{"code":"GBP","decimalPlaces":"2"},"amount":4.44,"currentBalance":108155.36,"generateAdvice":true,"id":"214561545638414.010001","originalAmount":4.44,"previousBalance":108150.92,"reference":"AAACT262715M4TN0GR","status":"Completed","transferType":"DEPOSITS-SETTLE-SETTLEMENT","transactionCurrency":{"code":"GBP","decimalPlaces":"2"},"transactionDate":"2026-09-28T10:40:14","transactionDescription1":"FD Accrued Interest Payment","transactionDescription2":"Deposit Ref No 2011995481","transactionType":"1707","valueDate":"2026-09-28","enrichedTransactionCategory":{"id":"Investments","name":"Investments","icon":"https://images.ctfassets.net/dh72gzoq5i91/2djmtkaskTO0GlEWLbabqn/affc364a1afbcbe8a66030953db22ced/Investments__1_.png","color":"#147144","fontColor":"#FFFFFF","isCustom":false,"isEditable":false},"enrichedTransaction":{"id":"tdst","reviseName":"FD Accrued Interest Payment","name":"1707","icon":"https://images.ctfassets.net/dh72gzoq5i91/23JoaIVp1s4epwC2S9J4RG/bdd6a62b3d7f174265e20473f90bffe6/Fixed_Deposit__1_.png"}}]}}}');
            }
           	return res;
        }
    }
    
    @testSetup
    static void setupTestData(){
        createRMT();
    	createAccountAndContact();
        createBudgetRecords();
    }
    
    @isTest
    static void testCreateNewWaiverRecord(){
    	
        Account acct = [Select Id FROM Account LIMIT 1];
        
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test file content'),
            IsMajorVersion = true
        );
        insert cv;

        // Get ContentDocumentId
        ContentVersion insertedCV = [ SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];

        Id documentId = insertedCV.ContentDocumentId; 
        
        String jsonFieldData = '{"accountId":"' + acct.Id + '","contentDocumentId":"' + documentId  + '","subject":"Testing - Approve","description":"Test","caseModel":"ila","type":"Fee & Charges","subType":"Credit card - Fee & Charges","requestType":"Cash Advance","caseOrigin":"Phone","claimAmount":"1","transactionRefNumber":"43243242"}';
        
        Test.startTest();
        User u = [Select Id FROM User where username = 'testapproval_Waiver@test.com'];
        Id waiverPSId = [SELECT Id FROM PermissionSet WHERE Name = 'Wavier_Matrix_PS' LIMIT 1].Id;
        
        System.runAs(u) {
        	WaiverRequestController.createWaiverRequest(jsonFieldData,new List<String>{ documentId });
        }
        Test.stopTest();
        
        List<New_Wavier_Approval__c> newWaivers = [SELECT Id FROM New_Wavier_Approval__c WHERE CreatedDate = TODAY];
        System.assertEquals(newWaivers.isEmpty(),false);
        
        //Reassigning the owner for approval record.
        newWaivers[0].Is_Reassign__c = true;
        newWaivers[0].Route_to_Queue__c = 'CEO';
        update newWaivers;
        
        //Getting list of approval histories 
        List<WaiverRequestController.CustomApprovalResponse> approvalHisotryList = WaiverRequestController.getWaiverApprovalHistory(newWaivers[0].Id);
		//System.assertEquals(approvalHisotryList.isEmpty(),false);        
    }
    
    @isTest
    static void getAccountListTest(){
        
        Account acct = [Select Id,CIF__pc  FROM Account LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AccountMockResponse(false));
        ApiConnection.Response ilaAccount = WaiverRequestController.loadAccountList(acct.Id,false);
        ApiConnection.Response alburaqAccount = WaiverRequestController.loadAccountList(acct.Id,true);
        Test.stopTest();
    }
    
    @isTest
    static void loadAccountTransactionsTest(){
        Account acct = [Select Id,CIF__pc  FROM Account LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AccountMockResponse(true));
        ApiConnection.Response alburaqAccount = WaiverRequestController.loadAccountTransactions(acct.CIF__pc,'ila','searchparm');
        Test.stopTest();
    }
    
    @isTest
    static void testWaiverEmailHandlerService(){
    	
        Account acct = [Select Id,CIF__pc FROM Account LIMIT 1];
        
        
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test file content'),
            IsMajorVersion = true
        );
        insert cv;

        // Get ContentDocumentId
        ContentVersion insertedCV = [ SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];

        Id documentId = insertedCV.ContentDocumentId;  
        
        String res = WaiverRequestController.validateFileSize(documentId);
        System.assertEquals(res,'success');
        
        String jsonFieldData = '{"accountId":"' + acct.Id + '","contentDocumentId":"' + documentId  + '","subject":"Testing - Approve","description":"Test","caseModel":"ila","type":"Fee & Charges","subType":"Credit card - Fee & Charges","requestType":"Overlimit","caseOrigin":"Phone","claimAmount":"1","transactionRefNumber":"43243242"}';

		User u = [Select Id FROM User where username = 'testapproval_Waiver@test.com'];
        Id waiverPSId = [SELECT Id FROM PermissionSet WHERE Name = 'Wavier_Matrix_PS' LIMIT 1].Id;
        
        
        Test.startTest();
        	System.runAs(u) {
                WaiverRequestController.createWaiverRequest(jsonFieldData,new List<String>{ documentId });
            }
        Test.stopTest();
        
        List<New_Wavier_Approval__c> newWaivers = [SELECT Id,Name FROM New_Wavier_Approval__c WHERE CreatedDate = TODAY];
        System.assertEquals(newWaivers.isEmpty(),false);
        
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'New Lead from Email';
        email.plainTextBody = 'Approve\nRecord is approved now\n*   Object Record Number - ' + newWaivers[0].Name;
        email.fromAddress = UserInfo.getUserEmail();
        
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.fromAddress = UserInfo.getUserEmail();
        envelope.toAddress = Label.Waiver_Email_Service_Email;
        
        WaiverEmailHandler service = new WaiverEmailHandler();
        
        Messaging.InboundEmailResult result = service.handleInboundEmail(email, envelope);
        
        //sending same email one more time to coverage the else condition
        Messaging.InboundEmailResult result2 = service.handleInboundEmail(email, envelope);
    }

    public static void createBudgetRecords(){
        List<Budget_Matrix__c> bmList = new List<Budget_Matrix__c>();
        bmList.add(new Budget_Matrix__c(CRM_Queue__c = 'Team Leaders FAQ',Utilization__c =0,Budget__c = 500,Role_Name__c ='Team Leaders'));
        bmList.add(new Budget_Matrix__c(CRM_Queue__c = 'Head Of Contact Center FAQ',Utilization__c =0,Budget__c = 1000,Role_Name__c ='Head of Contact Center'));
        bmList.add(new Budget_Matrix__c(CRM_Queue__c = 'Product Managers FAQ',Utilization__c =0,Budget__c = 2500,Role_Name__c ='Head of Customer Service'));
        bmList.add(new Budget_Matrix__c(CRM_Queue__c = 'Product Managers FAQ',Utilization__c =0,Budget__c = 1000,Role_Name__c ='Product Manager'));
        bmList.add(new Budget_Matrix__c(CRM_Queue__c = 'Head of Propositions FAQ',Utilization__c =0,Budget__c = 2500,Role_Name__c ='Head of Proposition'));
        bmList.add(new Budget_Matrix__c(CRM_Queue__c = 'Head of Business FAQ',Utilization__c =0,Budget__c = 10000,Role_Name__c ='HoB'));
        bmList.add(new Budget_Matrix__c(CRM_Queue__c = 'CEO FAQ',Utilization__c =0,Budget__c = 20000,Role_Name__c ='CEO'));
        
        insert bmList;
        
    }    
    public static void createAccountAndContact(){
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2_lettergeneration_fcr@ilatest.com';
        acc.ID_Number__pc = '851000000';
        acc.Nationality__pc = 'BH';
        acc.PersonMailingCity = 'Muharraq';
        acc.PersonMailingCountry = 'BH ';
        acc.PersonMailingState = 'Muharraq';
        acc.PersonMailingStreet = 'Villa 2 Bldg 111 Road 222';
        acc.PersonMailingPostalCode = '455';
        acc.Language_Preference__pc = 'English';
        insert acc;
        
        /*ContentVersion cv = new ContentVersion(
        	Title = 'test file',
            PathOnClient = 'testfile.txt',
            VersionData = Blob.valueOf('Hello Testing')
        );
        insert cv;
        */
        
    }
    
    private static void createRMT(){
        User sysAdmin = new User(
            Username = 'testapproval_Waiver@test.com',
            LastName = 'test123',
            FirstName = 'test123',
            Email = 'test123_approval_rmt@gmail.com',
            Alias = 'ikart',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [Select Id FROM Profile WHERE Name = 'System Administrator'].Id
        );
        insert sysAdmin;
        
        System.runAs(sysAdmin) {
            List<String> queueNames = new List<String>();
            queueNames.add('Team_Leaders_FAQ');
            queueNames.add('Head_Of_Contact_Center_FAQ');
            queueNames.add('Head_Of_Customer_Service_FAQ');
            queueNames.add('Product_Managers_FAQ');
            queueNames.add('Head_of_Propositions_FAQ');
            queueNames.add('Head_of_Business_FAQ');
            queueNames.add('CEO_FAQ');
            List<Group> groups = [Select Id FROM Group WHERE DeveloperName IN :queueNames];
            
        	//adding queue member.
            List<GroupMember> members = new List<GroupMember>();
            for(Group grp : groups){
                members.add(new GroupMember(GroupId = grp.Id, UserOrGroupId = sysAdmin.Id));
                members.add(new GroupMember(GroupId = grp.Id, UserOrGroupId = UserInfo.getUserId()));
            }
            
            insert members;
        }
    }
    
}