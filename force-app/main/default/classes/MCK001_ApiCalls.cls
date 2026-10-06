/**
 * @author ANISS MBARKI
 * @date Création 15/12/2021
 * @date Modification 
 * @description MCK001_ApiCalls - Apex class (part of the Mocking Framework) that contains the mock call
 * @history Modifications : 
 *       #CH01 : Swapna add creditCardStatementApi method
 *       #CH02 : Aniss Mbarki add AccountStatementsApi method
 *       #CH03 : Wissal benqezza add Account Closure Api calls
 *       #CH04 : Swapna added getCreditCardStatusApi and  getCreditCardDetailsApi method
 *       #CH05 : Wissal benqezza add updateCreditCardRequestStatusApi
 *       #CH06 : Wissal benqezza add blockUnblockAccountApi & getAccountsListAllApi & getAccountHoldTransactionsApi
 *       #CH07 : Wissal benqezza add UpdateAccountForInterestRate 
 *       #CH08 : Aniss Mbarki add scheduled PLA payments API
 *       #CH12 : Amina BENABDELKRIM add callValidateAccountTerminationApi  method.
 *       #CH13 : Wissal benqezza add callUpdateFeeWaiverFlagReasonApi and callUncollectedFeesApi . Date 24/10/2022
 *       #CH14 : Wissal benqezza add PeriodicReviewBlockProductsApi and PeriodicReviewUnblockProductsApi . Date 21/11/2022
 *       #CH15 : Wissal benqezza add BenefitPayAPIUpdateApi . Date 07/02/2023
 *       #CH16 : Elmustapha ELGARNI add updateCustomerDetailsAPI . Date 08/10/2023
 *       #CH17 : Imane Tsioucha add ManualOnboardingAPI . Date 15/11/2023
 *       #CH18 : Imane Tsioucha add CustomerTotalBalanceAPI . Date 13/02/2024
 *       #CH20 : Imane Tsioucha add MoEngageDeleteAPI . Date 17/05/2024
 *       #CH21 : Jayanth add BondSukukAPIs . Date 24/09/2024
 */
//@IsTest
public class MCK001_ApiCalls implements  ITF001_ApiCalls, HttpCalloutMock {
    
    public static Integer statusCodeGlobal {get; set;}
    public static String decision = 'PASS';
    public static Boolean nameScreening = true;
    
    public HttpResponse getComplianceCaseStatusApi(HttpRequest request, Integer statusCode){
        System.debug('===========getComplianceCaseStatusApi from Mock Class========');
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{'+
                                '"data":'+
                                    '{'+
                                        '"status":"check",'+
                                        '"screeningResults":"P",'+
                                        '"decision":"'+decision+'"'+
                                    '},'+
                                '"meta":'+
                                    '{'+
                                        '"code":"COMP-1001",'+
                                        '"message":"Case status has been retrieved successfully."'+
                                    '}'+
                            '}';

        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }
    
    public HttpResponse callNameScreeningApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }


