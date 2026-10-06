/********************************************************************************************
* @name                 JordanLoanControllerTest
* @description          Test class for JordanController and Jordan trigger helper, JordanCaseEmailRouterHandler.
* @date                 08/03/2026
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           08/03/2026     Initial Version
*********************************************************************************************
*/

@isTest
public class JordanLoanControllerTest {

    // Mock implementation
    private class MockHttpJordanLoaanResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            System.debug('req.endpoint ' + req.getEndpoint());
            String body = '{"meta":{"code":"CCRD-1100","message":"Card list has been retrieved successfully."},"data":{"currentCards":[{"id":"2660030003081773","cardSequenceNumber":"0001","expiryDate":"2027-04-22","cardProductionConfigurationId":2,"productMappingCode":"PLATINUM_CASHBACK_AND_REWARD_01","cardDisplayName":"ila Blu12e","cmsCardProductId":"003","cmsCardProductType":"01","isPrimary":true,"embossName":"Hasan Abdulla","blockDate":"2023-05-09","maskedCardNumber":"511724XXXXXX1773","issueDate":"2024-04-22","provider":"Mastercard","isRequestedCard":false,"order":3000,"isDelinquent":false,"mustBeActivated":false,"isBankBlocked":false,"hasSupplementaryCardFees":false,"status":"account_cancelled_by_bank","canRequestSupplementaryCard":false,"pendingRelease":false,"cardNature":"unsecured","supportedDigitalWallets":["APPLE_PAY"],"enabledCardActions":["SETUP_AUTOMATIC_PAYMENT","CHANGE_CREDIT_LIMIT","TRANSACTIONS_CONTROL"],"cardConfigurations":[{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"1"}],"enabledMainActions":[{"mainAction":"OFFERS","status":"SHOW_ENABLED","sortOrder":7}],"primaryCardPciNumber":"2660030003081773","applicationStatus":"","blockCode":"O","pendingRequests":[]},{"id":"898989898989","cardSequenceNumber":"0001","expiryDate":"2027-04-22","cardProductionConfigurationId":2,"productMappingCode":"PLATINUM_CASHBACK_AND_REWARD_01","cardDisplayName":"ila Test","cmsCardProductId":"003","cmsCardProductType":"01","isPrimary":true,"embossName":"Hasan Abdulla","blockDate":"2023-05-09","maskedCardNumber":"511724XXXXXX1773","issueDate":"2025-04-22","provider":"Mastercard","isRequestedCard":false,"order":3000,"cardNature":"unsecured","status":"AccountCancelledByBank","primaryCardPciNumber":"2660030003081773"}],"pendingCards":[{"id":"16511","cardProductConfigurationId":2,"cardType":"01","productMappingCode":"PLATINUM_CASHBACK_AND_REWARD_01","cardDisplayName":"ila Blue","cmsCardProductId":"003","cmsCardProductType":"01","status":"PENDING","order":1000,"caseId":"5007Y00000IlpWNQAZ","embossName":"MOHAMED ALBASRI","createdDate":"2021-09-26T14:45:36","modifiedDate":"2021-09-26T14:45:36","closureDate":"2021-09-26T14:45:36","creditLimit":4000.00000,"requestType":"CREDIT_CARD_ORDER","cardConfigurations":[{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"1"}]}],"cardOptions":[{"cardProductConfigurationId":4,"productMappingCode":"TITANIUM_CO_BRAND_01","cardDisplayName":"Titanium Gulf Air","cmsCardProductId":"005","cmsCardProductType":"01","order":2,"productStatus":"ORDER","cardConfigurations":[{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"0"}],"cardNature":["unsecured","secured"]}]}}';
            if (req.getEndpoint().contains('/api/v1/loan-jo/rlos/status/')) {
            	res.setBody(body);
            }
            else {
            	res.setBody(body);    
            }
            
