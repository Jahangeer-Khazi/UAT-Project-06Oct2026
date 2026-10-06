/**
 
 *  Version History :
 *         #CH01 Amina BENABDELKRIM  add add new field (case model) with default value 'ila'
 *
 */
@isTest
public class creditCardCustomerProfileUpdateTest {

    @isTest
    public static void testUpdateCustomerDetails(){
        Account acc = new Account();
        acc.LastName = 'LastName new';
        acc.PersonEmail= 'testAcc11@gmail.test';
        acc.Mobile_Country_Code__pc = '973';
        acc.PersonMobilePhone = '645383334000';
        acc.CIF__pc = '1234567';
        acc.Referral_Code__pc='abc1234';
        acc.Segment__pc = 'Regular';
        acc.Passport_Number__pc = 'abc123xyz';
        acc.Passport_Expiry_Date__pc=System.today().addDays(100);
        acc.Residency_Permit_Number__pc='23abc123';
        acc.Residency_Permit_Expiry__pc=System.today().addDays(100);
        acc.PersonMailingCity='city';
        acc.PersonMailingCountry='country';
        acc.PersonMailingState='state';
        acc.PersonMailingStreet='street';
        acc.Employer_Country__pc='AF';
        acc.cc_Residence_Status__pc='Owned';
        acc.cc_Number_of_years_at_current_residence__pc='1 to 2 Years';
        acc.Employer_Name__pc='XYZ';
        acc.Employment_Status__pc='Employed';
        acc.Employer_Address__pc='123ABC';
        acc.cc_Length_Of_Service__pc='1 to 3 years';
        //acc.Gross_Monthly_Income__pc='2500'; 
        acc.cc_Monthly_Income_Actual__pc=6000.00;
        acc.cc_Number_of_Dependents__pc=5.00;
        acc.cc_Academic_Qualifications__pc='Post Graduate';
        acc.cc_Friends_Name__pc='Shashank';
        acc.cc_Friends_Contact_Number__pc='098123';
        acc.Marital_Status__pc='NEVER MARRIED';
        insert acc;
        
        Case objCase = new Case();
        objCase.Subject = 'Test Case';
        objCase.Type = 'Stop Jamiyah';
        objCase.Status = 'In Progress';
        objCase.Priority = 'High';
        objCase.OwnerId = userInfo.getUserId();
        objCase.Origin = 'CRM';
        objCase.ContactId = acc.PersonContactId;
        objCase.AccountId = acc.id;
        objCase.cc_Passport_Number__c='qwe123poi';
        objCase.cc_Passport_Expiry_Date__c=System.today().addDays(150);
        objCase.cc_Residence_Permit_No__c='ghjk2123';
        objCase.cc_Residence_Permit_Expiry_Date__c=System.today().addDays(150);
        objCase.cc_House_Flat_Number__c='67';
        objCase.cc_Building__c='56';
        objCase.Street_Road_No__c='98';
        objCase.cc_Block_No__c='101';
        objCase.cc_City__c='city1';
        objCase.cc_Country__c='AX';
        objCase.cc_Residence_Occupancy_Status__c='Shared';
        objCase.cc_Number_of_Years_at_Current_Residence__c='2 to 3 Years';
        objCase.cc_Employment_Status__c='Unemployed';
        objCase.cc_Employer_Name__c='ABC';
     //   objCase.cc_Employer_Address_update__c='hgfdfgh';
        objCase.cc_Length_Of_Service__c='3 to 5 years';
        objCase.cc_sys_Montly_Income__c='5000';
        objCase.Monthly_Income_Actual__c=5000.00;
        objCase.cc_Number_of_Dependents__c=2.00;
        objCase.cc_Academic_Qualifications__c='Diploma';
        objCase.cc_Friend_s_Name__c='asdf';
        objCase.cc_Friend_s_Contact_Number__c='567654';
        objCase.cc_Marital_Status__c ='Married';
        objCase.Case_Model__c='ila';//CH01
        insert objCase;
        Map<Id,Id> testcaseVsAcc = new MAp<Id,Id>();
        testcaseVsAcc.put(objCase.Id,acc.Id);
        creditCardCustomerProfileUpdate.updateCustomerdetails(testcaseVsAcc);
        creditCardCustomerProfileUpdate.updateCustomerdetailsVIAHR(testcaseVsAcc);
        }
    @isTest
    public static void testUpdateCustomerDetails2(){
        Account acc = new Account();
        acc.LastName = 'LastName new';
        acc.PersonEmail= 'testAcc11@gmail.test';
        acc.Mobile_Country_Code__pc = '973';
        acc.PersonMobilePhone = '645383334000';
        acc.CIF__pc = '1234567';
        acc.Referral_Code__pc='abc1234';
        acc.Segment__pc = 'Regular';
        acc.Passport_Number__pc = 'abc123xyz';
        acc.Passport_Expiry_Date__pc=System.today().addDays(100);
        acc.Residency_Permit_Number__pc='23abc123';
        acc.Residency_Permit_Expiry__pc=System.today().addDays(100);
        acc.PersonMailingCity='city';
        acc.PersonMailingCountry='country';
        acc.PersonMailingState='state';
        acc.PersonMailingStreet='street';
        acc.Employer_Country__pc='AF';
        acc.cc_Residence_Status__pc='Owned';
        acc.cc_Number_of_years_at_current_residence__pc='1 to 2 Years';
        acc.Employer_Name__pc='XYZ';
        acc.Employment_Status__pc='Employed';
        acc.Employer_Address__pc='123ABC';
        acc.cc_Length_Of_Service__pc='1 to 3 years';
        //acc.Gross_Monthly_Income__pc='2500'; 
        acc.cc_Monthly_Income_Actual__pc=6000.00;
        acc.cc_Number_of_Dependents__pc=5.00;
        acc.cc_Academic_Qualifications__pc='Post Graduate';
        acc.cc_Friends_Name__pc='Shashank';
        acc.cc_Friends_Contact_Number__pc='098123';
        acc.Marital_Status__pc='NEVER MARRIED';
        acc.ID_Type__pc = 'Bahraini ID';
        insert acc;
        
        Case objCase = new Case();
        objCase.Subject = 'Test Case';
        objCase.Type = 'Stop Jamiyah';
        objCase.Status = 'In Progress';
        objCase.Priority = 'High';
        objCase.OwnerId = userInfo.getUserId();
        objCase.Origin = 'CRM';
        objCase.ContactId = acc.PersonContactId;
        objCase.AccountId = acc.id;
        objCase.cc_Passport_Number__c='qwe123poi';
        objCase.cc_Passport_Expiry_Date__c=System.today().addDays(150);
        objCase.cc_Residence_Permit_No__c='ghjk2123';
        objCase.cc_Residence_Permit_Expiry_Date__c=System.today().addDays(150);
        objCase.cc_House_Flat_Number__c='67';
        objCase.cc_Building__c='56';
        objCase.Street_Road_No__c='98';
        objCase.cc_Block_No__c='101';
        objCase.cc_City__c='city1';
        objCase.cc_Country__c='AX';
        objCase.cc_Residence_Occupancy_Status__c='Shared';
        objCase.cc_Number_of_Years_at_Current_Residence__c='2 to 3 Years';
        objCase.cc_Employment_Status__c='Unemployed';
        objCase.cc_Employer_Name__c='ABC';
     //   objCase.cc_Employer_Address_update__c='hgfdfgh';
        objCase.cc_Length_Of_Service__c='3 to 5 years';
        objCase.cc_sys_Montly_Income__c='5000';
        objCase.Monthly_Income_Actual__c=5000.00;
        objCase.cc_Number_of_Dependents__c=2.00;
        objCase.cc_Academic_Qualifications__c='Diploma';
        objCase.cc_Friend_s_Name__c='asdf';
        objCase.cc_Friend_s_Contact_Number__c='567654';
        objCase.cc_Marital_Status__c ='Married';
        objCase.Case_Model__c='ila';//CH01
        objCase.cc_CPR_Number__c = '435343';
        objCase.cc_CPR_Expiry_Date__c = System.today().addDays(150);
        insert objCase;
        Map<Id,Id> testcaseVsAcc = new MAp<Id,Id>();
        testcaseVsAcc.put(objCase.Id,acc.Id);
        creditCardCustomerProfileUpdate.updateCustomerdetails(testcaseVsAcc);
        creditCardCustomerProfileUpdate.updateCustomerdetailsVIAHR(testcaseVsAcc);
        }
    @isTest
    public static void testUpdateCustomerDetails3(){
        Account acc = new Account();
        acc.LastName = 'LastName new';
        acc.PersonEmail= 'testAcc11@gmail.test';
        acc.Mobile_Country_Code__pc = '973';
        acc.PersonMobilePhone = '645383334000';
        acc.CIF__pc = '1234567';
        acc.Referral_Code__pc='abc1234';
        acc.Segment__pc = 'Regular';
        acc.Passport_Number__pc = 'abc123xyz';
        acc.Passport_Expiry_Date__pc=System.today().addDays(100);
        acc.Residency_Permit_Number__pc='23abc123';
        acc.Residency_Permit_Expiry__pc=System.today().addDays(100);
        acc.PersonMailingCity='city';
        acc.PersonMailingCountry='country';
        acc.PersonMailingState='state';
        acc.PersonMailingStreet='street';
        acc.Employer_Country__pc='AF';
        acc.cc_Residence_Status__pc='Owned';
        acc.cc_Number_of_years_at_current_residence__pc='1 to 2 Years';
        acc.Employer_Name__pc='XYZ';
        acc.Employment_Status__pc='Employed';
        acc.Employer_Address__pc='123ABC';
        acc.cc_Length_Of_Service__pc='1 to 3 years';
        //acc.Gross_Monthly_Income__pc='2500'; 
        acc.cc_Monthly_Income_Actual__pc=6000.00;
        acc.cc_Number_of_Dependents__pc=5.00;
        acc.cc_Academic_Qualifications__pc='Post Graduate';
        acc.cc_Friends_Name__pc='Shashank';
        acc.cc_Friends_Contact_Number__pc='098123';
        acc.Marital_Status__pc='NEVER MARRIED';
        acc.ID_Type__pc = 'Passport';
        insert acc;
        
        Case objCase = new Case();
        objCase.Subject = 'Test Case';
        objCase.Type = 'Stop Jamiyah';
        objCase.Status = 'In Progress';
        objCase.Priority = 'High';
        objCase.OwnerId = userInfo.getUserId();
        objCase.Origin = 'CRM';
        objCase.ContactId = acc.PersonContactId;
        objCase.AccountId = acc.id;
        objCase.cc_Passport_Number__c='qwe123poi';
        objCase.cc_Passport_Expiry_Date__c=System.today().addDays(150);
        objCase.cc_Residence_Permit_No__c='ghjk2123';
        objCase.cc_Residence_Permit_Expiry_Date__c=System.today().addDays(150);
        objCase.cc_House_Flat_Number__c='67';
        objCase.cc_Building__c='56';
        objCase.Street_Road_No__c='98';
        objCase.cc_Block_No__c='101';
        objCase.cc_City__c='city1';
        objCase.cc_Country__c='AX';
        objCase.cc_Residence_Occupancy_Status__c='Shared';
        objCase.cc_Number_of_Years_at_Current_Residence__c='2 to 3 Years';
        objCase.cc_Employment_Status__c='Unemployed';
        objCase.cc_Employer_Name__c='ABC';
     //   objCase.cc_Employer_Address_update__c='hgfdfgh';
        objCase.cc_Length_Of_Service__c='3 to 5 years';
        objCase.cc_sys_Montly_Income__c='5000';
        objCase.Monthly_Income_Actual__c=5000.00;
        objCase.cc_Number_of_Dependents__c=2.00;
        objCase.cc_Academic_Qualifications__c='Diploma';
        objCase.cc_Friend_s_Name__c='asdf';
        objCase.cc_Friend_s_Contact_Number__c='567654';
        objCase.cc_Marital_Status__c ='Married';
        objCase.Case_Model__c='ila';//CH01
        objCase.cc_CPR_Number__c = '435343';
        objCase.cc_CPR_Expiry_Date__c = System.today().addDays(150);
        insert objCase;
        Map<Id,Id> testcaseVsAcc = new MAp<Id,Id>();
        testcaseVsAcc.put(objCase.Id,acc.Id);
        creditCardCustomerProfileUpdate.updateCustomerdetails(testcaseVsAcc);
        creditCardCustomerProfileUpdate.updateCustomerdetailsVIAHR(testcaseVsAcc);
        }
    
}