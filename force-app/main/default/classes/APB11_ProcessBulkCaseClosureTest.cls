@isTest
public class APB11_ProcessBulkCaseClosureTest {
     @isTest static void TestList()
     {
        Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId() ;
        acc1.LastName = 'LastName new';
        acc1.PersonEmail= 'testAcc11@gmail.test';
        acc1.Mobile_Country_Code__pc = '973';
        acc1.PersonMobilePhone = '645383334000';
        insert acc1;
        Case objCaseEKYC = new Case();
        objCaseEKYC.Subject = 'eKYC Signoff';
        objCaseEKYC.Description = 'eKYC Signoff';
        objCaseEKYC.Type = 'eKYC';
        objCaseEKYC.Case_Model__c='ila';//CH01
        objCaseEKYC.Status = 'In Progress';
        objCaseEKYC.Priority = 'High';
        objCaseEKYC.Origin = 'EKYC-SIGNOFF';
        objCaseEKYC.Case_Nature__c = 'RC';
        objCaseEKYC.ContactId = acc1.PersonContactId;
        objCaseEKYC.AccountId = acc1.id;
        insert objCaseEKYC;
        APB11_ProcessBulkCaseClosure APB = New APB11_ProcessBulkCaseClosure();
         Test.startTest();
            System.enqueueJob(APB);
          Test.stopTest();
     }
}