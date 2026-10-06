public without sharing class Lwc03_FinancialDetailsController {

    private static String CLASS_NAME = Lwc03_FinancialDetailsController.class.getName();
    private static ApiConnection con = new ApiConnection();

    public static HttpResponse callBcrbApi (HttpRequest request,Case caseRecord ,CaseAnnex__c caseAnnexRecord)
    {   
        String customerId = caseRecord.Customer_CIF__c;
        
        Http http = new Http(); 
        request.setTimeout(60000);
        if(customerId != null && customerId != ''){
            request.setHeader('customerId', customerId);
        }
        Decimal loanMonthlyInstalment;
        if(caseAnnexRecord.cx_ln_Approved_Installment_Amount__c != null){
            loanMonthlyInstalment = caseAnnexRecord.cx_ln_Approved_Installment_Amount__c;
        }else{
            loanMonthlyInstalment = caseAnnexRecord.cx_ln_Monthly_Instalment__c;
        }

        String body = '{"loanAmount": '+ caseAnnexRecord.cx_ln_Approved_Loan_Amount__c 
                        +', "loanDuration": '+caseAnnexRecord.cx_ln_Approved_Duration_Months__c
                        +', "loanMonthlyInstalment": '+ loanMonthlyInstalment +
                        +', "crmCaseId": '+ stringApiFormat(caseRecord.id) +
                        +', "isFileUploadRequired": '+ stringApiFormat('true') +
                    '}';
        request.setBody(body);

        HttpResponse bcrbResp;
        if ( test.isRunningTest() ) {
            //fake bcrbResp 
            bcrbResp = new HttpResponse();
            String body1 = '{"meta":{"code":"bcrb-1000","message":"Successfully retrieved liabilities."},"data":{"totalConsumerLoans":200,"totalMortgageLoans":320,"totalCreditCards":600.00,"totalGovernmentLoans":120,"totalOverdraftInstallments":0,"totalLeverageLoanInstallments":0,"totalBuyNowPayLaterInstallments":0,"totalCurrentObligations":1240.00,"totalCreditExposure":27100,"creditBureauScore":800,"transactionNo":"2172174","currentPSIExpiryDate":"2021-01-21","loanApplicationDecision":"No Decision","currentLoansLimit":56400.00,"totalIObligations":0,"numberOfArrears":0,"numberOfCorporateAccounts":0,"numberOfNonOwnerAccounts":0,"numberOfOpenedPSICases":1,"numberOfRejectedPSI30Days":0,"numberOfPSIILARejections":0,"numberOfNonNormalAccounts":0,"totalOfArrearsCurrentAndHistorical":0,"totalOfPenaltiesAndContraventionAccounts":0,"currentCustomerStatus":"Normal","numberOfCreditCardsWithoutIla":4,"numberOfIlaCreditCards":1,"totalCreditCardInstallments":530,"totalIlaCreditCardInstallmentsWithoutIla":410,"totalIlaCreditCardInstallments":120,"totalNumberOfLoans":0,"numberOfArrears1":0,"numberOfArrearsCurrentAndHistorical":0,"numberOfArrearsWithGovLoans":0,"numberOfArrearsWithoutGovLoans":0,"totalCurrentObligations1":0,"currentLoansLimit1":0,"currentCustomerStatus1":"Normal","numberOfCorporateAccounts1":0,"numberOfNonOwnerAccounts1":0,"numberOfOpenedPsiCases":1,"numberOfRejectedPsi30Days":0,"numberOfBillingAccounts":0}}';
            bcrbResp.setStatus('OK');    
            bcrbResp.setStatusCode(200);
            bcrbResp.setBody(body1);
            bcrbResp.setHeader('Content-Type', 'application/json');
        }else{
            bcrbResp = http.send(request);
        }
        return bcrbResp;
    }

    /*public static HttpResponse callEsalaryApi (Case caseRecord ,CaseAnnex__c caseAnnexRecord)
    {   
        String regionName = caseRecord.Region_Flag__c ; 
        String customerId = caseRecord.AccountId;
        if ( caseRecord.Case_Model__c == 'alburaq' ) {
            regionName += '_alburaq';
        }
        
        Http http = new Http();
        HttpRequest request1 = con.createRequest('POST', '/api/v1/bcrb/salary/certificate',regionName); 
        request1.setTimeout(60000);
        if(customerId != null && customerId != ''){
            request1.setHeader('customerId', customerId);
        }

        String body1 = '{"loanAmount": "'+ caseAnnexRecord.cx_ln_Requested_Loan_Finance_Amount__c +'", "loanDuration": "'+caseAnnexRecord.cx_ln_Requested_Duration_Months__c 
                        +'", "salaryPassCode": "'+caseAnnexRecord.Id+'", "loanMonthlyInstalment": "'+ caseAnnexRecord.cx_ln_Monthly_Instalment__c +'"}';
        request1.setBody(body1);

        HttpResponse esalaryResp;
        if ( !test.isRunningTest() ) {
            //fake response 
            esalaryResp = new HttpResponse();
            String body2 = '{    "meta": {        "code": "bcrb-1002",        "message": "Successfully retrieved eSalary Certificate."    },    "data": {        "employerName": "Raymond",        "occupation": "COMPUTER SYSTEMS ANALYST",        "lengthOfService": 9,        "otherDeductions": 60,        "totalDeductions": 28.10,        "basicSalary": 797,        "fixedAllowances": 140,        "variableAllowances": 1315.585,        "totalApprovedIncome": 937,        "isValid": true,        "errorMessage": "",        "businessIncome": 0,        "grossIncome": 2252.585,        "netIncome": 2224.485,        "finalDbr": 0    }}';
            esalaryResp.setStatus('OK');    
            esalaryResp.setStatusCode(200);
            esalaryResp.setBody(body2);
            esalaryResp.setHeader('Content-Type', 'application/json');
        }else{
            esalaryResp = http.send(request1);
        }
        
        return esalaryResp;
    }*/

    //will call only bcrb api
    @AuraEnabled
    public static Map<String, Object> reviewBcrbDetails (String caseId ,String caseAnnexId)
    {   
        Map<String, Object> result = new Map<String, Object>();
        try {
            Case caseRecord = [SELECT Id,Region_Flag__c,Case_Model__c,AccountId,Customer_CIF__c,Type FROM Case WHERE Id = :caseId];
            CaseAnnex__c caseAnnexRecord = [SELECT Id,cx_ln_Requested_Loan_Finance_Amount__c,cx_ln_Requested_Duration_Months__c,cx_ln_Monthly_Instalment__c,cx_ln_Approved_Loan_Amount__c,cx_ln_Approved_Duration_Months__c,cx_ln_Approved_Installment_Amount__c FROM CaseAnnex__c WHERE Id = :caseAnnexId];
            
            String regionName = caseRecord.Region_Flag__c ; 
            if ( caseRecord.Case_Model__c == 'alburaq' ) {
                regionName += '_alburaq';
            }
            HttpRequest request = con.createRequest('POST', '/api/v1/bcrb/inquiry',regionName);
            HttpResponse bcrbResp = callBcrbApi(request,caseRecord,caseAnnexRecord);
            
            //Always create system log    
            List<System_Action__c> lstSA = new List<System_Action__c>();
            lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),bcrbResp.getBody(),
                                                        request.getEndpoint(),request.getMethod(),
                                                        caseRecord.id,caseRecord.Customer_CIF__c,caseRecord.accountId,bcrbResp.getStatusCode(), 
                                                        'call bcrb API', caseRecord.Type
                                                    ));

            if(lstSA.size() > 0){
                insert lstSA;
            }

            if (bcrbResp.getStatusCode() != 200)
            {
                System.debug('The status code returned was not expected: ' + bcrbResp.getStatusCode() + ' ' + bcrbResp.getStatus());
                result.put('status', 'Error');
                result.put('message', 'Error occurred while processing: ' + bcrbResp.getStatusCode() + ' ' + bcrbResp.getStatus());
            }
            else
            {
                System.debug('bcrbp api bcrbResp.getBody() : ' + bcrbResp.getBody());
                result.put('status', 'Success');
                update new CaseAnnex__c(
                        Id=caseAnnexId, 
                        cx_ln_BCRB_Api_Response__c = bcrbResp.getBody()
                    );
            }
        } catch (Exception e) {
            result.put('status', 'Error');
            result.put('message', 'Error occurred while processing: ' + e.getMessage());
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }

        return result;
    }
    
    //fetch will call 2 apis : e-salary and bcrcb
    @AuraEnabled
    public static Map<String, Object> fetchBcrbDetails (String caseId ,String caseAnnexId)
    {   
        Map<String, Object> result = new Map<String, Object>();
        try {
            Case caseRecord = [SELECT Id,Region_Flag__c,Case_Model__c,AccountId,Customer_CIF__c,Type FROM Case WHERE Id = :caseId];
            CaseAnnex__c caseAnnexRecord = [SELECT Id,cx_ln_Requested_Loan_Finance_Amount__c,cx_ln_Requested_Duration_Months__c,cx_ln_Monthly_Instalment__c,cx_ln_Approved_Loan_Amount__c,cx_ln_Approved_Duration_Months__c,cx_ln_Approved_Installment_Amount__c FROM CaseAnnex__c WHERE Id = :caseAnnexId];
            
            String regionName = caseRecord.Region_Flag__c ; 
            if ( caseRecord.Case_Model__c == 'alburaq' ) {
                regionName += '_alburaq';
            }
            HttpRequest request = con.createRequest('POST', '/api/v1/bcrb/inquiry',regionName);
            HttpResponse bcrbResp = callBcrbApi(request,caseRecord,caseAnnexRecord);
            
            //Always create system log    
            List<System_Action__c> lstSA = new List<System_Action__c>();
            lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),bcrbResp.getBody(),
                                                        request.getEndpoint(),request.getMethod(),
                                                        caseRecord.id,caseRecord.Customer_CIF__c,caseRecord.accountId,bcrbResp.getStatusCode(), 
                                                        'call bcrb API', caseRecord.Type
                                                    ));

            if(lstSA.size() > 0){
                insert lstSA;
            }

            if (bcrbResp.getStatusCode() != 200)
            {
                System.debug('The status code returned was not expected: ' + bcrbResp.getStatusCode() + ' ' + bcrbResp.getStatus());
                result.put('status', 'Error');
                result.put('message', 'Error occurred while processing: ' + bcrbResp.getStatusCode() + ' ' + bcrbResp.getStatus());
            }
            else
            {
                System.debug('bcrbp api bcrbResp.getBody() : ' + bcrbResp.getBody());
                
                //call e-salary api ...
                //because "Income Details"&&"Income Deductions" sections only in unsecured senarios??
                    
                /*HttpResponse esalaryResp = callEsalaryApi(caseRecord,caseAnnexRecord);
                if (esalaryResp.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + esalaryResp.getStatusCode() + ' ' + esalaryResp.getStatus());
                    result.put('status', 'Error');
                    result.put('message', 'Error occurred while processing: ' + esalaryResp.getStatusCode() + ' ' + esalaryResp.getStatus());
                }
                else
                {
                    System.debug('E-salary api response.getBody() : ' + esalaryResp.getBody());
                    result.put('status', 'Success');
                    CaseAnnex__c cx = bcrbDetailsMapping(new CaseAnnex__c(Id=caseAnnexId),esalaryResp.getBody(),bcrbResp.getBody());
                    update cx;
                }*/
                result.put('status', 'Success');
                CaseAnnex__c cx = bcrbDetailsMapping(new CaseAnnex__c(Id=caseAnnexId),null,bcrbResp.getBody());
                update cx;
            }
        } catch (Exception e) {
            result.put('status', 'Error');
            result.put('message', 'Error occurred while processing: ' + e.getMessage());
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }

        return result;
    }

    public static CaseAnnex__c bcrbDetailsMapping(CaseAnnex__c cx, String esalaryData, String bcrbData){
        //toDo check also mapping in "CRB Review Details :" section in lwc03.js
        //Construct e-salary api response : //ne need any more
            /*Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(esalaryData);
            Map<String, Object> esalaryResp = (Map<String, Object>)m.get('data');
            cx.cx_ln_Basic_Salary__c = (esalaryResp.get('basicSalary')!= null && esalaryResp.get('basicSalary') != '') ? Decimal.valueOf(String.valueOf(esalaryResp.get('basicSalary'))) : null;
            cx.cx_ln_Fixed_Allowances__c = (esalaryResp.get('fixedAllowances')!= null && esalaryResp.get('fixedAllowances') != '') ? Decimal.valueOf(String.valueOf(esalaryResp.get('fixedAllowances'))) : null;
            cx.cx_ln_Variable_Allowances__c = (esalaryResp.get('variableAllowances')!= null && esalaryResp.get('variableAllowances') != '') ? Decimal.valueOf(String.valueOf(esalaryResp.get('variableAllowances'))) : null;
            cx.cx_ln_Business_Income__c = (esalaryResp.get('businessIncome')!= null && esalaryResp.get('businessIncome') != '') ? Decimal.valueOf(String.valueOf(esalaryResp.get('businessIncome'))) : null;
            cx.cx_ln_Total_Approved_Income__c = (esalaryResp.get('totalApprovedIncome')!= null && esalaryResp.get('totalApprovedIncome') != '') ? Decimal.valueOf(String.valueOf(esalaryResp.get('totalApprovedIncome'))) : null;
            cx.cx_ln_Gross_Income__c = (esalaryResp.get('grossIncome')!= null && esalaryResp.get('grossIncome') != '') ? Decimal.valueOf(String.valueOf(esalaryResp.get('grossIncome'))) : null;
            cx.cx_ln_Net_Income__c = (esalaryResp.get('netIncome')!= null && esalaryResp.get('netIncome') != '') ? Decimal.valueOf(String.valueOf(esalaryResp.get('netIncome'))) : null;
            cx.cx_ln_Other_Deductions__c = (esalaryResp.get('otherDeductions')!= null && esalaryResp.get('otherDeductions') != '') ? Decimal.valueOf(String.valueOf(esalaryResp.get('otherDeductions'))) : null;
            cx.cx_ln_Total_Deductions__c = (esalaryResp.get('totalDeductions')!= null && esalaryResp.get('totalDeductions') != '') ? Decimal.valueOf(String.valueOf(esalaryResp.get('totalDeductions'))) : null;
            */

        //Construct Bcrb api response :
        cx.cx_ln_BCRB_Api_Response__c = bcrbData;
        Map<String, Object> m1 = (Map<String, Object>)JSON.deserializeUntyped(bcrbData);
        Map<String, Object> bcrbResp = (Map<String, Object>)m1.get('data');
        cx.cx_ln_TotalCurrentObligations__c = (bcrbResp.get('totalCurrentObligations')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('totalCurrentObligations'))) : 0;
        cx.cx_ln_TotalConsumerLoansInstallments__c = (bcrbResp.get('totalConsumerLoans')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('totalConsumerLoans'))) : 0;
        cx.cx_ln_TotalMortgageLoansInstallments__c = (bcrbResp.get('totalMortgageLoans')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('totalMortgageLoans'))) : 0;
        cx.cx_ln_TotalCreditCardsInstallments__c = (bcrbResp.get('totalCreditCardInstallments')!= null && bcrbResp.get('totalCreditCardInstallments') != '') ? Decimal.valueOf(String.valueOf(bcrbResp.get('totalCreditCardInstallments'))) : 0;
        cx.cx_ln_Total_CCs_Installments_without_ila__c = (bcrbResp.get('totalIlaCreditCardInstallmentsWithoutIla')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('totalIlaCreditCardInstallmentsWithoutIla'))) : 0;
        cx.cx_ln_Total_IlaCreditCardsInstallments__c = (bcrbResp.get('totalIlaCreditCardInstallments')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('totalIlaCreditCardInstallments'))) : 0;
        cx.cx_ln_TotalGovernmentLoansInstallments__c = (bcrbResp.get('totalGovernmentLoans')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('totalGovernmentLoans'))) : 0;
        cx.cx_ln_TotalOverdraftInstallments__c = (bcrbResp.get('totalOverdraftInstallments')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('totalOverdraftInstallments'))) : 0;
        cx.cx_ln_TotalLeverageLoanInstallments__c = (bcrbResp.get('totalLeverageLoanInstallments')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('totalLeverageLoanInstallments'))) : 0;
        cx.cx_ln_TotalBuyNowPayLaterInstallments__c = (bcrbResp.get('totalBuyNowPayLaterInstallments')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('totalBuyNowPayLaterInstallments'))) : 0;
        cx.cx_ln_CurrentLoansLimit__c = (bcrbResp.get('currentLoansLimit')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('currentLoansLimit'))) : 0;
        //using formula field instead ..
        //cx.cx_ln_Total_Obligations__c = (bcrbResp.get('totalIObligations')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('totalIObligations'))) : 0;
        
        cx.cx_ln_No_of_Corporate_Accounts__c = (bcrbResp.get('numberOfCorporateAccounts')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('numberOfCorporateAccounts'))) : 0;
        cx.cx_ln_No_of_Non_Owner_Accounts__c = (bcrbResp.get('numberOfNonOwnerAccounts')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('numberOfNonOwnerAccounts'))) : 0;
        cx.cx_ln_No_of_non_normal_accounts__c = (bcrbResp.get('numberOfNonNormalAccounts')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('numberOfNonNormalAccounts'))) : 0;
        cx.cx_ln_No_of_Credit_Cards_without_Ila__c = (bcrbResp.get('numberOfCreditCardsWithoutIla')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('numberOfCreditCardsWithoutIla'))) : 0;
        cx.cx_ln_No_of_Ila_Credit_Cards__c = (bcrbResp.get('numberOfIlaCreditCards')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('numberOfIlaCreditCards'))) : 0;
        cx.cx_ln_NoPenaltiesContraventions_accounts__c = (bcrbResp.get('totalOfPenaltiesAndContraventionAccounts')!= null ) ? Decimal.valueOf(String.valueOf(bcrbResp.get('totalOfPenaltiesAndContraventionAccounts'))) : 0;
        cx.cx_ln_No_of_Billing_Accounts__c = (bcrbResp.get('numberOfBillingAccounts')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('numberOfBillingAccounts'))) : 0;
        cx.cx_ln_Total_no_of_Loans__c = (bcrbResp.get('totalNumberOfLoans')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('totalNumberOfLoans'))) : 0;
        cx.cx_ln_No_of_Arrears_with_gov_loans__c = (bcrbResp.get('numberOfArrearsWithGovLoans') != null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('numberOfArrearsWithGovLoans'))) : 0;
        cx.cx_ln_No_of_Arrears_without_gov_loans__c = (bcrbResp.get('numberOfArrearsWithoutGovLoans')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('numberOfArrearsWithoutGovLoans'))) : 0;
        
        cx.cx_ln_Current_Customer_Status__c = (bcrbResp.get('currentCustomerStatus')!= null) ? String.valueOf(bcrbResp.get('currentCustomerStatus')) : null;

        cx.cx_ln_Total_Credit_Exposure__c = (bcrbResp.get('totalCreditExposure')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('totalCreditExposure'))) : 0;
        cx.cx_ln_Credit_Bureau_Score__c = (bcrbResp.get('creditBureauScore')!= null) ? Decimal.valueOf(String.valueOf(bcrbResp.get('creditBureauScore'))) : 0;
        cx.cx_ln_Credit_Bureau_Risk_Rating__c = (bcrbResp.get('creditBureauRiskRating')!= null) ? (String)bcrbResp.get('creditBureauRiskRating') : null;
        //toDo : creditBureauRiskRating not existing on the response
        cx.cx_ln_Current_PSI_Transaction_No__c = (bcrbResp.get('transactionNo')!= null && String.valueOf(bcrbResp.get('transactionNo')) != '' && String.valueOf(bcrbResp.get('transactionNo')) != 'null' ) ? String.valueOf(bcrbResp.get('transactionNo')) : null;
        cx.cx_ln_Current_PSI_Expiry_Date__c = (bcrbResp.get('currentPSIExpiryDate')!= null) ? Date.valueOf(String.valueOf(bcrbResp.get('currentPSIExpiryDate'))) : null;
        return cx;
    }

    @AuraEnabled
    public static Map<String, Object> generateRepaymentSchedule (String caseId ,String caseAnnexId)
    {   
        Map<String, Object> result = new Map<String, Object>();
        try {
            Case caseRecord = [SELECT Id,Region_Flag__c,Case_Model__c,AccountId,Customer_CIF__c,Type, caseNumber, cc_Whitelisted_Employer__c, cc_Employer_Grade__c, cc_Employment_Status__c, cc_Nationality__c  FROM Case WHERE Id = :caseId];
            CaseAnnex__c caseAnnexRecord = [SELECT Id,cx_ln_Requested_Loan_Finance_Amount__c,cx_ln_Requested_Duration_Months__c,cx_ln_Monthly_Instalment__c,cx_ln_Approved_Loan_Amount__c,cx_ln_ApprovedInterestProfitRateReducing__c,cx_ln_Requested_Processing_Fees__c,cx_ln_Approved_Buyout_Amount__c,cx_ln_TotalLiabilitiesAmount__c,
                                                    cx_ln_Approved_Installment_Amount__c,cx_ln_Approved_PreInsuranceStatus__c,cx_ln_Approved_Insurance_Premium__c,cx_ln_Approved_Duration_Months__c,cx_ln_Approved_Cash_in_Hand__c,cx_ln_Approved_insurance__c,cx_ln_APR__c,cx_ln_ApprovedProcessing_Fee_Type__c,cx_ln_Requested_Vat_Processing_Fees__c,cx_ln_Approved_First_installment_date__c,cx_ln_Approved_Maturity_Date__c,
                                                    cx_ln_Product__c
                                            FROM CaseAnnex__c WHERE Id = :caseAnnexId];
            HttpRequest request22 = prepareSimulationRequest(caseRecord,caseAnnexRecord);
            HttpResponse simulationResp = callSimulationApi(caseRecord,caseAnnexRecord,request22,true);

            if (simulationResp.getStatusCode() != 200)
            { 
                System.debug('The status code returned was not expected: ' + simulationResp.getStatusCode() + ' ' + simulationResp.getStatus());
                result.put('status', 'Error');
                //result.put('message', 'Error occurred while processing: ' + simulationResp.getStatusCode() + ' ' + simulationResp.getStatus());
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
                caseAnnexRecord.cx_ln_core_product_name__c = (String)scheduleResp.get('transactProductName');

                //using this flag to say that the schedule is generated 
                //caseAnnexRecord.cx_ln_isScheduleGenerated__c = true;
                update caseAnnexRecord;
            }
        } catch (Exception e) {
            
            result.put('status', 'Error');
            result.put('message', 'Error occurred while processing: ' + e.getMessage());
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }

        return result;
    }

    @AuraEnabled
    public static Loans_ServiceManagerHandler.APIResponse getSimulationPaymentList(Id caseId, Id caseAnnexId) {
        System.debug('caseId getSimulationPaymentList ' +caseId );
        
        Loans_ServiceManagerHandler.APIResponse response = Loans_LoansListController.getSimulationPaymentList(caseId, null,true);
        if (response.isSuccess == true && response.headerData != null) {
            CaseAnnex__c caseAnnexRecord = new CaseAnnex__c(Id=caseAnnexId);
            Map<String, Object> scheduleRespHeader = (Map<String, Object>)response.headerData;
            caseAnnexRecord.cx_ln_Approved_Installment_Amount__c = (Decimal)scheduleRespHeader.get('monthlyInstallment');
            caseAnnexRecord.cx_ln_Approved_Insurance_Amount__c = (Decimal)scheduleRespHeader.get('insuranceAmount');
            caseAnnexRecord.cx_ln_APR__c = (Decimal)scheduleRespHeader.get('apr');
            caseAnnexRecord.cx_ln_Approved_Insurance_Rate__c = (Decimal)scheduleRespHeader.get('lifeInsuranceRate');
            caseAnnexRecord.cx_ln_Approved_Maturity_Date__c = Date.valueOf(String.valueOf(scheduleRespHeader.get('maturityDate'))) ;
            //using this flag to say that the schedule is generated 
            caseAnnexRecord.cx_ln_isScheduleGenerated__c = true;
            update caseAnnexRecord;
        }

        System.debug('Response getSimulationPaymentList object:'+response);

        return response;
    }

    public static HttpResponse callSimulationApi (Case caseRecord ,CaseAnnex__c caseAnnexRecord,HttpRequest request,Boolean saveLog)
    {    
        Http http = new Http();
        HttpResponse simulationResp;
        if ( test.isRunningTest() ) {
            //fake simulationResp 
            simulationResp = new HttpResponse();
            String body1 = '{"meta": {"code": "LOAN-1003","message": "Successfully created loan application."},"data": {"simulationReference": "AASIM251826SFNMSJL"}}';
            simulationResp.setStatus('OK');    
            simulationResp.setStatusCode(200);
            simulationResp.setBody(body1);
            simulationResp.setHeader('Content-Type', 'application/json');
        }else{
            simulationResp = http.send(request);
        }

        if(saveLog == true){
            List<System_Action__c> lstSA = new List<System_Action__c>();
            //Always create system log    
            lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),simulationResp.getBody(),
                                                        request.getEndpoint(),request.getMethod(),
                                                        caseRecord.id,caseRecord.Customer_CIF__c,caseRecord.accountId,simulationResp.getStatusCode(), 
                                                        'call simulation schedule API', caseRecord.Type
                                                    ));
    
            if(lstSA.size() > 0){
                insert lstSA;
            }
        }
        
        return simulationResp;
    }

    public static HttpRequest prepareSimulationRequest (Case caseRecord ,CaseAnnex__c caseAnnexRecord)
    {    
        String regionName = caseRecord.Region_Flag__c ; 
        String customerId = caseRecord.Customer_CIF__c;
        if ( caseRecord.Case_Model__c == 'alburaq' ) {
            regionName += '_alburaq';
        }
        
        HttpRequest request = con.createRequest('POST', '/api/v1/loans/simulation',regionName); 
        request.setTimeout(60000);
        if(customerId != null && customerId != ''){
            request.setHeader('customerId', customerId);
        }
        Decimal approvedInsuranceAmount;
        if(caseAnnexRecord.cx_ln_Approved_PreInsuranceStatus__c == 'Approved'){
            approvedInsuranceAmount = 0;
        }
        else if(caseAnnexRecord.cx_ln_Product__c == 'Secured'){
            approvedInsuranceAmount = 0;
        }
        //toDo : check this request body with shameer 
        //toDo : param "approvedBuyoutAmount" //to be confirmed with Gabeer 
        // String body ='{ "approvedAmount": '+ caseAnnexRecord.cx_ln_Approved_Loan_Amount__c +
        //                 ', "approvedTenor": '+ caseAnnexRecord.cx_ln_Approved_Duration_Months__c +
        //                 ', "approvedInterestRate": '+caseAnnexRecord.cx_ln_ApprovedInterestProfitRateReducing__c+
        //                 ', "approvedInsuranceType": '+ stringApiFormat(caseAnnexRecord.cx_ln_Approved_Insurance_Premium__c) +
        //                 ', "approvedInsuranceAmount": '+ approvedInsuranceAmount  +
        //                 ', "approvedProcessingFeeType": '+ stringApiFormat(caseAnnexRecord.cx_ln_ApprovedProcessing_Fee_Type__c) +
        //                 ', "approvedCashInHand": '+ caseAnnexRecord.cx_ln_Approved_Cash_in_Hand__c +
        //                 ', "approvedPreExistingInsurance": '+ caseAnnexRecord.cx_ln_Approved_insurance__c +
        //                 ', "approvedFirstPaymentDate": '+ stringApiFormat(dateToApiDateFormat(caseAnnexRecord.cx_ln_Approved_First_installment_date__c)) +
        //                 ', "crmCaseId": "'+ caseRecord.Id +
        //              '"}';

        String body ='{ "approvedAmount": '+ caseAnnexRecord.cx_ln_Approved_Loan_Amount__c +
                        ', "approvedTenor": '+ caseAnnexRecord.cx_ln_Approved_Duration_Months__c +
                        ', "approvedInterestRate": '+caseAnnexRecord.cx_ln_ApprovedInterestProfitRateReducing__c+
                        //', "approvedMonthlyInstallment": '+caseAnnexRecord.cx_ln_Approved_Installment_Amount__c+//toDo : no need to send this from crm ?? it's all the time readonly 
                        ', "approvedInsuranceType": '+ stringApiFormat(caseAnnexRecord.cx_ln_Approved_Insurance_Premium__c) +
                        ', "approvedInsuranceAmount": '+ approvedInsuranceAmount  +
                        ', "approvedProcessingFeeType": '+ stringApiFormat(caseAnnexRecord.cx_ln_ApprovedProcessing_Fee_Type__c) +
                        ', "approvedCashInHand": '+ caseAnnexRecord.cx_ln_Approved_Cash_in_Hand__c +
                        ', "approvedPreExistingInsurance": '+ caseAnnexRecord.cx_ln_Approved_insurance__c +
                        ', "approvedFirstPaymentDate": '+ stringApiFormat(dateToApiDateFormat(caseAnnexRecord.cx_ln_Approved_First_installment_date__c)) +
                        ', "approvedCurrency": "BHD"'+ 
                        ', "crmCaseId": '+ stringApiFormat(caseRecord.Id) +
                        ', "crmCaseNo": '+ stringApiFormat(caseRecord.caseNumber) +
                        //', "approvedApr": '+ caseAnnexRecord.cx_ln_APR__c + //todo :not having this ...
                        ', "approvedFee": '+ caseAnnexRecord.cx_ln_Requested_Processing_Fees__c +
                        ', "approvedVat": '+ caseAnnexRecord.cx_ln_Requested_Vat_Processing_Fees__c +
                        //', "approvedMaturityDate": '+ stringApiFormat(dateToApiDateFormat(caseAnnexRecord.cx_ln_Approved_Maturity_Date__c)) +//todo : not having this ...
                        //', "transactProduct": null'+//todo : not having this ...
                        ', "approvedBuyoutAmount":'+ caseAnnexRecord.cx_ln_TotalLiabilitiesAmount__c+
                        ', "nationality": '+ stringApiFormat(caseRecord.cc_Nationality__c) +
                        ', "approvedEmploymentStatus": '+ stringApiFormat(caseRecord.cc_Employment_Status__c) +
                        ', "approvedWhitelistedEmployer": '+  caseRecord.cc_Whitelisted_Employer__c +
                        ', "approvedEmployerGrade": '+ stringApiFormat(caseRecord.cc_Employer_Grade__c)+
                       
                    '}';
                    //   if(caseAnnexRecord.cx_ln_Product__c == 'Unsecured') {
                    //         body += ', "nationality": '+ stringApiFormat(caseRecord.cc_Nationality__c) +
                    //                 ', "approvedEmploymentStatus": '+ stringApiFormat(caseRecord.cc_Employment_Status__c) +
                    //                 ', "approvedWhitelistedEmployer": '+  caseRecord.cc_Whitelisted_Employer__c +
                    //                 ', "approvedEmployerGrade": '+ stringApiFormat(caseRecord.cc_Employer_Grade__c);
                    //     }
    
                    //       body += '}';
        System.debug('Request Body Mapping :' + body);
        request.setBody(body);
        
        return request;
    }

    public static String dateToApiDateFormat(Date input){
        if(input != null){
            Datetime output = input;
            return output.format('yyyy-MM-dd');
        }else{
            return null;
        }
    }
    public static String stringApiFormat(String input){
        if(input != null){
            return '"'+ input +'"';
        }else{
            return 'null';
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCaseFieldsMap(Id recordId) {
        // System.debug('recordId >> ' + recordId);
        
        if (recordId == null) {
            throw new AuraHandledException('Record Id cannot be null.');
        }

        try {
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Case.fields.getMap();
            List<String> fieldNames = new List<String>();
            for (String fieldName : fieldMap.keySet()) {
                fieldNames.add(fieldName);
            }
            String soqlQuery = 'SELECT ' + String.join(fieldNames, ', ') + ' FROM Case WHERE Id = :recordId LIMIT 1';
            // System.debug('SOQL Query: ' + soqlQuery);

            Case caseRecord = Database.query(soqlQuery);

            Map<String, Object> result = new Map<String, Object>();
            for (String fieldName : fieldMap.keySet()) {
                Object fieldValue = caseRecord.get(fieldName);
                result.put(fieldName, caseRecord.get(fieldName));
            }
            return result;
        } catch (Exception e) {
            System.debug('Exception in getCaseFields: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while fetching Case fields.');
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getCaseAnnexFieldsMap(Id recordId) {
        if (recordId == null) {
            throw new AuraHandledException('Record Id cannot be null.');
        }

        try {
            List<Map<String, Object>> results = new List<Map<String, Object>>();
            String query = 'SELECT ';
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.CaseAnnex__c.fields.getMap();
            // System.debug('fieldMap :: ' + fieldMap);

            for (String fieldName : fieldMap.keySet()) {
                query += fieldName + ', ';
            }

            query = query.substring(0, query.length() - 2);
            query += ' FROM CaseAnnex__c WHERE Case__c = :recordId LIMIT 1';

            List<CaseAnnex__c> caseAnnexRecords = Database.query(query);

            for (CaseAnnex__c record : caseAnnexRecords) {
                Map<String, Object> recordMap = new Map<String, Object>();
                for (String fieldName : fieldMap.keySet()) {
                    recordMap.put(fieldName, record.get(fieldName));
                }
                results.add(recordMap);
            }
            // System.debug('results :: ' + results);
            return results;
        } catch (Exception e) {
            System.debug('Exception in getCaseAnnexFields: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while fetching Case Annex fields.');
        }
    }
    @AuraEnabled
    public static void updateCaseAnnexRecord(Id recordAnnexId,String cx_ln_Requested_Liabilities,Decimal cx_ln_TotalLiabilitiesAmount,Decimal cx_ln_TotalLiabilityMonthlyInstallAmount ) {
        CaseAnnex__c cs = new CaseAnnex__c(Id = recordAnnexId, cx_ln_Requested_Liabilities__c = cx_ln_Requested_Liabilities,cx_ln_TotalLiabilitiesAmount__c = cx_ln_TotalLiabilitiesAmount,cx_ln_TotalLiabilityMonthlyInstallAmount__c = cx_ln_TotalLiabilityMonthlyInstallAmount ); 
        //NBA-15983 change 1
        cs.cx_ln_APR__c = null;
        update cs;
    }
}