            res.setStatusCode(200);
            return res;
        }
    }
    
    @testSetup
    static void setupTestData() {
        Id jordanQueueId;
        List<Group> groupList = [Select Id FROM Group WHERE DeveloperName = 'Jordan_Loans_Queue'];
        if(!groupList.isEmpty()){
            jordanQueueId = groupList[0].Id;
        }
        
        //User systemAdmin = [Select Id FROM User WHERE IsActive = TRUE AND Profile.Name = 'System Administrator' LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User systemAdmin = new User(
            Alias = 'jrtest',
            Email = 'jordantestuser@jordantest.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kuwait',
            Username = 'jordantestuser' + System.currentTimeMillis() + '@jordan.com',
            IsActive = true
        );
        insert systemAdmin;
        
        System.runAs(systemAdmin) {
         	
            if(jordanQueueId == null){
                //Creating Jordan_Loans_Queue
                Group jordanQueue = new Group(
                    Name = 'Jordan Loans Queue',DeveloperName = 'Jordan_Loans_Queue',Type = 'Queue'
                );
                insert jordanQueue; 
                jordanQueueId = jordanQueue.Id;
			}
            
            GroupMember gm = new GroupMember(
                GroupId = jordanQueueId,
                UserOrGroupId = systemAdmin.Id
            );
            insert gm;   
        }
    }
    
    @isTest
    static void jordanLoanCaseTest(){
        Account accObj = (Account)TestDataFactory.createSObject(new Account(CIF__pc='234512'), 'TestFactoryDefaults.AccountDefaults',true);
        Account accObj2 = (Account)TestDataFactory.createSObject(new Account(CIF__pc='12124545'), 'TestFactoryDefaults.AccountDefaults',true);

		//Jordan_Loans_Queue        
        Jordan_Loan__c obj = new Jordan_Loan__c();
        obj.CIF__c = '234512';
        obj.Origin__c = 'App';
        obj.Subject__c = 'Test RLOS Inquiry';
        obj.Requested_Product__c = 'Secured';
        obj.Requested_Amount__c = 1;
        obj.Requested_Term__c = 1;
        insert obj;
        
        //Updating the Jordan Loan status
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new MockHttpJordanLoaanResponseGenerator());
        //Status updated to Documents Required
        obj.Status__c = 'Documents Required';
        update obj;
        
        //Status updated to Submitted
        obj.Status__c = 'Submitted';
        update obj;
        
        //Status updated to LOS Study
        obj.Status__c = 'LOS Study';
        obj.RLOS_Application_Ref__c = '000-012345-PQR-001-0';
        update obj;
        
        //Status updated to LOS Approved
        obj.Status__c = 'LOS Approved';
        update obj;
        
        //Status updated to Process Loan Contract
        obj.Status__c = 'Process Loan Contract';
        update obj;
        
        //Status updated to Ready to Disburse
        obj.Status__c = 'Ready to Disburse';
        obj.CIF__c = '12124545';
        update obj;
        
        Test.stopTest();
    }
    
    @isTest
    static void testJordanRLOSInquiryPositive(){
        Account accObj = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Jordan_Loan__c obj = new Jordan_Loan__c();
        obj.CIF__c = '123456';
        obj.Origin__c = 'App';
        obj.Subject__c = 'Test RLOS Inquiry';
        obj.Requested_Product__c = 'Secured';
        obj.Requested_Amount__c = 1;
        obj.Requested_Term__c = 1;
        obj.RLOS_Application_Ref__c = '000-012345-PQR-001-0';
        insert obj;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new MockHttpJordanLoaanResponseGenerator());
        
        ApiConnection.Response response = JordanLoanController.callRLOSInquiry(obj.Id);
        System.debug('response ' + response);
        System.assertEquals(true,response.isSuccess,'Created RLOS Inquiry');
        Test.stopTest();
        
        Jordan_Loan__c jordanLoan = [Select Id,Name FROM Jordan_Loan__c WHERE Id =: obj.Id];
        
        //Creating email and envelope objects for 'JordanCaseEmailRouterHandler' email service.
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Your case number : [' + jordanLoan.Name + ']';
        email.plainTextBody = 'Testing Jordan Loan body text, Email service functionality validating.';
        env.fromAddress = 'test@test.com';
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = Blob.valueOf('This is test file content.');
        attachment.fileName = 'test_file.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[] { attachment };
        
        Messaging.InboundEmail.TextAttachment txtAttachment = new Messaging.InboundEmail.TextAttachment();
        txtAttachment.body = 'Name,Email,Phone\nJohn Doe,john@test.com,555-1234'; // String data
        txtAttachment.fileName = 'contacts.csv';
        txtAttachment.mimeTypeSubType = 'text/csv';
        
        // 3. Attach the file to the email text attachments array
        email.textAttachments = new Messaging.InboundEmail.TextAttachment[] { txtAttachment };
        
        JordanCaseEmailRouterHandler handler = new JordanCaseEmailRouterHandler();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, env);
		System.debug('result ' + result);
        
    }
    
    @isTest
    static void testJordanRLOSInquiryNegative(){
        Account accObj = (Account)TestDataFactory.createSObject(new Account(CIF__pc='1234567'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Jordan_Loan__c obj = new Jordan_Loan__c();
        obj.CIF__c = '1234567';
        obj.Origin__c = 'App';
        obj.Subject__c = 'Test RLOS Inquiry';
        obj.Requested_Product__c = 'Secured';
        obj.Requested_Amount__c = 1;
        obj.Requested_Term__c = 1;
        insert obj;
        
        ApiConnection.Response response = JordanLoanController.callRLOSInquiry(obj.Id);
        System.debug('response ' + response);
        System.assertEquals(false,response.isSuccess,'RLOS_Application_Ref__c is not populated.');
    }
}