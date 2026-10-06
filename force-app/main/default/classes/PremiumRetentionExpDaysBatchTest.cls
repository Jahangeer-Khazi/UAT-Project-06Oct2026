/*
     Version History :
 *         #CH01 Amina BENABDELKRIM  add add new field (case model) with default value 'ila'
*/
@isTest 
public class PremiumRetentionExpDaysBatchTest 
{
   static testMethod void PremiumTriggerHandlerTest(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Premium Retention').getRecordTypeId();
        Id invitationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Premium Invitation').getRecordTypeId();

            Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2@ilatest.com';
            acc.Nationality__pc = 'BH';
            acc.CIF__pc = '5464546';
            acc.Segment__pc='Staff';
            insert acc;
            
            
            Account acc1 = new Account();
            acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc1.FirstName = 'Test3';
            acc1.LastName = 'Class3';
            acc1.PersonEmail = 'test3@ilatest.com';
            acc1.Nationality__pc = 'BA';
            acc1.CIF__pc = '5464547';
            acc1.Segment__pc='Staff';
            insert acc1;
            
            Account acc2 = new Account();
            acc2.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc2.FirstName = 'Test4';
            acc2.LastName = 'Class4';
            acc2.PersonEmail = 'test4@ilatest.com';
            acc2.Nationality__pc = 'BH';
            acc2.CIF__pc = '5464548';
            acc2.Segment__pc='Staff';
            insert acc2;
            
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Sub_Status__c='Pending Customer';
            cs1.Subject = 'NewCreditCardApplicationTest';
            cs1.Description = 'Credit card Application Test for Duplicate Cards';
            cs1.Type = 'Premium Retention Application';
            cs1.ac_RequestedBy__c='Bank / CBB';
            cs1.Expiry_Days__c=2;
            cs1.Priority = 'High';
            cs1.Origin = 'Phone';
       		cs1.AccountId=acc1.Id;
       		cs1.Premium_Substatus_Changed__c=system.today().adddays(2);
            cs1.Case_Model__c='ila';//CH01
            insert cs1;
            
            Case cs2 = new Case();
            cs2.RecordTypeId = invitationRecordTypeId;
            cs2.Sub_Status__c='Pending Customer';
            cs2.Subject = 'NewCreditCardApplicationTest';
            cs2.Description = 'Credit card Application Test for Duplicate Cards';
            cs2.Type = 'Premium Retention Application';
            cs2.ac_RequestedBy__c='Bank / CBB';
            cs2.Expiry_Days__c=2;
       		cs2.AccountId=acc1.Id;
            cs2.Priority = 'High';
            cs2.Origin = 'Phone';
            cs2.Premium_Substatus_Changed__c=system.today();
            cs2.Case_Model__c='ila';//CH01
            insert cs2;
       
       		Case cs3 = new Case();
            cs3.RecordTypeId = invitationRecordTypeId;
            cs3.Sub_Status__c='Pending Customer';
            cs3.Subject = 'NewCreditCardApplicationTest';
            cs3.Description = 'Credit card Application Test for Duplicate Cards';
            cs3.Type = 'Premium Retention Application';
            cs3.ac_RequestedBy__c='Bank / CBB';
            cs3.Expiry_Days__c=2;
            cs3.Priority = 'High';
            cs3.Origin = 'Phone';
       		cs3.AccountId=acc1.Id;
       		cs3.Premium_Substatus_Changed__c=system.today().adddays(2);
            cs3.Case_Model__c='ila';//CH01
            insert cs3;

         List<Case> csList=[SELECT Id,Retention_Expiry_Days__c,RecordType_Name__c,Status,Sub_Status__c,contactEmail,OwnerId,ContactId FROM Case where status!='Closed' ];

        Test.startTest();
       BatchScheduleOnExpiryDays sh1 = new BatchScheduleOnExpiryDays();
		String sch = '0 0 5 * * ?'; system.schedule('Premium Expiry Days', sch, sh1);            
            
        Test.stopTest();
        }


}