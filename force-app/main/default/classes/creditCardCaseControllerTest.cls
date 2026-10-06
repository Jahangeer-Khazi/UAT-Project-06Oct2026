/*     Organization : ABC Bank
*      Created By:
*      Created Date:12/12/2022
*      Description:Test class for Credit Card Case Controller
*/
 @isTest
public class creditCardCaseControllerTest {

    
    @isTest
    static void creditCardCaseTest1(){
        List<case>ccase = New List<case>();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        insert acc;
        System.debug('Account Personel Email:'+acc.PersonEmail);
        System.debug('Account Personel CIF:'+acc.CIF__pc);
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.Case_Nature__c = 'RC';
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
        cs1.Case_Model__c='ila';
        
        test.startTest();
        insert cs1;
        ccase.add(cs1);
        creditCardCaseController.getCases();
        creditCardCaseController.assignCases(ccase);
        test.stopTest();
    }
}