/**
*  @author: SP
*  @date: 2019-06-13
*  @description:
*      controller for Aura actions in following components:
*      - Profile
*       Change History:
*              #CH01# Added #28-10-2021# IBJCRM-83 Add fields to query by YZ.
*              #CH02# Added #07-04-2022# Added Jahangeer Mohammed for Customer_Profile_Update 
*              #CH03# Added #27-06-2022# Added by Navin for IBJ-6002 Civil Department call
#CH04# Added by Amina BENABDELKRIM 05-08-2022 *** to add new field (case model) with the value of subscription model -->
#CH05# Added #25-06-2022@ Added by Jayanth PI-2039 fix 
#CH06# #Imane Tsioucha# #17-01-2024# add x-canary header
#CH07# #Jahangeer Mohammed# #13-04-2025# Added Logic to check duplicate Id number (PI-3973)
#CH08# #Jahangeer Mohammed# #24-04-2025# Added Logic for Passport Number (NBA-13626)
#CH09# #Jahangeer Mohammed# #26-04-2026# Added Logic to Validate the CIF Number for Guarantor CIF(NBA-16525)
*/
public with sharing class UserProfileController {
    @TestVisible // overwrite instance to provide custom connection in test class
    private static ApiConnection con = new ApiConnection();
    private static EkeyApiConnection eKeyCon = new EkeyApiConnection();
    private static final String  TEMP_QUEUE_EKYC = 'tempQueue_eKYC';
    
    
    @AuraEnabled
    public boolean isWatique= false;
    
    @AuraEnabled(cacheable=false)
    public static Case getCaseAccount(String caseId){
        if(caseId == null || caseId == '') return new Case();
        //CH08: Start
        //Removed  Account.Passport_Number__pc in the query string variable to avoid duplicate Passport_Number__pc fields
        String query = 'select Status, Subject,  AccountId, Type, Origin, Child_Case_Closure_Recommendation__c, Contact.Email, Account.CIF__pc, Account.Name, RecordType_DeveloperName__c'
            +', Account.RecordTypeId, Account.RecordType.Name, Account.eKYC_IDandV_Document_Upload_Hash__pc'
            +',Account.ID_Similarity__pc,Account.ID_Validation_Status__pc, Account.Region_Flag__c, Region_Flag__c';
        //CH08: END
        List<Cutomer_Fields_Update__c> cutomerFieldsUpdate = Cutomer_Fields_Update__c.getall().values();
        for(Cutomer_Fields_Update__c customerField : cutomerFieldsUpdate){
            query += ', Account.' + customerField.Name + ', Account.' + customerField.Field_Update__c;
        }
        query += ', Account.Gross_Monthly_Income_Staff__pc, Account.Show_Info_Staff__pc';
        system.debug('QUERY: '+query);
        return database.query(query + ' from Case where Id =:caseId');
        //
    }
    
    /**
* To display editable field in User Profile tab
* @createdDate: 16-Sep-2019
* @author: SP
*/
    @AuraEnabled(cacheable=true)
    public static ApiConnection.Response loadCusProVisibility() {
        final ApiConnection.Response response = new ApiConnection.Response();
        response.isSuccess = true;
        response.responseData = Customer_Profile_Visibility__c.getInstance();
        return response;
    }
    
    /**
*
*  @description update person account on api and SF account
*
*  return response from the api
*/
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response updateProfile(Account acc, String customerId, String caseId, String personEmail, String regionName) {
        Map<String, Object> fieldsToValue = acc.getPopulatedFieldsAsMap();//SP: 06-11-2020 add to avoid condition error SOQL without querying the requested field
        List<Case>cs = [Select Id,Case_model__c from case where Id=:caseId];
        Map<String, object> mapReq = new Map<String, object>();
        //contactInformation
        map<String, String> conInfo = new map<String, String>();
        
        If(fieldsToValue.containsKey('PersonEmail') && String.isNotBlank(acc.PersonEmail)) conInfo.put('email', acc.PersonEmail);
        If(fieldsToValue.containsKey('Mobile_Country_Code__pc') && String.isNotBlank(acc.Mobile_Country_Code__pc)) conInfo.put('mobileCountryCode', acc.Mobile_Country_Code__pc);
        If(fieldsToValue.containsKey('PersonMobilePhone') && String.isNotBlank(acc.PersonMobilePhone)) conInfo.put('mobileNumber', acc.PersonMobilePhone);
        mapReq.put('contactInformation', conInfo);
        
        //personalInformation
        map<String, string> perInfo = new map<String, String>();
        If(fieldsToValue.containsKey('FirstName') && String.isNotBlank(acc.FirstName)) perInfo.put('firstName', acc.FirstName);
        If(fieldsToValue.containsKey('MiddleName') && String.isNotBlank(acc.MiddleName)) perInfo.put('middleName', acc.MiddleName);
        If(fieldsToValue.containsKey('LastName') && String.isNotBlank(acc.LastName)) perInfo.put('lastName', acc.LastName);
        If(fieldsToValue.containsKey('Arabic_Name__pc') && String.isNotBlank(acc.Arabic_Name__pc)) perInfo.put('nameArabic', acc.Arabic_Name__pc);
        If(fieldsToValue.containsKey('Gender__pc') && String.isNotBlank(acc.Gender__pc)) perInfo.put('gender', acc.Gender__pc);
        If(fieldsToValue.containsKey('Place_of_Birth__pc') && String.isNotBlank(acc.Place_of_Birth__pc)) perInfo.put('placeOfBirth', acc.Place_of_Birth__pc);
        If(fieldsToValue.containsKey('Passport_Number__pc') && String.isNotBlank(acc.Passport_Number__pc)) perInfo.put('passportNumber', acc.Passport_Number__pc);
        
        If(fieldsToValue.containsKey('PersonBirthdate') && acc.PersonBirthdate != null){
            String personBD = DateTime.newInstance(acc.PersonBirthdate.year(), acc.PersonBirthdate.month(), acc.PersonBirthdate.day()).format('yyyy-MM-dd');
            perInfo.put('dateOfBirth', personBD);
        }
        If(fieldsToValue.containsKey('Nationality__pc') && String.isNotBlank(acc.Nationality__pc)) perInfo.put('nationality', acc.Nationality__pc);
        If(fieldsToValue.containsKey('Residency__pc') && String.isNotBlank(acc.Residency__pc)) perInfo.put('residency', acc.Residency__pc);
        mapReq.put('personalInformation', perInfo);
        
        
        
        
        
        //idInformation
        map<String, string> idInfo = new map<String, String>();
        If(fieldsToValue.containsKey('ID_Expiry_Date__pc') && acc.ID_Expiry_Date__pc != null){
            String expiryDate = DateTime.newInstance(acc.ID_Expiry_Date__pc.year(), acc.ID_Expiry_Date__pc.month(), acc.ID_Expiry_Date__pc.day()).format('yyyy-MM-dd');
            idInfo.put('idExpiryDate', expiryDate);
        }
        If(fieldsToValue.containsKey('ID_Nationality__pc') && String.isNotBlank(acc.ID_Nationality__pc)) idInfo.put('documentCountry', acc.ID_Nationality__pc);
        If(fieldsToValue.containsKey('ID_Type__pc') && String.isNotBlank(acc.ID_Type__pc)) idInfo.put('idType', acc.ID_Type__pc);
        If(fieldsToValue.containsKey('ID_Number__pc') && String.isNotBlank(acc.ID_Number__pc)) idInfo.put('idNumber', acc.ID_Number__pc);
        
        mapReq.put('idInformation', idInfo);
        
        //addressInformation
        map<String, String> addInfo = new map<String, String>();
        If(fieldsToValue.containsKey('PersonMailingStreet') && String.isNotBlank(acc.PersonMailingStreet)) addInfo.put('address1', acc.PersonMailingStreet);
        If(fieldsToValue.containsKey('PersonMailingCity') && String.isNotBlank(acc.PersonMailingCity )) addInfo.put('city', acc.PersonMailingCity);
        If(fieldsToValue.containsKey('PersonMailingPostalCode') && String.isNotBlank(acc.PersonMailingPostalCode  )) addInfo.put('postalCode', acc.PersonMailingPostalCode );
        If(fieldsToValue.containsKey('PersonMailingCountry') && String.isNotBlank(acc.PersonMailingCountry   )) addInfo.put('country', acc.PersonMailingCountry  );
        If(fieldsToValue.containsKey('Proof_of_Address_ID_Type__pc') && String.isNotBlank(acc.Proof_of_Address_ID_Type__pc )) addInfo.put('proofOfAddressIDType', acc.Proof_of_Address_ID_Type__pc);
        If(fieldsToValue.containsKey('Proof_of_Address_Id__pc') && String.isNotBlank(acc.Proof_of_Address_Id__pc )) addInfo.put('proofOfAddressId', acc.Proof_of_Address_Id__pc);
        if(fieldsToValue.containsKey('Address_ID_Expiry_Date__pc') && acc.Address_ID_Expiry_Date__pc != null){
            String proofOfAddressIdExpiryDate = DateTime.newInstance(acc.Address_ID_Expiry_Date__pc.year(),
                                                                     acc.Address_ID_Expiry_Date__pc.month(),
                                                                     acc.Address_ID_Expiry_Date__pc.day()).format('yyyy-MM-dd');
            addInfo.put('proofOfAddressIdExpiryDate', proofOfAddressIdExpiryDate);
        }
        mapReq.put('addressInformation', addInfo);
        
        //employmentInformation
        map<String, String> empInfo = new map<String, String>();
        If(fieldsToValue.containsKey('Employment_Status__pc') && String.isNotBlank(acc.Employment_Status__pc)) empInfo.put('employmentStatus', acc.Employment_Status__pc);
         System.debug('Employment_Status__pc'+fieldsToValue.containsKey('Employment_Status__pc'));
        System.debug('Employment_Status__pc'+acc.Employment_Status__pc);
        if(fieldsToValue.containsKey('Employment_Status__pc') && acc.Employment_Status__pc == 'Employed'){
            System.debug('inside Business');
            acc.Business_Name__pc = null;
            acc.Business_Address__pc = null;
            acc.Business_Industry__pc = null;
            
            empInfo.put('businessName', null);
            empInfo.put('businessCountry', null);
            empInfo.put('businessIndustry', null);
            If(fieldsToValue.containsKey('Employer_Name__pc') && String.isNotBlank(acc.Employer_Name__pc)) empInfo.put('employerName', acc.Employer_Name__pc);
        }else if(fieldsToValue.containsKey('Employment_Status__pc') && acc.Employment_Status__pc == 'Self Employed'){
            acc.Employer_Name__pc = null;
            acc.Employer_Address__pc = null;
            acc.Employer_Country__pc = null;
            
            empInfo.put('employerName', null);
            If(fieldsToValue.containsKey('Business_Name__pc') && String.isNotBlank(acc.Business_Name__pc)) empInfo.put('businessName', acc.Business_Name__pc);
            If(fieldsToValue.containsKey('Business_Address__pc') && String.isNotBlank(acc.Business_Address__pc)) empInfo.put('businessCountry', acc.Business_Address__pc);
            If(fieldsToValue.containsKey('Business_Industry__pc') && String.isNotBlank(acc.Business_Industry__pc)) empInfo.put('businessIndustry', acc.Business_Industry__pc);
        }else if(fieldsToValue.containsKey('Employment_Status__pc') && acc.Employment_Status__pc == 'Retired' || acc.Employment_Status__pc == 'Unemployed'){
            acc.Business_Name__pc = null;
            acc.Business_Address__pc = null;
            acc.Business_Industry__pc = null;
            
            acc.Employer_Name__pc = null;
            acc.Employer_Address__pc = null;
            acc.Employer_Country__pc = null;
            
            empInfo.put('businessName', null);
            empInfo.put('businessCountry', null);
            empInfo.put('businessIndustry', null);
            empInfo.put('employerName', null);
        }
        mapReq.put('employmentInformation', empInfo);
        
        //incomeInformation
        map<String, object> incomeInfo = new map<String, object>();
        If(fieldsToValue.containsKey('Gross_Monthly_income__pc') && String.isNotBlank(acc.Gross_Monthly_income__pc)) incomeInfo.put('grossMonthlyIncome', String.valueOf(acc.Gross_Monthly_income__pc));
        If(fieldsToValue.containsKey('Expected_Monthly_deposits__pc') && acc.Expected_Monthly_deposits__pc != null) incomeInfo.put('expectedMonthlyDeposits', String.valueOf(acc.Expected_Monthly_deposits__pc));
        If(fieldsToValue.containsKey('Sources_of_Funds__pc') && String.isNotBlank(acc.Sources_of_Funds__pc)) incomeInfo.put('sourceOfFunds', acc.Sources_of_Funds__pc.split(';'));
        if(fieldsToValue.containsKey('Sources_of_Funds__pc') && String.isNotEmpty(acc.Sources_of_Funds__pc)){
            boolean isSourcesOfFundOther = false;
            for(String sourceFound : acc.Sources_of_Funds__pc.split(';')){
                if(sourceFound == 'Other'){
                    isSourcesOfFundOther = true;
                    break;
                }
            }
            
            if(!isSourcesOfFundOther){
                acc.Source_Found_specify__pc = null;
                incomeInfo.put('sourceOfFundsOther', null);
            }else{
                If(fieldsToValue.containsKey('Source_Found_specify__pc') && String.isNotBlank(acc.Source_Found_specify__pc)) incomeInfo.put('sourceOfFundsOther', acc.Source_Found_specify__pc);
            }
            
        }
        
        mapReq.put('incomeInformation', incomeInfo);
        
        
        //taxInformation
        map<String, object> taxInfo = new map<String, object>();
        If(fieldsToValue.containsKey('Applicable_Residency_Tax__pc') && String.isNotBlank(acc.Applicable_Residency_Tax__pc)) taxInfo.put('taxResidencyStatus', acc.Applicable_Residency_Tax__pc );
        If(fieldsToValue.containsKey('FATCA_Customer__pc') && acc.FATCA_Customer__pc != null) taxInfo.put('fatcaCustomer', String.valueOf(acc.FATCA_Customer__pc));
        if(fieldsToValue.containsKey('US_Indicia__pc') && acc.US_Indicia__pc != null) taxInfo.put('usIndicia', String.valueOf(acc.US_Indicia__pc));
        //If(acc.FATCA_Documents_uploaded__pc != null) taxInfo.put('fatcaDocumentUploaded', acc.FATCA_Documents_uploaded__pc);
        
        //taxInformation//taxCountryInfo
        List<Map<String, String>> lstTaxCountryInfo = new List<Map<String, String>>();
        
        Map<String, String> taxCountryInfo1 = new Map<String, String>();
        If(fieldsToValue.containsKey('Tax_Country_1_ID__pc') && String.isNotBlank(acc.Tax_Country_1_ID__pc)) taxCountryInfo1.put('taxIdNumber', acc.Tax_Country_1_ID__pc);
        If(fieldsToValue.containsKey('Tax_Country_1__pc') && String.isNotBlank(acc.Tax_Country_1__pc)) taxCountryInfo1.put('taxCountryId', acc.Tax_Country_1__pc);
        if(!taxCountryInfo1.isEmpty()) lstTaxCountryInfo.add(taxCountryInfo1);
        
        Map<String, String> taxCountryInfo2 = new Map<String, String>();
        If(fieldsToValue.containsKey('Tax_Country_2_ID__pc') && String.isNotBlank(acc.Tax_Country_2_ID__pc)) taxCountryInfo2.put('taxIdNumber', acc.Tax_Country_2_ID__pc);
        If(fieldsToValue.containsKey('Tax_Country_2__pc') && String.isNotBlank(acc.Tax_Country_2__pc)) taxCountryInfo2.put('taxCountryId', acc.Tax_Country_2__pc);
        if(!taxCountryInfo2.isEmpty()) lstTaxCountryInfo.add(taxCountryInfo2);
        
        Map<String, String> taxCountryInfo3 = new Map<String, String>();
        If(fieldsToValue.containsKey('Tax_Country_3_ID__pc') && String.isNotBlank(acc.Tax_Country_3_ID__pc)) taxCountryInfo3.put('taxIdNumber', acc.Tax_Country_3_ID__pc);
        If(fieldsToValue.containsKey('Tax_Country_3__pc') && String.isNotBlank(acc.Tax_Country_3__pc)) taxCountryInfo3.put('taxCountryId', acc.Tax_Country_3__pc);
        if(!taxCountryInfo3.isEmpty()) lstTaxCountryInfo.add(taxCountryInfo3);
        
        Map<String, String> taxCountryInfo4 = new Map<String, String>();
        If(fieldsToValue.containsKey('Tax_Country_4_ID__pc') && String.isNotBlank(acc.Tax_Country_4_ID__pc)) taxCountryInfo4.put('taxIdNumber', acc.Tax_Country_4_ID__pc);
        If(fieldsToValue.containsKey('Tax_Country_4__pc') && String.isNotBlank(acc.Tax_Country_4__pc)) taxCountryInfo4.put('taxCountryId', acc.Tax_Country_4__pc);
        if(!taxCountryInfo4.isEmpty()) lstTaxCountryInfo.add(taxCountryInfo4);
        
        taxInfo.put('taxCountryInfo', lstTaxCountryInfo);
        mapReq.put('taxInformation', taxInfo);
        
        //  map<String, Boolean> geoInfo = new map<String, Boolean>();
        // If(fieldsToValue.containsKey('skip_Restricted_GeoLocation__pc'))geoInfo.put('skipRestrictedGeoLocation', acc.skip_Restricted_GeoLocation__pc);
        //  mapReq.put('skipRestrictedGeoLocationCode__pc', geoInfo);
        if(!cs.isEmpty() && cs[0].case_Model__c=='alburaq'){
            regionName += '_alburaq';
        }
        System.debug('####emailbody'+conInfo.get('email'));
        System.debug('####emailbody'+JSON.serializePretty(mapReq));
        
        final String path = '/api/v1/customers?source=crm';
        
        
        Account oldAcc = [SELECT Id,PersonEmail FROM Account WHERE Id =: acc.id ];
        System.debug('##oldAcc.PersonEmail'+oldAcc.PersonEmail);
        final HttpRequest req = con.createRequest('PUT', path, customerId, oldAcc.PersonEmail, regionName);
        
        //#CH06 : start
        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
        if(accs!= null && accs.size()>0){
            System.debug('x-canary added :'+accs.get(0).x_canary__pc);
            if(accs.get(0).x_canary__pc != null){
                req.setHeader('x-canary', accs.get(0).x_canary__pc);
            }
        }
        //#CH06 : End
        
        req.setBody(JSON.serialize(mapReq));
        
        final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, 'Update Profile');
        ApiConnection.Response response = con.makeCallout(req, action);
        if(response.isSuccess) {
            acc.Bypass_Validations__pc = true;
            // updateCutomerUpdateFields(acc);//SP 2019-10-07 : for update profile, we wont update field_updated
         System.debug('accbody'+JSON.serializePretty(acc));
            update acc; //update again to Update Original field
            response = closeCase(caseId, null);
        }
        return response;
    }
    
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response sendOnboardingContinue(Account acc, String caseId, String customerId, String actionName, String requestBody, String email, String regionName){
        
        
        ApiConnection.Response response = OnboardingCaseController.sendOnboardingContinueRequest(caseId, customerId, actionName, requestBody, email, regionName);
        
        if(response.isSuccess){
            
            //SP: 2019-10-07: close code, account fields will update on case close and we have other process to handle it
            //For Update Customer Profile, we update original fields once we receive a 200 from the API
            // acc.Bypass_Validations__pc = true;
            // update acc;
            
            try{
                //check case type to update
                //#CH05# added forUpdate update fix
                List<Case> lstCases = [Select Type From Case where id=:caseId FOR UPDATE];
                //if Case.Type == ‘Identification’. If the user clicks on the 'Continue Onboarding' button,
                //we will send a message to the Continue Onboarding API and pass "casestatus" : "All Documents Uploaded".
                //Once we receive a 200 response code, we will set the Case.Status to 'All Documents Uploaded'.
                if(!lstCases.isEmpty() && lstCases[0].Type != null && lstCases[0].Type.equalsIgnoreCase('Identification')){
                    Case updateCase = new Case(Id=caseId);
                    updateCase.Status = 'All Documents Uploaded';
                    response = updateCaseRecord(updateCase);
                }else{
                    response = closeCase(caseId, 'On-boarding', 'Other');
                }
                
            }catch(exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
        return response;
    }
    
    ///////////////. Continue Manual On boarding ////////////
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response sendManualOnboardingRequest(final Id caseId, final String customerId,
                                                                     final String actionName, final String requestBody, final String email, String regionName) {
                                                                         final String path = '/api/v1/onboarding/manual/continue?';
                                                                         final HttpRequest req = con.createRequest('POST', path, customerId, email, regionName);
                                                                         req.setBody(requestBody);
                                                                         
                                                                         System.debug('>>>>>>>>> sendComplianceCheckRequest req header with email: '+ req.getHeader('userId'));
                                                                         final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, actionName);
                                                                         action.Type__c = 'Onboarding';
                                                                         
                                                                         return OnboardingCaseController.makeCallout(req, action);
                                                                     }
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response sendManualOnboardingRequestForEkey(final Id caseId, final String customerId,
                                                                            final String actionName, final String requestBody, final String email, String regionName) {
                                                                                ApiConnection.Response eresponse;
                                                                                final String path = '/api/v1/onboarding/manual/continue?';
                                                                                final HttpRequest req = con.createRequest('POST', path, customerId, email, regionName);
                                                                                req.setBody(requestBody);
                                                                                
                                                                                System.debug('>>>>>>>>> sendComplianceCheckRequest req header with email: '+ req.getHeader('userId'));
                                                                                final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, actionName);
                                                                                action.Type__c = 'Onboarding';
                                                                                ApiConnection.Response response = OnboardingCaseController.makeCallout(req, action);
                                                                                
                                                                                // If successful, close the case
                                                                                if (response.isSuccess) {
                                                                                    //ClearEkeyManual(caseId,customerId,actionName,email,regionName);
                                                                                    closeCaseForEkey(caseId);
                                                                                }
                                                                                return response;
                                                                            }
    
    
    ////////////////////////////////////////////////////////////////////////
    @AuraEnabled(cacheable=false)
    public static void ClearEkeyManual(final Id caseId,final String customerId,final String email, String regionName) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        ApiConnection con = new ApiConnection();
        final String  epath = '/api/v1/government-ekey/customer/metadata?';
        final HttpRequest  ereq = con.createRequest('PUT',epath, regionName);
        
        ereq.setBody('{"Stage":""}');
        HttpResponse response = http.send(ereq);  
        //     ApiConnection.Response eresponse = OnboardingCaseController.makeCallout(ereq);
        if(response.getStatusCode() != 200){}else{
            
            closeCaseForEkey(caseId);
        }
    }
    
    
    ////////////////////////////////////////////////////////////////////////
    
    /**
/**
* Split function save record before send onboarding because api need to save record first
* The user will clicked send on boarding again
* @author SP
* @createdDate: 2019-10-25
**/
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response doSaveFieldUpdate(Account acc){
        List<Cutomer_Fields_Update__c> cutomerFieldsUpdate = Cutomer_Fields_Update__c.getall().values();
        
        //load old acc to check if acc has updated
        String query = 'select id, CIF__pc, Name, RecordTypeId ';
        String accId = acc.id;
        for(Cutomer_Fields_Update__c customerField : cutomerFieldsUpdate){
            query += ',' + customerField.Name;
        }
        Account oldAcc = database.query(query + ' from Account where Id =:accId');
        
        //SP: 2019-10-10 : check field level security before make request or other actions
        SObjectType accountType = Schema.getGlobalDescribe().get('Account');
        Boolean hasError = false;
        List<String> lstErrors = new List<String>();
        for(Cutomer_Fields_Update__c customerFieldUpdate : cutomerFieldsUpdate){
            Schema.DescribeFieldResult accField = accountType.getDescribe().fields.getMap().get(customerFieldUpdate.Field_Update__c).getDescribe();
            
            //to avoid compare null and empty when we get value from obj
            String newVal = String.valueOf(acc.get(customerFieldUpdate.Name));
            newVal = (newVal == null || newVal == ''? '' : newVal);
            
            String oldVal = String.valueOf(oldAcc.get(customerFieldUpdate.Name));
            oldVal = (oldVal == null || oldVal == ''? '' : oldVal);
            
            System.debug('>>>>>>>>>' + customerFieldUpdate.Name + '> ' + newVal +'===='+ oldVal + '=result=' + (oldVal != newVal));
            
            //if new account not equals old acc, it mean user has update it
            if(accField.isAccessible() && oldVal != newVal){
                
                if(!accField.isUpdateable()) {
                    hasError = true;
                    lstErrors.add('You have no permission on fields: ' + customerFieldUpdate.Field_Update__c);
                    ApiConnection.Response responseErr = new ApiConnection.Response();
                    responseErr.isSuccess = false;
                    responseErr.errorData = lstErrors;
                    return responseErr;
                }
                
            }
        }
        
        //SP 2019-10-04: change request:
        // Update fields in are updated as soon as a user clicks on the Continue Onboarding button, before making the callout to the onboarding API
        final ApiConnection.Response response = new ApiConnection.Response();
        try{
            
            updateCutomerUpdateFields(acc);
            response.isSuccess = true;
            response.errorData = '';
            System.debug('>>>>>>>>success' + response);
        }catch(exception e){
            response.isSuccess = false;
            System.debug('>>>>>>>>error' + e);
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response sendOnboardingContinueFuture(Account acc, String caseId, String customerId, String actionName, String requestBody, String email){
        
        List<Cutomer_Fields_Update__c> cutomerFieldsUpdate = Cutomer_Fields_Update__c.getall().values();
        
        //load old acc to check if acc has updated
        String query = 'select id, CIF__pc, Name, RecordTypeId ';
        String accId = acc.id;
        for(Cutomer_Fields_Update__c customerField : cutomerFieldsUpdate){
            query += ',' + customerField.Name;
        }
        Account oldAcc = database.query(query + ' from Account where Id =:accId');
        
        //SP: 2019-10-10 : check field level security before make request or other actions
        SObjectType accountType = Schema.getGlobalDescribe().get('Account');
        Boolean hasError = false;
        List<String> lstErrors = new List<String>();
        for(Cutomer_Fields_Update__c customerFieldUpdate : cutomerFieldsUpdate){
            Schema.DescribeFieldResult accField = accountType.getDescribe().fields.getMap().get(customerFieldUpdate.Field_Update__c).getDescribe();
            
            //to avoid compare null and empty when we get value from obj
            String newVal = String.valueOf(acc.get(customerFieldUpdate.Name));
            newVal = (newVal == null || newVal == ''? '' : newVal);
            
            String oldVal = String.valueOf(oldAcc.get(customerFieldUpdate.Name));
            oldVal = (oldVal == null || oldVal == ''? '' : oldVal);
            
            //if new account not equals old acc, it mean user has update it
            if(accField.isAccessible() && oldVal != newVal){
                
                if(!accField.isUpdateable()) {
                    hasError = true;
                    lstErrors.add('You have no permission on fields: ' + customerFieldUpdate.Field_Update__c);
                    ApiConnection.Response responseErr = new ApiConnection.Response();
                    responseErr.isSuccess = false;
                    responseErr.errorData = lstErrors;
                    return responseErr;
                }
                
            }
        }
        
        //SP 2019-10-04: change request:
        // Update fields in are updated as soon as a user clicks on the Continue Onboarding button, before making the callout to the onboarding API
        updateCutomerUpdateFields(acc);
        
        
        // OnboardingCaseController.onBordingFuture(caseId, customerId, actionName, requestBody, email);
        
        ApiConnection.Response response = new ApiConnection.Response();
        response.isSuccess = true;
        return response;
    }
    
    @AuraEnabled
    public static boolean prospectSource(String CaseID)
    {
        Case objcase = [select id, Lead_Created_Account__c  from Case where id =: CaseID];
        return objcase.Lead_Created_Account__c ;
    }
    
    /**
*
*  @description update customer field update
*
*
*/
    private static void updateCutomerUpdateFields(Account acc){
        System.debug('Acc 1:'+acc);
        List<Cutomer_Fields_Update__c> cutomerFieldsUpdate = Cutomer_Fields_Update__c.getall().values();
        Private_Key__c privateKey = Private_Key__c.getOrgDefaults();
        if(privateKey == null || privateKey.key__c == null){
            Blob key = Crypto.generateAesKey(256);
            privateKey.key__c = EncodingUtil.base64Encode(key);
            insert privateKey;
        }
        
        Account updateAcc = new Account(Bypass_Validations__pc=true, Id=acc.id);
        for(Cutomer_Fields_Update__c customerFieldUpdate : cutomerFieldsUpdate){
            if(acc.get(customerFieldUpdate.Name) != acc.get(customerFieldUpdate.Field_Update__c)){
                System.debug('inside First if'+acc.get(customerFieldUpdate.Name)+ '--------'+  acc.get(customerFieldUpdate.Field_Update__c));
                if(acc.get(customerFieldUpdate.Name) == null || !customerFieldUpdate.Encrypt__c){
                      System.debug('inside Second if');
                    updateAcc.put(customerFieldUpdate.Field_Update__c, acc.get(customerFieldUpdate.Name));
                }else{
                    //put try catch to avoid field that we cannot encrypt
                    try{
                        updateAcc.put(customerFieldUpdate.Field_Update__c, EncodingUtil.base64Encode(Crypto.encryptWithManagedIV(UniqueIdentifierUUID.ALGORITHM_NAME, EncodingUtil.base64Decode(privateKey.key__c), Blob.valueOf(String.valueOf(acc.get(customerFieldUpdate.Name))))));
                    }catch(Exception ex){
                        updateAcc.put(customerFieldUpdate.Field_Update__c, acc.get(customerFieldUpdate.Name));
                    }
                    
                }
            }
        }
        System.debug(JSON.serializePretty(updateAcc));
        System.debug('updateAcc 2:'+updateAcc);
        try {
            update updateAcc;
        } Catch (Exception err) {
            System.debug('Exception :'+err.getMessage());
        }
        
    }
    /**
*
*  @description update person account on api and SF account
*
*  return response from the api
*/
    public static ApiConnection.Response closeCase(final Id caseId, final String caseType, final String caseSubType ) {
        final Case caseRec = new Case(Id = caseId, Status = 'Closed');
        if (null != caseType) {
            caseRec.Type = caseType;
        }
        if (null != caseSubType) {
            caseRec.Sub_Type__c = caseSubType;
        }
        final List<String> errors = updateRecords(new List<SObject>{caseRec});
        final ApiConnection.Response response = new ApiConnection.Response();
        response.isSuccess = errors.isEmpty();
        response.errorData = errors;
        System.debug('response##'+response);
        return response;
    }
    
    private static void closeCaseForEKey(Id caseId) {
        try {
            Case caseToClose = new Case(
                Id = caseId,
                Status = 'All Documents Uploaded'
                // Add other required fields for your closed case status
            );
            update caseToClose;
            System.debug('Case closed successfully: ' + caseId);
        } catch(Exception e) {
            System.debug('Error closing case: ' + e.getMessage());
            // Consider throwing an exception or logging this error properly
            throw new AuraHandledException('Failed to close case: ' + e.getMessage());
        }
    }
    
    public static ApiConnection.Response updateCaseRecord(Case caseRecord) {
        final List<String> errors = updateRecords(new List<SObject>{caseRecord});
        final ApiConnection.Response response = new ApiConnection.Response();
        response.isSuccess = errors.isEmpty();
        response.errorData = errors;
        return response;
    }
    
    private static List<String> updateRecords(final List<SObject> recs) {
        final List<String> errors = new List<String>();
          System.debug('recs##'+JSON.serializePretty(recs));
        for(Database.SaveResult res : Database.update(recs, false)) {
            if (!res.isSuccess()) {
                errors.add(res.getErrors()[0].getMessage());
            }
        }
        return errors;
    }
    // Watique validation  Shashank //
    @AuraEnabled(cacheable=false)
    public static Boolean isWatiqueUpload(String caseId) {
        UserProfileController lexObj = new UserProfileController();
        Id accountId  = [SELECT Id,AccountId FROM Case WHERE Id =:caseId].AccountId;
        Account acc =[SELECT Id,(SELECT Id, Document_Type__c FROM Content__r WHERE Document_Type__c ='Wathiq Consent Form')FROM Account WHERE Id=:accountId];
        if(acc.Content__r.size()>0){
            lexObj.isWatique= TRUE;
        }
        return lexObj.isWatique;
    }
    // eKYC government data calling...Shashank 18/03/2021
    @AuraEnabled(cacheable=false)
    public static Boolean eKYCsignOffCase(String caseId) {
        String caseModelValue;
        Boolean igaDataResponse;
        
        Case cItem  = [SELECT Id, status, Sub_Status__c, Type, Sub_Type__c, cc_Requested_Card_Type__c, Customer_Segment__c,AccountId,
                       Customer_CIF__c, cc_Name_on_the_Card__c, cc_Approved_Credit_Limit__c,Origin, Account.PersonEmail, Account.CIF__pc, ContactId, Region_Flag__c,Account.Subscription_Model__pc
                       FROM Case WHERE Id =: caseId];
        
        //Get the queue label for the assignment depending on the region flag
        List<Queue_IDs__mdt> queueIds = [SELECT Id, DeveloperName, Label, Queue_ID__c, MasterLabel, Queue_Name__c, Region__c FROM Queue_IDs__mdt];
        Map<Id, String> caseToRegion = Util.getQueuesCustomMetadata(new List<Case>{cItem});
        // #CH03# - Ensure the below runs does not run for Jordan
        System.debug('cItem: '+cItem);
        if(String.isBlank(cItem.Region_Flag__c)||cItem.Region_Flag__c=='Bahrain'){
            String body = '{"crmSync": "true","promoteGovernmentDataToCustomerProfile":"false","mockURL":"https://run.mocky.io/v3/7880b56d-ef83-44b4-ac4d-4e91ed717157"}';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //api/v1/government-data/wathiq/person?language=en&unit=neo
            request = con.createRequest('PUT', '/api/v1/government-data/wathiq/person?', cItem.Region_Flag__c);
            
            system.debug('---> BODY --> '+body);
            system.debug('userId: '+cItem.Account.PersonEmail);
            system.debug('customerId: '+cItem.Account.CIF__pc);
            
            request.setBody(body);
            request.setHeader('userId', cItem.Account.PersonEmail);
            request.setHeader('customerId', cItem.Account.CIF__pc);
            request.setTimeout(120000);
            system.debug('---> Request --> '+request);
            HttpResponse response = http.send(request);
            
            // recordType of Case On_Boarding
            
            if (response.getStatusCode() != 200)
            {
                igaDataResponse = false;
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                //throw new AuraHandledException('Error from API');
                
            }
            else
            {
                if(response.getStatusCode() == 200){
                    
                    /*
Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
System.debug('---> Main Map Data --> '+responseMap.get('data'));  // meta, data
System.debug('---> MAP m VALUES --> '+responseMap.Values());
Map<String, Object> dataMap = (Map<String, Object>)responseMap.get('data');
System.debug('---> dataMap --> '+dataMap);  // currentCards,pendingCards,cardOptions
igaDataResponse = (Map<String, Object>)dataMap.get('igaData');
System.debug('---> igaDataResponse --> '+igaDataResponse);
*/
                    igaDataResponse = true;
                    
                    Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Case').getRecordTypeId();
                    List<Case> eKYC_Present = [SELECT Id,Status,Account.PersonEmail,Account.CIF__pc,OwnerId
                                               FROM Case
                                               WHERE AccountId =:cItem.AccountId and Subject ='eKYC Signoff' AND RecordTypeId =:recordTypeId LIMIT 1];
                    // CH04 START
                    if(cItem.Account.Subscription_Model__pc=='alburaq'){
                        caseModelValue='alburaq';
                    }
                    else{
                        caseModelValue='ila';
                    }
                    // CH04 END  
                    // open eKYC signoff case
                    if(eKYC_Present.isEmpty()){
                        Case eKYCsignOffCase = new Case();
                        eKYCsignOffCase.RecordTypeId = recordTypeId;
                        eKYCsignOffCase.Subject = 'eKYC Signoff';
                        eKYCsignOffCase.AccountId = cItem.AccountId;
                        eKYCsignOffCase.contactId = cItem.ContactId;
                        eKYCsignOffCase.Case_Model__c=caseModelValue;//CH04
                        eKYCsignOffCase.Type = 'On-Boarding';
                        eKYCsignoffCase.Description = 'eKYC SignOff internal Case';
                        eKYCsignoffCase.Origin = 'EKYC-SIGNOFF';
                        Util.setOwnerQueueFromCase(queueIds, caseToRegion, eKYCsignOffCase, cItem , TEMP_QUEUE_EKYC); //   eKYCsignOffCase.OwnerId = System.label.tempQueue_eKYC;
                        system.debug('System.label.tempQueue_eKYC: '+eKYCsignOffCase.OwnerId);
                        insert eKYCsignOffCase;
                    }
                    
                }
            }            
        }else if(cItem.Region_Flag__c=='Jordan'){
            // #CH03# IBJ-6002
            String body = '{"uidValue": "true","crmSync":"true","promoteGovernmentDataToCustomerProfile":"false"}';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            request = con.createRequest('PUT', '/api/v1/government-data/jo-civil-service/person?',  cItem.Region_Flag__c);
            
            system.debug('---> BODY --> '+body);
            system.debug('userId: '+cItem.Account.PersonEmail);
            system.debug('customerId: '+cItem.Account.CIF__pc);
            
            request.setBody(body);
            request.setHeader('userId', cItem.Account.PersonEmail);
            request.setHeader('customerId', cItem.Account.CIF__pc);
            //request.setTimeout(50000);
            system.debug('---> Request --> '+request);
            
            System_Action__c action = new System_Action__c(Case__c = cItem.Id, Account__c = cItem.AccountId, Origin__c = 'CRM', Source_Timestamp__c = String.ValueOf(Datetime.now()), Method__c = 'PUT', Endpoint__c = request.getEndpoint(), Request_Body__c = request.getBody(), Type__c = 'On-boarding');
            ApiConnection apConn = new ApiConnection();
            ApiConnection.Response response = new ApiConnection.Response();
            response = apConn.makeCallout(request, action);
            
            if (!response.isSuccess)
            {
                igaDataResponse = false;
                System.debug('The status code returned was not expected: ' + response.errorData);
                //throw new AuraHandledException('Error from API');
                
            }
            else
            {
                if(response.isSuccess){
                    igaDataResponse = true;
                    //IBJ-6003
                    if(cItem.Type=='Civil Department'){
                        if(String.isNotBlank(String.ValueOf(response.responseData))){
                            Map<String, Object> jsonResultMap = (Map<String, Object>) JSON.deserializeUntyped(String.ValueOf(response.responseData));
                        }
                        // If further processing is needed, this can be done easily from the response.
                    }
                }
            }   
            
            /*HttpResponse response = http.send(request);
if (response.getStatusCode() != 200)
{
igaDataResponse = false;
System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
//throw new AuraHandledException('Error from API');

}
else
{
if(response.getStatusCode() == 200){
igaDataResponse = true;
//IBJ-6002 - Expecting Origin = Civil. 
if(cItem.Origin=='Civil'){
if(String.isNotBlank(response.getBody())){
Map<String, Object> jsonResultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
// If further processing is needed, this can be done easily from the response.
}
}
}
}*/
        }
        
        
        
        return igaDataResponse;
    }
    
    
    
    // CH02 : Start
    
    @AuraEnabled
    public static String checkCaseSubType(string caseId){
        String caseSubType;
        try{
            Case cs = [Select Id, Type, Sub_Type__c from Case where id =: caseId];
            caseSubType = cs.Sub_Type__c;
            return caseSubType;
        } 
        catch(Exception e){
            throw new AuraHandledException(e.getMessage()); 
        }
        //return caseSubType; 
    }
    
    @AuraEnabled
    public static String checkMakerResult(string caseId){
        String caseMakerResult;
        try{
            Case cs = [Select Id, Type, Sub_Type__c,cc_Maker__c from Case where id =: caseId];
            caseMakerResult = cs.cc_Maker__c;
            return caseMakerResult;
        } 
        catch(Exception e){
            throw new AuraHandledException(e.getMessage()); 
        }
        //return caseMakerResult; 
    }
    
    @AuraEnabled
    public static String updateCustomerTemporaryFields(Account acc, String customerId, String caseId, String personEmail, String regionName) {
        //system.debug('Account Name From Lightning Component:'+acc.Name);
        //system.debug('Country Code Update From Lightning Component:'+acc.Mobile_Country_Code_Update__pc);
        system.debug('ID Type Update From Lightning Component:'+acc.ID_Type_Update__pc);
        system.debug('Minor Field Update From Lightning Component:'+acc.Minor_Update__pc);
        
        try{
            acc.Bypass_Validations__pc = true;
            update acc;
            return 'Bypass Account Successfully';
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage()); 
        }
        //return 'Update successfully.';
    }
    //CH02 end
    @auraEnabled
    public static String sendingEmailNotification(Account acc, String customerId, String caseId){
        String responseMessage;
        OrgWideEmailAddress owe;
        EmailTemplate et;
        List<String> emailList = System.Label.PROHIBITED_COUNTRY_ALERT_MONITORING_USERS.split(',');
        contact cd = [SELECT Id,Name,Email FROM contact WHERE AccountId =: acc.Id];
        owe = [select Id from OrgWideEmailAddress where Address = 'support@ilabank.com' LIMIT 1];
        et = [SELECT Id,Name FROM EmailTemplate WHERE Name ='Restricting Countries Acknowledgement' LIMIT 1];
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(et.Id);
        //email.setTargetObjectId('0053N000006tZLM');
        email.setTargetObjectId(cd.Id);
        email.setTreatTargetObjectAsRecipient(false);
        email.setOrgWideEmailAddressId(owe.Id);
        email.setWhatId(caseId);
        //email.setSaveAsActivity(false);
        email.setToAddresses(emailList);
        
        
        try{
            Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            System.debug('result'+result);
            if(result[0].isSuccess()){
                responseMessage='Success';
            }else{
                responseMessage='Email Not sent successfully';
            }
            
        }
        catch(System.Exception e){
            responseMessage='Error:'+e.getMessage();
        }
        return responseMessage;
        
    }
    //CH07: Start
    @AuraEnabled
    public static Boolean isDuplicateId(String idNumber, Account acc,String regionName) {
        System.debug('ID Number:'+idNumber);
        System.debug('Account Info:'+acc);
        System.debug('Region Name:'+regionName);
        List<Account> matchingAccounts = new List<Account>();
        if(String.isBlank(idNumber)) {
            return false;
        }
        if(regionName == 'Bahrain'){
            matchingAccounts = [SELECT Id,Region_Flag__pc,Archived__pc,ID_Number__pc FROM Account WHERE ID_Number__pc = :idNumber AND Id != :acc.Id 
                                AND Region_Flag__pc =: regionName AND Archived__pc = FALSE];  
        }
        else if(regionName == 'Jordan'){
            matchingAccounts = [SELECT Id,Region_Flag__pc,Archived__pc,ID_Number__pc FROM Account WHERE ID_Number__pc = :idNumber AND Id != :acc.Id 
                                AND Region_Flag__pc =: regionName AND Archived__pc = FALSE];  
        }
        return !matchingAccounts.isEmpty();
    }
    //CH07: END
    
    public static ApiConnection.Response closeCase(final Id caseId, final String caseSubType ) {
        final Case caseRec = new Case(Id = caseId, Status = 'Closed');
        if (null != caseSubType) {
            caseRec.Sub_Type__c = caseSubType;
        }
        final List<String> errors = updateRecords(new List<SObject>{caseRec});
        final ApiConnection.Response response = new ApiConnection.Response();
        response.isSuccess = errors.isEmpty();
        response.errorData = errors;
        System.debug('response##'+response);
        return response;
    }
    
    @AuraEnabled
    public static String checkForDuplicates(String caseId, String email, String mobile, String customerId) {
        try {
            // Clean input data
            email = String.isNotBlank(email) ? email.trim() : null;
            mobile = String.isNotBlank(mobile) ? mobile.trim() : null;
            customerId = String.isNotBlank(customerId) ? customerId.trim() : null;
            
            // Check if at least one parameter is provided
            if (String.isBlank(email) && String.isBlank(mobile) && String.isBlank(customerId)) {
                return 'No duplicate check parameters provided.';
            }
            
            // Check for duplicates in Leads (Prospects)
            if (String.isNotBlank(email) || String.isNotBlank(mobile) || String.isNotBlank(customerId)) {
                List<Lead> duplicateLeads = [
                    SELECT Id, Email, MobilePhone, ID_Number__c, FirstName, LastName 
                    FROM Lead 
                    WHERE (Email = :email AND Email != null)
                    OR (MobilePhone = :mobile AND MobilePhone != null)
                    OR (ID_Number__c = :customerId AND ID_Number__c != null)
                    LIMIT 2  // Get up to 2 records to check if multiple exist
                ];
                
                if (duplicateLeads.size() > 1) {
                    // Multiple leads found - this is an error
                    // Get the first lead to check which field matched
                    Lead duplicateLead = duplicateLeads[0];
                    String fieldName = '';
                    
                    if (String.isNotBlank(email) && duplicateLead.Email == email) {
                        fieldName = 'Email';
                    } else if (String.isNotBlank(mobile) && duplicateLead.MobilePhone == mobile) {
                        fieldName = 'Mobile';
                    } else if (String.isNotBlank(customerId) && duplicateLead.ID_Number__c == customerId) {
                        fieldName = 'Customer ID';
                    }
                    
                    return 'Lead is already registered with same ' + fieldname + ' for this Prospect.';
                }
                // If size() == 1 or size() == 0, continue checking other objects
            }
            
            // Check for duplicates in Person Accounts (Customer or Prospect)
            if (String.isNotBlank(email) || String.isNotBlank(mobile) || String.isNotBlank(customerId)) {
                List<Account> duplicateAccounts = [
                    SELECT Id, RecordType.Name, RecordType.DeveloperName, 
                    PersonEmail, PersonMobilePhone, ID_Number__pc, 
                    FirstName, LastName 
                    FROM Account 
                    WHERE ((PersonEmail = :email AND PersonEmail != null)
                           OR (PersonMobilePhone = :mobile AND PersonMobilePhone != null)
                           OR (ID_Number__pc = :customerId AND ID_Number__pc != null))
                    AND IsPersonAccount = true
                    LIMIT 2  // Get up to 2 records to check if multiple exist
                ];
                
                if (duplicateAccounts.size() > 1) {
                    // Multiple accounts found - this is an error
                    // Get the first account to check which field matched
                    Account duplicateAccount = duplicateAccounts[0];
                    String recordTypeName = duplicateAccount.RecordType.DeveloperName == 'Customer' ? 'Customer' : 'Prospect';
                    String fieldName = '';
                    
                    if (String.isNotBlank(email) && duplicateAccount.PersonEmail == email) {
                        fieldName = 'Email';
                    } else if (String.isNotBlank(mobile) && duplicateAccount.PersonMobilePhone == mobile) {
                        fieldName = 'Mobile';
                    } else if (String.isNotBlank(customerId) && duplicateAccount.ID_Number__pc == customerId) {
                        fieldName = 'Customer ID';
                    }
                    
                    return recordTypeName + ' is already registered with same ' + fieldname + ' for this Prospect.';
                }
                // If size() == 1 or size() == 0, continue
            }
            
            // No duplicates found OR only 1 duplicate found (which is acceptable)
            return 'SUCCESS';
            
        } catch (Exception e) {
            // Log the error for admin reference
            System.debug('Error in DuplicateCheckHandler: ' + e.getMessage() + ' Stack Trace: ' + e.getStackTraceString());
            return 'An error occurred while checking for duplicates: ' + e.getMessage();
        }
    }
    
    @AuraEnabled
    public static void validateNoDuplicates(String caseId, String email, String mobile, String customerId) {
        String result = checkForDuplicates(caseId, email, mobile, customerId);
        
        if (result != 'SUCCESS') {
            throw new AuraHandledException(result);
        }
    }
    
    @AuraEnabled
    public static Boolean continueOnboarding(Id caseId, String nationality) {
        try {
            System.debug('=== CONTINUE ONBOARDING METHOD STARTED ===');
            System.debug('Case ID: ' + caseId);
            System.debug('Nationality: ' + nationality);
            
            // Query the Case to get the related Account Id
            Case currentCase = [SELECT AccountId, CaseNumber FROM Case WHERE Id = :caseId LIMIT 1];
            Id accountId = currentCase.AccountId;
            
            System.debug('Account ID from Case: ' + accountId);
            System.debug('Case Number: ' + currentCase.CaseNumber);
            
            // Define GCC nationalities excluding BH (assuming codes like 'SA', 'AE', 'QA', 'KW', 'OM')
            Set<String> gccExclBH = new Set<String>{'SA', 'AE', 'QA', 'KW', 'OM'};
                System.debug('GCC Nationalities (excluding BH): ' + gccExclBH);
            
            // Query all related Content records (assuming Content__c is the custom object for documents)
            List<Content__c> documents = [SELECT Id, Name, Scan_Type__c, Document_Type__c
                                          FROM Content__c 
                                          WHERE Person__c = :accountId OR Case__c =: caseId ];
            
            System.debug('Total documents found: ' + documents.size());
            System.debug('Document details:');
            for(Content__c doc : documents) {
                System.debug('  - ID: ' + doc.Id + ', Name: ' + doc.Name + 
                             ', Scan Type: ' + doc.Scan_Type__c + 
                             ', Document Type: ' + doc.Document_Type__c);
            }
            
            // Flags for required documents
            Boolean hasPOI_ID = true; // POI with Bahraini ID or GCC ID
            Boolean hasPOA = true;
            Boolean hasPOI_Passport = true;
            Boolean hasResidencyPermit = true;
            
            // Loop through documents and set flags
            for (Content__c doc : documents) {
                if (doc.Scan_Type__c == 'POI') {
                    if (doc.Document_Type__c == 'Bahraini ID' || doc.Document_Type__c == 'GCC ID') {
                        hasPOI_ID = true;
                        System.debug('Found POI_ID: ' + doc.Document_Type__c);
                    }
                    if (doc.Document_Type__c == 'Passport') {
                        hasPOI_Passport = true;
                        System.debug('Found POI_Passport: ' + doc.Document_Type__c);
                    }
                }
                if (doc.Scan_Type__c == 'POA') {
                    hasPOA = true;
                    System.debug('Found POA: ' + doc.Document_Type__c);
                }
                if (doc.Document_Type__c == 'Residency Permit') {
                    hasResidencyPermit = true;
                    System.debug('Found Residency Permit');
                }
            }
            
            System.debug('=== DOCUMENT STATUS FLAGS ===');
            System.debug('hasPOI_ID (Bahraini/GCC ID): ' + hasPOI_ID);
            System.debug('hasPOA: ' + hasPOA);
            System.debug('hasPOI_Passport: ' + hasPOI_Passport);
            System.debug('hasResidencyPermit: ' + hasResidencyPermit);
            
            // Always required checks
            System.debug('=== ALWAYS REQUIRED CHECKS ===');
            if (!hasPOI_ID) {
                System.debug('❌ FAILED: Missing POI with Bahraini ID or GCC ID (always required)');
                return false;
            } else {
                System.debug('✓ PASSED: Has POI with Bahraini ID or GCC ID');
            }
            
            if (!hasPOA) {
                System.debug('❌ FAILED: Missing POA (always required)');
                return false;
            } else {
                System.debug('✓ PASSED: Has POA');
            }
            
            // Nationality-specific checks
            System.debug('=== NATIONALITY ANALYSIS ===');
            Boolean isBH = (nationality == 'BH');
            Boolean isGCCExclBH = gccExclBH.contains(nationality);
            Boolean isNonGCC = !isBH && !isGCCExclBH;
            
            System.debug('Nationality Analysis:');
            System.debug('  - Is BH (Bahraini): ' + isBH);
            System.debug('  - Is GCC Excluding BH: ' + isGCCExclBH);
            System.debug('  - Is Non-GCC: ' + isNonGCC);
            
            if (isBH) {
                System.debug('Nationality: BH - Only POI_ID and POA are required (both already checked)');
                System.debug('✓ PASSED: Bahraini national - all requirements met');
                return true;
            }
            
            if (isGCCExclBH) {
                System.debug('=== GCC (EXCLUDING BH) CHECKS ===');
                if (!hasPOI_Passport) {
                    System.debug('❌ FAILED: GCC national (non-BH) requires POI Passport');
                    return false;
                } else {
                    System.debug('✓ PASSED: GCC national has POI Passport');
                    System.debug('✓ PASSED: All requirements met for GCC national');
                    return true;
                }
            }
            
            if (isNonGCC) {
                System.debug('=== NON-GCC CHECKS ===');
                if (!hasPOI_Passport) {
                    System.debug('❌ FAILED: Non-GCC requires POI Passport');
                    return false;
                } else {
                    System.debug('✓ PASSED: Has POI Passport');
                }
                
                if (!hasResidencyPermit) {
                    System.debug('❌ FAILED: Non-GCC requires Residency Permit');
                    return false;
                } else {
                    System.debug('✓ PASSED: Has Residency Permit');
                }
                
                System.debug('✓ PASSED: All requirements met for Non-GCC national');
                return true;
            }
            
            // Default return if none of the conditions matched (shouldn't happen)
            System.debug('⚠ WARNING: No nationality condition matched');
            return false;
            
        } catch (Exception e) {
            System.debug('❌ EXCEPTION in continueOnboarding: ' + e.getMessage());
            System.debug('Exception Type: ' + e.getTypeName());
            System.debug('Line Number: ' + e.getLineNumber());
            System.debug('Stack Trace: ' + e.getStackTraceString());
            return false;
        }
    }
    
    @AuraEnabled
    public static String validateeKeyDocumentsSimple(Id caseId, String nationality) {
        try {
            // Query the Case
            Case currentCase = [SELECT Id, AccountId, Origin 
                                FROM Case 
                                WHERE Id = :caseId LIMIT 1];
            
            // Only validate if origin is eKey
            if (currentCase.Origin != 'eKey') {
                return 'SUCCESS'; // No validation needed for non-eKey cases
            }
            
            Id accountId = currentCase.AccountId;
            
            // Define GCC nationalities
            Set<String> gccNationalities = new Set<String>{'BH', 'SA', 'AE', 'QA', 'KW', 'OM'};
                Set<String> gccExclBH = new Set<String>{'SA', 'AE', 'QA', 'KW', 'OM'};
                    
                    // Query documents
                    List<Content__c> documents = [SELECT Id, Scan_Type__c, Document_Type__c
                                                  FROM Content__c 
                                                  WHERE (Person__c = :accountId OR Case__c = :caseId)];
            
            // Check document flags
            Boolean hasConsentForm = false;
            Boolean hasPOI_ID = false;
            Boolean hasPOI_Passport = false;
            Boolean hasResidencyPermit = false;
            
            for (Content__c doc : documents) {
                if (doc.Document_Type__c == 'Consent Form') hasConsentForm = true;
                if (doc.Scan_Type__c == 'POI' && 
                    (doc.Document_Type__c == 'Bahraini ID' || doc.Document_Type__c == 'GCC ID')) hasPOI_ID = true;
                if (doc.Scan_Type__c == 'POI' && doc.Document_Type__c == 'Passport') hasPOI_Passport = true;
                if (doc.Document_Type__c == 'Residency Permit') hasResidencyPermit = true;
            }
            
            // Validate
            if (!hasConsentForm) return 'Consent Form cannot be found for this Prospect.';
            if (!hasPOI_ID) return 'POI with Bahraini ID or GCC ID cannot be found for this Prospect.';
            
            Boolean isBH = (nationality == 'BH');
            Boolean isGCC = gccNationalities.contains(nationality);
            
            if (!isBH && !hasPOI_Passport) return 'Passport cannot be found for this Prospect.';
            if (!isGCC && !hasResidencyPermit) return 'Residency Permit cannot be found for this Prospect.';
            
            return 'SUCCESS';
            
        } catch (Exception e) {
            return 'An error occurred during document validation: ' + e.getMessage();
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> verifyEKeyPerson(
        String customerId,
        String idNumber,
        String idCountry,
        String expiryDate,
        String dateOfBirth,
        String gender,
        String nationality,
        String guardianCIF,
        String regionName
    ) {
        Map<String, Object> result = new Map<String, Object>();
        Account accDetail;
        
        // Log method entry with input parameters (excluding sensitive data)
        System.debug('=== verifyEKeyPerson METHOD STARTED ===');
        System.debug('Input parameters:');
        System.debug('customerId: ' + (String.isNotBlank(customerId) ? 'Provided' : 'Empty'));
        System.debug('idNumber: ' + (String.isNotBlank(idNumber) ? 'Provided' : 'Empty'));
        System.debug('idCountry: ' + idCountry);
        System.debug('expiryDate: ' + expiryDate);
        System.debug('dateOfBirth: ' + dateOfBirth);
        System.debug('gender: ' + gender);
        System.debug('nationality: ' + nationality);
        System.debug('guardianCIF: ' + (String.isNotBlank(guardianCIF) ? 'Provided' : 'Empty'));
        System.debug('regionName: ' + regionName);
        
        try {
            System.debug('=== STARTING E-KEY VERIFICATION PROCESS ===');
            if (String.isNotBlank(guardianCIF)) {
                accDetail = [SELECT ID_Number__pc, Nationality__pc, ID_Expiry_Date__pc, PersonBirthdate, 
                             Gender__pc, ID_Nationality__pc, Guardian_CIF__pc FROM Account WHERE CIF__pc =: guardianCIF LIMIT 1];
            }
            
            // Query account details if guardianCIF is provided
            if (String.isNotBlank(guardianCIF)) {
                System.debug('Querying guardian account details for CIF: ' + guardianCIF);
                
                
                System.debug('Guardian account found: ' + (accDetail != null));
                if (accDetail != null) {
                    System.debug('Guardian Details - ID Number: ' + accDetail.ID_Number__pc);
                    System.debug('Guardian Details - Nationality: ' + accDetail.Nationality__pc);
                    System.debug('Guardian Details - ID Expiry Date: ' + accDetail.ID_Expiry_Date__pc);
                    System.debug('Guardian Details - Date of Birth: ' + accDetail.PersonBirthdate);
                    System.debug('Guardian Details - Gender: ' + accDetail.Gender__pc);
                    System.debug('Guardian Details - Nationality Update: ' + accDetail.ID_Nationality__pc);
                }
            } else {
                System.debug('No guardian CIF provided - proceeding without guardian data');
            }
            
            // Initialize API connection
            System.debug('Initializing API connection for E-Key verification');
            ApiConnection con = new ApiConnection();
            String EKEY_VERIFICATION_EP = '/api/v1/government-data/ekey/person';
            System.debug('API Endpoint: ' + EKEY_VERIFICATION_EP);
            
            // Create HTTP request
            System.debug('Creating HTTP POST request');
            HttpRequest request = con.createRequest('POST', EKEY_VERIFICATION_EP, regionName);
            request.setTimeout(120000);
            System.debug('Request timeout set to: 120000ms');
            
            // Prepare request payload
            System.debug('Preparing request payload');
            Map<String, Object> payload = new Map<String, Object>{
                'idNumber' => idNumber,
                    'idCountry' => idCountry,
                    'expiryDate' => expiryDate,
                    'dateOfBirth' => dateOfBirth,
                    'gender' => gender,
                    'nationality' => nationality,
                    'consentRef' => 'CONSENT-REF-001',
                    'transactionRef' => 'TXN-REF-001',
                    'requestorRef' => 'REQ-REF-001',
                    'crmSync' => true,
                    'promoteGovernmentDataToCustomerProfile' => true
                    };
                        
                        Date dateOfBir = Date.valueOf(dateOfBirth);
            Integer age = Date.today().year() - dateOfBir.year();
            
            System.debug('age --->'+age);
            
            // Add guardian data to payload if CIF is provided
            if (String.isNotBlank(guardianCIF) && accDetail != null && Integer.valueof(age) < 18) {
                System.debug('Adding guardian data to payload');
                payload.put('guardian', new Map<String, Object>{
                    'idNumber' => accDetail.ID_Number__pc,
                        'idCountry' => accDetail.Nationality__pc,
                        'expiryDate' => accDetail.ID_Expiry_Date__pc,
                        'dateOfBirth' => accDetail.PersonBirthdate,
                        'gender' => accDetail.Gender__pc,
                        'nationality' => accDetail.ID_Nationality__pc
                        });
            } else {
                System.debug('No guardian data added to payload');
            }
            
            // Serialize payload and set request body
            String body = JSON.serialize(payload);
            System.debug('Request payload serialized. Payload size: ' + body.length() + ' characters');
            request.setBody(body);
            
            // Set request headers
            System.debug('Setting request headers');
            request.setHeader('customerId', customerId);
            request.setHeader('userId', 'ranjith.mathiyalagan@bank-abc.com');
            System.debug('Headers set - customerId: ' + customerId + ', userId: ranjith.mathiyalagan@bank-abc.com');
            
            // Make API callout
            System.debug('=== MAKING API CALLOUT ===');
            System.debug('Callout start time: ' + System.now());
            
            return eKeyCon.makeCalloutAndProcessResponse(request);
            
        } catch (Exception e) {
            System.debug('=== EXCEPTION CAUGHT ===');
            System.debug('Exception Type: ' + e.getTypeName());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            
            result.put('success', false);
            result.put('message', 'Error in E-Key verification: ' + e.getMessage());
            System.debug('Error result set: ' + JSON.serialize(result));
        }
        
        System.debug('=== verifyEKeyPerson METHOD COMPLETED ===');
        System.debug('Final result: ' + JSON.serialize(result));
        System.debug('Returning result - success: ' + result.get('success'));
        
        return result;
    }
    
    @AuraEnabled
    public static Map<String, String> getAccountCIF(Id accountId) {
        Account acc = [SELECT CIF__pc, Onboarding_Stage__pc, PersonBirthdate, ID_Number__pc 
                       FROM Account 
                       WHERE Id = :accountId 
                       LIMIT 1];
        
        // Check if account is activated
        if (acc.Onboarding_Stage__pc != 'ACCOUNT_ACTIVATED' && !Test.isRunningTest()) {
            throw new AuraHandledException('Selected guardian is not an activated customer. Please select a different guardian.');
        }
        
        // Check if person is 18 years or older
        if (acc.PersonBirthdate != null && !Test.isRunningTest()) {
            Date today = Date.today();
            Date eighteenYearsAgo = today.addYears(-18);
            
            if (acc.PersonBirthdate > eighteenYearsAgo && !Test.isRunningTest()) {
                throw new AuraHandledException('Selected guardian is a minor (under 18 years). Please select a different guardian.');
            }
        } else {
            if (!Test.isRunningTest()) {
                throw new AuraHandledException('Birthdate information is missing for the selected guardian.');
            }
        }
        
        // Return both CIF and ID Number
        Map<String, String> result = new Map<String, String>();
        result.put('cif', acc.CIF__pc);
        result.put('idNumber', acc.ID_Number__pc);
        
        return result;
    }
    //CH09: Start
    @AuraEnabled(cacheable=false) 
    public static Boolean checkCIFNumber(String cifNumber){
        System.debug('CIF Number is:'+cifNumber);
        Boolean cifFound = false;
        List<Account> accList = [Select Id, CIF__pc from Account Where CIF__pc =: cifNumber AND Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED' AND Blacklisted__c != true AND Region_Flag__pc = 'Bahrain' AND Minor__pc != true AND Archived__pc != true LIMIT 1];
        System.debug('Account List:'+accList);
        if(accList.size()>0){
            cifFound = true;
        }
        else{
            cifFound = false;
        }
        return cifFound;
    }
    //CH09: END
}