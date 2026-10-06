/**
 * Class to handle Saving Pot logic
 * @author Sopha Pum
 * @created 26-05-2020
 *    				  	 #CH01# #Jahangeer Mohammed #06-05-2024# Added logic for Audit History Enhancements(NBA-9027)
 *                       #CH02#: #Aitogram omar# #01-04-2026 Added logic for Dormancy Visibility Restrictions (NBA-11705)

 */
public with sharing class SavingPotController {

    @TestVisible // overwrite instance to provide custom connection in test class
    private static ApiConnection con = new ApiConnection();

    @TestVisible // overwrite instance to provide custom DAO in test class
    private static SavingPotController DAO = new SavingPotController();

    private final static List<String> SENSITIVE_FIELDS_ACCOUNT_LIST = new List<String>{
        'account.availableBalance',
        'account.ledgerBalance'
    };
    private final static List<String> SENSITIVE_FIELDS_ACCOUNT_DETAILS = new List<String>{
        'account.availableBalance',
        'account.ledgerBalance',
        'account.holdAmount',
        'goalAmount',
        'monthlyDepositAmount',
        'account.holdAmount'
    };

    /**
     * Method load saving pots (/pots) from API
     * @param customerId String customer id to search from API
     * @return ApiConnection.Response
     */
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadSavingPots(final String customerId, String regionName) {
         Account ObjAcc=[Select Id,x_canary__pc From account where CIF__pc=:customerId];
        final String path = '/api/v1/pots';
        final HttpRequest req = con.createRequest('GET', path, customerId, regionName);
        if(ObjAcc.x_canary__pc != null){
                req.setHeader('x-canary',ObjAcc.x_canary__pc);//CH22
            }
        System.debug('loadSavingPots>>>>>'+ObjAcc.x_canary__pc);
       final ApiConnection.Response response = con.makeCallout(req);

        // // //START Fake Response

       
        //        HttpResponse res = new HttpResponse();
                
        //         // Create Manually json response For Test Class
        //         String body = '{"meta":{"code":"SPOT-1004","message":"List of savings pot has been retrieved successfully."},"data":{"totalAmountInLocalCurrency":1800.000,"localCurrency":{"code":"BHD","description":"Bahraini Dinar","decimalPlaces":3},"pots":[{"potId":1,"name":"Vacation 2020","description":"Saving for my upcoming vacation","type":"regular","icon":"PalmTreeIcon.png","iconColor":"purple","potAccountId":"BH96ABCO14184349101102","linkedAccountId":"BH96ABCO14184349101101","status":"active","earnInterest":true,"currentDate":"15-6-20","startDate":"2020-03-20","savingDuration":10,"goalAmount":3000.00,"monthlyDepositAmount":300.00,"events":[{"eventId":"1234","name":"AUTOADJUSTED_WITHDRAWAL"},{"eventId":"4567","name":"AUTOADJUSTED_FUNDING"}],"endDate":"2021-01-20","collectionDay":20,"remainingSavingDuration":7,"remainingSavingAmount":2100,"customerId":"989248099","productType":"PotAccount","productName":"Savings Pot","category1":"","category2":"","account":{"number":"100001009280","branch":"","currency":{"code":"BHD","description":"Bahraini Dinar","decimalPlaces":3},"iban":"BH09ABCO00929029882","availableBalance":900.000,"ledgerBalance":900.000,"startDate":"2018-01-09","endDate":"2018-02-09","status":"Active","overdraftLimit":100000.000,"overdraftExpiryDate":"2020-12-31","overdraftAvailableLimit":1000000.000,"paymentsAllowed":true}},{"potId":2,"name":"Vacation 2021","description":"Saving for my upcoming vacation","type":"regular","icon":"PalmTreeIcon.png","iconColor":"blue","potAccountId":"BH96ABCO14184349101103","linkedAccountId":"BH96ABCO14184349101101","status":"closed","earnInterest":true,"savingDuration":10,"startDate":"2021-03-20","goalAmount":3000.00,"monthlyDepositAmount":300.00,"endDate":"2021-01-20","collectionDay":20,"remainingSavingDuration":6,"remainingSavingAmount":2400,"customerId":"989248099","alias":"Savings Pot","productType":"PotAccount","productName":"Savings Pot","category1":"","category2":"","account":{"number":"100001009280","branch":"","currency":{"code":"BHD","description":"Bahraini Dinar","decimalPlaces":3},"iban":"BH09ABCO00929029882","availableBalance":600.000,"ledgerBalance":600.000,"startDate":"2018-01-09","endDate":"2018-02-09","status":"Completed","overdraftLimit":100000.000,"overdraftExpiryDate":"2020-12-31","overdraftAvailableLimit":1000000.000,"paymentsAllowed":true}}]}}';
        //         res.setStatus('OK');
        //         res.setStatusCode(200);
        //         res.setBody(body);
        //         res.setHeader('Content-Type', 'application/json');  
        

        // // HttpResponse res= MCK001_ApiCalls.loadSavingPotsApi(req,200);

        // final Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        // ApiConnection.Response response= new ApiConnection.Response();
        // response.isSuccess=true;
        // response.responseData = resMap.get('data');
        // //END Fake Response



        System.debug('loadSavingPots>>>>>' + JSON.serializePretty(response));
        //to remove view info
        if (response.isSuccess && null != response.responseData) {
            final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            final Object[] pots = (Object[])responseData.get('pots');
            //System.debug('Transaction pots after getting response:'+pots.size());
            if (SensitiveDataCleaner.loadIsDataCleaningRequired(customerId)) {
                SensitiveDataCleaner.removeSensitiveData(pots, SENSITIVE_FIELDS_ACCOUNT_LIST);
            }
        }

        return response;
    }

    /**
     * Method to load pot detail info
     * @param customerId    String customer id
     * @param potId         String pot id
     * @return ApiConnection.Response
     */
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadPotDetails(final String customerId, final String potId, String regionName) {
        final String path = '/api/v1/pots/' + potId;
        final HttpRequest req = con.createRequest('GET', path, customerId, regionName);
                Account ObjAcc=[Select Id,x_canary__pc From account where CIF__pc=:customerId];
        if(ObjAcc.x_canary__pc != null){
                req.setHeader('x-canary',ObjAcc.x_canary__pc);//CH22
            }
        System.debug('load Pots details>>>>>');
       final ApiConnection.Response response = con.makeCallout(req);

 // //START Fake Response

       /*
                HttpResponse res = new HttpResponse();
                
                // Create Manually json response For Test Class
                String body = '{"meta":{"code":"SPOT-1001","message":"Savings pot details have been retrieved successfully. "},"data":{"potId":1,"name":"Vacation 2020","description":"Saving for my upcoming vacation","type":"regular","icon":"PalmTreeIcon.png","iconColor":"blue","potAccountId":"BH96ABCO14184349101102","linkedAccountId":"BH96ABCO14184349101101","status":"active","earnInterest":true,"startDate":"2020-03-20","savingDuration":10,"goalAmount":3000.00,"monthlyDepositAmount":300.00,"events":[{"eventId":"1234","name":"AUTOADJUSTED_WITHDRAWAL"},{"eventId":"4567","name":"AUTOADJUSTED_FUNDING"}],"alias":"Wife Account","productType":"Account","productName":"Saving Account","category1":"","category2":"","account":{"number":"100001009280","branch":"","currency":{"code":"BHD","description":"Bahraini Dinar","decimalPlaces":3},"iban":"BH09ABCO00929029882","availableBalance":100.000,"ledgerBalance":100.000,"startDate":"2018-01-09","endDate":"2018-02-09","status":"Active","overdraftLimit":100000.000,"overdraftExpiryDate":"2020-12-31","overdraftAvailableLimit":1000000.000,"paymentsAllowed":true,"swiftCode":"ABCOBHBMXXX","earnInterest":true,"creditTotalInterest":0.0,"debitTotalInterest":0.0,"allowInterestConditionUpdate":true,"interestRateInformation":{"earnInterest":true,"processingStatus":"PENDING","effectiveDate":"2021-07-30","modifiedDate":"2021-06-28"},"interestConditions":[{"rateType":"TIERED_INTEREST_RATE","rankOrder":1,"currency":{"code":"BHD","description":"Bahraini Dinar","decimalPlaces":3},"tier":"BHD 0 - 1,000","tier_start":0.000,"tier_end":1000.0,"rate":0.014,"applicable_balance":1000.0,"active":true,"show_rate":true},{"rateType":"TIERED_INTEREST_RATE","rankOrder":2,"currency":{"code":"BHD","description":"Bahraini Dinar","decimalPlaces":3},"tier":"BHD 1,000 - 5,000","tier_start":1000.000,"tier_end":5000.000,"rate":0.0155,"applicable_balance":1000.0,"active":true,"show_rate":true},{"rateType":"TIERED_INTEREST_RATE","rankOrder":3,"currency":{"code":"BHD","description":"Bahraini Dinar","decimalPlaces":3},"tier":"BHD 5,000 - 10,000","tier_start":5000.000,"tier_end":10000.000,"rate":0.0175,"applicable_balance":1000.0,"active":true,"show_rate":true},{"rateType":"TIERED_INTEREST_RATE","rankOrder":4,"currency":{"code":"BHD","description":"Bahraini Dinar","decimalPlaces":3},"tier":"BHD 10,000 - 250,000","tier_start":10000.000,"tier_end":250000.000,"rate":0.021,"applicable_balance":1000.0,"active":false,"show_rate":true},{"rateType":"TIERED_INTEREST_RATE","rankOrder":5,"currency":{"code":"BHD","description":"Bahraini Dinar","decimalPlaces":3},"tier":"BHD 250,000 +","tier_start":0.000,"tier_end":1000.0,"rate":0.0145,"applicable_balance":1000.0,"active":false,"show_rate":false}]},"standingOrder":{"reference":"","chargeType":"","comments":"","debit":{"accountNumber":"1234567890","currency":"BHD","customerId":"1234567","iban":"BH23ABCO1234567890001","availableBalance":123123.45,"accountStatus":"active","clientStatus":"active","narrative":["description1","description2","description3","description4","description5","description6"]},"credit":{"accountNumber":"2234567890","currency":"BHD","customerId":"2234567","iban":"BH23ABCO2234567890001","availableBalance":103123.45,"accountStatus":"active","clientStatus":"active","narrative":["description1","description2","description3","description4","description5","description6"]},"forcePost":false,"freezeUnfreezeFlag":true,"holdAdvanceDays":0,"installmentsRemaining":3,"lastInstallmentNumberProcessed":3,"lastInstallmentStatus":"SUCCESS","lastInstallmentDate":"2020-07-08","nextPaymentAmount":100.00,"nextPaymentDate":"2020-08-08","paymentFrequency":"MONTHLY","paymentAmount":"100.00","paymentStartDate":"2020-02-27","productType":"SOSO","outstandingPayments":900,"noOfRetriesAllowed":2,"type":"SOSO","status":"active","targetAmount":1200,"transactionType":"JMDB","targetEndDate":"2021-08-02","id":123,"creationDate":"2020-02-25T09:00:00"}}}';
                res.setStatus('OK');
                res.setStatusCode(200);
                res.setBody(body);
                res.setHeader('Content-Type', 'application/json');  
        

        // HttpResponse res= MCK001_ApiCalls.loadSavingPotsApi(req,200);

        final Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        ApiConnection.Response response= new ApiConnection.Response();
        response.isSuccess=true;
        response.responseData = resMap.get('data');
        // //END Fake Response
*/
        System.debug('load Pots details>>>>>' + JSON.serializePretty(response));

        //to remove view info
        if (response.isSuccess && null != response.responseData) {
            final Map<String, Object> responseData = (Map<String, Object>)response.responseData;

            if (SensitiveDataCleaner.loadIsDataCleaningRequired(customerId)) {
                SensitiveDataCleaner.removeSensitiveData(responseData, SENSITIVE_FIELDS_ACCOUNT_DETAILS);
            }
        }

        return response;
    }

    /**
     * Method to load Pot Transaction from API
     * @param customerId        String customer id
     * @param potId             String pot id
     * @param searchParametersJson      String json format for filter transaction
     * @return ApiConnection.Response
     */
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadPotTransactions(final String customerId, final String potId, final String searchParametersJson, String regionName) {

        //get baned date to display only transaction which isn't in segment = staff
        // List<Map<String, Datetime>> lstBanedDate = SensitiveDataCleaner.getStaffHideTransactionDate(customerId);

        // setup default response with no data

       /* ApiConnection.Response response = new ApiConnection.Response();
        response.isSuccess = true;
        response.responseData = new List<Object>();*/

        // final Boolean isTransactionsViewBlocked = SensitiveDataCleaner.loadIsDataCleaningRequired(customerId);
        // if ( false == isTransactionsViewBlocked ) {
        
            String path = '/api/v1/pots/' + potId + '/transactions';
          Account ObjAcc=[Select Id,x_canary__pc From account where CIF__pc=:customerId];
            

            String param = convertJsonToUrlParam(searchParametersJson);
            path = path + '?' + param;
            final HttpRequest req = con.createRequest('GET', path , customerId, regionName);
           if(ObjAcc.x_canary__pc != null){
                req.setHeader('x-canary',ObjAcc.x_canary__pc);//CH22
            }
            System.debug('loadPotTransactions>>>>>'+ObjAcc.x_canary__pc);

            final ApiConnection.Response response = con.makeCallout(req);
            // //START Fake Response

       
    /*            HttpResponse res = new HttpResponse();
                
                // Create Manually json response For Test Class
                String body = '{"meta":{"code":"","message":"List of transaction for Savings Pot has been retrieved successfully."},"data":{"potId":100,"name":"Vacation 2020","description":"Saving for my upcoming vacation","type":"no-goal","icon":"PalmTreeIcon.png","potAccountId":"BH96ABCO14184349101122","linkedAccountId":"BH96ABCO14184349101101","status":"active","transactions":[{"id":"989248099","transactionDate":"2019-07-01T12:29:08","valueDate":"2018-01-01","transactionType":"Account","transactionCurrency":{"code":"BHD","description":"Bahraini Dinar","decimalPlaces":3},"transactionExchangeRate":0.377,"accountCurrency":{"code":"BHD","description":"Bahraini Dinar","decimalPlaces":3},"transactionDescription1":"description 1","transactionDescription2":"description 2","transactionDescription3":"description 3","transactionDescription4":"description 4","transactionDescription5":"description 5","transactionDescription6":"description 6","amount":100.000,"originalAmount":100.000,"reference":"EBPP0039873","previousBalance":1000,"currentBalance":1100,"generateAdvice":true}]}}';
                res.setStatus('OK');
                res.setStatusCode(200);
                res.setBody(body);
                res.setHeader('Content-Type', 'application/json');  
        

        // HttpResponse res= MCK001_ApiCalls.loadSavingPotsApi(req,200);

        final Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        ApiConnection.Response response= new ApiConnection.Response();
        response.isSuccess=true;
        response.responseData = resMap.get('data');*/
        // //END Fake Response
            System.debug('loadPotTransactions>>>' + JSON.serializePretty(response));
            Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            Object[] transactions = (Object[])responseData.get('transactions');
			 System.debug('Transaction pots after getting response:'+transactions.size());
            //if there are requried clean data, it means segment is staff and view staff = false
            //we will filter staff transaction from it
            if (response.isSuccess && null != response.responseData){

                response.recordLength = transactions.size();
                //if view staff = true, we will display all transactions
                if(SensitiveDataCleaner.isAllowedViewStaffData(customerId)){
                    response.responseData = transactions;
                }
                //if view staff = false, we will display only transaction during Segment != staff
                else{
                    List<Map<String, Datetime>> lstBanedDate = SensitiveDataCleaner.getStaffHideTransactionDate(customerId);
                    response.responseData = SensitiveDataCleaner.filterBannedDate('transactionDate', lstBanedDate, transactions);
                }
            }

        // }
        return response;
    }

    /**
     * Method to convert Json String to Url param
     * @param jsonString        Json level 1 format only
     * @return string url param
     * @createdDate: SP 03-06-2020
     */
    public static String convertJsonToUrlParam(String jsonString){

        Map<String, Object> param = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

        String urlParam = '';
        for(String key: param.keySet()){
            String val = String.valueOf(param.get(key));
            urlParam += key + '=' + EncodingUtil.urlEncode(val, 'UTF-8') + '&';
        }

        urlParam = urlParam.removeEnd('&');
        return urlParam;

    }

//CH01: Start
    @AuraEnabled
    public static String createAuditRecordForSavingPotDetails(String accCIF, String potId){
        
        System.debug('Account CIF:'+accCIF);
        System.debug('Pot Id:'+potId);
        
        Customer_Pages_Audit_Trail__c cusAudit = new Customer_Pages_Audit_Trail__c();
        cusAudit.Customer_CIF__c = accCIF;
        cusAudit.User_Action__c = 'Viewed';
        cusAudit.User__c = userInfo.getUserId();
        cusAudit.Page_Name__c = 'Saving Pot Detail';
        cusAudit.Pot_ID__c = potId;
        insert cusAudit;
        
        return cusAudit.id;
    }
    //CH01: END


    // CH02 start  
     @AuraEnabled
    public static Boolean getJordanVisibility(String customerId) {
        return SensitiveDataCleaner.loadIsDataCleaningRequired(customerId);
    }
    // CH02 end  
}