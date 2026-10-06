/*      Organization : ABC Bank
*       Created By: Jayanth Manickam
*       Created Date: 21/09/2024
*       Change History: 
*/
@isTest
public class walkinCustomerErevealerCntrlTest {

    
    @isTest
    static void unitTest1(){
        Test.startTest();
        PageReference pageRef = Page.walkinCustomerErevealerVFPage;
        Test.setCurrentPage(pageRef);
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.Mobile_Country_Code__pc = '+973';
        acc.PersonMobilePhone = '6754645';
        insert acc;
        
        Case cs1 = new Case();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Walkin Customers').getRecordTypeId();
        cs1.RecordTypeId = recordTypeId;
        cs1.Type = 'Walkin Customer';
		cs1.SuppliedEmail = 'test2@ilatest.com';
        cs1.SuppliedPhone = '764547487';
        cs1.Sub_Type__c = 'IBAN Related';
        insert cs1;
        
        walkinCustomerErevealerController CE = New walkinCustomerErevealerController();
        CE.reqCase=cs1.CaseNumber;
        CE.saveRequest();
        Test.StopTest();
    }
    @isTest
    static void unitTest2(){
        Test.startTest();
         Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Integration', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName='uniqueUserName@ab.com');
        PageReference pageRef = Page.walkinCustomerErevealerVFPage;
        Test.setCurrentPage(pageRef);
        System.runAs(u) {
         Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.Mobile_Country_Code__pc = '+973';
        acc.PersonMobilePhone = '6754645';
        acc.subscription_Model__pc='ila';
        acc.CIF__pc='154545';
        insert acc;
        
        Case cs1 = new Case();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Walkin Customers').getRecordTypeId();
        cs1.RecordTypeId = recordTypeId;
        cs1.Type = 'Walkin Customer';
		cs1.SuppliedEmail = 'test2@ilatest.com';
        cs1.SuppliedPhone = '764547487';
        cs1.Sub_Type__c = 'IBAN Related';
        insert cs1;
            
        walkinCustomerErevealerController CE = New walkinCustomerErevealerController();
        CE.caseRec=cs1;
        CE.accRec=[Select Id, Name, CIF__pc,PersonMobilePhone,subscription_Model__pc From Account where Id=:acc.Id];
        CE.processRequest();
        }
        Test.StopTest();
    }
    @isTest
    static void unitTest3(){
        Test.startTest();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.Mobile_Country_Code__pc = '+973';
        acc.PersonMobilePhone = '6754645';
        acc.subscription_Model__pc='ila';
        acc.CIF__pc='154545';
        insert acc;
        
        Case cs1 = new Case();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Walkin Customers').getRecordTypeId();
        cs1.RecordTypeId = recordTypeId;
        cs1.Type = 'Walkin Customer';
		cs1.SuppliedEmail = 'test2@ilatest.com';
        cs1.SuppliedPhone = '764547487';
        cs1.Sub_Type__c = 'IBAN Related';
        insert cs1;

        Blob b = Blob.valueOf('Test Data');
    	Content__c cn = New Content__c ();
        cn.case__c=cs1.Id;
        insert cn;
    	Attachment attachment = new Attachment();
    	attachment.ParentId = cn.Id;
    	attachment.Name = 'Test Attachment for Parent';
    	attachment.Body = b;
    	
    	insert(attachment);
        PageReference pageRef = Page.walkinCustomerErevealerVFPage;
        Test.setCurrentPage(pageRef);
        walkinCustomerErevealerController CE = New walkinCustomerErevealerController();
        ApexPages.currentPage().getParameters().put('attachmentId',attachment.Id);
       // CE.cprattachmentId=attachment.Id;
        CE.customerSignature();
        Test.stopTest();
    }
    @isTest
    static void unitTest4(){
      
        Test.startTest();
        PageReference pageRef = Page.walkinCustomerErevealerVFPage;
        Test.setCurrentPage(pageRef);
        String url='data:image/png;base64,Test Data';
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.Mobile_Country_Code__pc = '+973';
        acc.PersonMobilePhone = '6754645';
        acc.subscription_Model__pc='ila';
        acc.CIF__pc='154545';
        insert acc;
        
        Case cs1 = new Case();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Walkin Customers').getRecordTypeId();
        cs1.RecordTypeId = recordTypeId;
        cs1.Type = 'Walkin Customer';
		cs1.SuppliedEmail = 'test2@ilatest.com';
        cs1.SuppliedPhone = '764547487';
        cs1.Sub_Type__c = 'IBAN Related';
        insert cs1;
        
       // walkinCustomerErevealerController CE = New walkinCustomerErevealerController();
        walkinCustomerErevealerController.GenerateImage(url,url,cs1.Id,url);
        Test.stopTest();
    }
    
    @isTest
    static void unitTest5(){
        Test.startTest();
        PageReference pageRef = Page.walkinCustomerErevealerVFPage;
        Test.setCurrentPage(pageRef);
        String url='data:image/png;base64,Test Data';
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.Mobile_Country_Code__pc = '+973';
        acc.PersonMobilePhone = '6754645';
        acc.subscription_Model__pc='ila';
        acc.CIF__pc='154545';
        insert acc;
        
        Case cs1 = new Case();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Walkin Customers').getRecordTypeId();
        cs1.RecordTypeId = recordTypeId;
        cs1.Type = 'Walkin Customer';
		cs1.SuppliedEmail = 'test2@ilatest.com';
        cs1.SuppliedPhone = '764547487';
        cs1.Sub_Type__c = 'IBAN Related';
        insert cs1;
        Blob b = Blob.valueOf('Test Data');
    	Content__c cn = New Content__c ();
        cn.case__c=cs1.Id;
        insert cn;
        
    	Attachment attachment = new Attachment();
    	attachment.ParentId = cn.Id;
    	attachment.Name = 'Test Attachment for Parent';
    	attachment.Body = b;
        insert(attachment);


        
        walkinCustomerErevealerController CE = New walkinCustomerErevealerController();
        ApexPages.currentPage().getParameters().put('caseId',cs1.Id);
        ApexPages.currentPage().getParameters().put('cresult',attachment.Id);
        ApexPages.currentPage().getParameters().put('bresult',attachment.Id);
        ApexPages.currentPage().getParameters().put('imgresult',attachment.Id);
        CE.GeneratePdf();
        Test.stopTest();
    }
}