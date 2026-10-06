/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 05-17-2024
 * @last modified by  : Elmustapha ELGARNI
**/
public class loanPaymentPdfController {
    //public String accName { get; set; }
    //public String customerId { get; set; }
    //public String selLoanId { get; set; }
    //public String regionName{get; set;}
    //public String loanFacilityNumber{get; set;}
    public String decodedaccName { get; set; }
    public String decodedcustomerId { get; set; }
    public String decodedcustomerCIFNo { get; set; }
    public String decodedselLoanId { get; set; }
    public String decodedregionName{get;set;}
    public String decodedloanFacilityNumber{get;set;}
    public String decodedPageName{get;set;}
    public String applicationNo { get; set; }
    public String caseCreatedDate { get; set; }
    public String currentDate { get; set; }
    public Loans_ServiceManagerHandler.APIResponse tmpResonse { get; set; }
    // List to hold the deserialized payments data
    public List<PaymentData> paymentsList { get; set; }
    public headerData header { get; set; }
    
    //header confige properties
    public Boolean isAlburaqProduct { get; set; }
    public String lbl_loanFinanceStartDate { get; set; }
    public String lbl_totalLoanAmount { get; set; }
    public String lbl_loanDuration { get; set; }
    public String lbl_interestRate { get; set; }
    public String lbl_totalInterestAmount { get; set; }
    public Decimal cashInHand { get; set; }
    public String lbl_ApprovedLoanAmount {get;set;}
    private static ApiConnection con = new ApiConnection();
    
    public String lbl_unit { get; set; }
    
