@isTest
public class PrizeoutControllerTest {
     @isTest
    static void PrizeoutControllerTest1() {
        Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2@ilatest.com';
            acc.Nationality__pc = 'BH';
            acc.CIF__pc = '5464546';
            acc.Segment__pc='Staff';
            insert acc;
        
        Case cs1 = new Case();
            cs1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Prizeout').getRecordTypeId();
            cs1.Subject = 'Prizeout';
            cs1.Description = 'N Prizeout';
            cs1.Type = 'Prizeout';
             // CH01 Added by KAOUTHAR ELOURAOUI  20-06-2022 *** to add new field (case model) -->
            //cs1.Case_Model__c='ila';
             // CH01 END
            cs1.cc_Name_on_the_Card__c = 'ABC';
            cs1.cc_Embossing_Line_4__c = 'XYZ';
            cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
            cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
            cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
            cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
            cs1.cc_Balance_Transfer_Amount__c = 1000;
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
            cs1.cc_Credit_Pre_Screening_Result__c = 'Discrepancy in Documents';
            //cs1.Sub_Status__c='Prizeout';
        cs1.Expiry_Days__c=2;
          insert cs1;

        test.startTest();
        PrizeoutController.getPremiumInvitationRecordType();
        test.stopTest();
    }

}