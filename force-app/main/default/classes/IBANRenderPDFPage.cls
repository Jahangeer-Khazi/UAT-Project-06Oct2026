public class IBANRenderPDFPage {
    Public string startDate {get;set;}
    Public string iBAN {get;set;}
    Public string accountCurrency {get;set;}
    Public string accountId {get;set;}
    Public String MailingAddress {get;set;}
    
    Public string caseId {get;set;}
    Public string caseModel {get;set;}
    Public string region {get;set;}
    
    public Account acc{get;set;}
    Public IBANRenderPDFPage(){
        startDate=ApexPages.currentPage().getParameters().get('startDate');
        iBAN=ApexPages.currentPage().getParameters().get('iBAN');
        accountCurrency=ApexPages.currentPage().getParameters().get('accountCurrency');
        accountId=ApexPages.currentPage().getParameters().get('accId');
        
        caseId=ApexPages.currentPage().getParameters().get('caseId');
        
        system.debug('account'+accountId);
        acc=[select id ,name,ID_Number__pc,PersonMailingStreet,PersonMailingCity,PersonMailingState,PersonMailingPostalCode,PersonMailingCountry,Address__c,Gender__pc from Account where id=:accountId ];
        
        if(caseId != null){
            Case caseObj = [SELECT Id,Case_Model__c,Region_flag__c FROM Case WHERE Id =:caseId ];   
            caseModel = caseObj.Case_Model__c;
            region=caseObj.Region_flag__c;
        }
        
        system.debug(MailingAddress);
        system.debug(iBAN);
        system.debug(accountCurrency);        
			
    }
    
    
}