/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date: 27-11-2022
* 		Change History: 
*				CH01: Added by #Jahangeer Mohammed# #08-03-2023# Suspend Overdue Stages(CRM23-183)
*				CH02: Added by #Jahangeer Mohammed# #10-09-2023# Exclude Residency Permit for GCC Countries(NBA-8829)
*			    CH03: Added by #Jahangeer Mohammed# #16-09-2024# Exclude Customer Name & DOB field to update on Customer Profile(NBA-12057)

*	     
*/
public class FetcheKYCIGADataQueuableAPI implements Queueable, Database.AllowsCallouts {
    private static ApiConnection con = new ApiConnection();
    public static String fakeBody;
    set<Id> caseId;
    public FetcheKYCIGADataQueuableAPI(set<Id> setCaseIdsSet){
        this.caseId = setCaseIdsSet;
    }
    public void execute(QueueableContext context){
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> lstCase = [Select Id,AccountId,Customer_CIF__c,cc_ID_Number__c,IDandV_Document_Upload_Hash__c,Region_Flag__c,Sub_Status__c,
                              Account.iGA_Passport_Number__pc,Account.PersonEmail,Account.CIF__pc,pr_ResidencyPermitPhotoRequired__c, Account.pr_ReviewStatus__c,
                              Account.Due_Diligence_Category__pc,pr_Overdue_Stage_Date__c,Account.ID_Nationality__pc from Case where Id IN : caseId];
        List<Account> accListToUpdate = new List<Account>();
        List<Case> caseListToUpdate = new List<Case>();
        List<eKYC_iGA_Response__c> eKYCListToUpdate = new List<eKYC_iGA_Response__c>();
        if(lstCase.size()>0){
            Set<String> setofErrorCaseId = new Set<String>();
            try{
                for(Case objCase : lstCase){
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    HttpResponse response;
                    String body = '';
                    if(System.Label.PERIODIC_REVIEW_ISACTUAL_RESPONSE.equalsIgnoreCase('true')){
                        String IdNumber = objCase.cc_ID_Number__c;
                        String IdNumberPdf = IdNumber + '.pdf';
                        String IdVHash = objCase.IDandV_Document_Upload_Hash__c;
                        System.debug('Id Number Pfd:'+IdNumberPdf);
                        System.debug('ID V Hash:'+IdVHash);
                        request = con.createRequest('POST', '/api/v1/government-data/wathiq/person/consent-and-data?', objCase.Region_Flag__c);
                        body = '{"consentMode":"IDandV","idAndVDocumentDetails":[{"documentName":"'+IdNumberPdf+'","documentHash":"'+IdVHash+'"}],"crmSync":true,"promoteGovernmentDataToCustomerProfile":false,"mockURL":null}';
                        //body = '{"consentMode":"IDandV","idAndVDocumentDetails":[{"documentName":"'+IdNumberPdf+'","documentHash":"'+IdVHash+'"}],"crmSync":true,"promoteGovernmentDataToCustomerProfile":false,"mockURL":"https://run.mocky.io/v3/4899b0df-c7d5-43b1-a4b1-fe9bcbb44d71"}';
						//body = '{"consentMode":"IDandV","idAndVDocumentDetails":[{"documentName":"'+IdNumberPdf+'","documentHash":"'+IdVHash+'"}],"crmSync":true,"promoteGovernmentDataToCustomerProfile":false,"mockURL":"https://run.mocky.io/v3/48079ce4-3835-48b3-9921-bc7c2519dbaa"}';
                        //body = '{"consentMode":"IDandV","idAndVDocumentDetails":[{"documentName":"'+IdNumberPdf+'","documentHash":"'+IdVHash+'"}],"crmSync":true,"promoteGovernmentDataToCustomerProfile":false,"mockURL":"https://run.mocky.io/v3/7880b56d-ef83-44b4-ac4d-4e91ed717157"}';
                        //body = '{"consentMode":"IDandV","idAndVDocumentDetails":[{"documentName":"'+IdNumberPdf+'","documentHash":"'+IdVHash+'"}],"crmSync":true,"promoteGovernmentDataToCustomerProfile":false,"mockURL":"https://run.mocky.io/v3/b98cbc77-fb6e-499f-bdee-f53a969f7d1a"}';
                        //body = '{"consentMode":"IDandV","idAndVDocumentDetails":[{"documentName":"'+IdNumberPdf+'","documentHash":"'+IdVHash+'"}],"crmSync":true,"promoteGovernmentDataToCustomerProfile":false,"mockURL":"https://run.mocky.io/v3/fc630048-602f-46f5-bb5a-801059fc2402"}';

                        request.setBody(body); 
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        request.setTimeout(70000);
                        system.debug('---> request1 --> '+request.getBody());
                        response = http.send(request);

                    } //If Ends for Actual Response
                    if(System.Label.PERIODIC_REVIEW_ISDUMMY_RESPONSE.equalsIgnoreCase('true')){
                        response = new HttpResponse();
                         //Dummy Positive response
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"USA","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                     
                        //Dummy response with First Name, Middle Name Empty and Nationality = BH
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Afzal","enMiddleName1":"","enMiddleName2":"","enMiddleName3":"","enMiddleName4":"","enLastName":"Mullah","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"BH","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                    
                        //Dummy response with Middle Name Empty with Nationality = Non-Bahraini
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Afzal","enMiddleName1":"","enMiddleName2":"","enMiddleName3":"","enMiddleName4":"","enLastName":"Mullah","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                    
                        //Dummy response with Gender Empty and Nationality = BH
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Afzal","enMiddleName1":"","enMiddleName2":"","enMiddleName3":"","enMiddleName4":"","enLastName":"Mullah","gender":"","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"Bh","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                    
                        //Dummy response with DOB Empty and Nationality = Non-Bahraini
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Afzal","enMiddleName1":"","enMiddleName2":"","enMiddleName3":"","enMiddleName4":"","enLastName":"Mullah","gender":"M","dateOfBirth":"","telephoneNumber":"36000000","email":"a@a.com","nationality":"USA","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                     
                        //Dummy response with Passport Number Empty and Nationality = BH
                       // body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Afzal","enMiddleName1":"","enMiddleName2":"","enMiddleName3":"","enMiddleName4":"","enLastName":"Mullah","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"BH","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                    
						 //Dummy response with Passport Expiry date Empty and Nationality = Non Bahraini
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"","passportNumber":"L980876","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Afzal","enMiddleName1":"","enMiddleName2":"","enMiddleName3":"","enMiddleName4":"","enLastName":"Mullah","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                    
                         //Dummy response with Resident Number Empty and Nationality = BH
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"","passportExpiryDate":"30/01/2024","passportNumber":"L897665","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Afzal","enMiddleName1":"","enMiddleName2":"","enMiddleName3":"","enMiddleName4":"","enLastName":"Mullah","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"BH","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                      
                        //Dummy response with Resident Expiry Date Empty and Nationality = USA
                       // body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"","residentPermitNo":"s3433421edd","passportExpiryDate":"30/06/2024","passportNumber":"L897665","idNumber":"777772828","cardCountry":"USA","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Afzal","enMiddleName1":"Ali","enMiddleName2":"","enMiddleName3":"","enMiddleName4":"","enLastName":"Mullah","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"periodictest@gmail.com","nationality":"USA","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                      
                        
                        //Dummy response with Middle Name Empty
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Afzal","enMiddleName1":"","enMiddleName2":"","enMiddleName3":"","enMiddleName4":"","enLastName":"Mullah","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"BH","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                    
                         //Dummy response with Middle Name Empty, Resident Expiry and Resident Permit Number Empty
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"","residentPermitNo":"","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Afzal","enMiddleName1":"","enMiddleName2":"","enMiddleName3":"","enMiddleName4":"","enLastName":"Mullah","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"BH","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                     
                        //Dummy response with Middle Name Empty, Passport Number and Passport Expiry Empty 
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"","passportNumber":"","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Afzal","enMiddleName1":"","enMiddleName2":"","enMiddleName3":"","enMiddleName4":"","enLastName":"Mullah","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"BH","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                    
                         
                        //Dummy response with Name & Middle Name Empty
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"","enMiddleName1":"","enMiddleName2":"","enMiddleName3":"","enMiddleName4":"","enLastName":"Mullah","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"BH","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                    
                        
                        //Dummy response with Gender empty & DOB Empty
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';

                        
                        //Dummy Positive response With Passport Number Empty
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                    
                        //Dummy Positive response With Passport Number Empty, Resident Number Empty and DOB Empty
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"01/03/2023","residentPermitNo":"","passportExpiryDate":"01/03/2023","passportNumber":"","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"","telephoneNumber":"36000000","email":"a@a.com","nationality":"USA","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                    
                        
                        //Dummy Positive response with Missing First Name
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';

                        //Dummy Positive response with Missing Middle Name and Last name
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"","enMiddleName2":"","enMiddleName3":"","enMiddleName4":"","enLastName":"","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                    
                         //Dummy Positive response with Gender as Empty
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';

                    
                        //Dummy Positive response with Resident Expiry Date as 22/10/2022
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"22/10/2022","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';

                        //Dummy Positive response with Passport Expiry Date as 30/09/2022
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"22/10/2026","residentPermitNo":"s3433421edd","passportExpiryDate":"30/09/2022","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"USA","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
  
                        
                        
                        //Dummy Positive response with Resident Expiry Date as 18/02/2023 & Resident Expiry Date as 18/02/2023
                         //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"18/02/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"18/02/2023","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';

                          //Dummy Positive response with DOB, Passport Number and Resident Permit Number Empty
                         //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"18/02/2023","residentPermitNo":"","passportExpiryDate":"18/02/2023","passportNumber":"","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';

                          //Dummy Positive response with DOB,Gender as empty and Passport Number and Resident Permit Number within 45 days range
                         //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"18/02/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"18/02/2023","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';

                        
                        //Dummy Positive response with Residency Permit Number & Passport Number empty
                         //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"","passportExpiryDate":"30/01/2024","passportNumber":"","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                    
                    
                        //Dummy Response with Missing Residency Expiry Date
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                    
                        //Dummy Response with Missing Residency Expiry Date & Resident Number
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                    
                        //Dummy Response with Missing Passport Expiry Date & Passport Number
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                    
                        //Dummy Response with Missing Gender & Date of Birth
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                    
                        //Dummy Response with Expiry Date < Today
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2021","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"BHR","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"BHR","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                    
                        //Dummy Response with Missing Passport Expiry Date
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                    
                        //Dummy Response with Passport Expiry Date is going to expire in 45 Days
                        //body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"04/02/2023","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}';
                    
                    	if(test.isRunningTest()){
                	    	body = fakeBody;
            		    }
                        response.setStatus('OK');
                        response.setStatusCode(200);
                        response.setBody(body);
                        response.setHeader('Content-Type', 'application/json');
                    } //If Ends for Dummy Response
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
                        System.debug('Passpory Expiry Date from API:'+passportExpiryDate);
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
                        System.debug('Passpory Expiry Date After Conversion:'+passportDateExpiry);
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
                        String cardCountryISO = '';
                        //CH02: Start
                        List<String> rpExclusionList = System.Label.RP_EXCLUSION_LIST.split(',');
                        if(rpExclusionList.contains(nationality) && nationality != '' && nationality != null){
                            System.debug('BAHRAINI CUSTOMER No need to Check Gender, DOB and Name');
                             Account a = new Account(Id = objCase.AccountId);
                             eKYC_iGA_Response__c eKYCiGA = new eKYC_iGA_Response__c(Account__c = objCase.AccountId,Case__c = objCase.Id);
                             if(trackFullName > 1 && gender != '' &&  gender != null  && dataOfBirth != '' && dataOfBirth != null){
                                
                                 if(String.isNotBlank((string)mapJSONIGAData.get('cardCountry2Digits'))){
									cardCountryISO = (string)mapJSONIGAData.get('cardCountry2Digits');
									if(objCase.Account.ID_Nationality__pc != cardCountryISO){
										a.ID_Nationality__pc = cardCountryISO;
									}
                                 }
                                
                                String arabFName = '';
                                String arabMName1 = '';
                                String arabMName2 = '';
                                String arabMName3 = '';
                                String arabMName4 = '';
                                String arabLName = '';
                                 
                                if(String.isNotBlank((string)mapJSONIGAData.get('arFirstName'))){
                                    arabFName =  (string)mapJSONIGAData.get('arFirstName');
                                }
                                if(String.isNotBlank((string)mapJSONIGAData.get('arMiddleName1'))){
                                    arabMName1 =  (string)mapJSONIGAData.get('arMiddleName1');
                                }
                                if(String.isNotBlank((string)mapJSONIGAData.get('arMiddleName2'))){
                                    arabMName2 =  (string)mapJSONIGAData.get('arMiddleName2');
                                }
                                if(String.isNotBlank((string)mapJSONIGAData.get('arMiddleName3'))){
                                    arabMName3 =  (string)mapJSONIGAData.get('arMiddleName3');
                                }
                                if(String.isNotBlank((string)mapJSONIGAData.get('arMiddleName4'))){
                                    arabMName4 =  (string)mapJSONIGAData.get('arMiddleName4');
                                }
                                if(String.isNotBlank((string)mapJSONIGAData.get('arLastName'))){
                                    arabLName =  (string)mapJSONIGAData.get('arLastName');
                                } 
                                
                                a.Arabic_Name__pc = arabFName + ' '+arabMName1 + ' '+arabMName2 + ' '+arabMName3 + ' '+arabMName4 + ' '+arabLName;
                                
                                //if(String.isNotBlank((string)mapJSONIGAData.get('arFirstName')) || String.isNotBlank((string)mapJSONIGAData.get('arMiddleName1')) || String.isNotBlank((string)mapJSONIGAData.get('arMiddleName2')) || String.isNotBlank((string)mapJSONIGAData.get('arMiddleName3')) || String.isNotBlank((string)mapJSONIGAData.get('arMiddleName4')) || String.isNotBlank((string)mapJSONIGAData.get('arLastName')) )
                                	//a.Arabic_Name__pc = (string)mapJSONIGAData.get('arFirstName') +' ' +(string)mapJSONIGAData.get('arMiddleName1') + ' ' +(string)mapJSONIGAData.get('arMiddleName2') + ' ' +(string)mapJSONIGAData.get('arMiddleName3') + ' ' +(string)mapJSONIGAData.get('arMiddleName4') + ' ' +(string)mapJSONIGAData.get('arLastName');
                                
                                //CH03: Start
                                //Account_Info_cannot_be_edited_directly Validation is restricting to update Account name
                                /*if(String.isNotBlank((string)mapJSONIGAData.get('enFirstName')))
                                	a.FirstName = (string)mapJSONIGAData.get('enFirstName');
                                
                                String midName1 = '';
                                String midName2 = '';
                                String midName3 = '';
                                String midName4 = '';
                                 
                                 if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName1'))){
                                     midName1 = (string)mapJSONIGAData.get('enMiddleName1');
                                 }
                                 if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName2'))){
                                     midName2 = (string)mapJSONIGAData.get('enMiddleName2');
                                 }
                                 if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName3'))){
                                     midName3 = (string)mapJSONIGAData.get('enMiddleName3');
                                 }
                                 if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName4'))){
                                     midName4 = (string)mapJSONIGAData.get('enMiddleName4');
                                 }
                                a.MiddleName = midName1 + ' ' +midName2 + ' '+midName3 + ' '+midName4; */
                                //CH03: END
                                //if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName1')) || String.isNotBlank((string)mapJSONIGAData.get('enMiddleName2')) || String.isNotBlank((string)mapJSONIGAData.get('enMiddleName3')) || String.isNotBlank((string)mapJSONIGAData.get('enMiddleName4')))
                                	//a.MiddleName = (string)mapJSONIGAData.get('enMiddleName1') +' ' +(string)mapJSONIGAData.get('enMiddleName2') +' ' +(string)mapJSONIGAData.get('enMiddleName3') + ' '+(string)mapJSONIGAData.get('enMiddleName4');
                                //CH03: Start
                                /*if(String.isNotBlank((string)mapJSONIGAData.get('enLastName')))
                                	a.LastName = (string)mapJSONIGAData.get('enLastName');*/
                                //CH03: END
                                if(String.isNotBlank((string)mapJSONIGAData.get('gender')))
                                	a.Gender__pc = (string)mapJSONIGAData.get('gender');
                               //CH03: Start
                                //a.PersonBirthdate = dob;
                               //CH03: END 
                                //if(String.isNotBlank((string)mapJSONIGAData.get('nationality')))
                                 	//a.Nationality__pc = (string)mapJSONIGAData.get('nationality');
                                 
                                if(String.isNotBlank((string)mapJSONIGAData.get('customerNationalityTwoChars')))
                                 	a.Nationality__pc = (string)mapJSONIGAData.get('customerNationalityTwoChars');
                                
                                if(String.isNotBlank((string)mapJSONemploymentInfo.get('employerName')))
                                	a.Employer_Name__pc = (string)mapJSONemploymentInfo.get('employerName');
                                if(String.isNotBlank((string)mapJSONemployerAddress.get('flatNumber')) || String.isNotBlank((string)mapJSONemployerAddress.get('buildingNumber')) || String.isNotBlank((string)mapJSONemployerAddress.get('buildingAlpha')) || String.isNotBlank((string)mapJSONemployerAddress.get('roadNumber')) || String.isNotBlank((string)mapJSONemployerAddress.get('blockNumber')))
									a.Employer_Address__pc = 'Flat ' + (string)mapJSONemployerAddress.get('flatNumber') + ', Bldng '+(string)mapJSONemployerAddress.get('buildingNumber') +' '+(string)mapJSONemployerAddress.get('buildingAlpha') +', Rd no '+(string)mapJSONemployerAddress.get('roadNumber') + ''+(string)mapJSONemployerAddress.get('blockNumber');
                                
                                if(String.isNotBlank((string)mapJSONIGAData.get('maritalStatus')))
                                	a.Marital_Status__pc = (string)mapJSONIGAData.get('maritalStatus');
                                if(String.isNotBlank((string)mapJSONIGAData.get('passportNumber')))
                                	a.Passport_Number__pc = (string)mapJSONIGAData.get('passportNumber');
                                if(String.isNotBlank((string)mapJSONIGAData.get('passportExpiryDate')))
                                	a.Passport_Expiry_Date__pc = passportDateExpiry;
                                if(String.isNotBlank((string)mapJSONIGAData.get('residentPermitNo')))
                                	a.Residency_Permit_Number__pc = (string)mapJSONIGAData.get('residentPermitNo');
                                if(String.isNotBlank((string)mapJSONIGAData.get('residentPermitExpiry')))
                                	a.Residency_Permit_Expiry__pc = residentDateExpiry;
                                
                                if(objCase.Account.Due_Diligence_Category__pc == 'Standard Due Diligence'){
                                    a.pr_NextReviewDate__c = System.today() + 1095;
                                }
                                else if(objCase.Account.Due_Diligence_Category__pc == 'Enhanced Due Diligence'){
                                    a.pr_NextReviewDate__c = System.today() + 365;
                                }
                                a.Bypass_Validations__pc = true;
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
                            else if(trackFullName <= 1 || gender != '' ||  gender != null  || dataOfBirth != '' || dataOfBirth != null){
                                 System.debug('Other Documents are required');
                                    if(objCase.Account.pr_ReviewStatus__c == '' || objCase.Account.pr_ReviewStatus__c == null || objCase.Account.pr_ReviewStatus__c == 'Completed' || objCase.Account.pr_ReviewStatus__c == 'In-Progress'){
                                        a.Id = objCase.AccountId;
                                        //a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                        //CH01: Start
                						if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     						a.pr_ReviewStatus__c = 'Overdue Stage 1';
										}
                						else
                							a.pr_ReviewStatus__c = 'Overdue';
                						//CH01: END
                                        accListToUpdate.add(a);
                                    }
                                    objCase.pr_OtherDocumentsRequired__c = true;
                                    objCase.Status = 'Pending Documents';
                                    if(objCase.Sub_Status__c == '' || objCase.Sub_Status__c == null || objCase.Sub_Status__c == 'In-Progress'){
                                        //objCase.Sub_Status__c = 'Overdue Stage 1';
                                        //CH01: Start
                        				if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            				objCase.Sub_Status__c = 'Overdue Stage 1';
                         				}
                         				else
                            				objCase.Sub_Status__c = 'Overdue';
                        				//CH01: END
                                        objCase.pr_Overdue_Stage_Date__c =System.now();
                                    }
                                    // objCase.eKYC_iGA_Response__c = response.getBody();
                                    Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                    objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    caseListToUpdate.add(objCase);
                                    eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    eKYCListToUpdate.add(eKYCiGA);
                            }
                        }
                        //CH02: END
                        //CH02: Start
                        else if(!rpExclusionList.contains(nationality) && nationality != '' && nationality != null){
                            System.debug('NON BAHRAINI CUSTOMER CHECK PASSPORT & RESIDENT EXPIRY');
                            System.debug('45 Days Range from Current Date:'+System.today().addDays(45));
                            Account a = new Account(Id = objCase.AccountId);
                            eKYC_iGA_Response__c eKYCiGA = new eKYC_iGA_Response__c(Account__c = objCase.AccountId,Case__c = objCase.Id);
                            if(passportDateExpiry != null && passportNumber != '' && passportNumber != null && residentDateExpiry != null && residentNumber != '' && residentNumber != null && trackFullName > 1){
                                
                                //////////////////////////////// Fetching the Latest Wathiq data from API //////////////////////////////
                                if(passportDateExpiry > System.today().addDays(45) && residentDateExpiry > System.today().addDays(45) && gender != '' &&  gender != null  && dataOfBirth != '' && dataOfBirth != null){
                                    System.debug('Passport & Resident Permit Not Expire');
                                    
                                    //Mapping of IGA Fields on eKYC Section & Main Field
                                   
                                    if(String.isNotBlank((string)mapJSONIGAData.get('cardCountry2Digits'))){
										cardCountryISO = (string)mapJSONIGAData.get('cardCountry2Digits');
										if(objCase.Account.ID_Nationality__pc != cardCountryISO){
											a.ID_Nationality__pc = cardCountryISO;
										}
                                	}
                                   
                                    String arabFName = '';
                                	String arabMName1 = '';
                                	String arabMName2 = '';
                                	String arabMName3 = '';
                                	String arabMName4 = '';
                                	String arabLName = '';
                                 
                                	if(String.isNotBlank((string)mapJSONIGAData.get('arFirstName'))){
                                    	arabFName =  (string)mapJSONIGAData.get('arFirstName');
                                	}
                                	if(String.isNotBlank((string)mapJSONIGAData.get('arMiddleName1'))){
                                    	arabMName1 =  (string)mapJSONIGAData.get('arMiddleName1');
                                	}
                                	if(String.isNotBlank((string)mapJSONIGAData.get('arMiddleName2'))){
                                    	arabMName2 =  (string)mapJSONIGAData.get('arMiddleName2');
                                	}
                                	if(String.isNotBlank((string)mapJSONIGAData.get('arMiddleName3'))){
                                    	arabMName3 =  (string)mapJSONIGAData.get('arMiddleName3');
                                	}
                                	if(String.isNotBlank((string)mapJSONIGAData.get('arMiddleName4'))){
                                    	arabMName4 =  (string)mapJSONIGAData.get('arMiddleName4');
                                	}
                                	if(String.isNotBlank((string)mapJSONIGAData.get('arLastName'))){
                                    	arabLName =  (string)mapJSONIGAData.get('arLastName');
                                	} 
                                
                                	a.Arabic_Name__pc = arabFName + ' '+arabMName1 + ' '+arabMName2 + ' '+arabMName3 + ' '+arabMName4 + ' '+arabLName;
                                    
                                    //if(String.isNotBlank((string)mapJSONIGAData.get('arFirstName')) || String.isNotBlank((string)mapJSONIGAData.get('arMiddleName1')) || String.isNotBlank((string)mapJSONIGAData.get('arMiddleName2')) || String.isNotBlank((string)mapJSONIGAData.get('arMiddleName3')) || String.isNotBlank((string)mapJSONIGAData.get('arMiddleName4')) || String.isNotBlank((string)mapJSONIGAData.get('arLastName')) )
                                        //a.Arabic_Name__pc = (string)mapJSONIGAData.get('arFirstName') +' ' +(string)mapJSONIGAData.get('arMiddleName1') + ' ' +(string)mapJSONIGAData.get('arMiddleName2') + ' ' +(string)mapJSONIGAData.get('arMiddleName3') + ' ' +(string)mapJSONIGAData.get('arMiddleName4') + ' ' +(string)mapJSONIGAData.get('arLastName');
                                    
                                    //CH03: Start
                                    //Account_Info_cannot_be_edited_directly Validation is restricting to update Account name
                                    /*if(String.isNotBlank((string)mapJSONIGAData.get('enFirstName')))
                                        a.FirstName = (string)mapJSONIGAData.get('enFirstName');
                                     
                                    String midName1 = '';
                                	String midName2 = '';
                                	String midName3 = '';
                                	String midName4 = '';
                                 
                                 	if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName1'))){
                                    	 midName1 = (string)mapJSONIGAData.get('enMiddleName1');
                                 	}
                                 	if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName2'))){
                                     	midName2 = (string)mapJSONIGAData.get('enMiddleName2');
                                 	}
                                 	if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName3'))){
                                     	midName3 = (string)mapJSONIGAData.get('enMiddleName3');
                                 	}
                                 	if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName4'))){
                                     	midName4 = (string)mapJSONIGAData.get('enMiddleName4');
                                 	}
                                	a.MiddleName = midName1 + ' ' +midName2 + ' '+midName3 + ' '+midName4;*/
                                    //CH03: END
                                    //if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName1')) || String.isNotBlank((string)mapJSONIGAData.get('enMiddleName2')) || String.isNotBlank((string)mapJSONIGAData.get('enMiddleName3')) || String.isNotBlank((string)mapJSONIGAData.get('enMiddleName4')))
                                        //a.MiddleName = (string)mapJSONIGAData.get('enMiddleName1') +' ' +(string)mapJSONIGAData.get('enMiddleName2') +' ' +(string)mapJSONIGAData.get('enMiddleName3') + ' '+(string)mapJSONIGAData.get('enMiddleName4');
                                    //CH03: Start
                                    /*if(String.isNotBlank((string)mapJSONIGAData.get('enLastName')))
                                        a.LastName = (string)mapJSONIGAData.get('enLastName');*/
                                    //CH03: END
                                    if(String.isNotBlank((string)mapJSONIGAData.get('gender')))
                                        a.Gender__pc = (string)mapJSONIGAData.get('gender');
                                    //CH03: Start
                                    //a.PersonBirthdate = dob;
                                    //CH03: END
                                    //if(String.isNotBlank((string)mapJSONIGAData.get('nationality')))
                                       // a.Nationality__pc = (string)mapJSONIGAData.get('nationality');
                                    
                                    if(String.isNotBlank((string)mapJSONIGAData.get('customerNationalityTwoChars')))
                                 		a.Nationality__pc = (string)mapJSONIGAData.get('customerNationalityTwoChars');
                                    
                                    if(String.isNotBlank((string)mapJSONemploymentInfo.get('employerName')))
                                        a.Employer_Name__pc = (string)mapJSONemploymentInfo.get('employerName');
                                    if(String.isNotBlank((string)mapJSONemployerAddress.get('flatNumber')) || String.isNotBlank((string)mapJSONemployerAddress.get('buildingNumber')) || String.isNotBlank((string)mapJSONemployerAddress.get('buildingAlpha')) || String.isNotBlank((string)mapJSONemployerAddress.get('roadNumber')) || String.isNotBlank((string)mapJSONemployerAddress.get('blockNumber')))
 										a.Employer_Address__pc = 'Flat ' + (string)mapJSONemployerAddress.get('flatNumber') + ', Bldng '+(string)mapJSONemployerAddress.get('buildingNumber') +' '+(string)mapJSONemployerAddress.get('buildingAlpha') +', Rd no '+(string)mapJSONemployerAddress.get('roadNumber') + ''+(string)mapJSONemployerAddress.get('blockNumber');
                                    
                                    if(String.isNotBlank((string)mapJSONIGAData.get('maritalStatus')))
                                        a.Marital_Status__pc = (string)mapJSONIGAData.get('maritalStatus');
                                    if(String.isNotBlank((string)mapJSONIGAData.get('passportNumber')))
                                    	a.Passport_Number__pc = (string)mapJSONIGAData.get('passportNumber');
                                    if(String.isNotBlank((string)mapJSONIGAData.get('passportExpiryDate')))
                                    	a.Passport_Expiry_Date__pc = passportDateExpiry;
                                    if(String.isNotBlank((string)mapJSONIGAData.get('residentPermitNo')))
                                    	a.Residency_Permit_Number__pc = (string)mapJSONIGAData.get('residentPermitNo');
                                    if(String.isNotBlank((string)mapJSONIGAData.get('residentPermitExpiry')))
                                    	a.Residency_Permit_Expiry__pc = residentDateExpiry;
                                    
                                    if(objCase.Account.Due_Diligence_Category__pc == 'Standard Due Diligence'){
                                        a.pr_NextReviewDate__c = System.today() + 1095;
                                    }
                                    else if(objCase.Account.Due_Diligence_Category__pc == 'Enhanced Due Diligence'){
                                        a.pr_NextReviewDate__c = System.today() + 365;
                                    }
                                    a.Bypass_Validations__pc = true;
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
                                if(passportDateExpiry > System.today().addDays(45) && residentDateExpiry > System.today().addDays(45) && (gender == '' || gender == null || dataOfBirth == '' || dataOfBirth == null)){
                                    System.debug('Other Documents are required');
                                    if(objCase.Account.pr_ReviewStatus__c == '' || objCase.Account.pr_ReviewStatus__c == null || objCase.Account.pr_ReviewStatus__c == 'Completed' || objCase.Account.pr_ReviewStatus__c == 'In-Progress'){
                                        a.Id = objCase.AccountId;
                                        //a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                        //CH01: Start
                						if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     						a.pr_ReviewStatus__c = 'Overdue Stage 1';
										}
                						else
                							a.pr_ReviewStatus__c = 'Overdue';
                						//CH01: END
                                        accListToUpdate.add(a);
                                    }
                                    objCase.pr_OtherDocumentsRequired__c = true;
                                    objCase.Status = 'Pending Documents';
                                    if(objCase.Sub_Status__c == '' || objCase.Sub_Status__c == null || objCase.Sub_Status__c == 'In-Progress'){
                                        //objCase.Sub_Status__c = 'Overdue Stage 1';
                                        //CH01: Start
                        				if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            				objCase.Sub_Status__c = 'Overdue Stage 1';
                         				}
                         				else
                            				objCase.Sub_Status__c = 'Overdue';
                        				//CH01: END
                                        objCase.pr_Overdue_Stage_Date__c =System.now();
                                    }
                                    // objCase.eKYC_iGA_Response__c = response.getBody();
                                    Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                    objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    caseListToUpdate.add(objCase);
                                    eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    eKYCListToUpdate.add(eKYCiGA);
                                }
                                ///////////////////////////////// Checking Gender, DateofBirth missing in API Response ///////////////////////////////////////
                                
                                ////////////////////////////////// Checking Resident Expiry Date < Today ///////////////////////////////////////////////
                                if(passportDateExpiry > System.today().addDays(45) && residentDateExpiry <= System.today().addDays(45) && gender != '' && gender != null && dataOfBirth != '' && dataOfBirth != null){
                                    System.debug('Resident Permit Expire is less then today');
                                    if(objCase.Account.pr_ReviewStatus__c == '' || objCase.Account.pr_ReviewStatus__c == null || objCase.Account.pr_ReviewStatus__c == 'Completed' || objCase.Account.pr_ReviewStatus__c == 'In-Progress'){
                                        a.Id = objCase.AccountId;
                                        //a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                        //CH01: Start
                						if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     						a.pr_ReviewStatus__c = 'Overdue Stage 1';
										}
                						else
                							a.pr_ReviewStatus__c = 'Overdue';
                						//CH01: END
                                        accListToUpdate.add(a);
                                    }
                                    objCase.pr_ResidencyPermitPhotoRequired__c = true;
                                    objCase.Status = 'Pending Documents';
                                    if(objCase.Sub_Status__c == '' || objCase.Sub_Status__c == null || objCase.Sub_Status__c == 'In-Progress'){
                                       //objCase.Sub_Status__c = 'Overdue Stage 1';
                                        //CH01: Start
                        				if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            				objCase.Sub_Status__c = 'Overdue Stage 1';
                         				}
                         				else
                            				objCase.Sub_Status__c = 'Overdue';
                        				//CH01: END
                                       objCase.pr_Overdue_Stage_Date__c =System.now(); 
                                    }
                                    //objCase.eKYC_iGA_Response__c = response.getBody();
                                    Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                    objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    caseListToUpdate.add(objCase);
                                    eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    eKYCListToUpdate.add(eKYCiGA);
                                }
                                ////////////////////////////////// Checking Resident Expiry Date < Today ///////////////////////////////////////////////
                                
                                ///////////////////////////////// Checking Resident Expiry Date < Today & Gender, DateofBirth missing in API Response///////////////////////////////////////////////////////////////////////////    
                                if(passportDateExpiry > System.today().addDays(45) && residentDateExpiry <= System.today().addDays(45) && (gender == '' || gender == null || dataOfBirth == '' || dataOfBirth == null)){
                                    System.debug('Resident Permit Expire');
                                    System.debug('Other Documents are required');
                                    if(objCase.Account.pr_ReviewStatus__c == '' || objCase.Account.pr_ReviewStatus__c == null || objCase.Account.pr_ReviewStatus__c == 'Completed' || objCase.Account.pr_ReviewStatus__c == 'In-Progress'){
                                       a.Id = objCase.AccountId;
                                       //a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                        //CH01: Start
                						if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     						a.pr_ReviewStatus__c = 'Overdue Stage 1';
										}
                						else
                							a.pr_ReviewStatus__c = 'Overdue';
                						//CH01: END
                                       accListToUpdate.add(a);
                                    }
                                    objCase.pr_ResidencyPermitPhotoRequired__c = true;
                                    objCase.pr_OtherDocumentsRequired__c = true;
                                    objCase.Status = 'Pending Documents';
                                    if(objCase.Sub_Status__c == '' || objCase.Sub_Status__c == null || objCase.Sub_Status__c == 'In-Progress'){
                                    	//objCase.Sub_Status__c = 'Overdue Stage 1';
                                    	//CH01: Start
                        				if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            				objCase.Sub_Status__c = 'Overdue Stage 1';
                         				}
                         				else
                            				objCase.Sub_Status__c = 'Overdue';
                        				//CH01: END
                                    	objCase.pr_Overdue_Stage_Date__c =System.now();
                                    }
                                    //objCase.eKYC_iGA_Response__c = response.getBody();
                                    Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                    objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    caseListToUpdate.add(objCase);
                                    eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    eKYCListToUpdate.add(eKYCiGA);
                                }
                                ///////////////////////////////// Checking Resident Expiry Date < Today & CardCountry, Gender, DateofBirth missing in API Response///////////////////////////////////////////////////////////////////////////    
                                
