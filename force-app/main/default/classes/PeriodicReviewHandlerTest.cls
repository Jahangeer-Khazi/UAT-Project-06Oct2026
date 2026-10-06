/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date: 22-12-2022
* 		Change History: 
*	   
*/
@isTest
public class PeriodicReviewHandlerTest {
    
    private class MyCalloutMock implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 200;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');    
            res.setHeader('Content-Type', 'application/json');
            //res.setBody
            res.setStatusCode(testStatusCode);
            if (null != testBody) {
                res.setBody(testBody);
            }
            return res;
        }
    }
    private class RestMockPositiveResponse implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2030","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2030","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}');    
            res.setStatusCode(200);
            return res;
        }
    }
    private class RestMockPositiveResponseNonBahrainGenderEmpty implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"BH","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}');    
            res.setStatusCode(200);
            return res;
        }
    }
    private class RestMockIDANDVHashResponse implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}');
            res.setStatusCode(200);
            return res;
        }
    }
     private class RestMockIDANDVHashResponseExcep implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"meta":{"code":"GENE-0001","message":"message"},"dat":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class RestMockWithResidentExpiry implements HttpCalloutMock 
    {
        public Integer testStatusCode = 200;
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}');    
            res.setStatusCode(testStatusCode);
            return res;
        }
    }
    private class RestMockWithResidentExpiryBH implements HttpCalloutMock 
    {
        public Integer testStatusCode = 200;
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"BH","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}');    
            res.setStatusCode(testStatusCode);
            return res;
        }
    }
    private class RestMockWithPassportExpiry implements HttpCalloutMock 
    {
        public Integer testStatusCode = 200;
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2030","residentPermitNo":"s3433421edd","passportExpiryDate":"15/01/2023","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}');    
            res.setStatusCode(testStatusCode);
            return res;
        }
    }
    private class RestMockWithPassportANDResidentExpiry implements HttpCalloutMock 
    {
        public Integer testStatusCode = 200;
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"15/01/2023","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}');    
            res.setStatusCode(testStatusCode);
            return res;
        }
    }
    private class RestMockWithPassportANDResidentExpiryANDGenderEmpty implements HttpCalloutMock 
    {
        public Integer testStatusCode = 200;
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/06/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"15/06/2023","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}');    
            res.setStatusCode(testStatusCode);
            return res;
        }
    }
     private class RestMockWithGenderEmpty implements HttpCalloutMock 
    {
        public Integer testStatusCode = 200;
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"15/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}');    
            res.setStatusCode(testStatusCode);
            return res;
        }
    }
    private class RestMockWithGenderEmptyResidentExpiry implements HttpCalloutMock 
    {
        public Integer testStatusCode = 200;
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"15/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}');    
            res.setStatusCode(testStatusCode);
            return res;
        }
    }
    private class RestMockWithGenderEmptyPassportExpiry implements HttpCalloutMock 
    {
        public Integer testStatusCode = 200;
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"15/01/2023","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}');    
            res.setStatusCode(testStatusCode);
            return res;
        }
    }
    private class RestMockWithFirstName implements HttpCalloutMock 
    {
        public Integer testStatusCode = 200;
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2030","residentPermitNo":"s3433421edd","passportExpiryDate":"15/01/2030","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"","enMiddleName2":"","enMiddleName3":"","enMiddleName4":"","enLastName":"","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}');    
            res.setStatusCode(testStatusCode);
            return res;
        }
    }
    private class RestMockWithPassportNumberEmpty implements HttpCalloutMock 
    {
        public Integer testStatusCode = 200;
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"15/01/2024","passportNumber":"","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdul","enMiddleName3":"Hasan","enMiddleName4":"Khazi","enLastName":"Salim","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}');    
            res.setStatusCode(testStatusCode);
            return res;
        }
    }
    private class RestMockWithResidentNumberEmpty implements HttpCalloutMock 
    {
        public Integer testStatusCode = 200;
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2024","residentPermitNo":"","passportExpiryDate":"15/01/2024","passportNumber":"L908654","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdul","enMiddleName3":"Hasan","enMiddleName4":"Khazi","enLastName":"Salim","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}');    
            res.setStatusCode(testStatusCode);
            return res;
        }
    }
    private class RestMockWithResidentANDPassportNumberEmpty implements HttpCalloutMock 
    {
        public Integer testStatusCode = 200;
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2024","residentPermitNo":"","passportExpiryDate":"15/01/2024","passportNumber":"","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdul","enMiddleName3":"Hasan","enMiddleName4":"Khazi","enLastName":"Salim","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}');    
            res.setStatusCode(testStatusCode);
            return res;
        }
    }
	private class RestMockWithNationalityEmpty implements HttpCalloutMock 
    {
        public Integer testStatusCode = 200;
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2024","residentPermitNo":"54654645","passportExpiryDate":"15/01/2024","passportNumber":"L90876767","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdul","enMiddleName3":"Hasan","enMiddleName4":"Khazi","enLastName":"Salim","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}');    
            res.setStatusCode(testStatusCode);
            return res;
        }
    }
    public static String bodyString(Case objCase){
        String IdNumberPdf = '13245';
        String IdVHash = 'Dummy Test Value';
        String body = '{"consentMode":"iDandV","idAndVDocumentDetails":[{"documentName":"'+IdNumberPdf+'","documentHash":"'+IdVHash+'"}],"crmSync":true,"promoteGovernmentDataToCustomerProfile":false,"mockURL":null}';
        return body;
    }
    public static String bodyStringToFetchIDANDVHashValue(Case objCase){
        String body = '{"s3Path":"","mockURL":null}';
        return body;
    }
    @isTest
    static void unitTest1(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;

        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        insert acc; 
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.AccountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        cs1.Force_Generate_Wathiq_Consent_Form__c = true;
        insert cs1;
    }
    
    @isTest
    static void unitTest2(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        insert acc; 
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        
        Case cs2 = new Case();
        cs2.RecordTypeId = recordTypeId;
        cs2.Subject = 'New Periodic Review';
        cs2.Description = 'Testing for Periodic Review';
        cs2.Type = 'Periodic Review';
        insert cs2;
    }
    
    @isTest
    static void unitTest3(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Hash Value';
        insert acc; 
        Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2030","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2030","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;
		//Setted a Mock Response in this method related to periodic review positive response
        Test.setMock(HttpCalloutMock.class, new RestMockPositiveResponse());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
    }
    @isTest
    static void unitTest4(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = '';
        insert acc; 
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
    }
    @isTest
    static void unitTest5(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = '';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        
        //Need to comment the below line when we get Actual API Response
		FetcheKYCDocumentHashQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyStringToFetchIDANDVHashValue(cs1);
        Test.stopTest();
        FetcheKYCDocumentHashQueuableAPI.createSystemAction(null, null, null, null, cs1.Id, null, cs1.accountId, 0, null, null);
    }
    @isTest
    static void unitTest6(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = '';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Bahraini ID';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cnt.Image_Type__c = 'Face';
        cnt.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt.Similarity__c = 'MATCH';
        insert cnt;
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Bahraini ID';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        insert cntFront;
        
        Content__c cntBack = new Content__c();
        cntBack.Person__c = acc.Id;
        cntBack.Document_Type__c = 'Bahraini ID';
        cntBack.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cntBack.Image_Type__c = 'Back';
        cntBack.Verification_Status__c = 'APPROVED_VERIFIED';
        cntBack.Similarity__c = 'MATCH';
        insert cntBack;
        
        Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
		FetcheKYCDocumentHashQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyStringToFetchIDANDVHashValue(cs1);
        Test.stopTest();
    }
    @isTest
    static void unitTest7(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = '';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Bahraini ID';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cnt.Image_Type__c = 'Face';
        cnt.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt.Similarity__c = 'MATCH';
        insert cnt;
        
        Content__c cnt2FaceRecord = new Content__c();
        cnt2FaceRecord.Person__c = acc.Id;
        cnt2FaceRecord.Document_Type__c = 'Bahraini ID';
        cnt2FaceRecord.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cnt2FaceRecord.Image_Type__c = 'Face';
        cnt2FaceRecord.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt2FaceRecord.Similarity__c = 'MATCH';
        insert cnt2FaceRecord;
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Bahraini ID';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        insert cntFront;
        
        Content__c cntBack = new Content__c();
        cntBack.Person__c = acc.Id;
        cntBack.Document_Type__c = 'Bahraini ID';
        cntBack.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cntBack.Image_Type__c = 'Back';
        cntBack.Verification_Status__c = 'APPROVED_VERIFIED';
        cntBack.Similarity__c = 'MATCH';
        insert cntBack;
        
        Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
         //Need to comment the below line when we get Actual API Response
		FetcheKYCDocumentHashQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyStringToFetchIDANDVHashValue(cs1);
        Test.stopTest();
    }
    @isTest
    static void unitTest8(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = '';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Bahraini ID';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cnt.Image_Type__c = 'Face';
        cnt.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt.Similarity__c = 'MATCH';
        insert cnt;
        
        Content__c cnt2FaceRecord = new Content__c();
        cnt2FaceRecord.Person__c = acc.Id;
        cnt2FaceRecord.Document_Type__c = 'Bahraini ID';
        cnt2FaceRecord.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cnt2FaceRecord.Image_Type__c = 'Face';
        cnt2FaceRecord.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt2FaceRecord.Similarity__c = 'MATCH';
        insert cnt2FaceRecord;
        
        Content__c cnt3FaceRecord = new Content__c();
        cnt3FaceRecord.Person__c = acc.Id;
        cnt3FaceRecord.Document_Type__c = 'Bahraini ID';
        cnt3FaceRecord.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cnt3FaceRecord.Image_Type__c = 'Face';
        cnt3FaceRecord.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt3FaceRecord.Similarity__c = 'MATCH';
        insert cnt3FaceRecord;
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Bahraini ID';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        insert cntFront;
        
        Content__c cntBack = new Content__c();
        cntBack.Person__c = acc.Id;
        cntBack.Document_Type__c = 'Bahraini ID';
        cntBack.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cntBack.Image_Type__c = 'Back';
        cntBack.Verification_Status__c = 'APPROVED_VERIFIED';
        cntBack.Similarity__c = 'MATCH';
        insert cntBack;
        
        Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
         
        //Need to comment the below line when we get Actual API Response
		FetcheKYCDocumentHashQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyStringToFetchIDANDVHashValue(cs1);
        Test.stopTest();
    }
    @isTest
    static void unitTest9(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = '';
        insert acc; 
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Bahraini ID';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cntFront.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        insert cntFront;
        
        Content__c cntBack = new Content__c();
        cntBack.Person__c = acc.Id;
        cntBack.Document_Type__c = 'Bahraini ID';
        cntBack.Document_Expiry_Date__c = System.today() + 60;
        cntBack.Scan_Type__c = 'POI';
        cntBack.Image_Type__c = 'Back';
        cntBack.Verification_Status__c = 'APPROVED_VERIFIED';
        cntBack.Similarity__c = 'MATCH';
        insert cntBack;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
    }
    @isTest
    static void unitTest10(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = '';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Bahraini ID';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cnt.Image_Type__c = 'Face';
        cnt.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt.Similarity__c = 'MATCH';
        insert cnt;
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Bahraini ID';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cntFront.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        insert cntFront;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
    }
    
    @isTest
    static void unitTest11(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = '';
        insert acc; 
        
        Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        cs1.Wathiq_Consent_Form_Available__c = true;
        update cs1;
        //Need to comment the below line when we get Actual API Response
		FetcheKYCDocumentHashQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyStringToFetchIDANDVHashValue(cs1);
        Test.stopTest();
    }
    
    ////////////////////////////////////////////// Start: Residency Expiry Within 45 Days Range ////////////////////////////////////////
    @isTest
    static void unitTest12(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2028","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;

        //Setted a Mock Response in this method related to resident expiry
        Test.setMock(HttpCalloutMock.class, new RestMockWithResidentExpiry());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
        update cs1;
        caseIds.add(cs1.id);
        List<Case> cseList = [Select id,pr_OtherDocumentsRequired__c,pr_ResidencyPermitPhotoRequired__c,eKYC_iGA_Response__c from case where id =: caseIds];
        System.debug('Case List in test class:'+cseList);
        
        cs1.cc_Residence_Permit_No__c = '64746547';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 3650;
        update cs1;
        System.debug('Case After update Resident Permit Photo:'+cs1.pr_ResidencyPermitPhotoRequired__c);

        cs1.Status = 'All Documents Uploaded';
        update cs1;
	}
    ////////////////////////////////////////////// END: Residency Expiry Within 45 Days Range ////////////////////////////////////////

   ////////////////////////////////////////////// Start: Residency Expiry Within 45 Days Range & Contact Agent has put again 45 Days Range ////////////////////////////////////////
	@isTest
    static void unitTest13(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2030","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;
		//Setted a Mock Response in this method related to resident expiry
		Test.setMock(HttpCalloutMock.class, new RestMockWithResidentExpiry());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
        update cs1;
        caseIds.add(cs1.id);
        List<Case> cseList = [Select id,pr_OtherDocumentsRequired__c,pr_ResidencyPermitPhotoRequired__c,eKYC_iGA_Response__c from case where id =: caseIds];
        System.debug('Case List in test class:'+cseList);
        
        cs1.cc_Residence_Permit_No__c = '64746547';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 2000;
        update cs1;
        System.debug('Case After update Resident Permit Photo:'+cs1.pr_ResidencyPermitPhotoRequired__c);

        cs1.Status = 'All Documents Uploaded';
        update cs1;
    }
    @isTest
    static void unitTest13_1(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2030","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"BHR","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;
		//Setted a Mock Response in this method related to resident expiry
		Test.setMock(HttpCalloutMock.class, new RestMockWithResidentExpiry());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
        update cs1;
        caseIds.add(cs1.id);
        List<Case> cseList = [Select id,pr_OtherDocumentsRequired__c,pr_ResidencyPermitPhotoRequired__c,eKYC_iGA_Response__c from case where id =: caseIds];
        System.debug('Case List in test class:'+cseList);
        
        cs1.cc_Residence_Permit_No__c = '64746547';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 2000;
        update cs1;
        System.debug('Case After update Resident Permit Photo:'+cs1.pr_ResidencyPermitPhotoRequired__c);

        cs1.Status = 'All Documents Uploaded';
        update cs1;
    }
    
     @isTest
    static void unitTest13_2(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2030","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"","enMiddleName2":"","enMiddleName3":"","enMiddleName4":"","enLastName":"","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"BHR","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;
		//Setted a Mock Response in this method related to resident expiry
		Test.setMock(HttpCalloutMock.class, new RestMockWithResidentExpiry());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
        update cs1;
        caseIds.add(cs1.id);
        List<Case> cseList = [Select id,pr_OtherDocumentsRequired__c,pr_ResidencyPermitPhotoRequired__c,eKYC_iGA_Response__c from case where id =: caseIds];
        System.debug('Case List in test class:'+cseList);
        
        cs1.cc_Residence_Permit_No__c = '64746547';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 2000;
        update cs1;
        System.debug('Case After update Resident Permit Photo:'+cs1.pr_ResidencyPermitPhotoRequired__c);

        cs1.Status = 'All Documents Uploaded';
        update cs1;
    }
    ////////////////////////////////////////////// END: Residency Expiry Within 45 Days Range & Contact Agent has put again 45 Days Range ////////////////////////////////////////

    
    //////////////////////////////////////////////// Start: Wathiq Accepted from Mobile App Without Docs /////////////////////////////////////////////
    @isTest
    static void unitTest14(){
       Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        insert acc; 
        
        Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        Test.stopTest();
        
        acc.Wathiq_Consent__pc = true;
        update acc;
	}
   //////////////////////////////////////////////// END: Wathiq Accepted from Mobile App Without Docs /////////////////////////////////////////////

   ////////////////////////////////////////////// Start: Wathiq Accepted from Mobile App With Wathiq Docs ////////////////////////////////////////////////
    @isTest
    static void unitTest15(){
       Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        insert acc;
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        Test.startTest();
        
        acc.Wathiq_Consent__pc = true;
        update acc;
        //Need to comment the below line when we get Actual API Response
		 FetcheKYCDocumentHashQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyStringToFetchIDANDVHashValue(cs1);
        Test.stopTest();
	}
    
   ////////////////////////////////////////////// END: Wathiq Accepted from Mobile App With Wathiq Docs ////////////////////////////////////////////////

   ////////////////////////////////////////////// Start: Wathiq Accepted from Mobile App With CPR Form ////////////////////////////////////////////
    @isTest
    static void unitTest16(){
       Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        insert acc;
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Bahraini ID';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cnt.Image_Type__c = 'Face';
        cnt.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt.Similarity__c = 'MATCH';
        insert cnt;
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Bahraini ID';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cntFront.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        insert cntFront;
        
        Content__c cntBack = new Content__c();
        cntBack.Person__c = acc.Id;
        cntBack.Document_Type__c = 'Bahraini ID';
        cntBack.Document_Expiry_Date__c = System.today() + 60;
        cntBack.Scan_Type__c = 'POI';
        cntBack.Image_Type__c = 'Back';
        cntBack.Verification_Status__c = 'APPROVED_VERIFIED';
        cntBack.Similarity__c = 'MATCH';
        insert cntBack;
        
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        Test.startTest();
        
        acc.Wathiq_Consent__pc = true;
        update acc;
        //Need to comment the below line when we get Actual API Response
		FetcheKYCDocumentHashQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyStringToFetchIDANDVHashValue(cs1);
        Test.stopTest();
	}
   ////////////////////////////////////////////// END: Wathiq Accepted from Mobile App With CPR Form ////////////////////////////////////////////

   ////////////////////////////////////////////// Start: Wathiq Accepted from Mobile App With CPR Form having 2 Face Records ////////////////////////////////////////////
    @isTest
    static void unitTest17(){
       Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        insert acc;
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Bahraini ID';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cnt.Image_Type__c = 'Face';
        cnt.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt.Similarity__c = 'MATCH';
        insert cnt;
        
        Content__c cnt2Face = new Content__c();
        cnt2Face.Person__c = acc.Id;
        cnt2Face.Document_Type__c = 'Bahraini ID';
        cnt2Face.Document_Expiry_Date__c = System.today() + 60;
        cnt2Face.Scan_Type__c = 'POI';
        cnt2Face.Image_Type__c = 'Face';
        cnt2Face.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt2Face.Similarity__c = 'MATCH';
        insert cnt2Face;
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Bahraini ID';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cntFront.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        insert cntFront;
        
        Content__c cntBack = new Content__c();
        cntBack.Person__c = acc.Id;
        cntBack.Document_Type__c = 'Bahraini ID';
        cntBack.Document_Expiry_Date__c = System.today() + 60;
        cntBack.Scan_Type__c = 'POI';
        cntBack.Image_Type__c = 'Back';
        cntBack.Verification_Status__c = 'APPROVED_VERIFIED';
        cntBack.Similarity__c = 'MATCH';
        insert cntBack;
        
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        Test.startTest();
        
        acc.Wathiq_Consent__pc = true;
        update acc;
        //Need to comment the below line when we get Actual API Response
		FetcheKYCDocumentHashQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyStringToFetchIDANDVHashValue(cs1);
        Test.stopTest();
	}
   ////////////////////////////////////////////// END: Wathiq Accepted from Mobile App With CPR Form having 2 Face Records ////////////////////////////////////////////

  ////////////////////////////////////////////// Start: Wathiq Accepted from Mobile App With CPR Form having 3 Face Records ////////////////////////////////////////////
  @isTest
    static void unitTest18(){
       Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        insert acc;
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Bahraini ID';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cnt.Image_Type__c = 'Face';
        cnt.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt.Similarity__c = 'MATCH';
        insert cnt;
        
        Content__c cnt2Face = new Content__c();
        cnt2Face.Person__c = acc.Id;
        cnt2Face.Document_Type__c = 'Bahraini ID';
        cnt2Face.Document_Expiry_Date__c = System.today() + 60;
        cnt2Face.Scan_Type__c = 'POI';
        cnt2Face.Image_Type__c = 'Face';
        cnt2Face.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt2Face.Similarity__c = 'MATCH';
        insert cnt2Face;
        
        Content__c cnt3Face = new Content__c();
        cnt3Face.Person__c = acc.Id;
        cnt3Face.Document_Type__c = 'Bahraini ID';
        cnt3Face.Document_Expiry_Date__c = System.today() + 60;
        cnt3Face.Scan_Type__c = 'POI';
        cnt3Face.Image_Type__c = 'Face';
        cnt3Face.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt3Face.Similarity__c = 'MATCH';
        insert cnt3Face;
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Bahraini ID';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cntFront.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        insert cntFront;
        
        Content__c cntBack = new Content__c();
        cntBack.Person__c = acc.Id;
        cntBack.Document_Type__c = 'Bahraini ID';
        cntBack.Document_Expiry_Date__c = System.today() + 60;
        cntBack.Scan_Type__c = 'POI';
        cntBack.Image_Type__c = 'Back';
        cntBack.Verification_Status__c = 'APPROVED_VERIFIED';
        cntBack.Similarity__c = 'MATCH';
        insert cntBack;
        
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        Test.startTest();
        
        acc.Wathiq_Consent__pc = true;
        update acc;
        //Need to comment the below line when we get Actual API Response
		FetcheKYCDocumentHashQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyStringToFetchIDANDVHashValue(cs1);
        Test.stopTest();
	}
    
     @isTest
    static void unitTest18_1(){
       Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        insert acc;
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Passport';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cnt.Image_Type__c = 'Face';
        cnt.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt.Similarity__c = 'MATCH';
        cnt.Document_Country__c = 'BH';
        insert cnt;
        
        Content__c cnt2Face = new Content__c();
        cnt2Face.Person__c = acc.Id;
        cnt2Face.Document_Type__c = 'Passport';
        cnt2Face.Document_Expiry_Date__c = System.today() + 60;
        cnt2Face.Scan_Type__c = 'POI';
        cnt2Face.Image_Type__c = 'Face';
        cnt2Face.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt2Face.Similarity__c = 'MATCH';
        cnt2Face.Document_Country__c = 'BH';
        insert cnt2Face;
        
        Content__c cnt3Face = new Content__c();
        cnt3Face.Person__c = acc.Id;
        cnt3Face.Document_Type__c = 'Passport';
        cnt3Face.Document_Expiry_Date__c = System.today() + 60;
        cnt3Face.Scan_Type__c = 'POI';
        cnt3Face.Image_Type__c = 'Face';
        cnt3Face.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt3Face.Similarity__c = 'MATCH';
        cnt3Face.Document_Country__c = 'BH';
        insert cnt3Face;
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Passport';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cntFront.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        cntFront.Document_Country__c = 'BH';
        insert cntFront;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        Test.startTest();
        
        acc.Wathiq_Consent__pc = true;
        update acc;
        //Need to comment the below line when we get Actual API Response
		FetcheKYCDocumentHashQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyStringToFetchIDANDVHashValue(cs1);
        Test.stopTest();
	}
     @isTest
    static void unitTest18_2(){
       Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        insert acc;
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Passport';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cnt.Image_Type__c = 'Face';
        cnt.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt.Similarity__c = 'MATCH';
        cnt.Document_Country__c = 'BH';
        insert cnt;
        
        Content__c cnt2Face = new Content__c();
        cnt2Face.Person__c = acc.Id;
        cnt2Face.Document_Type__c = 'Passport';
        cnt2Face.Document_Expiry_Date__c = System.today() + 60;
        cnt2Face.Scan_Type__c = 'POI';
        cnt2Face.Image_Type__c = 'Face';
        cnt2Face.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt2Face.Similarity__c = 'MATCH';
        cnt2Face.Document_Country__c = 'BH';
        insert cnt2Face;
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Passport';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cntFront.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        cntFront.Document_Country__c = 'BH';
        insert cntFront;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        Test.startTest();
        
        acc.Wathiq_Consent__pc = true;
        update acc;
        //Need to comment the below line when we get Actual API Response
		FetcheKYCDocumentHashQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyStringToFetchIDANDVHashValue(cs1);
        Test.stopTest();
	}
    
    @isTest
    static void unitTest18_3(){
       Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        insert acc;
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Passport';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cnt.Image_Type__c = 'Face';
        cnt.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt.Similarity__c = 'MATCH';
        cnt.Document_Country__c = 'BH';
        insert cnt;
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Passport';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cntFront.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        cntFront.Document_Country__c = 'BH';
        insert cntFront;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        Test.startTest();
        
        acc.Wathiq_Consent__pc = true;
        update acc;
        //Need to comment the below line when we get Actual API Response
		FetcheKYCDocumentHashQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyStringToFetchIDANDVHashValue(cs1);
        Test.stopTest();
	}
  ////////////////////////////////////////////// END: Wathiq Accepted from Mobile App With CPR Form having 3 Face Records ////////////////////////////////////////////

  ///////////////////////////////////////////// Start: Wathiq Accepted from Mobile App With Missing Face Photo ////////////////////////////////////////////
  @isTest
    static void unitTest19(){
       Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        insert acc;
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Bahraini ID';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cntFront.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        insert cntFront;
        
        Content__c cntBack = new Content__c();
        cntBack.Person__c = acc.Id;
        cntBack.Document_Type__c = 'Bahraini ID';
        cntBack.Document_Expiry_Date__c = System.today() + 60;
        cntBack.Scan_Type__c = 'POI';
        cntBack.Image_Type__c = 'Back';
        cntBack.Verification_Status__c = 'APPROVED_VERIFIED';
        cntBack.Similarity__c = 'MATCH';
        insert cntBack;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        
        Test.startTest();
        acc.Wathiq_Consent__pc = true;
        update acc;
        Test.stopTest();
	}
  ///////////////////////////////////////////// END: Wathiq Accepted from Mobile App With Missing Face Photo ////////////////////////////////////////////

  ///////////////////////////////////////////// Start: Wathiq Accepted from Mobile App With Missing Front or Back Photo /////////////////////////////////
  @isTest
    static void unitTest20(){
       Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        insert acc;
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Bahraini ID';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cntFront.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Face';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        insert cntFront;
        
        Content__c cntBack = new Content__c();
        cntBack.Person__c = acc.Id;
        cntBack.Document_Type__c = 'Bahraini ID';
        cntBack.Document_Expiry_Date__c = System.today() + 60;
        cntBack.Scan_Type__c = 'POI';
        cntBack.Image_Type__c = 'Back';
        cntBack.Verification_Status__c = 'APPROVED_VERIFIED';
        cntBack.Similarity__c = 'MATCH';
        insert cntBack;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        
        Test.startTest();
        acc.Wathiq_Consent__pc = true;
        update acc;
        Test.stopTest();
	}
  ///////////////////////////////////////////// END: Wathiq Accepted from Mobile App With Missing Front or Back Photo /////////////////////////////////

  ////////////////////////////////////////////// Start: API is returning Nationality = Bahrain and Resident Expiry is within 45 Days ////////////////////////////////////////
    @isTest
    static void unitTest21(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2030","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"BH","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;

        //Setted a Mock Response in this method related to resident expiry
        Test.setMock(HttpCalloutMock.class, new RestMockWithResidentExpiryBH());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
        update cs1;
        caseIds.add(cs1.id);
        List<Case> cseList = [Select id,pr_OtherDocumentsRequired__c,pr_ResidencyPermitPhotoRequired__c,eKYC_iGA_Response__c from case where id =: caseIds];
        System.debug('Case List in test class:'+cseList);
        
        cs1.cc_Residence_Permit_No__c = '64746547';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 3650;
        update cs1;
        System.debug('Case After update Resident Permit Photo:'+cs1.pr_ResidencyPermitPhotoRequired__c);

        cs1.Status = 'All Documents Uploaded';
        update cs1;
	}
    ////////////////////////////////////////////// END: API is returning Nationality = Bahrain and Resident Expiry is within 45 Days ////////////////////////////////////////

    ////////////////////////////////////////////// Start: API is returning Resident Expiry is within 45 Days and CA also enter within 45 Days  /////////////////////////////////////////////////////////
     @isTest
    static void unitTest22(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2030","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;

        //Setted a Mock Response in this method related to Resident Expiry
        Test.setMock(HttpCalloutMock.class, new RestMockWithResidentExpiry());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
        update cs1;
        caseIds.add(cs1.id);
        List<Case> cseList = [Select id,pr_OtherDocumentsRequired__c,pr_ResidencyPermitPhotoRequired__c,eKYC_iGA_Response__c from case where id =: caseIds];
        System.debug('Case List in test class:'+cseList);
        
        cs1.cc_Residence_Permit_No__c = '64746547';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 1000;
        update cs1;
        System.debug('Case After update Resident Permit Photo:'+cs1.pr_ResidencyPermitPhotoRequired__c);
        
        cs1.Status = 'All Documents Uploaded';
        update cs1;
	}
    ////////////////////////////////////////////// END: API is returning Resident Expiry is within 45 Days and CA also enter within 45 Days /////////////////////////////////////////////////////////

    ///////////////////////////////////////////// Start : API is returning Passport Expiry is within 45 Days Range //////////////////////////////////////////////
     @isTest
    static void unitTest23(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2030","residentPermitNo":"s3433421edd","passportExpiryDate":"15/01/2022","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;

        //Setted a Mock Response in this method related to Passport Expiry
        Test.setMock(HttpCalloutMock.class, new RestMockWithPassportExpiry());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
        update cs1;
        caseIds.add(cs1.id);
        List<Case> cseList = [Select id,pr_OtherDocumentsRequired__c,pr_ResidencyPermitPhotoRequired__c,eKYC_iGA_Response__c from case where id =: caseIds];
        System.debug('Case List in test class:'+cseList);
        
        cs1.cc_Passport_Number__c = 'L9807654';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 1000;
        cs1.Document_Country__c = 'IN';
        cs1.pcNationality__c = 'IN';
        update cs1;
        System.debug('Case After update Resident Permit Photo:'+cs1.pr_ResidencyPermitPhotoRequired__c);
        
        cs1.Status = 'All Documents Uploaded';
        update cs1;
	}
    
    ///////////////////////////////////////////// END : API is returning Passport Expiry is within 45 Days Range //////////////////////////////////////////////

    //////////////////////////////////////////// Start: API is returning Passport Expiry & Resident Expiry is within 45 Days Range /////////////////////////////////////////
      @isTest
    static void unitTest24(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"15/01/2023","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;

        //Setted a Mock Response in this method related to Passport Expiry & Resident Expiry
        Test.setMock(HttpCalloutMock.class, new RestMockWithPassportANDResidentExpiry());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
        update cs1;
        caseIds.add(cs1.id);
        List<Case> cseList = [Select id,pr_OtherDocumentsRequired__c,pr_ResidencyPermitPhotoRequired__c,eKYC_iGA_Response__c from case where id =: caseIds];
        System.debug('Case List in test class:'+cseList);
        
        cs1.cc_Passport_Number__c = 'L9807654';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 10;
        cs1.Document_Country__c = 'IN';
        cs1.pcNationality__c = 'IN';
        update cs1;
        
        cs1.cc_Residence_Permit_No__c = '64746547';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 10;
        update cs1;
        System.debug('Case After update Resident Permit Photo:'+cs1.pr_ResidencyPermitPhotoRequired__c);
        
        cs1.Status = 'All Documents Uploaded';
        update cs1;
	}
    
    //////////////////////////////////////////// END: API is returning Passport Expiry & Resident Expiry is within 45 Days Range /////////////////////////////////////////

    //////////////////////////////////////////// Start: API is returning Passport Expiry & Resident Expiry is within 45 Days Range /////////////////////////////////////////
      @isTest
    static void unitTest25(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"15/01/2023","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;

        //Setted a Mock Response in this method related to Passport Expiry & Resident Expiry
        Test.setMock(HttpCalloutMock.class, new RestMockWithPassportANDResidentExpiry());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
        update cs1;
        caseIds.add(cs1.id);
        List<Case> cseList = [Select id,pr_OtherDocumentsRequired__c,pr_ResidencyPermitPhotoRequired__c,eKYC_iGA_Response__c from case where id =: caseIds];
        System.debug('Case List in test class:'+cseList);
        
        cs1.cc_Residence_Permit_No__c = '64746547';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 10;
        update cs1;
        System.debug('Case After update Resident Permit Photo:'+cs1.pr_ResidencyPermitPhotoRequired__c);
        
        cs1.cc_Passport_Number__c = 'L9807654';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 10;
        cs1.Document_Country__c = 'IN';
        cs1.pcNationality__c = 'IN';
        update cs1;
        
        cs1.Status = 'All Documents Uploaded';
        update cs1;
	}
    
    //////////////////////////////////////////// END: API is returning Passport Expiry & Resident Expiry is within 45 Days Range /////////////////////////////////////////
 
    //////////////////////////////////////////// Start: API is returning Gender as Empty ////////////////////////////////////////////////////////////////
 @isTest
    static void unitTest26(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2030","residentPermitNo":"s3433421edd","passportExpiryDate":"15/01/2030","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;

        //Setted a Mock Response in this method related to Gender as Empty
        Test.setMock(HttpCalloutMock.class, new RestMockWithGenderEmpty());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
        update cs1;
        caseIds.add(cs1.id);
        List<Case> cseList = [Select id,pr_OtherDocumentsRequired__c,pr_ResidencyPermitPhotoRequired__c,eKYC_iGA_Response__c from case where id =: caseIds];
        System.debug('Case List in test class:'+cseList);
        String dob = '24/08/1990';
        cs1.pr_First_Name__c = 'Test';
        cs1.pr_Middle_Name__c = 'JOHN';
        cs1.pr_Middle_Name_2__c = 'TONY';
        cs1.pr_Middle_Name_3__c = 'CRUZ';
 		cs1.pr_Middle_Name_4__c = 'CRAIG';
        cs1.pr_Last_Name__c = 'CENA';
        cs1.pcGender__c = 'M';
        cs1.pcDate_of_Birth__c = Date.Parse(dob);
        update cs1;
        
        cs1.Status = 'All Documents Uploaded';
        update cs1;
	}
    
    //////////////////////////////////////////// END: API is returning Gender as Empty ////////////////////////////////////////////////////////////////

    //////////////////////////////////////////// Start: API is returning Gender as Empty & Resident Expiry ////////////////////////////////////////////////////////////////
 @isTest
    static void unitTest27(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"15/01/2030","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;

        //Setted a Mock Response in this method related to Gender as Empty and Resident Expiry
        Test.setMock(HttpCalloutMock.class, new RestMockWithGenderEmptyResidentExpiry());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
        update cs1;
        caseIds.add(cs1.id);
        List<Case> cseList = [Select id,pr_OtherDocumentsRequired__c,pr_ResidencyPermitPhotoRequired__c,eKYC_iGA_Response__c from case where id =: caseIds];
        System.debug('Case List in test class:'+cseList);
        String dob = '24/08/1990';
        cs1.pr_First_Name__c = 'Test';
        cs1.pr_Middle_Name__c = 'JOHN';
        cs1.pr_Middle_Name_2__c = 'TONY';
        cs1.pr_Middle_Name_3__c = 'CRUZ';
 		cs1.pr_Middle_Name_4__c = 'CRAIG';
        cs1.pr_Last_Name__c = 'CENA';
        cs1.pcGender__c = 'M';
        cs1.pcDate_of_Birth__c = Date.Parse(dob);
        update cs1;
        
        cs1.cc_Residence_Permit_No__c = '64746547';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 1000;
        update cs1;
        
        cs1.Status = 'All Documents Uploaded';
        update cs1;
	}
    
    //////////////////////////////////////////// END: API is returning Gender as Empty & Resident Expiry ////////////////////////////////////////////////////////////////

    
    //////////////////////////////////////////// Start: API is returning Gender as Empty & Resident Expiry ////////////////////////////////////////////////////////////////
 @isTest
    static void unitTest28(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"15/01/2030","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;

        //Setted a Mock Response in this method related to Gender as Empty and Resident Expiry
        Test.setMock(HttpCalloutMock.class, new RestMockWithGenderEmptyResidentExpiry());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
        update cs1;
        caseIds.add(cs1.id);
        List<Case> cseList = [Select id,pr_OtherDocumentsRequired__c,pr_ResidencyPermitPhotoRequired__c,eKYC_iGA_Response__c from case where id =: caseIds];
        System.debug('Case List in test class:'+cseList);
        
        cs1.cc_Residence_Permit_No__c = '64746547';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 1000;
        update cs1;
        
        String dob = '24/08/1990';
        cs1.pr_First_Name__c = 'Test';
        cs1.pr_Middle_Name__c = 'JOHN';
        cs1.pr_Middle_Name_2__c = 'TONY';
        cs1.pr_Middle_Name_3__c = 'CRUZ';
 		cs1.pr_Middle_Name_4__c = 'CRAIG';
        cs1.pr_Last_Name__c = 'CENA';
        cs1.pcGender__c = 'M';
        cs1.pcDate_of_Birth__c = Date.Parse(dob);
        update cs1;
        
        cs1.Status = 'All Documents Uploaded';
        update cs1;
	}
    
    //////////////////////////////////////////// END: API is returning Gender as Empty & Resident Expiry ////////////////////////////////////////////////////////////////

    //////////////////////////////////////////// Start: API is returning Gender as Empty & Passport Expiry ////////////////////////////////////////////////////////////////
    @isTest
    static void unitTest29(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2030","residentPermitNo":"s3433421edd","passportExpiryDate":"15/01/2023","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;

        //Setted a Mock Response in this method related to Gender as Empty and passport Expiry
        Test.setMock(HttpCalloutMock.class, new RestMockWithGenderEmptyPassportExpiry());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
        update cs1;
        caseIds.add(cs1.id);
        List<Case> cseList = [Select id,pr_OtherDocumentsRequired__c,pr_ResidencyPermitPhotoRequired__c,eKYC_iGA_Response__c from case where id =: caseIds];
        System.debug('Case List in test class:'+cseList);
        
        cs1.cc_Passport_Number__c = 'L9807654';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 1000;
        cs1.Document_Country__c = 'IN';
        cs1.pcNationality__c = 'IN';
        update cs1;
        
        String dob = '24/08/1990';
        cs1.pr_First_Name__c = 'Test';
        cs1.pr_Middle_Name__c = 'JOHN';
        cs1.pr_Middle_Name_2__c = 'TONY';
        cs1.pr_Middle_Name_3__c = 'CRUZ';
 		cs1.pr_Middle_Name_4__c = 'CRAIG';
        cs1.pr_Last_Name__c = 'CENA';
        cs1.pcGender__c = 'M';
        cs1.pcDate_of_Birth__c = Date.Parse(dob);
        update cs1;
        
        cs1.Status = 'All Documents Uploaded';
        update cs1;
	}

    //////////////////////////////////////////// END: API is returning Gender as Empty & Passport Expiry ////////////////////////////////////////////////////////////////

      //////////////////////////////////////////// Start: API is returning Gender as Empty & Passport Expiry ////////////////////////////////////////////////////////////////
    @isTest
    static void unitTest30(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 600;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2030","residentPermitNo":"s3433421edd","passportExpiryDate":"15/01/2023","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;

        //Setted a Mock Response in this method related to Gender as Empty and passport Expiry
        Test.setMock(HttpCalloutMock.class, new RestMockWithGenderEmptyPassportExpiry());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
        update cs1;
        caseIds.add(cs1.id);
        List<Case> cseList = [Select id,pr_OtherDocumentsRequired__c,pr_ResidencyPermitPhotoRequired__c,eKYC_iGA_Response__c from case where id =: caseIds];
        System.debug('Case List in test class:'+cseList);
        String dob = '24/08/1990';
        cs1.pr_First_Name__c = 'Test';
        cs1.pr_Middle_Name__c = 'JOHN';
        cs1.pr_Middle_Name_2__c = 'TONY';
        cs1.pr_Middle_Name_3__c = 'CRUZ';
 		cs1.pr_Middle_Name_4__c = 'CRAIG';
        cs1.pr_Last_Name__c = 'CENA';
        cs1.pcGender__c = 'M';
        cs1.pcDate_of_Birth__c = Date.Parse(dob);
        update cs1;
        
        cs1.cc_Passport_Number__c = 'L9807654';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 1000;
        cs1.Document_Country__c = 'IN';
        cs1.pcNationality__c = 'IN';
        update cs1;
        
        cs1.Status = 'All Documents Uploaded';
        update cs1;
	}

    //////////////////////////////////////////// END: API is returning Gender as Empty & Passport Expiry ////////////////////////////////////////////////////////////////

     //////////////////////////////////////////// Start: API is returning Only First Name ////////////////////////////////////////////////////////////////
    @isTest
    static void unitTest31(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2030","residentPermitNo":"s3433421edd","passportExpiryDate":"15/01/2030","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"","enMiddleName2":"","enMiddleName3":"","enMiddleName4":"","enLastName":"","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;

        //Setted a Mock Response in this method related to First Name
        Test.setMock(HttpCalloutMock.class, new RestMockWithFirstName());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
     }

    //////////////////////////////////////////// END: API is returning only First Name ////////////////////////////////////////////////////////////////

     //////////////////////////////////////////// Start: API is returning Passport Number Empty ////////////////////////////////////////////////////////////////
    @isTest
    static void unitTest32(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"15/01/2024","passportNumber":"","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Mohd","enMiddleName2":"Abdul","enMiddleName3":"","enMiddleName4":"Hasan","enLastName":"Khazi","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;

        //Setted a Mock Response in this method related to Passport Number Empty
        Test.setMock(HttpCalloutMock.class, new RestMockWithPassportNumberEmpty());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
     }

    //////////////////////////////////////////// END: API is returning Passport Number Empty ////////////////////////////////////////////////////////////////

     //////////////////////////////////////////// Start: API is returning Residency Number Empty ////////////////////////////////////////////////////////////////
    @isTest
    static void unitTest33(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2024","residentPermitNo":"","passportExpiryDate":"15/01/2024","passportNumber":"L908754","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Mohd","enMiddleName2":"Abdul","enMiddleName3":"","enMiddleName4":"Hasan","enLastName":"Khazi","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;

        //Setted a Mock Response in this method related to Resident Number Empty
        Test.setMock(HttpCalloutMock.class, new RestMockWithResidentNumberEmpty());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
     }

    //////////////////////////////////////////// END: API is returning Residency Number Empty ////////////////////////////////////////////////////////////////

     //////////////////////////////////////////// Start: API is returning Residency Number & Passport Number Empty ////////////////////////////////////////////////////////////////
    @isTest
    static void unitTest34(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2024","residentPermitNo":"","passportExpiryDate":"15/01/2024","passportNumber":"","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Mohd","enMiddleName2":"Abdul","enMiddleName3":"","enMiddleName4":"Hasan","enLastName":"Khazi","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;

        //Setted a Mock Response in this method related to Resident Number & Passport Number Empty
        Test.setMock(HttpCalloutMock.class, new RestMockWithResidentANDPassportNumberEmpty());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
     }

    //////////////////////////////////////////// END: API is returning Residency Number & Passport Number Empty ////////////////////////////////////////////////////////////////

      //////////////////////////////////////////// Start: API is returning Nationality Empty ////////////////////////////////////////////////////////////////
    @isTest
    static void unitTest35(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/01/2024","residentPermitNo":"65765856","passportExpiryDate":"15/01/2024","passportNumber":"L90757565","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Mohd","enMiddleName2":"Abdul","enMiddleName3":"","enMiddleName4":"Hasan","enLastName":"Khazi","gender":"M","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;

        //Setted a Mock Response in this method related to Nationality Empty
        Test.setMock(HttpCalloutMock.class, new RestMockWithNationalityEmpty());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
     }

    //////////////////////////////////////////// END: API is returning Nationality Empty ////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////Start : Covering Exception Code of FetcheKYCDocumentHashQueuableAPI Class ///////////////////////
    @isTest
    static void unitTest36(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = '';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        
        //Need to comment the below line when we get Actual API Response
		FetcheKYCDocumentHashQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"dat":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value Exception
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponseExcep());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyStringToFetchIDANDVHashValue(cs1);
        Test.stopTest();
        //FetcheKYCDocumentHashQueuableAPI.createSystemAction(null, null, null, null, cs1.Id, null, cs1.accountId, 0, null, null);
    }
    //////////////////////////////////////////////END : Covering Exception Code of FetcheKYCDocumentHashQueuableAPI Class ///////////////////////

    //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Accepted & IDAndVHash not available - No Documents Available ///////////////////////////////////////////////
    @isTest
    static void unitTest37(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;

        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        insert acc; 
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.AccountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        cs1.Force_Generate_Wathiq_Consent_Form__c = true;
        insert cs1;
        
        cs1.Re_Process_Wathiq_Form__c = true;
        update cs1;
    }
   //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Accepted & IDAndVHash not available - No Documents Available ///////////////////////////////////////////////

    //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Accepted & IDAndVHash not available - Documents Available ///////////////////////////////////////////////
    @isTest
    static void unitTest38(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;

        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 180;
        insert cnt;
        Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.AccountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        cs1.Force_Generate_Wathiq_Consent_Form__c = true;
        insert cs1;
        
        cs1.Re_Process_Wathiq_Form__c = true;
        update cs1;
        
         //Need to comment the below line when we get Actual API Response
		FetcheKYCDocHashValueToReprocess.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value Exception
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        Test.stopTest();
    }
   //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Accepted & IDAndVHash not available - Documents Available ///////////////////////////////////////////////

   //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Accepted & IDAndVHash not available - Documents Available With Exception Code///////////////////////////////////////////////
    @isTest
    static void unitTest39(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;

        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 180;
        insert cnt;
        Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.AccountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        cs1.Force_Generate_Wathiq_Consent_Form__c = true;
        insert cs1;
        
        cs1.Re_Process_Wathiq_Form__c = true;
        update cs1;
        
         //Need to comment the below line when we get Actual API Response
		FetcheKYCDocHashValueToReprocess.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"dat":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value Exception
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        Test.stopTest();
        
        FetcheKYCDocHashValueToReprocess.createSystemAction(null, null, null, null, cs1.Id, null, cs1.accountId, 0, null, null);

    }
   //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Accepted & IDAndVHash not available - Documents Available With Exception Code ///////////////////////////////////////////////

    //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Not Accepted & IDAndVHash not available - No Documents Available ///////////////////////////////////////////////
    @isTest
    static void unitTest40(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;

        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        //acc.Wathiq_Consent__pc = true;
        insert acc; 
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.AccountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        cs1.Force_Generate_Wathiq_Consent_Form__c = true;
        insert cs1;
        
        cs1.Re_Process_Wathiq_Form__c = true;
        update cs1;
    }
   //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Not Accepted & IDAndVHash not available - No Documents Available ///////////////////////////////////////////////

     //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Accepted & IDAndVHash not available - Documents Available CPR Form ///////////////////////////////////////////////
    @isTest
    static void unitTest41(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;

        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        insert acc; 
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Bahraini ID';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cntFront.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        insert cntFront;
        
        Content__c cntBack = new Content__c();
        cntBack.Person__c = acc.Id;
        cntBack.Document_Type__c = 'Bahraini ID';
        cntBack.Document_Expiry_Date__c = System.today() + 60;
        cntBack.Scan_Type__c = 'POI';
        cntBack.Image_Type__c = 'Back';
        cntBack.Verification_Status__c = 'APPROVED_VERIFIED';
        cntBack.Similarity__c = 'MATCH';
        insert cntBack;
       
        Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.AccountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        cs1.Force_Generate_Wathiq_Consent_Form__c = true;
        insert cs1;
        
        cs1.Re_Process_Wathiq_Form__c = true;
        update cs1;
        
         //Need to comment the below line when we get Actual API Response
		FetcheKYCDocHashValueToReprocess.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value Exception
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        Test.stopTest();
    }
   //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Accepted & IDAndVHash not available - Documents Available CPR Form ///////////////////////////////////////////////

    //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Accepted & IDAndVHash not available - Documents Available CPR Form - 2 Face Records ///////////////////////////////////////////////
    @isTest
    static void unitTest42(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;

        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Bahraini ID';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cnt.Image_Type__c = 'Face';
        cnt.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt.Similarity__c = 'MATCH';
        insert cnt;
        
        Content__c cnt2Face = new Content__c();
        cnt2Face.Person__c = acc.Id;
        cnt2Face.Document_Type__c = 'Bahraini ID';
        cnt2Face.Document_Expiry_Date__c = System.today() + 60;
        cnt2Face.Scan_Type__c = 'POI';
        cnt2Face.Image_Type__c = 'Face';
        cnt2Face.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt2Face.Similarity__c = 'MATCH';
        insert cnt2Face;
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Bahraini ID';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cntFront.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        insert cntFront;
        
        Content__c cntBack = new Content__c();
        cntBack.Person__c = acc.Id;
        cntBack.Document_Type__c = 'Bahraini ID';
        cntBack.Document_Expiry_Date__c = System.today() + 60;
        cntBack.Scan_Type__c = 'POI';
        cntBack.Image_Type__c = 'Back';
        cntBack.Verification_Status__c = 'APPROVED_VERIFIED';
        cntBack.Similarity__c = 'MATCH';
        insert cntBack;
        
       
        Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.AccountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        cs1.Force_Generate_Wathiq_Consent_Form__c = true;
        insert cs1;
        
        cs1.Re_Process_Wathiq_Form__c = true;
        update cs1;
        
         //Need to comment the below line when we get Actual API Response
		FetcheKYCDocHashValueToReprocess.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value Exception
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        Test.stopTest();
    }
   //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Accepted & IDAndVHash not available - Documents Available CPR Form - 2 Face Records ///////////////////////////////////////////////

     //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Accepted & IDAndVHash not available - Documents Available CPR Form - 3 Face Records ///////////////////////////////////////////////
    @isTest
    static void unitTest43(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;

        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Bahraini ID';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        cnt.Scan_Type__c = 'POI';
        cnt.Image_Type__c = 'Face';
        cnt.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt.Similarity__c = 'MATCH';
        insert cnt;
        
        Content__c cnt2Face = new Content__c();
        cnt2Face.Person__c = acc.Id;
        cnt2Face.Document_Type__c = 'Bahraini ID';
        cnt2Face.Document_Expiry_Date__c = System.today() + 60;
        cnt2Face.Scan_Type__c = 'POI';
        cnt2Face.Image_Type__c = 'Face';
        cnt2Face.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt2Face.Similarity__c = 'MATCH';
        insert cnt2Face;
        
        Content__c cnt3Face = new Content__c();
        cnt3Face.Person__c = acc.Id;
        cnt3Face.Document_Type__c = 'Bahraini ID';
        cnt3Face.Document_Expiry_Date__c = System.today() + 60;
        cnt3Face.Scan_Type__c = 'POI';
        cnt3Face.Image_Type__c = 'Face';
        cnt3Face.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt3Face.Similarity__c = 'MATCH';
        insert cnt3Face;
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Bahraini ID';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cntFront.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        insert cntFront;
        
        Content__c cntBack = new Content__c();
        cntBack.Person__c = acc.Id;
        cntBack.Document_Type__c = 'Bahraini ID';
        cntBack.Document_Expiry_Date__c = System.today() + 60;
        cntBack.Scan_Type__c = 'POI';
        cntBack.Image_Type__c = 'Back';
        cntBack.Verification_Status__c = 'APPROVED_VERIFIED';
        cntBack.Similarity__c = 'MATCH';
        insert cntBack;
        
       
        Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.AccountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        cs1.Force_Generate_Wathiq_Consent_Form__c = true;
        insert cs1;
        
        cs1.Re_Process_Wathiq_Form__c = true;
        update cs1;
        
         //Need to comment the below line when we get Actual API Response
		FetcheKYCDocHashValueToReprocess.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value Exception
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        Test.stopTest();
    }
   //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Accepted & IDAndVHash not available - Documents Available CPR Form - 3 Face Records ///////////////////////////////////////////////

    //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Accepted & IDAndVHash not available - Documents Available CPR Form - Missing Face Photo ///////////////////////////////////////////////
    @isTest
    static void unitTest44(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;

        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        insert acc; 
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Bahraini ID';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cntFront.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        insert cntFront;
        
        Content__c cntBack = new Content__c();
        cntBack.Person__c = acc.Id;
        cntBack.Document_Type__c = 'Bahraini ID';
        cntBack.Document_Expiry_Date__c = System.today() + 60;
        cntBack.Scan_Type__c = 'POI';
        cntBack.Image_Type__c = 'Back';
        cntBack.Verification_Status__c = 'APPROVED_VERIFIED';
        cntBack.Similarity__c = 'MATCH';
        insert cntBack;
        
        
       
        Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.AccountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        cs1.Force_Generate_Wathiq_Consent_Form__c = true;
        insert cs1;
        
        cs1.Re_Process_Wathiq_Form__c = true;
        update cs1;
        
         //Need to comment the below line when we get Actual API Response
		FetcheKYCDocHashValueToReprocess.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value Exception
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        Test.stopTest();
    }
    //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Accepted & IDAndVHash not available - Documents Available CPR Form - Missing Face Photo ///////////////////////////////////////////////

    //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Accepted & IDAndVHash not available - Documents Available CPR Form - Missing Front & Back Photo ///////////////////////////////////////////////
    @isTest
    static void unitTest45(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;

        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        insert acc; 
        
         Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Bahraini ID';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cntFront.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Face';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        insert cntFront;
        
        Content__c cntBack = new Content__c();
        cntBack.Person__c = acc.Id;
        cntBack.Document_Type__c = 'Bahraini ID';
        cntBack.Document_Expiry_Date__c = System.today() + 60;
        cntBack.Scan_Type__c = 'POI';
        cntBack.Image_Type__c = 'Back';
        cntBack.Verification_Status__c = 'APPROVED_VERIFIED';
        cntBack.Similarity__c = 'MATCH';
        insert cntBack;
        
        
       
        Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.AccountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        cs1.Force_Generate_Wathiq_Consent_Form__c = true;
        insert cs1;
        
        cs1.Re_Process_Wathiq_Form__c = true;
        update cs1;
        
         //Need to comment the below line when we get Actual API Response
		FetcheKYCDocHashValueToReprocess.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value Exception
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        Test.stopTest();
    }
    //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Accepted & IDAndVHash not available - Documents Available CPR Form - Missing Front & Back Photo ///////////////////////////////////////////////

    @isTest
    static void unitTest46(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Hash Value';
        insert acc; 
        Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"30/01/2024","residentPermitNo":"s3433421edd","passportExpiryDate":"30/01/2024","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"BH","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;
		//Setted a Mock Response in this method related to periodic review positive response
        Test.setMock(HttpCalloutMock.class, new RestMockPositiveResponseNonBahrainGenderEmpty());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
    }
    
    @isTest
    static void unitTest47(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
       
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/06/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"15/06/2023","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;

        //Setted a Mock Response in this method related to Gender as Empty and Resident Expiry
        Test.setMock(HttpCalloutMock.class, new RestMockWithPassportANDResidentExpiryANDGenderEmpty());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
        
	}
     @isTest
    static void unitTest48(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        insert acc; 
        
        Content__c cnt = new Content__c();
        cnt.Person__c = acc.Id;
        cnt.Document_Type__c = 'Wathiq Consent Form';
        cnt.Document_Expiry_Date__c = System.today() + 60;
        insert cnt;
        
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        //Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        insert cs1;
        //Need to comment the below line when we get Actual API Response
        FetcheKYCIGADataQueuableAPI.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"igaData":{"residentPermitExpiry":"15/06/2023","residentPermitNo":"s3433421edd","passportExpiryDate":"15/06/2023","passportNumber":"A77283D","idNumber":"777772828","cardCountry":"IN","caseId":"case00002","arFirstName":"محمد","arMiddleName1":"علي‎","arMiddleName2":"عبد الله","arMiddleName3":"حسين","arMiddleName4":"عبد السلام","arLastName":"جابر","enFirstName":"Mohd","enMiddleName1":"Ali","enMiddleName2":"Abdulla","enMiddleName3":"Hussain","enMiddleName4":"Abdul Salam","enLastName":"Jabber","gender":"","dateOfBirth":"30/11/1970","telephoneNumber":"36000000","email":"a@a.com","nationality":"IN","customerAddress":{"addressType":"VILLA","flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","city":"MANAMA"},"employmentInfo":{"occupation":"WORKER","employmentStatus":"ACTIVE (WORKING/STUDYING)","employerName":"INFORMATION & eGOVERNMENT AUTHORITY","employerAddress":{"flatNumber":"0","buildingNumber":"0","buildingAlpha":"Al-Jasra Building","roadNumber":"222","blockNumber":"222","country":"BAH"}},"maritalStatus":"","personPhoto":"/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==","signature":"Ayj3f/2Q=="},"crmSyncResult":true,"onboardingType":"iga","onboardingDecision":"SUCCESS"}}' ;

        //Setted a Mock Response in this method related to Gender as Empty and passport Expiry
        Test.setMock(HttpCalloutMock.class, new RestMockWithPassportANDResidentExpiryANDGenderEmpty());
        //final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = bodyString(cs1);
        Test.stopTest();
        update cs1;
        caseIds.add(cs1.id);
        List<Case> cseList = [Select id,pr_OtherDocumentsRequired__c,pr_ResidencyPermitPhotoRequired__c,eKYC_iGA_Response__c from case where id =: caseIds];
        System.debug('Case List in test class:'+cseList);
        
        cs1.cc_Passport_Number__c = 'L9807654';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 10;
        cs1.Document_Country__c = 'IN';
        cs1.pcNationality__c = 'IN';
        update cs1;
        
        cs1.cc_Residence_Permit_No__c = '64746547';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 10;
        update cs1;
        
        String dob = '24/08/1990';
        cs1.pr_First_Name__c = 'Test';
        cs1.pr_Middle_Name__c = 'JOHN';
        cs1.pr_Middle_Name_2__c = 'TONY';
        cs1.pr_Middle_Name_3__c = 'CRUZ';
 		cs1.pr_Middle_Name_4__c = 'CRAIG';
        cs1.pr_Last_Name__c = 'CENA';
        cs1.pcGender__c = 'M';
        cs1.pcDate_of_Birth__c = Date.Parse(dob);
        update cs1;
        
        cs1.Status = 'All Documents Uploaded';
        update cs1;
	}
    
     //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Accepted & IDAndVHash not available - Documents Available Passport Form  ///////////////////////////////////////////////
    @isTest
    static void unitTest49(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;

        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        insert acc; 
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Passport';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cntFront.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        cntFront.Document_Country__c = 'BH';
        insert cntFront;
        
        Content__c cntFace = new Content__c();
        cntFace.Person__c = acc.Id;
        cntFace.Document_Type__c = 'Passport';
        cntFace.Document_Expiry_Date__c = System.today() + 60;
        cntFace.Scan_Type__c = 'POI';
        cntFace.Image_Type__c = 'Face';
        cntFace.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFace.Similarity__c = 'MATCH';
        cntFace.Document_Country__c = 'BH';
        insert cntFace;
        
        
       
        Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.AccountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        cs1.Force_Generate_Wathiq_Consent_Form__c = true;
        insert cs1;
        
        cs1.Re_Process_Wathiq_Form__c = true;
        update cs1;
        
         //Need to comment the below line when we get Actual API Response
		FetcheKYCDocHashValueToReprocess.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value Exception
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        Test.stopTest();
    }
    
     @isTest
    static void unitTest50(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;

        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        insert acc; 
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Passport';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cntFront.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        cntFront.Document_Country__c = 'BH';
        insert cntFront;
        
        Content__c cntFront2 = new Content__c();
        cntFront2.Person__c = acc.Id;
        cntFront2.Document_Type__c = 'Passport';
        cntFront2.Document_Expiry_Date__c = System.today() + 60;
        cntFront2.Scan_Type__c = 'POI';
        cntFront2.Image_Type__c = 'Front';
        cntFront2.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront2.Similarity__c = 'MATCH';
        cntFront2.Document_Country__c = 'BH';
        insert cntFront2;
        
        Content__c cntFace = new Content__c();
        cntFace.Person__c = acc.Id;
        cntFace.Document_Type__c = 'Passport';
        cntFace.Document_Expiry_Date__c = System.today() + 60;
        cntFace.Scan_Type__c = 'POI';
        cntFace.Image_Type__c = 'Face';
        cntFace.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFace.Similarity__c = 'MATCH';
        cntFace.Document_Country__c = 'BH';
        insert cntFace;
        
        Content__c cntFace2 = new Content__c();
        cntFace2.Person__c = acc.Id;
        cntFace2.Document_Type__c = 'Passport';
        cntFace2.Document_Expiry_Date__c = System.today() + 60;
        cntFace2.Scan_Type__c = 'POI';
        cntFace2.Image_Type__c = 'Face';
        cntFace2.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFace2.Similarity__c = 'MATCH';
        cntFace2.Document_Country__c = 'BH';
        insert cntFace2;
        
        
       
        Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.AccountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        cs1.Force_Generate_Wathiq_Consent_Form__c = true;
        insert cs1;
        
        cs1.Re_Process_Wathiq_Form__c = true;
        update cs1;
        
         //Need to comment the below line when we get Actual API Response
		FetcheKYCDocHashValueToReprocess.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value Exception
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        Test.stopTest();
    }
    
     @isTest
    static void unitTest51(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;

        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Wathiq_Consent__pc = true;
        insert acc; 
        
        Content__c cntFront = new Content__c();
        cntFront.Person__c = acc.Id;
        cntFront.Document_Type__c = 'Passport';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cntFront.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        cntFront.Document_Country__c = 'BH';
        insert cntFront;
        
        Content__c cntFront2 = new Content__c();
        cntFront2.Person__c = acc.Id;
        cntFront2.Document_Type__c = 'Passport';
        cntFront2.Document_Expiry_Date__c = System.today() + 60;
        cntFront2.Scan_Type__c = 'POI';
        cntFront2.Image_Type__c = 'Front';
        cntFront2.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront2.Similarity__c = 'MATCH';
        cntFront2.Document_Country__c = 'BH';
        insert cntFront2;
        
        Content__c cntFront3 = new Content__c();
        cntFront3.Person__c = acc.Id;
        cntFront3.Document_Type__c = 'Passport';
        cntFront3.Document_Expiry_Date__c = System.today() + 60;
        cntFront3.Scan_Type__c = 'POI';
        cntFront3.Image_Type__c = 'Front';
        cntFront3.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront3.Similarity__c = 'MATCH';
        cntFront3.Document_Country__c = 'BH';
        insert cntFront3;
        
        Content__c cntFace = new Content__c();
        cntFace.Person__c = acc.Id;
        cntFace.Document_Type__c = 'Passport';
        cntFace.Document_Expiry_Date__c = System.today() + 60;
        cntFace.Scan_Type__c = 'POI';
        cntFace.Image_Type__c = 'Face';
        cntFace.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFace.Similarity__c = 'MATCH';
        cntFace.Document_Country__c = 'BH';
        insert cntFace;
        
        Content__c cntFace2 = new Content__c();
        cntFace2.Person__c = acc.Id;
        cntFace2.Document_Type__c = 'Passport';
        cntFace2.Document_Expiry_Date__c = System.today() + 60;
        cntFace2.Scan_Type__c = 'POI';
        cntFace2.Image_Type__c = 'Face';
        cntFace2.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFace2.Similarity__c = 'MATCH';
        cntFace2.Document_Country__c = 'BH';
        insert cntFace2;
        
        Content__c cntFace3 = new Content__c();
        cntFace3.Person__c = acc.Id;
        cntFace3.Document_Type__c = 'Passport';
        cntFace3.Document_Expiry_Date__c = System.today() + 60;
        cntFace3.Scan_Type__c = 'POI';
        cntFace3.Image_Type__c = 'Face';
        cntFace3.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFace3.Similarity__c = 'MATCH';
        cntFace3.Document_Country__c = 'BH';
        insert cntFace3;
       
        Test.startTest();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.AccountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        cs1.Force_Generate_Wathiq_Consent_Form__c = true;
        insert cs1;
        
        cs1.Re_Process_Wathiq_Form__c = true;
        update cs1;
        
         //Need to comment the below line when we get Actual API Response
		FetcheKYCDocHashValueToReprocess.fakeBody = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
        //Setted a mock response in this method related to ID and V Hash Value Exception
        Test.setMock(HttpCalloutMock.class, new RestMockIDANDVHashResponse());
        Test.stopTest();
    }
    
    //////////////////////////////////////////// Start : Covering for Reprocess Wathiq Form for Wathiq Accepted & IDAndVHash not available - Documents Available Passport Form  ///////////////////////////////////////////////


}