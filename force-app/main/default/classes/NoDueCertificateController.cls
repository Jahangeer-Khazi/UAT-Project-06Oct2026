public class NoDueCertificateController {
    Public string startDate {get;set;}
    Public string iBAN {get;set;}
    Public string accountCurrency {get;set;}
    Public string accountId {get;set;}
    Public String MailingAddress {get;set;}
    
    
    public Account acc{get;set;}
    Public NoDueCertificateController(){
        startDate=ApexPages.currentPage().getParameters().get('startDate');
        iBAN=ApexPages.currentPage().getParameters().get('iBAN');
        accountCurrency=ApexPages.currentPage().getParameters().get('accountCurrency');
        accountId=ApexPages.currentPage().getParameters().get('accId');
        system.debug('account'+accountId);
        acc=[select id ,name,ID_Number__pc,PersonMailingStreet,PersonMailingCity,PersonMailingState,PersonMailingPostalCode,PersonMailingCountry,Address__c,Gender__pc from Account where id=:accountId ];
        
        system.debug(MailingAddress);
        system.debug(iBAN);
        system.debug(accountCurrency);        
			
    }
    
    
}