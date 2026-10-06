/**
 *  Test methods for JamiyahAccountController
 *  @author: Sopha Pum
 *  @createdDate: 2020-10-30
 *  *  History :
 *      #CH01 Added by Imane tsioucha 20-06-2022 *** add new field (case model)
 *
 */
@isTest(isParallel=true)
private class JamiyahAccountControllerTest {
    private static final String BAHRAIN_REGION = 'Bahrain';
    private static final String JORDAN_REGION = 'Jordan';
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

    @isTest
    static void testRecordTypeServiceRequest () {
        Test.startTest();
        String recordTypeId = JamiyahAccountController.recordTypeServiceRequest();
        Test.stopTest();
        List<RecordType> lstRecordTyps = [Select Id From RecordType Where SobjectType='Case' and developerName ='Jamiyah'];
        System.assertEquals(recordTypeId, lstRecordTyps[0].id);
    }

    @isTest
    static void testloadJamiyahAccountList() {
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": {"code": "","message": ""},"jameyas": [{"participantId": 4323,"participantStatus": "ACCEPTED","id": 1235,"name": "Family","icon": "icon CXP info","jameyaStatus": "ACTIVE","isOrganiser": true,"displayDesignation": "Admin","totalShares": 10,"claimedShares": 1,"totalParticipantCount": 10,"firstCollectionDate": "2020-03-07","cyclePayoutAmount":2000,"cycleContributionAmount": 200,"currency": "BHD","hasOrganiserClaimedShares": true,"upcomingPayoutDate": "2020-04-15"}]}';

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
            ApiConnection.Response response = JamiyahAccountController.loadJamiyahAccountList('xxxxxx', BAHRAIN_REGION);
        Test.stopTest();
        System.assertEquals(true, response.isSuccess);
    }

    @isTest
    static void loadJamiyahAccountDetails() {
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": {"code": "GENE 0001","message": "message"},'+
                '"data": [{"icon": "100","name": "Summer Trip Jameya","description": "Summer Trip  Jameya for ila team","currency": "BHD","cyclePaymentAmount": 1400,"cycleContributionAmount": 200,' +
                '"firstCollectionDate": "2020- 01-25","numberOfShares": 7,"numberOfAcceptedShares": 3,"inviteeIban": "xxxxxxxxxx","isAnonymous  ": false,"jameyaStatus": "NEW","totalParticipantCount": 10,' +
        '"canSendInvitations": true,"isOrganiser": true,"isParticipant": true,"isInvitee": false,' +
        '"participants": [{"id": 1002001,"fullName": "Bob Anderson","mobileNumber": "+xxxxxxxxxx","displayDesignation": "Brandon, Case","status": "DECLINED","isOrganiser": false}, ' +
                         '{"id": 1002002,"fullName": null,"mobileNumber": "+xxxxxxxxxx","displayDesignation": "Neil,  Johnson","status": "ACCEPTED","isOrganiser": false}, ' +
                         '{"id": 1002003,"fullName": "Lidmila Vilensky ","mobileNumber": "+xxxxxxxxxx","displayDesignation": "Admin, You","status": "ACCEPTED","isOrganiser": true}],' +
        '"shares": [{"index": 1,"id": 123,"participantId": 1002002,"expectedPayoutDate": "25-06- 2020","payOutStatus": "PENDING","actualPayoutDate": null,"actualPayoutAmount": null}, ' +
                   '{"index": 2,"id": 124,"participantId": 1002003,"expectedPayoutDate": "25-07- 2020","payOutStatus": "PENDING","actualPayoutDate": null,"actualPayoutAmount": null}, ' +
                   '{"index": 3,"id": 123,"participantId": null,"expectedPayoutDate": "25-08- 2020","payOutStatus": "PENDING","actualPayoutDate": null,"actualPayoutAmount": null}, ' +
                   '{"index": 4,"id": 125,"participantId": null,"expectedPayoutDate": "25-09- 2020","payOutStatus": "PENDING","actualPayoutDate": null,"actualPayoutAmount": null}, ' +
                   '{"index": 5,"id": 126,"participantId": null,"expectedPayoutDate": "25-10- 2020","payOutStatus": "PENDING","actualPayoutDate": null,"actualPayoutAmount": null}],' +
        '"payments": [{"shareDate": "25-04-2020","participants": [{"id": 123,"name": "Participant 1","phone": "1234565434","amount": 100,"payInStatus": "SUCCESS"}, ' +
                                                                '{"id": 124,"name": "Participant 2","phone": "1234565434","amount": 100,"payInStatus": "FAILED"}]}, ' +
                    '{"shareDate": "25-05-2020",    "participants": [{"id": 125,"name": "Participant 1","phone": "1234565434","amount": 100,"payInStatus": "FAILED"}, ' +
                                                                '{"id": 125,"name": "Participant 2","phone": "1234565434","amount": 100,"payInStatus": "SUCCESS"}]}]}]}';

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
            ApiConnection.Response response = JamiyahAccountController.loadJamiyahAccountDetails('xxxxxx', 'jameyaid',BAHRAIN_REGION );
        Test.stopTest();
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);
    }

    @isTest
    static void apexStopJamiyahTrue(){
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"status" : "DELETE"}';
        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Class';
        acc.PersonEmail = 'testclass@ilatest.com';
        insert acc;


        Case objCase = new Case();
        objCase.recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Jamiyah').getRecordTypeId() ;
        objCase.Subject = 'Stop Jamiyah Account';
        objCase.Jamiyah_Id__c = 2134;
        objCase.Description = 'A technical issue has occurred at an API level.';
        objCase.Type = 'Stop Jamiyah';
        // CH01 Added by Imane tsioucha 20-06-2022 *** to add new field (case model) -->
        objCase.Case_Model__c = 'ila';
         // CH01  END-->
        objCase.Status = 'In Progress';
        objCase.Priority = 'High';
        objCase.ContactId = acc.PersonContactId;
        objCase.AccountId = acc.id;
        insert objCase;

        List<Account> lstAccs = [Select CIF__pc From Account where id=: acc.id];

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        ApiConnection.Response response = JamiyahAccountController.apexStopJamiyah(lstAccs[0].CIF__pc, true, objCase.id, BAHRAIN_REGION);
        Test.stopTest();
        System.assertEquals(true, response.isSuccess);
    }

    @isTest
    static void apexStopJamiyahFalse(){
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"status" : "DELETE"}';
        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Class';
        acc.PersonEmail = 'testclass@ilatest.com';
        insert acc;

        Case objCase = new Case();
        objCase.recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Jamiyah').getRecordTypeId() ;
        objCase.Subject = 'Stop Jamiyah Account';
        objCase.Jamiyah_Id__c = 2134;
        objCase.Requested_by_Admin_new__c = true;
        objCase.Description = 'A technical issue has occurred at an API level.';
        objCase.Type = 'Stop Jamiyah';
        // CH01 Added by Imane tsioucha 20-06-2022 *** to add new field (case model) -->
        objCase.Case_Model__c='ila';
         // CH01 END-->
        objCase.Status = 'In Progress';
        objCase.Priority = 'High';
        objCase.ContactId = acc.PersonContactId;
        objCase.AccountId = acc.id;
        insert objCase;

        List<Account> lstAccs = [Select CIF__pc From Account where id=: acc.id];

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        ApiConnection.Response response = JamiyahAccountController.apexStopJamiyah(lstAccs[0].CIF__pc, false, objCase.id, BAHRAIN_REGION);
        Test.stopTest();
        System.assertEquals(true, response.isSuccess);
    }
}