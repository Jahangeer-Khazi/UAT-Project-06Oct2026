public class LoanNoLiabilityController {

    public List<wrapCase> loanDetails{get; set;}
    public List<string> cardIds{get;set;}
    public String accountId {get;set;}
    public Account acc{get;set;}
    public String caseId {get;set;}
    public String gender {get;set;}
    public String caseNumber{get;set;}
    public Decimal legalFee{get;set;}
    
    public LoanNoLiabilityController(){
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
        List<Case> casedetails=[Select Id,Letter_Type__c, Case_Model__c, caseNumber,Total_Legal_Fee__c from Case where Id=:caseId];
        caseNumber=casedetails[0].caseNumber;
        system.debug('caseNumber==>'+caseNumber);
        
        legalFee=casedetails[0].Total_Legal_Fee__c;
        system.debug('legalFee==>'+legalFee);
        
        ApiConnection.Response getLoanOptions= new  ApiConnection.Response();
        if(casedetails[0].Letter_Type__c=='No Liability' || casedetails[0].Letter_Type__c=='Outstanding Balance')
        {
            
            getLoanOptions=Loans_ServiceManagerHandler.callLoansOptionsAPI(acc.CIF__pc, casedetails[0].Case_Model__c);
            system.debug('getLoanOptions .. '+getLoanOptions);
            
            if (getLoanOptions.isSuccess == true) {
                loanDetails = new List<wrapCase>();
                Map<String, Object> responseData = (Map<String, Object>) getLoanOptions.responseData;
                    
                if (responseData.containsKey('currentLoans')) {
                    List<Object> currentLoans = (List<Object>) responseData.get('currentLoans');
                    
                    for (Object loanObj : currentLoans) {
                        Map<String, Object> loanMap = (Map<String, Object>) loanObj;

                        String arrangementId = (String) loanMap.get('arrangementId');                  
                        System.debug('arrangementId for the loan : ' + arrangementId);
                        
                        String applicationId = (String) loanMap.get('applicationId'); 
                        System.debug('applicationId for the loan : ' + applicationId);
                        
                        String loanStartDate =  (String) loanMap.get('loanStartDate');
                        System.debug('loanStartDate for the loan : ' + loanStartDate);
                        
                        String productType =  (String) loanMap.get('productType');
                        System.debug('productType for the loan : ' + productType);
                        
                        Decimal loanOutstandingAmount = (Decimal) loanMap.get('loanOutstandingAmount');                  
                        System.debug('loanOutstandingAmount for the loan : ' + loanOutstandingAmount);
                        
                        Decimal principalLoanAmount = (Decimal) loanMap.get('principalLoanAmount');                  
                        System.debug('principalLoanAmount for the loan : ' + principalLoanAmount);

                        wrapCase w = new wrapCase(arrangementId, applicationId, loanStartDate, productType, loanOutstandingAmount, principalLoanAmount);
                        loanDetails.add(w);
                        System.debug('wrapper of loan >> '+loanDetails );
                    }
                } else {
                    System.debug('No loans found in the currentLoans list');
                }
            } else {
                System.debug('No currentLoans in the responseData');
            }
        } else {
            System.debug('API call was not successful. Error: ' + getLoanOptions.errorData);
        }
    }

    public class wrapCase {
        public String arrangementId {get;set;}
        public String applicationId {get;set;}
        public String loanStartDate {get;set;}
        public String productType {get;set;}
        public Decimal loanOutstandingAmount {get;set;}
        public Decimal principalLoanAmount {get;set;}
       
        public wrapCase(String arrangementId, String applicationId, String loanStartDate, String productType, Decimal loanOutstandingAmount, Decimal principalLoanAmount) {
            this.arrangementId = arrangementId;
            this.applicationId = applicationId;
            this.loanStartDate = loanStartDate;
            this.productType = productType;
            this.loanOutstandingAmount = loanOutstandingAmount.setScale(3);
            this.principalLoanAmount = principalLoanAmount.setScale(3);
        }
    }
}