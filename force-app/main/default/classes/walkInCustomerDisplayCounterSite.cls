public class walkInCustomerDisplayCounterSite {
    public Integer tokenNumber{get;set;}
    public Integer counterNumber{get;set;}
    id caseId;
    public walkInCustomerDisplayCounterSite(){
        System.debug('walkInCustomerDisplayCounterSite is Invoked');
        caseId = Apexpages.currentPage().getParameters().get('id');
        System.debug('-----> Case ID --> '+caseId);
        if(caseId != null){
            Case retreiveObjCase = [select id,Token_Counter__c,Counter_Number__c from Case where Id =:caseId];
        	tokenNumber = Integer.valueOf(retreiveObjCase.Token_Counter__c);
        	counterNumber = Integer.valueOf(retreiveObjCase.Counter_Number__c); 
        }
        
    }

}