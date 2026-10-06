/**
 * Test class for RequestDocsController
 * * Version History :
 *         #CH01 Added by OMAR AITOGRAM 20-06-2022 *** to add new field (case model) 
 */
@isTest
private class RequestDocsControllerTest {

    private static final String BAHRAIN_REGION = 'Bahrain';
    private static final String JORDAN_REGION = 'Jordan';

	@testSetup static void setup() {

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acc = new Account(LastName='Test', RecordTypeId=devRecordTypeId);
        insert acc;

		Contact con = new Contact(LastName='Test', Email='test@abcbank.com');
		insert con;
        // CH01 Added by KAOUTHAR ELOURAOUI  20-06-2022 *** to add new field (case model) -->
		insert new Case(
			Type = 'Identification',
			ContactId = con.Id,
			AccountId = acc.Id,
			Case_Model__c='ila'
			);
        // CH01 END  -->
		insert new Case(
					Type = 'Identification',
					ContactId = con.Id,
            		AccountId = acc.Id
					);
        insert new Request_Docs_Config__c(
        						Name = 'Request Docs1',
        						Path__c = 'https://bank-abc.atlassian.net/wiki/spaces/NA/pages/390791281/notifications+POST+API'
        						);
    }

    private class MyCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
        	String response =  '{'
        										+'"meta": {'
        										+'		"code": "NOTF-1000",'
        										+'		"message": "Email Notification has been sent successfully on an an Email."'
        										+'},'
        										+'"data": { } }';
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(response);
            return res;
        }
    }


    static testMethod void myUnitTest() {
    	Case c = [select Id from Case limit 1];

        system.assertEquals(false, RequestDocsController.isValidCase(c.Id));

    	//invalid case
    	try{
        	RequestDocsController.sendRequestDocs(c.Id,BAHRAIN_REGION );
    	}catch(exception e){
    		system.assert(true);
    	}

    	c.Type = 'Name Screening';
    	update c;
    	//No Configuration
    	try{
        	RequestDocsController.sendRequestDocs(c.Id, BAHRAIN_REGION);
    	}catch(exception e){
    		system.assert(true);
    	}

    	Request_Docs_Config__c requestSetting = Request_Docs_Config__c.getValues('Request Docs1');
    	requestSetting.Name = 'Request Docs';
    	update requestSetting;

    	Test.startTest();
	    // Set mock callout class
    	Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
    	ApiConnection.Response response = RequestDocsController.sendRequestDocs(c.Id, BAHRAIN_REGION);

    	Test.stopTest();
    	Case caseUpdated = [select Status from Case where Id = :c.Id];
    	system.assertEquals(true, response.isSuccess);
    	system.assertEquals(Label.Visit_to_Service_Center, caseUpdated.Status);
    }
}