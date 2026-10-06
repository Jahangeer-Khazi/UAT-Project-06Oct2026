/**
* @description       : Service class to call Different Apis & complex logic for Loans requirement.
* @author            : Aniss Mbarki
* @group             : 
* @last modified on  : 07-08-2024
* @last modified by  : Elmustapha ELGARNI
* @History : 
**/
public without sharing class Loans_ServiceManagerHandler {
    
    private static String CLASS_NAME = Loans_ServiceManagerHandler.class.getName();
    private static ApiConnection con = new ApiConnection();

    public class APIResponse {
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public Object responseData;
        @AuraEnabled
        public Object errorData;
        @AuraEnabled
        public Object headerData;
        @AuraEnabled
        public Integer recordLength;

        public HttpRequest requestHttp;
        public HttpResponse responseHttp;
    }
    
    /**
    * @description  Class used to conevert a number to words
    * @author elmustapha Elgarni | 14/08/2024
    **/
    public without sharing class numberToWordsUtilsClass {

        private final String[] BELOW_TWENTY = new String[]{ 'Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'};  
        private final String[] TENS = new String[]{'', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'};       
        private final String[] THOUSANDS = new String[]{'', 'Thousand', 'Million', 'Billion'};
            
        public String numberToWords(Integer num) {
            if (num == 0) {
                return 'Zero';
            }
            
            String result = '';
            Integer i = 0;
            
            while (num > 0) {
                if (Math.Mod(num, 1000) != 0) {
                    result = helper(Math.Mod(num, 1000)) + THOUSANDS[i] + ' ' + result;
                }
                num /= 1000;
                i++;
            }
            
            return result.trim();
        }

        private String helper(Integer num) {
            if (num == 0) {
                return '';
            } else if (num < 20) {
                return BELOW_TWENTY[num] + ' ';
            } else if (num < 100) {
                return TENS[num / 10] + ' ' + helper(Math.Mod(num, 10));
            } else {
                return BELOW_TWENTY[num / 100] + ' Hundred ' + helper(Math.Mod(num, 100));
            }
        }
    }
    
    /**
    * @description  method used to throw AuraHandledException with custom message
    * @author Aniss Mbarki | 07/12/2023 
    **/
    public static void thowException(String message){
        AuraHandledException ahe = new AuraHandledException(message);
        ahe.setMessage(message);
        throw ahe;
    }
    
    public static System_Action__c setSystemAction(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Final Integer statCode, Final String strAction, Final String strType) {
        System_Action__c action = new System_Action__c();
        action.Account_Number__c = custId;
        action.Action__c = strAction;
        //action.Card_Number__c = objCase.cc_Requested_Card_Type__c;
        action.Case__c = CaseId;
        action.Account__c = AccId;
        action.Endpoint__c = path;
        action.Method__c = method;
        action.HTTP_Response_Code__c = statCode;
        action.Origin__c = 'CRM';
        action.Request_Body__c = reqBody;
        action.Response_Body__c = resBody;
        action.Target__c = 'Orchestration Layer';
        action.Type__c = strType;
        
        return action; 
    }
    
    
    public static ApiConnection.Response formatResponse(HttpResponse res){
        ApiConnection.Response response = new ApiConnection.Response();
        ///////////////////
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
        ///////////////
        return response;
    }

    public static APIResponse formatAPIResponse(HttpResponse res,HttpRequest req){
        APIResponse response = new APIResponse();
        response.requestHttp = req;
        response.responseHttp = res;
        ///////////////////
        if (200 == res.getStatusCode()) {
            response.isSuccess = true;
            if (String.isNotBlank(res.getBody())) {
                final Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                response.responseData = resMap.get('data');
                response.headerData = resMap.get('header');
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
        ///////////////
        return response;
    }


    
    
    
    /**
    * @description  method used to call "Get Loan Transactions Api".
    * @author Aniss Mbarki | 07/12/2023
    **/
       
    public static ApiConnection.Response loadLoanTransactions(final String customerId,final String searchParametersJson, String regionName){
        PAD.debugLogBegin(CLASS_NAME, 'loadLoanTransactions', '');
         System.debug('searchParametersJson !!!!  ' +searchParametersJson);
        // setup default response with no data
        ApiConnection.Response response = new ApiConnection.Response();
        response.isSuccess = true;
        response.responseData = new List<Object>();
        final String path = '/api/v1/transactions?';
        final HttpRequest req = con.createRequest('POST', path, customerId, regionName);
        req.setTimeout(120000);
        req.setBody(searchParametersJson);
        System.debug('Request Endpoint: ' +req.getEndpoint());
        System.debug('Request Method: ' +req.getMethod());
        System.debug('Request Body:'+req.getBody());

        //#CH01 : start (add "x-canary" logic)
        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
        if(accs!= null && accs.size()>0){
            System.debug('x-canary added :'+accs.get(0).x_canary__pc);
            if(accs.get(0).x_canary__pc != null){
                req.setHeader('x-canary', accs.get(0).x_canary__pc);
            }
        }
        //#CH01 : end
        
        // HttpResponse responseHttp = new Loans_ServiceApiCallsMock().callGetLoanTransactionsApi(req,200);//fake response
        HttpResponse responseHttp = Loans_ServiceApiCallsEM.callGetLoanTransactionsApi(req,200);//real Api call        
        response = formatResponse(responseHttp);
        System.debug('loadLoanTransactions>>>>>' + JSON.serializePretty(response));
        
        Map<String, Object> responseData = (Map<String, Object>)response.responseData;
        System.debug('Response data keys:'+responseData.keySet());
        Object[] transactions = (Object[])responseData.get('transactions');
        System.debug('Transaction Length after getting response:'+transactions.size());
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
        System.debug('get Loan Transactions response: '+response);
        return response;
    }
    

     /**
    * @description  method used to call "Get Loan Payments Schedule Api".
    * @author Omar AITO-GRAM| 29/02/2024
    **/
    public static APIResponse callGetLoanPaymentsSchedule(Id caseId,String customerId, String searchParametersJson, String regName,Boolean saveLog){
        PAD.debugLogBegin(CLASS_NAME, 'callGetLoanPaymentsSchedule', '');
        String regionName = regName ;
        String caseModel;
        List<Account> lstAcc = [SELECT Id,Region_Flag__c,Subscription_Model__pc FROM Account WHERE CIF__pc = :customerId ];
        
        if(caseId != null){
            List<Case> cases = [SELECT Id,Case_Model__c,Region_Flag__c FROM Case WHERE Id = :caseId];
            if(cases != null && cases.size()>0){
                regionName = cases.get(0).Region_Flag__c;
                caseModel = cases.get(0).Case_Model__c;
            }
        }
        else if (regionName == null){
            if(lstAcc != null && lstAcc.size()>0){
                regionName = lstAcc.get(0).Region_Flag__c;
                caseModel = lstAcc.get(0).Subscription_Model__pc;
            }  
        }
        
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
        HttpRequest req = con.createRequest('POST', '/api/v1/loans/schedule?', customerId, regionName);

        req.setTimeout(60000);
        req.setBody(searchParametersJson);
        
        System.debug('callGetLoanPaymentsSchedule Endpoint : '+req.getEndpoint());
        System.debug('Request Body:'+req.getBody());
        
        //Call Mock Response
       
        HttpResponse response = Loans_ServiceApiCallsEM.callGetLoanPaymentsScheduleApi(req,200);//real api call
        //HttpResponse response = new Loans_ServiceApiCallsMock().callGetLoanPaymentsSchedule(req,200);

        if(saveLog){
            List<System_Action__c> lstSA = new List<System_Action__c>();
            //Always create system log    
            lstSA.add(SM001_ApiCalls.setSystemAction( req.getBody(),response.getBody(),
                                                        req.getEndpoint(),req.getMethod(),
                                                        caseId,customerId,lstAcc.get(0).Id,response.getStatusCode(), 
                                                        'call Get Schedule List API', null
                                                    ));
    
            if(lstSA.size() > 0){
                insert lstSA;
            }
        }

        System.debug('callGetLoanPaymentsSchedule response : '+response);
        APIResponse resp = formatAPIResponse(response,req);
        
        return resp;
    }

    /**
    * @description  method used to call "Get Loans Options Api".
    * @author Elmustapha elgarni | 11/12/2023
    **/
    public static ApiConnection.Response callLoansOptionsAPI(String customerId, String caseModel){
        PAD.debugLogBegin(CLASS_NAME, 'callLoansOptionsAPI', '');
        
        List<Account> lstAcc = [SELECT Id,Region_Flag__c,Subscription_Model__pc FROM Account WHERE CIF__pc = :customerId ];
        String regionName ;

        if(lstAcc != null && lstAcc.size()>0){
            regionName = lstAcc.get(0).Region_Flag__c;
            if(caseModel == null || caseModel == ''){
                caseModel = lstAcc.get(0).Subscription_Model__pc;
            }
        }  
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
       
        HttpRequest req = con.createRequest('GET', System.Label.LoansOptionsAPIPath, customerId, regionName);
        
        req.setTimeout(60000);
        
        System.debug('Request Endpoint: ' +req.getEndpoint());
        System.debug('Request Method: ' +req.getMethod());
        System.debug('Request Body:'+req.getBody());
        
        if(Test.isRunningTest()) {
            req.setHeader('Case-Model', caseModel);
            req.setHeader('customerId', customerId);
        }
        
        //Call Mock Response
        HttpResponse response = Loans_ServiceApiCallsEM.callLoansOptionsAPI(req,200);//real api call
        //HttpResponse response = new Loans_ServiceApiCallsMock().callLoansOptionsAPI(req,200);

        System.debug('callLoansOptionsAPI response : '+response);
        System.debug('callLoansOptionsAPI response body: '+response.getBody());
        
        return formatResponse(response);
    }
    
    //   omar start
    public static ApiConnection.Response callLoansEarlySettlementAPI(String customerId, String loanId, String caseModel){
         
        List<Account> lstAcc = [SELECT Id,CIF__pc ,Region_Flag__c,Subscription_Model__pc FROM Account WHERE CIF__pc = :customerId ];
        String regionName ;
        // String caseModel;

        if(lstAcc != null && lstAcc.size()>0){
            regionName = lstAcc.get(0).Region_Flag__c;
            if(caseModel == null || caseModel == ''){
                caseModel = lstAcc.get(0).Subscription_Model__pc;
            }
        }  
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }

        HttpRequest request1 = con.createRequest('GET', '/api/v1/loans/early-settlement-details/' + loanId, regionName);
            //   system.debug('customerId : '+ caseObj.Customer_CIF__c);
                request1.setHeader('customerId', lstAcc.get(0).CIF__pc);
                request1.setTimeout(60000);
                HttpResponse response1 = Loans_ServiceApiCallsEM.getLoanEarlySettlementDetailsAPI(request1,200);//real api call
                System.debug('getLoanEarlySettlementDetailsAPI response : '+ response1 );
                System.debug('getLoanEarlySettlementDetailsAPI response body: '+response1.getBody());
            
            return formatResponse(response1);
    }
    // omar end


    /**
    * @description  method used to call "get User Application Info API".
    * @author Elmustapha elgarni | 13/12/2023
    **/
    public static ApiConnection.Response getUserApplicationInfoAPI(String customerId,String loanProductConfigurationId, String caseModel){
        PAD.debugLogBegin(CLASS_NAME, 'getUserApplicationInfoAPI', '');
        List<Account> lstAcc = [SELECT Id,Region_Flag__c,Subscription_Model__pc,Segment__pc, Alburaq_Segment__pc, Nationality__pc  FROM Account WHERE CIF__pc = :customerId ];
        String regionName ;
        String segment;
        String nationality;
        string endpoint = System.Label.Loans_getUserApplicationInfoAPI;
        system.debug('lstAcc: '+lstAcc);
        if(lstAcc != null && lstAcc.size()>0){
            regionName = lstAcc.get(0).Region_Flag__c;
            if(caseModel == null || caseModel == ''){
                caseModel = lstAcc.get(0).Subscription_Model__pc;
            }
            
            segment = lstAcc.get(0).Segment__pc;
            nationality = lstAcc.get(0).Nationality__pc ;
        }

        if(loanProductConfigurationId != null && loanProductConfigurationId != ''){
            endpoint = endpoint +'&loanProductConfigurationId='+loanProductConfigurationId;
        }
        if(nationality != null && nationality != ''){
            endpoint = endpoint +'&nationality='+nationality;
        }
        if(segment != null && segment != ''){
            endpoint = endpoint +'&segment='+segment;
        }

       if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
        System.debug('getUserApplicationInfoAPI loanProductConfigurationId : '+loanProductConfigurationId);
        HttpRequest req = con.createRequest('GET', endpoint, customerId, regionName);
        req.setTimeout(60000);
        
        System.debug('Request Endpoint: ' +req.getEndpoint());
        System.debug('Request Method: ' +req.getMethod());
        System.debug('Request Body:'+req.getBody());
        
        HttpResponse response = Loans_ServiceApiCallsEM.getUserApplicationInfoAPI(req,200);//real api call
        // HttpResponse response = new Loans_ServiceApiCallsMock().getUserApplicationInfoAPI(req,200);
        System.debug('get UserApplicationInfo response: '+response);
        return formatResponse(response);
    }
    


    /**
    * @description  method used to call "Create Loan Application API".
    * @author Elmustapha elgarni | 20/12/2023
    **/
    public static ApiConnection.Response createLoanApplicationApi(Case caseObj){
        PAD.debugLogBegin(CLASS_NAME, 'createLoanApplicationApi', '');
        String caseId =caseObj.Id ;
        List<CaseAnnex__c> CaseAnnexList = new List<CaseAnnex__c>();
        String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('CaseAnnex__c');
        String soqlQuery = 'SELECT ' + fields + ' FROM CaseAnnex__c WHERE Case__c =:caseId';
        CaseAnnexList = new List<CaseAnnex__c>((List<CaseAnnex__c>)Database.query(soqlQuery));
        CaseAnnex__c caseAnnexObj = new CaseAnnex__c();
        if (CaseAnnexList != null && CaseAnnexList.size() > 0) {
            caseAnnexObj =CaseAnnexList[0];
        }

        
        String regionName = caseObj.Region_Flag__c;
        
        if (caseObj.Case_Model__c == 'alburaq') {
            regionName += '_alburaq';
        }
        String apiMethod = 'POST';
        HttpRequest request = con.createRequest(apiMethod, '/api/v1/loans/application',regionName); //System.Label.CC_EndPointCreditCardRequest
        system.debug('customerId : '+ caseObj.Customer_CIF__c);
        request.setHeader('customerId', caseObj.Customer_CIF__c);
         request.setTimeout(60000);  
        
        // Create a Map to represent the request body (Common for Creation and update)
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('loanProductConfigurationId', caseObj.Card_Product_Configuration_Id__c);
            requestBody.put('employmentStatus', caseObj.cc_Employment_Status__c);
            requestBody.put('employerId', null);
            requestBody.put('employerName', caseObj.cc_Employer_Name__c);
            requestBody.put('grossIncome', caseAnnexObj?.cx_ln_Gross_Income_2__c); 
            requestBody.put('isCurrentAddressValid', caseObj.cc_Use_Current_Address__c);
            requestBody.put('residenceStatus', caseObj.cc_Residence_Occupancy_Status__c);
            requestBody.put('currentAddresslivingPeriod', caseObj.cc_Number_years_at_current_residence_jo__c); //////// Number not picklist value /// use bahrain field
            requestBody.put('maritalStatus', caseObj.cc_Marital_Status__c);
            requestBody.put('numberOfDependents', caseObj.cc_Number_of_Dependents__c);
            requestBody.put('academicQualification', caseObj.cc_Academic_Qualifications__c);
            requestBody.put('personsContact', caseObj.cc_Friend_s_Contact_Number__c);
            requestBody.put('personsName', caseObj.cc_Friend_s_Name__c);
            requestBody.put('loanAmount', caseAnnexObj?.cx_ln_Requested_Loan_Finance_Amount__c?.setScale(3, System.RoundingMode.DOWN));  
            requestBody.put('loanDuration', caseAnnexObj?.cx_ln_Requested_Duration_Months__c);    
            requestBody.put('loanMonthlyInstalment', caseAnnexObj?.cx_ln_Monthly_Instalment__c?.setScale(3, System.RoundingMode.DOWN)); 
            requestBody.put('interestRate', caseAnnexObj?.cx_ln_Requested_Interest_Rate__c?.setScale(3, System.RoundingMode.DOWN));  
            requestBody.put('apr', caseAnnexObj?.cx_ln_APR__c);  
            requestBody.put('processingFees', caseAnnexObj?.cx_ln_Requested_Processing_Fees__c?.setScale(3, System.RoundingMode.DOWN));   
            requestBody.put('vatProcessingFees', caseAnnexObj?.cx_ln_Requested_Vat_Processing_Fees__c?.setScale(3, System.RoundingMode.DOWN));  
            requestBody.put('firstPaymentDate', caseAnnexObj?.cx_ln_Requested_First_Payment_Date__c); 
            requestBody.put('maturityDate', caseAnnexObj?.cx_ln_Requested_Maturity_Date__c);   
            requestBody.put('cashInHand', caseAnnexObj?.cx_ln_Requested_Cash_in_Hand__c?.setScale(3, System.RoundingMode.DOWN));  
            requestBody.put('caseNumber', caseObj.caseNumber);   

            if(caseAnnexObj != null && caseAnnexObj.cx_ln_Requested_Liabilities__c != null && caseAnnexObj.cx_ln_Requested_Liabilities__c != ''){
                String jsonString = caseAnnexObj.cx_ln_Requested_Liabilities__c;
                List<Object> dataList = (List<Object>)JSON.deserializeUntyped(jsonString);
                List<Map<String, Object>> selectedItems = new List<Map<String, Object>>();
                for (Object item : dataList) {
                    Map<String, Object> itemObj = (Map<String, Object>)Item;
                    if (itemObj.containsKey('selected') && (Boolean)itemObj.get('selected') == true) {
                        itemObj.remove('selected');
                        itemObj.remove('Id');
                        selectedItems.add(itemObj);
                    }
                }
                // String selectedJson = JSON.serialize(selectedItems);
                // system.debug('selectedJson : '+selectedJson ); 
                requestBody.put('liabilities', selectedItems );
            } else {
                requestBody.put('liabilities', null );
            }
            requestBody.put('bcrbTermsAndConditions', false);
            DateTime currentDateTime = DateTime.now();
            requestBody.put('applicationsubmissionDateTime', currentDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss'));   /////// is it current date?
            requestBody.put('currency', 'BHD');
            requestBody.put('crmCaseId', caseObj.Id);  
            // requestBody.put('insuranceAmount', null);   /////// not found ===== loansOptions.currentLoans[0].insurance
            // String loanNature = (caseObj.Loans_Requested_Loan_Type__c == null || caseObj.Loans_Requested_Loan_Type__c.containsIgnoreCase('Unsecured')) ? 'unsecured':'secured' ;
            requestBody.put('loanType', caseAnnexObj?.cx_ln_Loan_Finance_Type__c);
            requestBody.put('loanNature', caseAnnexObj?.cx_ln_Product__c);

            requestBody.put('segment', caseObj.Customer_Segment__c);
            requestBody.put('nationality', caseObj.cc_Nationality__c);

            requestBody.put('holdAccountType', caseObj.ccol_Hold_Account__c); 
            requestBody.put('holdAccountId', caseObj.ccol_Hold_Account_IBAN__c ); 
            requestBody.put('holdAmount', caseObj.ccol_Hold_Amount__c); 
            requestBody.put('holdAccountBalance', caseObj.ccol_Hold_Account_Balance__c);  

            requestBody.put('withCreditCard', null);
            requestBody.put('creditCardType', null);

        // Serialize the Map to JSON
        String requestBodyJson = JSON.serialize(requestBody);
        System.debug('createLoanApplicationApi requestBodyJson: '+requestBodyJson);
        request.setBody(requestBodyJson);
        
        
        System.debug('Request Endpoint: ' +request.getEndpoint());
        System.debug('Request Method: ' +request.getMethod());
        System.debug('Request Body:'+request.getBody());
        
        HttpResponse response = Loans_ServiceApiCallsEM.createLoanApplicationApi(request,200);//real api call
        //  HttpResponse response = new Loans_ServiceApiCallsMock().createLoanApplicationApi(request,200);
        
        List<System_Action__c> lstSA = new List<System_Action__c>();
        System.debug('createLoanApplicationApi response.getStatusCode() : '+response.getStatusCode() );
        
        if(response.getStatusCode() != 200 ){
            System.debug('Invalid Create Loan Application Request Status API after insert');
            caseObj.Last_Api_Call_Status__c = 'Failed';
            
        }else{
            System.debug('Update Loan Application Request Status API Getting Success Status Code from API after insert');
            caseObj.Last_Api_Call_Status__c = 'Success';

            Map<String, Object> parsedResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            Map<String, Object> data = (Map<String, Object>)parsedResponse.get('data');
            System.debug('Application ID: ' + (String)data.get('applicationId'));

            caseObj.Loan_Application_ID__c = (String)data.get('applicationId');
            caseObj.External_Id__c = (String)data.get('entityId');
			//caseObj.ccol_Hold_Account_Balance__c = (Decimal.valueOf(String.valueOf(caseObj.ccol_Hold_Account_Balance__c)) - Decimal.valueOf(String.valueOf(caseObj.ccol_hold_amount__c)));
            
            //add it aniss
            caseObj.ccol_Hold_Reference_Number__c = (String)data.get('holdReference');
        }
        // // Start Get default Account Number
        // String defaultAccountNumber = null;

        // ApiConnection.Response resp = BankAccountController.loadAccountList(caseObj.Customer_CIF__c, regionName);
        
        // lstSA.add(SM001_ApiCalls.setSystemAction( '',String.valueOf(resp.responseData),
        //                                             'Bank Accounts List','GET',
        //                                             caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
        //                                             caseObj.Type+' -- call get account List API', caseObj.Type
        //                                         ));

        // system.debug('AccountList resp .. '+resp);
        // if (resp.isSuccess == true) {
        //     final Map<String, Object> respData = (Map<String, Object>)resp.responseData;
        //     final Object[] accounts = (Object[])respData.get('accounts');
        //     for (Object accItem : accounts) {
        //         Map<String, Object> acct = (Map<String, Object>) accItem;
        //         Map<String, Object> acc = (Map<String, Object>) acct.get('account');
        //         system.debug('acc .. '+JSON.serialize(acc));
        //         if ((Boolean)acc.get('defaultAccount')) {
        //             defaultAccountNumber = (String)acc.get('number');
        //             break;
        //         }
        //     }
             
        // } 
        // caseAnnexObj.cx_ln_Main_BHD_Account_No__c = defaultAccountNumber;
        // // End Get Account Number     
        
        //Always create system log    
        lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                    request.getEndpoint(),request.getMethod(),
                                                    caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                    caseObj.Type+' -- call create Loan Application API', caseObj.Type
                                                ));

        if(lstSA.size() > 0){
            insert lstSA;
        }

        update caseObj;
        update caseAnnexObj;
        System.debug('createLoanApplicationApi response: '+response);
        return formatResponse(response);
    }


    /**
    * @description  method used to call "get appFulfillmentId API".
    * @author Elmustapha elgarni | 19/07/2024
    **/
    public static String populateAppFulfillmentIdAPI(Case caseObj){
        
        PAD.debugLogBegin(CLASS_NAME, 'populateAppFulfillmentIdAPI', '');

        List<System_Action__c> lstSA = new List<System_Action__c>();
        String regionName = caseObj.Region_Flag__c;
        String appFulfillmentId = null;
        
        if (caseObj.Case_Model__c == 'alburaq') {
            regionName += '_alburaq';
        }

        //HTTP Callout to get appFulfilmentId
        HttpRequest request1 = con.createRequest('POST', '/api/v1/loans/infinity/fulfillment',regionName); //System.Label.CC_EndPointCreditCardRequest
        system.debug('customerId : '+ caseObj.Customer_CIF__c);
        request1.setHeader('customerId', caseObj.Customer_CIF__c);
        request1.setTimeout(60000);

        String body = '{"applicationId": "' + caseObj.Loan_Application_ID__c + '",     "loanProductConfigurationId": '+ caseObj.Card_Product_Configuration_Id__c+'}';
        System.debug('getAppFulfillmentIdAPI Body' + body);
        request1.setBody(body);
            HttpResponse response1 = Loans_ServiceApiCallsEM.getAppFulfillmentIdAPI(request1,200);//real api call
            //  HttpResponse response1 = new Loans_ServiceApiCallsMock().getAppFulfillmentIdAPI(request1,200);

        System.debug('getAppFulfillmentIdAPI response : '+ response1 );
        System.debug('getAppFulfillmentIdAPI response Body : '+ response1.getBody() );
        if(response1.getStatusCode() != 200 ){
            System.debug('Invalid getAppFulfillmentIdAPI Request Status API after insert');
            caseObj.Last_Api_Call_Status__c = 'Failed';
            lstSA.add(SM001_ApiCalls.setSystemAction( request1.getBody(),response1.getBody(),
                                                request1.getEndpoint(),request1.getMethod(),
                                                caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response1.getStatusCode(), 
                                                caseObj.Type+'-- populate App FulfillmentId API', caseObj.Type
                                            ));
            
        }else{
            caseObj.Last_Api_Call_Status__c = 'Success';

            Map<String, Object> parsedResponse1 = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
            Map<String, Object> data1 = (Map<String, Object>)parsedResponse1.get('data');
            System.debug('AppFulfillmentIdAPI: ' + (String)data1.get('appFulfilmentId'));

            appFulfillmentId = (String)data1.get('appFulfilmentId');

        }

        if(lstSA.size() > 0){
            insert lstSA;
        }

        return appFulfillmentId;
    }


    
    /**
    * @description  method used to call "Update Loan Application".
    * @author Elmustapha elgarni | 20/12/2023
    **/
    public static HttpResponse updateLoanApplicationApi(Case caseObj, Map<String, Object> paramsMap){
        PAD.debugLogBegin(CLASS_NAME, 'updateLoanApplicationApi', '');
        String regionName = caseObj.Region_Flag__c;
        
        if (caseObj.Case_Model__c == 'alburaq') {
            regionName += '_alburaq';
        }

        HttpRequest request = con.createRequest('PUT', '/api/v1/loans/application',regionName); //System.Label.CC_EndPointCreditCardRequest
        system.debug('customerId : '+ caseObj.Customer_CIF__c);
        request.setHeader('customerId', caseObj.Customer_CIF__c);
        request.setTimeout(60000);  

        if(caseObj.Account.x_canary__pc != null){
            request.setHeader('x-canary', caseObj.Account.x_canary__pc);
        }
        
        // Create a Map to represent the request body (Common for Creation and update)
        // Map<String, Object> requestBody = new Map<String, Object>();
        // requestBody.put('loanProductConfigurationId', caseObj.Card_Product_Configuration_Id__c); ///==== loansOptions.personalLoans[0].loanProductConfigurationId /// credit card field
        paramsMap.put('loanProductConfigurationId', caseObj.Card_Product_Configuration_Id__c); ///==== loansOptions.personalLoans[0].loanProductConfigurationId /// credit card field

        // requestBody.put('status', paramsMap.get('status'));  /// Infinity Status

        // for (String key : paramsMap.keySet()) {
        //     requestBody.put(key, paramsMap.get(key));
        // }
       
        // Serialize the Map to JSON
        String requestBodyJson = JSON.serialize(paramsMap);
        request.setBody(requestBodyJson);
        System.debug('Request Endpoint: ' +request.getEndpoint());
        System.debug('Request Method: ' +request.getMethod());
        System.debug('Request Body:'+request.getBody());
        
        HttpResponse response = Loans_ServiceApiCallsEM.updateLoanApplicationApi(request,200);//real api call
        //  HttpResponse response = new Loans_ServiceApiCallsMock().updateLoanApplicationApi(request,200);
        
        List<System_Action__c> lstSA = new List<System_Action__c>();
        System.debug('updateLoanApplicationApi response.getStatusCode() : '+response.getStatusCode());
        // toDo Uncomment to log only on failiure
        // if(response.getStatusCode() != 200){
            
            lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                     request.getEndpoint(),request.getMethod(),
                                                     caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                     caseObj.Type+'-- call update Loan Application API', caseObj.Type
                                                    ));
        // }
        if(lstSA.size() > 0){
            insert lstSA;
        }
        System.debug('update loan application response: '+response);
        System.debug('update loan application response body: '+ response.getBody());
        return response;
    }
    
    // @future(callout=true)
    // public static void updateLoanApplicationApiFuture(Id caseId, Map<String, String> paramsMap){
        
    //     String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            
    //     String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc FROM Case WHERE Id =:caseId';
    //     Case caseRecord = Database.query(soqlQuery);
        
    //     updateLoanApplicationApi( caseRecord, paramsMap);
    // }
    
    /**
    * @description  method used to call "Get Existing Liabilities API".
    * @author Elmustapha elgarni | 09/01/2024
    * //UATNB-211338 : change function signature adding Decimal loanAmount, Decimal loanDuration, Decimal loanMonthlyInstalment
    **/
    public static ApiConnection.Response getExistingLiabilitiesAPI(String customerId, String caseModel, Decimal loanAmount, Decimal loanDuration, Decimal loanMonthlyInstalment){
        PAD.debugLogBegin(CLASS_NAME, 'getExistingLiabilitiesAPI', '');
        List<Account> lstAcc = [SELECT Id,Region_Flag__c,Subscription_Model__pc,Segment__pc, Alburaq_Segment__pc FROM Account WHERE CIF__pc = :customerId ];
        String regionName ;
        // String caseModel ;
        String segment;
        if(lstAcc != null && lstAcc.size()>0){
            regionName = lstAcc.get(0).Region_Flag__c;
            if(caseModel == null || caseModel == ''){
                caseModel = lstAcc.get(0).Subscription_Model__pc;
            }
            segment = lstAcc.get(0).Segment__pc;
        }  
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
        
        //UATNB-211338 : add +'&loanAmount='+loanAmount+'&loanDuration='+loanDuration+'&loanMonthlyInstalment='+loanMonthlyInstalment
        final HttpRequest req = con.createRequest('GET', System.Label.Loans_getExistingLiabilitiesAPI+'&loanAmount='+loanAmount+'&loanDuration='+loanDuration+'&loanMonthlyInstalment='+loanMonthlyInstalment , customerId, regionName);
        req.setTimeout(35000);
        System.debug('Request Endpoint: ' +req.getEndpoint());
        System.debug('Request Method: ' +req.getMethod());
        System.debug('Request Body:'+req.getBody());
        
        HttpResponse response = Loans_ServiceApiCallsEM.getExistingLiabilitiesAPI(req,200);//real api call
        // HttpResponse response = new Loans_ServiceApiCallsMock().getExistingLiabilitiesAPI(req,200);
        System.debug('get get Existing Liabilities response: '+response);
        return formatResponse(response);
    }
    
    /**
    * @description  method used to createDocuSignEnvelope (you should pass requestRecord(fill all params) ).
    * @author Aniss Mbarki | 21/03/2024
    **/
    @AuraEnabled
    public static Loan_DocuSignEnvelopeResponseWrapper createDocuSignEnvelope(Loan_DocuSignEnvelopeReqWrapper requestRecord){
        PAD.debugLogBegin(CLASS_NAME, 'createDocuSignEnvelope', '');
    
        Id caseIdStr = requestRecord.caseId;
        Loan_DocuSignEnvelopeResponseWrapper resp = new Loan_DocuSignEnvelopeResponseWrapper();
        List<Case> caseList = new List<Case>();
        String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
        
        String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,Account.Name FROM Case WHERE Id = :caseIdStr';
        caseList = new List<Case>((List<Case>)Database.query(soqlQuery));
        
    
        if( caseList != null && caseList.size() > 0 ){
            Case cItem = caseList.get(0);
            Id mySourceId = cItem.Id;
            Id caseAnnexId = cItem.CaseAnnex__c;
            String EnvelopeId = EmbeddedSigningController.sendEnvelope(cItem.Id, requestRecord.channel);

            // To be removed 
                // // Create an empty envelope.
                // dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(mySourceId));
        
                // dfsle.Recipient myRecipient;
                // if(requestRecord.channel == 'Email'){
                //     //myEnvelope = myEnvelope.withEmail('My custom Email Subject', 'My custom Email Message');
                //     //use the Recipient.fromSource method to create the Recipient to send an email
                //     myRecipient = dfsle.Recipient.fromSource(
                //         cItem.cc_Full_Name__c, // Recipient name
                //         cItem.cc_Email_Address__c, // Recipient email
                //         null, //Optional phone number
                //         'Signer', //Role Name. Specify the exact role name from template
                //         new dfsle.Entity(cItem.Id)); //source object for the Recipient.
        
                // }else if(requestRecord.channel == 'In-App') {
                //     // Add contact as an embedded recipient to not send email
                //     // toDo: Add role
                //     // myRecipient = dfsle.Recipient.newEmbeddedSigner(cItem.Account.Name, cItem.Account.PersonEmail, cItem.ContactId).withRole('Signer');
                //     myRecipient = dfsle.Recipient.newEmbeddedSigner(cItem.Account.Name, cItem.Account.PersonEmail, cItem.ContactId);
                // }
        
                // //add Recipient to the Envelope
                // system.debug('myEnvelope : ' + myEnvelope.withRecipients(new List<dfsle.Recipient> { myRecipient }));
                // myEnvelope = myEnvelope.withRecipients(new List<dfsle.Recipient> { myRecipient });
        
                // //myTemplateId contains the DocuSign Id of the DocuSign Template
                // String DocusignTemplateId = '';
                // if (cItem.case_Model__c == 'alburaq') {
                //     DocusignTemplateId = 'a729085e-1f44-413f-b24e-5535d9e85ac0';
                // } else {
                //     DocusignTemplateId = System.Label.Loans_DocusignTemplate;
                // }
                
                // dfsle.UUID Loans_DocusignTemplate_templateID = dfsle.UUID.parse(DocusignTemplateId);//toDo : to change after confirmation

                // dfsle.Document myDocument ;
                // myDocument = dfsle.Document.fromTemplate(
                //                     Loans_DocusignTemplate_templateID, // templateId in dfsle.UUID format
                //                     'Loans_DocusignTemplate'); // name of the template
                                    
                // Map<String, Map<String, Object>> envelopeEventUpdates= new Map<String, Map<String, Object>> {
                //     dfsle.Envelope.STATUS_SENT => new Map<String, Object> {
                //         'Last_Call_Outcome__c' => 'Sent'
                //     },
                //     dfsle.Envelope.STATUS_COMPLETED => new Map<String, Object> {
                //         'Last_Call_Outcome__c' => 'Completed',
                //         'Status' => 'Under Review',
                //         'Sub_Status__c' => 'Pending Signature Verification'
                //     }
                // };
                // // Define document write-back options
                // dfsle.Document.WriteBack documentWriteBack = new dfsle.Document.WriteBack(
                //     // Where to link the completed document(s)
                //     mySourceId,
                //     // The completed document(s) file name format
                //     dfsle.Document.WRITE_BACK_ENVELOPE_STATUS_PDF,
                //     // Whether to combine all the documents into a single PDF
                //     false,
                //     // Whether to include the Certificate of Completion (CoC)
                //     true);
        
                // // Create an instance of Envelope.Options
                // dfsle.Envelope.Options options = new dfsle.Envelope.Options(
                //     false, // includeDefaultAutoPlaceTags
                //     documentWriteBack, // documentWriteBack
                //     envelopeEventUpdates, // envelopeEventUpdates
                //     null // recipientEventUpdates
                // );
                
                // //add document to the Envelope
                        
                // myEnvelope = myEnvelope.withDocuments(new List<dfsle.Document> { myDocument }).withOptions(options);
                    
                // // Send the envelope.
                // myEnvelope = dfsle.EnvelopeService.sendEnvelope(
                //                 myEnvelope, // The envelope to send
                //                 true); // Send now?
                
            if(requestRecord.channel == 'Email'){
                resp.envelopeId = EnvelopeId;
    
            }else if(requestRecord.channel == 'In-App') {
                resp.envelopeId = EnvelopeId;
                resp.contactId = cItem.ContactId;
            }
        }
        
        return resp;
    }


    /**
    * @description  method used to call "Get Customer Products API".
    * @author Elmustapha elgarni | 09/01/2024
    **/
    public static ApiConnection.Response getCustomerProductsAPI(String customerId, String caseModel){
        PAD.debugLogBegin(CLASS_NAME, 'getCustomerProductsAPI', '');
        List<Account> lstAcc = [SELECT Id,Region_Flag__c,Subscription_Model__pc,Segment__pc, Alburaq_Segment__pc, x_canary__pc FROM Account WHERE CIF__pc = :customerId ];
        String regionName ;
        String Path = '/api/v1/customer-products/compatibility?target=LOANS';
        String segment;
        if(lstAcc != null && lstAcc.size()>0){
            regionName = lstAcc.get(0).Region_Flag__c;
            if(caseModel == null || caseModel == ''){
                caseModel = lstAcc.get(0).Subscription_Model__pc;
            }
            segment = lstAcc.get(0).Segment__pc;
        }  
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
        
        final HttpRequest req = con.createRequest('GET', Path, customerId, regionName);
        req.setTimeout(35000);
        req.setHeader('x-canary',lstAcc.get(0).x_canary__pc);
        System.debug('Request Endpoint: ' +req.getEndpoint());
        System.debug('Request Method: ' +req.getMethod());
        System.debug('Request Body:'+req.getBody());
        
        HttpResponse response = Loans_ServiceApiCallsEM.getCustomerProductsAPI(req,200);//real api call
        // HttpResponse response = new Loans_ServiceApiCallsMock().getCustomerProductsAPI(req,200);
        System.debug('get Customer Products API response: '+response.getBody());
        return formatResponse(response);
    }


    /**
    * @description  method used to call "Get Loan Calculator Matrix API".
    * @author Elmustapha elgarni | 04/06/2024
    **/
    public static ApiConnection.Response getLoanCalculatorMatrixAPI(String customerId, String caseModel){
        PAD.debugLogBegin(CLASS_NAME, 'getLoanCalculatorMatrixAPI', '');
        List<Account> lstAcc = [SELECT Id,Region_Flag__c,Subscription_Model__pc,Segment__pc, Alburaq_Segment__pc, ID_Nationality__pc, Nationality__pc,x_canary__pc,CIF__pc  FROM Account WHERE CIF__pc = :customerId ];
        String regionName ;
        String segment;
        String picklistValue;
        System.debug('CIF__pc'+lstAcc[0].CIF__pc);
         System.debug('Nationality__pc'+lstAcc[0].Nationality__pc);
        if(lstAcc != null && lstAcc.size()>0){
            regionName = lstAcc.get(0).Region_Flag__c;
            if(caseModel == null || caseModel == ''){
                caseModel = lstAcc.get(0).Subscription_Model__pc;
            }
            segment = lstAcc.get(0).Segment__pc;
            picklistValue = lstAcc.get(0).Nationality__pc;
        }  
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }

        // Start Get Natinalty Label
        // String objectName = 'Account';
        // String fieldName = 'ID_Nationality__pc';
        // String picklistValue = lstAcc.get(0).Nationality__pc;
        // String nationality = '';
        // Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
        // Schema.DescribeSObjectResult describeSObjectResult = sObjectType.getDescribe();
        // Map<String, Schema.SObjectField> fieldsMap = describeSObjectResult.fields.getMap();

        // if(fieldsMap.containsKey(fieldName)) {
        //     system.debug('fieldName'+ fieldName);
        //     Schema.DescribeFieldResult fieldResult = fieldsMap.get(fieldName).getDescribe();
        //     List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            
        //     for (Schema.PicklistEntry entry : picklistEntries) {
        //         if (entry.getValue().equals(picklistValue)) {
        //             nationality = entry.getLabel();
        //             system.debug(entry.getLabel());
        //         }
        //     }
        // }
        // nationality = nationality.trim();
        // system.debug('nationality :'+nationality);
        // End Get Natinalty Label
        String path = '/api/v1/loans/calculator-matrix?loanType=personal&segment=' + segment + '&nationality=' + picklistValue;
        final HttpRequest req = con.createRequest('GET', path, customerId, regionName);
        req.setTimeout(35000);
        System.debug('Request Endpoint: ' +req.getEndpoint());
        System.debug('Request Method: ' +req.getMethod());
        System.debug('Request Body:'+req.getBody());
        
        HttpResponse response = Loans_ServiceApiCallsEM.getLoanCalculatorMatrixAPI(req,200);//real api call
        // HttpResponse response = new Loans_ServiceApiCallsMock().getLoanCalculatorMatrixAPI(req,200);
        System.debug('get Customer Products API response: '+response.getBody());
        return formatResponse(response);
    }
    
    
}