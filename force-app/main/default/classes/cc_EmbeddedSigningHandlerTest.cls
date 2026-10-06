@IsTest
private class cc_EmbeddedSigningHandlerTest {
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
    
    @IsTest
    static void testSendEnvelope() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        
        System.runAs(testUser) {            
            // Create test data
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
            Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2@ilatest.com';
            acc.PersonMobilePhone = '284923833';
            acc.Nationality__pc = 'BH';
            acc.Region_Flag__c = 'Bahrain';
            acc.Region_Flag__pc = 'Bahrain';
            acc.Segment__pc = 'Regular';
            insert acc;
            
            Set<Id> CaseIDs = new Set<Id>();
            Set<Id> CaseIDsUpdate = new Set<Id>();
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Subject = 'NewCreditCardApplicationTest';
            cs1.Description = 'Credit card Application Test for Duplicate Cards';
            cs1.Type = 'Credit Card Application';
            cs1.cc_Name_on_the_Card__c = 'ABC';
            cs1.cc_Embossing_Line_4__c = 'XYZ';
            cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
            cs1.Priority = 'High';
            cs1.Awaiting_Customer_Feedback__c = false;
            cs1.Origin = 'Phone';
            cs1.AccountId = acc.Id;
            cs1.cc_Monthly_Income__c =6000;
            cs1.cc_PCI_Id__c = '8';
            cs1.cc_Passport_Number__c = 'RT546FRGF';
            cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
            cs1.cc_Residence_Permit_No__c = '546';
            cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
            cs1.cc_Balance_Transfer_Card_Provider__c = 'Test Bank';
            cs1.cc_Balance_Transfer_Card_Number__c = '5464564546wert45';
            cs1.cc_Balance_Transfer_Amount__c = 1000;
            cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
            cs1.Sub_Type__c = 'New Credit Card';
            cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
            cs1.Case_Model__c = 'ila';
            cs1.cc_CPR_Expiry_Date__c=System.Today()+10;
            cs1.cc_CPR_Number__c='32343422';
            insert cs1;
            
            test.startTest();
                Id caseId = cs1.Id;
                String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
                String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,Account.x_canary__pc,Account.Segment__pc,Account.Nationality__pc FROM Case WHERE Id = :caseId';
                List<Case> cases = new List<Case>((List<Case>)Database.query(soqlQuery));
                Case caseObj = cases[0];
                cc_EmbeddedSigningHandler.sendEnvelope(caseObj);
                Test.setMock(HttpCalloutMock.class, new RestMock());

                //test error scenario 
                try {
                    cc_EmbeddedSigningHandler.sendEnvelope(null);
                } catch (Exception e) {
                    System.debug('Exception ...');
                }
            test.stopTest();           
        } 
    }
}