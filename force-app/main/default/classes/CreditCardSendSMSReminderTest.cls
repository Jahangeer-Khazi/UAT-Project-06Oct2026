/**
 * @description       : This class is the test class related to CreditCardSendSMSReminder.cls
 * @author            : Aniss Mbarki |23/05/2023
**/

@isTest
public class CreditCardSendSMSReminderTest {

    @testSetup static void setupMethode() {
      
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case( 
        Region_Flag__c='Bahrain',
        Case_Model__c = 'ila',
        ContactId = acc1.PersonContactId,
        AccountId = acc1.id,
        Type='Credit Card Application',
        RecordTypeId = acRecordTypeId), 'TestFactoryDefaults.CaseDefaults',true);
    }

    @isTest
    public static void sendReminderTest(){  
        Case caseObj=[SELECT Id FROM Case LIMIT 1];
        
        test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            CreditCardSendSMSReminder.cc_SendSMSReminderFromFlow(new List<Id>{caseObj.Id});
        test.stopTest();
    }

    @isTest
    public static void cc_SendSMSReminderApiTest(){  
        List<Case> cases = new List<Case>();
        String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
        String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc FROM Case LIMIT 1';
        cases = new List<Case>((List<Case>)Database.query(soqlQuery));

        Case caseObj = cases.get(0);

        ApiConnection con = new ApiConnection();
        HttpRequest request = con.createRequest('POST','/api/v1/notifications?',caseObj.Region_Flag__c);
        test.startTest();

            //senario 1 :
            caseObj.Type = 'Credit Card Application';
            caseObj.cc_SMS_Sent_Flag__c = true;
            caseObj.cc_signature_sms_sent_flag__c = false;
            CreditCardSendSMSReminder.cc_SendSMSReminderApi(request,caseObj);

            //senario 2 :
            caseObj.Type = 'Credit Card Application';
            caseObj.cc_SMS_Sent_Flag__c = false;
            caseObj.cc_signature_sms_sent_flag__c = true;
            CreditCardSendSMSReminder.cc_SendSMSReminderApi(request,caseObj);

            //senario 3 :
            caseObj.Type = 'Credit Limit Increase Application';
            caseObj.cc_SMS_Sent_Flag__c = true;
            caseObj.cc_signature_sms_sent_flag__c = false;
            CreditCardSendSMSReminder.cc_SendSMSReminderApi(request,caseObj);

            //senario 4 :
            caseObj.Type = 'Credit Limit Increase Application';
            caseObj.cc_SMS_Sent_Flag__c = false;
            caseObj.cc_signature_sms_sent_flag__c = true;
            CreditCardSendSMSReminder.cc_SendSMSReminderApi(request,caseObj);
        test.stopTest();
    }

}