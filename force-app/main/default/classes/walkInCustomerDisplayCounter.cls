public class walkInCustomerDisplayCounter {
    public Integer tokenNumber{get;set;}
    public Integer counterNumber{get;set;}
    id caseId;
    public walkInCustomerDisplayCounter(){
        System.debug('walkInCustomerDisplayCounter is Invoked');
        caseId = Apexpages.currentPage().getParameters().get('id');
        System.debug('-----> Case ID --> '+caseId);
        Case retreiveObjCase = [select id,Token_Counter__c,Counter_Number__c from Case where Id =:caseId];
        tokenNumber = Integer.valueOf(retreiveObjCase.Token_Counter__c);
        counterNumber = Integer.valueOf(retreiveObjCase.Counter_Number__c);
    }
    public PageReference redirectToSiteURL(){
        System.debug('Action Method Called');
        System.debug('-----> Case ID in Redirect URL --> '+caseId);
        PageReference pr;
        pr = new PageReference('https://ilabank--uatx.sandbox.my.salesforce-sites.com/WalkinDisplayMonitor?id='+caseId);
        System.debug('Page Reference is:'+pr);
        pr.setRedirect(true);
        //pr.getParameters().put('id',caseId);
        return pr;
    }
    
}