                                ////////////////////////////////// Checking passport Expiry Date < Today ///////////////////////////////////////////////
                                if(passportDateExpiry <= System.today().addDays(45) && residentDateExpiry > System.today().addDays(45) && gender != '' && gender != null && dataOfBirth != '' && dataOfBirth != null){
                                    System.debug('Passport Expire date is less then today');
                                    if(objCase.Account.pr_ReviewStatus__c == '' || objCase.Account.pr_ReviewStatus__c == null || objCase.Account.pr_ReviewStatus__c == 'Completed' || objCase.Account.pr_ReviewStatus__c == 'In-Progress'){
                                       a.Id = objCase.AccountId;
                                      // a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                      //CH01: Start
                					  if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     						a.pr_ReviewStatus__c = 'Overdue Stage 1';
									  }
                					  else
                							a.pr_ReviewStatus__c = 'Overdue';
                					 //CH01: END
                                       accListToUpdate.add(a);
                                    }
                                    objCase.pr_PassportPhotoRequired__c = true;
                                    objCase.Status = 'Pending Documents';
                                    if(objCase.Sub_Status__c == '' || objCase.Sub_Status__c == null || objCase.Sub_Status__c == 'In-Progress'){
                                    	//objCase.Sub_Status__c = 'Overdue Stage 1';
                                    	//CH01: Start
                        				if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            				objCase.Sub_Status__c = 'Overdue Stage 1';
                         				}
                         				else
                            				objCase.Sub_Status__c = 'Overdue';
                        				//CH01: END
                                    	objCase.pr_Overdue_Stage_Date__c =System.now();
                                    }
                                    //objCase.eKYC_iGA_Response__c = response.getBody();
                                    Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                    objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    caseListToUpdate.add(objCase);
                                    eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    eKYCListToUpdate.add(eKYCiGA);
                                }
                                ////////////////////////////////// Checking passport Expiry Date < Today ///////////////////////////////////////////////
                                
                                ///////////////////////////////// Checking passport Expiry Date < Today & Gender, DateofBirth missing in API Response///////////////////////////////////////////////////////////////////////////    
                                if(passportDateExpiry <= System.today().addDays(45) && residentDateExpiry > System.today().addDays(45) && (gender == '' || gender == null || dataOfBirth == '' || dataOfBirth == null)){
                                    System.debug('Passport Expires');
                                    System.debug('Other Documents are required');
									if(objCase.Account.pr_ReviewStatus__c == '' || objCase.Account.pr_ReviewStatus__c == null || objCase.Account.pr_ReviewStatus__c == 'Completed' || objCase.Account.pr_ReviewStatus__c == 'In-Progress'){
                                       a.Id = objCase.AccountId;
                                       //a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                       //CH01: Start
                					   if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     						a.pr_ReviewStatus__c = 'Overdue Stage 1';
									   }
                					   else
                							a.pr_ReviewStatus__c = 'Overdue';
                					 //CH01: END
                                       accListToUpdate.add(a);
                                    }                                    
                                    objCase.pr_PassportPhotoRequired__c = true;
                                    objCase.pr_OtherDocumentsRequired__c = true;
                                    objCase.Status = 'Pending Documents';
                                    if(objCase.Sub_Status__c == '' || objCase.Sub_Status__c == null || objCase.Sub_Status__c == 'In-Progress'){
                                    	//objCase.Sub_Status__c = 'Overdue Stage 1';
                                    	//CH01: Start
                        				if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            				objCase.Sub_Status__c = 'Overdue Stage 1';
                         				}
                         				else
                            				objCase.Sub_Status__c = 'Overdue';
                        				//CH01: END
                                    	objCase.pr_Overdue_Stage_Date__c =System.now();
                                    }
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
                                    if(objCase.Account.pr_ReviewStatus__c == '' || objCase.Account.pr_ReviewStatus__c == null || objCase.Account.pr_ReviewStatus__c == 'Completed' || objCase.Account.pr_ReviewStatus__c == 'In-Progress'){
                                       a.Id = objCase.AccountId;
                                       //a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                       //CH01: Start
                					   if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     						a.pr_ReviewStatus__c = 'Overdue Stage 1';
									   }
                					   else
                							a.pr_ReviewStatus__c = 'Overdue';
                					 //CH01: END
                                       accListToUpdate.add(a);
                                    }
                                    objCase.pr_PassportPhotoRequired__c = true;
                                    objCase.pr_ResidencyPermitPhotoRequired__c = true;
                                    objCase.Status = 'Pending Documents';
                                    if(objCase.Sub_Status__c == '' || objCase.Sub_Status__c == null || objCase.Sub_Status__c == 'In-Progress'){
                                    	//objCase.Sub_Status__c = 'Overdue Stage 1';
                                    	//CH01: Start
                        				if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            				objCase.Sub_Status__c = 'Overdue Stage 1';
                         				}
                         				else
                            				objCase.Sub_Status__c = 'Overdue';
                        				//CH01: END
                                    	objCase.pr_Overdue_Stage_Date__c =System.now();
                                    }
                                    //objCase.eKYC_iGA_Response__c = response.getBody();
                                    Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                    objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    caseListToUpdate.add(objCase);
                                    eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    eKYCListToUpdate.add(eKYCiGA);
                                }
                                ///////////////////////////////// Checking passport Expiry & Resident Expiry < Today ////////////////////////////////////////////     
                                
                            	///////////////////////////////////// Checking Passport Expiry,Resident Expiry within 45 days range DOB and Gender are empty /////////////////////////////////
                                 if(passportDateExpiry <= System.today().addDays(45) && residentDateExpiry <= System.today().addDays(45) && (gender == '' || gender == null || dataOfBirth == '' || dataOfBirth == null)){
                                    System.debug('Passport & Resident Permit Expire Within 45 days range and DOB or Gender is empty');
                                    if(objCase.Account.pr_ReviewStatus__c == '' || objCase.Account.pr_ReviewStatus__c == null || objCase.Account.pr_ReviewStatus__c == 'Completed' || objCase.Account.pr_ReviewStatus__c == 'In-Progress'){
                                       a.Id = objCase.AccountId;
                                       //a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                       //CH01: Start
                					   if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     						a.pr_ReviewStatus__c = 'Overdue Stage 1';
									   }
                					   else
                							a.pr_ReviewStatus__c = 'Overdue';
                					  //CH01: END
                                       accListToUpdate.add(a);
                                    }
                                    objCase.pr_PassportPhotoRequired__c = true;
                                    objCase.pr_ResidencyPermitPhotoRequired__c = true;
                                    objCase.pr_OtherDocumentsRequired__c = true;
                                    objCase.Status = 'Pending Documents';
                                    if(objCase.Sub_Status__c == '' || objCase.Sub_Status__c == null || objCase.Sub_Status__c == 'In-Progress'){
                                    	//objCase.Sub_Status__c = 'Overdue Stage 1';
                                    	//CH01: Start
                        				if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            				objCase.Sub_Status__c = 'Overdue Stage 1';
                         				}
                         				else
                            				objCase.Sub_Status__c = 'Overdue';
                        				//CH01: END
                                    	objCase.pr_Overdue_Stage_Date__c =System.now();
                                    }
                                    //objCase.eKYC_iGA_Response__c = response.getBody();
                                    Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                    objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    caseListToUpdate.add(objCase);
                                    eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                    eKYCListToUpdate.add(eKYCiGA);
                                }
                                
                               ///////////////////////////////////// Checking Passport Expiry,Resident Expiry within 45 days range DOB and Gender are empty /////////////////////////////////

                            }
                            
                            //////////////////////////////////// Checking Full Name Tracking ///////////////////////////////////////////////////
                            else if(passportDateExpiry > System.today().addDays(45) && residentDateExpiry > System.today().addDays(45) && passportDateExpiry != null && passportNumber != '' && passportNumber != null && residentDateExpiry != null && residentNumber != '' && residentNumber != null && trackFullName <= 1){
                                if(objCase.Account.pr_ReviewStatus__c == '' || objCase.Account.pr_ReviewStatus__c == null || objCase.Account.pr_ReviewStatus__c == 'Completed' || objCase.Account.pr_ReviewStatus__c == 'In-Progress'){
                                    a.Id = objCase.AccountId;
                                    //a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                    //CH01: Start
                					if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     					a.pr_ReviewStatus__c = 'Overdue Stage 1';
									}
                					else
                						a.pr_ReviewStatus__c = 'Overdue';
                					//CH01: END
                                    accListToUpdate.add(a);
                                }
                                objCase.pr_OtherDocumentsRequired__c = true;
                                objCase.Status = 'Pending Documents';
                                if(objCase.Sub_Status__c == '' || objCase.Sub_Status__c == null || objCase.Sub_Status__c == 'In-Progress'){
                                	//objCase.Sub_Status__c = 'Overdue Stage 1';
                                	//CH01: Start
                        			if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            			objCase.Sub_Status__c = 'Overdue Stage 1';
                         			 }
                         			 else
                            			objCase.Sub_Status__c = 'Overdue';
                        			//CH01: END
                                	objCase.pr_Overdue_Stage_Date__c =System.now();
                                }
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
                                    (residentDateExpiry != null && residentNumber != '' && residentNumber != null) && (trackFullName > 1 && gender != '' && gender != null && dataOfBirth != '' && dataOfBirth != null)){
                                        System.debug('Passport Expiry Date is Blank from API OR Parameter Missing');
                                        if(objCase.Account.pr_ReviewStatus__c == '' || objCase.Account.pr_ReviewStatus__c == null || objCase.Account.pr_ReviewStatus__c == 'Completed' || objCase.Account.pr_ReviewStatus__c == 'In-Progress'){
                                            a.Id = objCase.AccountId;
                                        	//a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                        	//CH01: Start
                							if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     							a.pr_ReviewStatus__c = 'Overdue Stage 1';
											}
                							else
                								a.pr_ReviewStatus__c = 'Overdue';
                							//CH01: END
                                        	accListToUpdate.add(a);
                                        }
                                        objCase.pr_PassportPhotoRequired__c = true;
                                        objCase.Status = 'Pending Documents';
                                        if(objCase.Sub_Status__c == '' || objCase.Sub_Status__c == null || objCase.Sub_Status__c == 'In-Progress'){
                                        	//objCase.Sub_Status__c = 'Overdue Stage 1';
                                        	//CH01: Start
                        					if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            					objCase.Sub_Status__c = 'Overdue Stage 1';
                         			 		}
                         			 		else
                            					objCase.Sub_Status__c = 'Overdue';
                        					//CH01: END
                                        	objCase.pr_Overdue_Stage_Date__c =System.now();
                                        }
                                        Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                        objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                        caseListToUpdate.add(objCase);
                                        eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                        eKYCListToUpdate.add(eKYCiGA);
                                    }
                            ///////////////////// Checking Passport Expiry or Passport Number Missing in API Response //////////////////////////////
                            
                            ///////////////////// Checking Resident Expiry or Resident Number Missing in API Response /////////////////////////////
                            else if((residentDateExpiry == null || residentNumber == '' || residentNumber == null) &&
                                    (passportDateExpiry != null && passportNumber != '' && passportNumber != null ) && (trackFullName > 1 && gender != '' && gender != null && dataOfBirth != '' && dataOfBirth != null)){
                                        System.debug('Resident Expiry Date is Blank from API OR Parameter Missing');
                                        if(objCase.Account.pr_ReviewStatus__c == '' || objCase.Account.pr_ReviewStatus__c == null || objCase.Account.pr_ReviewStatus__c == 'Completed' || objCase.Account.pr_ReviewStatus__c == 'In-Progress'){
                                            a.Id = objCase.AccountId;
                                        	//a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                        	//CH01: Start
                							if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     							a.pr_ReviewStatus__c = 'Overdue Stage 1';
											}
                							else
                								a.pr_ReviewStatus__c = 'Overdue';
                							//CH01: END
                                        	accListToUpdate.add(a);
                                        }
                                        objCase.pr_ResidencyPermitPhotoRequired__c = true;
                                        objCase.Status = 'Pending Documents';
                                        if(objCase.Sub_Status__c == '' || objCase.Sub_Status__c == null || objCase.Sub_Status__c == 'In-Progress'){
                                        	//objCase.Sub_Status__c = 'Overdue Stage 1';
                                        	//CH01: Start
                        					if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            					objCase.Sub_Status__c = 'Overdue Stage 1';
                         			 		}
                         			 		else
                            					objCase.Sub_Status__c = 'Overdue';
                        					//CH01: END
                                        	objCase.pr_Overdue_Stage_Date__c =System.now();
                                        }
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
                                    (passportDateExpiry == null || passportNumber == '' || passportNumber == null) && (trackFullName > 1 && gender != '' && gender != null && dataOfBirth != '' && dataOfBirth != null)){
                                        System.debug('Any One Resident Expiry Date, Passport Expiry Date, Resident Number & Passport Number is Blank from API OR Parameter Missing');
                                        if(objCase.Account.pr_ReviewStatus__c == '' || objCase.Account.pr_ReviewStatus__c == null || objCase.Account.pr_ReviewStatus__c == 'Completed' || objCase.Account.pr_ReviewStatus__c == 'In-Progress'){
                                            a.Id = objCase.AccountId;
                                        	//a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                        	//CH01: Start
                							if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     							a.pr_ReviewStatus__c = 'Overdue Stage 1';
											}
                							else
                								a.pr_ReviewStatus__c = 'Overdue';
                							//CH01: END
                                        	accListToUpdate.add(a);
                                        }
                                        objCase.pr_ResidencyPermitPhotoRequired__c = true;
                                        objCase.pr_PassportPhotoRequired__c = true;
                                        objCase.Status = 'Pending Documents';
                                        if(objCase.Sub_Status__c == '' || objCase.Sub_Status__c == null || objCase.Sub_Status__c == 'In-Progress'){
                                        	//objCase.Sub_Status__c = 'Overdue Stage 1';
                                        	//CH01: Start
                        					if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            					objCase.Sub_Status__c = 'Overdue Stage 1';
                         			 		}
                         			 		else
                            					objCase.Sub_Status__c = 'Overdue';
                        					//CH01: END
                                        	objCase.pr_Overdue_Stage_Date__c =System.now();
                                        }
                                        Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                        objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                        caseListToUpdate.add(objCase);
                                        eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                        eKYCListToUpdate.add(eKYCiGA);
                                    }
                            ////////////////////// Checking Passport Expiry or Passport Number and Resident Number or Resident Expiry is Missing in API in Response ////////////////////////////////////////////////////
                          
                           ////////////////////// Checking Passport Expiry or Passport Number and Resident Number or Resident Expiry and Name or Gender or DataofBirth is Missing in API in Response ///////////////////////////////////////////////////////////
                           else if((residentDateExpiry == null || residentNumber == '' || residentNumber == null) &&
                                    (passportDateExpiry == null || passportNumber == '' || passportNumber == null) && (trackFullName <= 1 || gender == '' || gender == null || dataOfBirth == '' || dataOfBirth == null)){
                                        System.debug('Resident Expiry Date, Passport Expiry Date, Resident Number & Passport Number, Name or Gender or DataofBirth is Blank from API OR Parameter Missing');
                                        if(objCase.Account.pr_ReviewStatus__c == '' || objCase.Account.pr_ReviewStatus__c == null || objCase.Account.pr_ReviewStatus__c == 'Completed' || objCase.Account.pr_ReviewStatus__c == 'In-Progress'){
                                            a.Id = objCase.AccountId;
                                        	//a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                        	//CH01: Start
                							if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     							a.pr_ReviewStatus__c = 'Overdue Stage 1';
											}
                							else
                								a.pr_ReviewStatus__c = 'Overdue';
                							//CH01: END
                                        	accListToUpdate.add(a);
                                        }
                                        objCase.pr_ResidencyPermitPhotoRequired__c = true;
                                        objCase.pr_PassportPhotoRequired__c = true;
                                        objCase.pr_OtherDocumentsRequired__c = true;
                                        objCase.Status = 'Pending Documents';
                                        System.debug('Sub status value Check:'+ objCase.Sub_Status__c);
                                        if(objCase.Sub_Status__c == '' || objCase.Sub_Status__c == null || objCase.Sub_Status__c == 'In-Progress'){
                                        	//objCase.Sub_Status__c = 'Overdue Stage 1';
                                        	//CH01: Start
                        					if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            					objCase.Sub_Status__c = 'Overdue Stage 1';
                         			 		}
                         			 		else
                            					objCase.Sub_Status__c = 'Overdue';
                        					//CH01: END
                                        	objCase.pr_Overdue_Stage_Date__c =System.now();
                                        }
                                        Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                                        objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                        caseListToUpdate.add(objCase);
                                        eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                                        eKYCListToUpdate.add(eKYCiGA);
                                    }
                            
                            ////////////////////// Checking Passport Expiry or Passport Number and Resident Number or Resident Expiry and Name or Gender or DataofBirth is Missing in API in Response ///////////////////////////////////////////////////////////

                        }
                        //CH02: END
                        ///////////////////////// Checking if Nationality or cardCountry is Missing or null in API Response /////////////////////////////////////////////
                        else if(nationality == null || nationality == '' || cardCountry == null || cardCountry == ''){
                            Account a = new Account(Id = objCase.AccountId);
                            eKYC_iGA_Response__c eKYCiGA = new eKYC_iGA_Response__c(Account__c = objCase.AccountId,Case__c = objCase.Id);
                            if(objCase.Account.pr_ReviewStatus__c == '' || objCase.Account.pr_ReviewStatus__c == null || objCase.Account.pr_ReviewStatus__c == 'Completed' || objCase.Account.pr_ReviewStatus__c == 'In-Progress'){
                            	a.Id = objCase.AccountId;
                                //a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                //CH01: Start
                				if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     				a.pr_ReviewStatus__c = 'Overdue Stage 1';
								 }
                				 else
                					a.pr_ReviewStatus__c = 'Overdue';
                				//CH01: END
                                accListToUpdate.add(a);
                            }
                            objCase.pr_PassportPhotoRequired__c = true;
                            objCase.Status = 'Pending Documents';
                            if(objCase.Sub_Status__c == '' || objCase.Sub_Status__c == null || objCase.Sub_Status__c == 'In-Progress'){
                            	//objCase.Sub_Status__c = 'Overdue Stage 1';
                            	//CH01: Start
                        		if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            		objCase.Sub_Status__c = 'Overdue Stage 1';
                         		 }
                         		 else
                            		objCase.Sub_Status__c = 'Overdue';
                        		//CH01: END
                            	objCase.pr_Overdue_Stage_Date__c =System.now();
                            }
                            Map<String, Object> JSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                            objCase.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                            caseListToUpdate.add(objCase);
                            eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(JSONResponse);
                            eKYCListToUpdate.add(eKYCiGA);
                        }
                        ///////////////////////// Checking if Nationality or cardCountry is Missing or null in API Response /////////////////////////////////////////////
                        
                    }
                } //for loop End
            }catch(Exception ex){
                String compName = 'FetcheKYCIGADataQueuableAPI';
            	String compType = 'Apex Class';
                for(Case c: lstCase){
                  setofErrorCaseId.add(c.Id); 
                }
                String failureRecordReference = String.join(new List<String>(setofErrorCaseId), ',');
            	String ObjectType = 'Case';
            	String errorMessage = ex.getMessage()  + ex.getStackTraceString();
            	PeriodicReviewBatchTrackerLogs.errorCaselog(compName, compType, failureRecordReference,errorMessage,ObjectType);
           }
        } //if loop End
        
        Set<String> setErrCaseIds = new Set<String>();
        Set<String> setofSuccessFullCaseIds = new Set<String>();
        Set<String> setofErrorCaseIds = new Set<String>();
        Set<String> setOfErrormessage = new Set<String>();
		Set<String> setofErrorAccountIds = new Set<String>();
        try{
            if(accListToUpdate.size()>0){
                update accListToUpdate;
            }
        }catch(Exception Ex){
             String compName = 'FetcheKYCIGADataQueuableAPI';
             String compType = 'Apex Class';
             for(Account acc : accListToUpdate){
                setofErrorAccountIds.add(acc.Id);
            }
            String failureRecordReference = String.join(new List<String>(setofErrorAccountIds), ',');
            String ObjectType = 'Account';
            String errorMessage = ex.getMessage()  + ex.getStackTraceString();
            PeriodicReviewBatchTrackerLogs.errorlog(compName,compType,failureRecordReference,errorMessage,ObjectType);
        }
        try{
            if(caseListToUpdate.size()>0){
                Database.SaveResult[] SResult = Database.update(caseListToUpdate,false);
                for(Integer i=0; i<SResult.size(); i++){
                    if(SResult[i].isSuccess()){
                        setofSuccessFullCaseIds.add(caseListToUpdate.get(i).Id);
                    }
                    else if(!SResult[i].isSuccess()){
                        setofErrorCaseIds.add(caseListToUpdate.get(i).Id);
                        for(Database.Error err : SResult[i].getErrors()){
                            setOfErrormessage.add(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
                if(!setofSuccessFullCaseIds.isEmpty()){
                    String compName = 'FetcheKYCIGADataQueuableAPI';
                    String compType = 'Apex Class';
                    String successRecordReference = String.join(new List<String>(setofSuccessFullCaseIds), ',');
                    String ObjectType = 'Case';
                    String caseCategory = 'Fetching iGA & Checking Additional Docs';
                    PeriodicReviewBatchTrackerLogs.successCaselogWithCategory(compName, compType, successRecordReference,ObjectType,caseCategory);
                    
                }
                if(!setofErrorCaseIds.isEmpty()){
                    String compName = 'FetcheKYCIGADataQueuableAPI';
                    String compType = 'Apex Class';
                    String failureRecordReference = String.join(new List<String>(setofErrorCaseIds), ',');
                    String ObjectType = 'Case';
                    String errorMessage = String.join(new List<String>(setOfErrormessage), ',');
                    PeriodicReviewBatchTrackerLogs.errorCaselog(compName, compType, failureRecordReference,errorMessage,ObjectType);
                    
                }
              
            }
         }catch(Exception ex){
            String compName = 'FetcheKYCIGADataQueuableAPI';
            String compType = 'Apex Class';
            for(case c : caseListToUpdate){
                setErrCaseIds.add(c.Id);
            }
            String failureRecordReference = String.join(new List<String>(setErrCaseIds), ',');
            String ObjectType = 'Case';
            String errorMessage = ex.getMessage()  + ex.getStackTraceString();
            PeriodicReviewBatchTrackerLogs.errorCaselog(compName, compType, failureRecordReference,errorMessage,ObjectType);

        }
        if(eKYCListToUpdate.size()>0){
            insert eKYCListToUpdate;
        }
        if(lstSA.size()>0){
            insert lstSA;
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
}