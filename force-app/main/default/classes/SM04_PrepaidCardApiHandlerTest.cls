/**
 * @author Aniss Mbarki
 * @date Création 01/08/2022
 * @date Modification
 * 
 */
@isTest
public with sharing class SM04_PrepaidCardApiHandlerTest {
  
    @testSetup static void setupMethode() {
      

        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ppc_Prepaid_Card').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case( 
        Region_Flag__c='Bahrain',
        Case_Model__c = 'ila',
        ContactId = acc1.PersonContactId,
        AccountId = acc1.id,
        sc_Card_Holder_ID_Number__c = '123456',
        Type='Credit Card Prepaid Application',
        RecordTypeId = acRecordTypeId), 'TestFactoryDefaults.CaseDefaults',true);
        
        
    }
    //makerResult=Pending Documents
    @isTest
    public static void updateCreditCardReqApiFromFlowPendingDocumentsTest(){  
        List<SM04_PrepaidCardApiHandler.RequestPrepaidCard> reqPrepCardsList=new List<SM04_PrepaidCardApiHandler.RequestPrepaidCard>();
        SM04_PrepaidCardApiHandler.RequestPrepaidCard PrepCards=new SM04_PrepaidCardApiHandler.RequestPrepaidCard();
        Case caseObj=[SELECT Id FROM Case LIMIT 1];
        PrepCards.caseId=caseObj.Id;
        PrepCards.makerResult='Pending Documents';
        PrepCards.subStatus='Pending Documents'; 
        reqPrepCardsList.add(PrepCards);
        
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;
       List<String> response= SM04_PrepaidCardApiHandler.updateCreditCardReqApiFromFlow(reqPrepCardsList);
        test.stopTest();
    }
    //makerResult=Send to Pre-Screener
    @isTest
    public static void updateCreditCardReqApiFromFlowSendtoPreScreenerTest(){  
        List<SM04_PrepaidCardApiHandler.RequestPrepaidCard> reqPrepCardsList=new List<SM04_PrepaidCardApiHandler.RequestPrepaidCard>();
        SM04_PrepaidCardApiHandler.RequestPrepaidCard PrepCards=new SM04_PrepaidCardApiHandler.RequestPrepaidCard();
        Case caseObj=[SELECT Id FROM Case LIMIT 1];
        PrepCards.caseId=caseObj.Id;
        PrepCards.makerResult='Send to Pre-Screener';
        reqPrepCardsList.add(PrepCards);
        
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;
       List<String> response= SM04_PrepaidCardApiHandler.updateCreditCardReqApiFromFlow(reqPrepCardsList);
        test.stopTest();
    }
    //makerResult=Decline
    @isTest
    public static void updateCreditCardReqApiFromFlowDeclineTest(){  
        List<SM04_PrepaidCardApiHandler.RequestPrepaidCard> reqPrepCardsList=new List<SM04_PrepaidCardApiHandler.RequestPrepaidCard>();
        SM04_PrepaidCardApiHandler.RequestPrepaidCard PrepCards=new SM04_PrepaidCardApiHandler.RequestPrepaidCard();
        Case caseObj=[SELECT Id FROM Case LIMIT 1];
        PrepCards.caseId=caseObj.Id;
        PrepCards.makerResult='Decline';
       
        reqPrepCardsList.add(PrepCards);
        
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;
       List<String> response= SM04_PrepaidCardApiHandler.updateCreditCardReqApiFromFlow(reqPrepCardsList);
        test.stopTest();
    }

     //makerResult=Cancelled by Customer
    @isTest
    public static void updateCreditCardReqApiFromFlowCancelledbyCustomerTest(){  
        List<SM04_PrepaidCardApiHandler.RequestPrepaidCard> reqPrepCardsList=new List<SM04_PrepaidCardApiHandler.RequestPrepaidCard>();
        SM04_PrepaidCardApiHandler.RequestPrepaidCard PrepCards=new SM04_PrepaidCardApiHandler.RequestPrepaidCard();
        Case caseObj=[SELECT Id FROM Case LIMIT 1];
        PrepCards.caseId=caseObj.Id;
        PrepCards.makerResult='Cancelled by Customer';
        
        reqPrepCardsList.add(PrepCards);
        
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;
       List<String> response= SM04_PrepaidCardApiHandler.updateCreditCardReqApiFromFlow(reqPrepCardsList);
        test.stopTest();
    }
     //makerResult=Accept
    @isTest
    public static void updateCreditCardReqApiFromFlowPreResultAcceptNameScreeningTrueTest(){  
        List<SM04_PrepaidCardApiHandler.RequestPrepaidCard> reqPrepCardsList=new List<SM04_PrepaidCardApiHandler.RequestPrepaidCard>();
        SM04_PrepaidCardApiHandler.RequestPrepaidCard PrepCards=new SM04_PrepaidCardApiHandler.RequestPrepaidCard();
        Case caseObj=[SELECT Id FROM Case LIMIT 1];
        PrepCards.caseId=caseObj.Id;
        PrepCards.makerResult='Accept';
        reqPrepCardsList.add(PrepCards);
        
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        MCK001_ApiCalls.nameScreening = true;
       List<String> response= SM04_PrepaidCardApiHandler.updateCreditCardReqApiFromFlow(reqPrepCardsList);
        test.stopTest();
    }

    @isTest
    public static void updateCreditCardReqApiFromFlowPreResultAcceptNameScreeningFalseTest(){  
        List<SM04_PrepaidCardApiHandler.RequestPrepaidCard> reqPrepCardsList=new List<SM04_PrepaidCardApiHandler.RequestPrepaidCard>();
        SM04_PrepaidCardApiHandler.RequestPrepaidCard PrepCards=new SM04_PrepaidCardApiHandler.RequestPrepaidCard();
        Case caseObj=[SELECT Id FROM Case LIMIT 1];
        PrepCards.caseId=caseObj.Id;
        PrepCards.makerResult='Accept';
        reqPrepCardsList.add(PrepCards);
        
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        MCK001_ApiCalls.nameScreening = false;
       List<String> response= SM04_PrepaidCardApiHandler.updateCreditCardReqApiFromFlow(reqPrepCardsList);
        test.stopTest();
    }

    @isTest
    public static void updateCreditCardReqApiFromFlowPreResultAcceptNameScreeningError500Test(){  
        List<SM04_PrepaidCardApiHandler.RequestPrepaidCard> reqPrepCardsList=new List<SM04_PrepaidCardApiHandler.RequestPrepaidCard>();
        SM04_PrepaidCardApiHandler.RequestPrepaidCard PrepCards=new SM04_PrepaidCardApiHandler.RequestPrepaidCard();
        Case caseObj=[SELECT Id FROM Case LIMIT 1];
        PrepCards.caseId=caseObj.Id;
        PrepCards.makerResult='Accept';
        reqPrepCardsList.add(PrepCards);
        
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 500;
       List<String> response= SM04_PrepaidCardApiHandler.updateCreditCardReqApiFromFlow(reqPrepCardsList);
        test.stopTest();
    }

    @isTest
    public static void updateCreditCardReqApiFromFlowErrorTest(){  
        List<SM04_PrepaidCardApiHandler.RequestPrepaidCard> reqPrepCardsList=new List<SM04_PrepaidCardApiHandler.RequestPrepaidCard>();
        SM04_PrepaidCardApiHandler.RequestPrepaidCard PrepCards=new SM04_PrepaidCardApiHandler.RequestPrepaidCard();
        PrepCards.caseId='notValid';
        reqPrepCardsList.add(PrepCards);
        
        test.startTest();
        try {
            List<String> response= SM04_PrepaidCardApiHandler.updateCreditCardReqApiFromFlow(reqPrepCardsList);
            
        } catch (Exception e) {
            System.debug('good');
        }
        test.stopTest();
    }
    
    @isTest
    public static void updateCreditCardReqApiFromFlowQaAcceptTest(){  
        List<SM04_PrepaidCardApiHandler.RequestPrepaidCard> reqPrepCardsList=new List<SM04_PrepaidCardApiHandler.RequestPrepaidCard>();
        SM04_PrepaidCardApiHandler.RequestPrepaidCard PrepCards=new SM04_PrepaidCardApiHandler.RequestPrepaidCard();
        Case caseObj=[SELECT Id FROM Case LIMIT 1];
        PrepCards.caseId=caseObj.Id;
        PrepCards.qaResult='Accept';
        reqPrepCardsList.add(PrepCards);
        
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        List<String> response= SM04_PrepaidCardApiHandler.updateCreditCardReqApiFromFlow(reqPrepCardsList); 
        test.stopTest();
    }
    
    @isTest
    public static void updateCreditCardReqApiFromFlowQaPendingTest(){  
        List<SM04_PrepaidCardApiHandler.RequestPrepaidCard> reqPrepCardsList=new List<SM04_PrepaidCardApiHandler.RequestPrepaidCard>();
        SM04_PrepaidCardApiHandler.RequestPrepaidCard PrepCards=new SM04_PrepaidCardApiHandler.RequestPrepaidCard();
        Case caseObj=[SELECT Id FROM Case LIMIT 1];
        PrepCards.caseId=caseObj.Id;
        PrepCards.qaResult='Pending Documents';
        reqPrepCardsList.add(PrepCards);
        
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        List<String> response= SM04_PrepaidCardApiHandler.updateCreditCardReqApiFromFlow(reqPrepCardsList); 
        test.stopTest();
    }
    
    
    @isTest
    public static void updateCreditCardReqApiFromFlowQaDeclinedTest(){  
        List<SM04_PrepaidCardApiHandler.RequestPrepaidCard> reqPrepCardsList=new List<SM04_PrepaidCardApiHandler.RequestPrepaidCard>();
        SM04_PrepaidCardApiHandler.RequestPrepaidCard PrepCards=new SM04_PrepaidCardApiHandler.RequestPrepaidCard();
        Case caseObj=[SELECT Id FROM Case LIMIT 1];
        PrepCards.caseId=caseObj.Id;
        PrepCards.qaResult='Decline';
        reqPrepCardsList.add(PrepCards);
        
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        List<String> response= SM04_PrepaidCardApiHandler.updateCreditCardReqApiFromFlow(reqPrepCardsList); 
        test.stopTest();
    }
    
    
    @isTest
    public static void updateCreditCardReqApiFromFlowAcceptMyselfTest(){  
        List<SM04_PrepaidCardApiHandler.RequestPrepaidCard> reqPrepCardsList=new List<SM04_PrepaidCardApiHandler.RequestPrepaidCard>();
        SM04_PrepaidCardApiHandler.RequestPrepaidCard PrepCards=new SM04_PrepaidCardApiHandler.RequestPrepaidCard();
        Case caseObj=[SELECT Id FROM Case LIMIT 1];
        caseObj.sc_Relationship__c = 'Myself';
        update caseObj;
        PrepCards.caseId=caseObj.Id;
        PrepCards.makerResult='Accept';
        reqPrepCardsList.add(PrepCards);
        
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        MCK001_ApiCalls.nameScreening = true;
       List<String> response= SM04_PrepaidCardApiHandler.updateCreditCardReqApiFromFlow(reqPrepCardsList);
        test.stopTest();
    }

    @isTest
    public static void updateCreditCardReqApiFromFlowQaAcceptError500Test(){  
        List<SM04_PrepaidCardApiHandler.RequestPrepaidCard> reqPrepCardsList=new List<SM04_PrepaidCardApiHandler.RequestPrepaidCard>();
        SM04_PrepaidCardApiHandler.RequestPrepaidCard PrepCards=new SM04_PrepaidCardApiHandler.RequestPrepaidCard();
        Case caseObj=[SELECT Id FROM Case LIMIT 1];
        PrepCards.caseId=caseObj.Id;
        PrepCards.qaResult='Accept';
        reqPrepCardsList.add(PrepCards);
        
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 500;
       List<String> response= SM04_PrepaidCardApiHandler.updateCreditCardReqApiFromFlow(reqPrepCardsList);
        test.stopTest();
    }
}