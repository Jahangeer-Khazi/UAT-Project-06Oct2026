/********************************************************************************************
* @name                 OutstandingBalanceLetterController
* @description          This controller is responsible to render Outstanding Balance / No Due Letter
* @date                 10/09/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           10/09/2025     Initial Version
*********************************************************************************************
*/

public class OutstandingBalanceLetterController {

    public String accountId { get; set; }
    public String caseId { get; set; }
    public String formattedCCTotalOutstanding { get; set; } //currency formatting with 3 decimal points.
    public String formattedLoanTotalOutstanding { get; set; } //currency formatting with 3 decimal points.
    public String formattedGrandTotalOutstanding { get; set; } //currency formatting with 3 decimal points.
    public String formattedLegalFee { get; set; } //currency formatting with 3 decimal points.
    public String gender { get; set; }
    public Decimal cc_totalOutstanding { get; set; }
    public Decimal loan_totalOutstanding { get; set; }
    
    public Date caseDate { get; set; }
    public Date letterDate { get; set; }
    
    public Case caseObj { get; set; }
    public Account accountObj { get; set; }
    
    String productName { get; set; }
    
    public Boolean isLoansFinanceOnly { get; set; }
    public Boolean isAlburaq { get; set; }
    public Boolean isCreditCardOnly { get; set; }
    public Boolean isLoansAndCardOnly { get; set; }
    public Boolean isAllDueClear { get; set; }
    public Boolean isAlburaqModel { get; set; }
    
    public OutstandingBalanceWrapper obWrapper { get; set; }
    
    private static ApiConnection con = new ApiConnection();
    
    public OutstandingBalanceLetterController(){
        //Fetching account id and case id from page parameters
        accountId = ApexPages.currentPage().getParameters().get('accId');
        caseId = ApexPages.currentPage().getParameters().get('csId');
        
        isLoansFinanceOnly = false;
        isAlburaq = false;
        isCreditCardOnly = false;
        isLoansAndCardOnly = false;
        isAlburaqModel = false;
        
        caseDate = System.today();
        
        cc_totalOutstanding = 0;
        loan_totalOutstanding = 0;
        
        obWrapper = new OutstandingBalanceWrapper();
        obWrapper.cardWrapperList = new List<OutstandingBalanceWrapper.CreditCardWrapper>();
        obWrapper.ilaLoanWrapperList = new List<OutstandingBalanceWrapper.LoanWrapper>();
        obWrapper.alburaqLoanWrapperList = new List<OutstandingBalanceWrapper.LoanWrapper>();
        
        if(!String.isEmpty(caseId)){
            caseObj = [Select Id,CaseNumber,Total_Legal_Fee__c,cc_ID_Number__c,ac_Iban__c,
                       Case_Nature__c,cc_Checker_Result_Date_Time__c,CreatedDate 
                       FROM Case WHERE Id =: caseId];
            
            if(caseObj.Total_Legal_Fee__c == null){
               caseObj.Total_Legal_Fee__c = 0; 
            }
            if(caseObj.Case_Nature__c == 'FCR'){
                letterDate = caseObj.CreatedDate.date(); 
            }else{
                if(caseObj.cc_Checker_Result_Date_Time__c != null){
                    letterDate = caseObj.cc_Checker_Result_Date_Time__c.date(); 
                }else{
                    letterDate = System.today();
                }
            }
        }
        
        if(!String.isEmpty(accountId)){
            accountObj = [Select Id,Name,CIF__pc,Subscription_Model__pc,PersonEmail,Region_Flag__c,ID_Number__pc,Gender__pc 
                                  FROM Account WHERE id=:accountId];
            
            if(accountObj.Gender__pc == 'M'){
                gender = 'Mr';
            }
            else {
                gender = 'Ms';
            }
            
            getCustomerCardDetails();
            getCustomerLoanDetails();
        }
        
        //setting credit card balance to 0 if it is negative
        if(cc_totalOutstanding < 0){
            cc_totalOutstanding = 0;
        }
        
        formattedCCTotalOutstanding = getFormattedCurrency(cc_totalOutstanding);
        formattedLoanTotalOutstanding = getFormattedCurrency(loan_totalOutstanding);
        formattedLegalFee = getFormattedCurrency(caseObj.Total_Legal_Fee__c);
        formattedGrandTotalOutstanding = getFormattedCurrency(cc_totalOutstanding + loan_totalOutstanding + caseObj.Total_Legal_Fee__c);
        
        
        if(obWrapper.cardWrapperList.isEmpty()){
            if(!obWrapper.ilaLoanWrapperList.isEmpty() && !obWrapper.alburaqLoanWrapperList.isEmpty()){
                //show ila_loan_only
                isLoansFinanceOnly = true;
            }
            else if(!obWrapper.alburaqLoanWrapperList.isEmpty()){
                //show alburaq
                isAlburaq = true;
            }
            else {
                //ila_loan_only
                isLoansFinanceOnly = true;
            }
        }
        else {
            if(obWrapper.ilaLoanWrapperList.isEmpty() && obWrapper.alburaqLoanWrapperList.isEmpty()){
                //ila card only
                isCreditCardOnly = true;
            }
            else {
                //ila lona finance & card
                isLoansAndCardOnly = true;
            }
        }
        
        
        if(accountObj.Subscription_Model__pc == 'alburaq' || accountObj.Subscription_Model__pc == 'both'){
            isAlburaqModel = true;    
        }
        
        //checking no due
        if(obWrapper.cardWrapperList.isEmpty() && 
           obWrapper.ilaLoanWrapperList.isEmpty() && 
           obWrapper.alburaqLoanWrapperList.isEmpty()){
            isAllDueClear = true;
        }
        else {
            isAllDueClear = false;
        }
    }

