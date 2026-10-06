/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 16-06-2023
 * @last modified by  : Elmustapha ELGARNI
 * Changes History    : CH01: 16/06/2023 Added by Imane Tsioucha 
 *                      CH02 => 03/02/2025 by  Elmustapha Elgarni : Add method to fetch customer record By CIF (used for https://bank-abc.atlassian.net/browse/NBA-13052)
**/
public class customerProductStatusCtrl {
  @AuraEnabled 
    public static Account  fetchCustomerDetail(String key){
        return [Select id,Salary_Transfer_Status__pc,Salary_Transfer_Transaction_Count__pc,name,RM_ID__pc,Collection_Case__c,Legal_Action__c,Loan_Collection_Case__c, Loan_Legal_Action__c,VVIP__pc,Subscription_Model__pc, AlKanz_Status__pc,USP_Message__pc, Region_Flag__pc,Has_Kanz_Account__pc, Has_Kanz_Balance__pc, Has_Kanz_Chance__pc,PLA_Eligibility__pc,Nationality__pc,RP_Expired_Since__pc, Alburaq_Segment__pc,Segment__pc,Blacklisted__c,Canceled_Work_Permit_Status__c,Use_Preferential_FD_Rate__pc
                From Account
                Where Id =:key];
    }

    // Start CH01: Add ID Download Button for Bahraini ID
      //// Commenting the method pre RM-2964 release
  /*  @AuraEnabled
    public static Account getAccount(String objectId) {
        Account acc = [SELECT Id, Name, Ila_Customer_Name__c FROM Account WHERE Id = :objectId];
        return acc;
        
    } 
   @AuraEnabled
    public static List<ContentVersion> getAccountDocuments(String objectId) {
        List<Id> documentsIdsList= new List<Id>();
        List<ContentDocumentLink> contentDocumentLink= new List<ContentDocumentLink>();
        Set<Id> documentId=new Set<Id>();
    
        List<Content__c >documentsList = [SELECT Id, Name,Document_Type__c, Image_Type__c,Validity__c FROM Content__c WHERE Person__c=:objectId AND Document_Type__c='Bahraini ID' AND ( Image_Type__c='Back' OR Image_Type__c='Front' ) AND Validity__c=true ];
        for(Content__c doc:documentsList  ){
            documentsIdsList.add(doc.Id);
        }
        for( ContentDocumentLink contDoc:[SELECT ContentDocument.Id, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId IN :documentsIdsList]){
            documentId.add(contDoc.ContentDocument.Id);
        }
         List<ContentVersion> Version =new List<ContentVersion>();
         Version=[SELECT Id from ContentVersion WHERE IsLatest=true AND ContentDocumentId IN:documentId ];
  
        System.debug('tessst'+contentDocumentLink);
        return Version;

    }*/
    // END CH01: Add ID Download Button for Bahraini ID
    
      //// Commenting the method pre RM-2964 release

    // Start CH02 : Add method to fetch customer record By CIF 
    @AuraEnabled 
    public static Account fetchCustomerDetailsByCIF(String cif) {
        List<Account> accounts = [SELECT Id, Collection_Case__c, Legal_Action__c, Loan_Collection_Case__c, Loan_Legal_Action__c, 
                                  Subscription_Model__pc, Region_Flag__pc, Alburaq_Segment__pc, Segment__pc, Blacklisted__c 
                                  FROM Account 
                                  WHERE CIF__pc = :cif 
                                  LIMIT 1];
        system.debug('Account List '+ accounts);
        return accounts.isEmpty() ? null : accounts[0];
    }
    // End  CH02 : Add method to fetch customer record By CIF
}