    public loanPaymentPdfController() {
        // Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=paymentsSchedule.pdf');

        String pageName = ApexPages.currentPage().getParameters().get('pageName');
        System.debug('pageName ' + pageName);
        decodedPageName = EncodingUtil.base64Decode(pageName).toString();
        
        currentDate = '';
        DateTime now = DateTime.now();
        currentDate = DateTime.now().format('dd/MM/yyyy');
        if(decodedPageName == 'case'){
            String caseId = ApexPages.currentPage().getParameters().get('caseId');
            String decodedCaseId = EncodingUtil.base64Decode(caseId).toString();
            List<Case> csList = [Select Id,CaseNumber,Account.Name,Account.CIF__pc,RecordType_DeveloperName__c,Sub_Type__c,
                                  CreatedDate,Case_Model__c,Region_Flag__c,Customer_CIF__c,CaseAnnex__r.cx_ln_SR_Arrangment_Id__c,CaseAnnex__r.cx_ln_SimulationReference__c
                                  FROM Case WHERE Id =:decodedCaseId 
                                  LIMIT 1];
            List<CaseAnnex__c> caseAnnexs = [SELECT Id, cx_ln_Approved_Cash_in_Hand__c,cx_ln_Approved_Loan_Amount__c FROM CaseAnnex__c 
                                             WHERE Case__c =:decodedCaseId];
            
            if(!caseAnnexs.isEmpty()){
                cashInHand  = caseAnnexs[0].cx_ln_Approved_Cash_in_Hand__c;
            }
            else {
                cashInHand = 0;
            }
            System.debug('cashInHand ' + cashInHand);
            Loans_ServiceManagerHandler.APIResponse response;
            if (csList.get(0).RecordType_DeveloperName__c == 'LoanFinanceServiceRequest' && (csList.get(0).Sub_Type__c == 'Partial Settlement' || csList.get(0).Sub_Type__c == 'Top-up' || csList.get(0).Sub_Type__c == 'Restructuring') ) {
                String customerId = csList.get(0).Customer_CIF__c;
                String arrangementId = csList.get(0).CaseAnnex__r.cx_ln_SR_Arrangment_Id__c;
                String simulationReference = csList.get(0).CaseAnnex__r.cx_ln_SimulationReference__c;
                response = LoanServiceRequest_FinDetailsController.callGetLoanPaymentsScheduleForServiceRequest(csList.get(0).Id,customerId,simulationReference, arrangementId , false);
                
            }
            else{
                response = Loans_LoansListController.getSimulationPaymentList(decodedCaseId,csList.get(0).Region_Flag__c,false);
            }
            
            
            
            LoanAPIResponse loanResponse = new LoanAPIResponse();
            loanResponse.headerData = response.headerData;
            loanResponse.responseData = response.responseData;
            loanResponse.isSuccess = response.isSuccess;
            loanResponse.errorData = response.errorData;
            loanResponse.recordLength = response.recordLength;
            
            String jsonString =  JSON.serializePretty(loanResponse);
            System.debug('response case api ' + jsonString);
            //System.debug('jsonString ' + jsonString); 
            PaymentResponse payResponse = (PaymentResponse)System.JSON.deserialize(jsonString, PaymentResponse.class);
            
            header = new headerData();
            
            if (payResponse != null && payResponse.headerData != null) {
                header = payResponse.headerData;
                header.cashInHand = cashInHand;
                
                Decimal approvedLoanAmount = 0;
                if(!caseAnnexs.isEmpty()){	
                    approvedLoanAmount = caseAnnexs[0].cx_ln_Approved_Loan_Amount__c != null ? caseAnnexs[0].cx_ln_Approved_Loan_Amount__c : 0;
                }
                //'Approved Loan Amount' mapping would change for Top-up subtype 
                if (csList.get(0).RecordType_DeveloperName__c == 'LoanFinanceServiceRequest' && csList.get(0).Sub_Type__c == 'Top-up'){
                    header.principleAmount = header.remainingPrincipalAmount;// change UATNB-210123
            	}
                else if(csList.get(0).RecordType_DeveloperName__c == 'LoanFinanceServiceRequest' && csList.get(0).Sub_Type__c == 'Partial Settlement'){
                    header.principleAmount = header.remainingPrincipalAmount;// change UATNB-210123
                }
                
                header.monthlyInstallment = header.nextInstallmentAmount;// change (UATNB-210713)
                //updating the currency formatting YYYY-mm-DD to dd-MM-YYYY
                updateDateFormatOnHeaderDataFields();
            }
            
            if (payResponse != null && payResponse.responseData != null) {
                paymentsList = new List<PaymentData>(payResponse.responseData);
            } else {
                paymentsList = new List<PaymentData>();
            }
            
            
            if(!csList.isEmpty()){
                applicationNo = csList[0].CaseNumber;
                decodedaccName = csList[0].Account.Name;
                decodedcustomerCIFNo = csList[0].Account.CIF__pc;
                caseCreatedDate = csList[0].CreatedDate.format('dd/MM/YYYY');
                currentDate = caseCreatedDate;
                isAlburaqProduct = csList[0].Case_Model__c == 'ila' ? false : true;
                configureLabels(isAlburaqProduct);
            }
        }
        else {
            String accName = ApexPages.currentPage().getParameters().get('accName');
            System.debug('Account Name: ' + accName);
            
            String customerId = ApexPages.currentPage().getParameters().get('customerId');
            System.debug('Customer ID: ' + customerId);
            
            String customerCIFNo = ApexPages.currentPage().getParameters().get('customerCIFNo');
            
            String loanFacilityNumber = ApexPages.currentPage().getParameters().get('loanFacilityNumber');
            System.debug('Selected loanFacilityNumber: ' + loanFacilityNumber);
            
            String selLoanId = ApexPages.currentPage().getParameters().get('selLoanId');
            System.debug('Selected Loan ID: ' + selLoanId);
            
            String regionName = ApexPages.currentPage().getParameters().get('regionName');
            System.debug('Region Name: ' + regionName);
            
            String scheduleType = ApexPages.currentPage().getParameters().get('scheduleType');
    
            String isAlburaq = ApexPages.currentPage().getParameters().get('isAlburaq');
            String decodeIsAlburaq = EncodingUtil.base64Decode(isAlburaq).toString();
            
            isAlburaqProduct = decodeIsAlburaq == 'true' ? true : false;
            configureLabels(isAlburaqProduct);
            // Decode the parameters from base64
            decodedaccName = EncodingUtil.base64Decode(accName).toString();
            decodedloanFacilityNumber = EncodingUtil.base64Decode(loanFacilityNumber).toString();
            decodedcustomerId = EncodingUtil.base64Decode(customerId).toString();
            decodedselLoanId = EncodingUtil.base64Decode(selLoanId).toString();
            decodedregionName = EncodingUtil.base64Decode(regionName).toString();
            decodedcustomerCIFNo = EncodingUtil.base64Decode(customerCIFNo).toString();
            String decodedScheduleType = EncodingUtil.base64Decode(scheduleType).toString();
            applicationNo = decodedselLoanId;
            String searchParametersJson = '{"arrangementId":"'+ decodedselLoanId +'","type":"'+ decodedScheduleType +'"}';
            System.debug('api call Loans_ServiceManagerHandler.callGetLoanPaymentsSchedule --> ');
            System.debug('decodedcustomerId --> ' + decodedcustomerId);
            System.debug('searchParametersJson --> ' + searchParametersJson);
            System.debug('decodedregionName --> ' + decodedregionName);
            Loans_ServiceManagerHandler.APIResponse response = Loans_ServiceManagerHandler.callGetLoanPaymentsSchedule(null,decodedcustomerId, searchParametersJson,decodedregionName,false);
            
            
            LoanAPIResponse loanResponse = new LoanAPIResponse();
            loanResponse.headerData = response.headerData;
            loanResponse.responseData = response.responseData;
            loanResponse.isSuccess = response.isSuccess;
            loanResponse.errorData = response.errorData;
            loanResponse.recordLength = response.recordLength;
            
            System.debug('searchParametersJson response ' + response);
            String jsonString =  JSON.serializePretty(loanResponse);
            PaymentResponse payResponse = (PaymentResponse)System.JSON.deserialize(jsonString, PaymentResponse.class);
            
            header = new headerData();
            
            if (payResponse != null && payResponse.headerData != null) {
                header = payResponse.headerData;
                System.debug('response header ' + header);

                cashInHand = header.cashInHand;
                header.monthlyInstallment = header.nextInstallmentAmount;// change (UATNB-210713)
                updateDateFormatOnHeaderDataFields();
            }
            
            if (PayResponse != null && PayResponse.responseData != null) {
                paymentsList = new List<PaymentData>(PayResponse.responseData);
            } else {
                paymentsList = new List<PaymentData>();
            }
            
            /*
            Loans_ServiceManagerHandler.APIResponse response = new Loans_ServiceManagerHandler.APIResponse();
            response = loadPaymentsSchedule(decodedselLoanId,decodedloanFacilityNumber,decodedcustomerId,decodedregionName);
            System.debug('Repayments schedule Response in constructor:'+response);
            String jsonString =  JSON.serializePretty(response);
            System.debug('JSON String in constructor:'+jsonString);//responseData
            
            PaymentResponse payResponse = (PaymentResponse)System.JSON.deserialize(jsonString, PaymentResponse.class);
            System.debug('Pay Response:'+PayResponse);
            if (PayResponse != null && PayResponse.responseData != null) {
                paymentsList = new List<PaymentData>(PayResponse.responseData);
            } else {
                paymentsList = new List<PaymentData>();
            }
            
            header = new headerData();
            if (PayResponse != null && PayResponse.headerData != null) {
                header = PayResponse.headerData;
            } 
            System.debug('header :'+header);
            
            //Customer name will be fetched if its empty.
            if(String.isEmpty(decodedaccName) && !String.isEmpty(decodedcustomerId)){
                List<Account> accList = [Select Id,Name FROM Account WHERE CIF__pc =:decodedcustomerId LIMIT 1];
                if(!accList.isEmpty()){
                    decodedaccName = accList[0].Name;
                }
            }*/   
        }
        
        //Updating the date format on paymentlist wrapper
        for(PaymentData pData :paymentsList){
            pData.installmentDueDate = updateDateFormat(pData.installmentDueDate);
        }
    }
    
