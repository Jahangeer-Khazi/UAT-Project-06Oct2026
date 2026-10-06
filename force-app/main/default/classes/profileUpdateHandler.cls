/*      Organization : ABC Bank
*      Created By: Jahangeer Mohammed
*      Created Date:05/02/2023
*      Change History: 
*          #CH1#- ByPassGeoLocation Exipry 
		   #CH02# #Jahangeer Mohammed# 10-03-2026# Added Logic for Credit Card Guarantor CIF (NBA-16525)

*/
public class profileUpdateHandler {
    
    public static void profileUpdate(Set<Id> caseIds){
        Map<Id,Map<String,Object>> mapCaseIdAndRelatedRequest = new Map<Id,Map<String,Object>>();
        //CH02: Added Account.Credit_Card_Guarantor_CIF__pc,Account.Credit_Card_Guarantor_CIF_Update__pc in SOQL
        for(Case cs : [Select id,AccountId, Type, Sub_Type__c,Case_Model__c,Account.PersonEmail, Account.PersonMobilePhone, Account.Mobile_Country_Code__pc,Account.Mobile_Country_Code_Update__pc,Account.Mobile_Update__pc,Account.Email_Update__pc,Account.ID_Type__pc, Account.ID_Type_Update__pc,Account.ID_Expiry_Date_Update__pc,Account.ID_Expiry_Date__pc,
                       Account.FirstName,Account.MiddleName, Account.LastName, Account.FirstName_Update__pc, Account.MiddleName_Update__pc,Account.LastName_Update__pc,Account.Proof_of_Address_Id__pc,Account.Proof_of_Address_Id_Update__pc,Account.Proof_of_Address_ID_Type__pc,Account.Proof_of_Address_ID_Type_Update__pc,Account.Address_ID_Expiry_Date__pc,Account.Address_ID_Expiry_Date_Update__pc,
                       Account.PersonMailingStreet,Account.Mailing_Street_Update__pc, Account.PersonMailingCity, Account.Mailing_City_Update__pc, Account.PersonMailingPostalCode, Account.Postcode_Block_Update__pc,Account.PersonMailingCountry,Account.Mailing_Country_Update__pc, 
                       Account.Residency_Permit_Number__pc,Account.Residency_Permit_Number_Update__pc,Account.Residency_Permit_Expiry__pc,Account.Residency_Permit_Expiry_Update__pc,Account.Employment_Status__pc,Account.Employment_Status_Update__pc,Account.Employer_Name__pc,Account.Employer_Name_Update__pc,
                       Account.Employer_Country__pc,Account.Employer_Country_Update__pc,Account.Business_Name__pc,Account.Business_Name_Update__pc,Account.Business_Address__pc,Account.Business_Address_Update__pc,Account.Business_Industry__pc,Account.Business_Industry_Update__pc,Account.Sources_of_Funds__pc,Account.Sources_of_Funds_Update__pc,
                       Account.Gross_Monthly_Income__pc,Account.Gross_Monthly_Income_Update__pc,Account.Expected_Monthly_deposits__pc,Account.Expected_Monthly_deposits_Update__pc,Account.Passport_Number__pc,Account.Passport_Number_Update__pc,Account.Passport_Expiry_Date__pc,Account.Passport_Expiry_Date_Update__pc,Account.Nationality__pc,Account.Nationality_Update__pc,
                       Account.Place_of_birth_government__pc,Account.Place_of_birth_government_Update__pc,Account.Place_of_Birth_Update__pc,Account.Place_of_Birth__pc,Account.Account_Opening_Reason__pc,Account.Account_Opening_Reason_Update__pc,Account.Minor__pc,Account.Minor_Update__pc,Account.Guardian_CIF__pc,Account.Guardian_CIF_Update__pc,
                       Account.Guardian_CPR__pc, Account.Guardian_CPR_Update__pc,Account.skip_Restricted_GeoLocation__pc,Account.skip_Restricted_GeoLocation_Update__pc,Account.Whitelist_Country__pc,Account.Bypass_Geo_Location_Check_Update__pc, Account.Bypass_Geo_Location_Check__pc,Account.Bypass_Geo_Location_End_Date_Update__pc,Account.Bypass_Geo_Location_End_Date__pc,Account.Bypass_Geo_Location_Country__pc,Account.Bypass_Geo_Location_Country_Update__pc, 
                       Account.Credit_Card_Guarantor_CIF__pc,Account.Credit_Card_Guarantor_CIF_Update__pc from Case where id =: caseIds]){
                           Map<String, String> conInfo = new Map<String, String>();
                           Map<String, String> idInfo = new Map<String, String>();
                           Map<String, String> perInfo = new Map<String, String>();
                           //CH02: Start
                           Map<String, String> profInfo = new Map<String, String>();
                           //CH02: END
                           Map<String, String> addrInfo = new Map<String, String>();
                           Map<String, String> empInfo = new Map<String, String>();
                           Map<String, String> guardInfo = new Map<String, String>();
                           Map<String, String> geoInfo = new Map<String, String>();
                           Map<String, object> incInfo = new Map<String, object>();
                           Map<String, object> accInfo = new Map<String, object>();
                           Map<String, object> mapReq = new Map<String, object>();
                           
                           ////////////////////////////////////////// Start: When an Agent is updating the Mobile & Country Code related fields ///////////////////////////////////////////////////////////////////
                           if((cs.Type == 'Personal Info Update' || cs.Type == 'Profile Update') && cs.Sub_Type__c == 'Mobile update'){
                               
                               if(cs.Account.PersonEmail != null){
                                   conInfo.put('email', cs.Account.PersonEmail);
                                   //mapReq.put('contactInformation', conInfo);
                               }
                               /********************************************* Start: Agent is updating only Mobile Phone ******************************************************/
                               if(cs.Account.PersonMobilePhone != cs.Account.Mobile_Update__pc && cs.Account.Mobile_Update__pc != null){
                                   System.debug('Agent is updating only Mobile Phone');
                                   conInfo.put('mobileNumber', cs.Account.Mobile_Update__pc);
                                   mapReq.put('contactInformation', conInfo);
                               }
                               /********************************************* END: Agent is updating only Mobile Phone ******************************************************/
                               
                               /********************************************* Start: Agent is updating only Mobile Country Code ******************************************************/
                               System.debug('Mobile Country Code:'+cs.Account.Mobile_Country_Code__pc);
                               System.debug('Mobile Country Code Update:'+cs.Account.Mobile_Country_Code_Update__pc);
                               
                               if(cs.Account.Mobile_Country_Code__pc != cs.Account.Mobile_Country_Code_Update__pc && cs.Account.Mobile_Country_Code_Update__pc != null){
                                   System.debug('Agent is updating only Mobile Country Code');
                                   conInfo.put('mobileCountryCode', cs.Account.Mobile_Country_Code_Update__pc);
                                   mapReq.put('contactInformation', conInfo);
                               }
                               /********************************************* END: Agent is updating only Mobile Country Code ******************************************************/
                               mapCaseIdAndRelatedRequest.put(cs.id,mapReq);
                               
                           } //if END
                           ////////////////////////////////////////// END: When an Agent is updating the Mobile & Country Code related fields ///////////////////////////////////////////////////////////////////
                           
                           ////////////////////////////////////////// Start: When an Agent is updating the Email field ///////////////////////////////////////////////////
                           else if((cs.Type == 'Personal Info Update' || cs.Type == 'Profile Update') && cs.Sub_Type__c == 'Email update' && cs.Account.PersonEmail != null && cs.Account.PersonEmail != cs.Account.Email_Update__pc && cs.Account.Email_Update__pc != null){
                               System.debug('Agent is updating Email');
                               conInfo.put('email', cs.Account.Email_Update__pc); 
                               mapReq.put('contactInformation', conInfo);
                               mapCaseIdAndRelatedRequest.put(cs.id,mapReq);
                           } //else if END
                           ////////////////////////////////////////// END: When an Agent is updating the Email field ///////////////////////////////////////////////////
                           
                           ////////////////////////////////////////// Start: When an Agent is updating the ID Type & ID Expiry Date related fields ///////////////////////////////////////////////////////////////////
                           else if((cs.Type == 'Personal Info Update' || cs.Type == 'Profile Update') && (cs.Sub_Type__c == 'Expired ID Update' || cs.Sub_Type__c == 'ID Expiry Update' || cs.Sub_Type__c == 'ID Type Update')){
                               
                               if(cs.Account.PersonEmail != null){
                                   conInfo.put('email', cs.Account.PersonEmail);
                                   mapReq.put('contactInformation', conInfo);
                               }
                               
                               /***************************************************** Start: Agent is updating only ID Type field ****************************************************/
                               if(cs.Account.ID_Type__pc != cs.Account.ID_Type_Update__pc && cs.Account.ID_Type_Update__pc != null){
                                   System.debug('Agent is updating Mobile only ID Type field');
                                   String expiryDate = DateTime.newInstance(cs.Account.ID_Expiry_Date_Update__pc.year(), cs.Account.ID_Expiry_Date_Update__pc.month(), cs.Account.ID_Expiry_Date_Update__pc.day()).format('yyyy-MM-dd');
                                   idInfo.put('idType', cs.Account.ID_Type_Update__pc);
                                   mapReq.put('idInformation', idInfo);
                               }
                               /***************************************************** END: Agent is updating only ID Type field ****************************************************/
                               
                               /******************************************************* Start: Agent is updating only ID Expiry Date field *********************************************************/
                               if(cs.Account.ID_Expiry_Date__pc != cs.Account.ID_Expiry_Date_Update__pc && cs.Account.ID_Expiry_Date_Update__pc != null){
                                   System.debug('Agent is updating Mobile only ID Expiry Date field');
                                   String expiryDate = DateTime.newInstance(cs.Account.ID_Expiry_Date_Update__pc.year(), cs.Account.ID_Expiry_Date_Update__pc.month(), cs.Account.ID_Expiry_Date_Update__pc.day()).format('yyyy-MM-dd');
                                   idInfo.put('idExpiryDate', expiryDate);
                                   mapReq.put('idInformation', idInfo);
                               }
                               /******************************************************* END: Agent is updating only ID Expiry Date field *********************************************************/
                               mapCaseIdAndRelatedRequest.put(cs.id,mapReq);
                           } //else if END
                           ////////////////////////////////////////// END: When an Agent is updating the ID Type & ID Expiry Date related fields ///////////////////////////////////////////////////////////////////
                           
                           ////////////////////////////////////////// Start: When an Agent is updating the Personnel Information related fields ///////////////////////////////////////////////////////////////////
                           else if((cs.Type == 'Personal Info Update' || cs.Type == 'Profile Update') && (cs.Sub_Type__c == 'Name Fix / Update' || cs.Sub_Type__c == 'Name Update')){
                               
                               if(cs.Account.PersonEmail != null){
                                   conInfo.put('email', cs.Account.PersonEmail);
                                   mapReq.put('contactInformation', conInfo);
                               } 
                               
                               /************************************************* Start: Agent is updating only First Name *****************************************/
                               if(cs.Account.FirstName != cs.Account.FirstName_Update__pc && cs.Account.FirstName_Update__pc != null){
                                   System.debug('Agent is updating only First Name');
                                   perInfo.put('firstName',cs.Account.FirstName_Update__pc);
                                   mapReq.put('personalInformation', perInfo);  
                               }
                               /************************************************* END: Agent is updating only First Name *****************************************/
                               
                               /************************************************* Start: Agent is updating only Middle Name *******************************************/
                               if(cs.Account.MiddleName != cs.Account.MiddleName_Update__pc){
                                   System.debug('Agent is updating only Middle Name');
                                   perInfo.put('middleName',cs.Account.MiddleName_Update__pc==null?'':cs.Account.MiddleName_Update__pc);
                                   mapReq.put('personalInformation', perInfo);  
                               }       
                               
                               /************************************************* END: Agent is updating only Middle Name *******************************************/
                               
                               /************************************************* Start: Agent is updating only Last Name ***********************************************/
                               if(cs.Account.LastName != cs.Account.LastName_Update__pc && cs.Account.LastName_Update__pc != null){
                                   System.debug('Agent is updating only Last Name');
                                   perInfo.put('lastName',cs.Account.LastName_Update__pc);
                                   mapReq.put('personalInformation', perInfo);  
                               }
                               /************************************************* END: Agent is updating only Last Name ***********************************************/
                               mapCaseIdAndRelatedRequest.put(cs.id,mapReq);
                           } //else if END
                           ////////////////////////////////////////// END: When an Agent is updating the Personnel Information related fields ///////////////////////////////////////////////////////////////////
                           
                           /////////////////////////////////////////// Start: When Agent is updating Address related Information ////////////////////////////////////
                           else if((cs.Type == 'Personal Info Update' || cs.Type == 'Profile Update') && cs.Sub_Type__c == 'Address update'){
                               if(cs.Account.PersonEmail != null){
                                   conInfo.put('email', cs.Account.PersonEmail);
                                   mapReq.put('contactInformation', conInfo);
                               } 
                               /****************************************** Start: Agent is updating ID Number **************************************************/   
                               if(cs.Account.Proof_of_Address_Id__pc != cs.Account.Proof_of_Address_Id_Update__pc && cs.Account.Proof_of_Address_Id_Update__pc != null){
                                   System.debug('Agent is updating only ID Number');
                                   addrInfo.put('proofOfAddressId',cs.Account.Proof_of_Address_Id_Update__pc);
                                   mapReq.put('addressInformation', addrInfo);  
                               }
                               /****************************************** END: Agent is updating ID Number *****************************************************/   
                               
                               /****************************************** Start: Agent is updating ID Type **************************************************/
                               if(cs.Account.Proof_of_Address_ID_Type__pc != cs.Account.Proof_of_Address_ID_Type_Update__pc && cs.Account.Proof_of_Address_ID_Type_Update__pc != null){
                                   System.debug('Agent is updating only ID Type');
                                   addrInfo.put('proofOfAddressIdType',cs.Account.Proof_of_Address_ID_Type_Update__pc);
                                   mapReq.put('addressInformation', addrInfo);  
                               }
                               /****************************************** END: Agent is updating ID Type **************************************************/
                               
                               /****************************************** Start: Agent is updating Proof of Address Expiry Date ******************************************/
                               if(cs.Account.Address_ID_Expiry_Date__pc != cs.Account.Address_ID_Expiry_Date_Update__pc && cs.Account.Address_ID_Expiry_Date_Update__pc != null){
                                   System.debug('Agent is updating only Proof of ID Expiry Date');
                                   String expiryDate = DateTime.newInstance(cs.Account.Address_ID_Expiry_Date_Update__pc.year(), cs.Account.Address_ID_Expiry_Date_Update__pc.month(), cs.Account.Address_ID_Expiry_Date_Update__pc.day()).format('yyyy-MM-dd');
                                   addrInfo.put('proofOfAddressIdExpiryDate',expiryDate);
                                   mapReq.put('addressInformation', addrInfo);  
                               }  
                               /****************************************** END: Agent is updating Proof of Address Expiry Date ******************************************/
                               
                               /****************************************** Start: Agent is updating Mailing Street ***********************************************************/
                               if(cs.Account.PersonMailingStreet != cs.Account.Mailing_Street_Update__pc && cs.Account.Mailing_Street_Update__pc != null){
                                   System.debug('Agent is updating only Mailing Street');
                                   addrInfo.put('address1',cs.Account.Mailing_Street_Update__pc);
                                   mapReq.put('addressInformation', addrInfo);  
                               }
                               /****************************************** Start: Agent is updating Mailing Street ***********************************************************/
                               
                               /****************************************** Start: Agent is updating Mailing City ***********************************************************/
                               if(cs.Account.PersonMailingCity != cs.Account.Mailing_City_Update__pc && cs.Account.Mailing_City_Update__pc != null){
                                   System.debug('Agent is updating only Mailing City');
                                   addrInfo.put('city',cs.Account.Mailing_City_Update__pc);
                                   mapReq.put('addressInformation', addrInfo);  
                               }
                               /****************************************** Start: Agent is updating Mailing City ***********************************************************/
                               
                               /****************************************** Start: Agent is updating Postal Code ***********************************************************/
                               if(cs.Account.PersonMailingPostalCode != cs.Account.Postcode_Block_Update__pc && cs.Account.Postcode_Block_Update__pc != null){
                                   System.debug('Agent is updating only Postal Code');
                                   addrInfo.put('postalCode',cs.Account.Postcode_Block_Update__pc);
                                   mapReq.put('addressInformation', addrInfo);  
                               }
                               /****************************************** Start: Agent is updating Postal Code ***********************************************************/
                               
                               /****************************************** Start: Agent is updating Mailing Country ***********************************************************/
                               if(cs.Account.PersonMailingCountry != cs.Account.Mailing_Country_Update__pc && cs.Account.Mailing_Country_Update__pc != null){
                                   System.debug('Agent is updating only Mailing Country');
                                   addrInfo.put('country',cs.Account.Mailing_Country_Update__pc);
                                   mapReq.put('addressInformation', addrInfo);  
                               }
                               /****************************************** Start: Agent is updating Mailing Country ***********************************************************/
                               mapCaseIdAndRelatedRequest.put(cs.id,mapReq);
                           } //else if END
                           ////////////////////////////////////////// END: When Agent is updating Address related Information ///////////////////////////////////////      
                           
                           ////////////////////////////////////////// Start: When Agent is filling Additional Information fields ///////////////////////////////////////       
                           else if((cs.Type == 'Personal Info Update' || cs.Type == 'Profile Update') && cs.Sub_Type__c == 'Additional Information'){
                               if(cs.Account.PersonEmail != null){
                                   conInfo.put('email', cs.Account.PersonEmail);
                                   mapReq.put('contactInformation', conInfo);
                               }
                               /******************************************** Start: Agent is updating Resident Number **********************************************/
                               if(cs.Account.Residency_Permit_Number__pc != cs.Account.Residency_Permit_Number_Update__pc && cs.Account.Residency_Permit_Number_Update__pc != null){
                                   System.debug('Agent is updating only Resident Permit Number');
                                   idInfo.put('residencyPermitNumber',cs.Account.Residency_Permit_Number_Update__pc);
                                   mapReq.put('idInformation', idInfo);
                               }
                               /******************************************** END: Agent is updating Resident Number **********************************************/
                               
                               /********************************************* Start: Agent is updating Residency Expiry Date ****************************************/
                               if(cs.Account.Residency_Permit_Expiry__pc != cs.Account.Residency_Permit_Expiry_Update__pc && cs.Account.Residency_Permit_Expiry_Update__pc != null){
                                   System.debug('Agent is updating only Resident Expiry Date');
                                   String expiryDate = DateTime.newInstance(cs.Account.Residency_Permit_Expiry_Update__pc.year(), cs.Account.Residency_Permit_Expiry_Update__pc.month(), cs.Account.Residency_Permit_Expiry_Update__pc.day()).format('yyyy-MM-dd');
                                   idInfo.put('residencyPermitExpiry',expiryDate);
                                   mapReq.put('idInformation',idInfo);
                               }
                               /********************************************* END: Agent is updating Residency Expiry Date ****************************************/
                               
                               /******************************************** Start: Agent is updating Passport Number **********************************************/
                               if(cs.Account.Passport_Number__pc != cs.Account.Passport_Number_Update__pc && cs.Account.Passport_Number_Update__pc != null){
                                   System.debug('Agent is updating only Passport Number');
                                   idInfo.put('passportNumber',cs.Account.Passport_Number_Update__pc);
                                   mapReq.put('idInformation', idInfo);
                               }
                               /******************************************** END: Agent is updating Passport Number **********************************************/
                               
                               /********************************************* Start: Agent is updating Passport Expiry Date ****************************************/
                               if(cs.Account.Passport_Expiry_Date__pc != cs.Account.Passport_Expiry_Date_Update__pc && cs.Account.Passport_Expiry_Date_Update__pc != null){
                                   System.debug('Agent is updating only Passport Expiry Date');
                                   String expiryDate = DateTime.newInstance(cs.Account.Passport_Expiry_Date_Update__pc.year(), cs.Account.Passport_Expiry_Date_Update__pc.month(), cs.Account.Passport_Expiry_Date_Update__pc.day()).format('yyyy-MM-dd');
                                   idInfo.put('passportExpiryDate',expiryDate);
                                   mapReq.put('idInformation',idInfo);
                               }
                               /********************************************* END: Agent is updating Passport Expiry Date ****************************************/
                               
                               /********************************************* Start: Agent is updating Employer Country ****************************************/
                               if(cs.Account.Employer_Country__pc != cs.Account.Employer_Country_Update__pc && cs.Account.Employer_Country_Update__pc != null){
                                   System.debug('Agent is updating only Employer Country');
                                   empInfo.put('employerCountry',cs.Account.Employer_Country_Update__pc);
                                   mapReq.put('employmentInformation',empInfo);
                               }
                               /********************************************* END: Agent is updating Employer Country ****************************************/
                               
                               /********************************************* Start: Agent is updating Employment Status ****************************************/
                               if(cs.Account.Employment_Status__pc != cs.Account.Employment_Status_Update__pc && cs.Account.Employment_Status_Update__pc != null){
                                   System.debug('Agent is updating only Employment Status');
                                   empInfo.put('employmentStatus',cs.Account.Employment_Status_Update__pc);
                                   mapReq.put('employmentInformation',empInfo);
                               }
                               /********************************************* END: Agent is updating Employment Status ****************************************/
                               
                               /********************************************* Start: Agent is updating Employment Name ****************************************/
                               if(cs.Account.Employer_Name__pc != cs.Account.Employer_Name_Update__pc && cs.Account.Employer_Name_Update__pc != null){
                                   System.debug('Agent is updating only Employment Name');
                                   empInfo.put('employerName',cs.Account.Employer_Name_Update__pc);
                                   mapReq.put('employmentInformation',empInfo);
                               }
                               /********************************************* END: Agent is updating Employment Name ****************************************/
                               
                               /********************************************* Start: Agent is updating Business Name ****************************************/
                               if(cs.Account.Business_Name__pc != cs.Account.Business_Name_Update__pc && cs.Account.Business_Name_Update__pc != null){
                                   System.debug('Agent is updating only Business Name');
                                   empInfo.put('businessName',cs.Account.Business_Name_Update__pc);
                                   mapReq.put('employmentInformation',empInfo);
                               }
                               /********************************************* END: Agent is updating Business Name ****************************************/
                               
                               /********************************************* Start: Agent is updating Business Address ****************************************/
                               /*if(cs.Account.Business_Address__pc != cs.Account.Business_Address_Update__pc && cs.Account.Business_Address_Update__pc != null){
System.debug('Agent is updating only Business Address');
empInfo.put('businessCountry',cs.Account.Business_Address_Update__pc);
mapReq.put('employmentInformation',empInfo);
}*/
                               /********************************************* END: Agent is updating Business Address ****************************************/
                               
                               /********************************************* Start: Agent is updating Business Industry ****************************************/
                               if(cs.Account.Business_Industry__pc != cs.Account.Business_Industry_Update__pc && cs.Account.Business_Industry_Update__pc != null){
                                   System.debug('Agent is updating only Business Industry');
                                   empInfo.put('businessIndustry',cs.Account.Business_Industry_Update__pc);
                                   mapReq.put('employmentInformation',empInfo);
                               }
                               /********************************************* END: Agent is updating Business Industry ****************************************/
                               
                               /********************************************* Start: Agent is updating Nationality ****************************************/
                               if(cs.Account.Nationality__pc != cs.Account.Nationality_Update__pc && cs.Account.Nationality_Update__pc != null){
                                   System.debug('Agent is updating only Nationality');
                                   perInfo.put('nationality',cs.Account.Nationality_Update__pc);
                                   mapReq.put('personalInformation',perInfo);
                               }
                               /********************************************* END: Agent is updating Nationality ****************************************/
                               
                               /********************************************* Start: Agent is updating Place Of Birth Govt ****************************************/
                               /*if(cs.Account.Place_of_birth_government__pc != cs.Account.Place_of_birth_government_Update__pc && cs.Account.Place_of_birth_government_Update__pc != null){
System.debug('Agent is updating only Place of birth govt');
perInfo.put('governmentPlaceOfBirth',cs.Account.Place_of_birth_government_Update__pc);
mapReq.put('personalInformation',perInfo);
}*/
                               if(cs.Account.Place_of_Birth__pc != cs.Account.Place_of_Birth_Update__pc && cs.Account.Place_of_Birth_Update__pc != null){
                                   System.debug('Agent is updating only Place of birth govt');
                                   perInfo.put('placeOfBirth',cs.Account.Place_of_Birth_Update__pc);
                                   mapReq.put('personalInformation',perInfo);
                               }
                               /********************************************* END: Agent is updating Place Of Birth Govt ****************************************/
                               
                               /********************************************* Start: Agent is updating Source Of Funds ****************************************/
                               if(cs.Account.Sources_of_Funds__pc != cs.Account.Sources_of_Funds_Update__pc && cs.Account.Sources_of_Funds_Update__pc != null){
                                   System.debug('Agent is updating only source of funds');
                                   incInfo.put('sourceOfFunds',cs.Account.Sources_of_Funds_Update__pc.split(';'));
                                   mapReq.put('incomeInformation',incInfo);
                               }
                               /********************************************* END: Agent is updating Source Of Funds ****************************************/
                               
                               /********************************************* Start: Agent is updating Account Opening reason ****************************************/
                               if(cs.Account.Account_Opening_Reason__pc  != cs.Account.Account_Opening_Reason_Update__pc && cs.Account.Account_Opening_Reason_Update__pc != null){
                                   System.debug('Agent is updating only Account Opening Reason');
                                   accInfo.put('accountOpeningReason',cs.Account.Account_Opening_Reason_Update__pc.split(';'));
                                   mapReq.put('accountInfo',accInfo);
                               }
                               /********************************************* END: Agent is updating Account Opening Reason ****************************************/
                               
                               /********************************************* Start: Agent is updating Gross Monthly Income ****************************************/
                               if(cs.Account.Gross_Monthly_Income__pc != cs.Account.Gross_Monthly_Income_Update__pc && cs.Account.Gross_Monthly_Income_Update__pc != null){
                                   System.debug('Agent is updating only Gross Monthly Income Update');
                                   incInfo.put('grossMonthlyIncome',cs.Account.Gross_Monthly_Income_Update__pc);
                                   mapReq.put('incomeInformation',incInfo);
                               }
                               /********************************************* END: Agent is updating Gross Monthly Income ****************************************/
                               
                               /********************************************* Start: Agent is updating Expected Monthly Deposits ****************************************/
                               if(cs.Account.Expected_Monthly_deposits__pc != cs.Account.Expected_Monthly_deposits_Update__pc && cs.Account.Expected_Monthly_deposits_Update__pc != null){
                                   System.debug('Agent is updating only Expected Monthly Deposits');
                                   incInfo.put('expectedMonthlyDeposits',cs.Account.Expected_Monthly_deposits_Update__pc);
                                   mapReq.put('incomeInformation',incInfo);
                               }
                               /********************************************* END: Agent is updating Expected Monthly Deposits ****************************************/
                               mapCaseIdAndRelatedRequest.put(cs.id,mapReq);
                           } //else if End
                           ////////////////////////////////////////// END: When Agent is filling Additional Information fields ///////////////////////////////////////       
                           
                           /////////////////////////////////////////// Start: When Agent is filling Guardian Information fields /////////////////////////////////////////
                           else if((cs.Type == 'Personal Info Update' || cs.Type == 'Profile Update') && cs.Sub_Type__c == 'Guardian Info'){
                               if(cs.Account.PersonEmail != null){
                                   conInfo.put('email', cs.Account.PersonEmail);
                                   mapReq.put('contactInformation', conInfo);
                               } 
                               /******************************************* Start: Agent is Updating Minor Flag ******************************************/   
                               if(cs.Account.Minor__pc != cs.Account.Minor_Update__pc && cs.Account.Minor_Update__pc != null){
                                   System.debug('Agent is updating only Minor Flag');
                                   perInfo.put('isMinor',String.valueOf(cs.Account.Minor_Update__pc));
                                   mapReq.put('personalInformation',perInfo); 
                               }
                               /******************************************* END: Agent is Updating Minor Flag ******************************************/   
                               
                               /******************************************* Start: Agent is Updating Guardian CIF ****************************************/
                               if(cs.Account.Guardian_CIF__pc != cs.Account.Guardian_CIF_Update__pc && cs.Account.Guardian_CIF_Update__pc != null){
                                   System.debug('Agent is updating only Guardian CIF');
                                   perInfo.put('guardianCIF',cs.Account.Guardian_CIF_Update__pc);
                                   mapReq.put('personalInformation',perInfo);
                               }
                               /******************************************* END : Agent is Updating Guardian CIF *****************************************/
                               
                               /******************************************** Start: Agent is Updating Guardian CPR ****************************************/
                               /* if(cs.Account.Guardian_CPR__pc != cs.Account.Guardian_CPR_Update__pc && cs.Account.Guardian_CPR_Update__pc != null){
System.debug('Agent is updating only Guardian CPR');
guardInfo.put('guardianCPR',cs.Account.Guardian_CPR_Update__pc);
mapReq.put('profile',guardInfo);
}*/
                               /******************************************** Start: Agent is Updating Guardian CPR ****************************************/
                               mapCaseIdAndRelatedRequest.put(cs.id,mapReq);
                           } //else if Ends
                           
                           ////////////////////////////////////////// END : When Agent is filling Guardian Information fields ///////////////////////////////////////////
                          
                           //CH02: Start 
                          //////////////////////////////////////////Start: When Agent is filling Guarantor Information fields ///////////////////////////////////////////
                           else if((cs.Type == 'Personal Info Update' || cs.Type == 'Profile Update') && cs.Sub_Type__c == 'Credit Card Guarantor CIF'){
                               if(cs.Account.PersonEmail != null){
                                   conInfo.put('email', cs.Account.PersonEmail);
                                   mapReq.put('contactInformation', conInfo);
                               } 
                               /******************************************* Start: Agent is Updating Guarantor CIF ****************************************/
                               if(cs.Account.Credit_Card_Guarantor_CIF__pc != cs.Account.Credit_Card_Guarantor_CIF_Update__pc && cs.Account.Credit_Card_Guarantor_CIF_Update__pc != null){
                                   System.debug('Agent is updating only Guarantor CIF');
                                   profInfo.put('creditCardGuarantorCIF',cs.Account.Credit_Card_Guarantor_CIF_Update__pc);
                                   mapReq.put('profile',profInfo);
                               }
                               /******************************************* END : Agent is Updating Guarantor CIF *****************************************/
                         	   mapCaseIdAndRelatedRequest.put(cs.id,mapReq);
                           }
                          //////////////////////////////////////////END: When Agent is filling Guarantor Information fields ///////////////////////////////////////////
						 //CH02: END
						 
                           ///////////////////////////////////////////// Start: When Agent is filling GeoLocation fields /////////////////////////////////////////
                           else if((cs.Type == 'Personal Info Update' || cs.Type == 'Profile Update') && cs.Sub_Type__c =='Geo-Location Check'){
                               system.debug('Geo-Location Check');
                               /******************************************* Start: Agent is Updating By pass Geo Location ****************************************/
                              if(cs.Account.Bypass_Geo_Location_Check__pc != cs.Account.Bypass_Geo_Location_Check_Update__pc){
                                   system.debug('inside geo');
                                   if(cs.Account.PersonEmail != null){
                                       conInfo.put('email', cs.Account.PersonEmail);
                                       mapReq.put('contactInformation', conInfo);
                                       mapReq.put('skipRestrictedGeoLocation',cs.Account.Bypass_Geo_Location_Check_Update__pc);
                                       mapReq.put('skipRestrictedGeoLocationCountry',cs.Account.Bypass_Geo_Location_Country_Update__pc);
                                       Time midnight = Time.newInstance(23, 59, 59, 0); 
                                       Datetime skipRestrictedGeoLocationExpiryDate = DateTime.newInstance(cs.Account.Bypass_Geo_Location_End_Date_Update__pc, midnight); 
                                       mapReq.put('skipRestrictedGeoLocationExpiryDate',skipRestrictedGeoLocationExpiryDate);
                                       //mapReq.put('skipRestrictedGeoLocationExpiryDate',cs.Account.Bypass_Geo_Location_End_Date_Update__pc);
                                       mapCaseIdAndRelatedRequest.put(cs.id,mapReq);
                                   } 
                                   
                               }
                               /******************************************* END :  Agent is Updating By pass Geo Location*****************************************/
                           }
                           ////////////////////////////////////////// END : When Agent is filling GeoLocation fields ///////////////////////////////////////////
                       }//for loop Ends
        
        if(!mapCaseIdAndRelatedRequest.isEmpty()){
            //Calling the Queueable class to post the data to the Update Customer detail API
            System.debug('Map Request Body:'+mapCaseIdAndRelatedRequest);
            profileUpdateHandlerAPI profileMobileUpdate = new profileUpdateHandlerAPI(mapCaseIdAndRelatedRequest);
            System.enqueueJob(profileMobileUpdate);
        }
        
    }//Method Ends
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    //CH1:START
    @InvocableMethod(label='profileUpdateHandler-Expire Bypass Geolocation' description='Expire Bypass Geolocation' callout=true )
        public static void profileUpdateExpireBypassGeo(List<Id> caseIds){
        Map<Id,Map<String,Object>> mapCaseIdAndRelatedRequest = new Map<Id,Map<String,Object>>();
             
             for(Case cs : [Select id,AccountId, Type, Sub_Type__c,Case_Model__c,Account.PersonEmail, Account.PersonMobilePhone, Account.Mobile_Country_Code__pc,Account.Mobile_Country_Code_Update__pc,Account.Mobile_Update__pc,Account.Email_Update__pc,Account.ID_Type__pc, Account.ID_Type_Update__pc,Account.ID_Expiry_Date_Update__pc,Account.ID_Expiry_Date__pc,
                       Account.FirstName,Account.MiddleName, Account.LastName, Account.FirstName_Update__pc, Account.MiddleName_Update__pc,Account.LastName_Update__pc,Account.Proof_of_Address_Id__pc,Account.Proof_of_Address_Id_Update__pc,Account.Proof_of_Address_ID_Type__pc,Account.Proof_of_Address_ID_Type_Update__pc,Account.Address_ID_Expiry_Date__pc,Account.Address_ID_Expiry_Date_Update__pc,
                       Account.PersonMailingStreet,Account.Mailing_Street_Update__pc, Account.PersonMailingCity, Account.Mailing_City_Update__pc, Account.PersonMailingPostalCode, Account.Postcode_Block_Update__pc,Account.PersonMailingCountry,Account.Mailing_Country_Update__pc, 
                       Account.Residency_Permit_Number__pc,Account.Residency_Permit_Number_Update__pc,Account.Residency_Permit_Expiry__pc,Account.Residency_Permit_Expiry_Update__pc,Account.Employment_Status__pc,Account.Employment_Status_Update__pc,Account.Employer_Name__pc,Account.Employer_Name_Update__pc,
                       Account.Employer_Country__pc,Account.Employer_Country_Update__pc,Account.Business_Name__pc,Account.Business_Name_Update__pc,Account.Business_Address__pc,Account.Business_Address_Update__pc,Account.Business_Industry__pc,Account.Business_Industry_Update__pc,Account.Sources_of_Funds__pc,Account.Sources_of_Funds_Update__pc,
                       Account.Gross_Monthly_Income__pc,Account.Gross_Monthly_Income_Update__pc,Account.Expected_Monthly_deposits__pc,Account.Expected_Monthly_deposits_Update__pc,Account.Passport_Number__pc,Account.Passport_Number_Update__pc,Account.Passport_Expiry_Date__pc,Account.Passport_Expiry_Date_Update__pc,Account.Nationality__pc,Account.Nationality_Update__pc,
                       Account.Place_of_birth_government__pc,Account.Place_of_birth_government_Update__pc,Account.Place_of_Birth_Update__pc,Account.Place_of_Birth__pc,Account.Account_Opening_Reason__pc,Account.Account_Opening_Reason_Update__pc,Account.Minor__pc,Account.Minor_Update__pc,Account.Guardian_CIF__pc,Account.Guardian_CIF_Update__pc,
                       Account.Guardian_CPR__pc, Account.Guardian_CPR_Update__pc,Account.skip_Restricted_GeoLocation__pc,Account.skip_Restricted_GeoLocation_Update__pc,Account.Whitelist_Country__pc,Account.Bypass_Geo_Location_Check_Update__pc, Account.Bypass_Geo_Location_Check__pc,Account.Bypass_Geo_Location_End_Date_Update__pc,Account.Bypass_Geo_Location_End_Date__pc,Account.Bypass_Geo_Location_Country__pc,Account.Bypass_Geo_Location_Country_Update__pc from Case where id =: caseIds]){             
                           Map<String, String> conInfo = new Map<String, String>();
                           Map<String, object> mapReq = new Map<String, object>();
                          // if(cs.Account.Bypass_Geo_Location_Check__pc != cs.Account.Bypass_Geo_Location_Check_Update__pc){
                                   system.debug('inside geo');
                                   if(cs.Account.PersonEmail != null){
                                       conInfo.put('email', cs.Account.PersonEmail);
                                       mapReq.put('contactInformation', conInfo);
                                       mapReq.put('skipRestrictedGeoLocation',cs.Account.Bypass_Geo_Location_Check_Update__pc);
                                       mapReq.put('skipRestrictedGeoLocationCountry',cs.Account.Bypass_Geo_Location_Country_Update__pc);
                                       mapReq.put('skipRestrictedGeoLocationExpiryDate',cs.Account.Bypass_Geo_Location_End_Date_Update__pc);
                                       mapCaseIdAndRelatedRequest.put(cs.id,mapReq);
                                   } 
                                   
                           //    }
        }
       if(!mapCaseIdAndRelatedRequest.isEmpty()){
            //Calling the Queueable class to post the data to the Update Customer detail API
            System.debug('Map Request Body:'+mapCaseIdAndRelatedRequest);
            profileUpdateHandlerAPI profileMobileUpdate = new profileUpdateHandlerAPI(mapCaseIdAndRelatedRequest);
            System.enqueueJob(profileMobileUpdate);
        }
        }
}