/*      Organization : ABC Bank
 *      Created By: Jahangeer Mohammed
 *      Created Date:05/02/2023
 *      Change History: 
 * 		   #CH01# #Jahangeer Mohammed# 10-03-2026# Added Logic for Credit Card Guarantor CIF (NBA-16525)

 *            
*/
public class profileUpdateHandlerAPI implements Queueable, Database.AllowsCallouts {
    private static ApiConnection con = new ApiConnection();
    Map<Id,Map<String,Object>> mapCaseIdRelatedAccRequest;
    public profileUpdateHandlerAPI(Map<Id,Map<String,Object>> mapCaseIdRelatedAccRequest){
        this.mapCaseIdRelatedAccRequest = mapCaseIdRelatedAccRequest;
    }
    public void execute(QueueableContext context){
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Account> accListToUpdate = new List<Account>();
        List<Case> caseListToUpdate = new List<Case>();
        //CH01: Added Account.Credit_Card_Guarantor_CIF__pc,Account.Credit_Card_Guarantor_CIF_Update__pc in SOQL
        List<Case> lstCase = [Select id,AccountId,Type,Sub_Type__c,Case_Model__c,Status,Region_Flag__c,Customer_CIF__c,cc_Checker_Result__c,cc_Checker_Result_Date_Time__c,Account.CIF__pc,Account.PersonEmail, Account.PersonMobilePhone, Account.Mobile_Country_Code__pc,Account.Mobile_Country_Code_Update__pc,Account.Mobile_Update__pc,
                              Account.Email_Update__pc, Account.ID_Type__pc, Account.ID_Type_Update__pc,Account.ID_Expiry_Date_Update__pc,Account.ID_Expiry_Date__pc, Account.FirstName,Account.MiddleName, Account.LastName, Account.FirstName_Update__pc, Account.MiddleName_Update__pc,Account.LastName_Update__pc, 
                              Account.Proof_of_Address_Id__pc,Account.Proof_of_Address_Id_Update__pc,Account.Proof_of_Address_ID_Type__pc,Account.Proof_of_Address_ID_Type_Update__pc,Account.Address_ID_Expiry_Date__pc,Account.Address_ID_Expiry_Date_Update__pc,
                              Account.PersonMailingStreet,Account.Mailing_Street_Update__pc, Account.PersonMailingCity, Account.Mailing_City_Update__pc, Account.PersonMailingPostalCode, Account.Postcode_Block_Update__pc,Account.PersonMailingCountry,Account.Mailing_Country_Update__pc, 
                              Account.Residency_Permit_Number__pc,Account.Residency_Permit_Number_Update__pc,Account.Residency_Permit_Expiry__pc,Account.Residency_Permit_Expiry_Update__pc,Account.Employment_Status__pc,Account.Employment_Status_Update__pc,Account.Employer_Name__pc,Account.Employer_Name_Update__pc,
                              Account.Employer_Country__pc,Account.Employer_Country_Update__pc,Account.Business_Name__pc,Account.Business_Name_Update__pc,Account.Business_Address__pc,Account.Business_Address_Update__pc,Account.Business_Industry__pc,Account.Business_Industry_Update__pc,Account.Sources_of_Funds__pc,Account.Sources_of_Funds_Update__pc,
                              Account.Gross_Monthly_Income__pc,Account.Gross_Monthly_Income_Update__pc,Account.Expected_Monthly_deposits__pc,Account.Expected_Monthly_deposits_Update__pc,Account.Passport_Number__pc,Account.Passport_Number_Update__pc,Account.Passport_Expiry_Date__pc,Account.Passport_Expiry_Date_Update__pc,Account.Nationality__pc,Account.Nationality_Update__pc,
                              Account.Place_of_birth_government__pc,Account.Place_of_birth_government_Update__pc,Account.Account_Opening_Reason__pc,Account.Account_Opening_Reason_Update__pc, Account.Minor__pc,Account.Minor_Update__pc,Account.Guardian_CIF__pc,Account.Guardian_CIF_Update__pc,Account.x_canary__pc,
                              Account.Guardian_CPR__pc, Account.Guardian_CPR_Update__pc,Account.Place_of_Birth__pc,Account.Place_of_Birth_Update__pc,Account.Bypass_Geo_Location_Check_Update__pc,Account.Bypass_Geo_Location_Check__pc,Account.Whitelist_Country__pc,Account.skip_Restricted_GeoLocation__pc,Account.skip_Restricted_GeoLocation_Update__pc,Account.Bypass_Geo_Location_End_Date__pc,Account.Bypass_Geo_Location_End_Date_Update__pc,Account.Bypass_Geo_Location_Country__pc,Account.Bypass_Geo_Location_Country_Update__pc,
                              Account.Credit_Card_Guarantor_CIF__pc,Account.Credit_Card_Guarantor_CIF_Update__pc from Case where id =: mapCaseIdRelatedAccRequest.keySet()];
        if(lstCase.size() > 0){
            for(Case objCase : lstCase){
                String path = '/api/v1/customers';
                if(mapCaseIdRelatedAccRequest.containsKey(objCase.id)){
                   Map<String,Object> reqBody = mapCaseIdRelatedAccRequest.get(objCase.id);
                   System.debug('Sample Request Map:'+reqBody);
                   String body = JSON.serialize(reqBody);
                   System.debug('String Body After Serializing:'+body);
                   Http http = new Http();
                   HttpRequest request = new HttpRequest();
                   String regionName = objCase.Region_Flag__c;
                   if(objCase.Case_Model__c == 'alburaq'){
                        regionName += '_alburaq';
                   }
                   //request = con.createRequest('PUT',path,objCase.Region_Flag__c);
                   request = con.createRequest('PUT',path,regionName);
                   request.setHeader('customerId', objCase.Account.CIF__pc);
                    if(objCase.Account.x_canary__pc != null){
                        request.setHeader('x-canary', objCase.Account.x_canary__pc);
                    }
                   request.setBody(body);
                   request.setTimeout(120000);
                   System.debug('Request Body:'+request.getBody());
                   HttpResponse response = http.send(request);
                   if(response.getStatusCode() != 200){
                        System.debug('Invalid Status Code from API:'+response.getStatusCode());
                        System.debug('Error Response Body:'+response.getBody());
                        objCase.cc_Checker_Result_Date_Time__c = System.now();
                        objCase.cc_Checker_Result__c = '';
                        caseListToUpdate.add(objCase);
                        lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Customer Update Profile', 'Update Customer Profile');
                        
                   }
                   else{
                        System.debug('Success response code:'+response.getStatusCode());
                        System.debug('Success Response Body:'+response.getBody());
                        Account acc = new Account();
                        acc.Id = objCase.AccountId;
                        if((objCase.Type == 'Personal Info Update' || objCase.Type == 'Profile Update') && objCase.Sub_Type__c == 'Mobile update'){
                          acc.Mobile_Country_Code__pc = objCase.Account.Mobile_Country_Code_Update__pc;
                          acc.PersonMobilePhone = objCase.Account.Mobile_Update__pc;
                          accListToUpdate.add(acc);  
                        }
                        else if((objCase.Type == 'Personal Info Update' || objCase.Type == 'Profile Update') && objCase.Sub_Type__c == 'Email update')
                        {
                            acc.PersonEmail = objCase.Account.Email_Update__pc;
                            accListToUpdate.add(acc);  
                        }
                        else if((objCase.Type == 'Personal Info Update' || objCase.Type == 'Profile Update') && (objCase.Sub_Type__c == 'Expired ID Update' || objCase.Sub_Type__c == 'ID Expiry Update' || objCase.Sub_Type__c == 'ID Type Update')){
                           acc.ID_Type__pc =  objCase.Account.ID_Type_Update__pc;
                           acc.ID_Expiry_Date__pc = objCase.Account.ID_Expiry_Date_Update__pc;
                           accListToUpdate.add(acc);
                        }
                        else if((objCase.Type == 'Personal Info Update' || objCase.Type == 'Profile Update') && (objCase.Sub_Type__c == 'Name Fix / Update' || objCase.Sub_Type__c == 'Name Update')){
                           if(objCase.Account.FirstName_Update__pc != null)
                                acc.FirstName = objCase.Account.FirstName_Update__pc;
                           if(objCase.Account.MiddleName_Update__pc != null)
                                acc.MiddleName = objCase.Account.MiddleName_Update__pc;
                           if(objCase.Account.LastName_Update__pc != null)
                                acc.LastName = objCase.Account.LastName_Update__pc;
                           accListToUpdate.add(acc);
                        }
                       else if((objCase.Type == 'Personal Info Update' || objCase.Type == 'Profile Update') && objCase.Sub_Type__c == 'Address update'){
                           if(objCase.Account.Proof_of_Address_Id_Update__pc != null)
                               acc.Proof_of_Address_Id__pc = objCase.Account.Proof_of_Address_Id_Update__pc;
                           if(objCase.Account.Proof_of_Address_ID_Type_Update__pc != null)
                               acc.Proof_of_Address_ID_Type__pc = objCase.Account.Proof_of_Address_ID_Type_Update__pc;
                           if(objCase.Account.Address_ID_Expiry_Date_Update__pc != null)
                               acc.Address_ID_Expiry_Date__pc = objCase.Account.Address_ID_Expiry_Date_Update__pc;
                           if(objCase.Account.Mailing_Street_Update__pc != null)
                               acc.PersonMailingStreet = objCase.Account.Mailing_Street_Update__pc;
                           if(objCase.Account.Mailing_City_Update__pc != null)
                               acc.PersonMailingCity = objCase.Account.Mailing_City_Update__pc;
                           if(objCase.Account.Postcode_Block_Update__pc != null)
                               acc.PersonMailingPostalCode = objCase.Account.Postcode_Block_Update__pc;
                           if(objCase.Account.Mailing_Country_Update__pc != null)
                               acc.PersonMailingCountry = objCase.Account.Mailing_Country_Update__pc;
                           accListToUpdate.add(acc);
                       }
                       else if((objCase.Type == 'Personal Info Update' || objCase.Type == 'Profile Update') && objCase.Sub_Type__c == 'Additional Information'){
                            if(objCase.Account.Residency_Permit_Number_Update__pc != null)
                               acc.Residency_Permit_Number__pc = objCase.Account.Residency_Permit_Number_Update__pc;
                            if(objCase.Account.Residency_Permit_Expiry_Update__pc != null)
                               acc.Residency_Permit_Expiry__pc = objCase.Account.Residency_Permit_Expiry_Update__pc;
                            if(objCase.Account.Employment_Status_Update__pc != null)
                               acc.Employment_Status__pc = objCase.Account.Employment_Status_Update__pc;
                            if(objCase.Account.Employer_Name_Update__pc != null)
                               acc.Employer_Name__pc = objCase.Account.Employer_Name_Update__pc;
                            if(objCase.Account.Employer_Country_Update__pc != null)
                               acc.Employer_Country__pc = objCase.Account.Employer_Country_Update__pc;
                            if(objCase.Account.Business_Name_Update__pc != null)
                               acc.Business_Name__pc = objCase.Account.Business_Name_Update__pc;
                            //if(objCase.Account.Business_Address_Update__pc != null)
                              // acc.Business_Address__pc = objCase.Account.Business_Address_Update__pc;
                            if(objCase.Account.Business_Industry_Update__pc != null)
                               acc.Business_Industry__pc = objCase.Account.Business_Industry_Update__pc;
                            if(objCase.Account.Sources_of_Funds_Update__pc != null)
                               acc.Sources_of_Funds__pc = objCase.Account.Sources_of_Funds_Update__pc;
                            if(objCase.Account.Gross_Monthly_Income_Update__pc != null)
                               acc.Gross_Monthly_Income__pc = objCase.Account.Gross_Monthly_Income_Update__pc;
                            if(objCase.Account.Expected_Monthly_deposits_Update__pc != null)
                               acc.Expected_Monthly_deposits__pc = objCase.Account.Expected_Monthly_deposits_Update__pc;
                            if(objCase.Account.Passport_Number_Update__pc != null)
                               acc.Passport_Number__pc = objCase.Account.Passport_Number_Update__pc;
                            if(objCase.Account.Passport_Expiry_Date_Update__pc != null)
                               acc.Passport_Expiry_Date__pc = objCase.Account.Passport_Expiry_Date_Update__pc;
                            if(objCase.Account.Nationality_Update__pc != null)
                               acc.Nationality__pc = objCase.Account.Nationality_Update__pc;
                            //if(objCase.Account.Place_of_birth_government_Update__pc != null)
                               //acc.Place_of_birth_government__pc = objCase.Account.Place_of_birth_government_Update__pc;
                            if(objCase.Account.Place_of_Birth_Update__pc != null)
                               acc.Place_of_Birth__pc = objCase.Account.Place_of_Birth_Update__pc;
                           accListToUpdate.add(acc);
                        }
                        else if((objCase.Type == 'Personal Info Update' || objCase.Type == 'Profile Update') && objCase.Sub_Type__c == 'Guardian Info'){
                            if(objCase.Account.Minor_Update__pc != null)
                                acc.Minor__pc = objCase.Account.Minor_Update__pc;
                            if(objCase.Account.Guardian_CIF_Update__pc != null)
                                acc.Guardian_CIF__pc = objCase.Account.Guardian_CIF_Update__pc;
                            //if(objCase.Account.Guardian_CPR_Update__pc != null)
                                //acc.Guardian_CPR__pc = objCase.Account.Guardian_CPR_Update__pc;
                            accListToUpdate.add(acc);
                        }
                       //CH01: Start
                       else if((objCase.Type == 'Personal Info Update' || objCase.Type == 'Profile Update') && objCase.Sub_Type__c == 'Credit Card Guarantor CIF'){
                           if(objCase.Account.Credit_Card_Guarantor_CIF_Update__pc != null){
                               acc.Credit_Card_Guarantor_CIF__pc = objCase.Account.Credit_Card_Guarantor_CIF_Update__pc;
                               accListToUpdate.add(acc);
                           }
                       }
                       //CH01: END
                       else if((objCase.Type == 'Personal Info Update' || objCase.Type == 'Profile Update') && objCase.Sub_Type__c == 'Geo-Location Check'){
                            acc.Bypass_Geo_Location_Check__pc = objCase.Account.Bypass_Geo_Location_Check_Update__pc;
                            acc.Bypass_Geo_Location_End_Date__pc = objCase.Account.Bypass_Geo_Location_End_Date_Update__pc;
                            acc.Bypass_Geo_Location_Country__pc = objCase.Account.Bypass_Geo_Location_Country_Update__pc;
                          /*  if(objCase.Account.Bypass_Geo_Location_Check_Update__pc){
                                System.debug('skipRestrictedGeoLocationCode###'+String.valueOf((mapCaseIdRelatedAccRequest.get(objCase.id)).get('contactInformation')));
                            Map<String, Object> firstMap = (Map<String,Object>)(mapCaseIdRelatedAccRequest.get(objCase.id)).get('contactInformation');
                            acc.skipRestrictedGeoLocationCode__pc=String.valueOf(firstMap.get('skipRestrictedGeoLocationCode')); 
                            }else{
                                 acc.skipRestrictedGeoLocationCode__pc='';
                            }*/
                           
                            accListToUpdate.add(acc);
                        }
                        objCase.Sub_Status__c = 'Approved';
                        objCase.Status = 'Closed';
                        objCase.cc_Checker_Result_Date_Time__c = System.now();
                        caseListToUpdate.add(objCase);
                        lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Customer Update Profile', 'Update Customer Profile');

                   }
                } //If Ends
            } //for loop Ends
            if(accListToUpdate.size()>0){
                update accListToUpdate;
            }
            if(caseListToUpdate.size()>0){
                update caseListToUpdate;
            }
            if(lstSA.size()>0){
                insert lstSA;
            }
        }
    }
     public static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Final Integer statCode, Final String strAction, Final String strType) {
        List<System_Action__c> lstSA = new List<System_Action__c>();
        System_Action__c action = new System_Action__c();
        action.Account_Number__c = custId;
        action.Action__c = strAction;
        action.Case__c = CaseId;
        action.Account__c = AccId;
        action.Endpoint__c = path;
        action.Method__c = method;
        action.HTTP_Response_Code__c = statCode;
        action.Origin__c = 'CRM';
        action.Request_Body__c = reqBody;
        action.Response_Body__c = resBody;
        action.Target__c = 'Orchestration Layer';
        action.Type__c = strType;
        lstSA.add(action);
        
        return lstSA;
        
    }
    public static String generateRandomString(Integer len) {
    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    String randStr = '';
    while (randStr.length() < len) {
       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
       randStr += chars.substring(idx, idx+1);
    }
    return randStr; 
}
}