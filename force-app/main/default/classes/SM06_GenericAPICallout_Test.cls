@isTest
public with sharing class SM06_GenericAPICallout_Test {
    
    @testSetup static void setupMethode() {
      
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card_Services').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case( 
        Region_Flag__c='Bahrain',
        Case_Model__c = 'ila',
        ContactId = acc1.PersonContactId,
        AccountId = acc1.id,
        Invitation_Expiry_Date__c = Date.newInstance(2026, 12, 9),
        Type='Credit Card Invitation',
        Sub_Type__c='World Elite Invitation',
        RecordTypeId = acRecordTypeId), 'TestFactoryDefaults.CaseDefaults',true);  
        
    }

    @isTest
    public static void apiCallout_TestSuccess(){  
        List<SM06_GenericAPICallout.RequestDetails> RequestDetailsList=new List<SM06_GenericAPICallout.RequestDetails>();
        SM06_GenericAPICallout.RequestDetails ReqDetails=new SM06_GenericAPICallout.RequestDetails();
        Case caseObj=[SELECT Id FROM Case LIMIT 1];
        ReqDetails.caseId=caseObj.Id;
        ReqDetails.Path='/credit-cards';
        ReqDetails.method='PUT'; 
        ReqDetails.json_header = '{ "userId": "elmustapha.elgarni@da-tech.ma" , "customerId": "5376353" , "Content-Type": "application/json"}';
        ReqDetails.json_body = '{ "productType": "World Elite", "status" : "ACCEPTED_BY_CUSTOMER", "expiryDate": "16-11-2023" }';
        ReqDetails.json_ActionsOnSuccess = '[{"fieldName": "Status","data_source": "value","value": "closed","data_path": "" },{"fieldName": "Awaiting_Customer_Feedback__c","data_source": "value","value": "","data_path": "" },{"fieldName": "Date_Awaiting_Customer_Feedback__c","data_source": "value","value": "","data_path": "" },{"fieldName": "sub_status__c","data_source": "value","value": "Accepted by Customer","data_path": "" }]';
        ReqDetails.json_ActionsOnFailure = '[{"fieldName": "cc_Contact_Centre_Result__c","data_source": "value","value": "","data_path": "" }]';
        RequestDetailsList.add(ReqDetails);
        
        test.startTest();
        SM06_GenericAPICallout.MockResponseStatusCode = 200;
        List<String> response= SM06_GenericAPICallout.apiCallout(RequestDetailsList);
        System.assert(response==null);
        test.stopTest();
    }

    @isTest
    public static void apiCallout_TestFailure(){  
        List<SM06_GenericAPICallout.RequestDetails> RequestDetailsList=new List<SM06_GenericAPICallout.RequestDetails>();
        SM06_GenericAPICallout.RequestDetails ReqDetails=new SM06_GenericAPICallout.RequestDetails();
        Case caseObj=[SELECT Id FROM Case LIMIT 1];
        ReqDetails.caseId=caseObj.Id;
        ReqDetails.Path='/credit-cards';
        ReqDetails.method='PUT'; 
        ReqDetails.json_header = '{ "userId": "elmustapha.elgarni@da-tech.ma" , "customerId": "5376353" , "Content-Type": "application/json"}';
        ReqDetails.json_body = '{ "productType": "World Elite", "status" : "ACCEPTED_BY_CUSTOMER", "expiryDate": "16-11-2023" }';
        ReqDetails.json_ActionsOnSuccess = '[{"fieldName": "Status","data_source": "value","value": "closed","data_path": "" },{"fieldName": "Awaiting_Customer_Feedback__c","data_source": "value","value": "","data_path": "" },{"fieldName": "Date_Awaiting_Customer_Feedback__c","data_source": "value","value": "","data_path": "" },{"fieldName": "sub_status__c","data_source": "value","value": "Accepted by Customer","data_path": "" }]';
        ReqDetails.json_ActionsOnFailure = '[{"fieldName": "cc_Contact_Centre_Result__c","data_source": "value","value": "","data_path": "" }]';
        RequestDetailsList.add(ReqDetails);
        
        test.startTest();
        SM06_GenericAPICallout.MockResponseStatusCode = 400;
        List<String> response= SM06_GenericAPICallout.apiCallout(RequestDetailsList);
        System.assert(response==null);
        test.stopTest();
    }

}