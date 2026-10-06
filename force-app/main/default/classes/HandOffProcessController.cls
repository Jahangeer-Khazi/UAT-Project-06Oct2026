/**
 * @description       : 
 * @author            : AITOGRAM Omar
 * @group             : 
 * @last modified on  : 04-28-2024
 * @last modified by  : AITOGRAM Omar
*      #CH03# #Aniss Mbarki# #29-07-2026#  set default values (NBA-17410)
 * 
**/
 
public without sharing class HandOffProcessController {

    private static ApiConnection con = new ApiConnection();
    private static List<System_Action__c> lstSA = new List<System_Action__c>();

    @AuraEnabled
    public static Map<String, Object> getCaseAnnexFields(String caseId) {
        Map<String, Object> result = new Map<String, Object>();
        List<Case> caseList = [SELECT Id, isSubmitted__c FROM Case WHERE Id = :caseId LIMIT 1];
         List<CaseAnnex__c> cases = [SELECT 
                                        Id, Early_Settlement_Reason__c, FEEAmount__c,
                                        FEEType__c, ReversalWaiverReason__c, cx_ln_NumberDeferredInstallments__c,
                                        InstallDefermentReason__c,  PartialSettlementAmount__c, PartialSettlementRestructure__c,
                                        InstalmentsForAdvancePayments__c, AdvancePaymentAmount__c, AdvancePayment__c, cx_ln_RestructureOption__c,cx_ln_Installment_Advance_Payment_reason__c,
                                        cx_ln_Requested_Duration_Months__c,ApprovedLoanTopUpDuration__c,cx_ln_ApprovedNewRate__c
                                     FROM CaseAnnex__c
                                     WHERE Case__c  = :caseId LIMIT 1];
        
        if (!cases.isEmpty()) {
            System.debug('cases >>> ');
            
            CaseAnnex__c caseRecord = cases[0];
            //result.put('TotalTopUpAmount__c', caseRecord.TotalTopUpAmount__c);
            //result.put('TotalNumberOfInstallments__c', caseRecord.TotalNumberOfInstallments__c);
            //result.put('EarlySettlementReason__c', caseRecord.Early_Settlement_Reason__c);
            result.put('FEEAmount__c', caseRecord.FEEAmount__c);
            result.put('FEEType__c', caseRecord.FEEType__c);
            result.put('ReversalWaiverReason__c', caseRecord.ReversalWaiverReason__c);
            result.put('InstallDefermentReason__c', caseRecord.InstallDefermentReason__c);
            result.put('cx_ln_NumberDeferredInstallments__c', caseRecord.cx_ln_NumberDeferredInstallments__c);
            result.put('PartialSettlementRestructure__c', caseRecord.PartialSettlementRestructure__c);
            result.put('PartialSettlementAmount__c', caseRecord.PartialSettlementAmount__c);
            result.put('cx_ln_Requested_Duration_Months__c', caseRecord.cx_ln_Requested_Duration_Months__c);
            result.put('ApprovedLoanTopUpDuration__c', caseRecord.ApprovedLoanTopUpDuration__c);
            result.put('InstalmentsForAdvancePayments__c', caseRecord.InstalmentsForAdvancePayments__c);
            // result.put('AdvancePayment__c', caseRecord.AdvancePayment__c);
            result.put('cx_ln_Installment_Advance_Payment_reason__c', caseRecord.cx_ln_Installment_Advance_Payment_reason__c);
            //result.put('ReasonForTheLoanFinanceRestructur__c', caseRecord.ReasonForTheLoanFinanceRestructur__c);
            result.put('cx_ln_RestructureOption__c', caseRecord.cx_ln_RestructureOption__c);
            result.put('cx_ln_ApprovedNewRate__c', caseRecord.cx_ln_ApprovedNewRate__c);

        }
        
        // Check if Content__c records exist for this Case  (Omar start)
        List<Content__c> contents = [SELECT Id FROM Content__c WHERE Case__c = :caseId];
        result.put('hasContent', (contents!=null && contents.size()>0)? true: false);
        System.debug('contents >>> '+ contents);
        // (Omar end)

         List<String> RestructuringValues = getPicklistValues('CaseAnnex__c', 'cx_ln_RestructureOption__c');
         result.put('RestructuringValues', RestructuringValues);
         //List<String> EarlySettlementPicklistValues = getPicklistValues('CaseAnnex__c', 'Early_Settlement_Reason__c');
         //result.put('EarlySettlementReasonPicklistValues', EarlySettlementPicklistValues);
         List<String> PartialSettlementPicklistValues = getPicklistValues('CaseAnnex__c', 'PartialSettlementRestructure__c');
         result.put('PartialSettlementRestructureValues', PartialSettlementPicklistValues);
         //List<String> AdvancePaymentPicklistValues = getPicklistValues('CaseAnnex__c', 'AdvancePayment__c');
         //result.put('AdvancePaymentPicklistValues', AdvancePaymentPicklistValues);
         result.put('isSubmitted', caseList[0].isSubmitted__c);

        System.debug('result >>> '+ result);
        return result;
    }

    
  
    
    
    // Method to retrieve picklist values 
    public static List<String> getPicklistValues(String objectApiName, String fieldApiName) {
        List<String> values = new List<String>();
        List<PicklistValueInfo> picklistInfo = [SELECT Label, Value FROM PicklistValueInfo WHERE EntityParticle.EntityDefinition.QualifiedApiName = :objectApiName AND EntityParticle.QualifiedApiName = :fieldApiName AND IsActive = true LIMIT 50];
        for (PicklistValueInfo info : picklistInfo) {
            values.add(info.Value+';'+info.Label);
        }
        return values;
    }

    @AuraEnabled
    public static Boolean checkContentsofList (String caseId) {//#CH01
        System.debug('checkContentsofList >>> '+ caseId);
        List<Content__c> contents = [SELECT Id FROM Content__c WHERE Case__c = :caseId];
        Boolean hasContent = (contents!=null && contents.size()>0)? true: false;
        System.debug('hasContent >>> '+ hasContent);
        return hasContent;
    }
    
    
   @AuraEnabled
    public static void submitForm(String caseId, String earlySettlementReason, Decimal FEEAmount, String FEEType, String ReversalWaiverReason, 
                                String InstallDefermentReason,Integer NumberDeferredInstallments, String PartialSettlementRestructureValue, Decimal PartialSettlementAmount,Integer PartialSettlementTerm,Decimal newRate, 
                                Integer InstalmentsForAdvancePayments, String AdvancePaymentReason, String AdvancePaymentValue, String restructuringValue, String LoanId, Map<Object, Object> loanObj) {
                            
        CaseAnnex__c caseAnnexRecord;
        List<Case> cases = new List<Case>();
        if (caseId != null) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            
            String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,Account.ID_Type__pc,Account.ID_Number__pc,Account.ID_Expiry_Date__pc FROM Case WHERE Id = :caseId';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        }
        Case caseObj = cases[0];
        
        //List<CaseAnnex__c> caseAnnexList = [SELECT Id, Case__c, Case__r.Sub_Type__c, TotalTopUpAmount__c, TotalNumberOfInstallments__c, Early_Settlement_Reason__c FROM CaseAnnex__c WHERE Case__c = :caseId LIMIT 1];
        
        if (caseObj.CaseAnnex__c != null) {
            caseAnnexRecord = new CaseAnnex__c(id=caseObj.CaseAnnex__c);
            System.debug('Retrieved Case Record: ' + caseAnnexRecord);
        } 
        else {
            caseAnnexRecord = new CaseAnnex__c(Case__c = caseId);
        }

        // set field values for the caseAnnex based on submitForm 
        List<RecordType> recTypeList = [SELECT DeveloperName, Id ,SobjectType FROM RecordType WHERE  DeveloperName ='LoanFinanceServiceRequest' and SobjectType ='CaseAnnex__c'];
        if(recTypeList!=null &&recTypeList.size() > 0){
            caseAnnexRecord.RecordTypeId=recTypeList[0].Id;
        }

        //earlySettlement fields
        if (earlySettlementReason != null) {
            caseAnnexRecord.cx_ln_Installment_Advance_Payment_reason__c = earlySettlementReason;
        }

        // AdvancePayment fields
        if (AdvancePaymentReason != null) {
            caseAnnexRecord.cx_ln_Installment_Advance_Payment_reason__c = AdvancePaymentReason;
        }
        if (InstalmentsForAdvancePayments != null) {
            caseAnnexRecord.InstalmentsForAdvancePayments__c = InstalmentsForAdvancePayments;
        } 

        //PartialSettlement fields 
        if (PartialSettlementRestructureValue != null) {
            caseAnnexRecord.PartialSettlementRestructure__c = PartialSettlementRestructureValue;
        }    
        if (PartialSettlementAmount != null) {
            caseAnnexRecord.PartialSettlementAmount__c = PartialSettlementAmount;
        }
        if (PartialSettlementTerm != null) {
            caseAnnexRecord.cx_ln_Requested_Duration_Months__c = PartialSettlementTerm;
        }
        if (newRate != null) {
            caseAnnexRecord.cx_ln_ApprovedNewRate__c = newRate;
        }

        //other fields for other loan sub types ..
        /*if (totalTopUpAmount != null) {
            caseAnnexRecord.TotalTopUpAmount__c = totalTopUpAmount;
        }      
        if (totalNumberOfInstallments != null) {
            caseAnnexRecord.TotalNumberOfInstallments__c = totalNumberOfInstallments;
        }*/          
        if (FEEAmount != null) {
            caseAnnexRecord.FEEAmount__c = FEEAmount;
        }        
        if (FEEType != null) {
            caseAnnexRecord.FEEType__c = FEEType;
        }    
        if (ReversalWaiverReason != null) {
            caseAnnexRecord.ReversalWaiverReason__c = ReversalWaiverReason;
        }     
        if (InstallDefermentReason != null) {
            caseAnnexRecord.InstallDefermentReason__c = InstallDefermentReason;
        }  
        if (NumberDeferredInstallments != null) {
            caseAnnexRecord.cx_ln_NumberDeferredInstallments__c = NumberDeferredInstallments;
        }  
        if (AdvancePaymentValue != null) {
            caseAnnexRecord.AdvancePayment__c = AdvancePaymentValue;
        }  
        if (restructuringValue != null) {
            caseAnnexRecord.cx_ln_RestructureOption__c = restructuringValue;
        }
        System.debug('Case annex Record: ' + caseAnnexRecord);

    
        System.debug('Case Record: ' + caseAnnexRecord);
    
        if (caseAnnexRecord != null) {
            System.debug('CaseAnnex__c Record Exist');
    
            if (caseObj.Sub_Type__c == 'Early Settlement') {
                caseAnnexRecord.cx_ln_Installment_Advance_Payment_reason__c = earlySettlementReason;
            } else if (caseObj.Sub_Type__c == 'Fees Reversal / Waiver') {
                System.debug('Subtype is Fees Reversal / Waiver');
                caseAnnexRecord.FEEAmount__c = FEEAmount;
                caseAnnexRecord.FEEType__c = FEEType;
                caseAnnexRecord.ReversalWaiverReason__c = ReversalWaiverReason;
            } else if (caseObj.Sub_Type__c == 'Instalment Deferment / Postponement') {
                System.debug('Instalment Deferment / Postponement');
                caseAnnexRecord.InstallDefermentReason__c = InstallDefermentReason;
                caseAnnexRecord.cx_ln_NumberDeferredInstallments__c = NumberDeferredInstallments;

                //#CH03 :Start //default values set bcz of (NBA-17410
                caseAnnexRecord.cx_ln_Deferment_with_Applicable_Fees__c = 'Yes'; 
                caseAnnexRecord.cx_ln_Approved_Number_of_Months__c = String.valueOf(NumberDeferredInstallments);
                caseAnnexRecord.cx_ln_Approved_Deferment_Fee_Amount__c = NumberDeferredInstallments*10;
                //#CH03 :End

            } else if (caseObj.Sub_Type__c == 'Partial Settlement' || caseObj.Sub_Type__c == 'Top-up') {
                System.debug(caseObj.Sub_Type__c);
                caseAnnexRecord.PartialSettlementRestructure__c = PartialSettlementRestructureValue;
                caseAnnexRecord.PartialSettlementAmount__c = PartialSettlementAmount;
                caseAnnexRecord.cx_ln_Requested_Duration_Months__c = PartialSettlementTerm;

                caseAnnexRecord.cx_ln_Approved_Loan_Amount__c = PartialSettlementAmount;
                caseAnnexRecord.cx_Approved_Partial_payment_option__c = PartialSettlementRestructureValue;
                caseAnnexRecord.cx_ln_Approved_Duration_Months__c = PartialSettlementTerm;
                
                if(caseObj.Account.ID_Type__pc == 'Bahraini ID'){
                    caseObj.cc_CPR_Number__c = caseObj.Account.ID_Number__pc;
                    caseObj.cc_CPR_Expiry_Date__c = caseObj.Account.ID_Expiry_Date__pc;
                }
            } else if (caseObj.Sub_Type__c == 'Advance Payment') {
                System.debug('Advance Payment');
                caseAnnexRecord.InstalmentsForAdvancePayments__c = InstalmentsForAdvancePayments;
                caseAnnexRecord.cx_ln_Installment_Advance_Payment_reason__c = AdvancePaymentReason;
                //caseAnnexRecord.AdvancePayment__c = AdvancePaymentValue;//I think no need for this value in this sceanrio anymre
            } else if (caseObj.Sub_Type__c == 'Restructuring') {
                System.debug('Restructuring');
                caseAnnexRecord.cx_ln_RestructureOption__c = restructuringValue;
                //if "Term" required please use PartialSettlementTerm
                caseAnnexRecord.cx_ln_Requested_Duration_Months__c = PartialSettlementTerm;
                caseAnnexRecord.cx_ln_Approved_Duration_Months__c = PartialSettlementTerm;
                caseAnnexRecord.cx_ln_ApprovedNewRate__c = newRate;
            } 
            else {
                    System.debug('Subtype not found');
            }
            
            Decimal currentLoanInstallment = (Decimal) loanObj.get('monthlyInstallment'); 
            caseAnnexRecord.cx_ln_Requested_Loan_Finance_Amount__c = currentLoanInstallment;

           System.debug('CaseAnnex__c Record Upserted Successfully');

           String transactProduct = (String) loanObj.get('transactProduct'); 
           String ac_currency = (String) loanObj.get('currency'); 

           //set case value after submit to store loanId and isSubmited to true
           caseObj.isSubmitted__c = true;
           caseObj.cc_PCI_Id__c = LoanId;
           caseObj.Card_Product_Configuration_Id__c = transactProduct;
           caseObj.ac_Currency__c = ac_currency;
           
           
           //call api after submit based on type and sub-type
           if(caseObj.isSubmitted__c){
                //omar Start
                if(caseObj.Sub_Type__c == 'Fees Reversal / Waivers' && caseObj.RecordType_DeveloperName__c == 'LoanFinanceServiceRequest'){
                    caseObj.OwnerId =  System.label.Loan_Finance_Request_Fees_Waiver_Queue;
                }
                else if(caseObj.Sub_Type__c == 'Advance Payment' && caseObj.RecordType_DeveloperName__c == 'LoanFinanceServiceRequest'){
                    caseObj.OwnerId =  System.label.Loan_Finance_Request_Approver;
                }
                else {
                   caseObj.OwnerId = System.label.Loan_Finance_Request_Pre_screener_Queue;
                }
                //omar end
                
                if(caseObj.Sub_Type__c == 'Early Settlement' && caseObj.RecordType_DeveloperName__c == 'LoanFinanceServiceRequest'){
              
                  String regionName = caseObj.Region_Flag__c;
                  if (caseObj.Case_Model__c == 'alburaq') {
                      regionName += '_alburaq';
                  }
                  //HTTP Callout to get Early settlement Details
                  HttpRequest request1 = con.createRequest('GET', '/api/v1/loans/early-settlement-details/' + caseObj.cc_PCI_Id__c,regionName);
                  system.debug('customerId : '+ caseObj.Customer_CIF__c);
                  request1.setHeader('customerId', caseObj.Customer_CIF__c);
                  request1.setTimeout(60000);
                  HttpResponse response1 = Loans_ServiceApiCallsEM.getLoanEarlySettlementDetailsAPI(request1,200);//real api call
                  // HttpResponse response1 = new Loans_ServiceApiCallsMock().getLoanEarlySettlementDetailsAPI(request1,200);

                  System.debug('getLoanEarlySettlementDetailsAPI response : '+ response1 );
                  System.debug('getLoanEarlySettlementDetailsAPI response Body : '+ response1.getBody() );

                  lstSA.add(SM001_ApiCalls.setSystemAction( request1.getBody(),response1.getBody(),
                                                      request1.getEndpoint(),request1.getMethod(),
                                                      caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response1.getStatusCode(), 
                                                      caseObj.Type+'-- getLoanEarlySettlementSetails API', caseObj.Type
                                                  ));
                  if(response1.getStatusCode() != 200 ){
                      System.debug('Invalid getLoanEarlySettlementDetailsAPI Request Status API after insert');
                      caseObj.Last_Api_Call_Status__c = 'Failed';
                      
                  }else{
                      caseObj.Last_Api_Call_Status__c = 'Success';

                      Map<String, Object> parsedResponse1 = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                      Map<String, Object> data = (Map<String, Object>)parsedResponse1.get('data');

                      caseAnnexRecord.EarlyRepaymentFee__c = (Decimal)data.get('earlySettlementFee');
                      caseAnnexRecord.cx_ln_Early_Settlement_fee_VAT__c = (Decimal)data.get('earlySettlementFeeVAT');
                      caseAnnexRecord.cc_ln_Early_Settlement_fee_VAT_inclusive__c = (Decimal)data.get('earlySettlementFeeFull');
                      caseAnnexRecord.cx_ln_Current_Remaining_principal_amount__c = (Decimal)data.get('remainingPrincipalAmount');
                      caseAnnexRecord.cx_ln_Current_Accrued_interest_amount__c = (Decimal)data.get('accruedInterestAmount');
                      caseAnnexRecord.cx_Current_Remaining_administration_fee__c = (Decimal)data.get('remainingAdminFee');
                      caseAnnexRecord.cx_Current_RemainingAdministrationFeeVAT__c = (Decimal)data.get('remainingAdminFeeVAT');
                      caseAnnexRecord.cx_Full_Remaining_administration_fee__c = (Decimal)data.get('remainingAdminFeeFull');
                      caseAnnexRecord.cx_Current_Late_payment_charges__c = (Decimal)data.get('latePaymentCharges');
                      caseAnnexRecord.cx_Current_Late_payment_charges_VAT__c = (Decimal)data.get('latePaymentChargesVAT');
                      caseAnnexRecord.cx_Full_late_payment_charges_VAT_inlu__c = (Decimal)data.get('latePaymentChargesFull');
                      caseAnnexRecord.cx_Insurance_amount_assessment__c = (Decimal)data.get('insuranceAmount');
                      Date maturityDate = Date.valueOf(String.valueOf(data.get('currentMaturityDate')));
                      caseAnnexRecord.cx_ln_Requested_Maturity_Date__c = maturityDate ;
                      caseAnnexRecord.cx_Total_Payoff_amount__c = (Decimal)data.get('totalPayoffAmount');
                      //caseAnnexRecord.cx_ln_BonusDiscount__c = (Decimal)data.get('XX');//NBA-16578 //#CH02
                  }
                } 
                else if((caseObj.Sub_Type__c == 'Partial Settlement' && caseObj.RecordType_DeveloperName__c == 'LoanFinanceServiceRequest')){

                  String regionName = caseObj.Region_Flag__c;
                  if (caseObj.Case_Model__c == 'alburaq') {
                      regionName += '_alburaq';
                  }
                  //HTTP Callout to get Partial settlement Details 
                  HttpRequest request1 = con.createRequest('GET', '/api/v1/loans/partial-settlement-details/' + caseObj.cc_PCI_Id__c+'/'+caseAnnexRecord.cx_ln_Approved_Loan_Amount__c,regionName); //System.Label.CC_EndPointCreditCardRequest
                  system.debug('customerId : '+ caseObj.Customer_CIF__c);
                  request1.setHeader('customerId', caseObj.Customer_CIF__c);
                  request1.setTimeout(60000);
                  HttpResponse response1 = Loans_ServiceApiCallsEM.getLoanPartialSettlementDetailsAPI(request1,200);//real api call
                  // HttpResponse response1 = new Loans_ServiceApiCallsMock().getLoanPartialSettlementDetailsAPI(request1,200);

                  System.debug('getLoanPartialSettlementDetailsAPI response : '+ response1 );
                  System.debug('getLoanPartialSettlementDetailsAPI response Body : '+ response1.getBody() );
                  
                  lstSA.add(SM001_ApiCalls.setSystemAction( request1.getBody(),response1.getBody(),
                                                      request1.getEndpoint(),request1.getMethod(),
                                                      caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response1.getStatusCode(), 
                                                      caseObj.Type+'-- getLoanPartialSettlementSetails API', caseObj.Type
                                                  ));
                  if(response1.getStatusCode() != 200 ){
                      System.debug('Invalid getLoanPartialSettlementDetailsAPI Request Status API after insert');
                      caseObj.Last_Api_Call_Status__c = 'Failed';
                      
                  }else{
                      caseObj.Last_Api_Call_Status__c = 'Success';
                      
                      Map<String, Object> parsedResponse1 = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                      Map<String, Object> data = (Map<String, Object>)parsedResponse1.get('data');
                      
                      caseAnnexRecord.cx_ln_Current_Remaining_principal_amount__c = (Decimal)data.get('currentRemainingPrincipalAmount');
                      caseAnnexRecord.cx_ln_Current_Accrued_interest_amount__c = (Decimal)data.get('currentAccruedInterestAmount');
                      caseAnnexRecord.PartialRepaymentFee__c = (Decimal)data.get('currentPartialSettlementFee');
                      caseAnnexRecord.cx_ln_Early_Settlement_fee_VAT__c = (Decimal)data.get('currentPartialSettlementFeeVAT');
                      caseAnnexRecord.cc_ln_Early_Settlement_fee_VAT_inclusive__c = (Decimal)data.get('currentPartialSettlementFeeFull');
                      caseAnnexRecord.cx_Current_Remaining_administration_fee__c = (Decimal)data.get('currentRemainingAdminFee');
                      caseAnnexRecord.cx_Current_RemainingAdministrationFeeVAT__c = (Decimal)data.get('currentRemainingAdminFeeVAT');
                      caseAnnexRecord.cx_Full_Remaining_administration_fee__c = (Decimal)data.get('currentRemainingAdminFeeFull');
                      caseAnnexRecord.cx_Current_Late_payment_charges__c = (Decimal)data.get('currentLatePaymentCharges');
                      caseAnnexRecord.cx_Current_Late_payment_charges_VAT__c = (Decimal)data.get('currentLatePaymentChargesVAT');
                      caseAnnexRecord.cx_Full_late_payment_charges_VAT_inlu__c = (Decimal)data.get('currentLatePaymentChargesFull');
                      caseAnnexRecord.cx_Insurance_amount_assessment__c = (Decimal)data.get('currentInsuranceAmount');
                      Date maturityDate = Date.valueOf(String.valueOf(data.get('currentMaturityDate')));
                      caseAnnexRecord.cx_ln_Requested_Maturity_Date__c = maturityDate ;
                      caseAnnexRecord.cx_Total_Payoff_amount__c = (Decimal)data.get('totalPayoffAmount');
                      
                  }
                } 
                else if((caseObj.Sub_Type__c == 'Top-up' && caseObj.RecordType_DeveloperName__c == 'LoanFinanceServiceRequest')){
                  String regionName = caseObj.Region_Flag__c;
                  if (caseObj.Case_Model__c == 'alburaq') {
                      regionName += '_alburaq';
                  }
                  //HTTP Callout to get Partial settlement Details
                  HttpRequest request1 = con.createRequest('GET', '/api/v1/loans/loan-top-up-details/' + caseObj.cc_PCI_Id__c,regionName);
                  system.debug('customerId : '+ caseObj.Customer_CIF__c);
                  request1.setHeader('customerId', caseObj.Customer_CIF__c);
                  request1.setTimeout(60000);
                  HttpResponse response1 = Loans_ServiceApiCallsEM.getLoanPartialSettlementDetailsAPI(request1,200);//real api call
                  // HttpResponse response1 = new Loans_ServiceApiCallsMock().getLoanPartialSettlementDetailsAPI(request1,200);
     
                  System.debug('getLoanDetailsAPI loan-top-up-details  response : '+ response1 );
                  System.debug('getLoanDetailsAPI loan-top-up-details response Body : '+ response1.getBody() );
                  
                  lstSA.add(SM001_ApiCalls.setSystemAction( request1.getBody(),response1.getBody(),
                                                      request1.getEndpoint(),request1.getMethod(),
                                                      caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response1.getStatusCode(), 
                                                      caseObj.Type+'-- Get Loan loan-top-up-details API', caseObj.Type
                                                  ));
                  if(response1.getStatusCode() != 200 ){
                      System.debug('Invalid getLoanDetailsAPI loan-top-up-details Request Status API after insert');
                      caseObj.Last_Api_Call_Status__c = 'Failed';
                      
                  }else{
                      caseObj.Last_Api_Call_Status__c = 'Success';
                      
                      Map<String, Object> parsedResponse1 = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                      Map<String, Object> data = (Map<String, Object>)parsedResponse1.get('data');
                      
                      caseAnnexRecord.cx_ln_Current_Remaining_principal_amount__c = (Decimal)data.get('currentRemainingPrincipalAmount');
                      caseAnnexRecord.cx_ln_Current_Accrued_interest_amount__c = (Decimal)data.get('currentAccruedInterestAmount');
                      caseAnnexRecord.PartialRepaymentFee__c = (Decimal)data.get('currentPartialSettlementFee');
                      caseAnnexRecord.cx_ln_Early_Settlement_fee_VAT__c = (Decimal)data.get('currentPartialSettlementFeeVAT');
                      caseAnnexRecord.cc_ln_Early_Settlement_fee_VAT_inclusive__c = (Decimal)data.get('currentPartialSettlementFeeFull');
                      caseAnnexRecord.cx_Current_Remaining_administration_fee__c = (Decimal)data.get('currentRemainingAdminFee');
                      caseAnnexRecord.cx_Current_RemainingAdministrationFeeVAT__c = (Decimal)data.get('currentRemainingAdminFeeVAT');
                      caseAnnexRecord.cx_Full_Remaining_administration_fee__c = (Decimal)data.get('currentRemainingAdminFeeFull');
                      caseAnnexRecord.cx_Current_Late_payment_charges__c = (Decimal)data.get('currentLatePaymentCharges');
                      caseAnnexRecord.cx_Current_Late_payment_charges_VAT__c = (Decimal)data.get('currentLatePaymentChargesVAT');
                      caseAnnexRecord.cx_Full_late_payment_charges_VAT_inlu__c = (Decimal)data.get('currentLatePaymentChargesFull');
                      caseAnnexRecord.cx_Insurance_amount_assessment__c = (Decimal)data.get('currentInsuranceAmount');
                      Date maturityDate = Date.valueOf(String.valueOf(data.get('currentMaturityDate')));
                      caseAnnexRecord.cx_ln_Requested_Maturity_Date__c = maturityDate ;
                      caseAnnexRecord.cx_Total_Payoff_amount__c = (Decimal)data.get('totalPayoffAmount');
                      
                  }
                } 
                else if((caseObj.Sub_Type__c == 'Restructuring' && caseObj.RecordType_DeveloperName__c == 'LoanFinanceServiceRequest')){
                   String regionName = caseObj.Region_Flag__c;
                   if (caseObj.Case_Model__c == 'alburaq') {
                       regionName += '_alburaq';
                   }
                   //HTTP Callout to get Partial settlement Details
                   HttpRequest request1 = con.createRequest('GET', '/api/v1/loans/fac-reschedule-details/' + caseObj.cc_PCI_Id__c,regionName);
                   system.debug('customerId : '+ caseObj.Customer_CIF__c);
                   request1.setHeader('customerId', caseObj.Customer_CIF__c);
                   request1.setTimeout(60000);
                   HttpResponse response1 = Loans_ServiceApiCallsEM.getLoanPartialSettlementDetailsAPI(request1,200);//real api call
                   // HttpResponse response1 = new Loans_ServiceApiCallsMock().getLoanPartialSettlementDetailsAPI(request1,200);
      
                   System.debug('getLoanDetailsAPI fac-reschedule-details  response : '+ response1 );
                   System.debug('getLoanDetailsAPI fac-reschedule-details response Body : '+ response1.getBody() );
                   
                   lstSA.add(SM001_ApiCalls.setSystemAction( request1.getBody(),response1.getBody(),
                                                       request1.getEndpoint(),request1.getMethod(),
                                                       caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response1.getStatusCode(), 
                                                       caseObj.Type+'-- Get Loan fac-reschedule-details API', caseObj.Type
                                                   ));
                   if(response1.getStatusCode() != 200 ){
                       System.debug('Invalid getLoanDetailsAPI fac-reschedule-details Request Status API after insert');
                       caseObj.Last_Api_Call_Status__c = 'Failed';
                       
                   }else{
                       caseObj.Last_Api_Call_Status__c = 'Success';
                       
                       Map<String, Object> parsedResponse1 = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                       Map<String, Object> data = (Map<String, Object>)parsedResponse1.get('data');
                       
                       caseAnnexRecord.cx_ln_Current_Remaining_principal_amount__c = (Decimal)data.get('currentRemainingPrincipalAmount');
                       caseAnnexRecord.cx_ln_Current_Accrued_interest_amount__c = (Decimal)data.get('currentAccruedInterestAmount');
                       caseAnnexRecord.PartialRepaymentFee__c = (Decimal)data.get('currentPartialSettlementFee');
                       caseAnnexRecord.cx_ln_Early_Settlement_fee_VAT__c = (Decimal)data.get('currentPartialSettlementFeeVAT');
                       caseAnnexRecord.cc_ln_Early_Settlement_fee_VAT_inclusive__c = (Decimal)data.get('currentPartialSettlementFeeFull');
                       caseAnnexRecord.cx_Current_Remaining_administration_fee__c = (Decimal)data.get('currentRemainingAdminFee');
                       caseAnnexRecord.cx_Current_RemainingAdministrationFeeVAT__c = (Decimal)data.get('currentRemainingAdminFeeVAT');
                       caseAnnexRecord.cx_Full_Remaining_administration_fee__c = (Decimal)data.get('currentRemainingAdminFeeFull');
                       caseAnnexRecord.cx_Current_Late_payment_charges__c = (Decimal)data.get('currentLatePaymentCharges');
                       caseAnnexRecord.cx_Current_Late_payment_charges_VAT__c = (Decimal)data.get('currentLatePaymentChargesVAT');
                       caseAnnexRecord.cx_Full_late_payment_charges_VAT_inlu__c = (Decimal)data.get('currentLatePaymentChargesFull');
                       caseAnnexRecord.cx_Insurance_amount_assessment__c = (Decimal)data.get('currentInsuranceAmount');
                       Date maturityDate = Date.valueOf(String.valueOf(data.get('currentMaturityDate')));
                       caseAnnexRecord.cx_ln_Requested_Maturity_Date__c = maturityDate ;
                       caseAnnexRecord.cx_Total_Payoff_amount__c = (Decimal)data.get('totalPayoffAmount');
                       
                   }
                }
                else if((caseObj.Sub_Type__c == 'Instalment Deferment / Postponement' && caseObj.RecordType_DeveloperName__c == 'LoanFinanceServiceRequest')){
                    String regionName = caseObj.Region_Flag__c;
                    if (caseObj.Case_Model__c == 'alburaq') {
                        regionName += '_alburaq';
                    }
                    //HTTP Callout to get Partial settlement Details
                    HttpRequest request1 = con.createRequest('GET', '/api/v1/loans/deferment-details/' + caseObj.cc_PCI_Id__c,regionName);
                    system.debug('customerId : '+ caseObj.Customer_CIF__c);
                    request1.setHeader('customerId', caseObj.Customer_CIF__c);
                    request1.setTimeout(60000);
                    HttpResponse response1 = Loans_ServiceApiCallsEM.getLoanPartialSettlementDetailsAPI(request1,200);//real api call
                    // HttpResponse response1 = new Loans_ServiceApiCallsMock().getLoanPartialSettlementDetailsAPI(request1,200);
       
                    System.debug('getLoanDetailsAPI fac-reschedule-details  response : '+ response1 );
                    System.debug('getLoanDetailsAPI fac-reschedule-details response Body : '+ response1.getBody() );
                    
                    lstSA.add(SM001_ApiCalls.setSystemAction( request1.getBody(),response1.getBody(),
                                                        request1.getEndpoint(),request1.getMethod(),
                                                        caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response1.getStatusCode(), 
                                                        caseObj.Type+'-- Get Loan fac-reschedule-details API', caseObj.Type
                                                    ));
                    if(response1.getStatusCode() != 200 ){
                        System.debug('Invalid getLoanDetailsAPI fac-reschedule-details Request Status API after insert');
                        caseObj.Last_Api_Call_Status__c = 'Failed';
                        
                    }else{
                        caseObj.Last_Api_Call_Status__c = 'Success';
                        
                        Map<String, Object> parsedResponse1 = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                        Map<String, Object> data = (Map<String, Object>)parsedResponse1.get('data');
                        caseAnnexRecord.PartialRepaymentFee__c = (Decimal)data.get('defermentFee');
                        caseAnnexRecord.cx_ln_Early_Settlement_fee_VAT__c = (Decimal)data.get('defermentFeeVAT');
                        caseAnnexRecord.cc_ln_Early_Settlement_fee_VAT_inclusive__c = (Decimal)data.get('defermentFeeFull');
                    }
                }
           }

           upsert caseAnnexRecord;
           update caseObj;
           if(lstSA != null && lstSA.size()>0){
               insert lstSA;
           }
           
        } else {
            System.debug('Case Record or Related CaseAnnex__c Record Does Not Exist');
        }
    }
    
    // omar start
     @AuraEnabled
    public static void syncForm(String caseId, String LoanId, Map<Object, Object> loanObj) {

    
        System.debug('test refresh APi !!! '+ caseId);
                            
        CaseAnnex__c caseAnnexRecord;
        List<Case> cases = new List<Case>();
        if (caseId != null) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            
            String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,Account.ID_Type__pc,Account.ID_Number__pc,Account.ID_Expiry_Date__pc,CaseAnnex__r.cx_ln_Approved_Loan_Amount__c FROM Case WHERE Id = :caseId';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        }
        Case caseObj = cases[0];
        
        //List<CaseAnnex__c> caseAnnexList = [SELECT Id, Case__c, Case__r.Sub_Type__c, TotalTopUpAmount__c, TotalNumberOfInstallments__c, Early_Settlement_Reason__c FROM CaseAnnex__c WHERE Case__c = :caseId LIMIT 1];
        
        if (caseObj.CaseAnnex__c != null) {
            caseAnnexRecord = new CaseAnnex__c(id=caseObj.CaseAnnex__c);
            System.debug('Retrieved Case Record: ' + caseAnnexRecord);
        } 
        else {
            caseAnnexRecord = new CaseAnnex__c(Case__c = caseId);
        }

        // set field values for the caseAnnex based on submitForm 
        List<RecordType> recTypeList = [SELECT DeveloperName, Id ,SobjectType FROM RecordType WHERE  DeveloperName ='LoanFinanceServiceRequest' and SobjectType ='CaseAnnex__c'];
        if(recTypeList!=null &&recTypeList.size() > 0){
            caseAnnexRecord.RecordTypeId=recTypeList[0].Id;
        }

     
        System.debug('Case annex Record: ' + caseAnnexRecord);

    
        System.debug('Case Record: ' + caseAnnexRecord);
    
        if (caseAnnexRecord != null) {
            System.debug('CaseAnnex__c Record Exist');
    
         
            
        if (String.isBlank(LoanId)) {
            LoanId = caseObj.cc_PCI_Id__c;
        }

        if (loanObj != null) {
            Decimal currentLoanInstallment = (Decimal) loanObj.get('monthlyInstallment'); 
            caseAnnexRecord.cx_ln_Requested_Loan_Finance_Amount__c = currentLoanInstallment;
        }

        System.debug('CaseAnnex__c Record Upserted Successfully');
        caseObj.cc_PCI_Id__c = LoanId;

        if (loanObj != null) {
            String transactProduct = (String) loanObj.get('transactProduct'); 
            String ac_currency = (String) loanObj.get('currency'); 
            caseObj.Card_Product_Configuration_Id__c = transactProduct;
            caseObj.ac_Currency__c = ac_currency;
        }
           
           
           //call api after submit based on type and sub-type
           if(caseObj.isSubmitted__c){
              
                
                if(caseObj.Sub_Type__c == 'Early Settlement' && caseObj.RecordType_DeveloperName__c == 'LoanFinanceServiceRequest'){
              
                  String regionName = caseObj.Region_Flag__c;
                  if (caseObj.Case_Model__c == 'alburaq') {
                      regionName += '_alburaq';
                  }
                  //HTTP Callout to get Early settlement Details
                  HttpRequest request1 = con.createRequest('GET', '/api/v1/loans/early-settlement-details/' + caseObj.cc_PCI_Id__c,regionName);
                  system.debug('customerId : '+ caseObj.Customer_CIF__c);
                  request1.setHeader('customerId', caseObj.Customer_CIF__c);
                  request1.setTimeout(60000);
                  HttpResponse response1 = Loans_ServiceApiCallsEM.getLoanEarlySettlementDetailsAPI(request1,200);//real api call
                  // HttpResponse response1 = new Loans_ServiceApiCallsMock().getLoanEarlySettlementDetailsAPI(request1,200);

                  System.debug('getLoanEarlySettlementDetailsAPI response : '+ response1 );
                  System.debug('getLoanEarlySettlementDetailsAPI response Body : '+ response1.getBody() );

                  lstSA.add(SM001_ApiCalls.setSystemAction( request1.getBody(),response1.getBody(),
                                                      request1.getEndpoint(),request1.getMethod(),
                                                      caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response1.getStatusCode(), 
                                                      caseObj.Type+'-- getLoanEarlySettlementSetails API', caseObj.Type
                                                  ));
                  if(response1.getStatusCode() != 200 ){
                      System.debug('Invalid getLoanEarlySettlementDetailsAPI Request Status API after insert');
                      caseObj.Last_Api_Call_Status__c = 'Failed';
                      
                  }else{
                      caseObj.Last_Api_Call_Status__c = 'Success';

                      Map<String, Object> parsedResponse1 = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                      Map<String, Object> data = (Map<String, Object>)parsedResponse1.get('data');

                      caseAnnexRecord.EarlyRepaymentFee__c = (Decimal)data.get('earlySettlementFee');
                      caseAnnexRecord.cx_ln_Early_Settlement_fee_VAT__c = (Decimal)data.get('earlySettlementFeeVAT');
                      caseAnnexRecord.cc_ln_Early_Settlement_fee_VAT_inclusive__c = (Decimal)data.get('earlySettlementFeeFull');
                      caseAnnexRecord.cx_ln_Current_Remaining_principal_amount__c = (Decimal)data.get('remainingPrincipalAmount');
                      caseAnnexRecord.cx_ln_Current_Accrued_interest_amount__c = (Decimal)data.get('accruedInterestAmount');
                      caseAnnexRecord.cx_Current_Remaining_administration_fee__c = (Decimal)data.get('remainingAdminFee');
                      caseAnnexRecord.cx_Current_RemainingAdministrationFeeVAT__c = (Decimal)data.get('remainingAdminFeeVAT');
                      caseAnnexRecord.cx_Full_Remaining_administration_fee__c = (Decimal)data.get('remainingAdminFeeFull');
                      caseAnnexRecord.cx_Current_Late_payment_charges__c = (Decimal)data.get('latePaymentCharges');
                      caseAnnexRecord.cx_Current_Late_payment_charges_VAT__c = (Decimal)data.get('latePaymentChargesVAT');
                      caseAnnexRecord.cx_Full_late_payment_charges_VAT_inlu__c = (Decimal)data.get('latePaymentChargesFull');
                      caseAnnexRecord.cx_Insurance_amount_assessment__c = (Decimal)data.get('insuranceAmount');
                      Date maturityDate = Date.valueOf(String.valueOf(data.get('currentMaturityDate')));
                      caseAnnexRecord.cx_ln_Requested_Maturity_Date__c = maturityDate ;
                      caseAnnexRecord.cx_Total_Payoff_amount__c = (Decimal)data.get('totalPayoffAmount');
                  }
                } 
                else if((caseObj.Sub_Type__c == 'Partial Settlement' && caseObj.RecordType_DeveloperName__c == 'LoanFinanceServiceRequest')){

                  String regionName = caseObj.Region_Flag__c;
                  if (caseObj.Case_Model__c == 'alburaq') {
                      regionName += '_alburaq';
                  }
                  //HTTP Callout to get Partial settlement Details
                  HttpRequest request1 = con.createRequest('GET', '/api/v1/loans/partial-settlement-details/' + caseObj.cc_PCI_Id__c +'/'+caseObj.CaseAnnex__r.cx_ln_Approved_Loan_Amount__c,regionName); //System.Label.CC_EndPointCreditCardRequest
                  system.debug('customerId : '+ caseObj.Customer_CIF__c);
                  request1.setHeader('customerId', caseObj.Customer_CIF__c);
                  request1.setTimeout(60000);
                  HttpResponse response1 = Loans_ServiceApiCallsEM.getLoanPartialSettlementDetailsAPI(request1,200);//real api call
                  // HttpResponse response1 = new Loans_ServiceApiCallsMock().getLoanPartialSettlementDetailsAPI(request1,200);

                  System.debug('getLoanPartialSettlementDetailsAPI response : '+ response1 );
                  System.debug('getLoanPartialSettlementDetailsAPI response Body : '+ response1.getBody() );
                  
                  lstSA.add(SM001_ApiCalls.setSystemAction( request1.getBody(),response1.getBody(),
                                                      request1.getEndpoint(),request1.getMethod(),
                                                      caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response1.getStatusCode(), 
                                                      caseObj.Type+'-- getLoanPartialSettlementSetails API', caseObj.Type
                                                  ));
                  if(response1.getStatusCode() != 200 ){
                      System.debug('Invalid getLoanPartialSettlementDetailsAPI Request Status API after insert');
                      caseObj.Last_Api_Call_Status__c = 'Failed';
                      
                  }else{
                      caseObj.Last_Api_Call_Status__c = 'Success';
                      
                      Map<String, Object> parsedResponse1 = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                      Map<String, Object> data = (Map<String, Object>)parsedResponse1.get('data');
                      
                      caseAnnexRecord.cx_ln_Current_Remaining_principal_amount__c = (Decimal)data.get('currentRemainingPrincipalAmount');
                      caseAnnexRecord.cx_ln_Current_Accrued_interest_amount__c = (Decimal)data.get('currentAccruedInterestAmount');
                      caseAnnexRecord.PartialRepaymentFee__c = (Decimal)data.get('currentPartialSettlementFee');
                      caseAnnexRecord.cx_ln_Early_Settlement_fee_VAT__c = (Decimal)data.get('currentPartialSettlementFeeVAT');
                      caseAnnexRecord.cc_ln_Early_Settlement_fee_VAT_inclusive__c = (Decimal)data.get('currentPartialSettlementFeeFull');
                      caseAnnexRecord.cx_Current_Remaining_administration_fee__c = (Decimal)data.get('currentRemainingAdminFee');
                      caseAnnexRecord.cx_Current_RemainingAdministrationFeeVAT__c = (Decimal)data.get('currentRemainingAdminFeeVAT');
                      caseAnnexRecord.cx_Full_Remaining_administration_fee__c = (Decimal)data.get('currentRemainingAdminFeeFull');
                      caseAnnexRecord.cx_Current_Late_payment_charges__c = (Decimal)data.get('currentLatePaymentCharges');
                      caseAnnexRecord.cx_Current_Late_payment_charges_VAT__c = (Decimal)data.get('currentLatePaymentChargesVAT');
                      caseAnnexRecord.cx_Full_late_payment_charges_VAT_inlu__c = (Decimal)data.get('currentLatePaymentChargesFull');
                      caseAnnexRecord.cx_Insurance_amount_assessment__c = (Decimal)data.get('currentInsuranceAmount');
                      Date maturityDate = Date.valueOf(String.valueOf(data.get('currentMaturityDate')));
                      caseAnnexRecord.cx_ln_Requested_Maturity_Date__c = maturityDate ;
                      caseAnnexRecord.cx_Total_Payoff_amount__c = (Decimal)data.get('totalPayoffAmount');
                      
                  }
                } 
                else if((caseObj.Sub_Type__c == 'Top-up' && caseObj.RecordType_DeveloperName__c == 'LoanFinanceServiceRequest')){
                  String regionName = caseObj.Region_Flag__c;
                  if (caseObj.Case_Model__c == 'alburaq') {
                      regionName += '_alburaq';
                  }
                  //HTTP Callout to get Partial settlement Details
                  HttpRequest request1 = con.createRequest('GET', '/api/v1/loans/loan-top-up-details/' + caseObj.cc_PCI_Id__c,regionName);
                  system.debug('customerId : '+ caseObj.Customer_CIF__c);
                  request1.setHeader('customerId', caseObj.Customer_CIF__c);
                  request1.setTimeout(60000);
                  HttpResponse response1 = Loans_ServiceApiCallsEM.getLoanPartialSettlementDetailsAPI(request1,200);//real api call
                  // HttpResponse response1 = new Loans_ServiceApiCallsMock().getLoanPartialSettlementDetailsAPI(request1,200);
     
                  System.debug('getLoanDetailsAPI loan-top-up-details  response : '+ response1 );
                  System.debug('getLoanDetailsAPI loan-top-up-details response Body : '+ response1.getBody() );
                  
                  lstSA.add(SM001_ApiCalls.setSystemAction( request1.getBody(),response1.getBody(),
                                                      request1.getEndpoint(),request1.getMethod(),
                                                      caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response1.getStatusCode(), 
                                                      caseObj.Type+'-- Get Loan loan-top-up-details API', caseObj.Type
                                                  ));
                  if(response1.getStatusCode() != 200 ){
                      System.debug('Invalid getLoanDetailsAPI loan-top-up-details Request Status API after insert');
                      caseObj.Last_Api_Call_Status__c = 'Failed';
                      
                  }else{
                      caseObj.Last_Api_Call_Status__c = 'Success';
                      
                      Map<String, Object> parsedResponse1 = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                      Map<String, Object> data = (Map<String, Object>)parsedResponse1.get('data');
                      
                      caseAnnexRecord.cx_ln_Current_Remaining_principal_amount__c = (Decimal)data.get('currentRemainingPrincipalAmount');
                      caseAnnexRecord.cx_ln_Current_Accrued_interest_amount__c = (Decimal)data.get('currentAccruedInterestAmount');
                      caseAnnexRecord.PartialRepaymentFee__c = (Decimal)data.get('currentPartialSettlementFee');
                      caseAnnexRecord.cx_ln_Early_Settlement_fee_VAT__c = (Decimal)data.get('currentPartialSettlementFeeVAT');
                      caseAnnexRecord.cc_ln_Early_Settlement_fee_VAT_inclusive__c = (Decimal)data.get('currentPartialSettlementFeeFull');
                      caseAnnexRecord.cx_Current_Remaining_administration_fee__c = (Decimal)data.get('currentRemainingAdminFee');
                      caseAnnexRecord.cx_Current_RemainingAdministrationFeeVAT__c = (Decimal)data.get('currentRemainingAdminFeeVAT');
                      caseAnnexRecord.cx_Full_Remaining_administration_fee__c = (Decimal)data.get('currentRemainingAdminFeeFull');
                      caseAnnexRecord.cx_Current_Late_payment_charges__c = (Decimal)data.get('currentLatePaymentCharges');
                      caseAnnexRecord.cx_Current_Late_payment_charges_VAT__c = (Decimal)data.get('currentLatePaymentChargesVAT');
                      caseAnnexRecord.cx_Full_late_payment_charges_VAT_inlu__c = (Decimal)data.get('currentLatePaymentChargesFull');
                      caseAnnexRecord.cx_Insurance_amount_assessment__c = (Decimal)data.get('currentInsuranceAmount');
                      Date maturityDate = Date.valueOf(String.valueOf(data.get('currentMaturityDate')));
                      caseAnnexRecord.cx_ln_Requested_Maturity_Date__c = maturityDate ;
                      caseAnnexRecord.cx_Total_Payoff_amount__c = (Decimal)data.get('totalPayoffAmount');
                      
                  }
                } 
                else if((caseObj.Sub_Type__c == 'Restructuring' && caseObj.RecordType_DeveloperName__c == 'LoanFinanceServiceRequest')){
                   String regionName = caseObj.Region_Flag__c;
                   if (caseObj.Case_Model__c == 'alburaq') {
                       regionName += '_alburaq';
                   }
                   //HTTP Callout to get Partial settlement Details
                   HttpRequest request1 = con.createRequest('GET', '/api/v1/loans/fac-reschedule-details/' + caseObj.cc_PCI_Id__c,regionName);
                   system.debug('customerId : '+ caseObj.Customer_CIF__c);
                   request1.setHeader('customerId', caseObj.Customer_CIF__c);
                   request1.setTimeout(60000);
                   HttpResponse response1 = Loans_ServiceApiCallsEM.getLoanPartialSettlementDetailsAPI(request1,200);//real api call
                   // HttpResponse response1 = new Loans_ServiceApiCallsMock().getLoanPartialSettlementDetailsAPI(request1,200);
      
                   System.debug('getLoanDetailsAPI fac-reschedule-details  response : '+ response1 );
                   System.debug('getLoanDetailsAPI fac-reschedule-details response Body : '+ response1.getBody() );
                   
                   lstSA.add(SM001_ApiCalls.setSystemAction( request1.getBody(),response1.getBody(),
                                                       request1.getEndpoint(),request1.getMethod(),
                                                       caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response1.getStatusCode(), 
                                                       caseObj.Type+'-- Get Loan fac-reschedule-details API', caseObj.Type
                                                   ));
                   if(response1.getStatusCode() != 200 ){
                       System.debug('Invalid getLoanDetailsAPI fac-reschedule-details Request Status API after insert');
                       caseObj.Last_Api_Call_Status__c = 'Failed';
                       
                   }else{
                       caseObj.Last_Api_Call_Status__c = 'Success';
                       
                       Map<String, Object> parsedResponse1 = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                       Map<String, Object> data = (Map<String, Object>)parsedResponse1.get('data');
                       
                       caseAnnexRecord.cx_ln_Current_Remaining_principal_amount__c = (Decimal)data.get('currentRemainingPrincipalAmount');
                       caseAnnexRecord.cx_ln_Current_Accrued_interest_amount__c = (Decimal)data.get('currentAccruedInterestAmount');
                       caseAnnexRecord.PartialRepaymentFee__c = (Decimal)data.get('currentPartialSettlementFee');
                       caseAnnexRecord.cx_ln_Early_Settlement_fee_VAT__c = (Decimal)data.get('currentPartialSettlementFeeVAT');
                       caseAnnexRecord.cc_ln_Early_Settlement_fee_VAT_inclusive__c = (Decimal)data.get('currentPartialSettlementFeeFull');
                       caseAnnexRecord.cx_Current_Remaining_administration_fee__c = (Decimal)data.get('currentRemainingAdminFee');
                       caseAnnexRecord.cx_Current_RemainingAdministrationFeeVAT__c = (Decimal)data.get('currentRemainingAdminFeeVAT');
                       caseAnnexRecord.cx_Full_Remaining_administration_fee__c = (Decimal)data.get('currentRemainingAdminFeeFull');
                       caseAnnexRecord.cx_Current_Late_payment_charges__c = (Decimal)data.get('currentLatePaymentCharges');
                       caseAnnexRecord.cx_Current_Late_payment_charges_VAT__c = (Decimal)data.get('currentLatePaymentChargesVAT');
                       caseAnnexRecord.cx_Full_late_payment_charges_VAT_inlu__c = (Decimal)data.get('currentLatePaymentChargesFull');
                       caseAnnexRecord.cx_Insurance_amount_assessment__c = (Decimal)data.get('currentInsuranceAmount');
                       Date maturityDate = Date.valueOf(String.valueOf(data.get('currentMaturityDate')));
                       caseAnnexRecord.cx_ln_Requested_Maturity_Date__c = maturityDate ;
                       caseAnnexRecord.cx_Total_Payoff_amount__c = (Decimal)data.get('totalPayoffAmount');
                       
                   }
                }
                else if((caseObj.Sub_Type__c == 'Instalment Deferment / Postponement' && caseObj.RecordType_DeveloperName__c == 'LoanFinanceServiceRequest')){
                    String regionName = caseObj.Region_Flag__c;
                    if (caseObj.Case_Model__c == 'alburaq') {
                        regionName += '_alburaq';
                    }
                    //HTTP Callout to get Partial settlement Details
                    HttpRequest request1 = con.createRequest('GET', '/api/v1/loans/deferment-details/' + caseObj.cc_PCI_Id__c,regionName);
                    system.debug('customerId : '+ caseObj.Customer_CIF__c);
                    request1.setHeader('customerId', caseObj.Customer_CIF__c);
                    request1.setTimeout(60000);
                    HttpResponse response1 = Loans_ServiceApiCallsEM.getLoanPartialSettlementDetailsAPI(request1,200);//real api call
                    // HttpResponse response1 = new Loans_ServiceApiCallsMock().getLoanPartialSettlementDetailsAPI(request1,200);
       
                    System.debug('getLoanDetailsAPI fac-reschedule-details  response : '+ response1 );
                    System.debug('getLoanDetailsAPI fac-reschedule-details response Body : '+ response1.getBody() );
                    
                    lstSA.add(SM001_ApiCalls.setSystemAction( request1.getBody(),response1.getBody(),
                                                        request1.getEndpoint(),request1.getMethod(),
                                                        caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response1.getStatusCode(), 
                                                        caseObj.Type+'-- Get Loan fac-reschedule-details API', caseObj.Type
                                                    ));
                    if(response1.getStatusCode() != 200 ){
                        System.debug('Invalid getLoanDetailsAPI fac-reschedule-details Request Status API after insert');
                        caseObj.Last_Api_Call_Status__c = 'Failed';
                        
                    }else{
                        caseObj.Last_Api_Call_Status__c = 'Success';
                        
                        Map<String, Object> parsedResponse1 = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                        Map<String, Object> data = (Map<String, Object>)parsedResponse1.get('data');
                        caseAnnexRecord.PartialRepaymentFee__c = (Decimal)data.get('defermentFee');
                        caseAnnexRecord.cx_ln_Early_Settlement_fee_VAT__c = (Decimal)data.get('defermentFeeVAT');
                        caseAnnexRecord.cc_ln_Early_Settlement_fee_VAT_inclusive__c = (Decimal)data.get('defermentFeeFull');
                    }
                }
           }

           upsert caseAnnexRecord;
           update caseObj;
           if(lstSA != null && lstSA.size()>0){
               insert lstSA;
           }
           
        } else {
            System.debug('Case Record or Related CaseAnnex__c Record Does Not Exist');
        }
    }
    // omar end 
    @AuraEnabled(cacheable=false)
    public static Loans_ServiceManagerHandler.APIResponse getPaymentList(final String customerId , String searchParametersJson, String regionName) {
        System.debug('Customer ID HandOffProcessController.getPaymentList ' +customerId + ' ... searchParametersJson  '+ searchParametersJson);
        
        Loans_ServiceManagerHandler.APIResponse response = Loans_ServiceManagerHandler.callGetLoanPaymentsSchedule(null,customerId, searchParametersJson, regionName,false);
        
        System.debug('Response object:'+response);

        return response;
    }
}