    /**
     * @description : This method would fetch the customer credit card details from the api, Api would return 'currentLoans'.
     * We would be considering only those card which has isPrimary = true, cardNature <> 'prepaid'
     * @return : void
     */ 
    public void getCustomerCardDetails(){
        List<Map<String,Object>> retriveCardOption =  new List<Map<String,Object>>();
        String filerOption = 'D'; //D is for Outstanding balance / No due Letter 
        
        ApiConnection.Response response = SM001_ApiCalls.getCreditCardStatusApi(con, accountObj.PersonEmail,accountObj.CIF__pc,filerOption,accountObj.Region_Flag__c);
        
        Map<String, Object> responseData = (Map<String, Object>)response.responseData;
        List<Object> currCardsList = new List<Object>();
        
        for(String key :responseData.keyset()){
            System.debug('response data key "' + key + '" = ' + responseData.get(key));
        }
        
        if(responseData != null && responseData.containsKey('currentCards')){
            System.debug('card responseData ' + responseData.get('currentCards'));
            currCardsList = (List<Object>)responseData.get('currentCards');
        }
        
        List<Map<String, Object>> lstcardMap = new List<Map<String, Object>> ();
        for(Object curCards : currCardsList){
            lstcardMap.add((Map<String, Object>)curCards);
            Map<String, Object> mapRelatedCurrentCards = (Map<String, Object>)curCards;
            
            if(mapRelatedCurrentCards.get('isPrimary') == true && !((String)mapRelatedCurrentCards.get('cardNature')).equalsIgnoreCase('prepaid')){
                retriveCardOption.add(mapRelatedCurrentCards);
            }
        }
        
        for( Map<String,Object> card : retriveCardOption){
            string creditcardId = (String)card.get('id');
            Map<String,Object> additionalCardDetailsMap = getCustomerAdditionalCardDetails(creditcardId);
            if(!additionalCardDetailsMap.isEmpty()){
                
                Decimal cardoutstandingBalance = (Decimal)additionalCardDetailsMap.get('usedCreditLimit');
                
                cc_totalOutstanding = cc_totalOutstanding + cardoutstandingBalance;
                
                OutstandingBalanceWrapper.CreditCardWrapper cardWrapper = new OutstandingBalanceWrapper.CreditCardWrapper();
                cardWrapper.cardNumber = (String)card.get('maskedCardNumber');
                cardWrapper.cardType = (String)card.get('cardDisplayName');
                cardWrapper.creditLimit = (Decimal)additionalCardDetailsMap.get('creditLimit');
                cardWrapper.outstandingBalance = cardoutstandingBalance;
                cardWrapper.formattedCreditLimit = getFormattedCurrency(cardWrapper.creditLimit);
                cardWrapper.formattedOutstandingBalance = getFormattedCurrency(cardoutstandingBalance);
                obWrapper.cardWrapperList.add(cardWrapper);
            }
        }
    }   
    