        // Create Manually json response For Test Class
        String body = '{'+
                                '"data":'+
                                    '{'+
                                        '"riskRating":"LOW",'+
                                        '"screeningResult":["PEPHIT"],'+
                                        '"eddDecision":"PASS",'+
                                        '"nameScreening":'+nameScreening+
                                    '},'+
                                '"meta":'+
                                    '{'+
                                        '"code":"COMP-1000",'+
                                        '"message":"Name screening and risk classification gets verified successfully."'+
                                    '}'+
                            '}';

        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }
    
    public HttpResponse callApiToCreateSupplementaryCardInVPlus(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{"data":{"transitionInProgress":false,"currentSegment":{"segmentName":"REGULAR","segmentCrmId":"Regular"},"currentCards":[{"id":"10010522439126747125063583","cardName":"VIRTUAL","cardDisplayName":"Virtual","cardAfsId":"TestVirtualCards","productType":"Virtual","cardMinimumBalance":0,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":false,"limit":0,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"},{"id":"100105224391267471250615229","cardName":"CLASSIC","cardDisplayName":"Classic","cardAfsId":"Debit Classic","productType":"Classic","cardMinimumBalance":20,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"limit":1000,"nextAnnualAnniversaryDate":"2021-06-18T07:55:26","discount":{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"}],"segmentOptions":[{"segmentName":"STAFF","segmentCrmId":"Staff"},{"segmentName":"ROYAL_FAMILY","segmentCrmId":"Royal Family"},{"segmentName":"PREMIUM","segmentCrmId":"Premium"},{"segmentName":"PREMIUM_PLUS","segmentCrmId":"Premium Plus"},{"segmentName":"SENSITIVE","segmentCrmId":"Sensitive"}],"cardOptions":[{"cardName":"WORLD","cardDisplayName":"World","cardAfsId":"MasterCardWorld","productType":"World","cardMinimumBalance":0,"order":1,"issuanceFee":0.000,"annualFee":37.500,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":1.875,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":39.375},{"cardName":"ELITE","cardDisplayName":"Elite","cardAfsId":"WORLD_ELITE","productType":"World Elite","cardMinimumBalance":0,"order":2,"issuanceFee":0.000,"annualFee":75.000,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":3.750,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":78.750}],"discountOptions":[{"name":"None","displayName":"No discount","discountPercentage":0},{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},{"name":"Discount50","displayName":"50 percent discount","discountPercentage":50},{"name":"Discount75","displayName":"75 percent discount","discountPercentage":75},{"name":"Free","displayName":"No charge","discountPercentage":100}]},"meta":{"code":"SGMT-1006","message":"Customer Segment Options retrieved successfully."}}';

        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }

    public HttpResponse callBlockAmountApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{"meta":{"code":10003,"displayMessage":"The amount has been blocked successfully"},'+
           '"data":{"blockId":1,"caseNumber": "test","letterReferenceNumber": "test","blockStatus": "test","blockedAmount": 125,"reminaingAmount": 123,'+
               '"currency":{"code":"BHD","decimal": "3"},'+                            
               '"accounts": [{"iban": "BH11ABCO22012121151515","currency":{"code":"BHD","decimal": "3"},"amountInAccountCurrency":1222,"holdAmount":123,"holdReferenceNumber":"dsfsf","exchangeRate": 1}]'+
               '}}';

        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }
    
    public HttpResponse callUnblockAmountApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{"meta":{"code":10003,"displayMessage":"The amount has been blocked successfully"},'+
        '"data":{"blockId":1,"caseNumber": "test","letterReferenceNumber": "test","blockStatus": "test","blockedAmount": 125,"reminaingAmount": 123,'+
            '"currency":{"code":"BHD","decimal": "3"},'+                            
            '"accounts": [{"iban": "BH11ABCO22012121151515","currency":{"code":"BHD","decimal": "3"},"amountInAccountCurrency":1222,"holdAmount":123,"holdReferenceNumber":"dsfsf","exchangeRate": 1}]'+
            '}}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }

    public ApiConnection.Response processCalloutResponse(final HTTPResponse res) {
        final ApiConnection.Response response = new ApiConnection.Response();
        try {
            if (200 == res.getStatusCode()) {
                response.isSuccess = true;
                if (String.isNotBlank(res.getBody())) {
                    final Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    response.responseData = resMap.get('data');
                }
            } else {
                response.isSuccess = false;
                try {
                    final Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    response.errorData = resMap.containsKey('meta')? resMap.get('meta') : resMap;
                } catch (Exception e) {
                    response.errorData = res.getBody();
                } 
                System.debug('response.errorData=' + response.errorData);
            }
        }catch(Exception ex){
                System.debug('ex.errorData=' + ex.getMessage());
        }
        return response;
    }

    //CH01 -Begin
    public ApiConnection.Response callCreditCardStatementApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        return processCalloutResponse(callCreditCardStatementApi(request,statusCode));
    }
    public HttpResponse callCreditCardStatementApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{  "meta": {"code": "STMT-1000","message": "Statement list has been retrieved successfully." },"data": {"statements": [{"statementDate": "2019-01-31","statementDescription": "January, 2019","dueDate": "2021-01-01","latePaymentGraceDate": "2021-01-01","openingBalance": 1000,"closingBalance": 900,"minimumDueAmount": 10,"pastDueAmount": 200,"overLimitAmount": 50,"accountId": "455512******4554"},{"statementDate": "2019-01-31","statementDescription": "January, 2019","dueDate": "2021-01-01","latePaymentGraceDate": "2021-01-01","openingBalance": 1000,"closingBalance": 900,"minimumDueAmount": 10,"pastDueAmount": 200,"overLimitAmount": 50,"accountId": "455512******4554"}]   }}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }

    public ApiConnection.Response callCreditCardStatementDetailsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        return processCalloutResponse(callCreditCardStatementDetailsApi(request,statusCode));
    }
    public HttpResponse callCreditCardStatementDetailsApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{"meta": {"code": "STMT-1001","message": "Statement details have been retrieved successfully." }, "data": {"fileMimeType" : "application/pdf","fileName" : "statement-20190101.pdf","fileContent" : "YXNmYWRzZmFkZHNhZmRhc2Zkc2Fkc2FkZnNhcw==","fileSize": "40"}}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }
    //CH01 -End

    //CH02 -Begin
    public ApiConnection.Response callAccountStatementsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        return processCalloutResponse(callAccountStatementsApi(request,statusCode));
    }
    public HttpResponse callAccountStatementsApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{"meta": {"code": "STMT-1000","message": "Statement list has been retrieved successfully."},"data": {"statements": [{"statementDate": "2019-01-31","statementDescription": "January, 2019"},{"statementDate": "2019-02-28","statementDescription": "February, 2019"}]}}'; 
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }

    public ApiConnection.Response callAccountStatementsDetailsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        return processCalloutResponse(callAccountStatementsDetailsApi(request,statusCode));
    }
    public HttpResponse callAccountStatementsDetailsApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        String fileContent = 'JVBERi0xLjcKJaGzxdcKMSAwIG9iago8PC9OYW1lczw8L0Rlc3RzIDQgMCBSID4';
        // Create Manually json response For Test Class
        String body = '{ "meta": {"code": "STMT-1001", "message": "Statement details have been retrieved successfully." }, "data": {"fileMimeType" : "application/pdf", "fileName" : "statement-20190101.pdf","fileContent" : "'+fileContent+'","fileSize": "40"}}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }
    //CH02 -End

    //CH03 -Begin
    public HttpResponse callAccountListApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{"meta":{"code":"ACCO-1000","message":"Accounts list for customer [2061256] has been retrieved successfully."},"data":{"accounts":[{"id":"BH35ABCO20612569101001","customerId":"2061256","alias":"BHD Account","productType":"account","productName":"BHD Account","category1":"","category2":"","detailsExist":true,"account":{"branch":"91084710","number":"206125691010","currency":{"code":"BHD","decimalPlaces":"3"},"iban":"BH35ABCO20612569101001","availableBalance":9222.573,"ledgerBalance":9933.573,"startDate":"2021-09-13","endDate":"2021-12-31","overdraftLimit":0.0,"overdraftExpiryDate":"2022-01-17","overdraftAvailableLimit":0.0,"paymentsAllowed":true,"status":"Active","creditInterestFrequencyCode":"200001","creditInterestFrequency":"MONTHLY","debitInterestFrequencyCode":"0","debitInterestFrequency":"N/A","creditGlAccount":"2011204","creditGlAccountDescription":"LIAB CURRENT ACCT - REGULAR","debitGlAccount":"2011204","debitGlAccountDescription":"LIAB CURRENT ACCT - REGULAR","minimumBalance":0.0,"maximumBalance":0.0,"valueBalance":9933.573,"holdAmount":711.0,"overdraftReviewDate":"1957-01-01","defaultAccount":true}}]}}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;     
    }
    public HttpResponse callValidateAccountClosureApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{"meta":{"code":"PROD-1015","message":"Product account closure validation successfully completed"},"data":{"eligible":false,"notEligibleReasons":[{"code":"MAIN_ACCOUNT"},{"code":"HOLD_AMOUNT"},{"code":"HAS_BALANCE"}]}}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;     
    }

    public HttpResponse callCloseAccountApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{"meta":{"code":"PROD-1015","message": "The validation has been performed successfully"},"data":{"eligible":false,"notEligibleReasons": "MAIN_ACCOUNT"}}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;     
    }
    //CH03 -End

    //CH04-Swapna-start
    public ApiConnection.Response getCreditCardStatusApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        return processCalloutResponse(getCreditCardStatusApi(request,statusCode));
    }
    public HttpResponse getCreditCardStatusApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
         String body = '{"meta":{"code":"CCRD-1100","message":"Card list has been retrieved successfully."},"data":{"currentCards":[{"id":"2660030003081773","cardSequenceNumber":"0001","expiryDate":"2027-04-22","cardProductionConfigurationId":2,"productMappingCode":"PLATINUM_CASHBACK_AND_REWARD_01","cardDisplayName":"ila Blu12e","cmsCardProductId":"003","cmsCardProductType":"01","isPrimary":true,"embossName":"Hasan Abdulla","maskedCardNumber":"511724XXXXXX1773","issueDate":"2024-04-22","provider":"Mastercard","isRequestedCard":false,"order":3000,"isDelinquent":false,"mustBeActivated":false,"isBankBlocked":false,"hasSupplementaryCardFees":false,"canRequestSupplementaryCard":false,"pendingRelease":false,"cardNature":"unsecured","supportedDigitalWallets":["APPLE_PAY"],"enabledCardActions":["SETUP_AUTOMATIC_PAYMENT","CHANGE_CREDIT_LIMIT","TRANSACTIONS_CONTROL"],"cardConfigurations":[{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"1"}],"enabledMainActions":[{"mainAction":"OFFERS","status":"SHOW_ENABLED","sortOrder":7}],"primaryCardPciNumber":"2660030003081773","applicationStatus":"","blockCode":"O","pendingRequests":[]}],"pendingCards":[{"id":"16511","cardProductConfigurationId":2,"cardType":"01","productMappingCode":"PLATINUM_CASHBACK_AND_REWARD_01","cardDisplayName":"ila Blue","cmsCardProductId":"003","cmsCardProductType":"01","status":"PENDING","order":1000,"caseId":"5007Y00000IlpWNQAZ","embossName":"MOHAMED ALBASRI","createdDate":"2021-09-26T14:45:36","modifiedDate":"2021-09-26T14:45:36","closureDate":"2021-09-26T14:45:36","creditLimit":4000.00000,"requestType":"CREDIT_CARD_ORDER","cardConfigurations":[{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"1"}]}],"cardOptions":[{"cardProductConfigurationId":4,"productMappingCode":"TITANIUM_CO_BRAND_01","cardDisplayName":"Titanium Gulf Air","cmsCardProductId":"005","cmsCardProductType":"01","order":2,"productStatus":"ORDER","cardConfigurations":[{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"0"}],"cardNature":["unsecured","secured"]}]}}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }

    public ApiConnection.Response getCreditCardDetailsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        return processCalloutResponse(getCreditCardDetailsApi(request,statusCode));
    }
    public HttpResponse getCreditCardDetailsApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{"meta":{"code":"CCRD-XXXX","message":"Card inquiry successfully completed."},"data":{"cif":"1293978","pciNumber":"2660030003081773","customerName":"ABC XYZ","usedCreditLimit":1049.5,"holdAmount":0.0,"lastPaymentAmount":0.0,"creditLimit":2000.0,"availableCreditLimit":950.5,"availableCashLimit":1150.5,"currentDues":60.0,"minimumDues":230.0,"totalDues":230.0,"pastDues":170.0,"paymentDueDate":"2024-09-05","recoverOption":0,"pointsBalance":0.0,"lastStatmentBalance":1049.5,"cashLimit":1200.0,"paymentSinceLastStatements":0.0,"isPrimary":true,"embossName":"Hasan Abdulla","cmsAccountId":"511724XXXXXX1773","isReissued":false,"currentPurchaseAmount":0.0,"currentUsedCashAmount":0.0,"currentReturnsAmount":0.0,"currency":{"code":"BHD","decimalPlaces":3},"expiryDate":"2027-04-22","cmsProductDescription":"ILA BLUE","issueDate":"2024-04-22","primaryCardPciNumber":"DEF08FC548C1BB41","cmsCardProductId":"003","email":"alaa.m.hossam@gmail.com","mobileNumber":"009765654589","unbilledAmount":0.0,"lastStatementDate":"2024-08-21","lastTransactionDate":"2024-04-23","bankAccountId":"397891010BHD    ","plasticCardType":"P","plasticCardDescription":"ILA BLUE","accountBlockCode1":"O","accountBlockCode2":"T","accountBlockDate1":"2024-08-05","directDebitPercentage":0,"cashbackAmount":0.000,"totalCashbackAmount":0,"paymentLastStatementBalance":1049.5,"paymentMinimumDues":230.0,"paymentUsedCreditLimit":1049.5,"recentCreditsAmount":0.0,"recentDebitsAmount":0.0}}';                             

        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }
    //CH04-Swapna-End

    //CH05 -Begin
    public HttpResponse updateCreditCardRequestStatusApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{"meta":{"code":"CCRD-1500","message":"Credit card request status has been updated successfully."}}';

        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
         
        return response ;
    }
    //CH05 -End
    
    public HttpResponse updatePrepaidSupplementaryCreditCardApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{"meta":{"code":"CCRD-1500","message":"Credit card request status has been updated successfully."}}';

        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
         
        return response ;
    }

    //CH06 -Begin
    public HttpResponse blockUnblockAccountApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{    "meta": {        "code": "ACCT-1008",        "message": "Account has blocked successfully."    },   "data": {}}';

        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
         
        return response ;
    }

    public HttpResponse getAccountsListAllApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{"meta": {"code": "ACCO-1000","message": "Accounts list for customer [8610001] has been retrieved successfully."},"data": {"allowAccountCreation": true,"accounts": [{"id": "BH97ABCO86100019101101","customerId": "8610001","alias": "Neo BANK Saving Account 1","productType": "account","productName": "Neo BANK Saving Account 1","category1": "","category2": "","detailsExist": true,"defaultAccount": true,"account": {"number": "861000191011","currency": {"code": "USD","decimalPlaces": "2"},"iban": "BH97ABCO86100019101101","availableBalance": 586828,"ledgerBalance": 10090344,"startDate": "2019-02-08","endDate": "2019-02-10","overdraftLimit": 0,"overdraftExpiryDate": "2019-05-03","overdraftAvailableLimit": 0,"paymentsAllowed": true,"creditInterestFrequencyCode": "200001","creditInterestFrequency": "MONTHLY","debitInterestFrequencyCode": "200001","debitInterestFrequency": "MONTHLY","creditGlAccount": "2011204","creditGlAccountDescription": "LIAB CURRENT ACCT - REGULAR","debitGlAccount": "2011204","debitGlAccountDescription": "LIAB CURRENT ACCT - REGULAR","minimumBalance": 0,"maximumBalance": 0,"valueBalance": 10090344,"holdAmount": 9503516,"overdraftReviewDate": "1957-01-01"}},{"id": "BH32ABCO86100019101301","customerId": "8610001","alias": "Neo BANK Current Account 1","productType": "account","productName": "Neo BANK Current Account 1","category1": "","category2": "","detailsExist": true,"defaultAccount": false,"account": {"number": "861000191013","currency": {"code": "USD","decimalPlaces": "2"},"iban": "BH32ABCO86100019101301","availableBalance": 179911,"ledgerBalance": 179911,"startDate": "2019-02-08","endDate": "2019-02-10","overdraftLimit": 0,"overdraftExpiryDate": "2019-05-03","overdraftAvailableLimit": 0,"paymentsAllowed": true,"creditInterestFrequencyCode": "200001","creditInterestFrequency": "MONTHLY","debitInterestFrequencyCode": "200001","debitInterestFrequency": "MONTHLY","creditGlAccount": "2011204","creditGlAccountDescription": "LIAB CURRENT ACCT - REGULAR","debitGlAccount": "2011204","debitGlAccountDescription": "LIAB CURRENT ACCT - REGULAR","minimumBalance": 0,"maximumBalance": 0,"valueBalance": 179911,"holdAmount": 0,"overdraftReviewDate": "1957-01-01","accountType":"KANZ"}}]}}';

        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
         
        return response ;
    }

    public HttpResponse getAccountHoldTransactionsApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{"meta": {"code": "TRAN-1009","message": "Transaction Details for Account Id has been retrieved successfully."},"data": {"transactions": [{"id": "BH09ABCO00929029882","holdDate": "2019-01-01","holdExpiryDate": "2019-08-01","holdType": "Release Debit Card Transaction","holdCurrency": "","holdAmount": "100","holdReferenceNumber": "1254555","previousBalance": "2019-01-31","currentBalance": "","generateAdvice": "completed","holdDescription1":"","holdDescription2":"","holdDescription3":"","holdDescription4":"","holdDescription5":"","holdDescription6":""}]}}';

        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
         
        return response ;
    }
    //CH06 -End

    //CH07 -End
    public HttpResponse UpdateAccountForInterestRate(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{"meta":{"code":"ACCO-1001","message":"Account Details for given account has been retrieved successfully."},"data":{"customerId":"989248099","id":"BH09ABCO00929029882","alias":"Wife Account","productType":"Account","productName":"Saving Account","category1":"","category2":"","account":{"number":"100001009280","branch":"","currency":{"code":"BHD","description":"Bahraini Dinar","decimalPlaces":3},"iban":"BH09ABCO00929029882","availableBalance":100,"ledgerBalance":100,"startDate":"2018-01-09","endDate":"2018-02-09","status":"Active","overdraftLimit":100000,"overdraftExpiryDate":"2020-12-31","overdraftAvailableLimit":1000000,"paymentsAllowed":true}}}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
         
        return response ;
    }
    //CH07 -End

    //CH08 -Begin
    public ApiConnection.Response callScheduledPlaPaymentsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        return processCalloutResponse(callScheduledPlaPaymentsApi(request,statusCode));
    }
    public HttpResponse callScheduledPlaPaymentsApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{"meta":{"code":"PLAS-1028","message":"Prize linked account scheduled payments have been retrieved successfully"},"data":{"paymentSchedules":[{"id":2,"amount":50.00,"currency":"BHD","frequency":"MONTHLY","startDate":"2022-06-07 00:00:00","nextPaymentDate":"2022-07-31 00:00:00","endOfMonth":true,"status":"NEW"},{"id":1,"amount":59.00,"currency":"BHD","frequency":"MONTHLY","startDate":"2022-06-07 00:00:00","nextPaymentDate":"2022-07-31 00:00:00","endOfMonth":true,"status":"NEW"}]}}'; 
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }

    public ApiConnection.Response callScheduledPlaPaymentDetailsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        return processCalloutResponse(callScheduledPlaPaymentDetailsApi(request,statusCode));
    }
    public HttpResponse callScheduledPlaPaymentDetailsApi(HttpRequest request, Integer statusCode){

        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        String body = '{"meta":{"code":"PLAS-3000","message":"Prize linked account scheduled payments transactions have been retrieved successfully"},"data":{"paymentSchedules":[{"iban":"BH15ABCO12956049101001","amount":59.00,"currency":{"code":"BHD"},"transactionReference":"PADB22060214103014","transactionDate":"2022-06-02T14:10:31","status":"SUCCESS"}]}}'; 

        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }
    //CH08 -End

    //CH12 -Start
    public HttpResponse callValidateAccountTerminationApi(HttpRequest request, Integer statusCode){
            HttpResponse response = new HttpResponse();
            if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

            // Create Manually json response For Test Class
            String body = '{"meta":{"code":"PROD-1015","message":"Product account termination validation successfully completed"},"data":{"eligible":false,"notEligibleReasons":[{"code":"MAIN_ACCOUNT"},{"code":"HOLD_AMOUNT"},{"code":"HAS_BALANCE"}],"eligibilityChecksStatus":[{"eligibilityStatus":true}]}}';
        	response.setStatus('OK');
            response.setStatusCode(statusCode);
            response.setBody(body);
            response.setHeader('Content-Type', 'application/json');
            
            return response ;     
        }
    //CH12 -END

    public HttpResponse respond(HTTPRequest req) {
        System.debug('===========respond========');
        String endPoint = req.getEndpoint();
        String method = req.getMethod();
        if ( endPoint != null && endPoint.contains('/api/v1/compliances') && method != null && method.contains('GET') ){
            return getComplianceCaseStatusApi(req, statusCodeGlobal);
        }else if( endPoint != null && endPoint.contains('/api/v1/compliances/direct') && method != null && method.contains('POST') ){
            return callNameScreeningApi(req, statusCodeGlobal);
        }else if(endPoint != null && endPoint.contains('/api/v1/credit-cards/request') && method != null && method.contains('PUT')){
            return callApiToCreateSupplementaryCardInVPlus(req, statusCodeGlobal);
        }else if(endPoint != null && endPoint.contains('/api/v1/customer-products/amount-block') && method != null && method.contains('POST')){
            return callBlockAmountApi(req, statusCodeGlobal);
        }

        //CH01 -Begin    
        else if(endPoint != null && endPoint.contains('/api/v1/statements/credit-card') && method != null && method.contains('POST')){
            return callCreditCardStatementApi(req , statusCodeGlobal);
        }else if(endPoint != null && endPoint.contains('/api/v1/statements/credit-card/details') && method != null && method.contains('POST')){
            return callCreditCardStatementDetailsApi(req , statusCodeGlobal);
        }
        //CH01 -End

        //CH02 -Begin    
        else if(endPoint != null && endPoint.contains('/api/v1/statements') && method != null && method.contains('POST')){
            return callAccountStatementsApi(req , statusCodeGlobal);
        }else if(endPoint != null && endPoint.contains('/api/v1/statements/details') && method != null && method.contains('POST')){
            return callAccountStatementsDetailsApi(req , statusCodeGlobal);
        }
        //CH02 -End

        //CH03 -Begin    
        else if(endPoint != null && endPoint.contains('/api/v1/accounts') && method != null && method.contains('GET')){
            return callAccountListApi(req , statusCodeGlobal);
        }    
        else if(endPoint != null && endPoint.contains('/api/v1/customer-products/account/closure/validation') && method != null && method.contains('GET')){
            return callValidateAccountClosureApi(req , statusCodeGlobal);
        }    
        else if(endPoint != null && endPoint.contains('/api/v1/customer-products/account') && method != null && method.contains('DELETE')){
            return callCloseAccountApi(req , statusCodeGlobal);
        }
        //CH03 -End
        
        //CH04-start
        else if ( endPoint != null && endPoint.contains('/api/v1/credit-cards?') && method != null && method.contains('GET') ){
            return getCreditCardStatusApi(req, statusCodeGlobal);
        }else if ( endPoint != null && endPoint.contains('/api/v1/credit-cards/{cardId}/details') && method != null && method.contains('GET') ){
            return getCreditCardDetailsApi(req, statusCodeGlobal);
        }
        //CH04-End
        
        else{
            return callUnblockAmountApi(req, statusCodeGlobal);
        }
    }
    //CH13 -Begin
    public HttpResponse callUpdateFeeWaiverFlagReasonApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{"meta":{"code":"ACCO-1012","message":"Fee Waiver Flag And Reason are updated successfully"}}';

        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
         
        return response ;
    }
        
        public ApiConnection.Response callUncollectedFeesApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        return processCalloutResponse(callUncollectedFeesApi(request,statusCode));
         }
        public HttpResponse  callUncollectedFeesApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
         String body = '{"meta": {"code": "TRAN-1009","message": "Transaction Details for Account Id has been retrieved successfully."},"data": {"transactions": [{"id": "BH09ABCO00929029882","holdDate": "2019-01-01","holdExpiryDate": "2019-08-01","holdType": "Release Debit Card Transaction","holdCurrency": "","holdAmount": "100","holdReferenceNumber": "1254555","previousBalance": "2019-01-31","currentBalance": "","generateAdvice": "completed","holdDescription1":"","holdDescription2":"","holdDescription3":"","holdDescription4":"","holdDescription5":"","holdDescription6":""}]}}';

        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');         
        return response ;
    }
    //CH13 -End
   //CH14 -Start
    public HttpResponse PeriodicReviewBlockProductsApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{  	   "meta":{  		  "code":10003,		  "displayMessage":"The validation for {CIF} has been processed successfully."	   }	}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
         
        return response ;
    }
    public HttpResponse PeriodicReviewUnblockProductsApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{  	   "meta":{  		  "code":10003,		  "displayMessage":"The validation for {CIF} has been processed successfully."	   }	}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
         
        return response ;
    }
     //CH14 -End
     //CH15 -Start
    public HttpResponse BenefitPayAPIUpdateApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{  	 { "meta": { "code": "CUST-1008", "message": "Customer Details have been updated successfully."}}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
         
        return response ;
    }
     //CH15 -End


     //CH16 -Start
    public HttpResponse updateCustomerDetailsAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{  	 { "meta": { "code": "CUST-1008", "message": "Customer Details have been updated successfully."}}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
         
        return response ;
    }
     //CH16 -End
     //CH17 -Start
    public HttpResponse ManualOnboardingAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        String body = '{  	 { "meta": { "code": "CUST-1008", "message": "Case Closed successfully."}}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
         
        return response ;
    }
     //CH17 -End

     //CH18 -Start
    public HttpResponse CustomerTotalBalanceAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        String body = '{"meta":{"code":"PROD-0001","displayMessage":"Total Balance retrived successfully"},"data":{"total_balance":9666.321,"currency":"BHD","decimalPlaces":"3"}}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
         
        return response ;
    }
     //CH18 -End

     //CH20 -Start
    public HttpResponse MoEngageDeleteAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        String body = '{ { "meta": { "code": "MOEN-1000", "displayMessage": "Your request has been accepted and will be processed soon."}}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
         
        return response ;
    }
     //CH20 -End
    
  // CH21 -Start
       public HTTPResponse GetInstrumentAPI(HTTPRequest request, Integer statusCode ) {
            String body = '{"meta":{"code":"bond-1000","message":"Resultsfetchedsuccessfully."},"data":{"instruments":[{"isinTypeCBB":"","isinCodeCBB":"","issueNoCBB":"","issueAmountCBB":"","invitationDateCBB":"12-01-2024","tenderDateCBB":"12-01-2024","issueDateCBB":"12-01-2024","maturityDateCBB":"12-01-2024","rateCBB":5.5,"issuePrice":4.99,"period":{"tenure":"","tenure_type":""},"nextCouponDate":"","couponDistributionFlag":true,"couponDistributionFrequency":9,"isinName":"","group":"","securityType":"","currency":"","bidDueDate":"12-01-2024","minimumOrderAmount":5,"maximumOrderAmount":1000000000,"processingFeesPercentage":90.987,"processingFeesMinimumAmount":99,"processingFeesVAT":9.009,"creationDate":"","allowActions":["cancel"]}]}}}';
            HTTPResponse res = new HTTPResponse();
           if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(statusCode);
            return res;
        } 
        public HTTPResponse GetInvestmentDetailsAPI(HTTPRequest request, Integer statusCode ) {
            String body = '{"meta":{"code":"BOND-1000","message":"Resultsfetchedsuccessfully."},"data":{"investments":[{"id":"d","CrmRefrence":"","status":"","funding_account_iban":"","bid_creation_date":"","bid_amount":33.421,"bid_amount_vat":33.421,"bid_amount_fee":33.421,"bid_allocation_date":"","bid_allocation_percentage":"","bid_allocation_amount":333,"bid_allocation_amount_fee":44,"bid_allocation_amount_vat":22,"CBB_percentage_of_total":144,"yield_rate":0.390,"maturity_amount":778,"cancellation_date":"","selling_price":33,"selling_date":"","proceeds_credited_on":"","proceeds_credited_to_account":"","creation_date":"","instrument":{"isinTypeCBB":"","isinCodeCBB":"","issueNoCBB":"","issueAmountCBB":"","invitationDateCBB":"","tenderDateCBB":"","issueDateCBB":"","maturityDateCBB":"","rateCBB":5.5,"issuePrice":4.99,"period":{"tenure":"","tenure_type":""},"nextCouponDate":"","couponDistributionFlag":true,"couponDistributionFrequency":9,"isinName":"","group":"","securityType":"","currency":"","bidDueDate":"","minimumOrderAmount":5.000,"minimumNoOfUnits":99.987,"processingFeesPercentage":90.987,"processingFeesMinimumAmount":99,"processingFeesVAT":9.009,"creationDate":"","allowActions":["cancel"],}}]}}';
            HTTPResponse res = new HTTPResponse();
           if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(statusCode);
            return res;
        } 
    
    //CH21 -Begin
    public ApiConnection.Response callBondSukukStatementsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        return processCalloutResponse(callBondSukukStatementsApi(request,statusCode));
    }
    public HttpResponse callBondSukukStatementsApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{"meta": {"code": "STMT-1000","message": "Statement list has been retrieved successfully."},"data": {"statements": [{"statementDate": "2019-01-31","statementDescription": "January, 2019"},{"statementDate": "2019-02-28","statementDescription": "February, 2019"}]}}'; 
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }
    
        public ApiConnection.Response callBondSukukStatementsDetailsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        return processCalloutResponse(callBondSukukStatementsDetailsApi(request,statusCode));
    }
    public HttpResponse callBondSukukStatementsDetailsApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        String fileContent = 'JVBERi0xLjcKJaGzxdcKMSAwIG9iago8PC9OYW1lczw8L0Rlc3RzIDQgMCBSID4';
        // Create Manually json response For Test Class
        String body = '{ "meta": {"code": "STMT-1001", "message": "Statement details have been retrieved successfully." }, "data": {"fileMimeType" : "application/pdf", "fileName" : "statement-20190101.pdf","fileContent" : "'+fileContent+'","fileSize": "40"}}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }
    //CH21 -End
}