/*    Organization : ABC Bank
 *      Created By: Maksud Ali
 *      Created Date: 27-09-2026
 *      Change History: 
 *            PlaceHoldQueueable Controller Coverage (CRM-255)
*/

@isTest
public class PlaceHoldQueueableTest {

    // Mock implementation
    private class MockHttpPlaceHoldApiResponseGenerator implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            System.debug('req.endpoint ' + req.getEndpoint());
            
            String body = '';
            
            body = '{"meta":{"code":"GET-CBS_HOLDS-TRAN-1000","message":"place hold successfully."},"data":{"holdReference":"30482e1e9ec34"}}';
            
            res.setBody(body);
            
            res.setStatusCode(200);
            return res;
        }
    }
    
    @testSetup
    static void setupTestData() {
        createAccountAndContact();
        placeholdCase();
    }
    
    @isTest
    public static void placeHoldTestwihAllAccount(){
        Set<Id> caseIds = new Set<Id>();
        
        for(Case c : [Select Id FROM Case WHERE Place_hold_on_all_Accounts__c = true]){
            caseIds.add(c.Id);
        }
        
        Test.startTest();
        System.enqueueJob(new PlaceHoldQueueable(caseIds));
        Test.stopTest();
    }
    
    @isTest
    public static void placeHoldTestwihSelectedAccount(){
        Set<Id> caseIds = new Set<Id>();
        
        for(Case c : [Select Id FROM Case WHERE Place_hold_on_all_Accounts__c = false]){
            caseIds.add(c.Id);
        }
        
        Test.startTest();
        System.enqueueJob(new PlaceHoldQueueable(caseIds));
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
    
    public static void placeholdCase(){
        Account acct = [Select Id FROM Account WHERE PersonEmail = 'test2_creditcard_fcr@ilatest.com'];
        Contact cnt = [Select Id FROM Contact WHERE Email = 'test2_creditcard_fcr@ilatest.com'];
        
        Date futureDate = Date.today().addDays(20);
        String fromDate = DateTime.newInstance(futureDate,Time.newInstance(0,0,0,0)).formatGmt('yyyy-MM-dd');
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('db_AccountHold').getRecordTypeId();
        
        Case c = new Case();
        c.RecordTypeId = recordTypeId;
        c.ContactId = cnt.Id;
        c.Subject = 'test case - Placehold Selected Acc';
        c.Description = 'test desc';
        c.Case_Model__c = 'ila';
        c.Origin = 'CRM';
        c.Case_Nature__c = 'FCR';
        c.Type = 'Place Hold';
        c.BUA_AccountsInformation__c = 'BH87ABCO91002012030153 - BHD - CUSTOMER_ACCOUNT,BH87ABCO91002012030154 - BHD - CUSTOMER_ACCOUNT';
        c.RHA_HoldAmount__c = '3';
        c.RHA_HoldExpiryDate__c = fromDate;
        c.Hold_Description__c = 'test description';
        c.Sub_Status__c = 'In-Progress';
        c.Place_hold_on_all_Accounts__c = false;
        insert c;
        
        Case c1 = new Case();
        c1.RecordTypeId = recordTypeId;
        c1.ContactId = cnt.Id;
        c1.Subject = 'test case - Placehold All Acc';
        c1.Description = 'test desc';
        c1.Case_Model__c = 'ila';
        c1.Origin = 'CRM';
        c1.Case_Nature__c = 'FCR';
        c1.Type = 'Place Hold';
        c1.BUA_AccountsInformation__c = 'BH87ABCO91002043530153 - BHD - CUSTOMER_ACCOUNT';
        c1.RHA_HoldAmount__c = '5';
        c.RHA_HoldExpiryDate__c = fromDate;
        c1.Hold_Description__c = 'test description';
        c1.Sub_Status__c = 'In-Progress';
        c1.Place_hold_on_all_Accounts__c = true;
        insert c1;
    }
}