/*    Organization : ABC Bank
 *      Created By: Maksud Ali
 *      Created Date: 23-09-2026
 *      Change History: 
 *            Relationship Termination Account Closure Controller Coverage (NBA-16921)
*/

@isTest
public class RelationshipTerminationAccControllerTest {

    // Mock implementation
    private class MockHttpRelationshipTerminationResponseGenerator implements HttpCalloutMock {
        
        Boolean isHassala;
        
        MockHttpRelationshipTerminationResponseGenerator(Boolean isHassala){
            this.isHassala = isHassala;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            System.debug('req.endpoint ' + req.getEndpoint());
            
            String body = '';
            
            if(isHassala){
                body = '{"meta": {"code": "CPRD-4001","message": "Relationship termination validation failed"},"data": {"status": "AWATING_HASSALA_COB_CLOSURE","pendingClosureOperationId": "PCL-20260819-FF1E03A","customerProfileClosed": false,"closedAccounts": [{"iban": "BH89ABCO91002011956494","accountType": "HASSALA","unit": "ila"}],"pendingAccounts": [{"iban": "BH89ABCO91002011956494","accountType": null,"unit": null,"reason": null}],"validationErrors": null}}';
            }
            else {
                body = '{"meta": {"code": "CPRD-4001","message": "Relationship termination validation failed"},"data": {"status": "SUCCESS","pendingClosureOperationId": "PCL-20260819-FF1E03A","customerProfileClosed": false,"closedAccounts": [{"iban": "BH89ABCO91002011956494","accountType": "HASSALA","unit": "ila"}],"pendingAccounts": [{"iban": "BH89ABCO91002011956494","accountType": null,"unit": null,"reason": null}],"validationErrors": null}}';
            }
            
            res.setBody(body);
            
            res.setStatusCode(200);
            return res;
        }
    }
    
    @testSetup
    static void setupTestData() {
        createAccountAndContact();
        relationshipTerminationCase();
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
    
    @isTest
    public static void relationshipTerminationHassalaTest(){
        Case s = [Select Id,Unit_Termination__c FROM Case Where Subject = 'test case - Relationship Termination' LIMIT 1];
        
        List<Case> caseList = RelationshipTerminationAccController.getCaseDetails(s.Id);
        
        Test.setMock(HttpCalloutMock.class,new MockHttpRelationshipTerminationResponseGenerator(true));
        Test.startTest();
        ApiConnection.Response responseWithHassala =  RelationshipTerminationAccController.relationshipTerminationAccount(s.Id,s.Unit_Termination__c);
        Test.stopTest();
    }
    
    @isTest
    public static void relationshipTerminationTest(){
        Case s = [Select Id,Unit_Termination__c FROM Case Where Subject = 'test case - Relationship Termination' LIMIT 1];
        
        List<Case> caseList = RelationshipTerminationAccController.getCaseDetails(s.Id);
        
        Test.setMock(HttpCalloutMock.class,new MockHttpRelationshipTerminationResponseGenerator(false));
        Test.startTest();
        ApiConnection.Response responseWithHassala =  RelationshipTerminationAccController.relationshipTerminationAccount(s.Id,s.Unit_Termination__c);
        Test.stopTest();
    }
    
    public static void relationshipTerminationCase(){
        Account acct = [Select Id FROM Account WHERE PersonEmail = 'test2_creditcard_fcr@ilatest.com'];
        Contact cnt = [Select Id FROM Contact WHERE Email = 'test2_creditcard_fcr@ilatest.com'];
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('New_Update_Customer_Profile').getRecordTypeId();
        Case c = new Case();
        c.RecordTypeId = recordTypeId;
        c.ContactId = cnt.Id;
        c.Subject = 'test case - Relationship Termination';
        c.Description = 'test desc';
        c.Case_Model__c = 'ila';
        c.Origin = 'CRM';
        c.Case_Nature__c = 'Account Maintenance';
        c.Type = 'Relationship Termination';
        c.Sub_Type__c = 'Relationship Termination - By Customer';
        c.Unit_Termination__c = 'alburaq';
        //c.Closure_Reason__c = 'Customer Request - Customer Service Issue';
        insert c;
    }
}