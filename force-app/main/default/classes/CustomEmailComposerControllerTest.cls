/********************************************************************************************
* @name                 CustomEmailComposerControllerTest
* @description          Test class for CustomEmailComposerController.
* @date                 08/03/2026
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           08/03/2026     Initial Version
*********************************************************************************************
*/

@isTest
public class CustomEmailComposerControllerTest {

    @isTest
    static void testSendEmailToJordan(){
        Account accObj = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Jordan_Loan__c obj = new Jordan_Loan__c();
        obj.CIF__c = '123456';
        obj.Origin__c = 'App';
        obj.Subject__c = 'Test RLOS Inquiry';
        obj.Requested_Product__c = 'Secured';
        obj.Requested_Amount__c = 1;
        obj.Requested_Term__c = 1;
        obj.RLOS_Application_Ref__c = '000-012345-PQR-001-0';
        insert obj;
        
        //Sending an email.
        CustomEmailComposerController.sendEmail('test@toaddress.com','test@ccaddress.com','testingsubject','this is a testing body',obj.Id);
        
        Map<String,Object> jordanMap = CustomEmailComposerController.getJordanCase(obj.Id);
        System.assert(!jordanMap.isEmpty());
        
        
        //Updating Jordan Queue Owner
        String res = CustomEmailComposerController.updateQueueOwner(obj.Id,'Jordan Loans Queue');
        System.assert(res != '');
        
        String res2 = CustomEmailComposerController.updateQueueOwner(obj.Id,'Backoffice');
        System.assert(res2 != '');
    }
    
    @isTest
    static void testGetHTMLTemplate(){
    	String htmlTemplate = CustomEmailComposerController.getHtmlTemplate();
        System.debug('htmlTemplate ' + htmlTemplate);
    }
    
}