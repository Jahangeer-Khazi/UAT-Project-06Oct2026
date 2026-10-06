public class NoLiabilityController {

    public List<wrapCase> cardDetails{get; set;}
    public List<string> cardIds{get;set;}
    Public string accountId {get;set;}
    public Account acc{get;set;}
    Public string caseId {get;set;}
    Public string gender {get;set;}
    public String caseNumber{get;set;}
    public Decimal legalFee{get;set;}
    Public NoLiabilityController(){
        accountId=ApexPages.currentPage().getParameters().get('accId');
        acc=[select id ,name,Gender__pc,ID_Number__pc,CIF__pc,PersonMailingStreet,PersonMailingCity,PersonMailingState,PersonMailingPostalCode,PersonMailingCountry from Account where id=:accountId];
        if(acc.Gender__pc=='M')
        {
            gender='Mr';
        }
        else
        {
           gender= 'Ms';
        }
        caseId=ApexPages.currentPage().getParameters().get('csId');
        system.debug('caseId==>'+caseId);
    	List<Case> casedetails=[Select Id,Letter_Type__c,caseNumber,Total_Legal_Fee__c from Case where Id=:caseId];
        caseNumber=casedetails[0].caseNumber;
        legalFee=casedetails[0].Total_Legal_Fee__c;
        Map<String,String> getCardOptions= new Map<String,String>();
        if(casedetails[0].Letter_Type__c=='Outstanding Balance')
        {
            getCardOptions=CreditCollectionLettersController.getCardOptions(acc.Id,'D');
        }
        if(casedetails[0].Letter_Type__c=='No Liability')
        {
            getCardOptions=CreditCollectionLettersController.getCardOptions(acc.Id,'C');
        }
		if(getCardOptions.size()>0)
        {
       cardDetails= new List<wrapCase>();
        for(String card:getCardOptions.keySet())
        {
            string cardpciNumber=card.substringBefore('&');
            string cards=card.substringAfter('&');
            string cardissueDate=cards.substringBefore('&');
            cards=cards.substringAfter('&');
            string creditcardId=cards.substringBefore('&');
            Map<String,String> loadCardDetails=CreditCollectionLettersController.loadCardDetails(acc.Id, creditcardId);
            List<string> cardlimit =new List<string> (loadCardDetails.keySet());
            string credicardLimit=cardlimit[0];
            string cardoutstandingBalance=loadCardDetails.get(cardlimit[0]);
            string cardcancellationDate=cards.substringAfter('&');
            if(creditcardId!=null)
            {
            
            //CH01 : aniss add - 21/07/2022
            Date DatecardissueDate;
            if(cardissueDate != null && cardissueDate != 'null'){
                DatecardissueDate = Date.valueof(cardissueDate);
            }
            wrapCase w = new wrapCase(creditcardId,getCardOptions.get(card),credicardLimit,cardpciNumber,cardoutstandingBalance,DatecardissueDate,'9',cardcancellationDate);
            //CH01 : end
            cardDetails.add(w);
            }
           
        }
        system.debug('cardDetails==>'+cardDetails);
        }
    }
    
     // wrapper/container class 
    public class wrapCase {
        public String cardId {get;set;}
        public String displayName {get;set;}
        public String cardLimit {get;set;}
        public String pciNumber {get;set;}
        public String outstandingBalance {get;set;}
        public Date issueDate {get;set;}
        public String letterType {get;set;}
        public String cancellationDate {get;set;}
        //Constructor method 
        public wrapCase(String cardId,String displayName,String cardLimit,String pciNumber,String outstandingBalance,Date issueDate,String letterType,string cancellationDate) {
            this.cardId=cardId;
            this.displayName = displayName;
            this.cardLimit = cardLimit;
            this.pciNumber=pciNumber;
            this.outstandingBalance=outstandingBalance;
            this.issueDate=issueDate;
            this.letterType=letterType;
            this.cancellationDate=cancellationDate;
        }
    }

}