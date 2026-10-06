public class LetterGenerationController {

    public List<wrapAccount> accDetails{get; set;}
    public List<wrapCase> cardDetails{get; set;}
    public List<string> cardIds{get;set;}
    Public string accountId {get;set;}
    public Account acc{get;set;}
    Public string caseId {get;set;}
    Public string gender {get;set;}
    public String caseNumber{get;set;}
    public Date letterDate{get;set;}
    public Decimal legalFee{get;set;}
    Public string cc_ID_Number {get;set;}
    Public string ac_Iban {get;set;}
    public Boolean isAlburaq { get; set; }

    private static ApiConnection con = new ApiConnection();
    
    Public LetterGenerationController(){
        
        isAlburaq = false;
        
        accountId=ApexPages.currentPage().getParameters().get('accId');
        acc=[SELECT id,name,x_canary__pc,Gender__pc,Subscription_Model__pc,ID_Number__pc,CIF__pc,PersonMailingStreet,PersonMailingCity,PersonMailingState,PersonMailingPostalCode,PersonMailingCountry,PersonEmail,Region_Flag__c,Bank_Account_Opening_Date__c FROM Account WHERE id=:accountId];
        if(acc.Gender__pc=='M')
        {
            gender='Mr';
        }
        else
        {
           gender= 'Ms';
        }
        
        
        
        caseId=ApexPages.currentPage().getParameters().get('csId');
        
        List<Case> casedetails=[Select Id,Sub_Type__c,caseNumber,Total_Legal_Fee__c,CreatedDate,cc_Checker_Result_Date_Time__c,Case_Nature__c,cc_ID_Number__c,ac_Iban__c,Case_Model__c from Case where Id=:caseId];
        caseNumber=casedetails[0].caseNumber;
        cc_ID_Number=casedetails[0].cc_ID_Number__c;
        ac_Iban=casedetails[0].ac_Iban__c;
        if(casedetails[0].Case_Nature__c == 'FCR'){
            letterDate = casedetails[0].CreatedDate.date(); 
        }else{
            if(casedetails[0].cc_Checker_Result_Date_Time__c != null){
                letterDate = casedetails[0].cc_Checker_Result_Date_Time__c.date(); 
            }else{
                letterDate = System.today();
            }
        }
        
        
        legalFee=casedetails[0].Total_Legal_Fee__c;
        List<Map<String,Object>> getCardOptions= new List<Map<String,Object>>();
        if(casedetails[0].Sub_Type__c=='Outstanding balance Letter')
        {
            getCardOptions=getCardOptions(acc,'D');
            getCustomerLoanDetails(acc);
        }
        else if(casedetails[0].Sub_Type__c=='Cancellation Letter')
        {
            getCardOptions=getCardOptions(acc,'A');
        }
        else if(casedetails[0].Sub_Type__c=='No Due Letter')
        {
            getCardOptions=getCardOptions(acc,'D');
        }
        else if(casedetails[0].Sub_Type__c=='Balance Confirmation Letter')
        {
            String regionName = acc.Region_Flag__c;
            if(casedetails[0].Case_Model__c == 'alburaq'){
                regionName += '_alburaq';
                isAlburaq = true;
            }
            HttpRequest request = con.createRequest('GET','/api/v1/accounts/all',regionName);

            HttpResponse response = SM001_ApiCalls.getAccountsListAllApi(request,acc);
            
            //fake responsE
            /*HttpResponse response = new HttpResponse();
            String body = '{"meta": {"code": "ACCO-1000","message": "Accounts list for customer [8610001] has been retrieved successfully."},"data": {"allowAccountCreation": true,"accounts": [{"id": "BH97ABCO86100019101101","customerId": "8610001","alias": "Neo BANK Saving Account 1","productType": "account","productName": "Neo BANK Saving Account 1","category1": "","category2": "","detailsExist": true,"defaultAccount": true,"account": {"number": "861000191011","currency": {"code": "USD","decimalPlaces": "2"},"iban": "BH97ABCO86100019101101","availableBalance": 586828,"ledgerBalance": 10090344,"startDate": "2019-02-08","endDate": "2019-02-10","overdraftLimit": 0,"overdraftExpiryDate": "2019-05-03","overdraftAvailableLimit": 0,"paymentsAllowed": true,"creditInterestFrequencyCode": "200001","creditInterestFrequency": "MONTHLY","debitInterestFrequencyCode": "200001","debitInterestFrequency": "MONTHLY","creditGlAccount": "2011204","creditGlAccountDescription": "LIAB CURRENT ACCT - REGULAR","debitGlAccount": "2011204","debitGlAccountDescription": "LIAB CURRENT ACCT - REGULAR","minimumBalance": 0,"maximumBalance": 0,"valueBalance": 10090344,"holdAmount": 9503516,"overdraftReviewDate": "1957-01-01"}},{"id": "BH32ABCO86100019101301","customerId": "8610001","alias": "Neo BANK Current Account 1","productType": "account","productName": "Neo BANK Current Account 1","category1": "","category2": "","detailsExist": true,"defaultAccount": false,"account": {"number": "861000191013","currency": {"code": "USD","decimalPlaces": "2"},"iban": "BH32ABCO86100019101301","availableBalance": 179911,"ledgerBalance": 179911,"startDate": "2019-02-08","endDate": "2019-02-10","overdraftLimit": 0,"overdraftExpiryDate": "2019-05-03","overdraftAvailableLimit": 0,"paymentsAllowed": true,"creditInterestFrequencyCode": "200001","creditInterestFrequency": "MONTHLY","debitInterestFrequencyCode": "200001","debitInterestFrequency": "MONTHLY","creditGlAccount": "2011204","creditGlAccountDescription": "LIAB CURRENT ACCT - REGULAR","debitGlAccount": "2011204","debitGlAccountDescription": "LIAB CURRENT ACCT - REGULAR","minimumBalance": 0,"maximumBalance": 0,"valueBalance": 179911,"holdAmount": 0,"overdraftReviewDate": "1957-01-01", "accountType":"KANZ"}}]}}';
            response.setStatus('OK');
            response.setStatusCode(200);
            response.setBody(body);
            response.setHeader('Content-Type', 'application/json');*/
            
            accDetails= new List<wrapAccount>();
            Integer increment=0;
            if (response.getStatusCode() != 200 ) {
                String errorMsg = 'The status code returned was not expected when we are calling Get Account List API : ' + response.getStatusCode();
            }else {
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                List<Object> accountList = (List<Object>)m1.get('accounts'); 
                for(Object accountDetails : accountList){
                    Map<String,Object> mapaccountConfig = (Map<String, Object>)accountDetails;
                    Map<String,Object> mapaccountDetails = (Map<String, Object>)mapaccountConfig.get('account');
                    String accountType = String.valueOf(mapaccountDetails.get('accountType'));//toDo: check mapping if productName?? or accountType??
                    if(accountType == 'CUSTOMER_ACCOUNT' || accountType == 'KANZ'){
                        String accIban = String.valueOf(mapaccountDetails.get('iban'));
                        String accCurrency = (String) ((Map<String, Object>)mapaccountDetails.get('currency')).get('code');
                        String availableBalance = String.valueOf(mapaccountDetails.get('availableBalance'));
                        system.debug('acc balance ' + availableBalance);
                        increment ++;
                        if(!String.isBlank(availableBalance)){
                            Decimal decimalBalance = Decimal.valueOf(availableBalance);
                            Decimal roundedBalance = decimalBalance.setScale(3,RoundingMode.HALF_UP);
                            availableBalance = String.valueOf(roundedBalance);
                        }
                        wrapAccount w = new wrapAccount(increment,accIban,accountType,accCurrency,availableBalance);
                        accDetails.add(w);
                    }
                }
                //order accDetails list (order by account type (customeraccount) first with the following currency order (BHD, USD, GBP, EUR, AED, SAR, CAD), then KANZ account.)
                accDetails = sortAndRenumberAccounts(accDetails);
            }
        }
        else if(casedetails[0].Sub_Type__c=='Reference Letter')
        {
            System.debug('Reference Letter scenario !!');
            if(casedetails[0].Case_Model__c == 'alburaq'){
                isAlburaq = true;
            }
        }

        System.debug('getCardOptions 109 '+ getCardOptions);
		if(getCardOptions.size()>0)
        {
            
            cardDetails= new List<wrapCase>();
            for( Map<String,Object> card : getCardOptions)
            {
                System.debug('getCardOptions card '+ card);
                string cardpciNumber=(String)card.get('maskedCardNumber');
                string cardissueDate=(String)card.get('issueDate');
                string creditcardId=(String)card.get('id');
                Map<String,String> loadCardDetails=loadCardDetails(acc, creditcardId);
                List<string> cardlimit =new List<string> (loadCardDetails.keySet());
                string credicardLimit=cardlimit[0];
                string cardoutstandingBalance=loadCardDetails.get(cardlimit[0]);
                string cardcancellationDate=(String)loadCardDetails.get('blockDate');
                if(creditcardId!=null)
                {
                    Date DatecardissueDate;
                    if(cardissueDate != null && cardissueDate != 'null'){
                        DatecardissueDate = Date.valueof(cardissueDate);
                    }
                    wrapCase w = new wrapCase(creditcardId,(String)card.get('cardDisplayName'),credicardLimit,cardpciNumber,cardoutstandingBalance,DatecardissueDate,'9',cardcancellationDate);
                    cardDetails.add(w);
               }
            }
            system.debug('cardDetails==>'+cardDetails);
        }
    }

    public static void getCustomerLoanDetails(Account accObj){
    	 
        ApiConnection.Response response = Loans_ServiceManagerHandler.callLoansOptionsAPI(accObj.CIF__pc,accObj.Subscription_Model__pc);
        Map<String, Object> responseData = (Map<String, Object>)response.responseData;
        List<Object> currentLoans = (List<Object>)responseData.get('currentLoans');
        for(Object loan : currentLoans){
            Map<String, Object> loanObject = (Map<String, Object>)loan;
            System.debug('response loan loanObject arrangementId ' + loanObject.get('arrangementId'));
            System.debug('response loan loanObject productType ' + loanObject.get('productType'));
            System.debug('response loan loanObject loanOutstandingAmount ' + loanObject.get('loanOutstandingAmount'));
        }
        System.debug('response loan api ' + responseData);
    }
    
    public static List<Map<String,Object>> getCardOptions(Account accObj,string filerOption){
        List<Map<String,Object>> retriveCardOption =  new List<Map<String,Object>>();
        Map<String,String> retrivePCIOption = new Map<String,String>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        system.debug('accObj==>'+accObj);
        
        //fake response start
        /*HttpResponse response1 = new HttpResponse();
        String body = '{"meta":{"code":"CCRD-1100","message":"Card list has been retrieved successfully."},"data":{"currentCards":[{"id":"2660030003081773","cardSequenceNumber":"0001","expiryDate":"2027-04-22","cardProductionConfigurationId":2,"productMappingCode":"PLATINUM_CASHBACK_AND_REWARD_01","cardDisplayName":"ila Blu12e","cmsCardProductId":"003","cmsCardProductType":"01","isPrimary":true,"embossName":"Hasan Abdulla","blockDate":"2023-05-09","maskedCardNumber":"511724XXXXXX1773","issueDate":"2024-04-22","provider":"Mastercard","isRequestedCard":false,"order":3000,"isDelinquent":false,"mustBeActivated":false,"isBankBlocked":false,"hasSupplementaryCardFees":false,"canRequestSupplementaryCard":false,"pendingRelease":false,"cardNature":"unsecured","supportedDigitalWallets":["APPLE_PAY"],"enabledCardActions":["SETUP_AUTOMATIC_PAYMENT","CHANGE_CREDIT_LIMIT","TRANSACTIONS_CONTROL"],"cardConfigurations":[{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"1"}],"enabledMainActions":[{"mainAction":"OFFERS","status":"SHOW_ENABLED","sortOrder":7}],"primaryCardPciNumber":"2660030003081773","applicationStatus":"","blockCode":"O","pendingRequests":[]},{"id":"898989898989","cardSequenceNumber":"0001","expiryDate":"2027-04-22","cardProductionConfigurationId":2,"productMappingCode":"PLATINUM_CASHBACK_AND_REWARD_01","cardDisplayName":"ila Test","cmsCardProductId":"003","cmsCardProductType":"01","isPrimary":true,"embossName":"Hasan Abdulla","blockDate":"2023-05-09","maskedCardNumber":"511724XXXXXX1773","issueDate":"2025-04-22","provider":"Mastercard","isRequestedCard":false,"order":3000,"cardNature":"unsecured","status":"AccountCancelledByBank","primaryCardPciNumber":"2660030003081773"}],"pendingCards":[{"id":"16511","cardProductConfigurationId":2,"cardType":"01","productMappingCode":"PLATINUM_CASHBACK_AND_REWARD_01","cardDisplayName":"ila Blue","cmsCardProductId":"003","cmsCardProductType":"01","status":"PENDING","order":1000,"caseId":"5007Y00000IlpWNQAZ","embossName":"MOHAMED ALBASRI","createdDate":"2021-09-26T14:45:36","modifiedDate":"2021-09-26T14:45:36","closureDate":"2021-09-26T14:45:36","creditLimit":4000.00000,"requestType":"CREDIT_CARD_ORDER","cardConfigurations":[{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"1"}]}],"cardOptions":[{"cardProductConfigurationId":4,"productMappingCode":"TITANIUM_CO_BRAND_01","cardDisplayName":"Titanium Gulf Air","cmsCardProductId":"005","cmsCardProductType":"01","order":2,"productStatus":"ORDER","cardConfigurations":[{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"0"}],"cardNature":["unsecured","secured"]}]}}';
        response1.setStatus('OK');
        response1.setStatusCode(200);
        response1.setBody(body);

        Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());

        ApiConnection.Response response = new ApiConnection.Response();
        response.isSuccess = true;
        response.responseData = resMap.get('data');*/
        //fake response end
		System.debug('MX accObj ' + accObj);
        System.debug('MX filerOption ' + filerOption);
        
        
        HttpRequest request = con.createRequest('GET', '/api/v1/credit-cards', accObj.CIF__pc, accObj.Region_Flag__c);
        if(accObj.x_canary__pc != null){
            request.setHeader('x-canary', accObj.x_canary__pc); //CH09
        }
        String endPoint = request.getEndpoint();
        request.setEndpoint(endPoint + '&filterOption=' + filerOption);
        ApiConnection.Response response = con.makeCallout(request);
        
        
        //final ApiConnection.Response response = SM001_ApiCalls.getCreditCardStatusApi(con, accObj.PersonEmail,accObj.CIF__pc,filerOption,accObj.Region_Flag__c);
        System.debug('MX response '+ JSON.serializePretty(response));
        if (response!=null && response.isSuccess && null != response.responseData) {
            Map<String, Object> m = (Map<String, Object>)response.responseData;
            List<Object> currCardsList = (List<Object>)m.get('currentCards');
            List<Map<String, Object>> lstcardMap = new List<Map<String, Object>> ();
            for(Object curCards : currCardsList){
                lstcardMap.add((Map<String, Object>)curCards);
            }
         
            for(Map<String,Object> mapRelatedCurrentCards : lstcardMap){
                System.debug('194 mapRelatedCurrentCards ' + mapRelatedCurrentCards);
                String cancelledCardStatus = 'account_cancelled_by_bank,account_cancelled_by_customer';
                String status = (String)mapRelatedCurrentCards.get('status');
                
                if(filerOption=='A' && cancelledCardStatus.contains(status.toLowerCase()) || filerOption=='D')
                {
                    if(mapRelatedCurrentCards.containsKey('id')&& mapRelatedCurrentCards.get('isPrimary')==true) 
                   {
                       String cardNature = (String) mapRelatedCurrentCards.get('cardNature');
                       if(!cardNature.contains('prepaid')){
                           retriveCardOption.add(mapRelatedCurrentCards);
                       }
                    }
                }
                
            }
        }
        else
        {
            System.debug('The status code returned was not expected: ' + response );
 
        }
        return retriveCardOption;
    }

    public static Map<String,String> loadCardDetails(Account accObj, String cardId) {
        Map<String,String> retriveCardOption =  new Map<String,String>();

        //fake response start
        /*HttpResponse response1 = new HttpResponse();
        String body = '{"meta":{"code":"CCRD-XXXX","message":"Card inquiry successfully completed."},"data":{"cif":"1293978","pciNumber":"2660030003081773","customerName":"ABC XYZ","usedCreditLimit":1049.5,"holdAmount":0.0,"lastPaymentAmount":0.0,"creditLimit":2000.0,"availableCreditLimit":950.5,"availableCashLimit":1150.5,"currentDues":60.0,"minimumDues":230.0,"totalDues":230.0,"pastDues":170.0,"paymentDueDate":"2024-09-05","recoverOption":0,"pointsBalance":0.0,"lastStatmentBalance":1049.5,"cashLimit":1200.0,"paymentSinceLastStatements":0.0,"isPrimary":true,"embossName":"Hasan Abdulla","cmsAccountId":"511724XXXXXX1773","isReissued":false,"currentPurchaseAmount":0.0,"currentUsedCashAmount":0.0,"currentReturnsAmount":0.0,"currency":{"code":"BHD","decimalPlaces":3},"expiryDate":"2027-04-22","cmsProductDescription":"ILA BLUE","issueDate":"2024-04-22","primaryCardPciNumber":"DEF08FC548C1BB41","cmsCardProductId":"003","email":"alaa.m.hossam@gmail.com","mobileNumber":"009765654589","unbilledAmount":0.0,"lastStatementDate":"2024-08-21","lastTransactionDate":"2024-04-23","bankAccountId":"397891010BHD    ","plasticCardType":"P","plasticCardDescription":"ILA BLUE","accountBlockCode1":"O","accountBlockCode2":"T","accountBlockDate1":"2024-08-05","directDebitPercentage":0,"cashbackAmount":0.000,"totalCashbackAmount":0,"paymentLastStatementBalance":1049.5,"paymentMinimumDues":230.0,"paymentUsedCreditLimit":1049.5,"recentCreditsAmount":0.0,"recentDebitsAmount":0.0}}';
        response1.setStatus('OK');
        response1.setStatusCode(200);
        response1.setBody(body);

        Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());

        ApiConnection.Response response = new ApiConnection.Response();
        response.isSuccess = true;
        response.responseData = resMap.get('data');*/
        //fake response end

        final ApiConnection.Response response = SM001_ApiCalls.getCreditCardDetailsApi(con,cardId,accObj.CIF__pc,accObj.personEmail,accObj.Region_Flag__c);

        system.debug('---> RESPONSE --> '+response);
        Map<String, Object> m = (Map<String, Object>)response.responseData;
        retriveCardOption.put(string.valueOf(m.get('creditLimit')),string.valueOf(m.get('usedCreditLimit')));
        
        String blockDate = '';
        if(m.containsKey('accountBlockDate2')){
			blockDate = (String)m.get('accountBlockDate2');     
        }
        retriveCardOption.put('blockDate',blockDate);
        system.debug('---->> retriveCardOption --> '+retriveCardOption);
  
       return retriveCardOption;
    }
    
    // Main sorting and re-indexing method
    public static List<wrapAccount> sortAndRenumberAccounts(List<wrapAccount> accDetails) {
        if (accDetails == null || accDetails.isEmpty()) return accDetails;

        for (Integer i = 0; i < accDetails.size(); i++) {
            for (Integer j = i + 1; j < accDetails.size(); j++) {
                String key1 = accDetails[i].getSortKey();
                String key2 = accDetails[j].getSortKey();
                if (key1 > key2) {
                    wrapAccount temp = accDetails[i];
                    accDetails[i] = accDetails[j];
                    accDetails[j] = temp;
                }
            }
        }

        // Reassign increment starting from 1
        Integer index = 1;
        for (wrapAccount acc : accDetails) {
            acc.increment = index++;
        }

        return accDetails;
    }

    // Priority for account types
    public static Integer getAccountTypeOrder(String accType) {
        if (accType == 'CUSTOMER_ACCOUNT') return 1;
        if (accType == 'KANZ') return 2;
        return 99;
    }

    // Priority for currencies
    public static Integer getCurrencyOrder(String currencyAcc) {
        List<String> currencyOrder = new List<String>{'BHD', 'USD', 'GBP', 'EUR', 'AED', 'SAR', 'CAD'};
        Integer index = currencyOrder.indexOf(currencyAcc);
        return index == -1 ? 99 : index;
    }

    // Manual left-pad for numeric strings
    public static String leftPad(String input, Integer totalLength) {
        while (input.length() < totalLength) {
            input = '0' + input;
        }
        return input;
    }

    // wrapper/container class 
    public class wrapCase {
        public String cardId {get;set;}
        public String displayName {get;set;}
        public String cardLimit {get;set;}
        public String pciNumber {get;set;}
        public Date issueDate {get;set;}
        public String outstandingBalance {get;set;}
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

    // wrapper/container class 
    public class wrapAccount {
        public Integer increment {get;set;}
        public String accIban {get;set;}
        public String accType {get;set;}
        public String accCurrency {get;set;}
        public String balance {get;set;}
        //Constructor method 
        public wrapAccount(Integer increment,String accIban,String accType,String accCurrency,String balance) {
            this.increment=increment;
            this.accIban=accIban;
            this.accType = accType;
            this.accCurrency = accCurrency;
            this.balance=balance;
        }

        // Generate a combined sort key: format "01-00", "01-01", etc.
        public String getSortKey() {
            Integer typeOrder = LetterGenerationController.getAccountTypeOrder(this.accType);
            Integer currencyOrder = LetterGenerationController.getCurrencyOrder(this.accCurrency);
            return LetterGenerationController.leftPad(String.valueOf(typeOrder), 2) +
                   LetterGenerationController.leftPad(String.valueOf(currencyOrder), 2);
        }
    }
}