    /**
     * @description : This method would fetch the addition card details
     * @param : cardId
     * @return : Map<String,Object>
     */
    public Map<String,Object> getCustomerAdditionalCardDetails(String cardId){
        Map<String,String> retriveCardOption =  new Map<String,String>();
        ApiConnection.Response response = SM001_ApiCalls.getCreditCardDetailsApi(con,cardId,accountObj.CIF__pc,accountObj.personEmail,accountObj.Region_Flag__c);
        Map<String, Object> responseData = (Map<String, Object>)response.responseData;
        return responseData;
    }
    
    /**
     * @description : This method would fetch the customer loan details for both ila and alburaq subscription.
     * @return : void
     */
    public void getCustomerLoanDetails(){
        List<OutstandingBalanceWrapper.LoanWrapper> loanWrapperList = new List<OutstandingBalanceWrapper.LoanWrapper>();
        
        //checking if subscription is 'both' that means customer has ila and alburaq and both loans api needs to be called.
        if(accountObj.Subscription_Model__pc == 'both'){
            List<Object> ilaLoans = getCurrentLoans('ila');
            obWrapper.ilaLoanWrapperList = getLoanWrapperList(ilaLoans);
            
            List<Object> alBuraqLoans = getCurrentLoans('alburaq');
            obWrapper.alburaqLoanWrapperList = getLoanWrapperList(alBuraqLoans);
        }
        else {
            List<Object> currentLoans = getCurrentLoans(accountObj.Subscription_Model__pc);
            if(accountObj.Subscription_Model__pc == 'ila'){
                obWrapper.ilaLoanWrapperList = getLoanWrapperList(currentLoans);    
            }
            else {
                obWrapper.alburaqLoanWrapperList = getLoanWrapperList(currentLoans);
            }
        }
    }
    
    /**
     * @description : This method would fetch the current loans from loan api.
     * @param : caseModel
     * @return : List<Object>
     */
    public List<Object> getCurrentLoans(String caseModel){
        ApiConnection.Response response = Loans_ServiceManagerHandler.callLoansOptionsAPI(accountObj.CIF__pc,caseModel);
        Map<String, Object> responseData = (Map<String, Object>)response.responseData;
        System.debug('responseDataLoan '+JSON.serializePretty(responseData));
        if(responseData != null && responseData.containsKey('currentLoans')){
            List<Object> currentLoanList = (List<Object>)responseData.get('currentLoans');
            System.debug('currentLoanList size ' + currentLoanList.size());
            try {
                for(Object loan :currentLoanList){
                    Map<String, Object> loanObject = (Map<String, Object>)loan;
                    String loanId = (String)loanObject.get('arrangementId');
                    ApiConnection.Response loanDetailResponse = Loans_ServiceManagerHandler.callLoansEarlySettlementAPI(accountObj.CIF__pc,loanId,caseModel);
                    System.debug('loanDetailResponse '+JSON.serializePretty(loanDetailResponse));
                    
					Map<String, Object> responseEarlySettlementData = (Map<String, Object>)loanDetailResponse.responseData;
                    Decimal totalPayoffAmount = (Decimal)responseEarlySettlementData.get('totalPayoffAmount');
                    
                    loanObject.put('totalPayoffAmount',totalPayoffAmount);

                    String regionFlag = accountObj.Region_Flag__c;
                    
                    if(caseModel != 'ila'){
                       regionFlag += '_alburaq'; 
                    }
                    
                    String searchParam = '{"arrangementId":"' + loanId + '","type":"Schedule"}';
                    
                    Loans_ServiceManagerHandler.APIResponse paymentScheduleResponse = Loans_ServiceManagerHandler.callGetLoanPaymentsSchedule(null,accountObj.CIF__pc, searchParam, regionFlag,false);
                    
                    if(paymentScheduleResponse.isSuccess){
                    	Map<String, Object> responseInstallmentAmount = (Map<String, Object>)paymentScheduleResponse.headerData;
                        System.debug('responseInstallmentResponse ' + responseInstallmentAmount);
                        Decimal monthlyInstallment = (Decimal)responseInstallmentAmount.get('nextInstallmentAmount');
                        System.debug('loanId = ' + loanId + ' monthlyInstallment = ' + monthlyInstallment);
                        monthlyInstallment = monthlyInstallment == null ? 0 : monthlyInstallment;
                        loanObject.put('monthlyInstallmentSchedule',monthlyInstallment);    
                    }
                    else {
                        loanObject.put('monthlyInstallmentSchedule',0);
                    }
                }
            }
            catch(Exception ex){
            	System.debug('ex loan apis ' + ex.getMessage());
            }
            return currentLoanList;
        }
        return new List<Object>();
    }
    