    /**
     * @description - this method would update the date format on all the date fields.
     */
    public void updateDateFormatOnHeaderDataFields(){
        header.firstInstallmentDate = updateDateFormat(header.firstInstallmentDate);
        header.lastInstallmentDate = updateDateFormat(header.lastInstallmentDate);
        System.debug('loanStartDate ' + header.loanStartDate);
        header.loanStartDate = updateDateFormat(header.loanStartDate);
        
    }
    
    /**
     * @description - this method would takes a date string yyyy-mm-dd and return it to dd-mm-yyyy
     */
    public String updateDateFormat(String dtString){
        System.debug('dtString ' + dtString);
        String newDate = dtString;
        if(!String.isEmpty(newDate) && newDate.length() == 10){ //10 is a total of "yyyy-mm-dd" string
            List<String> dateComponents = newDate.split('-');
            if(dateComponents.size() == 3){
                newDate = dateComponents[2] + '-' + dateComponents[1] + '-' + dateComponents[0];
            }
        }
        
        return newDate;
    }
    
    public void configureLabels(Boolean isAlburaq){
        if(isAlburaq){
            lbl_loanFinanceStartDate = 'Finance Start Date';
            lbl_totalLoanAmount = 'Total Finance Amount';
            lbl_loanDuration = 'Finance Duration';
            lbl_interestRate = 'Profit Rate (Reducing)';
            lbl_totalInterestAmount = 'Total Profit Amount';
            lbl_unit = 'Alburaq';
            lbl_ApprovedLoanAmount = 'Approved Finance Amount';
        }
        else {
            lbl_loanFinanceStartDate = 'Loan Start Date';
            lbl_totalLoanAmount = 'Total Repayment Amount';
            lbl_loanDuration = 'Loan Duration';
            lbl_interestRate = 'Interest Rate (Reducing)';
            lbl_totalInterestAmount = 'Total Interest Amount';
            lbl_unit = 'Ila';
            lbl_ApprovedLoanAmount = 'Approved Loan Amount';
        }
    }
    
