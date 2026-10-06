public class StandardTabsAuditTrackController {
    
    @AuraEnabled
    public static String createAuditRecord(Id recordId, String tabName){
        Account acct = [select Id, CIF__pc, Name, PersonEmail, PersonMobilePhone, RecordTypeId, RecordType.Name, Mobile_Country_Code__pc,
                Segment__pc, Region_Flag__c,FirstName,LastName ,Subscription_Model__pc,Alburaq_Segment__pc from Account where Id = :recordId];
        
        Customer_Pages_Audit_Trail__c cusAudit = new Customer_Pages_Audit_Trail__c();
        cusAudit.Customer_CIF__c = acct.CIF__pc;
        cusAudit.User_Action__c = 'Viewed';
        if(tabName == 'Customer Details'){
          cusAudit.Page_Name__c = 'Customer Detail';  
        }
        else if(tabName == 'Ila Accounts'){
           cusAudit.Page_Name__c = 'Ila Bank Accounts List';   
        }
        else if(tabName == 'Alburaq Accounts'){
          cusAudit.Page_Name__c = 'Alburaq Bank Accounts List';     
        }
        else if(tabName == 'Case List'){
           cusAudit.Page_Name__c = 'Cases List'; 
        }
        else if(tabName == 'Documents List'){
           cusAudit.Page_Name__c = 'Documents List'; 
        }
        else if(tabName == 'Activity List'){
           cusAudit.Page_Name__c = 'Customer Activities List'; 
        }
        cusAudit.User__c = userInfo.getUserId();
        insert cusAudit;
        return cusAudit.id;
    }
    
     @AuraEnabled
    public static String createAuditRecordSubTabs(String accId, String subTabName){
        System.debug('Account Id:'+accId);
        System.debug('Sub Tab Name:'+subTabName);
        
        Account acct = [select Id, CIF__pc, Name, PersonEmail, PersonMobilePhone, RecordTypeId, RecordType.Name, Mobile_Country_Code__pc,
                Segment__pc, Region_Flag__c,FirstName,LastName ,Subscription_Model__pc,Alburaq_Segment__pc from Account where Id =: accId limit 1];
        System.debug('Account acc:'+acct);
        Customer_Pages_Audit_Trail__c cusAudit = new Customer_Pages_Audit_Trail__c();
        cusAudit.Customer_CIF__c = acct.CIF__pc;
        cusAudit.User_Action__c = 'Viewed';
        if(subTabName == 'Credit Card'){
            cusAudit.Page_Name__c = 'Credit Card List'; 
        }
        else if(subTabName == 'Fixed Deposits'){
            cusAudit.Page_Name__c = 'Fixed Deposits List';
        }
        else if(subTabName == 'Debit Cards'){
            cusAudit.Page_Name__c = 'Debit Cards List';
        }
        else if(subTabName == 'Saving Pots'){
            cusAudit.Page_Name__c = 'Saving Pots List';
        }
        else if(subTabName == 'Jamiyah Accounts'){
            cusAudit.Page_Name__c = 'Jamiyah Accounts List';
        }
        cusAudit.User__c = userInfo.getUserId();
        insert cusAudit;
        return cusAudit.id;
    }
    
    @AuraEnabled
    public static String createAuditRecordForContent(Id recordId, String tabName){
        Content__c ct = [select Id, Name, Person__r.CIF__pc,Document_Type__c,Image_Type__c from Content__c where Id = :recordId];
        
        Customer_Pages_Audit_Trail__c cusAudit = new Customer_Pages_Audit_Trail__c();
        cusAudit.Customer_CIF__c = ct.Person__r.CIF__pc;
        cusAudit.User_Action__c = 'Viewed';
        cusAudit.Content_Reference__c = ct.Name;
        cusAudit.Document_Type__c = ct.Document_Type__c;
        cusAudit.Attachment_Type__c = ct.Image_Type__c;
        cusAudit.User__c = userInfo.getUserId();
        cusAudit.Page_Name__c = 'Specific Document Detail';
        insert cusAudit;
        return cusAudit.id;
    }
    
     @AuraEnabled
    public static String createAuditRecordForCase(Id recordId, String tabName){
        Case cse = [select Id, CaseNumber, Type,Account.CIF__pc from Case where Id = :recordId];
        
        Customer_Pages_Audit_Trail__c cusAudit = new Customer_Pages_Audit_Trail__c();
        cusAudit.Customer_CIF__c = cse.Account.CIF__pc;
        cusAudit.User_Action__c = 'Viewed';
        cusAudit.Case_Number__c = cse.CaseNumber;
        cusAudit.Case_Type__c = cse.Type;
        cusAudit.User__c = userInfo.getUserId();
        cusAudit.Page_Name__c = 'Specific Case Detail';
        insert cusAudit;
        return cusAudit.id;
    }

}