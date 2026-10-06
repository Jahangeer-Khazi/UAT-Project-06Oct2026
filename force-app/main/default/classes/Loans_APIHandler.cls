/**
 * @description       : 
 * @author            : Elmustapha ELGARNI
 * @group             : 
 * @last modified on  : 07-04-2024
 * @last modified by  : Elmustapha ELGARNI
 *      Change History: 
 *             #CH03# #Aniss Mbarki# 03-02-2026# Added Logic for Loans - Introducing "Pledge Form" To Secured Loans DocuSign Documents  (NBA-16477)
 *             #CH04# #Aniss Mbarki# 03-08-2026# Added Logic for day2 CR  Loans (NBA-17380)
**/
public without sharing class Loans_APIHandler {

    private static String CLASS_NAME = Loans_APIHandler.class.getName();
    private static String FIXED_SENDER = 'ABCOBHBM';

    private static ApiConnection con = new ApiConnection();
    private static List<System_Action__c> lstSA = new List<System_Action__c>();
    private static List<CaseComment> lstComment = new List<CaseComment>();
    private static Map<Case,String> mapEmailPerCase = new Map<Case,String>();
    private static List<Case> emailtoOwnerCases = new List<Case>();
    // public static Integer updateCreditCardRequestStatusApi_StatusCode = 200;

    // public static Integer getCardProductConfiId_IncludeOtherProductsEqualTrue_StatusCode = 200;
    public static boolean throwException_1 = false;
    public static boolean throwException_2 = false;

    private static CaseAnnex__c tempCaseAnnexRecord;
    
    
    // we  call this in creation annd update  
    @InvocableMethod(label='call Create/Update Loan Application API' description='call Create Loan Application API' callout=true )
    public static List<String> updateLoanUpdateApiFromFlow(List<LoanWrapper> Loans){
        
        system.debug('Loans debug ==> '+Loans);
        LoanWrapper Loan = Loans.get(0);
        Map<String,String> details = new Map<String,String>();
        details.put('isNew',Loan.isNew);
        details.put('objectSource',Loan.objectSource);
        details.put('changedField',Loan.changedField);
        system.debug('debug call updateLoanUpdateApiFromFlow');
        
        try{
            //call future method
            if(throwException_1){
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception!');
                throw e;
            }

            if(Loan.isSynchronousCallout != null && Loan.isSynchronousCallout == 'true'){
                system.debug('debug call updateLoanApiSimpleMeth without future context ');
                updateLoanApiSimpleMeth(new Set<Id>{loan.caseId},details);
            }else {
                system.debug('debug call updateLoanApiFutureMeth 1');
                updateLoanApiFutureMeth(new Set<Id>{loan.caseId},details);
            }
            
        }catch(Exception e){
            Case caseObj = [SELECT Id,Customer_CIF__c,accountId,Type FROM Case WHERE Id =: Loan.caseId];
            caseObj.Last_Api_Call_Status__c = 'Failed';
            update caseObj;
            //store unexpected errors from system !!
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            insert SM001_ApiCalls.setSystemAction( e.getMessage(),String.valueOf(e.getStackTraceString()),
                                                  null,null,
                                                  caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                  'please check : '+CLASS_NAME+'.updateLoanUpdateApiFromFlow()', caseObj.Type
                                                 );
        }
        
        List<String> strLst = new List<String>();
        for(LoanWrapper qst : Loans){
            strLst.add(qst.caseId);
        }
        return strLst;
    } 
    
    @future(callout=true)
    public static void updateLoanApiFutureMeth(Set<Id> caseIds , Map<String,String> details){
        try{
            updateLoanApiSimpleMeth(caseIds,details);
        }catch(Exception e){
            Case caseObj = [SELECT Id,Customer_CIF__c,accountId,Type FROM Case WHERE Id IN :caseIds LIMIT 1];
            //store unexpected errors from system !!
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            insert SM001_ApiCalls.setSystemAction( e.getMessage(),String.valueOf(e.getStackTraceString()),
                                                  null,null,
                                                  caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                  'please check : '+CLASS_NAME+'.updateLoanApiFutureMeth()', caseObj.Type
                                                 );
        }
    }
    
    public static void updateLoanApiSimpleMeth(Set<Id> caseIds , Map<String,String> details){
        system.debug('debug call updateLoanApiProcess began');
        List<Case> cases = new List<Case>();
        List<CaseAnnex__c> CaseAnnexs = new List<CaseAnnex__c>();
        Set<Id> setSTPupdateIds = new Set<Id>();
        //UATNB-192759: START
        Set<Id> caseIdsExpires = new Set<Id>();
        //UATNB-192759: END
        
        //UATNB-192753: START
        Set<Id> caseIdsDecline = new Set<Id>();
        //UATNB-192753: END
        
        //UATNB-192750: START
        Set<Id> caseIdsCancelled = new Set<Id>();
        //UATNB-192750: END

        Map<Id, Id> mapCasetoAccount = new Map<Id, Id>();
        
        String isNew = details.get('isNew');
        String objectSource = details.get('objectSource');
        String changedField = details.get('changedField');
        system.debug('debug isNew :'+isNew);
        system.debug('debug changedField :'+changedField);
        system.debug('debug caseIds :'+caseIds);
        if (caseIds != null && caseIds.size() > 0) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            
            String soqlQuery = 'SELECT ' + fields + ',CaseAnnex__r.cx_ln_Cross_Selling_PreScreening_Result__c,CaseAnnex__r.cx_ln_Cross_Selling_Evaluator_Result__c,CaseAnnex__r.cx_ln_Cross_Selling_Verifier_Result__c,CaseAnnex__r.cx_ln_Cross_Selling_Approver_Result__c,Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,Account.x_canary__pc FROM Case WHERE Id IN :caseIds FOR UPDATE';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        }
        // Added this for safety check - omar start
        if(cases == null || cases.isEmpty()) {
            System.debug('No cases found for the given IDs');
            return;
        }
        // omar end
        
        Case caseObj = cases[0];
        system.debug('debug caseObj :'+caseObj);
        String caseAnnexId = caseObj.CaseAnnex__c;
        String caseAnnexfields = DM000_sObjectDescriber.constructFieldListForQueryFrom('CaseAnnex__c');   
        String caseAnnexsoqlQuery = 'SELECT ' + caseAnnexfields + ' FROM CaseAnnex__C WHERE Id =:caseAnnexId';
        //Start : bug fix for cross selling loan
        if( caseObj != null && caseObj.AIR_HaveCreditCard__c == false ){
            caseAnnexsoqlQuery += ' FOR UPDATE';
        }
        //End : bug fix for cross selling loan
        
        CaseAnnexs = new List<CaseAnnex__c>((List<CaseAnnex__c>)Database.query(caseAnnexsoqlQuery));
        CaseAnnex__c caseAnnexRecord;
        if(!CaseAnnexs.isEmpty()){
            caseAnnexRecord = CaseAnnexs[0];
        }
        try {
            
            if(throwException_2){
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception!');
                throw e;
            }

            String regionName = caseObj.Region_Flag__c;
            if (caseObj.Case_Model__c == 'alburaq') {
                regionName += '_alburaq';
            }

            if(isNew != null && isNew.equalsIgnoreCase('yes') ){ // Handle Creation 
                // Start Get default Account Number
                String defaultAccountNumber = null;
                // omar start
                //ApiConnection.Response resp = BankAccountController.loadAccountList(caseObj.Customer_CIF__c, regionName);
                ApiConnection.Response resp;

                if (Test.isRunningTest()) {
                     resp = new ApiConnection.Response();
                    resp.isSuccess = true;
                    
                     Map<String, Object> fakeData = new Map<String, Object>{
                        'accounts' => new List<Object>{
                            new Map<String, Object>{
                                'account' => new Map<String, Object>{
                                    'accountType' => 'CUSTOMER_ACCOUNT',
                                    'availableBalance' => 7800.0,
                                    'branch' => 'BH0020091',
                                    'currency' => new Map<String, Object>{ 'code' => 'BHD', 'decimalPlaces' => 3 }
                                },
                                'alias' => 'BHD Account',
                                'customerId' => '6193048',
                                'id' => 'BH54ABCO91002011606857',
                                'productName' => 'BHD Account',
                                'productType' => 'account'
                            },
                            new Map<String, Object>{
                                'account' => new Map<String, Object>{
                                    'accountType' => 'CUSTOMER_ACCOUNT',
                                    'availableBalance' => 38500.0,
                                    'branch' => 'BH0020091',
                                    'currency' => new Map<String, Object>{ 'code' => 'BHD', 'decimalPlaces' => 3 }
                                },
                                'alias' => 'BHD Account',
                                'customerId' => '6193048',
                                'id' => 'BH30ABCO91002011608356',
                                'productName' => 'BHD Account',
                                'productType' => 'account'
                            }
                        }
                    };
                    
                    resp.responseData = fakeData;
                    
                } else {
                    // Real callout
                    resp = BankAccountController.loadAccountList(caseObj.Customer_CIF__c, regionName);
                }

                //omar end 

                lstSA.add(SM001_ApiCalls.setSystemAction( '',String.valueOf(resp.responseData),
                                                            '/api/v1/accounts?','GET',
                                                            caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                            caseObj.Type+' -- call get account List API', caseObj.Type
                                                        ));

                system.debug('AccountList resp .. '+resp);
                if (resp.isSuccess == true) {
                    final Map<String, Object> respData = (Map<String, Object>)resp.responseData;
                    final Object[] accounts = (Object[])respData.get('accounts');
                    for (Object accItem : accounts) {
                        Map<String, Object> acct = (Map<String, Object>) accItem;
                        Map<String, Object> acc = (Map<String, Object>) acct.get('account');
                        system.debug('acc .. '+JSON.serialize(acc));
                        if ((Boolean)acc.get('defaultAccount')) {
                            defaultAccountNumber = (String)acc.get('number');
                            break;
                        }
                    }
                    
                } 
                caseAnnexRecord.cx_ln_Main_BHD_Account_No__c = defaultAccountNumber;
                // End Get Account Number 
                
                // Call create loan application API
                if(caseObj.cc_CC_Application_Source__c != 'API'){
                    ApiConnection.Response response = new ApiConnection.Response();
                
                    response = Loans_ServiceManagerHandler.createLoanApplicationApi(caseObj);
                    
                    System.debug('callCreateLoanApplicationAPI##'+response);
                    system.debug('---> Response New --> '+response.responseData);
                    
                    if(response.isSuccess){
                        caseObj.Last_Api_Call_Status__c = 'Success';
                    } else {
                        caseObj.Last_Api_Call_Status__c = 'Failed';
                    }
                }
                
                //handle cross seling loan after creation
                if(caseObj.AIR_HaveCreditCard__c == true){
                    Http http = new Http();
                    HttpRequest request10 = new HttpRequest();
                    Integer cardProductConfigurationIdString;
                    
                    //request10 = con.createRequest('GET', '/api/v1/credit-cards?', regionName ); 
                    request10 = con.createRequest('GET', System.Label.CC_EndPointGetCreditCards, regionName ); 

                    System.debug('Person Email :'+caseObj.Account.PersonEmail);
                    System.debug('Customer ID :'+caseObj.Account.CIF__pc);
                    //System.debug('Case ID :'+setCaseId);
                    
                    request10.setHeader('userId', caseObj.Account.PersonEmail);
                    request10.setHeader('customerId', caseObj.Account.CIF__pc);
                    if(caseObj.Account.x_canary__pc != null){
                        request10.setHeader('x-canary', caseObj.Account.x_canary__pc);//CH22
                    }
                    
                    system.debug('---> request10 --> '+request10.getBody());
                    request10.setTimeout(60000);
                    HttpResponse response10 = http.send(request10);
                    system.debug('---> Responce New --> '+response10.getBody());
                    lstSA.add(SM001_ApiCalls.setSystemAction(request10.getBody(),response10.getBody(),
                                                            request10.getEndpoint(),request10.getMethod(),
                                                            caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response10.getStatusCode(),
                                                            caseObj.Type+' -- call api to et api/v1/credit-cards list --', 'Credit Card'));
                    if (response10.getStatusCode() != 200)
                    {
                        System.debug('The status code returned was not expected: ' + response10.getStatusCode() + ' ' + response10.getStatus());
                    }
                    else
                    {
                        System.debug(response10.getBody());
                        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response10.getBody());
                        System.debug('---> MAP m --> '+m);  // meta, data
                        System.debug('---> MAP m VALUES --> '+m.Values());
                        Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                        System.debug('---> MAP m1 --> '+m1);  // currentCards,pendingCards,cardOptions
                        List<Object> m2 = (List<Object>)m1.get('cardOptions');
                        System.debug('---> LIST m2 --> '+m2);
                        
                        List<Map<String, Object>> a = new List<Map<String, Object>> ();
                        
                        for(Object obj : m2)
                        {
                            a.add((Map<String, Object>)obj);
                            {
                                system.debug('---->> OBJ Iterations --> '+obj);
                            }
                        }
                        system.debug('---->> FINALL aaaa --> '+a);
                        
                        for(Map<String, Object> map1 : a)
                        {
                            if(map1.get('productMappingCode')== caseObj.cc_Requested_Card_Type__c)
                            {
                                system.debug('---> FINALL 1111 --> '+(Integer)map1.get('cardProductConfigurationId'));
                                cardProductConfigurationIdString = (Integer)map1.get('cardProductConfigurationId');
                                system.debug('---> FINALL cardProductConfigurationId --> '+cardProductConfigurationIdString);
                                caseObj.PrimaryCardProductConfigurationId__c = String.valueOf(cardProductConfigurationIdString);
                            }
                        }
                    }
                    HttpRequest request1 = con.createRequest('POST', '/api/v1/credit-cards/cross?',regionName);
                    HttpResponse response11 = Loan_CrossSellingCcFinalApproval.updateCrossSellingCaseStatusApi(request1,caseObj,'IN_PROGRESS');
                    //Store Both Success/Error Response 
                    if(response11 != null && response11.getStatusCode() != null){
                        lstSA.add(SM001_ApiCalls.setSystemAction( request1.getBody(),response11.getBody(),
                                        request1.getEndpoint(),request1.getMethod(),
                                        caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response11.getStatusCode(), 
                                        caseObj.Type+' Request cross selling Status API', caseObj.Type
                                    ));
                    }

                }

                /*if(caseAnnexRecord.cx_ln_Product__c == 'Secured'){
                    //call the bcrb decisioning "/api/v1/bcrb/decision"
                    HttpRequest request9 = con.createRequest('POST', '/api/v1/bcrb/decision?', regionName);
                    HttpResponse response9 = callBcrbDecisioningApi(request9,caseObj,caseAnnexRecord);
                    lstSA.add(SM001_ApiCalls.setSystemAction( request9.getBody(),response9.getBody(),
                                                    request9.getEndpoint(),request9.getMethod(),
                                                        caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response9.getStatusCode(), 
                                                        caseObj.Type+' -- the bcrb decisioning API', caseObj.Type
                                                    ));
    
                    if(response9.getStatusCode() != 200){
                        system.debug('---> Error on the bcrb decisioning --> '+response9.getBody());
                    }
                    else{
                        system.debug('---> Success Response Body BCRB --> '+response9.getBody());
                        Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response9.getBody());// meta, data
                        Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                        string controlType = String.valueOf(dataMap.get('decision'));
                        string autoDecisioningResult = String.valueOf(dataMap.get('autoDecisioningResult'));
                        // string controlType = 'STP';
                        caseAnnexRecord.cx_ln_Auto_Decisioning_Result__c = autoDecisioningResult;
                        System.debug(dataMap);
                        if(controlType == 'STP'){
                            Map<String, Object> scheduleAPIResult = generateRepaymentScheduleApiHandler(caseObj, caseAnnexRecord);
                            // call  api bcrb enquiry (fetch bcrb)
                            // Lwc03_FinancialDetailsController.fetchBcrbDetails(caseObj.Id, caseAnnexRecord.Id);
                            //reset it to null
                            caseObj.cc_Control_Type__c = null;
                            
                            if(scheduleAPIResult.get('status') == 'Success'){
                                System.debug('scheduleAPIResult Success : ');
                            }
                            System.enqueueJob(new UpdateCaseFieldJob(
                                caseObj.Id, 'cc_Control_Type__c', controlType
                            ));
                        }
                    }
                }*/

                caseAnnexRecord = handleReminderFields(caseObj, caseAnnexRecord);
                
                //set default values after case creation
                if( caseAnnexRecord.cx_ln_Product__c == 'Secured' && caseAnnexRecord.cx_ln_Requested_Insurance_Amount__c == null){
                    caseAnnexRecord.cx_ln_Requested_Insurance_Amount__c = 0;
                }

                if(caseObj.ccol_Hold_Amount__c != null){
                    caseObj.Approved_Hold_Amount_in_words__c = CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(caseObj.ccol_Hold_Amount__c);//#CH03
                }
            }
            else if (isNew != null && isNew.equalsIgnoreCase('no')) {// Handle Update
                System.debug('isNew Loan Update');
                Map<String, Object> paramsMap = new Map<String, Object>();
                paramsMap.put('crmCaseId',caseObj.Id);
                switch on changedField {
                    when 'Resend_DocuSign__c'{

                        paramsMap.put('status','Pending');
                        paramsMap.put('crmCaseNo',caseObj.caseNumber);
                        paramsMap.put('crmCaseId',caseObj.Id);
                        
                        if(caseObj.Resend_DocuSign__c == 'Email'){
                            paramsMap.put('subStatus','Pending Signature Email');

                        } else{
                            paramsMap.put('subStatus','Pending Signature In-App');
                        }

                        String respEnvelopeId = details.get('envelopeId');
                        String resContactId = details.get('contactId');
                        if(respEnvelopeId != null && respEnvelopeId != ''){
                            paramsMap.put('envelopeId',respEnvelopeId);
                            paramsMap.put('contactId',resContactId);
                        }

                        HttpResponse response;
                        response = Loans_ServiceManagerHandler.updateLoanApplicationApi(caseObj, paramsMap);
                    }
                    when 'Last_Call_Outcome__c'{
                        // if(caseObj.Last_Call_Outcome__c == 'Completed'){
                        //     mapEmailPerCase.put(caseObj,'ILA_PL_Send_SignedDocs');
                        // }
                        // Shameer : Update the CRM status and sub status, and do not call update api.

                        // Docusign signing is completed, Customer signed the documents
                        if(caseObj.Last_Call_Outcome__c == 'Completed'){
                            paramsMap.put('status','Under Review');
                            paramsMap.put('subStatus','Pending Signature Verification');
                            HttpResponse response;
                            response = Loans_ServiceManagerHandler.updateLoanApplicationApi(caseObj, paramsMap);
                            system.debug('---> Response after Last_Call_Outcome__c Completed --> '+response.getBody());
                            if(response.getStatusCode() != 200){
                                caseObj.Last_Api_Call_Status__c = 'Failed';
                            }
                            else{
                                system.debug('debug Success API');
                                caseObj.Last_Api_Call_Status__c = 'Success';
                                caseObj.Status = 'Under Review';
                            }
                        }
                    }
                    when 'cc_Control_Type__c'{
                        if(caseObj.cc_Control_Type__c == 'STP'){
                            System.debug('cc_Control_Type__c getting changed to STP');
                            
                            //call fetch bcrb api details
                            HttpRequest reqBcrb = con.createRequest('POST', '/api/v1/bcrb/inquiry', caseObj.Customer_CIF__c, regionName);

                           
                            HttpResponse bcrbResp = Lwc03_FinancialDetailsController.callBcrbApi(reqBcrb,caseObj,caseAnnexRecord);
                           
                            //Always create system log    
                            lstSA.add(SM001_ApiCalls.setSystemAction( reqBcrb.getBody(),bcrbResp.getBody(),
                                reqBcrb.getEndpoint(),reqBcrb.getMethod(),
                                caseObj.Id,caseObj.Customer_CIF__c,caseObj.AccountId,bcrbResp.getStatusCode(), 
                                'call bcrb API', null
                            ));
                            if (bcrbResp.getStatusCode() != 200)
                            {
                                System.debug('The status code returned was not expected: ' + bcrbResp.getStatusCode() + ' ' + bcrbResp.getStatus());
                            }
                            else
                            {
                                System.debug('bcrbp api bcrbResp.getBody() : ' + bcrbResp.getBody());
                                caseAnnexRecord = Lwc03_FinancialDetailsController.bcrbDetailsMapping(caseAnnexRecord,null,bcrbResp.getBody());
                            }

                            //call generate schedule API:
                            /*Map<String, Object> scheduleAPIResult = generateRepaymentScheduleApiHandler(caseObj, caseAnnexRecord);
                            if(scheduleAPIResult.get('status') == 'Success'){
                                System.debug('scheduleAPIResult Success : ');
                            }*/

                            HttpRequest req11 = con.createRequest('POST', '/api/v1/loans/schedule?', caseObj.Customer_CIF__c, regionName);
                            String searchParametersJson = '{"crmCaseId": "'+caseObj.Id+'","simulationReference":"'+caseAnnexRecord.cx_ln_SimulationReference__c+'","type": "Simulation"}';
                            req11.setTimeout(60000);
                            req11.setBody(searchParametersJson);
                            // OMAR start

                            //HttpResponse apiResp = Loans_ServiceApiCallsEM.callGetLoanPaymentsScheduleApi(req11,200);//real api call

                            HttpResponse apiResp;
                            if ( test.isRunningTest() ) {
                               //fake response 
                               apiResp = new HttpResponse();
                               String body1 = '{"meta":{"code":"LOAN-2300","message":"Successfully retrieved loan payment schedules."},"header":{"principleAmount":4500.000,"interestRate":4.000,"loanPeriod":6,"loanStartDate":"2025-10-05","lifeInsuranceRate":0.139,"insuranceAmount":2.194,"monthlyInstallment":776.576,"numberOfPayments":6,"firstInstallmentDate":"2025-10-28","lastInstallmentDate":"2026-03-28","totalInterest":47.267,"administrationFees":100.000,"administrationFeesVat":10.002,"firstInterestAccrualDate":"2025-10-10","totalCostOfLoan":4659.463,"apr":13.720,"cashInHand":4500.000,"maturityDate":"2026-03-28","currency":"BHD"},"data":[{"installmentNo":1,"installmentDueDate":"2025-10-28","noOfDays":18,"beginningBalance":4500.000,"outstandingAmount":4500.000,"paymentDate":"2025-10-28","transactionType":"Simulation","scheduleType":"FUTURE","monthlyInsuranceFeesReducing":0.626,"monthlyInsuranceFeesFlat":0.365,"adminFeesFlat":16.666,"adminFeesVat":1.667,"monthlyInstallmentFull":776.576,"monthlyInstallmentExcludingCharges":757.878,"principalAmount":748.878,"interestAmount":9.000,"endingBalance":3751.122},{"installmentNo":2,"installmentDueDate":"2025-11-28","noOfDays":31,"beginningBalance":3751.122,"outstandingAmount":3751.122,"paymentDate":"2025-11-28","transactionType":"Simulation","scheduleType":"FUTURE","monthlyInsuranceFeesReducing":0.521,"monthlyInsuranceFeesFlat":0.365,"adminFeesFlat":16.666,"adminFeesVat":1.667,"monthlyInstallmentFull":776.576,"monthlyInstallmentExcludingCharges":757.878,"principalAmount":744.957,"interestAmount":12.921,"endingBalance":3006.165},{"installmentNo":3,"installmentDueDate":"2025-12-28","noOfDays":30,"beginningBalance":3006.165,"outstandingAmount":3006.165,"paymentDate":"2025-12-28","transactionType":"Simulation","scheduleType":"FUTURE","monthlyInsuranceFeesReducing":0.418,"monthlyInsuranceFeesFlat":0.365,"adminFeesFlat":16.666,"adminFeesVat":1.667,"monthlyInstallmentFull":776.576,"monthlyInstallmentExcludingCharges":757.878,"principalAmount":747.857,"interestAmount":10.021,"endingBalance":2258.308},{"installmentNo":4,"installmentDueDate":"2026-01-28","noOfDays":31,"beginningBalance":2258.308,"outstandingAmount":2258.308,"paymentDate":"2026-01-28","transactionType":"Simulation","scheduleType":"FUTURE","monthlyInsuranceFeesReducing":0.314,"monthlyInsuranceFeesFlat":0.365,"adminFeesFlat":16.666,"adminFeesVat":1.667,"monthlyInstallmentFull":776.576,"monthlyInstallmentExcludingCharges":757.878,"principalAmount":750.099,"interestAmount":7.779,"endingBalance":1508.209},{"installmentNo":5,"installmentDueDate":"2026-02-28","noOfDays":31,"beginningBalance":1508.209,"outstandingAmount":1508.209,"paymentDate":"2026-02-28","transactionType":"Simulation","scheduleType":"FUTURE","monthlyInsuranceFeesReducing":0.210,"monthlyInsuranceFeesFlat":0.365,"adminFeesFlat":16.666,"adminFeesVat":1.667,"monthlyInstallmentFull":776.576,"monthlyInstallmentExcludingCharges":757.878,"principalAmount":752.683,"interestAmount":5.195,"endingBalance":755.526},{"installmentNo":6,"installmentDueDate":"2026-03-28","noOfDays":28,"beginningBalance":755.526,"outstandingAmount":755.526,"paymentDate":"2026-03-28","transactionType":"Simulation","scheduleType":"FUTURE","monthlyInsuranceFeesReducing":0.105,"monthlyInsuranceFeesFlat":0.004,"adminFeesFlat":16.670,"adminFeesVat":1.667,"monthlyInstallmentFull":776.583,"monthlyInstallmentExcludingCharges":757.877,"principalAmount":755.526,"interestAmount":2.351,"endingBalance":0.000}]}';
                               apiResp.setStatus('OK');    
                               apiResp.setStatusCode(200);
                               apiResp.setBody(body1);
                               apiResp.setHeader('Content-Type', 'application/json');
                           }else {
                                
                               apiResp = Loans_ServiceApiCallsEM.callGetLoanPaymentsScheduleApi(req11,200);
                           }
                            
                            // OMAR END
                            
                            //Always create system log    
                            lstSA.add(SM001_ApiCalls.setSystemAction( req11.getBody(),apiResp.getBody(),
                                req11.getEndpoint(),req11.getMethod(),
                                caseObj.Id,caseObj.Customer_CIF__c,caseObj.AccountId,apiResp.getStatusCode(), 
                                'call Get Schedule List API', null
                            ));

                            if(apiResp.getStatusCode() == 200){
                                System.debug('getSimulationPaymentList --> Sucess');
                                Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(apiResp.getBody());
                                Map<String, Object> scheduleRespHeader = (Map<String, Object>)resMap.get('header');
                                caseAnnexRecord.cx_ln_Approved_Installment_Amount__c = (Decimal)scheduleRespHeader.get('monthlyInstallment');
                                caseAnnexRecord.cx_ln_Approved_Insurance_Amount__c = (Decimal)scheduleRespHeader.get('insuranceAmount');
                                caseAnnexRecord.cx_ln_APR__c = (Decimal)scheduleRespHeader.get('apr');
                                caseAnnexRecord.cx_ln_Approved_Insurance_Rate__c = (Decimal)scheduleRespHeader.get('lifeInsuranceRate');
                                caseAnnexRecord.cx_ln_Approved_Maturity_Date__c = Date.valueOf(String.valueOf(scheduleRespHeader.get('maturityDate'))) ;

                                CC_Application_Status_Mapping__mdt apiStatusMappingRecord = [SELECT id,Label, fieldAPiName__c, Value__c, apiStatus__c,Awaiting_Customer_Feedback__c,Sub_Status__c,
                                                                        queueDeveloperName__c,isApiCall__c,crmStage__c,emailAlertName__c,cc_Application_Stages__c,regionName__c,Status__c,
                                                                        Type__c, criteria__c,MasterLabel,isDocuSign__c,sectionResultFields__c, fieldsToBeReseted__c, Object__c
                                                                        FROM CC_Application_Status_Mapping__mdt 
                                                                        WHERE Type__c = :caseObj.Type AND regionName__c = :caseObj.Region_Flag__c AND fieldAPiName__c = :'cc_Credit_Approval_Result__c' 
                                                                        AND Value__c = :'Approve' AND RecordType_DeveloperName__c =:caseObj.RecordType_DeveloperName__c LIMIT 1];
                                
                                if(apiStatusMappingRecord != null && apiStatusMappingRecord.isApiCall__c == true ){

                                    // paramsMap.put('status',apiStatusMappingRecord.apiStatus__c);
                                    paramsMap.put('status',apiStatusMappingRecord.Status__c);
                                    paramsMap.put('subStatus',apiStatusMappingRecord.Sub_Status__c);
                                    paramsMap.put('crmCaseNo',caseObj.caseNumber);
                                    paramsMap.put('crmCaseId',caseObj.Id);

                                    //paramsMap.put('approvedAmount', caseAnnexRecord.cx_ln_Approved_Loan_Amount__c);//toBeCommented
                                    //paramsMap.put('approvedInterestRate',caseAnnexRecord.cx_ln_ApprovedInterestProfitRateReducing__c);//toBeCommented
                                    //paramsMap.put('approvedMonthlyInstallment',caseAnnexRecord.cx_ln_Approved_Installment_Amount__c);//toBeCommented
                                    //paramsMap.put('approvedTenor',caseAnnexRecord.cx_ln_Approved_Duration_Months__c); //////////toBeCommented
                                    //paramsMap.put('approvedCurrency','BHD');//toBeCommented
                                    paramsMap.put('approvedCashInHand',caseAnnexRecord.cx_ln_Approved_Cash_in_Hand__c);
                                    //paramsMap.put('approvedApr',caseAnnexRecord.cx_ln_APR__c); ////////toBeCommented
                                    //paramsMap.put('approvedFee',caseAnnexRecord.cx_ln_Requested_Processing_Fees__c); ///////////// //toBeCommented
                                    //paramsMap.put('approvedVat',caseAnnexRecord.cx_ln_Requested_Vat_Processing_Fees__c); ////////// //toBeCommented
                                    //paramsMap.put('approvedFirstPaymentDate',caseAnnexRecord.cx_ln_Approved_First_installment_date__c);//toBeCommented
                                    //paramsMap.put('approvedMaturityDate',caseAnnexRecord.cx_ln_Approved_Maturity_Date__c);//toBeCommented
                                    paramsMap.put('approvedInsuranceType',caseAnnexRecord.cx_ln_Approved_Insurance_Premium__c); 
                                    paramsMap.put('approvedPreExistingInsurance',caseAnnexRecord.cx_ln_Approved_insurance__c);
                                    paramsMap.put('approvedProcessingFeeType',caseAnnexRecord.cx_ln_ApprovedProcessing_Fee_Type__c);
                                    //paramsMap.put('approvedInsuranceAmount',caseAnnexRecord.cx_ln_Approved_Insurance_Amount__c);//toBeCommented
                                    paramsMap.put('conditionalSalaryCertificateRequired',caseAnnexRecord.cx_ln_RequireSalaryCertificate__c);
                                    
                                    String respEnvelopeId = details.get('envelopeId');
                                    String resContactId = details.get('contactId');
                                    if(respEnvelopeId != null && respEnvelopeId != ''){
                                        paramsMap.put('envelopeId',respEnvelopeId);
                                        paramsMap.put('contactId',resContactId);
                                    }

                                    HttpResponse response;
                                    response = Loans_ServiceManagerHandler.updateLoanApplicationApi(caseObj, paramsMap);
                                    system.debug('---> Response New --> '+response.getBody());
                                    
                                    if(response.getStatusCode() != 200){
                                        caseAnnexRecord.put( 'cx_ln_Credit_Approval_Result__c' , null );
                                        caseObj.put( 'cc_Credit_Approval_Result__c' , null ); 
                                        caseObj.Last_Api_Call_Status__c = 'Failed';
                                        caseObj.cc_Control_Type__c = null;
                                    }
                                    else{
                                        system.debug('debug Success API');
                                        caseObj.Last_Api_Call_Status__c = 'Success';
                                        caseObj = LoanApplicationProcessFields(caseObj, caseAnnexRecord, 'cc_Credit_Approval_Result__c',apiStatusMappingRecord);
                                        caseAnnexRecord = tempCaseAnnexRecord;

                                        //toDo : ...

                                        if(caseAnnexRecord.cx_ln_Product__c == 'Unsecured'){
                                            //unsecured
                                            caseAnnexRecord.cx_ln_Credit_Pre_Screening_Result__c = 'Accept';
                                            caseObj.cc_Credit_Pre_Screening_Result__c = 'Accept';
                                            caseObj.cc_Credit_Pre_Screening_by__c = UserInfo.getUserId();
                                            caseObj.cc_Credit_Evaluation_Result__c = 'Accept';
                                            caseObj.cc_Credit_Verification_Result__c = 'Approve';
                                            caseAnnexRecord.cx_ln_Credit_Approval_Result__c = 'Approve';
                                            caseObj.cc_Credit_Approval_Result__c = 'Approve';
                                        }

                                        if(caseAnnexRecord.cx_ln_Product__c == 'Secured'){
                                            //secured
                                            caseAnnexRecord.cx_ln_Credit_Pre_Screening_Result__c = 'Accept';
                                            caseObj.cc_Credit_Pre_Screening_Result__c = 'Accept';
                                            caseObj.cc_Credit_Pre_Screening_by__c = UserInfo.getUserId();
                                            caseAnnexRecord.cx_ln_Credit_Approval_Result__c = 'Approve';
                                            caseObj.cc_Credit_Approval_Result__c = 'Approve';

                             
                                        }
                                        
                                        //using this flag to say that the schedule is generated 
                                        caseAnnexRecord.cx_ln_isScheduleGenerated__c = true;

                                        // on approver acceptance, crm calls the update API with substates “pending offer acceptance “. 
                                        //API will recalculate, validate, drop the initial hold, create the new hold and return the holdReference,holdAmount and holdAccountBalance in the API response.
                                        if(apiStatusMappingRecord.apiStatus__c == 'PENDING_OFFER_ACCEPTANCE'){
                                            Map<String, Object> deserializeResponse1 = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                                            Map<String, Object> dataMap1 = (Map<String, Object>)deserializeResponse1.get('data');

                                            //#CH01 Start : Omar
                                            if(dataMap1.get('arrangementId') != null){
                                                caseObj.cc_PCI_Id__c = String.valueOf(dataMap1.get('arrangementId'));
                                            }
                                            //#CH01 END : Omar

                                            if(dataMap1.get('holdAmount') != null){
                                                caseObj.ccol_Hold_Amount__c = Decimal.valueOf(String.valueOf(dataMap1.get('holdAmount')));
                                            }
                                            if(dataMap1.get('holdReference') != null){
                                                caseObj.ccol_Hold_Reference_Number__c = String.valueOf(dataMap1.get('holdReference'));
                                            }
                                            if(dataMap1.get('holdAccountBalance') != null){
                                                caseObj.ccol_Hold_Account_Balance__c = Decimal.valueOf(String.valueOf(dataMap1.get('holdAccountBalance')));
                                            }
                                        }
                                    }
                                
                                }else if(apiStatusMappingRecord != null && apiStatusMappingRecord.isApiCall__c == false){
                                    system.debug('debug not calling API:');
                                    caseObj.Last_Api_Call_Status__c = 'Success';
                                    caseObj = LoanApplicationProcessFields(caseObj, caseAnnexRecord , 'cc_Credit_Approval_Result__c',apiStatusMappingRecord);
                                    caseAnnexRecord = tempCaseAnnexRecord;
                                    
                                }else {
                                    // No meteadata record was found
                                    system.debug('debug No meteadata record found'+caseObj.CaseNumber);
                                    
                                    /*lstSA.add(SM001_ApiCalls.setSystemAction( null,'Error Message : ' +'No meteadata record found'+caseObj.CaseNumber,
                                                                            null,null,
                                                                            caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                                            caseObj.Type+' updateLoanApiFutureMeth (No CC_Application_Status_Mapping__mdt meteadata record found for this changed field: '+changedField+')', caseObj.Type
                                                                            ));*/

                                    caseObj.Last_Api_Call_Status__c = 'Failed';

                                    caseAnnexRecord.put( 'cx_ln_Credit_Approval_Result__c' , null );
                                    caseObj.put( 'cc_Credit_Approval_Result__c' , null );
                                               
                                }                             
                            }
                            else{
                                caseObj.cc_Control_Type__c = null;
                            }

                            if(caseObj.ccol_Hold_Amount__c != null){
                                caseObj.Approved_Hold_Amount_in_words__c = CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(caseObj.ccol_Hold_Amount__c);//#CH03
                            }
                        }
                    }
                    when else {
                        // Start Handling metadata
                        CC_Application_Status_Mapping__mdt apiStatusMappingRecord = getApiStatusBasedOnCaseChanges(caseObj, caseAnnexRecord, objectSource ,changedField);
                        
                        if(apiStatusMappingRecord != null){
                            system.debug('debugging return metadata record : '+apiStatusMappingRecord.MasterLabel);
                        }

                        if(apiStatusMappingRecord != null && apiStatusMappingRecord.isApiCall__c == true ){

                            // paramsMap.put('status',apiStatusMappingRecord.apiStatus__c);
                            paramsMap.put('status',apiStatusMappingRecord.Status__c);
                            paramsMap.put('subStatus',apiStatusMappingRecord.Sub_Status__c);
                            paramsMap.put('crmCaseNo',caseObj.caseNumber);
                            paramsMap.put('crmCaseId',caseObj.Id);

                            // if(apiStatusMappingRecord.isDocuSign__c){

                            //     Loan_DocuSignEnvelopeReqWrapper requestWrapper = new Loan_DocuSignEnvelopeReqWrapper();
                            //     requestWrapper.cif = caseObj.Customer_CIF__c;
                            //     requestWrapper.caseId = caseObj.Id;
                            //     requestWrapper.channel = 'In-App';
                            //     requestWrapper.caseModel = caseObj.Case_Model__c;
                            //     Loan_DocuSignEnvelopeResponseWrapper resp = Loans_ServiceManagerHandler.createDocuSignEnvelope(requestWrapper);

                            //     paramsMap.put('contactId',resp.contactId);
                            //     paramsMap.put('envelopeId',resp.envelopeId);
                            // }
                            
                            if((apiStatusMappingRecord.fieldAPiName__c == 'cc_Credit_Approval_Result__c' && apiStatusMappingRecord.Value__c == 'Approve') ||
                                (apiStatusMappingRecord.fieldAPiName__c == 'cc_Operations_Result__c' && apiStatusMappingRecord.Value__c == 'Accept') ||
                                (apiStatusMappingRecord.fieldAPiName__c == 'cc_Signature_Verifier_Result__c' && apiStatusMappingRecord.Value__c == 'Accept') ||
                                apiStatusMappingRecord.apiStatus__c == 'PENDING_STL'
                            ){
                                //paramsMap.put('approvedAmount', caseAnnexRecord.cx_ln_Approved_Loan_Amount__c);//toBeCommented
                                //paramsMap.put('approvedInterestRate',caseAnnexRecord.cx_ln_ApprovedInterestProfitRateReducing__c);//toBeCommented
                                //paramsMap.put('approvedMonthlyInstallment',caseAnnexRecord.cx_ln_Approved_Installment_Amount__c);//toBeCommented
                                //paramsMap.put('approvedTenor',caseAnnexRecord.cx_ln_Approved_Duration_Months__c); //toBeCommented
                                //paramsMap.put('approvedCurrency','BHD');//toBeCommented
                                paramsMap.put('approvedCashInHand',caseAnnexRecord.cx_ln_Approved_Cash_in_Hand__c);
                                //paramsMap.put('approvedApr',caseAnnexRecord.cx_ln_APR__c); //toBeCommented
                                //paramsMap.put('approvedFee',caseAnnexRecord.cx_ln_Requested_Processing_Fees__c); //toBeCommented
                                //paramsMap.put('approvedVat',caseAnnexRecord.cx_ln_Requested_Vat_Processing_Fees__c); //toBeCommented
                                //paramsMap.put('approvedFirstPaymentDate',caseAnnexRecord.cx_ln_Approved_First_installment_date__c);//toBeCommented
                                //paramsMap.put('approvedMaturityDate',caseAnnexRecord.cx_ln_Approved_Maturity_Date__c);//toBeCommented
                                paramsMap.put('approvedInsuranceType',caseAnnexRecord.cx_ln_Approved_Insurance_Premium__c); 
                                paramsMap.put('approvedPreExistingInsurance',caseAnnexRecord.cx_ln_Approved_insurance__c);
                                paramsMap.put('approvedProcessingFeeType',caseAnnexRecord.cx_ln_ApprovedProcessing_Fee_Type__c);
                                //paramsMap.put('approvedInsuranceAmount',caseAnnexRecord.cx_ln_Approved_Insurance_Amount__c);//toBeCommented
                                paramsMap.put('conditionalSalaryCertificateRequired',caseAnnexRecord.cx_ln_RequireSalaryCertificate__c);

                                if(apiStatusMappingRecord.fieldAPiName__c == 'cc_Credit_Approval_Result__c' && apiStatusMappingRecord.Value__c == 'Approve'){
                                    String respEnvelopeId = details.get('envelopeId');
                                    String resContactId = details.get('contactId');
                                    if(respEnvelopeId != null && respEnvelopeId != ''){
                                        paramsMap.put('envelopeId',respEnvelopeId);
                                        paramsMap.put('contactId',resContactId);
                                    }
                                }
                            }

                            if(apiStatusMappingRecord.fieldAPiName__c == 'cc_Signature_Verifier_Result__c' && (apiStatusMappingRecord.Value__c == 'Re-Send' || apiStatusMappingRecord.Value__c == 'Re-Send In-App') ){ //#CH04
                                //paramsMap.put('recreateEnvelop',true);//toDo : check with Shameer to remove this or not??
                                String respEnvelopeId = details.get('envelopeId');
                                String resContactId = details.get('contactId');
                                if(respEnvelopeId != null && respEnvelopeId != ''){
                                    paramsMap.put('envelopeId',respEnvelopeId);
                                    paramsMap.put('contactId',resContactId);
                                }
                            }
                            // if(apiStatusMappingRecord.apiStatus__c == 'ACTIVE' || apiStatusMappingRecord.apiStatus__c == 'PENDING_OUTSTANDING_LETTER'
                            //     || apiStatusMappingRecord.apiStatus__c == 'PENDING_STL'){
                            if(caseAnnexRecord.cx_ln_Approved_Buyout_Amount__c != null && caseAnnexRecord.cx_ln_Document_Verifier_OBL_Result__c == 'Accept'){
                                paramsMap.put('isBuyOut', true);
                                paramsMap.put('approvedBuyoutAmount', caseAnnexRecord.cx_ln_Approved_Buyout_Amount__c);

                                //start NBA-17570 : 
                                if(caseAnnexRecord.cx_ln_Requested_MultiBankLiabilities__c != null && caseAnnexRecord.cx_ln_Requested_MultiBankLiabilities__c != ''){
                                    paramsMap.put('buyoutBanks', buildBuyoutBanks(caseAnnexRecord, caseObj));
                                } else {
                                    paramsMap.put('buyoutBanks', null );
                                }
                                //NBA-17570 : END
                            }else{
                                Boolean isBuyout = false;
                                Decimal liabilitiesAmount = 0;
                                if(caseAnnexRecord.cx_ln_Requested_Liabilities__c != null && caseAnnexRecord.cx_ln_Requested_Liabilities__c != ''){
                                    // Deserialize the JSON into a List of Objects (Map<String, Object>)
                                    List<Object> liabilities = (List<Object>) JSON.deserializeUntyped(caseAnnexRecord.cx_ln_Requested_Liabilities__c);
                                   
                                    for (Object item : liabilities) {
                                        Map<String, Object> liability = (Map<String, Object>) item;
                                        if (liability.containsKey('selected') && (Boolean)liability.get('selected') == true) {
                                            isBuyout = true; // At least one selected liability found
                                            liabilitiesAmount += (Decimal)liability.get('outstanding');
                                        }
                                    }
                                }
                                paramsMap.put('isBuyOut', isBuyout);
                                paramsMap.put('approvedBuyoutAmount', liabilitiesAmount);
                            }

                                
                            // }

                            // HttpResponse response;
                            //response = Loans_ServiceManagerHandler.updateLoanApplicationApi(caseObj, paramsMap);
                            // OMAR Start
                            HttpResponse response;
                            if ( test.isRunningTest() ) {
                               //fake response 
                               response = new HttpResponse();
                               String body1 = '{"meta":{"code":"LOAN-1003","message":"Successfully created loan application."},"data":{"crmCaseId":"500Pw00000NdUaTIAV","status":"Under Review","subStatus":"In-Progress"}}';
                               response.setStatus('OK');    
                               response.setStatusCode(200);
                               response.setBody(body1);
                               response.setHeader('Content-Type', 'application/json');
                            }else {
                               response = Loans_ServiceManagerHandler.updateLoanApplicationApi(caseObj, paramsMap);
                            }
                            // OMAR END
                            

                            system.debug('---> Response New --> '+response.getBody());
                            
                            if(response.getStatusCode() != 200){
                                if (apiStatusMappingRecord.object__c == 'CaseAnnex__c') {
                                    caseAnnexRecord.put( changedField , null );
                                } else {
                                    if( changedField != null && !changedField.equalsIgnoreCase('Sub_Status__c') ){
                                        caseObj.put( changedField , null ); 
                                    }
                                }
                                caseObj.Last_Api_Call_Status__c = 'Failed';
                            }
                            else{
                                system.debug('debug Success API');
                                caseObj.Last_Api_Call_Status__c = 'Success';
                                caseObj = LoanApplicationProcessFields(caseObj, caseAnnexRecord, changedField,apiStatusMappingRecord);
                                caseAnnexRecord = tempCaseAnnexRecord;
                                
                                //#CH01 Start: Omar
                                Map<String, Object> deserializeResponse1 = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                                Map<String, Object> dataMap1 = (Map<String, Object>)deserializeResponse1.get('data');
                                if(dataMap1.get('arrangementId') != null){
                                    caseObj.cc_PCI_Id__c = String.valueOf(dataMap1.get('arrangementId'));
                                }
                                //#CH01 END : Omar

                                if(apiStatusMappingRecord.status__c == 'Under Review' && apiStatusMappingRecord.Sub_Status__c == 'Pending Disbursement'){
                                    //toDo check the response 
                                    if(dataMap1.get('status') != null){
                                        caseObj.status = String.valueOf(dataMap1.get('status'));
                                    }
                                    if(dataMap1.get('subStatus') != null){
                                        caseObj.Sub_Status__c = String.valueOf(dataMap1.get('subStatus'));
                                    }
                                    //caseObj.status = 'Closed';
                                    //caseObj.Sub_Status__c = 'Approved';
                                }

                                // on approver acceptance, crm calls the update API with substates “pending offer acceptance “. 
                                //API will recalculate, validate, drop the initial hold, create the new hold and return the holdReference,holdAmount and holdAccountBalance in the API response.
                                if(apiStatusMappingRecord.apiStatus__c == 'PENDING_OFFER_ACCEPTANCE'){
                                    if(dataMap1.get('holdAmount') != null){
                                        caseObj.ccol_Hold_Amount__c = Decimal.valueOf(String.valueOf(dataMap1.get('holdAmount')));
                                    }
                                    if(dataMap1.get('holdReference') != null){
                                        caseObj.ccol_Hold_Reference_Number__c = String.valueOf(dataMap1.get('holdReference'));
                                    }
                                    if(dataMap1.get('holdAccountBalance') != null){
                                        caseObj.ccol_Hold_Account_Balance__c = Decimal.valueOf(String.valueOf(dataMap1.get('holdAccountBalance')));
                                    }
                                }

                                //update Customer Profile fields based 
                                if (apiStatusMappingRecord.fieldAPiName__c == 'cc_Credit_Approval_Result__c' && (apiStatusMappingRecord.Value__c == 'Approve' || apiStatusMappingRecord.Value__c == 'Decline') ){
                                    mapCasetoAccount.put(caseObj.Id, caseObj.AccountId);
                                }
                            }

                            //handle cross seling loan on expiry scenario
                            if(caseObj.AIR_HaveCreditCard__c == true && apiStatusMappingRecord.fieldAPiName__c == 'Sub_Status__c' && apiStatusMappingRecord.Value__c == 'Expired'){
                                if( caseObj.CaseAnnex__r.cx_ln_Cross_Selling_PreScreening_Result__c != 'Decline' && caseObj.CaseAnnex__r.cx_ln_Cross_Selling_PreScreening_Result__c != 'Cancelled' &&
                                    caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Evaluator_Result__c != 'Decline' && caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Evaluator_Result__c != 'Cancelled' &&
                                    caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Verifier_Result__c != 'Decline' && caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Verifier_Result__c != 'Cancelled' &&
                                    caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Approver_Result__c != 'Decline' && caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Approver_Result__c != 'Cancelled'
                                ){
                                    //Commented as per the defect UATNB-192759
                                    /*HttpRequest request2 = con.createRequest('POST', '/api/v1/credit-cards/cross?',regionName);
                                    HttpResponse response12 = Loan_CrossSellingCcFinalApproval.updateCrossSellingCaseStatusApi(request2,caseObj,'EXPIRED');
                                    //Store Both Success/Error Response 
                                    if(response12 != null && response12.getStatusCode() != null){
                                        lstSA.add(SM001_ApiCalls.setSystemAction( request2.getBody(),response12.getBody(),
                                                    request2.getEndpoint(),request2.getMethod(),
                                                        caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response12.getStatusCode(), 
                                                        caseObj.Type+' Request cross selling Status API', caseObj.Type
                                                    ));
                                        
                                    }*/
                                    //UATNB-192759: START
                                    caseIdsExpires.add(caseObj.Id);
                                    //UATNB-192759: END
                                }
                            }
                            //UATNB-192753: START
                            else if(caseObj.AIR_HaveCreditCard__c == true  && apiStatusMappingRecord.Value__c == 'Decline' 
                                && (apiStatusMappingRecord.fieldAPiName__c == 'cc_Credit_Approval_Result__c' || apiStatusMappingRecord.fieldAPiName__c == 'cc_Credit_Evaluation_Result__c' || apiStatusMappingRecord.fieldAPiName__c == 'cc_Credit_Pre_Screening_Result__c' || apiStatusMappingRecord.fieldAPiName__c == 'cc_Credit_Verification_Result__c' ) 
                            ){
                                if(caseObj.CaseAnnex__r.cx_ln_Cross_Selling_PreScreening_Result__c == 'Decline' || caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Evaluator_Result__c == 'Decline' ||
                                  caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Verifier_Result__c == 'Decline' || caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Approver_Result__c == 'Decline'){
                                    caseIdsDecline.add(caseObj.Id);
                                }
                            }
                            //UATNB-192753: END
                            
                            //UATNB-192750: START
                            else if(caseObj.AIR_HaveCreditCard__c == true  && apiStatusMappingRecord.Value__c == 'Cancelled'
                                && (apiStatusMappingRecord.fieldAPiName__c == 'cc_Credit_Approval_Result__c' || apiStatusMappingRecord.fieldAPiName__c == 'cc_Credit_Evaluation_Result__c' || apiStatusMappingRecord.fieldAPiName__c == 'cc_Credit_Pre_Screening_Result__c' || apiStatusMappingRecord.fieldAPiName__c == 'cc_Credit_Verification_Result__c' )
                            ){
                                if(caseObj.CaseAnnex__r.cx_ln_Cross_Selling_PreScreening_Result__c == 'Cancelled' || caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Evaluator_Result__c == 'Cancelled' ||
                                  caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Verifier_Result__c == 'Cancelled' || caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Approver_Result__c == 'Cancelled'){
                                    caseIdsCancelled.add(caseObj.Id);
                                }
                                
                            }
                            //UATNB-192750: END

                            //NBA-16577: START
                            else if(caseObj.AIR_HaveCreditCard__c == true && apiStatusMappingRecord.fieldAPiName__c == 'cc_Signature_Verifier_Result__c'){
                                if( apiStatusMappingRecord.Value__c == 'Decline' ){
                                    caseIdsDecline.add(caseObj.Id);
                                }
                                else if(apiStatusMappingRecord.Value__c == 'Cancelled by Customer'){
                                    caseIdsCancelled.add(caseObj.Id);
                                }
                            }
                            //NBA-16577: END
                        
                        }else if(apiStatusMappingRecord != null && apiStatusMappingRecord.isApiCall__c == false){
                            system.debug('debug not calling API:');
                            caseObj.Last_Api_Call_Status__c = 'Success';
                            caseObj = LoanApplicationProcessFields(caseObj, caseAnnexRecord, changedField,apiStatusMappingRecord);
                            caseAnnexRecord = tempCaseAnnexRecord;
                            
                        }else {
                            // No meteadata record was found
                            system.debug('debug No meteadata record found'+caseObj.CaseNumber);
                            
                            /*lstSA.add(SM001_ApiCalls.setSystemAction( null,'Error Message : ' +'No meteadata record found'+caseObj.CaseNumber,
                                                                     null,null,
                                                                     caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                                     caseObj.Type+' updateLoanApiFutureMeth (No CC_Application_Status_Mapping__mdt meteadata record found for this changed field: '+changedField+')', caseObj.Type
                                                                    ));*/
                            caseObj.Last_Api_Call_Status__c = 'Failed';
                            if (objectSource == 'CaseAnnex__c') {
                                caseAnnexRecord.put( changedField , null );
                            } else {
                                if( changedField != null && !changedField.equalsIgnoreCase('Sub_Status__c') && !changedField.equalsIgnoreCase('Status') ){
                                    caseObj.put( changedField , null ); 
                                }
                            }            
                        }

                        caseObj.Loan_case_Annex_changed_field__c = null;
                        caseObj.Loan_case_Annex_changed_field_new_value__c = null;
                        caseObj.Loan_case_Annex_changed_field_old_value__c = null;

                        if(caseObj.ccol_Hold_Amount__c != null){
                            caseObj.Approved_Hold_Amount_in_words__c = CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(caseObj.ccol_Hold_Amount__c);//#CH03
                        }

                        // End Handling metadata
                    }
                }

                if(changedField == 'Status' || changedField == 'Sub_Status__c'){
                    caseAnnexRecord = handleReminderFields(caseObj, caseAnnexRecord);
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            lstSA.add(SM001_ApiCalls.setSystemAction( null,'Error Message : ' +e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString()),
                                                        null,null,
                                                        caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                        caseObj.Type+'updateLoanApiFutureMeth (unhandled error)', caseObj.Type
                                                    ));
                    
        }

        if(cases != null && cases.size()>0){
            system.debug('Debug Update Case:');
            update caseObj;
        }

        if(CaseAnnexs != null && CaseAnnexs.size()>0){
            system.debug('Debug Update Case Annex:');
            update caseAnnexRecord;
        }

        //UATNB-192759: START
        String Status = '';
        if(caseIdsExpires.size()>0){
            Status = 'EXPIRED';
            LoanCrossSellingQueuable loanCrossSelling = new LoanCrossSellingQueuable(caseIdsExpires,Status);
            System.enqueueJob(loanCrossSelling);
        }
        //UATNB-192759: END

        //UATNB-192753: START
        if(caseIdsDecline.size()>0){
            Status = 'DECLINED';
            LoanCrossSellingQueuable loanCrossSellingDecline = new LoanCrossSellingQueuable(caseIdsDecline,Status);
            System.enqueueJob(loanCrossSellingDecline);
        }
        //UATNB-192753: END
        
        //UATNB-192750: START
        if(caseIdsCancelled.size()>0){
            Status = 'CANCELLED';
            LoanCrossSellingQueuable loanCrossSellingCancelled = new LoanCrossSellingQueuable(caseIdsCancelled,Status);
             System.enqueueJob(loanCrossSellingCancelled);
        }
        //UATNB-192750: END
        if(lstSA != null && lstSA.size()>0 && !Test.isRunningTest()){
            
            insert lstSA;
        }
        
        if(lstComment != null && lstComment.size()>0){
            insert lstComment;
        }

        if(!mapCasetoAccount.isEmpty()) {
            System.enqueueJob( new UpdateCaseFieldJob(mapCasetoAccount) );
        }
        
        system.debug('mapEmailPerCase '+mapEmailPerCase);
        // Handle Email Alerts
        for( Case cs : mapEmailPerCase.keySet() ){
            
            Flow.Interview loansNotificationsFlow = Flow.Interview.createInterview('Loans_Notifications_Flow', 
                                                    new Map<String, Object>{
                                                        'newCase' => cs,
                                                        'NotificationTime' => 'immediate'
                                                    });

            loansNotificationsFlow.start();

        }

        system.debug('emailtoOwnerCases '+emailtoOwnerCases);
        // Handle Email Alerts for internal emails to oner
        for( Case cs : emailtoOwnerCases ){
            
            Flow.Interview loansNotificationsFlow1 = Flow.Interview.createInterview('Loans_Notifications_Flow', 
                                                    new Map<String, Object>{
                                                        'newCase' => cs,
                                                        'varT_EmailDeveloperName' => 'Email_Notification_General'
                                                    });

            loansNotificationsFlow1.start();
        }
    }

    @AuraEnabled
    public static Map<String, Object> generateRepaymentScheduleApiHandler (Case caseRecord ,CaseAnnex__c caseAnnexRecord)
    {   
        System.debug('generateRepaymentScheduleApiHandler: execute Method');
        Map<String, Object> result = new Map<String, Object>();
        try {

            //no need to create logs for this api , 
            //.. if yes, please handle the creation on this class to avoid the error : "Error Message : You have uncommitted work pending. Please commit or rollback before calling out .."
            HttpRequest request = Lwc03_FinancialDetailsController.prepareSimulationRequest(caseRecord,caseAnnexRecord);
            HttpResponse simulationResp = Lwc03_FinancialDetailsController.callSimulationApi(caseRecord,caseAnnexRecord,request,false);//make the flag to false to not save system log
            //store system log all the time
            lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),simulationResp.getBody(),
                                                        request.getEndpoint(),request.getMethod(),
                                                        caseRecord.id,caseRecord.Customer_CIF__c,caseRecord.accountId,simulationResp.getStatusCode(), 
                                                        'call simulation schedule API', caseRecord.Type
                                                    ));

            if (simulationResp.getStatusCode() != 200)
            {
                System.debug('The status code returned was not expected: ' + simulationResp.getStatusCode() + ' ' + simulationResp.getStatus());
                result.put('status', 'Error');
                Map<String, Object> m1 = (Map<String, Object>)JSON.deserializeUntyped(simulationResp.getBody());
                Map<String, Object> scheduleRespMeta = (Map<String, Object>)m1.get('meta');
                String msg = (String)scheduleRespMeta.get('message');
                result.put('message', 'Error occurred while calling the simulation schedule API : ' + msg);
            }
            else
            {
                System.debug('bcrbp api simulationResp.getBody() : ' + simulationResp.getBody());
                result.put('status', 'Success');
                result.put('response', simulationResp.getBody());
                Map<String, Object> m1 = (Map<String, Object>)JSON.deserializeUntyped(simulationResp.getBody());
                Map<String, Object> scheduleResp = (Map<String, Object>)m1.get('data');
                caseAnnexRecord.cx_ln_SimulationReference__c = (String)scheduleResp.get('simulationReference');
            }
        } catch (Exception e) {
            result.put('status', 'Error');
            result.put('message', 'Error occurred while processing: ' + e.getMessage());
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }

        return result;
    }

    //////////////////////////////////
    public static Case LoanApplicationProcessFields( Case caseObj,CaseAnnex__C caseAnnexRecord, String changedField ,CC_Application_Status_Mapping__mdt apiStatusMappingRecord){
        
        String regionName = caseObj.Region_Flag__c; 
        
        caseObj.Awaiting_Customer_Feedback__c = apiStatusMappingRecord.Awaiting_Customer_Feedback__c;
        if(apiStatusMappingRecord.Sub_Status__c != null ){
            caseObj.Sub_Status__c = apiStatusMappingRecord.Sub_Status__c;
            caseObj.LastCaseSubStatusChanged__c = System.now();
                        
        }      
        if(apiStatusMappingRecord.Status__c != null ){

            caseObj.Status = apiStatusMappingRecord.Status__c;
            caseAnnexRecord.cx_ln_Last_Status_Changed_Date_Time__c = System.now();

            if(apiStatusMappingRecord.Status__c == 'Pending' && apiStatusMappingRecord.Sub_Status__c == 'Pending Offer Acceptance' ){
                caseAnnexRecord.cx_ln_Review_Offer_Date_Time__c = System.now();
            } 
            // else {
            //     caseAnnexRecord.cx_ln_Review_Offer_Date_Time__c = null;
            // }

            caseAnnexRecord = handleReminderFields(caseObj, caseAnnexRecord);
            
            
        }   
        
        if(apiStatusMappingRecord.fieldAPiName__c == 'Status' && apiStatusMappingRecord.Value__c == 'Pending Signature' ){

            caseAnnexRecord = handleReminderFields(caseObj, caseAnnexRecord);
            
        }
        
        if(apiStatusMappingRecord.queueDeveloperName__c != null ){
            caseObj.OwnerId = getQueueIdBasedOnQueueDevName(apiStatusMappingRecord.queueDeveloperName__c);
            emailtoOwnerCases.add(caseObj);
        }
        if(apiStatusMappingRecord.cc_Application_Stages__c != null ){
            caseObj.cc_Application_Stages__c = apiStatusMappingRecord.cc_Application_Stages__c;
        }
        if(apiStatusMappingRecord.isApiCall__c == true){
            caseObj.Last_Api_Call_Status__c = 'Success';
        }
        if(apiStatusMappingRecord.crmStage__c != null){
            caseObj.cc_CRM_Stage__c = apiStatusMappingRecord.crmStage__c;
        }
        if(apiStatusMappingRecord.emailAlertName__c != null && apiStatusMappingRecord.emailAlertName__c != ''){
            mapEmailPerCase.put(caseObj,apiStatusMappingRecord.emailAlertName__c);
        }
        
        if( apiStatusMappingRecord.sectionResultFields__c != null ){
            List<string> fieldList = apiStatusMappingRecord.sectionResultFields__c.split(';');
            String commentResult;
            system.debug('fieldList : ' +fieldList);
            List<string> fieldList0 = fieldList.get(0).split('\\.');
            system.debug('fieldList0 : ' +fieldList0);
            if(fieldList0.size() > 1){
                if(fieldList0.get(0) == 'CaseAnnex__c'){
                    caseAnnexRecord.put(fieldList0.get(1),System.now());
                } else {
                    caseObj.put(fieldList0.get(0),System.now());
                    
                }
            }else {
                caseObj.put(fieldList.get(0),System.now());
                
            }

            List<string> fieldList1 = fieldList.get(1).split('\\.');
            if(fieldList1.size() > 1){
                if(fieldList1.get(0) == 'CaseAnnex__c'){
                    caseAnnexRecord.put(fieldList1.get(1),UserInfo.getUserId());
                } else {
                    caseObj.put(fieldList1.get(0),UserInfo.getUserId());
                    
                }
            } else {
                caseObj.put(fieldList.get(1),UserInfo.getUserId());
                
            }

            if(fieldList.size() > 2){
                List<string> fieldList2 = fieldList.get(2).split('\\.');
                if(fieldList2.size() > 1){
                    if(fieldList2.get(0) == 'CaseAnnex__c'){
                        commentResult = (String)caseAnnexRecord.get(fieldList2.get(1));
                    } else {
                        commentResult = (String)caseObj.get(fieldList2.get(1));
                    }
                } else {
                    commentResult = (String)caseObj.get(fieldList.get(2));
                }
                 System.debug('commentResult'+commentResult);
                if( commentResult != null ){
                    CaseComment resultComm = new CaseComment( ParentID=caseObj.id, CommentBody= fieldList.get(3) + ' - '+ commentResult );
                    System.debug('commentResult'+commentResult);
                    lstComment.add(resultComm);
    
                    if(fieldList2.size() > 1){
                        if(fieldList2.get(0) == 'CaseAnnex__c'){
                            caseAnnexRecord.put(fieldList2.get(1),null);
                        } else {
                            caseObj.put(fieldList2.get(1),null);
                        }
                    } else {
                        caseObj.put(fieldList.get(2),null);
                    }
                    
                }
            }

        }

        if( apiStatusMappingRecord.fieldsToBeReseted__c != null ){
            
            for(String Field: apiStatusMappingRecord.fieldsToBeReseted__c.split(';')){
                String fieldName;
                String objectName;
                System.debug('Field'+Field);
                List<string> ListField = Field.split('\\.');
                if(ListField.size() > 1 && ListField.get(0) == 'CaseAnnex__c'){
                    
                    objectName = 'CaseAnnex__c';
                    fieldName = ListField.get(1);
                    SObjectType r = ((SObject)(Type.forName('Schema.'+objectName).newInstance())).getSObjectType();
                    DescribeSObjectResult d = r.getDescribe();
                    if( d.fields.getMap().get(fieldName)!= null && String.valueof(d.fields.getMap().get(fieldName).getDescribe().getType()) == 'BOOLEAN'){
                        caseObj.put(FieldName,false);
                        continue;
                    }
                    System.debug('FieldName'+FieldName);
                    caseAnnexRecord.put(FieldName,null);

                } else {
                    objectName = 'Case';
                    fieldName = Field;
                    SObjectType r = ((SObject)(Type.forName('Schema.'+objectName).newInstance())).getSObjectType();
                    DescribeSObjectResult d = r.getDescribe();
                    if( d.fields.getMap().get(fieldName)!= null && String.valueof(d.fields.getMap().get(fieldName).getDescribe().getType()) == 'BOOLEAN'){
                        caseObj.put(FieldName,false);
                        continue;
                    }
                    System.debug('FieldNamecase'+FieldName);
                    caseObj.put(FieldName,null);
                }
                
                
            }
        }

        tempCaseAnnexRecord = caseAnnexRecord;

        // Trigger immediate email
        // if(apiStatusMappingRecord.emailAlertName__c != null && apiStatusMappingRecord.emailAlertName__c != ''){
            
        //     // Flow.Interview loansNotificationsFlow = Flow.Interview.createInterview('Loans_Notifications_Flow', 
        //     //                                         new Map<String, Object>{
        //     //                                             'newCase' => caseObj,
        //     //                                             'NotificationTime' => 'immediate'
        //     //                                         });

        //     // loansNotificationsFlow.start();

        // }

        return caseObj;
    }

    ///////////////////////////////
    public static caseAnnex__c handleReminderFields (Case caseObj, caseAnnex__c caseAnnexRecord){
        // Start Handle Reminder Fields
        List<Case_Reminder_Configuration__mdt> reminderMetadataList = [SELECT MasterLabel,Status__c,SubStatus__c,Reminder_1_Hours__c,Reminder_2_Hours__c,Reminder_3_Hours__c, Expiry_Hours__c 
        FROM Case_Reminder_Configuration__mdt  
        WHERE Status__c = :caseObj.Status AND SubStatus__c = :caseObj.Sub_Status__c AND Case_Type__c = :caseObj.Type];

        if (!reminderMetadataList.isEmpty()) { 

            System.debug('Case_Reminder_Configuration__mdt record: ' + reminderMetadataList[0].MasterLabel);
            Case_Reminder_Configuration__mdt reminderMetadataRecord = reminderMetadataList[0];
            Datetime currentDT = Datetime.now();

            // Add Seconds
            // caseAnnexRecord.cx_ln_Reminder_1_Datetime__c = currentDT.addSeconds(40);
            // caseAnnexRecord.cx_ln_Reminder_2_Datetime__c = currentDT.addSeconds(70);
            // caseAnnexRecord.cx_ln_Reminder_3_Datetime__c = currentDT.addSeconds(100);
            // caseAnnexRecord.cx_ln_expiry_Datetime__c = currentDT.addSeconds(150);

            // Add minutes
            caseAnnexRecord.cx_ln_Reminder_1_Datetime__c = reminderMetadataRecord.Reminder_1_Hours__c != null ? currentDT.addMinutes(5) : null;
            caseAnnexRecord.cx_ln_Reminder_2_Datetime__c = reminderMetadataRecord.Reminder_2_Hours__c != null ? currentDT.addMinutes(10) : null;
            caseAnnexRecord.cx_ln_Reminder_3_Datetime__c = reminderMetadataRecord.Reminder_3_Hours__c != null ? currentDT.addMinutes(15) : null;
            caseAnnexRecord.cx_ln_expiry_Datetime__c = reminderMetadataRecord.Expiry_Hours__c != null ? currentDT.addMinutes(2800) : null;

            // Add Hours // toDo Uncoment before deployment
            // caseAnnexRecord.cx_ln_Reminder_1_Datetime__c = reminderMetadataRecord.Reminder_1_Hours__c != null ? currentDT.addHours(reminderMetadataRecord.Reminder_1_Hours__c.intValue()) : null;
            // caseAnnexRecord.cx_ln_Reminder_2_Datetime__c = reminderMetadataRecord.Reminder_2_Hours__c != null ? currentDT.addHours(reminderMetadataRecord.Reminder_2_Hours__c.intValue()) : null;
            // caseAnnexRecord.cx_ln_Reminder_3_Datetime__c = reminderMetadataRecord.Reminder_3_Hours__c != null ? currentDT.addHours(reminderMetadataRecord.Reminder_3_Hours__c.intValue()) : null;
            // caseAnnexRecord.cx_ln_expiry_Datetime__c = reminderMetadataRecord.Expiry_Hours__c != null ? currentDT.addHours(reminderMetadataRecord.Expiry_Hours__c.intValue()) : null;

        } else {
            System.debug('No matching metadata record found.');
            caseAnnexRecord.cx_ln_Reminder_1_Datetime__c = null;
            caseAnnexRecord.cx_ln_Reminder_2_Datetime__c = null;
            caseAnnexRecord.cx_ln_Reminder_3_Datetime__c = null;
            caseAnnexRecord.cx_ln_expiry_Datetime__c = null;
        }
        // End Handle Reminder Fields

        return caseAnnexRecord;
    }

    //////////////////////////////////
    public static Id getQueueIdBasedOnQueueDevName(String queueName ) {
        List<Group> queueIds = [SELECT Id, Name, DeveloperName from Group where type = 'queue' and DeveloperName =: queueName];
        
        if(queueIds != null && queueIds.size()>0 ){
            System.debug('Debug queue Ids: '+queueIds);
            return queueIds[0].Id;
        }
        return null;
    }

    /////////////////////////////////////
    public static CC_Application_Status_Mapping__mdt getApiStatusBasedOnCaseChanges( Case caseObj, CaseAnnex__C CaseAnnexRecord, String ObjectSource, String changedField ){
        
        String fieldValue ;
        if(ObjectSource == 'CaseAnnex__c'){
            fieldValue = String.valueOf(CaseAnnexRecord.get(changedField));
        }else{
            fieldValue = String.valueOf(caseObj.get(changedField));
        }
        system.debug('Metada caseObj.Type '+caseObj.Type);
        system.debug('Metada caseObj.Region_Flag__c '+caseObj.Region_Flag__c);
        system.debug('Metada changedField '+changedField);
        system.debug('Metada fieldValue '+fieldValue);
        system.debug('Metada caseObj.RecordType_DeveloperName__c '+caseObj.RecordType_DeveloperName__c);

        List<CC_Application_Status_Mapping__mdt> mappingMetadataList = [SELECT id,Label, fieldAPiName__c, Value__c, apiStatus__c,Awaiting_Customer_Feedback__c,Sub_Status__c,
                                                                        queueDeveloperName__c,isApiCall__c,crmStage__c,emailAlertName__c,cc_Application_Stages__c,regionName__c,Status__c,
                                                                        Type__c, criteria__c,MasterLabel,isDocuSign__c,sectionResultFields__c, fieldsToBeReseted__c, Object__c
                                                                        FROM CC_Application_Status_Mapping__mdt 
                                                                        WHERE Type__c = :caseObj.Type AND regionName__c = :caseObj.Region_Flag__c AND fieldAPiName__c = :changedField 
                                                                        AND Value__c = :fieldValue AND RecordType_DeveloperName__c =:caseObj.RecordType_DeveloperName__c];
        
        CC_Application_Status_Mapping__mdt defaultMetadataRec = null;
        system.debug('debugging Metadata List:' +mappingMetadataList);
        
        for(CC_Application_Status_Mapping__mdt metadataRec : mappingMetadataList) {
            if(metadataRec.criteria__c == null){
                defaultMetadataRec = metadataRec;
                continue;
            }
            if(evaluateCriteria(ObjectSource, caseObj, CaseAnnexRecord, metadataRec.criteria__c)){
                return metadataRec;
            }
            
        }                                           
        return defaultMetadataRec;
    }
    
    ///////////////////////////////////////
    public static Boolean evaluateCriteria(String ObjectSource, Case caseObj, CaseAnnex__c CaseAnnexRecord, String criteriaField ){
        Boolean result = true;
        for(String criteria:criteriaField.split('&&')){
            
            List<string> opList = criteria.split(';');
            
            String caseField = opList[0];
            String operator = opList[1];
            String value = opList[2];
            String fieldValue;
            if(caseField.contains('.')){
                String[] caseFieldList = caseField.split('\\.');
                if(caseFieldList.get(0) == 'CaseAnnex__c'){
                    fieldValue = String.valueOf(CaseAnnexRecord.get(caseFieldList.get(1)));
                } else { 
                    fieldValue = String.valueOf(caseObj.get(caseFieldList.get(1)));
                }
                
            } else {
                fieldValue = String.valueOf(caseObj.get(caseField));
            }

            if(operator == '=='){
                result = result && (fieldValue == value);
            } else if(operator == '!='){
                result = result && (fieldValue != value);
            }
        }
        return result;
    }


    // //////////////////////////////////
    public static void sendEmailAlert(Case objCase,String emailAlertName){
        
        Map<String, Object> Params = new Map<String, Object>();
        Params.put('recordId',objCase.Id);
        Params.put('emailAlertName',emailAlertName);
        Params.put('caseModel',objCase.Case_Model__c);
        Params.put('caseRecordTyeName',objCase.RecordType_DeveloperName__c);
        //create instance of Interview
        Flow.Interview.Send_Emails_Alert_Flow stage = new Flow.Interview.Send_Emails_Alert_Flow(Params);
        //Invoke start method
        stage.start(); 
    } 


    //call the bcrb decisioning "/api/v1/bcrb/decision" in case of secured loans
    public static HttpResponse callBcrbDecisioningApi(HttpRequest request,Case objCase,CaseAnnex__c caseAnnexRecord){
        PAD.debugLogBegin(CLASS_NAME, 'callBcrbDecisioningApi','Parameters : [objCase] : '+ objCase);
        System.debug('test bcrB Case >> '+ objCase.Customer_CIF__c +' ... '+  objCase.Account.PersonEmail);
        request.setHeader('customerId', objCase.Customer_CIF__c);
        request.setHeader('userId', objCase.Account.PersonEmail);
 
        Map<String, String> requestObject = new Map<String, String>{
            'crmCaseId' => objCase.Id,
            'facilityAmount' => String.valueOf(caseAnnexRecord.cx_ln_Requested_Loan_Finance_Amount__c),
            'facilityDuration' => String.valueOf(caseAnnexRecord.cx_ln_Requested_Duration_Months__c),
            'facilityMonthlyInstalment' => String.valueOf(caseAnnexRecord.cx_ln_Monthly_Instalment__c), 
            'generateReport' => 'false',
            'target' => 'PERSONAL_LOAN_SECURED'
        };
       
        request.setBody( JSON.serialize(requestObject) );

        
        System.debug('********************* callBcrbDecisioningApi request.getEndpoint() **********************');
        System.debug(request.getEndpoint());
        
        System.debug('********************* callBcrbDecisioningApi request.getBody() **********************');
        System.debug(request.getBody());
        
        request.setTimeout(60000);
        HttpResponse response;
        if ( test.isRunningTest() ) {
            //fake response 
            response = new HttpResponse();
            String body1 = '{"meta":{"code":"CCRD-12345","message":"application is captured successfully"},"data":{"decision":"STP","manualReason":null}}';
            response.setStatus('OK');    
            response.setStatusCode(200);
            response.setBody(body1);
            response.setHeader('Content-Type', 'application/json');
        }else {
            Http http = new Http();
            response = http.send(request);
        }

        PAD.debugLogEnd(CLASS_NAME, 'callBcrbDecisioningApi', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        
        return response;
    }

    //Start NBA-17570
    public static Boolean isBahrainWorkingDay(Date d) {
        // Bahrain weekend = Friday + Saturday
        Datetime dt = Datetime.newInstance(d,Time.newInstance(12, 0, 0, 0));
        String dayName = dt.format('EEE', 'Asia/Bahrain');
        if (dayName == 'Fri' || dayName == 'Sat') {
            return false;
        }
        // Check Salesforce Holiday calendar
        Integer holidayCount = [SELECT COUNT() FROM Holiday WHERE ActivityDate = :d];
        return holidayCount == 0;
    }
    private static List<Map<String, Object>> buildBuyoutBanks(CaseAnnex__c caseAnnexRecord,Case caseObj) {
        Map<String, Loan_MultiBankLiability__mdt> multiBankConfigByEntity = new Map<String, Loan_MultiBankLiability__mdt>();
        for (Loan_MultiBankLiability__mdt config : [SELECT EntityBankName__c,IsActive__c,BeneficiaryAddress__c,BeneficiaryBankIBAN__c,PaymentType__c,SwiftCode__c FROM Loan_MultiBankLiability__mdt WHERE IsActive__c = true]) {
            if (!String.isBlank(config.EntityBankName__c)) {
                multiBankConfigByEntity.put(config.EntityBankName__c, config);
            }
        }
        List<Object> dataList = (List<Object>) JSON.deserializeUntyped(caseAnnexRecord.cx_ln_Requested_MultiBankLiabilities__c);
        List<Map<String, Object>> selectedItems = new List<Map<String, Object>>();
        
        // Calculate Bahrain value date once
        Date bahrainToday = Date.valueOf(Datetime.now().format('yyyy-MM-dd', 'Asia/Bahrain'));
        Integer bahrainHour = Integer.valueOf(Datetime.now().format('H', 'Asia/Bahrain'));
        Date valueDate = bahrainToday;
        if (!isBahrainWorkingDay(valueDate) || bahrainHour >= 13) {
            do {
                valueDate = valueDate.addDays(1);
            } while (!isBahrainWorkingDay(valueDate));
        }

        for (Object item : dataList) {
            Map<String, Object> itemObj = (Map<String, Object>) item;
            if (itemObj.containsKey('selected') && (Boolean) itemObj.get('selected') == true) {
                String entity = String.valueOf(itemObj.get('entity'));
                Loan_MultiBankLiability__mdt config = multiBankConfigByEntity.get(entity);
                String chequeNumber = String.valueOf(itemObj.get('chequeNumber'));
                String liabilityId = String.valueOf(itemObj.get('liabilityID'));
                Decimal outstandingAmount = Decimal.valueOf( String.valueOf(itemObj.get('outstanding')));
                String senderInformation = 'SETTLEMENT OF LOAN NUMBER ' +liabilityId +' RELATED TO ' +caseObj.cc_Full_Name__c +' (' +caseObj.cc_CPR_Number__c +')';
                String receiver = config?.SwiftCode__c;

                Map<String, Object> apiItem = initializeBuyoutBanksMapBody();
                apiItem.put('bankName', entity);
                apiItem.put('paymentType', config?.PaymentType__c);
                apiItem.put('currency', 'BHD');
                apiItem.put('outstandingAmount', outstandingAmount);
                apiItem.put('liabilityId', liabilityId);
                
                if (config?.PaymentType__c == 'MT103') {
                    apiItem.put( 'beneficiaryNameAddress',entity + ', ' + config?.BeneficiaryAddress__c);
                }
                if (config?.PaymentType__c == 'MT103' || config?.PaymentType__c == 'Internal') {
                    apiItem.put('beneficiaryBankIBAN',config?.BeneficiaryBankIBAN__c);
                }
                
                apiItem.put('sender', FIXED_SENDER);
                
                if (config?.PaymentType__c == 'MT103') {
                    apiItem.put('remittanceInformation',senderInformation);
                }
                if (config?.PaymentType__c == 'MT202' || config?.PaymentType__c == 'MT103') {
                    apiItem.put('receiver', receiver);
                    apiItem.put('senderInformation', senderInformation);
                }

                if (config?.PaymentType__c == 'Cheque') {
                    apiItem.put('payeeName', liabilityId);
                    apiItem.put('paymentDetails',senderInformation);
                    apiItem.put('senderInformation', chequeNumber);
                }
                //toDo : check with Ashish
                apiItem.put('valueDate',String.valueOf(valueDate));

                selectedItems.add(apiItem);
            }
        }

        return selectedItems.isEmpty() ? null : selectedItems;
    }
    private static Map<String, Object> initializeBuyoutBanksMapBody(){
        Map<String, Object> apiItem = new Map<String, Object>();
        apiItem.put('bankName', '');
        apiItem.put('paymentType', '');
        apiItem.put('currency', '');
        apiItem.put('outstandingAmount', '');
        apiItem.put('liabilityId', '');
        apiItem.put( 'beneficiaryNameAddress','');
        apiItem.put('beneficiaryBankIBAN','');
        apiItem.put('sender', '');
        apiItem.put('remittanceInformation','');
        apiItem.put('receiver', '');
        apiItem.put('senderInformation', '');
        apiItem.put('payeeName', '');
        apiItem.put('paymentDetails','');
        apiItem.put('valueDate','');
        return apiItem;
    }
    //End NBA-17570

    ///////////////////////////////////////
    public class LoanWrapper {
        @InvocableVariable(label='Case Id' description='the Id of the Case' required=true)
        public String caseId;
        
        @InvocableVariable(label='isNew' description='used after insert (yes or no)')
        public String isNew;
        
        @InvocableVariable(label='objectSource' description='Object apiName')
        public String objectSource;

        @InvocableVariable(label='changedField' description='changedField apiName')
        public String changedField;

        @InvocableVariable(label='isSynchronousCallout' description='isSynchronousCallout')
        public String isSynchronousCallout;
    }

    // Inner class to update
    public class UpdateCaseFieldJob implements Queueable {
        private Map<Id, Id> mapCasetoAccount;

        public UpdateCaseFieldJob(Map<Id, Id> mapCasetoAccount) {
            this.mapCasetoAccount = mapCasetoAccount;
        }

        public void execute(QueueableContext qc) {
            System.debug('execute Queueable method UpdateCaseFieldJob -- to call creditCardCustomerProfileUpdate.updateCustomerdetails');
            creditCardCustomerProfileUpdate.updateCustomerdetails(mapCasetoAccount); //call queable
        }
    }
}