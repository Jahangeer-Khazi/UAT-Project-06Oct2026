/**
 * @description       : 
 * @author            : Elmustapha ELGARNI
 * @group             : 
 * @last modified on  : 06-20-2023
 * @last modified by  : Elmustapha ELGARNI
**/
@isTest
public with sharing class SM05_CreditCardApiHandlerTest {

    private static ApiConnection con = new ApiConnection();
    public class ExampleCalloutMock implements HttpCalloutMock {
        Integer statusCode;
        ExampleCalloutMock(Integer statusCode) {this.statusCode = statusCode;}
      
        public HTTPResponse respond(HTTPRequest req) {
          
          
          // Create a fake response
          HttpResponse res = new HttpResponse();
          res.setHeader('Content-Type', 'application/json');
          res.setBody('{"example":"test"}');
          res.setStatusCode(this.statusCode);  // use injected status code as response
          return res;
         }
        }



    @testSetup static void setupMethode() {
      

        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123496', Region_Flag__c='Jordan', Region_Flag__pc='Jordan'), 'TestFactoryDefaults.AccountDefaults',true);
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        Id staffRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card_Staff_Application').getRecordTypeId();
        
        Case caseObj = (Case)TestDataFactory.createSObject(new Case( 
        Region_Flag__c='Jordan',
        Case_Model__c = 'ila',
        ContactId = acc1.PersonContactId,
        AccountId = acc1.id,
        Type='Credit Card Application',
        cc_CPR_Number__c='Y6668',
        sc_Card_Holder_Jordan_ID_Number__c='12356789',
        cc_CPR_Expiry_Date__c= Date.newInstance(2026, 12, 9),
        cc_Passport_Number__c='Y6668',
        cc_Passport_Expiry_Date__c=Date.newInstance(2026, 12, 9),
        cc_Residence_Permit_No__c ='Y6668',
        cc_Residence_Permit_Expiry_Date__c=Date.newInstance(2026, 12, 9),
        RecordTypeId = acRecordTypeId), 'TestFactoryDefaults.CaseDefaults',false);
		
        insert caseObj;
        // Case caseObjStaff = (Case)TestDataFactory.createSObject(new Case( 
        // Region_Flag__c='Jordan',
        // Case_Model__c = 'ila',
        // ContactId = acc1.PersonContactId,
        // AccountId = acc1.id,
        // cc_CRM_Stage__c=null,
        // Type='Credit Card Application',
        // cc_CPR_Number__c='Y6668',
        // cc_CPR_Expiry_Date__c= Date.newInstance(2026, 12, 9),
        // cc_Passport_Number__c='Y6668',
        // cc_Passport_Expiry_Date__c=Date.newInstance(2026, 12, 9),
        // cc_Residence_Permit_No__c ='Y6668',
        // cc_Residence_Permit_Expiry_Date__c=Date.newInstance(2026, 12, 9),
        // RecordTypeId = StaffRecordTypeId), 'TestFactoryDefaults.CaseDefaults',true);
        
        
    }

    @isTest
    public static void updatePrescreenerResult_Test(){  
        List<SM05_CreditCardApiHandler.RequestCreditCard> reqCreditCardsList=new List<SM05_CreditCardApiHandler.RequestCreditCard>();
        SM05_CreditCardApiHandler.RequestCreditCard creditCards=new SM05_CreditCardApiHandler.RequestCreditCard();
        Case caseObj=[SELECT Id,Type,Region_Flag__c,cc_Credit_Pre_Screening_Result__c,RecordType_DeveloperName__c FROM Case LIMIT 1];
        
        test.startTest();

        MCK001_ApiCalls.statusCodeGlobal = 200;
        
        caseObj.cc_Credit_Pre_Screening_Result__c = 'Accept';
        update caseObj;
        
        test.stopTest();
        caseObj=[SELECT Id,Type,Region_Flag__c,cc_Credit_Pre_Screening_Result__c,RecordType_DeveloperName__c FROM Case LIMIT 1];

        System.assertequals(caseObj.cc_Credit_Pre_Screening_Result__c , 'Accept');
    }

    

    
    @isTest
    static void testUpdateCreditCardRequestStatusApi() {
        
        Case caseObj=[SELECT Id,Type,Region_Flag__c,Customer_CIF__c,cc_Name_on_the_Card__c,cc_Credit_Evaluation_Result__c,RecordType_DeveloperName__c, PrimaryCardProductConfigurationId__c ,
                        cc_Approved_Credit_Limit__c, cc_Requested_Credit_Limit__c, cc_Approved_Balance_Transfer_Amount__c, cc_Balance_Transfer_Amount__c, AccountId
                        FROM Case LIMIT 1];
        
        HttpRequest request = con.createRequest('PUT', System.Label.CC_EndPointCreditCardRequest,'Bahrain');
        request.setTimeout(60000);

        // Set up the expected mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(404);
        mockResponse.setBody('{"response": "Not found"}');
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock(404));

        // Call the method being tested
        HttpResponse response = SM05_CreditCardApiHandler.updateCreditCardRequestStatusApi(request, caseObj, 'APPROVED', 'no');

       
    }

    @isTest
    static void updateCreditCardReqApiFutureMeth_Test(){
        
        List<SM05_CreditCardApiHandler.RequestCreditCard> reqCreditCardsList=new List<SM05_CreditCardApiHandler.RequestCreditCard>();
        SM05_CreditCardApiHandler.RequestCreditCard creditCards=new SM05_CreditCardApiHandler.RequestCreditCard();
        Case caseObj=[SELECT Id,Type,Region_Flag__c,cc_Credit_Pre_Screening_Result__c,RecordType_DeveloperName__c FROM Case LIMIT 1];
        caseObj.cc_Credit_Pre_Screening_Result__c = 'Re-Upload Document';
        update caseObj;

        test.startTest();
        
        Map<String,String> details = new Map<String,String>();
        details.put('isNew','no');
        details.put('changedField','cc_Credit_Pre_Screening_Result__c');
        
        SM05_CreditCardApiHandler.updateCreditCardReqApiFutureMeth(new Set<Id>{caseObj.Id},details);

        SM05_CreditCardApiHandler.updateCreditCardRequestStatusApi_StatusCode= 401;
        SM05_CreditCardApiHandler.updateCreditCardReqApiFutureMeth(new Set<Id>{caseObj.Id},details);

        

        test.stopTest();

        caseObj=[SELECT Id,Type,Region_Flag__c,cc_Credit_Pre_Screening_Result__c,RecordType_DeveloperName__c FROM Case LIMIT 1];
        //System.assertequals(caseObj.cc_Credit_Pre_Screening_Result__c , 'Accept');

        
    }

    @isTest
    static void updateCreditCardReqApiFutureMeth_Test2(){
        
        List<SM05_CreditCardApiHandler.RequestCreditCard> reqCreditCardsList=new List<SM05_CreditCardApiHandler.RequestCreditCard>();
        SM05_CreditCardApiHandler.RequestCreditCard creditCards=new SM05_CreditCardApiHandler.RequestCreditCard();
        
        List<Case> cases = new List<Case>();
        
        String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
        
        String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc FROM Case LIMIT 1';
        cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        

        Case caseObj= cases[0];
        caseObj.cc_Credit_Pre_Screening_Result__c = 'Accept';
        update caseObj;
        
        test.startTest();
        
        Map<String,String> details = new Map<String,String>();
        details.put('isNew','yes');
        details.put('changedField','cc_Credit_Pre_Screening_Result__c');
        
        SM05_CreditCardApiHandler.updateCreditCardReqApiFutureMeth(new Set<Id>{caseObj.Id},details);
        SM05_CreditCardApiHandler.getCardProductConfiId_IncludeOtherProductsEqualTrue(caseObj);

        // SM05_CreditCardApiHandler.updateCreditCardRequestStatusApi_StatusCode= 401;
        // SM05_CreditCardApiHandler.updateCreditCardReqApiFutureMeth(new Set<Id>{caseObj.Id},details);

        test.stopTest();

        // caseObj=[SELECT Id,Type,Region_Flag__c,cc_Credit_Pre_Screening_Result__c,RecordType_DeveloperName__c FROM Case LIMIT 1];
        //System.assertequals(caseObj.cc_Credit_Pre_Screening_Result__c , 'Accept');

        
    }

    @isTest
    static void evaluatecriteriaFunction_Test(){
        
        
        List<Case> cases = new List<Case>();
        String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
        String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc FROM Case LIMIT 1';
        cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        
        Case caseObj= cases[0];
        caseObj.cc_Credit_Pre_Screening_Result__c = 'Accept';
        update caseObj;
        
        test.startTest();
        
        Boolean bool = SM05_CreditCardApiHandler.evaluateCriteria(caseObj, 'cc_Credit_Pre_Screening_Result__c;==;Accept');
        Boolean bool2 = SM05_CreditCardApiHandler.evaluateCriteria(caseObj, 'cc_Credit_Pre_Screening_Result__c;!=;Accept');

        test.stopTest();
        System.assertequals( true , bool);
        System.assertequals( false , bool2);
    }

    @isTest
    static void sendEmailAlert_Test(){
        
        
        List<Case> cases = new List<Case>();
        String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
        String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc FROM Case LIMIT 1';
        cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        
        Case caseObj= cases[0];
        caseObj.cc_Credit_Pre_Screening_Result__c = 'Accept';
        update caseObj;
        
        test.startTest();
        SM05_CreditCardApiHandler.sendEmailAlert(caseObj, 'CC_UPLOAD_SALARY_TRANSFER_UNDERTAKING_JO');
        test.stopTest();
    }

    @isTest
    static void updateCreditCardReqApiFutureMeth_Test3(){
        
        
        List<Case> cases = new List<Case>();
        String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
        String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc FROM Case LIMIT 1';
        cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        
        Case caseObj= cases[0];
        caseObj.cc_Credit_Pre_Screening_Result__c = 'Discrepancy in documents';
        update caseObj;
        
        test.startTest();
        
        Map<String,String> details = new Map<String,String>();
        details.put('isNew','yes');
        details.put('changedField','cc_Credit_Pre_Screening_Result__c');
        
        SM05_CreditCardApiHandler.updateCreditCardReqApiFutureMeth(new Set<Id>{caseObj.Id},details);
        SM05_CreditCardApiHandler.getCardProductConfiId_IncludeOtherProductsEqualTrue_StatusCode = 400;
        SM05_CreditCardApiHandler.getCardProductConfiId_IncludeOtherProductsEqualTrue(caseObj);

        test.stopTest();

        
    }

    
    @isTest
    static void testUpdateCreditCardReqApiFromFlow() {
        Case caseObj=[SELECT Id FROM Case LIMIT 1];
        system.debug('caseObj debug ==> '+ caseObj);
        
        SM05_CreditCardApiHandler.RequestCreditCard testRequest = new SM05_CreditCardApiHandler.RequestCreditCard();
        testRequest.caseId = caseObj.Id;
        testRequest.isNew = 'yes';
        testRequest.changedField = 'cc_Credit_Business_Team_L2_Result__c';
        
 
        List<SM05_CreditCardApiHandler.RequestCreditCard> testRequestList = new List<SM05_CreditCardApiHandler.RequestCreditCard>();
        testRequestList.add(testRequest);
        Test.startTest();
        List<String> result = SM05_CreditCardApiHandler.updateCreditCardReqApiFromFlow(testRequestList);
        Test.stopTest();
  
  
    }
    
    
	@isTest
    static void Test1(){
        
        List<SM05_CreditCardApiHandler.RequestCreditCard> reqCreditCardsList=new List<SM05_CreditCardApiHandler.RequestCreditCard>();
        SM05_CreditCardApiHandler.RequestCreditCard creditCards=new SM05_CreditCardApiHandler.RequestCreditCard();
        Case caseObj=[SELECT Id,Type,Region_Flag__c,cc_Credit_Pre_Screening_Result__c,RecordType_DeveloperName__c FROM Case LIMIT 1];
        caseObj.cc_Credit_Pre_Screening_Result__c = 'Re-Upload Document';
        update caseObj;

        test.startTest();
        
        Map<String,String> details = new Map<String,String>();
        details.put('isNew','no');
        details.put('changedField','cc_Credit_Pre_Screening_Result__c');
        
        SM05_CreditCardApiHandler.updateCreditCardReqApiFutureMeth(new Set<Id>{caseObj.Id},details);

        SM05_CreditCardApiHandler.updateCreditCardRequestStatusApi_StatusCode= 400;
        SM05_CreditCardApiHandler.updateCreditCardReqApiFutureMeth(new Set<Id>{caseObj.Id},details);
        
        SM05_CreditCardApiHandler.updateCreditCardRequestStatusApi_StatusCode= 200;
        SM05_CreditCardApiHandler.updateCreditCardReqApiFutureMeth(new Set<Id>{caseObj.Id},details);

        test.stopTest();

        caseObj=[SELECT Id,Type,Region_Flag__c,cc_Credit_Pre_Screening_Result__c,RecordType_DeveloperName__c FROM Case LIMIT 1];
        //System.assertequals(caseObj.cc_Credit_Pre_Screening_Result__c , 'Accept');

        
    }    
    
    @isTest
    static void Test2_Exception(){
        
        Case caseObj=[SELECT Id FROM Case LIMIT 1];
        system.debug('caseObj debug ==> '+ caseObj);
        
        SM05_CreditCardApiHandler.RequestCreditCard testRequest = new SM05_CreditCardApiHandler.RequestCreditCard();
        testRequest.caseId = caseObj.Id;
        testRequest.isNew = 'yes';
        testRequest.changedField = 'cc_Credit_Business_Team_L2_Result__c';
        SM05_CreditCardApiHandler.throwException_1= true;
        
 
        List<SM05_CreditCardApiHandler.RequestCreditCard> testRequestList = new List<SM05_CreditCardApiHandler.RequestCreditCard>();
        testRequestList.add(testRequest);
        Test.startTest();
        List<String> result = SM05_CreditCardApiHandler.updateCreditCardReqApiFromFlow(testRequestList);
        Test.stopTest();

        
    }    
    
   
	@isTest
    static void Test3_Exception(){
        
        Case caseObj=[SELECT Id FROM Case LIMIT 1];
        system.debug('caseObj debug ==> '+ caseObj);
        
        SM05_CreditCardApiHandler.RequestCreditCard testRequest = new SM05_CreditCardApiHandler.RequestCreditCard();
        testRequest.caseId = caseObj.Id;
        testRequest.isNew = 'yes';
        testRequest.changedField = 'cc_Credit_Business_Team_L2_Result__c';
        SM05_CreditCardApiHandler.throwException_2= true;
        
 
        List<SM05_CreditCardApiHandler.RequestCreditCard> testRequestList = new List<SM05_CreditCardApiHandler.RequestCreditCard>();
        testRequestList.add(testRequest);
        Test.startTest();
        List<String> result = SM05_CreditCardApiHandler.updateCreditCardReqApiFromFlow(testRequestList);
        Test.stopTest();

        
    }    

    @isTest
    static void Test4_Suppl(){
        
        List<Case> cases = new List<Case>();
        String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
        String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,(SELECT Id,Status__c FROM Supplementary_Cards__r) FROM Case LIMIT 1';
        cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            SM05_CreditCardApiHandler.nameScreeningProcess(cases.get(0),'Sub_Status__c');
            SM05_CreditCardApiHandler.callApiToCreateSupplementaryCardInVPlus(cases.get(0),'Sub_Status__c');
            SM05_CreditCardApiHandler.getCardProductConfigurationId_SupplementaryCase(cases.get(0));
        Test.stopTest();

        
    }

}