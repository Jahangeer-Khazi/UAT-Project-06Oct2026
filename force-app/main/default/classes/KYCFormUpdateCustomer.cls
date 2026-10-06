/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 12-01-2026
*       Change History: 
*        
*/
public class KYCFormUpdateCustomer {
    public static Account updateKycFormCustomer(KYC_Verification__c kyc){
        List<KYC_Form__c> kycForms = [Select Id, KYC_Verification__c,KYC_Verification__r.Account_Name__c, Account_Usage_Reason__c, Employment_Status__c, Employer_Name__c, Employment_Industry__c,Business_Industry__c,
                               Employment_Country__c, Occupation__c, Source_of_Funds__c, Gross_Monthly_Income__c, Expected_Monthly_Deposits__c, Applicable_Residency_Tax__c, 
                               Tax_Country_1__c, Tax_Country_1_ID__c, Tax_Country_2__c, Tax_Country_2_ID__c, Tax_Country_3__c, Tax_Country_3_ID__c, Tax_Country_4__c, Tax_Country_4_ID__c,
                               US_Indicia__c, FATCA_Customer__c, FATCA_Declaration_Document_Type__c, FATCA_Declaration_Timestamp__c, Estimated_Net_Worth__c, Monthly_Salary__c,
                               Annual_Dividends__c, Monthly_Rental_Income__c, Investments__c, Monthly_Business_Proceeds__c, Inheritance__c, Submitted_By__c, Submitted_On__c from KYC_Form__c where KYC_Verification__c =: kyc.id ORDER BY CreatedDate DESC LIMIT 1];
    	Account acc;
        
        if (kycForms.isEmpty()) {
            System.debug('No KYC_Form__c found for KYC Id: ' + kyc.Id);
            return null;
        }
        
        KYC_Form__c kycForm = kycForms[0];
        
        if(kycForm != null){
            acc = new Account(Id = kyc.Account_Name__c);
            if(kycForm.Account_Usage_Reason__c != null && kycForm.Account_Usage_Reason__c != ''){
                acc.Account_Opening_Reason__pc = kycForm.Account_Usage_Reason__c;
            }
            if(kycForm.Employment_Status__c != null && kycForm.Employment_Status__c != ''){
                acc.Employment_Status__pc = kycForm.Employment_Status__c; 
            }
            if(kycForm.Employer_Name__c != null && kycForm.Employer_Name__c != ''){
                acc.Employer_Name__pc = kycForm.Employer_Name__c;
            }
            if(kycForm.Business_Industry__c != null && kycForm.Business_Industry__c != ''){
                acc.Business_Industry__pc = kycForm.Business_Industry__c; 
            }
            if(kycForm.Employment_Country__c != null && kycForm.Employment_Country__c != ''){
                acc.Employer_Country__pc = kycForm.Employment_Country__c; 
            }
            if(kycForm.Occupation__c != null && kycForm.Occupation__c != ''){
                acc.Occupation__pc = kycForm.Occupation__c;
            }
            if(kycForm.Source_of_Funds__c != null && kycForm.Source_of_Funds__c != ''){
                acc.Sources_of_Funds__pc = kycForm.Source_of_Funds__c;
            }
            if(kycForm.Gross_Monthly_Income__c != null && kycForm.Gross_Monthly_Income__c != ''){
                acc.Gross_Monthly_Income__pc = kycForm.Gross_Monthly_Income__c; 
            }
            if(kycForm.Expected_Monthly_Deposits__c != null){
                acc.Expected_Monthly_deposits__pc = kycForm.Expected_Monthly_Deposits__c;
            }
            if(kycForm.Tax_Country_1__c != null && kycForm.Tax_Country_1__c != ''){
                acc.Tax_Country_1__pc = kycForm.Tax_Country_1__c;
            }
            if(kycForm.Tax_Country_1_ID__c != null && kycForm.Tax_Country_1_ID__c != ''){
                acc.Tax_Country_1_ID__pc = kycForm.Tax_Country_1_ID__c;
            }
            if(kycForm.Tax_Country_2__c != null && kycForm.Tax_Country_2__c != ''){
                acc.Tax_Country_2__pc = kycForm.Tax_Country_2__c;
            }
            if(kycForm.Tax_Country_2_ID__c != null && kycForm.Tax_Country_2_ID__c != ''){
                acc.Tax_Country_2_ID__pc = kycForm.Tax_Country_2_ID__c;
            }
            if(kycForm.Tax_Country_3__c != null && kycForm.Tax_Country_3__c != ''){
                acc.Tax_Country_3__pc = kycForm.Tax_Country_3__c;
            }
            if(kycForm.Tax_Country_3_ID__c != null && kycForm.Tax_Country_3_ID__c != ''){
                acc.Tax_Country_3_ID__pc = kycForm.Tax_Country_3_ID__c;
            }
            if(kycForm.Tax_Country_4__c != null && kycForm.Tax_Country_4__c != ''){
                acc.Tax_Country_4__pc = kycForm.Tax_Country_4__c;
            }
            if(kycForm.Tax_Country_4_ID__c != null && kycForm.Tax_Country_4_ID__c != ''){
                acc.Tax_Country_4_ID__pc = kycForm.Tax_Country_4_ID__c;
            }
            if(kycForm.FATCA_Declaration_Document_Type__c != null && kycForm.FATCA_Declaration_Document_Type__c != ''){
               acc.FATCA_Declaration_Form_Type__pc = kycForm.FATCA_Declaration_Document_Type__c;  
            }
            if(kycForm.FATCA_Declaration_Timestamp__c != null){
                acc.FATCA_Declaration_Last_Update__pc =kycForm.FATCA_Declaration_Timestamp__c;
            }
            acc.Applicable_Residency_Tax__pc = kycForm.Applicable_Residency_Tax__c; 
            acc.US_Indicia__pc = kycForm.US_Indicia__c;
            acc.FATCA_Customer__pc = kycForm.FATCA_Customer__c;
            
        }
        
        return acc; 
    }
    
