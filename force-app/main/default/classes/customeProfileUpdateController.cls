/*    Organization : ABC Bank
 *      Created By: Prashant Kulshrestha
 *      Created Date: 07-06-2022
 *      Change History: 
 *            
*/

public class customeProfileUpdateController {
    
    private static ApiConnection con = new ApiConnection();
    
    @future(callout=true)
    public static void updateProfile_onAccount(Set<Id> accNew,Set<Id> caseId) {
        system.debug('Null Prashant'+accNew);
        List<System_Action__c> lst = new List<System_Action__c>();
        List<Case> cases = DM002_Case.getListByIds(caseId);
        List<Account> accList = new List<Account>();
        List<Case> caseListToUpdate = new List<Case>();
        
        Account acc = [select id,LastName, ID_Number_Update__pc,ID_Type_Update__pc,ID_Expiry_Date_Update__pc ,LastName_Update__pc,MiddleName_Update__pc,FirstName_Update__pc,Mailing_Country_Update__pc,Postcode_Block_Update__pc,
                       Mailing_City_Update__pc,Mailing_Street_Update__pc,Proof_of_Address_Id_Update__pc,Proof_of_Address_ID_Type_Update__pc,Address_ID_Expiry_Date_Update__pc,Email_Update__pc,PersonEmail,CIF__pc,Region_Flag__c,
                       Mobile_Update__pc,Mobile_Country_Code_Update__pc,Mailing_Area__c,Mailing_Building_Number__c,Mailing_Apartment_Number__c,Gross_Monthly_Income__pc,Expected_Monthly_deposits__pc,Other_Sources_of_Fund__pc,
                       Expected_Amount_Range__pc,Employer_Address__pc,Employer_City__pc,Employer_Country__pc,Mailing_Area_Update__pc,Mailing_Building_Number_Update__pc,Mailing_Apartment_Number_Update__pc,Gross_Monthly_Income_Update__pc,
                       Expected_Monthly_deposits_Update__pc,Other_Sources_of_Fund_Update__pc,Expected_Amount_Range_Update__pc,Employer_Address_Update__pc,Employer_City_Update__pc,
                       Employer_Country_Update__pc from account where id=:accNew limit 1];
        
        System.debug('Details of Account:'+acc);
        Map<String, Object> fieldsToValue = acc.getPopulatedFieldsAsMap();//SP: 06-11-2020 add to avoid condition error SOQL without querying the requested field
        
        Map<String, object> mapReq = new Map<String, object>();
        //MobileInformation
        map<String, String> conInfo = new map<String, String>();
        If(fieldsToValue.containsKey('Email_Update__pc') && String.isNotBlank(acc.Email_Update__pc)){
           conInfo.put('email', acc.Email_Update__pc);
        }else{
           conInfo.put('email', acc.PersonEmail);
        } 
        If(fieldsToValue.containsKey('Mobile_Country_Code_Update__pc') && String.isNotBlank(acc.Mobile_Country_Code_Update__pc))
            conInfo.put('mobileCountryCode', acc.Mobile_Country_Code_Update__pc);
        If(fieldsToValue.containsKey('Mobile_Update__pc') && String.isNotBlank(acc.Mobile_Update__pc)) 
            conInfo.put('mobileNumber', acc.Mobile_Update__pc);
        mapReq.put('contactInformation', conInfo);
        
       
        map<String, string> perInfo = new map<String, String>();
        If(fieldsToValue.containsKey('FirstName_Update__pc') && String.isNotBlank(acc.FirstName_Update__pc)) 
            perInfo.put('firstName', acc.FirstName_Update__pc);
        If(fieldsToValue.containsKey('MiddleName_Update__pc') && String.isNotBlank(acc.MiddleName_Update__pc)) 
            perInfo.put('middleName', acc.MiddleName_Update__pc);
        If(fieldsToValue.containsKey('LastName_Update__pc') && String.isNotBlank(acc.LastName_Update__pc)) 
            perInfo.put('lastName', acc.LastName_Update__pc);
        mapReq.put('personalInformation', perInfo);
        
        
        //idInformation
        map<String, string> idInfo = new map<String, String>();
        If(fieldsToValue.containsKey('ID_Expiry_Date_Update__pc') && acc.ID_Expiry_Date_Update__pc != null){
            String expiryDate = DateTime.newInstance(acc.ID_Expiry_Date_Update__pc.year(), acc.ID_Expiry_Date_Update__pc.month(), acc.ID_Expiry_Date_Update__pc.day()).format('yyyy-MM-dd');
            idInfo.put('idExpiryDate', expiryDate);
        }
        If(fieldsToValue.containsKey('ID_Nationality__pc') && String.isNotBlank(acc.ID_Nationality__pc)) 
            idInfo.put('documentCountry', acc.ID_Nationality__pc);
        If(fieldsToValue.containsKey('ID_Type_Update__pc') && String.isNotBlank(acc.ID_Type_Update__pc)) 
            idInfo.put('idType', acc.ID_Type_Update__pc);
        If(fieldsToValue.containsKey('ID_Number_Update__pc') && String.isNotBlank(acc.ID_Number_Update__pc)) 
            idInfo.put('idNumber', acc.ID_Number_Update__pc);
        
        mapReq.put('idInformation', idInfo);
        
        //addressInformation
        map<String, String> addInfo = new map<String, String>();
        If(fieldsToValue.containsKey('Mailing_Street_Update__pc') && String.isNotBlank(acc.Mailing_Street_Update__pc)) 
            addInfo.put('address1', acc.Mailing_Street_Update__pc);
        If(fieldsToValue.containsKey('Mailing_City_Update__pc') && String.isNotBlank(acc.Mailing_City_Update__pc )) 
            addInfo.put('city', acc.Mailing_City_Update__pc);
        If(fieldsToValue.containsKey('Postcode_Block_Update__pc') && String.isNotBlank(acc.Postcode_Block_Update__pc  )) 
            addInfo.put('postalCode', acc.Postcode_Block_Update__pc );
        If(fieldsToValue.containsKey('Mailing_Country_Update__pc') && String.isNotBlank(acc.Mailing_Country_Update__pc   )) 
            addInfo.put('country', acc.Mailing_Country_Update__pc  );
        If(fieldsToValue.containsKey('Proof_of_Address_ID_Type_Update__pc') && String.isNotBlank(acc.Proof_of_Address_ID_Type_Update__pc )) 
            addInfo.put('proofOfAddressIDType', acc.Proof_of_Address_ID_Type_Update__pc);
        If(fieldsToValue.containsKey('Proof_of_Address_Id_Update__pc') && String.isNotBlank(acc.Proof_of_Address_Id_Update__pc )) 
            addInfo.put('proofOfAddressId', acc.Proof_of_Address_Id_Update__pc);
        if(fieldsToValue.containsKey('Address_ID_Expiry_Date_Update__pc') && acc.Address_ID_Expiry_Date_Update__pc != null){
            String proofOfAddressIdExpiryDate = DateTime.newInstance(acc.Address_ID_Expiry_Date_Update__pc.year(),
                                                                     acc.Address_ID_Expiry_Date_Update__pc.month(),
                                                                     acc.Address_ID_Expiry_Date_Update__pc.day()).format('yyyy-MM-dd');
            addInfo.put('proofOfAddressIdExpiryDate', proofOfAddressIdExpiryDate);
        }
        mapReq.put('addressInformation', addInfo); 
        
        
       
         for(Case caseObj : cases){
            final String path = '/api/v1/customers?source=crm';
            Http http = new Http();
            HttpRequest req = new HttpRequest(); 
            req =con.createRequest('PUT', path, acc.CIF__pc ,acc.PersonEmail, acc.Region_Flag__c);  
             req.setBody(JSON.serialize(mapReq));
             req.setHeader('userId', acc.PersonEmail);
             req.setTimeout(120000);
             System.debug('Get Body:'+req.getBody());
             HttpResponse response1 = http.send(req);
            if(response1.getStatusCode() != 200){
                System.debug('Invalid Status Code from API');
                System_Action__c actionRecord = SM001_ApiCalls.setSystemAction( req.getBody(),response1.getBody(),
                                                    req.getEndpoint() ,req.getMethod(),
                                                    caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response1.getStatusCode(), 
                                                    'Customer Update Profile', 'Update Customer Profile'
                                                );
                lst.add(actionRecord);
                }
            else{
            system.debug('@@@@'+acc.Mobile_Update__pc);
            system.debug('@@@@'+acc.Mobile_Country_Code_Update__pc);
            acc.PersonMobilePhone = acc.Mobile_Update__pc;
            acc.Mobile_Country_Code__pc = acc.Mobile_Country_Code_Update__pc;
            acc.Mobile_Update__pc = acc.Mobile_Update__pc;
            acc.Mobile_Country_Code_Update__pc = acc.Mobile_Country_Code_Update__pc;
           // acc.Email_Update__pc =  acc.PersonEmail;
            If(String.isNotBlank(acc.Email_Update__pc)){
               acc.PersonEmail = acc.Email_Update__pc;
            }else{
              acc.Email_Update__pc = acc.PersonEmail;
            }
            acc.Proof_of_Address_ID_Type__pc = acc.Proof_of_Address_ID_Type_Update__pc;
            acc.Address_ID_Expiry_Date__pc = acc.Address_ID_Expiry_Date_Update__pc;
            acc.Proof_of_Address_Id__pc = acc.Proof_of_Address_Id_Update__pc;
            acc.PersonMailingStreet = acc.Mailing_Street_Update__pc;
            acc.PersonMailingCity = acc.Mailing_City_Update__pc;
            acc.PersonMailingPostalCode = acc.Postcode_Block_Update__pc;
            acc.PersonMailingCountry = acc.Mailing_Country_Update__pc;
           // acc.FirstName = acc.FirstName_Update__pc;
           // acc.MiddleName = acc.MiddleName_Update__pc;
            If(String.isNotBlank(acc.LastName_Update__pc)){
               acc.LastName = acc.LastName_Update__pc;
               acc.FirstName = acc.FirstName_Update__pc;
               acc.MiddleName = acc.MiddleName_Update__pc;
            }else{
              acc.LastName_Update__pc = acc.LastName;
            }
            acc.ID_Expiry_Date__pc = acc.ID_Expiry_Date_Update__pc;
            acc.ID_Type__pc = acc.ID_Type_Update__pc;
            acc.ID_Number__pc = acc.ID_Number_Update__pc;
                
                if(acc.Region_Flag__c == 'Jordan') {
                    acc.Mailing_Area__c = acc.Mailing_Area_Update__pc;
                    acc.Mailing_Building_Number__c = acc.Mailing_Building_Number_Update__pc;
                    acc.Mailing_Apartment_Number__c = acc.Mailing_Apartment_Number_Update__pc;
                    acc.Gross_Monthly_Income__pc = acc.Gross_Monthly_Income_Update__pc;
                    
                    acc.Expected_Monthly_deposits__pc = acc.Expected_Monthly_deposits_Update__pc;
                    acc.Mailing_Building_Number__c = acc.Mailing_Building_Number_Update__pc;
                    acc.Other_Sources_of_Fund__pc = acc.Other_Sources_of_Fund_Update__pc;
                    acc.Expected_Amount_Range__pc = acc.Expected_Amount_Range_Update__pc;
                    acc.Employer_Address__pc = acc.Employer_Address_Update__pc;
                    acc.Employer_City__pc = acc.Employer_City_Update__pc;
                    acc.Employer_Country__pc = acc.Employer_Country_Update__pc;
                }
            
                if(caseObj.origin == 'ekey') {
                    acc.eKYC_IDandV_Document_Upload_Hash__pc = '';
                }
                
            //acc.Email_Update__pc = acc.Email_Update__pc;
            accList.add(acc);
                
                
            
            caseObj.Status = 'Closed';
            caseListToUpdate.add(caseObj);
                System.debug('Getting Success Status Code from API');
            }
          } // for loop Ends  
          
           If(accList != null && accList.size()>0){
            update acc; //update again to Update Original field 
            } 
            if(caseListToUpdate != null && caseListToUpdate.size()>0){
            update caseListToUpdate;
            }
            if(lst != null && lst.size()>0){
            insert lst;
            }    
        
    }
    public static void updateProfileForAdditionalInfor(Set<Id> accNew,Set<Id> caseId) {
        List<Case> cases = DM002_Case.getListByIds(caseId);
        List<Account> acList = [select id, Document_Country_Update__pc, ID_Nationality__pc, Nationality__pc ,Nationality_Update__pc, Place_of_Birth__pc ,Place_of_Birth_Update__pc, Passport_Expiry_Date__pc,Passport_Expiry_Date_Update__pc, Passport_Number__pc ,Passport_Number_Update__pc,Account_Opening_Reason__pc, Account_Opening_Reason_Update__pc,Employer_Country_Update__pc, Employer_Country__pc ,Employer_Address__pc,Employer_Address_Update__pc,Residency_Permit_Expiry__pc,Residency_Permit_Expiry_Update__pc,Residency_Permit_Number__pc ,Residency_Permit_Number_Update__pc,US_Indicia__pc,US_Indicia_Update__pc,Applicable_Residency_Tax__pc,Applicable_Residency_Tax_Update__pc,Tax_Country_4_ID__pc,Tax_Country_4_ID_Update__pc,Tax_Country_4__pc,Tax_Country_4_Update__pc,Tax_Country_3_ID__pc,Tax_Country_3_ID_Update__pc,Tax_Country_3__pc,Tax_Country_3_Update__pc ,Tax_Country_2_ID__pc,Tax_Country_2_ID_Update__pc,Tax_Country_2__pc,Tax_Country_2_Update__pc,Tax_Country_1_ID__pc,Tax_Country_1_ID_Update__pc,Tax_Country_1__pc,Tax_Country_1_Update__pc,Fatca_Customer__pc,Fatca_Customer_Update__pc,Expected_Monthly_deposits__pc,Expected_Monthly_deposits_Update__pc,Source_Found_specify__pc,Source_of_Funds_please_specify_Update__pc,Sources_of_Funds__pc,Sources_of_Funds_Update__pc,Business_Industry__pc, Business_Industry_Update__pc,Business_Address__pc,Business_Address_Update__pc,Business_Name__pc,Business_Name_Update__pc,Employer_Name__pc,Employer_Name_Update__pc,Employment_Status__pc,Employment_Status_Update__pc from account where id=:accNew];
        List<Account> accUpdateList = new List<Account>();
        
        for(Account acObj : acList){
        
          acObj.Passport_Expiry_Date__pc = acObj.Passport_Expiry_Date_Update__pc;
           acObj.Place_of_Birth__pc = acObj.Place_of_Birth_Update__pc;
        
          acObj.Nationality__pc = acObj.Nationality_Update__pc;
          
          acObj.ID_Nationality__pc = acObj.Document_Country_Update__pc;
          acObj.Expected_Monthly_deposits__pc = acObj.Expected_Monthly_deposits_Update__pc;
        
           acObj.Account_Opening_Reason__pc = acObj.Account_Opening_Reason_Update__pc;
           acObj.Passport_Number__pc = acObj.Passport_Number_Update__pc;
        
          
           acObj.Residency_Permit_Number__pc = acObj.Residency_Permit_Number_Update__pc;
           acObj.Residency_Permit_Expiry__pc = acObj.Residency_Permit_Expiry_Update__pc;
           
           acObj.Employer_Address__pc = acObj.Employer_Address_Update__pc;
           acObj.Employer_Country__pc = acObj.Employer_Country_Update__pc;
        
           acObj.Employment_Status__pc = acObj.Employment_Status_Update__pc;
           acObj.employer_name__pc = acObj.Employer_Name_Update__pc;
           
           acObj.Business_Name__pc = acObj.Business_Name_Update__pc;
           acObj.Business_Address__pc = acObj.Business_Address_Update__pc;
           
           acObj.Business_Industry__pc = acObj.Business_Industry_Update__pc;
           acObj.Sources_of_Funds__pc = acObj.Sources_of_Funds_Update__pc;
           
           acObj.Source_Found_specify__pc = acObj.Source_of_Funds_please_specify_Update__pc;
          // acObj.Fatca_Customer__pc = acObj.Fatca_Customer_Update__pc;
           
           acObj.Tax_Country_1__pc = acObj.Tax_Country_1_Update__pc;
           acObj.Tax_Country_1_ID__pc = acObj.Tax_Country_1_ID_Update__pc;

           acObj.Tax_Country_2__pc = acObj.Tax_Country_2_Update__pc;
           acObj.Tax_Country_2_ID__pc = acObj.Tax_Country_2_ID_Update__pc;
           
           acObj.Tax_Country_3__pc = acObj.Tax_Country_3_Update__pc;
           acObj.Tax_Country_3_ID__pc = acObj.Tax_Country_3_ID_Update__pc;

           acObj.Tax_Country_4__pc = acObj.Tax_Country_4_Update__pc;
           acObj.Tax_Country_4_ID__pc = acObj.Tax_Country_4_ID_Update__pc;
           
           acObj.Applicable_Residency_Tax__pc = acObj.Applicable_Residency_Tax_Update__pc;
           acObj.US_Indicia__pc = acObj.US_Indicia_Update__pc;
           
           accUpdateList.add(acObj);
        }
         for(Case caseObj : cases){
                caseObj.Status = 'Closed';
                System.debug('Update on Case');
         }
         if(cases != null && cases.size()>0){
            update cases;
            }
        
         If(accUpdateList != null && accUpdateList.size()>0){
            update accUpdateList; //update again to Update Original field 
           } 
        
    }
    
}