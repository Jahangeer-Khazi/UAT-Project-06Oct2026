/**
 * @author Aniss Mbarki
 * @date Création 29/11/2024
 * @date Modification
 * @description : 
 */
public without sharing class LTNG056_LoansCalculatorController {

    private static String CLASS_NAME = LTNG056_LoansCalculatorController.class.getName();
    private static ApiConnection con = new ApiConnection();
    
    @AuraEnabled
    public static Map<String, Object> calculatorApiCall (Map<String,Object> param)
    {   
        System.debug('param>>>>>'+param);
        Map<String, Object> result = new Map<String, Object>();

        try {
            // Extract values from the Map parameter
            String segment = (String)param.get('segment');
            String regionName = (String)param.get('regionName');
            String nationality = (String)param.get('nationality');
            String customerId = (String)param.get('customerId');
            String loanType = (String)param.get('loanType');
            String subscription = (String)param.get('subscription');
            String calculationMethod = (String)param.get('calculationMethod');
            Decimal LoanAmount = (param.containsKey('LoanAmount') && String.isNotEmpty((String)param.get('LoanAmount')))?Decimal.valueOf((String)param.get('LoanAmount')):0;
            Decimal LoanDuration = (param.containsKey('LoanDuration') && String.isNotEmpty((String)param.get('LoanDuration')))?Decimal.valueOf((String)param.get('LoanDuration')):0;
            Decimal InstallmentAmount = (param.containsKey('InstallmentAmount') && String.isNotEmpty((String)param.get('InstallmentAmount')))? Decimal.valueOf((String)param.get('InstallmentAmount')): 0;
            Decimal ExistingLoans = (param.containsKey('ExistingLoans') && String.isNotEmpty((String)param.get('ExistingLoans')))? Decimal.valueOf((String)param.get('ExistingLoans')): 0;
            Decimal loanCoefficientTotalRepayment = Decimal.valueof(System.Label.Loan_CoefficientTotalRepayment);

            result = checkCalculatorApiParams(param);
            System.debug('response==>test'+(String)result.get('status'));
            if( (String)result.get('status') == 'Success'){
                System.debug('response==>test'+(String)result.get('response'));
                String bodyTxt = (String)result.get('response');
                System.debug('response.getBody() : ' + bodyTxt);
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(bodyTxt);
                Map<String, Object> m0 = (Map<String, Object>)m.get('data');

                Map<String, Object> configurationsMap = (Map<String, Object>)((List<Object>)m0.get('configurations')).get(0);
                Decimal interestRate = (Decimal)(configurationsMap.get('interestRate'));
                result.put('interestRate', interestRate);
                Decimal ProcessingFee = (Decimal)(configurationsMap.get('processingFee'));
                result.put('processingFee', ProcessingFee);
                Decimal VATProcessingFee = (Decimal)(configurationsMap.get('vatProcessingFee'));
                result.put('vatProcessingFee', VATProcessingFee);

                // Insurance Amount ?? is it hold amount??
                // keep displaying "Total Cash InHand" ??
                
                String firstPaymentDateStr = (String)(configurationsMap.get('firstPaymentDate'));
                result.put('firstPaymentDate', firstPaymentDateStr);
                
                //Start - calculte "Maturity Date" ==> returned (First Payment date + Loan Duration in month)
                // Parse the date string to Date object (assuming format is 'yyyy-MM-dd')
                Date firstPaymentDate = Date.valueOf(firstPaymentDateStr);
                // Add months
                Date maturityDateObj = firstPaymentDate.addMonths(loanDuration.intValue()-1);// Add n-1 months // because of US UATNB-175258
                // Convert Date to Datetime (midnight of that day)
                Datetime maturityDateTime = Datetime.newInstance(maturityDateObj.year(), maturityDateObj.month(), maturityDateObj.day());
                // Format as string
                String maturityDateStr = maturityDateTime.format('yyyy-MM-dd');

                result.put('maturityDate', maturityDateStr);
                //End - calculte "Maturity Date"

                if( calculationMethod == 'BY_LOAN_AMOUNT' ){
                    //all good let's do the calculation : ...
                    Decimal MonthlyInterestRate = ( interestRate /(12 * 100) );
                    Decimal NumberOfMonths = LoanDuration;
                    System.debug('LoanAmount##'+LoanAmount);
                    System.debug('MonthlyInterestRate##'+MonthlyInterestRate);
                    System.debug('NumberOfMonths##'+NumberOfMonths);
                    System.debug('ProcessingFee##'+ProcessingFee);
                     System.debug('VATProcessingFee##'+VATProcessingFee);
                    // Start Calculate the monthly installment
                    Decimal monthlyInstallment = LoanAmount * (MonthlyInterestRate * Math.pow(1 + MonthlyInterestRate.doubleValue(), NumberOfMonths.doubleValue())) / (Math.pow(1 + MonthlyInterestRate.doubleValue(), NumberOfMonths.doubleValue()) - 1);
                    //monthlyInstallment = monthlyInstallment.setScale(3, RoundingMode.HALF_UP);
                    System.debug('Monthly Installment: ' + monthlyInstallment.setScale(3, RoundingMode.HALF_UP));
                    result.put('monthlyInstallment', monthlyInstallment.setScale(3, RoundingMode.HALF_UP));
                    // End Calculate the monthly installment

                    Decimal totalRepayment = monthlyInstallment * NumberOfMonths;
                    
                    // Start Calculate the totalRepayment
                    totalRepayment = totalRepayment.setScale(3, RoundingMode.HALF_UP);
                    System.debug('totalRepayment: ' + totalRepayment);
                    result.put('totalRepayment', totalRepayment);
                    // End Calculate totalRepayment

                    // Start Calculate totalInterest
                    Decimal totalInterest = (monthlyInstallment * NumberOfMonths) - LoanAmount;
                    System.debug('total Interest: ' + totalInterest);
                    result.put('totalInterest', totalInterest.setScale(3, RoundingMode.HALF_UP));
                    // End Calculate totalInterest


                    // Start Calculate the totalCashInHand
                    Decimal totalCashInHand = LoanAmount - ExistingLoans;
                    System.debug('totalCashInHand: ' + totalCashInHand);
                    result.put('totalCashInHand', totalCashInHand.setScale(3, RoundingMode.HALF_UP));
                    // End Calculate totalCashInHand
                    
                    // Start Calculate the holdAmount
                    Decimal holdAmount = (totalRepayment) * loanCoefficientTotalRepayment;
                    System.debug('holdAmount: ' + holdAmount);
                    result.put('holdAmount', holdAmount.setScale(3, RoundingMode.HALF_UP));
                    // End Calculate holdAmount

                }else if( calculationMethod == 'BY_MONTHLY_INSTALLMENT' ){
                    //all good let's do the calculation : ...

                    Decimal MonthlyInstallment = InstallmentAmount;
                    System.debug('MonthlyInstallment: ' + MonthlyInstallment);
                    Decimal MonthlyInterestRate = ( interestRate /(12 * 100) );
                    System.debug('MonthlyInterestRate: ' + MonthlyInterestRate);
                    Decimal NumberOfMonths = LoanDuration;

                    // Start Calculate loanAmount
                    Decimal loanAmountDecimal = MonthlyInstallment * (Math.pow(1 + MonthlyInterestRate.doubleValue(), NumberOfMonths.doubleValue()) - 1) /
                                                (MonthlyInterestRate * Math.pow(1 + MonthlyInterestRate.doubleValue(), NumberOfMonths.doubleValue()));

                    loanAmountDecimal = loanAmountDecimal.setScale(3, RoundingMode.HALF_UP);
                    System.debug('loanAmount: ' + loanAmountDecimal);
                    result.put('loanAmount', loanAmountDecimal);
                    // End Calculate loanAmount

                    // Start Calculate the totalRepayment
                    Decimal totalRepayment = MonthlyInstallment * NumberOfMonths;
                    totalRepayment = totalRepayment.setScale(3, RoundingMode.HALF_UP);
                    System.debug('totalRepayment: ' + totalRepayment);
                    result.put('totalRepayment', totalRepayment);
                    // End Calculate totalRepayment

                    // Start Calculate totalInterest
                    Decimal totalInterest = (MonthlyInstallment * NumberOfMonths) - loanAmountDecimal ;
                    System.debug('total Interest: ' + totalInterest);
                    result.put('totalInterest', totalInterest.setScale(3, RoundingMode.HALF_UP));
                    // End Calculate totalInterest

                    // Start Calculate the totalCashInHand
                    Decimal totalCashInHand = loanAmountDecimal - ExistingLoans;
                    System.debug('totalCashInHand: ' + totalCashInHand);
                    result.put('totalCashInHand', totalCashInHand.setScale(3, RoundingMode.HALF_UP));
                    // End Calculate totalCashInHand
                    
                    // Start Calculate the holdAmount
                    Decimal holdAmount = (totalRepayment) * loanCoefficientTotalRepayment;
                    System.debug('holdAmount: ' + holdAmount);
                    result.put('holdAmount', holdAmount.setScale(3, RoundingMode.HALF_UP));
                    // End Calculate holdAmount
                }
            }
            
        } catch (Exception e) {
            result.put('status', 'Error');
            result.put('message', 'Error occurred while processing: ' + e.getMessage());
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }

        // Return the result map (can include more data if needed)
        return result;
    }
    
    @AuraEnabled
    public static Map<String, Object> checkCalculatorApiParams (Map<String,Object> param)
    {   
        System.debug('param>>>>>'+param);
        Map<String, Object> result = new Map<String, Object>();
        try {
            // Extract values from the Map parameter
            String segment = (String)param.get('segment');
            String regionName = (String)param.get('regionName');
            String nationality = (String)param.get('nationality');
            String customerId = (String)param.get('customerId');
            String loanType = (String)param.get('loanType');
            String subscription = (String)param.get('subscription');
            String calculationMethod = (String)param.get('calculationMethod');
            
            if (subscription == 'alburaq') {
                regionName += '_alburaq';
            }
            
            Http http = new Http();
            HttpRequest request = con.createRequest('GET', '/api/v1/loans/calculator-matrix?loanType='+loanType+'&segment='+segment+'&nationality='+nationality,regionName); 
            request.setTimeout(60000);
            if(customerId != null && customerId != ''){
                request.setHeader('customerId', customerId);
            }
            HttpResponse response;
            if ( test.isRunningTest() ) {
                //fake response 
                response = new HttpResponse();
                String body1 = '{"meta":{"code":"LOAN-1002","message":"Successfullyretrievedloancalculatormatrix."},"data":{"configurations":[{"tier":"1-1200000","minimumLoanAmount":1000,"maximumLoanAmount":100000,"interestRate":40,"processingFee":100,"firstPaymentDate":"2025-05-28","vatProcessingFee":10.0}],"equations":{"DEFAULT":{"order":["monthlyInstallment","totalRepayment","totalCashInHand","totalInterest","holdAmount"],"loanAmount":"(((GrossIncome/2)-CreditCardsMinimumDue)*((((1+MonthlyInterestRate)^NumberOfMonths)-1)/(MonthlyInterestRate*((1+MonthlyInterestRate)^NumberOfMonths))))","totalRepayment":"((GrossIncome/2)-CreditCardsMinimumDue)*NumberOfMonths","totalCashInHand":"LoanAmount-ExistingLoans","monthlyInstallment":"TotalRepayment/NumberOfMonths","totalInterest":"TotalRepayment-LoanAmount","holdAmount":"TotalRepayment+ProcessingFee+VATProcessingFee"},"BY_LOAN_AMOUNT":{"order":["monthlyInstallment","totalRepayment","totalCashInHand","totalInterest","holdAmount"],"totalRepayment":"MonthlyInstallment * NumberOfMonths","totalCashInHand":"LoanAmount - ExistingLoans","monthlyInstallment":"LoanAmount * (MonthlyInterestRate * (1 + MonthlyInterestRate)^NumberOfMonths) / (((1 + MonthlyInterestRate)^NumberOfMonths) - 1)","totalInterest":"(MonthlyInstallment * NumberOfMonths) - LoanAmount","holdAmount":"TotalRepayment * 1"},"BY_MONTHLY_INSTALLMENT":{"order":["monthlyInstallment","totalRepayment","totalCashInHand","totalInterest","holdAmount"],"loanAmount":"MonthlyInstallment * ((1 + MonthlyInterestRate)^NumberOfMonths - 1) / (MonthlyInterestRate * (1 + MonthlyInterestRate)^NumberOfMonths)","totalRepayment":"MonthlyInstallment * NumberOfMonths","totalCashInHand":"LoanAmount - ExistingLoans","monthlyInstallment":"","totalInterest":"(MonthlyInstallment * NumberOfMonths) - LoanAmount","holdAmount":"TotalRepayment * 1"}}}}';
                response.setStatus('Success');    
                response.setStatusCode(200);
                response.setBody(body1);
                response.setHeader('Content-Type', 'application/json');
            }else{
                response = http.send(request);
            }

            if (response.getStatusCode() != 200)
            {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                result.put('status', 'Error');
                result.put('message', 'Error occurred while processing: ' + response.getStatusCode() + ' ' + response.getStatus());
            }
            else
            {
                System.debug('response.getBody() : ' + response.getBody());
                
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                Map<String, Object> m0 = (Map<String, Object>)m.get('data');
                Map<String, Object> configurationsMap = (Map<String, Object>)((List<Object>)m0.get('configurations')).get(0);
                Map<String, Object> equationsMap = (Map<String, Object>)m0.get('equations');

                LoanCalculator__mdt loanCalculatorConfigCRM = [SELECT Id,DeveloperName,EquationHoldAmount__c,EquationLoanAmount__c,EquationMonthlyInstallment__c,EquationTotalCashInHand__c,EquationTotalInterest__c,EquationTotalRepayment__c FROM LoanCalculator__mdt WHERE DeveloperName =: calculationMethod LIMIT 1];
                System.debug('calculationMethod: ' + calculationMethod);
                String errMsg = '';
                if( calculationMethod == 'BY_LOAN_AMOUNT' ){
                    Map<String, Object> BY_LOAN_AMOUNT_Map = (Map<String, Object>)equationsMap.get('BY_LOAN_AMOUNT');
                    if( String.valueOf(BY_LOAN_AMOUNT_Map.get('totalRepayment')).trim() != loanCalculatorConfigCRM.EquationTotalRepayment__c.trim() ){
                        System.debug('totalRepayment--->> '+String.valueOf(BY_LOAN_AMOUNT_Map.get('totalRepayment')));
                        errMsg += ' Total Repayment;';
                    }
                    if( String.valueOf(BY_LOAN_AMOUNT_Map.get('totalCashInHand')).trim() != loanCalculatorConfigCRM.EquationTotalCashInHand__c.trim() ){
                        System.debug('totalCashInHand--->> '+String.valueOf(BY_LOAN_AMOUNT_Map.get('totalCashInHand')));
                        errMsg += ' Total CashInHand;';
                    }
                    if( String.valueOf(BY_LOAN_AMOUNT_Map.get('monthlyInstallment')).trim() != loanCalculatorConfigCRM.EquationMonthlyInstallment__c.trim() ){
                        System.debug('monthlyInstallment--->> '+String.valueOf(BY_LOAN_AMOUNT_Map.get('monthlyInstallment')));
                        errMsg += ' Monthly Installment;';
                    }
                    if( String.valueOf(BY_LOAN_AMOUNT_Map.get('totalInterest')).trim() != loanCalculatorConfigCRM.EquationTotalInterest__c.trim() ){
                        System.debug('totalInterest--->> '+String.valueOf(BY_LOAN_AMOUNT_Map.get('totalInterest')));
                        errMsg += ' Total Interest;';
                    }
                    if( String.valueOf(BY_LOAN_AMOUNT_Map.get('holdAmount')).trim() != loanCalculatorConfigCRM.EquationHoldAmount__c.trim() ){
                        System.debug('holdAmount--->> '+String.valueOf(BY_LOAN_AMOUNT_Map.get('holdAmount')));
                        errMsg += ' Hold Amount;';
                    }

                }else if( calculationMethod == 'BY_MONTHLY_INSTALLMENT' ){
                    Map<String, Object> BY_MONTHLY_INSTALLMENT_Map = (Map<String, Object>)equationsMap.get('BY_MONTHLY_INSTALLMENT');
                    if( String.valueOf(BY_MONTHLY_INSTALLMENT_Map.get('totalRepayment')).trim() != loanCalculatorConfigCRM.EquationTotalRepayment__c.trim() ){
                        System.debug('BY_MONTHLY_INSTALLMENT_Map totalRepayment--->> '+String.valueOf(BY_MONTHLY_INSTALLMENT_Map.get('totalRepayment')));
                        errMsg += ' Total Repayment;';
                    }
                    if( String.valueOf(BY_MONTHLY_INSTALLMENT_Map.get('totalCashInHand')).trim() != loanCalculatorConfigCRM.EquationTotalCashInHand__c.trim() ){
                        System.debug('BY_MONTHLY_INSTALLMENT_Map totalCashInHand--->> '+String.valueOf(BY_MONTHLY_INSTALLMENT_Map.get('totalCashInHand')));

                        errMsg += ' Total CashInHand;';
                    }
                    if( String.valueOf(BY_MONTHLY_INSTALLMENT_Map.get('totalInterest')).trim() != loanCalculatorConfigCRM.EquationTotalInterest__c.trim() ){
                        System.debug('BY_MONTHLY_INSTALLMENT_Map totalInterest--->> '+String.valueOf(BY_MONTHLY_INSTALLMENT_Map.get('totalInterest')));
                        errMsg += ' Total Interest;';
                    }
                    if( String.valueOf(BY_MONTHLY_INSTALLMENT_Map.get('holdAmount')).trim() != loanCalculatorConfigCRM.EquationHoldAmount__c.trim() ){
                        System.debug('BY_MONTHLY_INSTALLMENT_Map holdAmount--->> '+String.valueOf(BY_MONTHLY_INSTALLMENT_Map.get('holdAmount')));
                        errMsg += ' holdAmount;';
                    }
                    if( String.valueOf(BY_MONTHLY_INSTALLMENT_Map.get('loanAmount')).trim() != loanCalculatorConfigCRM.EquationLoanAmount__c.trim() ){
                        System.debug('BY_MONTHLY_INSTALLMENT_Map loanAmount--->> '+String.valueOf(BY_MONTHLY_INSTALLMENT_Map.get('loanAmount')));
                        errMsg += ' Loan Amount;';
                    }
                }

                if(errMsg != ''){
                    errMsg = 'Please check with your Administrator ,Error on the configuration of these params :'+errMsg;
                    result.put('status', 'Error');
                    result.put('message', errMsg);
                }else{
                    result.put('status', 'Success');
                    result.put('response', response.getBody());
                }
            }
           
            
        } catch (Exception e) {
            result.put('status', 'Error');
            result.put('message', 'Error occurred while processing: ' + e.getMessage());
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }

        return result;
    }
}