    public static Source_of_Wealth__c insertSourceofWealth(KYC_Verification__c kyc){
         List<KYC_Form__c> kycForms = [Select Id, KYC_Verification__c,KYC_Verification__r.Account_Name__c, Account_Usage_Reason__c, Employment_Status__c, Employer_Name__c, Employment_Industry__c,Business_Industry__c,
                               Employment_Country__c, Occupation__c, Source_of_Funds__c, Gross_Monthly_Income__c, Expected_Monthly_Deposits__c, Applicable_Residency_Tax__c, 
                               Tax_Country_1__c, Tax_Country_1_ID__c, Tax_Country_2__c, Tax_Country_2_ID__c, Tax_Country_3__c, Tax_Country_3_ID__c, Tax_Country_4__c, Tax_Country_4_ID__c,
                               US_Indicia__c, FATCA_Customer__c, FATCA_Declaration_Document_Type__c, FATCA_Declaration_Timestamp__c, Estimated_Net_Worth__c, Monthly_Salary__c,
                               Annual_Dividends__c, Monthly_Rental_Income__c, Investments__c, Monthly_Business_Proceeds__c, Inheritance__c, Submitted_By__c, Submitted_On__c from KYC_Form__c where KYC_Verification__c =: kyc.id ORDER BY CreatedDate DESC LIMIT 1];
                    
        Source_of_Wealth__c sow = new Source_of_Wealth__c();
        
        if(kycForms.isEmpty()) {
            System.debug('No KYC_Form__c found for KYC Id: ' + kyc.Id);
            return null;
        }
        
        KYC_Form__c kycForm = kycForms[0];

        if(kycForm != null){
            if(kycForm.Annual_Dividends__c != null || kycForm.Estimated_Net_Worth__c != null || kycForm.Inheritance__c != null || kycForm.Investments__c != null || kycForm.Monthly_Business_Proceeds__c != null ||
               kycForm.Monthly_Rental_Income__c != null || kycForm.Monthly_Salary__c != null || kycForm.Submitted_By__c != null || kycForm.Submitted_On__c != null){
                   
                   sow.Customer__c = kycForm.KYC_Verification__r.Account_Name__c;
                   sow.Annual_Dividends__c = kycForm.Annual_Dividends__c;
                   sow.Estimated_Net_Worth__c = kycForm.Estimated_Net_Worth__c;
                   sow.Inheritance__c = kycForm.Inheritance__c;
                   sow.Investments__c = kycForm.Investments__c;
                   sow.Monthly_Business_Proceeds__c = kycForm.Monthly_Business_Proceeds__c;
                   sow.Monthly_Rental_Income__c = kycForm.Monthly_Rental_Income__c;
                   sow.Monthly_Salary__c = kycForm.Monthly_Salary__c;
                   sow.Submitted_By__c = kycForm.Submitted_By__c;
                   sow.Submitted_On__c = kycForm.Submitted_On__c;
               }
            
        }
        return sow;
    }
    
}