    /*
    public Loans_ServiceManagerHandler.APIResponse loadPaymentsSchedule(String selLoanId,String loanFacilityNumber, final String customerId, String regionName){
        Loans_ServiceManagerHandler.APIResponse response = new Loans_ServiceManagerHandler.APIResponse();
        response.responseData = new List<Object>();
        
        System.debug('Selected Loan Id:'+selLoanId+ customerId + regionName+ loanFacilityNumber);
        
        String requestBody = '{"arrangementId":"' + selLoanId + '","loanFacilityNumber":"'+ loanFacilityNumber + '","type":"Schedule"}';
        
        
        //List<Case> cases = [SELECT Id,Customer_CIF__c,CaseAnnex__r.cx_ln_SimulationReference__c FROM Case WHERE Id = :caseId];
        //String customerId = cases.get(0).Customer_CIF__c;
        //String simulationReference = cases.get(0).CaseAnnex__r.cx_ln_SimulationReference__c;
        //String searchParametersJson = '{"crmCaseId": "'+caseId+'","simulationReference":"'+simulationReference+'","type": "Simulation"}';
        String searchParametersJson = '{"type": "Simulation"}';
        
        system.debug('Request Body:'+requestBody);
        response = Loans_ServiceManagerHandler.callGetLoanPaymentsSchedule(customerId, requestBody,searchParametersJson,regionName,false);
        System.debug('Response Body for payments schedule' + JSON.serializePretty(response));
        return response;
    }*/
    
    // Wrapper class to represent payment data
    public class headerData {
        public Decimal principleAmount { get; set; }
        public Decimal RemainingPrincipalAmount { get; set; }
        public Decimal interestRate { get; set; }
        public Decimal loanPeriod { get; set; }
        public String loanStartDate { get; set; }
        public Decimal lifeInsuranceRate { get; set; }
        public Decimal insuranceAmount { get; set; }
        public Decimal monthlyInstallment { get; set; }
        public Decimal nextInstallmentAmount { get; set; }
        public Decimal numberOfPayments { get; set; }
        public String firstInstallmentDate { get; set; }
        public String lastInstallmentDate { get; set; }
        public Decimal totalInterest { get; set; }
        public Decimal administrationFees { get; set; }
        public Decimal administrationFeesVat { get; set; }
        public Decimal totalCostOfLoan { get; set; }
        public String firstInterestAccrualDate { get; set; }
        public Decimal apr { get; set; }
        public Decimal cashInHand { get; set; }
        //maturity //toCheck
        //currency //toCheck
        
        public String getFormattedTotalCostOfLoan(){
            return getFormattedCurrency(totalCostOfLoan);
        }
        