    /**
     * @description : This method would generate the loan wrapper list, it would iterate currentloan which return from the api.
     * those loan data/record would be consider which does not have 'close,pending,closure,unauth' status. 
     * it would also calculate outstandingAmount
     * @param : currentLoans
     * @return : List<OutstandingBalanceWrapper.LoanWrapper>
     */
    public List<OutstandingBalanceWrapper.LoanWrapper> getLoanWrapperList(List<Object> currentLoans){
        List<OutstandingBalanceWrapper.LoanWrapper> loanWrapperList = new List<OutstandingBalanceWrapper.LoanWrapper>();
        String statusToAvoid = 'close,closed,pending,closure,unauth'; //loan status must not be one of them.
        
        for(Object loan : currentLoans){
            Map<String, Object> loanObject = (Map<String, Object>)loan;
            String loanType = (String)loanObject.get('productType');
            String loanAccount = (String)loanObject.get('loanAccountNumber');
            String loanProductName = (String)loanObject.get('productName');
            String loanProductType = (String)loanObject.get('productType');
            String status = (String)loanObject.get('status');
            
            Decimal outstandingAmount = (Decimal)loanObject.get('totalPayoffAmount');
            
            
            Decimal monthlyInstallmentSchedule = (Decimal)loanObject.get('monthlyInstallmentSchedule');
            System.debug('monthlyInstallmentSchedule = ' + monthlyInstallmentSchedule);
            
            //START CR - NBA-17271
            Decimal monthlyInstallment  = (Decimal)loanObject.get('monthlyInstallment'); 
            
            outstandingAmount = outstandingAmount == null ? 0 : outstandingAmount;
            if(monthlyInstallmentSchedule > 0){
                outstandingAmount = outstandingAmount + (1.5 * monthlyInstallmentSchedule);
                
                outstandingAmount = outstandingAmount.setScale(3, RoundingMode.HALF_UP);
            }
            //END CR - NBA-17271
            System.debug('status to avoid ' + status);
            if(!statusToAvoid.contains(status.toLowerCase()) || status.toLowerCase() == 'auth'){
                loan_totalOutstanding = loan_totalOutstanding + outstandingAmount;
                OutstandingBalanceWrapper.LoanWrapper loanWrapper = new OutstandingBalanceWrapper.LoanWrapper();
                loanWrapper.financeType = loanType;
                loanWrapper.financeAccount = loanAccount;
                loanWrapper.productName = loanProductName;
                loanWrapper.productType = loanProductType;
                loanWrapper.outstandingBalance = outstandingAmount;
                loanWrapper.formattedOutstandingBalance = getFormattedCurrency(outstandingAmount);
                loanWrapperList.add(loanWrapper);
            }
            
        }
        return loanWrapperList;
    }
    
    /**
     * @description : This method would generate thousand separate currency formating e.g 100,100.000
     * @param : currencyValue
     * @return : String
     */
    public String getFormattedCurrency(Decimal currencyValue){
        if(currencyValue == null) return '';
        
        String formattedCurrency = currencyValue.format();
        if(formattedCurrency != '' && !formattedCurrency.contains('.')){
            formattedCurrency = formattedCurrency + '.000';
        }
        else {
            String currencyDecimal = formattedCurrency.split('\\.')[1];
            if(currencyDecimal.length() == 0){
                formattedCurrency = formattedCurrency + '000';
            }
            else if(currencyDecimal.length() == 1){
                formattedCurrency = formattedCurrency + '00';
            }
            else if(currencyDecimal.length() == 2){
                formattedCurrency = formattedCurrency + '0';
            }
        }
        return formattedCurrency;
    }
}