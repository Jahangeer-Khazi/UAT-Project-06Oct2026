/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 15-06-2022
*       Change History: 
*    
*/
global class PeriodicReviewHandlerAPI {
    private static ApiConnection con = new ApiConnection();
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
    @future(callout=true)
    public static void fetcheKYCiGAData(Set<Id> setCaseId){
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> lstCase = [Select Id,AccountId,Customer_CIF__c,cc_ID_Number__c,IDandV_Document_Upload_Hash__c,Region_Flag__c,
                              Account.iGA_Passport_Number__pc,Account.PersonEmail,Account.CIF__pc,pr_ResidencyPermitPhotoRequired__c, 
                              Account.Due_Diligence_Category__pc,pr_Overdue_Stage_Date__c from Case where Id IN : setCaseId];
        List<Account> accListToUpdate = new List<Account>();
        List<Case> caseListToUpdate = new List<Case>();
        List<eKYC_iGA_Response__c> eKYCListToUpdate = new List<eKYC_iGA_Response__c>();
        if(lstCase.size()>0){
            for(Case objCase : lstCase){
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                String IdNumber = objCase.cc_ID_Number__c;
                String IdNumberPdf = IdNumber + '.pdf';
                String IdVHash = objCase.IDandV_Document_Upload_Hash__c;
                System.debug('Id Number Pfd:'+IdNumberPdf);
                System.debug('ID V Hash:'+IdVHash);
                /*request = con.createRequest('POST', '/api/v1/government-data/wathiq/person/consent-and-data?', objCase.Region_Flag__c);
String body = '{"consentMode":"iDandV","idAndVDocumentDetails":[{"documentName":"'+IdNumberPdf+'","documentHash":"'+IdVHash+'"}],"crmSync":true,"promoteGovernmentDataToCustomerProfile":false,"mockURL":null}';
request.setBody(body); 
request.setHeader('userId', objCase.Account.PersonEmail);
request.setHeader('customerId', objCase.Account.CIF__pc);
system.debug('---> request1 --> '+request.getBody());
HttpResponse response = http.send(request);*/
                HttpResponse response = new HttpResponse();
                
                //Dummy Positive response
                String body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"09/03/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"09/03/2023","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                
                //Dummy Response with Missing Residency Expiry Date
                //String body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                
                //Dummy Response with Missing Residency Expiry Date & Resident Number
                //String body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                
                //Dummy Response with Missing Passport Expiry Date & Passport Number
                //String body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';

                //Dummy Response with Missing Gender & Date of Birth
                //String body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';

                //Dummy Response with Expiry Date < Today
                //String body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2021","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"BHR","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"BHR","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                
                //Dummy Response with Missing Passport Expiry Date
                //String body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                
                //Dummy Response with Passport Expiry Date < Today
                //String body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2021","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"BHR","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"BHR","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                
                
                
                response.setStatus('OK');
                response.setStatusCode(200);
                response.setBody(body);
                response.setHeader('Content-Type', 'application/json');
                if(response.getStatusCode() != 200){
                    System.debug('Invalid Status Code from API');
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/government-data/wathiq/person/consent-and-data?language=en&unit=neo','POST',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Periodic Review', 'Periodic Review');
                    
                }
                else{
                    System.debug('Getting Success Response from API:'+response.getBody());
                    Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                    Map<String, Object> mapJSONData = (Map<String, Object>)mapJSONResponse.get('data');
                    Map<String, Object> mapJSONIGAData = (Map<String, Object>)mapJSONData.get('igaData');
                    Map<String, Object> mapJSONemploymentInfo = (Map<String, Object>)mapJSONIGAData.get('employmentInfo');
                    Map<String, Object> mapJSONcustomerAddress = (Map<String, Object>)mapJSONIGAData.get('customerAddress');
                    Map<String, object> mapJSONemployerAddress = (Map<String, Object>)mapJSONemploymentInfo.get('employerAddress');
                    
                    String nationality = (string)mapJSONIGAData.get('nationality');
                    String passportNumber = (string)mapJSONIGAData.get('passportNumber');
                    String passportExpiryDate =  (string)mapJSONIGAData.get('passportExpiryDate');
                    String residentNumber = (string)mapJSONIGAData.get('residentPermitNo');
                    System.debug('Resident Number from API:'+residentNumber);
                    String residentExpiryDate = (string)mapJSONIGAData.get('residentPermitExpiry');
                    System.debug('Resident Expiry Date from API:'+residentExpiryDate);
                    
                    String cardCountry = (string)mapJSONIGAData.get('cardCountry');
                    String gender = (string)mapJSONIGAData.get('gender');
                    String dataOfBirth = (string)mapJSONIGAData.get('dateOfBirth');
                    Date passportDateExpiry;
                    Date residentDateExpiry;
                    Date dob;
                    if(String.isNotBlank(passportExpiryDate)){
                        passportDateExpiry = Date.parse(passportExpiryDate);
                    }
                    if(String.isNotBlank(residentExpiryDate)){
                        residentDateExpiry = Date.parse(residentExpiryDate);
                    }
                    if(String.isNotBlank(dataOfBirth)){
                        dob = Date.parse(dataOfBirth);
                    }
                    System.debug('Resident Expiry Date After Conversion:'+residentDateExpiry);
                    
                    Integer trackFullName = 0;
                    String fullName = (string)mapJSONIGAData.get('enFirstName');
                    String middleName1 = (string)mapJSONIGAData.get('enMiddleName1');
                    String middleName2 = (string)mapJSONIGAData.get('enMiddleName2');
                    String middleName3 = (string)mapJSONIGAData.get('enMiddleName3');
                    String middleName4 = (string)mapJSONIGAData.get('enMiddleName4');
                    String lastName = (string)mapJSONIGAData.get('enLastName');
                    
                    if(fullName != '' && fullName !=null)
                        trackFullName++;
                    if(middleName1 != '' && middleName1 !=null)
                        trackFullName++;
                    if(middleName2 != '' && middleName2 !=null)
                        trackFullName++;
                    if(middleName3 != '' && middleName3 !=null)
                        trackFullName++;
                    if(middleName4 != '' && middleName4 !=null)
                        trackFullName++;
                    if(lastName != '' && lastName !=null)
                        trackFullName++;
                    System.debug('Tracking Full Name Count:'+trackFullName);
                    
                    if(nationality == 'BH'){
                        System.debug('BAHRAINI CUSTOMER No need to Check for conditions like Passport Expiry & Resident Expiry');
                        Account a = new Account(Id = objCase.AccountId);
                        eKYC_iGA_Response__c eKYCiGA = new eKYC_iGA_Response__c(Account__c = objCase.AccountId,Case__c = objCase.Id);

                        a.iGA_Document_Country__pc = (string)mapJSONIGAData.get('cardCountry');
                        a.ID_Nationality__pc = (string)mapJSONIGAData.get('cardCountry');
                        
                        a.iGA_ID_Number__pc = (string)mapJSONIGAData.get('idNumber');

                        a.iGA_Arabic_First_Name__pc = (string)mapJSONIGAData.get('arFirstName');
                        a.iGA_Arabic_Middle_Name_1__pc = (string)mapJSONIGAData.get('arMiddleName1');
                        a.iGA_Arabic_Middle_Name_2__pc = (string)mapJSONIGAData.get('arMiddleName2');
                        a.iGA_Arabic_Middle_Name_3__pc = (string)mapJSONIGAData.get('arMiddleName3');
                        a.iGA_Arabic_Middle_Name_4__pc = (string)mapJSONIGAData.get('arMiddleName4');
                        a.iGA_Arabic_Last_Name__pc =  (string)mapJSONIGAData.get('arLastName');
                        a.Arabic_Name__pc = (string)mapJSONIGAData.get('arFirstName') +' ' +(string)mapJSONIGAData.get('arMiddleName1') + ' ' +(string)mapJSONIGAData.get('arMiddleName2') + ' ' +(string)mapJSONIGAData.get('arMiddleName4') + ' ' +(string)mapJSONIGAData.get('arLastName');
                        
                        a.iGA_English_First_Name__pc = (string)mapJSONIGAData.get('enFirstName');
                        a.iGA_English_Middle_Name_1__pc = (string)mapJSONIGAData.get('enMiddleName1');
                        a.iGA_English_Middle_Name_2__pc = (string)mapJSONIGAData.get('enMiddleName2');
                        a.iGA_English_Middle_Name_3__pc = (string)mapJSONIGAData.get('enMiddleName3');
                        a.iGA_English_Middle_Name_4__pc = (string)mapJSONIGAData.get('enMiddleName4');
                        a.iGA_English_Last_Name__pc = (string)mapJSONIGAData.get('enLastName');
                        
                        //Account_Info_cannot_be_edited_directly Validation is restricting to update Account name
                        /*a.FirstName = (string)mapJSONIGAData.get('enFirstName');
                          a.MiddleName = (string)mapJSONIGAData.get('enMiddleName1') +' ' +(string)mapJSONIGAData.get('enMiddleName2') +' ' +(string)mapJSONIGAData.get('enMiddleName3') + ' '+(string)mapJSONIGAData.get('enMiddleName4');
                          a.LastName = (string)mapJSONIGAData.get('enLastName');*/
                        
                        a.iGA_Gender__pc = (string)mapJSONIGAData.get('gender');
                        a.Gender__pc = (string)mapJSONIGAData.get('gender');
                        
                        a.iGA_Date_of_Birth__pc = (string)mapJSONIGAData.get('dateOfBirth');
                        a.PersonBirthdate = dob;
                        
                        a.iGA_Mobile_Number__pc = (string)mapJSONIGAData.get('telephoneNumber');
                        a.iGA_Email__pc = (string)mapJSONIGAData.get('email');
                        
                        a.iGA_Mailing_Flat_Number__pc = (string)mapJSONcustomerAddress.get('flatNumber');
                        a.iGA_Mailing_Building_Number__pc = (string)mapJSONcustomerAddress.get('buildingNumber');
                        a.iGA_Mailing_Building_Alpha__pc = (string)mapJSONcustomerAddress.get('buildingAlpha');
                        a.iGA_Mailing_Road_Number__pc = (string)mapJSONcustomerAddress.get('roadNumber');
                        a.iGA_Mailing_Block_Number__pc = (string)mapJSONcustomerAddress.get('blockNumber');
                        
                        a.iGA_Nationality__pc = (string)mapJSONIGAData.get('nationality');
                        a.Nationality__pc = (string)mapJSONIGAData.get('nationality');
                        
                        a.iGA_Occupation__pc = (string)mapJSONemploymentInfo.get('occupation');
                        a.iGA_Employment_Status__pc = (string)mapJSONemploymentInfo.get('employmentStatus');
                        
                        a.iGA_Employer_Name__pc = (string)mapJSONemploymentInfo.get('employerName');
                        a.Employer_Name__pc = (string)mapJSONemploymentInfo.get('employerName');
                        
                        a.iGA_Employer_Flat_Number__pc = (string)mapJSONemployerAddress.get('flatNumber');
                        a.iGA_Employer_Building_Number__pc = (string)mapJSONemployerAddress.get('buildingNumber');
                        a.iGA_Employer_Building_Alpha__pc = (string)mapJSONemployerAddress.get('buildingAlpha');
                        a.iGA_Employer_Road_Number__pc = (string)mapJSONemployerAddress.get('roadNumber');
                        a.iGA_Employer_Block_Number__pc = (string)mapJSONemployerAddress.get('blockNumber');
                        a.Employer_Address__pc = 'Flat ' + (string)mapJSONemployerAddress.get('flatNumber') + ', Bldng '+(string)mapJSONemployerAddress.get('buildingNumber') +' '+(string)mapJSONemployerAddress.get('buildingAlpha') +', Rd no '+(string)mapJSONemployerAddress.get('roadNumber') + ''+(string)mapJSONemployerAddress.get('blockNumber');
                        
                        a.iGA_Marital_Status__pc = (string)mapJSONIGAData.get('maritalStatus');
                        a.Marital_Status__pc = (string)mapJSONIGAData.get('maritalStatus');
                        
                        a.iGA_Passport_Number__pc = (string)mapJSONIGAData.get('passportNumber');
                        a.Passport_Number__pc = (string)mapJSONIGAData.get('passportNumber');
                        
                        a.iGA_Passport_Expiry_Date__pc = (string)mapJSONIGAData.get('passportExpiryDate');
                        a.Passport_Expiry_Date__pc = passportDateExpiry;
                        
                        a.iGA_Residency_Permit_Number__pc = (string)mapJSONIGAData.get('residentPermitNo');
                        a.Residency_Permit_Number__pc = (string)mapJSONIGAData.get('residentPermitNo');
                        
                        a.iGA_Residency_Permit_Expiry__pc = (string)mapJSONIGAData.get('residentPermitExpiry');
                        a.Residency_Permit_Expiry__pc = residentDateExpiry;
                        
                        if(objCase.Account.Due_Diligence_Category__pc == 'Standard Due Diligence'){
                            a.pr_NextReviewDate__c = System.today() + 365;
                        }
                        else if(objCase.Account.Due_Diligence_Category__pc == 'Enhanced Due Diligence'){
                            a.pr_NextReviewDate__c = System.today() + 1095;
                        }
                        
                        a.pr_ReviewStatus__c = 'Completed';
                        System.debug('Account acc:'+a);
                        accListToUpdate.add(a);
                        //objCase.eKYC_iGA_Response__c = response.getBody();
                        Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                        objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                        objCase.Sub_Status__c = 'Completed';
                        objCase.Status = 'Closed';
                        caseListToUpdate.add(objCase);
                        eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                        eKYCListToUpdate.add(eKYCiGA);
                    }
                    else if(nationality != 'BH' && nationality != '' && nationality != null){
                        System.debug('NON BAHRAINI CUSTOMER CHECK PASSPORT & RESIDENT EXPIRY');
                        Account a = new Account(Id = objCase.AccountId);
                        eKYC_iGA_Response__c eKYCiGA = new eKYC_iGA_Response__c(Account__c = objCase.AccountId,Case__c = objCase.Id);
                        if(passportDateExpiry != null && passportNumber != '' && passportNumber != null && residentDateExpiry != null && residentNumber != '' && residentNumber != null && trackFullName > 1){
                            
                            //////////////////////////////// Fetching the Latest Wathiq data from API //////////////////////////////
                            //system.today().addDays(45)
                            if(passportDateExpiry >= System.today().addDays(45) && residentDateExpiry >= System.today().addDays(45) && gender != '' &&  gender != null  && dataOfBirth != '' && dataOfBirth != null){
                                System.debug('Passport & Resident Permit Not Expire');
                                
                                //Mapping of IGA Fields on eKYC Section & Main Field
                                a.iGA_Document_Country__pc = (string)mapJSONIGAData.get('cardCountry');
                                a.ID_Nationality__pc = (string)mapJSONIGAData.get('cardCountry');
                                
                                a.iGA_ID_Number__pc = (string)mapJSONIGAData.get('idNumber');
                                
                                a.iGA_Arabic_First_Name__pc = (string)mapJSONIGAData.get('arFirstName');
                                a.iGA_Arabic_Middle_Name_1__pc = (string)mapJSONIGAData.get('arMiddleName1');
                                a.iGA_Arabic_Middle_Name_2__pc = (string)mapJSONIGAData.get('arMiddleName2');
                                a.iGA_Arabic_Middle_Name_3__pc = (string)mapJSONIGAData.get('arMiddleName3');
                                a.iGA_Arabic_Middle_Name_4__pc = (string)mapJSONIGAData.get('arMiddleName4');
                                a.iGA_Arabic_Last_Name__pc =  (string)mapJSONIGAData.get('arLastName');
                                a.Arabic_Name__pc = (string)mapJSONIGAData.get('arFirstName') +' ' +(string)mapJSONIGAData.get('arMiddleName1') + ' ' +(string)mapJSONIGAData.get('arMiddleName2') + ' ' +(string)mapJSONIGAData.get('arMiddleName4') + ' ' +(string)mapJSONIGAData.get('arLastName');
                                
                                a.iGA_English_First_Name__pc = (string)mapJSONIGAData.get('enFirstName');
                                a.iGA_English_Middle_Name_1__pc = (string)mapJSONIGAData.get('enMiddleName1');
                                a.iGA_English_Middle_Name_2__pc = (string)mapJSONIGAData.get('enMiddleName2');
                                a.iGA_English_Middle_Name_3__pc = (string)mapJSONIGAData.get('enMiddleName3');
                                a.iGA_English_Middle_Name_4__pc = (string)mapJSONIGAData.get('enMiddleName4');
                                a.iGA_English_Last_Name__pc = (string)mapJSONIGAData.get('enLastName');
                                
                                //Account_Info_cannot_be_edited_directly Validation is restricting to update Account name
                                /*a.FirstName = (string)mapJSONIGAData.get('enFirstName');
                                  a.MiddleName = (string)mapJSONIGAData.get('enMiddleName1') +' ' +(string)mapJSONIGAData.get('enMiddleName2') +' ' +(string)mapJSONIGAData.get('enMiddleName3') + ' '+(string)mapJSONIGAData.get('enMiddleName4');
                                  a.LastName = (string)mapJSONIGAData.get('enLastName');*/
                                
                                a.iGA_Gender__pc = (string)mapJSONIGAData.get('gender');
                                a.Gender__pc = (string)mapJSONIGAData.get('gender');
                                
                                a.iGA_Date_of_Birth__pc = (string)mapJSONIGAData.get('dateOfBirth');
                                a.PersonBirthdate = dob;
                                
                                a.iGA_Mobile_Number__pc = (string)mapJSONIGAData.get('telephoneNumber');
                                a.iGA_Email__pc = (string)mapJSONIGAData.get('email');
                                
                                a.iGA_Mailing_Flat_Number__pc = (string)mapJSONcustomerAddress.get('flatNumber');
                                a.iGA_Mailing_Building_Number__pc = (string)mapJSONcustomerAddress.get('buildingNumber');
                                a.iGA_Mailing_Building_Alpha__pc = (string)mapJSONcustomerAddress.get('buildingAlpha');
                                a.iGA_Mailing_Road_Number__pc = (string)mapJSONcustomerAddress.get('roadNumber');
                                a.iGA_Mailing_Block_Number__pc = (string)mapJSONcustomerAddress.get('blockNumber');
                                
                                a.iGA_Nationality__pc = (string)mapJSONIGAData.get('nationality');
                                a.Nationality__pc = (string)mapJSONIGAData.get('nationality');
                                
                                a.iGA_Occupation__pc = (string)mapJSONemploymentInfo.get('occupation');
                                a.iGA_Employment_Status__pc = (string)mapJSONemploymentInfo.get('employmentStatus');
                                
                                a.iGA_Employer_Name__pc = (string)mapJSONemploymentInfo.get('employerName');
                                a.Employer_Name__pc = (string)mapJSONemploymentInfo.get('employerName');
                                
                                a.iGA_Employer_Flat_Number__pc = (string)mapJSONemployerAddress.get('flatNumber');
                                a.iGA_Employer_Building_Number__pc = (string)mapJSONemployerAddress.get('buildingNumber');
                                a.iGA_Employer_Building_Alpha__pc = (string)mapJSONemployerAddress.get('buildingAlpha');
                                a.iGA_Employer_Road_Number__pc = (string)mapJSONemployerAddress.get('roadNumber');
                                a.iGA_Employer_Block_Number__pc = (string)mapJSONemployerAddress.get('blockNumber');
                                //a.Employer_Address__pc = (string)mapJSONemployerAddress.get('flatNumber') + ' '+(string)mapJSONemployerAddress.get('buildingNumber') +' '+(string)mapJSONemployerAddress.get('buildingAlpha') +' '+(string)mapJSONemployerAddress.get('roadNumber') + ''+(string)mapJSONemployerAddress.get('blockNumber');
                                a.Employer_Address__pc = 'Flat ' + (string)mapJSONemployerAddress.get('flatNumber') + ', Bldng '+(string)mapJSONemployerAddress.get('buildingNumber') +' '+(string)mapJSONemployerAddress.get('buildingAlpha') +', Rd no '+(string)mapJSONemployerAddress.get('roadNumber') + ''+(string)mapJSONemployerAddress.get('blockNumber');

                                System.debug('Employer Full Address:'+ a.Employer_Address__pc);
                                
                                a.iGA_Marital_Status__pc = (string)mapJSONIGAData.get('maritalStatus');
                                a.Marital_Status__pc = (string)mapJSONIGAData.get('maritalStatus');
                                
                                a.iGA_Passport_Number__pc = (string)mapJSONIGAData.get('passportNumber');
                                a.Passport_Number__pc = (string)mapJSONIGAData.get('passportNumber');
                                
                                a.iGA_Passport_Expiry_Date__pc = (string)mapJSONIGAData.get('passportExpiryDate');
                                a.Passport_Expiry_Date__pc = passportDateExpiry;
                                
                                a.iGA_Residency_Permit_Number__pc = (string)mapJSONIGAData.get('residentPermitNo');
                                a.Residency_Permit_Number__pc = (string)mapJSONIGAData.get('residentPermitNo');
                                
                                a.iGA_Residency_Permit_Expiry__pc = (string)mapJSONIGAData.get('residentPermitExpiry');
                                a.Residency_Permit_Expiry__pc = residentDateExpiry;
                                
                                if(objCase.Account.Due_Diligence_Category__pc == 'Standard Due Diligence'){
                                    a.pr_NextReviewDate__c = System.today() + 365;
                                }
                                else if(objCase.Account.Due_Diligence_Category__pc == 'Enhanced Due Diligence'){
                                    a.pr_NextReviewDate__c = System.today() + 1095;
                                }
                                
                                a.pr_ReviewStatus__c = 'Completed';
                                System.debug('Account acc:'+a);
                                accListToUpdate.add(a);
                                Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                //objCase.eKYC_iGA_Response__c = response.getBody();
                                objCase.Sub_Status__c = 'Completed';
                                objCase.Status = 'Closed';
                                caseListToUpdate.add(objCase);
                                eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                eKYCListToUpdate.add(eKYCiGA);
                            }
                            //////////////////////////////// Fetching the Latest Wathiq data from API //////////////////////////////
                            
                            ///////////////////////////////// Checking Gender, DateofBirth missing in API Response ///////////////////////////////////////
                            if(passportDateExpiry >= System.today().addDays(45) && residentDateExpiry >= System.today().addDays(45) && (gender == '' || gender == null || dataOfBirth == '' || dataOfBirth == null)){
                                System.debug('Other Documents are required');
                                a.Id = objCase.AccountId;
                                a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                accListToUpdate.add(a);
                                objCase.pr_OtherDocumentsRequired__c = true;
                                objCase.Status = 'Pending Documents';
                                objCase.Sub_Status__c = 'Overdue Stage 1';
                                objCase.pr_Overdue_Stage_Date__c =System.now();
                               // objCase.eKYC_iGA_Response__c = response.getBody();
                                Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                caseListToUpdate.add(objCase);
                                eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                eKYCListToUpdate.add(eKYCiGA);
                            }
                            ///////////////////////////////// Checking Gender, DateofBirth missing in API Response ///////////////////////////////////////
                            
                            ////////////////////////////////// Checking Resident Expiry Date < Today ///////////////////////////////////////////////
                            if(passportDateExpiry >= System.today().addDays(45) && residentDateExpiry <= System.today().addDays(45) && gender != '' && gender != null && dataOfBirth != '' && dataOfBirth != null){
                                System.debug('Resident Permit Expire is less then today');
                                a.Id = objCase.AccountId;
                                a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                accListToUpdate.add(a);
                                objCase.pr_ResidencyPermitPhotoRequired__c = true;
                                objCase.Status = 'Pending Documents';
                                objCase.Sub_Status__c = 'Overdue Stage 1';
                                objCase.pr_Overdue_Stage_Date__c =System.now();
                                //objCase.eKYC_iGA_Response__c = response.getBody();
                                 Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                caseListToUpdate.add(objCase);
                                eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                eKYCListToUpdate.add(eKYCiGA);
                            }
                            ////////////////////////////////// Checking Resident Expiry Date < Today ///////////////////////////////////////////////
                            
                            ///////////////////////////////// Checking Resident Expiry Date < Today & Gender, DateofBirth missing in API Response///////////////////////////////////////////////////////////////////////////    
                            if(passportDateExpiry >= System.today().addDays(45) && residentDateExpiry <= System.today().addDays(45) && (gender == '' || gender == null || dataOfBirth == '' || dataOfBirth == null)){
                                System.debug('Resident Permit Expire');
                                System.debug('Other Documents are required');
                                a.Id = objCase.AccountId;
                                a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                accListToUpdate.add(a);
                                objCase.pr_ResidencyPermitPhotoRequired__c = true;
                                objCase.pr_OtherDocumentsRequired__c = true;
                                objCase.Status = 'Pending Documents';
                                objCase.Sub_Status__c = 'Overdue Stage 1';
                                objCase.pr_Overdue_Stage_Date__c =System.now();
                                //objCase.eKYC_iGA_Response__c = response.getBody();
                                 Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                caseListToUpdate.add(objCase);
                                eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                eKYCListToUpdate.add(eKYCiGA);
                            }
                            ///////////////////////////////// Checking Resident Expiry Date < Today & CardCountry, Gender, DateofBirth missing in API Response///////////////////////////////////////////////////////////////////////////    
                            
                            ////////////////////////////////// Checking passport Expiry Date < Today ///////////////////////////////////////////////
                            if(passportDateExpiry <= System.today().addDays(45) && residentDateExpiry >= System.today().addDays(45) && gender != '' && gender != null && dataOfBirth != '' && dataOfBirth != null){
                                System.debug('Passport Expire date is less then today');
                                a.Id = objCase.AccountId;
                                a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                accListToUpdate.add(a);
                                objCase.pr_PassportPhotoRequired__c = true;
                                objCase.Status = 'Pending Documents';
                                objCase.Sub_Status__c = 'Overdue Stage 1';
                                objCase.pr_Overdue_Stage_Date__c =System.now();
                                //objCase.eKYC_iGA_Response__c = response.getBody();
                                 Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                 objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                caseListToUpdate.add(objCase);
                                eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                eKYCListToUpdate.add(eKYCiGA);
                            }
                            ////////////////////////////////// Checking passport Expiry Date < Today ///////////////////////////////////////////////
                            
                            ///////////////////////////////// Checking passport Expiry Date < Today & Gender, DateofBirth missing in API Response///////////////////////////////////////////////////////////////////////////    
                            if(passportDateExpiry <= System.today().addDays(45) && residentDateExpiry >= System.today().addDays(45) && (gender == '' || gender == null || dataOfBirth == '' || dataOfBirth == null)){
                                System.debug('Passport Expires');
                                System.debug('Other Documents are required');
                                a.Id = objCase.AccountId;
                                a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                accListToUpdate.add(a);
                                objCase.pr_PassportPhotoRequired__c = true;
                                objCase.pr_OtherDocumentsRequired__c = true;
                                objCase.Status = 'Pending Documents';
                                objCase.Sub_Status__c = 'Overdue Stage 1';
                                objCase.pr_Overdue_Stage_Date__c =System.now();
                                //objCase.eKYC_iGA_Response__c = response.getBody();
                                 Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                caseListToUpdate.add(objCase);
                                eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                eKYCListToUpdate.add(eKYCiGA);
                            }
                            ///////////////////////////////// Checking passport Expiry Date < Today & CardCountry, Gender, DateofBirth missing in API Response///////////////////////////////////////////////////////////////////////////    
                            
                            ///////////////////////////////// Checking passport Expiry & Ressident Expiry < Today ////////////////////////////////////////////     
                            if(passportDateExpiry <= System.today().addDays(45) && residentDateExpiry <= System.today().addDays(45) && gender != '' && gender != null && dataOfBirth != '' && dataOfBirth != null){
                                System.debug('Passport & Resident Permit Expire');
                                a.Id = objCase.AccountId;
                                a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                accListToUpdate.add(a);
                                objCase.pr_PassportPhotoRequired__c = true;
                                objCase.pr_ResidencyPermitPhotoRequired__c = true;
                                objCase.Status = 'Pending Documents';
                                objCase.Sub_Status__c = 'Overdue Stage 1';
                                objCase.pr_Overdue_Stage_Date__c =System.now();
                                //objCase.eKYC_iGA_Response__c = response.getBody();
                                 Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                 objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                caseListToUpdate.add(objCase);
                                eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                eKYCListToUpdate.add(eKYCiGA);
                            }
                            ///////////////////////////////// Checking passport Expiry & Resident Expiry < Today ////////////////////////////////////////////     
                            
                        }
                        
                        //////////////////////////////////// Checking Full Name Tracking ///////////////////////////////////////////////////
                        else if(passportDateExpiry != null && passportNumber != '' && passportNumber != null && residentDateExpiry != null && residentNumber != '' && residentNumber != null && trackFullName <= 1){
                            a.Id = objCase.AccountId;
                            a.pr_ReviewStatus__c = 'Overdue Stage 1';
                            accListToUpdate.add(a);
                            objCase.pr_OtherDocumentsRequired__c = true;
                            objCase.Status = 'Pending Documents';
                            objCase.Sub_Status__c = 'Overdue Stage 1';
                            objCase.pr_Overdue_Stage_Date__c =System.now();
                            //objCase.eKYC_iGA_Response__c = response.getBody();
                             Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                             objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                            caseListToUpdate.add(objCase);
                            eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                            eKYCListToUpdate.add(eKYCiGA);
                        }
                        //////////////////////////////////// Checking Full Name Tracking ///////////////////////////////////////////////////
                        
                        /////////////////////// Checking Passport Expiry or Passport Number Missing in API Response //////////////////////////////
                        else if((passportDateExpiry == null || passportNumber == '' || passportNumber == null) &&
                                (residentDateExpiry != null && residentNumber != '' && residentNumber != null) && trackFullName > 1){
                                    System.debug('Passport Expiry Date is Blank from API OR Parameter Missing');
                                    a.Id = objCase.AccountId;
                                    a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                    accListToUpdate.add(a);
                                    objCase.pr_PassportPhotoRequired__c = true;
                                    objCase.Status = 'Pending Documents';
                                    objCase.Sub_Status__c = 'Overdue Stage 1';
                                    objCase.pr_Overdue_Stage_Date__c =System.now();
                                    Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                    objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    caseListToUpdate.add(objCase);
                                    eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    eKYCListToUpdate.add(eKYCiGA);
                                }
                        ///////////////////// Checking Passport Expiry or Passport Number Missing in API Response //////////////////////////////
                        
                        ///////////////////// Checking Resident Expiry or Resident Number Missing in API Response /////////////////////////////
                        else if((residentDateExpiry == null || residentNumber == '' || residentNumber == null) &&
                                (passportDateExpiry != null && passportNumber != '' && passportNumber != null ) && trackFullName > 1){
                                    System.debug('Resident Expiry Date is Blank from API OR Parameter Missing');
                                    a.Id = objCase.AccountId;
                                    a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                    accListToUpdate.add(a);
                                    objCase.pr_ResidencyPermitPhotoRequired__c = true;
                                    objCase.Status = 'Pending Documents';
                                    objCase.Sub_Status__c = 'Overdue Stage 1';
                                    objCase.pr_Overdue_Stage_Date__c =System.now();
                                    //Map<String,Object> jsonMap= response.getBody();
                                    Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                    objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    caseListToUpdate.add(objCase);
                                    eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    eKYCListToUpdate.add(eKYCiGA);
                                }
                        ///////////////////// Checking Resident Expiry or Resident Number Missing in API Response/////////////////////////////
                        
                        ////////////////////// Checking Passport Expiry or Passport Number and Resident Number or Resident Expiry is Missing in API in Response ////////////////////////////////////////////////////
                        else if((residentDateExpiry == null || residentNumber == '' || residentNumber == null) &&
                                (passportDateExpiry == null || passportNumber == '' || passportNumber == null ) && trackFullName > 1){
                                    System.debug('Any One Resident Expiry Date, Passport Expiry Date, Resident Number & Passport Number is Blank from API OR Parameter Missing');
                                    a.Id = objCase.AccountId;
                                    a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                    accListToUpdate.add(a);
                                    objCase.pr_ResidencyPermitPhotoRequired__c = true;
                                    objCase.pr_PassportPhotoRequired__c = true;
                                    objCase.Status = 'Pending Documents';
                                    objCase.Sub_Status__c = 'Overdue Stage 1';
                                    objCase.pr_Overdue_Stage_Date__c =System.now();
                                     Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                    objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    caseListToUpdate.add(objCase);
                                    eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    eKYCListToUpdate.add(eKYCiGA);
                                }
                        ////////////////////// Checking Passport Expiry or Passport Number and Resident Number or Resident Expiry is Missing in API in Response ////////////////////////////////////////////////////
                        
                    }
                    ///////////////////////// Checking if Nationality or cardCountry is Missing or null in API Response /////////////////////////////////////////////
                    else if(nationality == null || nationality == '' || cardCountry == null || cardCountry == ''){
                        Account a = new Account(Id = objCase.AccountId);
                        eKYC_iGA_Response__c eKYCiGA = new eKYC_iGA_Response__c(Account__c = objCase.AccountId,Case__c = objCase.Id);
                        a.Id = objCase.AccountId;
                        a.pr_ReviewStatus__c = 'Overdue Stage 1';
                        accListToUpdate.add(a);
                        objCase.pr_PassportPhotoRequired__c = true;
                        objCase.Status = 'Pending Documents';
                        objCase.Sub_Status__c = 'Overdue Stage 1';
                        objCase.pr_Overdue_Stage_Date__c =System.now();
                         Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                        objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                        caseListToUpdate.add(objCase);
                         eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                        eKYCListToUpdate.add(eKYCiGA);
                    }
                    ///////////////////////// Checking if Nationality or cardCountry is Missing or null in API Response /////////////////////////////////////////////
                    
                }
            } //for loop End
        } //if loop End
        try{
            if(accListToUpdate.size()>0){
                update accListToUpdate;
            }
            if(caseListToUpdate.size()>0){
                update caseListToUpdate;
            }
            if(eKYCListToUpdate.size()>0){
                insert eKYCListToUpdate;
            }
        }catch(Exception e){
            System.debug('Exception Message in Periodic Handler API:'+e.getMessage());
        }
        if(lstSA.size()>0){
            insert lstSA;
        }
    } //Future Methods Ends
    
     @future(callout=true)
    public static void fetcheKYCDocumentHashValue(Set<Id> setCaseId){
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Account> accToUpdate = new List<Account>();
        List<Case> caseToUpdate = new List<Case>();
        List<Case> lstCase = [Select Id,Status,Sub_Status__c,AccountId,Customer_CIF__c,Region_Flag__c,Account.PersonEmail,Account.CIF__pc,Account.eKYC_IDandV_Document_Upload_Hash__pc
                              from Case where Id IN : setCaseId];
        if(lstCase.size()>0){
            for(Case objCase : lstCase){
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                //request = con.createRequest('POST', '/api/v1/government-data/wathiq/person/document?', objCase.Region_Flag__c);
                //String body = '{"s3Path":"","mockURL":null}';
                String body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
                HttpResponse response = new HttpResponse();
                response.setStatus('OK');
                response.setStatusCode(200);
                response.setBody(body);
                response.setHeader('Content-Type', 'application/json');
                //request.setBody(body); 
                //request.setHeader('userId', objCase.Account.PersonEmail);
                //request.setHeader('customerId', objCase.Account.CIF__pc);
                //system.debug('---> request body --> '+request.getBody());
                //HttpResponse response = http.send(request);
                if(response.getStatusCode() != 200){
                    System.debug('Invalid Status Code from API');
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/government-data/wathiq/person/document?language=en&unit=neo','POST',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Periodic Review', 'Periodic Review');
                }
                else{
                    System.debug('Response Body:'+response.getBody());
                    Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                    Map<String, Object> mapJSONData = (Map<String, Object>)mapJSONResponse.get('data');
                    String docHashValue = (String)mapJSONData.get('documentHash');
                    System.debug('Doc Hash Value:'+docHashValue);
                    Account a = new Account();
                    a.Id = objCase.AccountId;
                    a.pr_ReviewStatus__c = 'In-Progress';
                    a.eKYC_IDandV_Document_Upload_Hash__pc = docHashValue;
                    accToUpdate.add(a);
                    objCase.Sub_Status__c = 'In-Progress';
                    objCase.Status = 'In Progress';
                    //objCase.Account.eKYC_IDandV_Document_Upload_Hash__pc = docHashValue;
                    caseToUpdate.add(objCase);
                }
            }
        }
        try{
            if(caseToUpdate.size()>0){
                update caseToUpdate;
            }
            if(accToUpdate.size()>0){
                update accToUpdate;
            }
        }catch(Exception e){
            System.debug('Exception Message in Periodic Handler API:'+e.getMessage());
        }    
         if(lstSA.size()>0){
            insert lstSA;
        }
    }
    
} //Class End