        public String getFormattedInterestRate(){
            return getFormattedCurrency(interestRate);
        }
        
        public String getFormattedLifeInsuranceRate(){
            return getFormattedCurrency(lifeInsuranceRate);
        }
        
        public String getFormattedApr(){
            return getFormattedCurrency(apr);
        }
        
        public String getFormattedPrincipleAmount(){
            return getFormattedCurrency(principleAmount);
        }
        
        public String getFormattedMonthlyInstallment(){
            return getFormattedCurrency(monthlyInstallment);
        }
        
        public String getFormattedCashInHand(){
            return getFormattedCurrency(cashInHand);
        }
        
        public String getFormattedTotalInterest(){
            return getFormattedCurrency(totalInterest);
        }
        
        public String getFormattedInsuranceAmount(){
            System.debug('insuranceAmount ' + insuranceAmount);
            return getFormattedCurrency(insuranceAmount);
        }
        
        public String getFormattedAdministrationFees(){
            return getFormattedCurrency(administrationFees);
        }
        
        public String getFormattedAdministrationFeesVat(){
            return getFormattedCurrency(administrationFeesVat);
        }
        
        public String getFormattedCurrency(Decimal currencyValue){
            if(currencyValue == null) return '0.000';
            
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

    public class PaymentData {
        public String paymentDate { get; set; }
        public Decimal monthlyInstallmentNoCharge { get; set; } //toCheck
        public Decimal interestAmount { get; set; }
        public Decimal adminFeesFlat { get; set; }
        public Decimal adminFeesVat { get; set; }
        public Decimal monthlyInsuranceFeesReducing { get; set; }
        public Decimal monthlyInsuranceFeesFlat { get; set; }
        public Decimal outstandingAmount { get; set; }
        public Decimal endingBalance { get; set; }
        public Decimal principalAmount { get; set; }
        public Decimal totalAmount { get; set; }//toCheck
        public String transactionType { get; set; }
        public String billStatus { get; set; }
        public String scheduleType { get; set; }
        public String settleDate { get; set; }//toCheck
        public Integer installmentNo { get; set; }
        public String installmentDueDate { get; set; }
        public Integer noOfDays { get; set; }
        public Decimal beginningBalance { get; set; }
        public Decimal monthlyInstallmentFull { get; set; }
        public Decimal monthlyInstallmentExcludingCharges { get; set; }
        
        public String getFormattedMonthlyInsuranceFeesFlat(){
            return getFormattedCurrency(monthlyInsuranceFeesFlat);
        }
        public String getFormattedAdminFeesVat(){
            return getFormattedCurrency(adminFeesVat);
        }
        
        public String getFormattedAdminFeesFlat(){
            return getFormattedCurrency(adminFeesFlat);
        }
        
        public String getFormattedOutstandingAmount(){
            return getFormattedCurrency(outstandingAmount);
        }
        
        public String getFormattedMonthlyInstallmentFull(){
            return getFormattedCurrency(monthlyInstallmentFull);
        }
        
        public String getFormattedMonthlyInstallmentExcludingCharges(){
            return getFormattedCurrency(monthlyInstallmentExcludingCharges);
        }
        
        public String getFormattedMonthlyInsuranceFeesReducing(){
            return getFormattedCurrency(monthlyInsuranceFeesReducing);
        }
        
        public String getFormattedEndingBalance(){
            return getFormattedCurrency(endingBalance);
        }
        
        public String getFormattedInterestAmount(){
            return getFormattedCurrency(interestAmount);
        }
            
        public String getFormattedPrincipalAmount(){
            return getFormattedCurrency(principalAmount);
        }
        
        public String getFormattedBeginningBalance(){
            return getFormattedCurrency(beginningBalance);
        }
        
        public String getFormattedCurrency(Decimal currencyValue){
            
            if(currencyValue == null) return '0.000';
            
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

    public class PaymentResponse {
        public headerData headerData { get; set; }
        public List<PaymentData> responseData { get; set; }
    }
    
    
    public class LoanAPIResponse {
        public Boolean isSuccess;
        public Object responseData;
        public Object errorData;
        public Object headerData;
        public Integer recordLength;
    }
    
}