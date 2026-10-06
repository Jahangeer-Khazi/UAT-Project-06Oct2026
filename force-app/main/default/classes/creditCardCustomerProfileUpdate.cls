/*     Organization : ABC Bank
*      Created By: 
*      Created Date: 
*      Change History: 
*      #CH01# #Jahangeer Mohammed# #28-06-2022# Added Logic to populate ID Number, ID Expiry Date, ID Type as per(NBA-5692 & NBA-5693)
*      #CH02# #Jahangeer Mohammed# #10-05-2023# Added Logic to populate ID Number, ID Expiry Date for Jordan Customer
*      #CH03# #Jahangeer Mohammed# #04-11-2025# Added Logic for Mailing Street Segregation for Loan and Credit Cards
	   #CH04# #Jahangeer Mohammed# #21-04-2026# Added Logic for Loan Finance Service Request(UATNB-213431)
*/

global class creditCardCustomerProfileUpdate
{ 
    public static void updateCustomerdetails(Map<Id, Id> mapCaseAcc)
    {  
        List<Account> accUpdateList = new List<Account>();
        //CH01: Added fields ID_Number__pc,ID_Expiry_Date__pc,ID_Type__pc in Parent SOQL and cc_CPR_Number__c,cc_CPR_Expiry_Date__c,cc_Approved_Salary__c in child SOQL
        //CH02: Added field ccjo_ID_Number__c, ccjo_ID_Expiry_Date__c in child SOQL and Region_Flag__pc in Parent SOQL
        //CH03: Added fields RecordType_DeveloperName__c,CaseAnnex__r.cx_ln_Address_Line__c in child SOQL
        for(Account accObj : [SELECT id,Occupation__pc,ID_Number__pc,ID_Expiry_Date__pc,Region_Flag__pc,ID_Type__pc, Passport_Number__pc, Passport_Expiry_Date__pc, Residency_Permit_Number__pc,Residency_Permit_Expiry__pc,PersonMailingCity,PersonMailingCountry,PersonMailingPostalCode,PersonMailingState,PersonMailingStreet,Employer_Country__pc,cc_Residence_Status__pc,cc_Number_of_years_at_current_residence__pc,Employer_Name__pc,Employment_Status__pc,Employer_Address__pc,cc_Length_Of_Service__pc,Gross_Monthly_Income__pc,cc_Monthly_Income_Actual__pc,cc_Number_of_Dependents__pc,cc_Academic_Qualifications__pc,cc_Friends_Name__pc,cc_Friends_Contact_Number__pc,Marital_Status__pc,         
        (SELECT id,cc_Occupation__c,cc_Number_years_at_current_residence_jo__c,cc_CPR_Number__c,cc_CPR_Expiry_Date__c,ccjo_ID_Number__c,ccjo_ID_Expiry_Date__c,cc_Approved_Salary__c, AccountId, cc_Passport_Number__c, cc_Passport_Expiry_Date__c, cc_Residence_Permit_No__c, cc_Residence_Permit_Expiry_Date__c, cc_House_Flat_Number__c, cc_Building__c, Street_Road_No__c,cc_Block_No__c, cc_City__c, cc_Country__c,cc_Residence_Occupancy_Status__c, cc_Number_of_Years_at_Current_Residence__c, cc_Employment_Status__c, cc_Employer_Name__c, cc_Employer_Address_update__c, cc_Length_Of_Service__c, cc_sys_Montly_Income__c, Monthly_Income_Actual__c, cc_Number_of_Dependents__c, cc_Academic_Qualifications__c, cc_Friend_s_Name__c, cc_Friend_s_Contact_Number__c, cc_Marital_Status__c,RecordType_DeveloperName__c,
        CaseAnnex__r.cx_ln_Address_Line__c,CaseAnnex__r.cx_ln_Postal_Code_Block__c,CaseAnnex__r.cx_ln_Employer_Address__c,CaseAnnex__r.cx_ln_Total_Approved_Income__c  from Cases WHERE Id In: mapCaseAcc.keySet()) 
        FROM Account WHERE id in: mapCaseAcc.Values()])
        {
            for(Case csObj : accObj.Cases)
            {
                if(accObj.id == csObj.AccountId)
                {
                    if(accObj.Passport_Number__pc != csObj.cc_Passport_Number__c && csObj.cc_Passport_Number__c != null)
                        accObj.Passport_Number__pc = csObj.cc_Passport_Number__c;
                    if(accObj.Passport_Expiry_Date__pc != csObj.cc_Passport_Expiry_Date__c && csObj.cc_Passport_Expiry_Date__c != null)
                        accObj.Passport_Expiry_Date__pc = csObj.cc_Passport_Expiry_Date__c;
                    if(accObj.Residency_Permit_Number__pc != csObj.cc_Residence_Permit_No__c && csObj.cc_Residence_Permit_No__c != null)
                        accObj.Residency_Permit_Number__pc = csObj.cc_Residence_Permit_No__c;
                    if(accObj.Residency_Permit_Expiry__pc != csObj.cc_Residence_Permit_Expiry_Date__c && csObj.cc_Residence_Permit_Expiry_Date__c != null)
                        accObj.Residency_Permit_Expiry__pc = csObj.cc_Residence_Permit_Expiry_Date__c;
                    if(accObj.PersonMailingCity != csObj.cc_City__c && csObj.cc_City__c != null)
                        accObj.PersonMailingCity = csObj.cc_City__c;
                    //CH03: Start
                    //CH04: Start
                    if(csObj.RecordType_DeveloperName__c != 'Loan_Application' && csObj.RecordType_DeveloperName__c != 'LoanFinanceServiceRequest'){
                       if((accObj.PersonMailingStreet != csObj.Street_Road_No__c && csObj.Street_Road_No__c != null) || (accObj.PersonMailingStreet != csObj.cc_House_Flat_Number__c && csObj.cc_House_Flat_Number__c != null))
                        accObj.PersonMailingStreet = 'Flat '+ csObj.cc_House_Flat_Number__c+', Bldng '+csObj.cc_Building__c+', Rd no '+csObj.Street_Road_No__c; 
                    }else if(csObj.RecordType_DeveloperName__c == 'Loan_Application' || csObj.RecordType_DeveloperName__c == 'LoanFinanceServiceRequest'){
                        if(accObj.PersonMailingStreet != csObj.CaseAnnex__r.cx_ln_Address_Line__c && csObj.CaseAnnex__r.cx_ln_Address_Line__c != null){
                           accObj.PersonMailingStreet =  csObj.CaseAnnex__r.cx_ln_Address_Line__c;
                        }
                    }
                    //CH04: END
                    //CH03: END
                    
                    //CH03: Start
                    //CH04: Start
                    if(csObj.RecordType_DeveloperName__c != 'Loan_Application' && csObj.RecordType_DeveloperName__c != 'LoanFinanceServiceRequest'){
                        if(accObj.PersonMailingPostalCode != csObj.cc_Block_No__c && csObj.cc_Block_No__c != null)
                            accObj.PersonMailingPostalCode = csObj.cc_Block_No__c;
                    }else if(csObj.RecordType_DeveloperName__c == 'Loan_Application' || csObj.RecordType_DeveloperName__c == 'LoanFinanceServiceRequest'){
                         if(accObj.PersonMailingPostalCode != csObj.CaseAnnex__r.cx_ln_Postal_Code_Block__c && csObj.CaseAnnex__r.cx_ln_Postal_Code_Block__c != null)
                            accObj.PersonMailingPostalCode = csObj.CaseAnnex__r.cx_ln_Postal_Code_Block__c;
                    }
                    //CH04: END
                    //CH03: END
                    
                    //CH03: Start
                    //CH04: Start
                    if(csObj.RecordType_DeveloperName__c == 'Loan_Application' || csObj.RecordType_DeveloperName__c == 'LoanFinanceServiceRequest'){
                        if(accObj.Occupation__pc != csObj.cc_Occupation__c && csObj.cc_Occupation__c != null){
                            accObj.Occupation__pc = csObj.cc_Occupation__c;
                        }
                    }
                    //CH04: END
                    //CH03: END
                    
                    if(accObj.PersonMailingCountry != csObj.cc_Country__c && csObj.cc_Country__c != null)
                        accObj.PersonMailingCountry = csObj.cc_Country__c;
                    if(accObj.cc_Residence_Status__pc != csObj.cc_Residence_Occupancy_Status__c && csObj.cc_Residence_Occupancy_Status__c != null)
                        accObj.cc_Residence_Status__pc = csObj.cc_Residence_Occupancy_Status__c;
                    //CH03: Start
                    //CH04: Start
                    if(csObj.RecordType_DeveloperName__c != 'Loan_Application' && csObj.RecordType_DeveloperName__c != 'LoanFinanceServiceRequest'){
                        if(accObj.cc_Number_of_years_at_current_residence__pc != csObj.cc_Number_of_Years_at_Current_Residence__c && csObj.cc_Number_of_Years_at_Current_Residence__c != null)
                        accObj.cc_Number_of_years_at_current_residence__pc = csObj.cc_Number_of_Years_at_Current_Residence__c;
                    }
                    else if(csObj.RecordType_DeveloperName__c == 'Loan_Application' || csObj.RecordType_DeveloperName__c == 'LoanFinanceServiceRequest'){
                        if(accObj.cc_Number_of_years_at_current_residence__pc != csObj.cc_Number_years_at_current_residence_jo__c && csObj.cc_Number_years_at_current_residence_jo__c != null)
                        accObj.cc_Number_of_years_at_current_residence__pc = csObj.cc_Number_years_at_current_residence_jo__c;
                    }
                    //CH04: END
                    //CH03: END
                    if(accObj.Employment_Status__pc != csObj.cc_Employment_Status__c && csObj.cc_Employment_Status__c != null)
                        accObj.Employment_Status__pc = csObj.cc_Employment_Status__c;
                    if(accObj.Employer_Name__pc != csObj.cc_Employer_Name__c && csObj.cc_Employer_Name__c != null)
                        accObj.Employer_Name__pc = csObj.cc_Employer_Name__c;
                    
                    //CH03: Start
                    //CH04: Start
                    if(csObj.RecordType_DeveloperName__c != 'Loan_Application' && csObj.RecordType_DeveloperName__c != 'LoanFinanceServiceRequest'){
                        if(accObj.Employer_Address__pc != csObj.cc_Employer_Address_update__c && csObj.cc_Employer_Address_update__c != null)
                        accObj.Employer_Address__pc = csObj.cc_Employer_Address_update__c;
                    }else if(csObj.RecordType_DeveloperName__c == 'Loan_Application' || csObj.RecordType_DeveloperName__c == 'LoanFinanceServiceRequest'){
                        if(accObj.Employer_Address__pc != csObj.CaseAnnex__r.cx_ln_Employer_Address__c && csObj.CaseAnnex__r.cx_ln_Employer_Address__c != null){
                            accObj.Employer_Address__pc = csObj.CaseAnnex__r.cx_ln_Employer_Address__c;
                        }else if(csObj.CaseAnnex__r.cx_ln_Employer_Address__c == null && csObj.CaseAnnex__c!=null && (accObj.Employer_Address__pc !=csObj.cc_Employer_Address_update__c) && csObj.cc_Employer_Address_update__c!=null ){
                            accObj.Employer_Address__pc = csObj.cc_Employer_Address_update__c;
                        }
                    }
                    //CH04: END
                    //CH03: END
                   
                        
                    if(accObj.cc_Length_Of_Service__pc != csObj.cc_Length_Of_Service__c && csObj.cc_Length_Of_Service__c != null)
                        accObj.cc_Length_Of_Service__pc = csObj.cc_Length_Of_Service__c;
                    
                   //CH03: Start
                   //CH04: Start
                    if(csObj.RecordType_DeveloperName__c != 'Loan_Application' && csObj.RecordType_DeveloperName__c != 'LoanFinanceServiceRequest'){
                        if(accObj.cc_Monthly_Income_Actual__pc != csObj.cc_Approved_Salary__c && csObj.cc_Approved_Salary__c != null)
                        accObj.cc_Monthly_Income_Actual__pc = csObj.cc_Approved_Salary__c; 
                    }else if(csObj.RecordType_DeveloperName__c == 'Loan_Application' || csObj.RecordType_DeveloperName__c == 'LoanFinanceServiceRequest'){
                       if(accObj.cc_Monthly_Income_Actual__pc != csObj.CaseAnnex__r.cx_ln_Total_Approved_Income__c && csObj.CaseAnnex__r.cx_ln_Total_Approved_Income__c != null) 
                           accObj.cc_Monthly_Income_Actual__pc = csObj.CaseAnnex__r.cx_ln_Total_Approved_Income__c;
                    }
                    //CH04: END
                    //CH03: END
                    
                    if(accObj.cc_Number_of_Dependents__pc != csObj.cc_Number_of_Dependents__c && csObj.cc_Number_of_Dependents__c != null)
                        accObj.cc_Number_of_Dependents__pc = csObj.cc_Number_of_Dependents__c;
                    if(accObj.cc_Academic_Qualifications__pc != csObj.cc_Academic_Qualifications__c && csObj.cc_Academic_Qualifications__c != null)
                        accObj.cc_Academic_Qualifications__pc = csObj.cc_Academic_Qualifications__c;
                    if(accObj.cc_Friends_Name__pc != csObj.cc_Friend_s_Name__c && csObj.cc_Friend_s_Name__c != null)
                        accObj.cc_Friends_Name__pc = csObj.cc_Friend_s_Name__c;
                    if(accObj.cc_Friends_Contact_Number__pc != csObj.cc_Friend_s_Contact_Number__c && csObj.cc_Friend_s_Contact_Number__c != null)
                        accObj.cc_Friends_Contact_Number__pc = csObj.cc_Friend_s_Contact_Number__c;
                    if(accObj.Marital_Status__pc != csObj.cc_Marital_Status__c && csObj.cc_Marital_Status__c != null)
                        accObj.Marital_Status__pc = csObj.cc_Marital_Status__c;
                    //CH01: Start
                    //CH02: Start Added a Region Flag in if condition
                    if(accObj.ID_Type__pc != 'Bahraini ID' && accObj.Region_Flag__pc == 'Bahrain'){
                        if(csObj.cc_CPR_Number__c != null && csObj.cc_CPR_Expiry_Date__c != null){
                            accObj.ID_Type__pc = 'Bahraini ID';
                            accObj.ID_Number__pc = csObj.cc_CPR_Number__c;
                            accObj.ID_Expiry_Date__pc = csObj.cc_CPR_Expiry_Date__c;
                        }
                        
                    }
                    //CH02: END
                     //CH02: Start Added a Region Flag in if condition
                    if(accObj.ID_Type__pc == 'Bahraini ID' && accObj.Region_Flag__pc == 'Bahrain'){
                        if(accObj.ID_Number__pc != csObj.cc_CPR_Number__c && csObj.cc_CPR_Number__c != null){
                             accObj.ID_Number__pc = csObj.cc_CPR_Number__c;
                        }
                        if(accObj.ID_Expiry_Date__pc != csObj.cc_CPR_Expiry_Date__c && csObj.cc_CPR_Expiry_Date__c != null){
                            accObj.ID_Expiry_Date__pc = csObj.cc_CPR_Expiry_Date__c;
                        }
                        
                    }
                    //CH02: END
                    //CH01: END
                    //CH02: Start
                    /*if(accObj.ID_Type__pc != 'Jordanian ID' && accObj.Region_Flag__pc == 'Jordan'){
                        accObj.ID_Type__pc = 'Jordanian ID';
                        accObj.ID_Number__pc = csObj.ccjo_ID_Number__c;
                        accObj.ID_Expiry_Date__pc = csObj.ccjo_ID_Expiry_Date__c;
                    }
                    if(accObj.ID_Type__pc == 'Jordanian ID' && accObj.Region_Flag__pc == 'Jordan'){
                        if(accObj.ID_Number__pc != csObj.ccjo_ID_Number__c ){
                             accObj.ID_Number__pc = csObj.ccjo_ID_Number__c;
                        }
                        if(accObj.ID_Expiry_Date__pc != csObj.ccjo_ID_Expiry_Date__c){
                            accObj.ID_Expiry_Date__pc = csObj.ccjo_ID_Expiry_Date__c;
                        }
                        
                    }*/
                    //CH02: END
                    accUpdateList.add(accObj);
                }
            }
        }
        if(accUpdateList.size()>0)
            update accUpdateList;
    }
      //CH01: Start
    public static void updateCustomerdetailsVIAHR(Map<Id, Id> mapCaseAcc)
    {  
        List<Account> accUpdateList = new List<Account>();
        for(Account accObj : [SELECT id,ID_Number__pc,ID_Expiry_Date__pc,ID_Type__pc,cc_Monthly_Income_Actual__pc,         
                              (SELECT id,cc_CPR_Number__c,cc_CPR_Expiry_Date__c,cc_Approved_Salary__c, AccountId from Cases WHERE Id In: mapCaseAcc.keySet()) 
                              FROM Account WHERE id in: mapCaseAcc.Values()])
        {
            for(Case csObj : accObj.Cases)
            {
                if(accObj.id == csObj.AccountId)
                {
                    if(accObj.ID_Type__pc != 'Bahraini ID'){
                        if(csObj.cc_CPR_Number__c != null && csObj.cc_CPR_Expiry_Date__c != null){
                            accObj.ID_Type__pc = 'Bahraini ID';
                            accObj.ID_Number__pc = csObj.cc_CPR_Number__c;
                            accObj.ID_Expiry_Date__pc = csObj.cc_CPR_Expiry_Date__c;
                        }
                        
                    }
                    if(accObj.ID_Type__pc == 'Bahraini ID'){
                        if(accObj.ID_Number__pc != csObj.cc_CPR_Number__c && csObj.cc_CPR_Number__c != null){
                             accObj.ID_Number__pc = csObj.cc_CPR_Number__c;
                        }
                        if(accObj.ID_Expiry_Date__pc != csObj.cc_CPR_Expiry_Date__c && csObj.cc_CPR_Expiry_Date__c != null){
                            accObj.ID_Expiry_Date__pc = csObj.cc_CPR_Expiry_Date__c;
                        }
                        
                    }
                    accUpdateList.add(accObj);
                }
            }
        }
        if(accUpdateList.size()>0)
            update accUpdateList;
    }
    //CH01: END
}