@IsTest
private class Loan_CreateDocuSignEnvelopeRest_Test {

    @IsTest
    static void testCreateDocuSignEnvelope() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('Loan_Application').getRecordTypeId();

        Account testAccount = (Account)TestDataFactory.createSObject(
            new Account(CIF__pc='123456', Archived__pc=false), 
            'TestFactoryDefaults.AccountDefaults', 
            true
        );

        Case cs = (Case)TestDataFactory.createSObject(
            new Case(
                RecordTypeId = acRecordTypeId, 
                ContactId = testAccount.PersonContactId, 
                AccountId = testAccount.Id
            ), 
            'TestFactoryDefaults.CaseDefaults', 
            true
        );

        ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert cv;

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = cs.Id,
            ShareType = 'V'
        );
        insert cdl;

        Loan_DocuSignEnvelopeReqWrapper reqWrapper = new Loan_DocuSignEnvelopeReqWrapper();
        reqWrapper.cif = cs.Account.CIF__pc;
        reqWrapper.caseId = cs.Id;
        reqWrapper.channel = 'In-App';
        reqWrapper.caseModel = cs.Case_Model__c;

        String jsonString = JSON.serialize(reqWrapper);

        RestRequest req = new RestRequest(); 
        req.requestUri = '/services/apexrest/docusign_toolKit/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        User testUser = dfsle.UserMock.createDocuSignSender();
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        testUser.Region_Flag__c = 'Bahrain';
        update testUser;

        System.runAs(testUser) {
            Test.startTest();
            try {
                Loan_DocuSignEnvelopeResponseWrapper responseWrapper = 
                    Loan_CreateDocuSignEnvelopeRest.createDocuSignEnvelope();  
                System.debug('responseWrapper  >> '+ responseWrapper);
            } catch (Exception e) {
                System.debug('Exception Type: ' + e.getTypeName());
                System.debug('Exception Message: ' + e.getMessage());
                System.debug('Stack Trace: ' + e.getStackTraceString());

            }
            Test.stopTest();
        }
    }
}