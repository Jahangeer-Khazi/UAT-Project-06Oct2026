/**
 *  Version History :
 *         #CH01 Amina BENABDELKRIM  add add new field (case model) with default value 'ila'
 *
 */@isTest
public class EnvelopeStatusHandlerTest {

    @isTest
    public static void DocusignEnvelopeStatusHandlerTest(){

        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2class@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5460046';
        insert acc;

        test.startTest();
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
        cs1.cc_Balance_Transfer_Amount__c = 170.2;
        cs1.cc_Balance_Transfer_Card_Number__c = '1234567891011123';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test';
        cs1.Case_Model__c = 'ila';//CH01
        insert cs1;

        dfsle__EnvelopeStatus__c objEnvStatus = new dfsle__EnvelopeStatus__c();
        objEnvStatus.dfsle__SourceId__c = cs1.id;
        objEnvStatus.dfsle__Status__c = 'Sent';
        insert objEnvStatus;

        objEnvStatus.dfsle__Status__c = 'Completed';
        update objEnvStatus;
    }
}