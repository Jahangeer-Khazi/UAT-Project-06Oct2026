/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date: 28-11-2022
* 		Change History: 
*	     
*/
@isTest
public class FetcheKYCDocumentHashSchedulableTest {
@isTest
    static void unitTest1(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        insert acc; 
        Set<Id> caseIds = new Set<Id>();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.AccountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        caseIds.add(cs1.Id);
        Test.startTest();
        FetcheKYCDocumentHashSchedulable schedulePeriodicReview = new FetcheKYCDocumentHashSchedulable(caseIds);
        String sch ='0 48 * * * ?'; 
		System.schedule('Schedule the Periodic review Case', sch,schedulePeriodicReview);
        Test.stopTest();
    }
}