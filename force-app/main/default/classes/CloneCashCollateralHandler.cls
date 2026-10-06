/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 13-01-2022
*       Change History: 
*          #CH01# #Jahangeer Mohammed# #26-04-2022# Added Logic to populate user for Cash Collateral Application. 
*          #CH02# #Jahangeer Mohammed# #15-05-2022# Added extra brackets in If condition for Decline & Cancelled by Customer(PI-1564)
*          #CH03# #Jahangeer Mohammed #28-06-2022# Added Logic to Populate CPR Number & CPR Expiry(NBA-5692 & NBA-5693)
*          #CH04# #Jahangeer Mohammed# #15-08-2022# Added Logic to Populate Approved Campaign Name as per ticket(NBA-5719)
*          #CH05# #Jahangeer Mohammed# #08-09-2022# Added Logic for Cash Collateral Limit Increase Application(NBA-6043)
*		   #CH06# #Jahangeer Mohammed# #21-11-2022# Added Logic for Cancelled by Customer for Cash Collateral Limit Increase Process(NBA-6559)
* 		   #CH07# #Jahangeer Mohammed# #10-04-2023# Restrict Cash Collateral Applications to Bahrain Region
		   #CH08# #Jayanth Manickam #04-05-2023# Jordan CashCollteral Limit Increase Application 

*/
public class CloneCashCollateralHandler {
    
    public static void handlerAfterCaseUpdate(List<Case> lstCase){
        Set<Id> setCashCollateralCaseAcceptByPrescreener = new Set<Id>();
        Set<Id> setCashCollateralCaseDiscrepancyByPrescreener = new Set<Id>();
        Set<Id> setCashCollateralCaseReferToServiceCenterByPrescreener = new Set<Id>();
        Set<Id> setCashCollateralCaseReturnToPrescreenerByServiceCenter = new Set<Id>();
        Set<Id> setCashCollateralCaseApprovedByApprover = new Set<Id>();
        Set<Id> setCashCollateralCaseReferToServiceCenterByApprover = new Set<Id>();
        Set<Id> setCashCollateralCaseReturnToApproverByServiceCenter = new Set<Id>();
        Set<Id> setCashCollateralCaseAcceptBySignatureVerifierForNonBalanceTransfer = new Set<Id>();
        Set<Id> setCashCollateralCaseAcceptBySignatureVerifierForBalanceTransfer = new Set<Id>();
        Set<Id> setCashCollateralCaseResendBySignatureVerifier = new Set<Id>();
        Set<Id> setCashCollateralCaseReferToServiceCenterBySignatureVerifier = new Set<Id>();
        Set<Id> setCashCollateralCaseReturnToSignatureVerifierByServiceCenter = new Set<Id>(); 
        Set<Id> setCashCollateralCaseAcceptByHRForNonBalanceTransfer = new Set<Id>();
        Set<Id> setCashCollateralCaseAcceptByHRForBalanceTransfer = new Set<Id>();
        Set<Id> setCashCollateralCaseDecline = new Set<Id>();
        Set<Id> setCashCollateralCaseCancelledByCustomer = new Set<Id>();
        Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();
        //CH03: Start
        Map<Id,Id> mapCasetoAccount = new Map<Id,Id>();
        Map<Id,Id> mapCasetoAccountHR = new Map<Id,Id>();
        //CH03: END
        //CH05: Start
        Set<Id> setCashCollateralLimitIncreaseCaseAcceptByPrescreener = new Set<Id>();
        Set<Id> setCashCollateralLimitIncreaseCaseDecline = new Set<Id>();
        Set<Id> setCashCollateralLimitIncreaseCaseApprovedByApprover = new Set<Id>();
        Set<Id> setCashCollateralLimitIncreaseCaseReferToServiceCenterByApprover = new Set<Id>();
        Set<Id> setCashCollateralLimitIncreaseCaseAcceptBySignatureVerifier = new Set<Id>();
        Set<Id> setCashCollateralLimitIncreaseCaseResendBySignatureVerifier = new Set<Id>();
        set<Id> setCashCollateralLimitIncreaseCaseReturnToApproverByServiceCenter = new Set<Id>();
        set<Id> setCashCollateralLimitIncreaseCaseAcceptByHR = new Set<Id>();
        //CH05: END
        //CH06: Start
        Set<Id> setCashCollateralLimitIncreaseCaseCancelledByCustomer = new Set<Id>();
        //CH06: END
        
        for(Case caseObj : lstCase) {
            Case caseOldObj = (Case)trigger.oldMap.get(caseobj.id);
            string recordtypeName = rt_Map.get(caseObj.RecordTypeId).getName();
            if(caseObj.Sub_Status__c != caseOldObj.Sub_Status__c && caseObj.Sub_Status__c =='Discrepancies' && (caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral')){
                System.debug('Dicrepancy in Documents for Cash Collateral');
                setCashCollateralCaseDiscrepancyByPrescreener.add(caseObj.id);
            }
            
            if(caseOldObj.cc_Credit_Pre_Screening_Result__c != caseObj.cc_Credit_Pre_Screening_Result__c  && caseObj.cc_Credit_Pre_Screening_Result__c =='Accept' && 
               (caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') && (caseObj.cc_Application_Stages__c == 'Credit Pre-Screening' || caseObj.cc_Application_Stages__c == 'New'))
            {
                system.debug('----> Prescreener Accept in Cash Collateral --> '+caseObj);
                setCashCollateralCaseAcceptByPrescreener.add(caseObj.id);
            }
            //CH05: Start
            /************************************************************* Start : Credit Pre-screener Stage - Cash Collateral Limit Increase Application  *****************************************************/
            if(caseOldObj.cc_Credit_Pre_Screening_Result__c != caseObj.cc_Credit_Pre_Screening_Result__c  && caseObj.cc_Credit_Pre_Screening_Result__c =='Accept' && 
               (caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase') && (caseObj.cc_Application_Stages__c == 'Credit Pre-Screening' || caseObj.cc_Application_Stages__c == 'New'))
            {
                system.debug('----> Prescreener Accept in Cash Collateral limit Increase --> '+caseObj);
                setCashCollateralLimitIncreaseCaseAcceptByPrescreener.add(caseObj.id);
            }
            /************************************************************* END : Credit Pre-screener Stage - Cash Collateral Limit Increase Application  *****************************************************/
            //CH05: END
            
            if((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') &&
               caseObj.cc_Credit_Pre_Screening_Result__c == 'Refer to Service Center' && caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c &&
               (caseObj.cc_Application_Stages__c == 'Credit Pre-Screening' || caseObj.cc_Application_Stages__c == 'New' )){
                   System.debug('Set Cases from Pre screener Queue to Service Center in Cash Collateral');
                   setCashCollateralCaseReferToServiceCenterByPrescreener.add(caseObj.id); 
               }
            
            if(caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' &&  caseObj.cc_Credit_Approval_Result__c == 'Approve' &&
               caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Approval'){
                   System.debug('Set Cases for Signature Verification Queue From Credit Approver in Cash Collateral');
                   setCashCollateralCaseApprovedByApprover.add(caseObj.id);
               }
             //CH05: Start
            /************************************************************* Start : Credit Approver Stage - Cash Collateral Limit Increase Application  *****************************************************/
            if(caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase' &&  caseObj.cc_Credit_Approval_Result__c == 'Approve' &&
            caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c &&
            caseObj.cc_Application_Stages__c == 'Credit Approval'){
                System.debug('Set Cases for Signature Verification Queue From Credit Approver in Cash Collateral limit Increase');
                setCashCollateralLimitIncreaseCaseApprovedByApprover.add(caseObj.id);
            }
            if((caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase') &&
               caseObj.cc_Credit_Approval_Result__c == 'Refer to Service Center' &&
               caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Approval'){
                   System.debug('Set Cases for Credit Card Service Center Queue From Credit Approver in cash collateral limit Increase');
                   setCashCollateralLimitIncreaseCaseReferToServiceCenterByApprover.add(caseObj.id); 
            } 
            /************************************************************* END : Credit Approver Stage - Cash Collateral Limit Increase Application  *****************************************************/
            //CH05: END
            
            if((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') &&
               caseObj.cc_Credit_Approval_Result__c == 'Refer to Service Center' &&
               caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Approval'){
                   System.debug('Set Cases for Credit Card Service Center Queue From Credit Approver in cash collateral');
                   setCashCollateralCaseReferToServiceCenterByApprover.add(caseObj.id); 
               } 
            
            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') ) &&
               caseObj.cc_Signature_Verifier_Result__c == 'Accept' &&  caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification' && (caseObj.cc_Approved_Requested_Card_Type__c != 'PLATINUM_BALANCE_TRANSFER_01')){
                   System.debug('Set Cases for Credit Signature for ila blue/black for Cash Collateral'); 
                   setCashCollateralCaseAcceptBySignatureVerifierForNonBalanceTransfer.add(caseObj.id);
               }
             //CH05: Start
            /************************************************************ Start : Signature Verifier Stage - Cash Collateral Limit Increase Application **********************************************************/
            if(((caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase') ) &&
            caseObj.cc_Signature_Verifier_Result__c == 'Accept' &&  caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
            caseObj.cc_Application_Stages__c == 'Credit Signature Verification'){
                System.debug('Set Cases when signature verifier accepts for Cash Collateral limit increase'); 
                setCashCollateralLimitIncreaseCaseAcceptBySignatureVerifier.add(caseObj.id);
            }

            if(((caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) &&
               caseObj.cc_Signature_Verifier_Result__c == 'Re-Send' && caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification'){
                   System.debug('Set Cases Remains in for Credit Signature verifier in cash collateral limit Increase'); 
                   setCashCollateralLimitIncreaseCaseResendBySignatureVerifier.add(caseObj.id);
               }
            /************************************************************ END :  Signature Verifier Stage - Cash Collateral Limit Increase Application **********************************************************/
            //CH05: END
            
            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral')) &&
               caseObj.cc_Signature_Verifier_Result__c == 'Accept' &&  caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification' && caseObj.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' && caseObj.cc_Approved_Transfer_Type__c == 'Balance Transfer'){
                   System.debug('Set Cases for Credit Signature for ila switch Balance Transfer for cash collateral'); 
                   setCashCollateralCaseAcceptBySignatureVerifierForBalanceTransfer.add(caseObj.id);
               }
            //CH05: Added Type and Sub Type related to Cash Collateral Limit Increase in if block
            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') || (caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) &&
               caseObj.cc_Signature_Verifier_Result__c == 'Re-Send' && caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification'){
                   System.debug('Set Cases Remains in for Credit Signature verifier in cash collateral'); 
                   setCashCollateralCaseResendBySignatureVerifier.add(caseObj.id);
               }
            
            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral')) &&
               caseObj.cc_Signature_Verifier_Result__c == 'Refer to Service Center' &&
               caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification'){ 
                   System.debug('Set Cases for Credit Card Service Center Queue From Signature Verifier in cash collateral');
                   setCashCollateralCaseReferToServiceCenterBySignatureVerifier.add(caseObj.id);
               }
            
            if((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') &&
               caseObj.cc_Service_Centre_Result__c == 'Return to Pre-Screener' && caseObj.cc_Service_Centre_Result__c != caseOldObj.cc_Service_Centre_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre'){ 
                   System.debug('Set Cases Routed from Service Center to Pre-screener queue For Cash Collateral ');
                   setCashCollateralCaseReturnToPrescreenerByServiceCenter.add(caseObj.id);
               }
            
            if((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') &&
               caseObj.cc_Service_Centre_Result__c == 'Return to Approver' &&
               caseObj.cc_Service_Centre_Result__c != caseOldObj.cc_Service_Centre_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre'){ 
                   System.debug('Set Cases Routed from Service Center to Approval queue for cash collateral');
                   setCashCollateralCaseReturnToApproverByServiceCenter.add(caseObj.id);
               }
              //CH05: Start
            /************************************************************* Start : Credit Service Center Stage - Cash Collateral Limit Increase Application  *****************************************************/
            if((caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase') &&
               caseObj.cc_Service_Centre_Result__c == 'Return to Approver' &&
               caseObj.cc_Service_Centre_Result__c != caseOldObj.cc_Service_Centre_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre'){ 
                   System.debug('Set Cases Routed from Service Center to Approval queue for cash collateral limit increase');
                   setCashCollateralLimitIncreaseCaseReturnToApproverByServiceCenter.add(caseObj.id);
               }
           /************************************************************* END : Credit Service Center Stage - Cash Collateral Limit Increase Application  *****************************************************/
            //CH05: END
            
            if((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') &&
               caseObj.cc_Service_Centre_Result__c == 'Return to Signature Verifier' && caseObj.cc_Service_Centre_Result__c != caseOldObj.cc_Service_Centre_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre'){ 
                   System.debug('Set Cases Routed from Service Center to Signature Verification queue in cash collateral');
                   setCashCollateralCaseReturnToSignatureVerifierByServiceCenter.add(caseObj.id);
               }
            
            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral')) && 
               recordtypeName == 'Credit Card Cash Collateral Staff' &&         
               (caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && caseObj.cc_HR_Result__c =='Approved') && caseObj.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' && caseObj.cc_Approved_Transfer_Type__c == 'Balance Transfer')  
            {
                System.debug('Set Cases for HR Approval Balance Transfer in cash collateral'); 
                setCashCollateralCaseAcceptByHRForBalanceTransfer.add(caseObj.id);
            }
            
            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral')) && 
               recordtypeName == 'Credit Card Cash Collateral Staff' &&         
               (caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && caseObj.cc_HR_Result__c =='Approved') && caseObj.cc_Approved_Requested_Card_Type__c != 'PLATINUM_BALANCE_TRANSFER_01' && caseObj.cc_Approved_Requested_Card_Type__c != '')  
            {
                System.debug('Set Cases for HR Approval Non Balance Transfer for Cash Collateral'); 
                setCashCollateralCaseAcceptByHRForNonBalanceTransfer.add(caseObj.id);
            }
            //CH05: Start
            if(caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && recordtypeName == 'Cash Collateral Credit Limit Increase Staff' &&
               caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && caseObj.cc_HR_Result__c =='Approved')
            {
                System.debug('Set Cases for HR Approval in Cash Collateral Credit Limit Update');
                setCashCollateralLimitIncreaseCaseAcceptByHR.add(caseObj.id);
            }
            //CH05: END
            //CH02: Added extra brackets in if condition to avoid multiple future calls.
            if((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') && 
               ((caseObj.cc_CEO_Result__c != caseOldObj.cc_CEO_Result__c && caseObj.cc_CEO_Result__c == 'Decline') ||
               (caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c && caseObj.cc_Credit_Approval_Result__c =='Decline') || 
               (caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && caseObj.cc_HR_Result__c =='Decline') || 
               (caseObj.cc_Business_Approval_Result__c != caseOldObj.cc_Business_Approval_Result__c && caseObj.cc_Business_Approval_Result__c =='Decline')|| 
               (caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c && caseObj.cc_Credit_Pre_Screening_Result__c =='Decline')))
            {
                System.debug('Inside Decline Condition for Cash Collateral');
                setCashCollateralCaseDecline.add(caseObj.id);
            }
             //CH05: Start
            /********************************************************* Start : Cash Collateral Limit Increase Decline Cases ****************************************************************/
            if((caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase') && ((caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c && caseObj.cc_Credit_Pre_Screening_Result__c =='Decline')
            || (caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c && caseObj.cc_Credit_Approval_Result__c =='Decline') || (caseObj.cc_Business_Approval_Result__c != caseOldObj.cc_Business_Approval_Result__c && caseObj.cc_Business_Approval_Result__c =='Decline') || (caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && caseObj.cc_HR_Result__c =='Decline'))){
                System.debug('Inside Decline Condition for Cash Collateral limit increase');
                setCashCollateralLimitIncreaseCaseDecline.add(caseObj.id);
            }
            /********************************************************* END : Cash Collateral Limit Increase Decline Cases ****************************************************************/
            //CH05: END
            //CH06: Start
            /********************************************************* Start : Cash Collateral Limit Increase Cancelled by Customer Cases ****************************************************************/
             if((caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase') && 
               ((caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c && caseObj.cc_Credit_Approval_Result__c =='Cancelled by Customer') || 
               (caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && caseObj.cc_HR_Result__c =='Cancelled by Customer') || 
               (caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c && caseObj.cc_Credit_Pre_Screening_Result__c =='Cancelled by Customer')))
            {
                System.debug('Inside CANCEL BY Customer Condition in Cash Collateral limit increase');
                setCashCollateralLimitIncreaseCaseCancelledByCustomer.add(caseObj.id);
            }
            
            /********************************************************* END : Cash Collateral Limit Increase Cancelled by Customer Cases ****************************************************************/
			//CH06: END
            //CH02: Added extra brackets in if condition to avoid multiple future calls. 
            if((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') && 
               ((caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c && caseObj.cc_Credit_Approval_Result__c =='Cancelled by Customer') || 
               (caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && caseObj.cc_HR_Result__c =='Cancelled by Customer') || 
               (caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c && caseObj.cc_Credit_Pre_Screening_Result__c =='Cancelled by Customer')))
            {
                System.debug('Inside CANCEL BY Customer Condition in Cash Collateral');
                setCashCollateralCaseCancelledByCustomer.add(caseObj.id);
            }
             //CH03: Start
            //CH05: Start #Added Cash Collateral Limit Increase Condition in If block
            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') || (caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase'))  && caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c && (caseObj.cc_Credit_Approval_Result__c == 'Approve' || caseObj.cc_Credit_Approval_Result__c == 'Decline')){
                mapCasetoAccount.put(caseObj.Id, caseObj.AccountId);
            }
             if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') || (caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) && caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && (caseObj.cc_HR_Result__c == 'Approve' || caseObj.cc_HR_Result__c == 'Decline')){
                mapCasetoAccountHR.put(caseObj.Id, caseObj.AccountId);
            }
            //CH05: END
           //CH03: END
         //CH08:START
         if((caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase') && caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && (caseObj.cc_HR_Result__c == 'Approve' || caseObj.cc_HR_Result__c == 'Decline')){
               // mapCasetoAccountHR.put(caseObj.Id, caseObj.AccountId);
            }
        //CH08:END
        }//for loop End
         //CH05: Start
        /****************************************** Start : Cash Collateral Limit Increase Application API Calls  **************************************/
        if(!setCashCollateralLimitIncreaseCaseAcceptByPrescreener.isEmpty()){
            System.debug('Testing for Future Call for Cash Collateral Limit Increase when Pre-screener accepts');
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralLimitIncreaseCaseAcceptByPrescreener);
        }
        if(!setCashCollateralLimitIncreaseCaseApprovedByApprover.isEmpty()){
            System.debug('Testing for Future Call for Cash Collateral Limit Increase when Credit Approver accepts');
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralLimitIncreaseCaseApprovedByApprover);
            if(!test.isRunningTest()){
                DocuSignApexToolKit autoSendDocSign =  new DocuSignApexToolKit(setCashCollateralLimitIncreaseCaseApprovedByApprover);
                System.enqueueJob(autoSendDocSign);
            }
        }

        if(!setCashCollateralLimitIncreaseCaseReferToServiceCenterByApprover.isEmpty()){
            System.debug('Testing for Future Call for Cash Collateral Limit Increase when Credit Approver refer to service center');
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralLimitIncreaseCaseReferToServiceCenterByApprover);
        }
        if(!setCashCollateralLimitIncreaseCaseReturnToApproverByServiceCenter.isEmpty()){
            System.debug('Testing for Future Call for Cash Collateral Limit Increase when Service Center return to credit approver');
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralLimitIncreaseCaseReturnToApproverByServiceCenter);
        }
        if(!setCashCollateralLimitIncreaseCaseAcceptBySignatureVerifier.isEmpty()){
            System.debug('Testing for Future Call for Cash Collateral Limit Increase when signature verifier accepts');
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralLimitIncreaseCaseAcceptBySignatureVerifier);
        }
        if(!setCashCollateralLimitIncreaseCaseResendBySignatureVerifier.isEmpty()){
            System.debug('Testing for Future Call for Cash Collateral Limit Increase when signature verifier re-send');
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralLimitIncreaseCaseResendBySignatureVerifier);
        }
        if(!setCashCollateralLimitIncreaseCaseAcceptByHR.isEmpty()){
            System.debug('Testing for Future Call for Cash Collateral Limit Increase when HR Approves');
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralLimitIncreaseCaseAcceptByHR);
            if(test.isRunningTest()){
                DocuSignApexToolKit autoSendDocSign =  new DocuSignApexToolKit(setCashCollateralLimitIncreaseCaseAcceptByHR);
                System.enqueueJob(autoSendDocSign);
            }
        }

        if(!setCashCollateralLimitIncreaseCaseDecline.isEmpty()){
            System.debug('Testing for Future Call for Cash Collateral Limit Increase when Pre-screener, Approver or Business Team Decline');
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralLimitIncreaseCaseDecline);
        }
        /****************************************** END : Cash Collateral Limit Increase Application API Calls  **************************************/
        //CH05: END
        if(!setCashCollateralCaseAcceptByPrescreener.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseAcceptByPrescreener);
        }
        if(!setCashCollateralCaseDiscrepancyByPrescreener.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseDiscrepancyByPrescreener);
        }
        if(!setCashCollateralCaseReferToServiceCenterByPrescreener.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseReferToServiceCenterByPrescreener);
        }
        if(!setCashCollateralCaseReturnToPrescreenerByServiceCenter.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseReturnToPrescreenerByServiceCenter);
        }
        if(!setCashCollateralCaseApprovedByApprover.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseApprovedByApprover);
            if(!test.isRunningTest()){
                DocuSignApexToolKit autoSendDocSign =  new DocuSignApexToolKit(setCashCollateralCaseApprovedByApprover);
                System.enqueueJob(autoSendDocSign);
            }
        }
        if(!setCashCollateralCaseReturnToApproverByServiceCenter.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseReturnToApproverByServiceCenter);
        }
        if(!setCashCollateralCaseReferToServiceCenterByApprover.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseReferToServiceCenterByApprover);
        }
        if(!setCashCollateralCaseAcceptBySignatureVerifierForNonBalanceTransfer.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseAcceptBySignatureVerifierForNonBalanceTransfer);
        }
        if(!setCashCollateralCaseAcceptBySignatureVerifierForBalanceTransfer.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseAcceptBySignatureVerifierForBalanceTransfer);
        }
        if(!setCashCollateralCaseResendBySignatureVerifier.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseResendBySignatureVerifier);
             if(!test.isRunningTest()){
                DocuSignApexToolKit autoSendDocSign =  new DocuSignApexToolKit(setCashCollateralCaseResendBySignatureVerifier);
                System.enqueueJob(autoSendDocSign);
            }
        }
        if(!setCashCollateralCaseReferToServiceCenterBySignatureVerifier.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseReferToServiceCenterBySignatureVerifier);
        }
        if(!setCashCollateralCaseReturnToSignatureVerifierByServiceCenter.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseReturnToSignatureVerifierByServiceCenter);
        }
        if(!setCashCollateralCaseAcceptByHRForNonBalanceTransfer.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseAcceptByHRForNonBalanceTransfer);
        }
        if(!setCashCollateralCaseAcceptByHRForBalanceTransfer.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseAcceptByHRForBalanceTransfer);
        }
        if(!setCashCollateralCaseDecline.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseDecline);
        }
        if(!setCashCollateralCaseCancelledByCustomer.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseCancelledByCustomer);
        }
        //CH06: Start
        if(!setCashCollateralLimitIncreaseCaseCancelledByCustomer.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralLimitIncreaseCaseCancelledByCustomer);
        }
        //CH06: END
        //CH03: Start
        if(!mapCasetoAccount.isEmpty())
        {
            creditCardCustomerProfileUpdate.updateCustomerdetails(mapCasetoAccount);
        }
        if(!mapCasetoAccountHR.isEmpty())
        {
            creditCardCustomerProfileUpdate.updateCustomerdetailsVIAHR(mapCasetoAccountHR);
        }
        //CH03: END
    }
    
    public static void handlerAfterCaseCreation(List<Case> lstCase){
        Set<Id> setCashCollateralCaseInProgress = new Set<Id>();
        //CH05: Start
        Set<Id> setCashCollateralLimitIncreaseCaseInProgress = new Set<Id>();
        //CH05: END
        for(Case caseObj : lstCase) {
             if(caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && caseObj.Sub_Status__c == 'In-Progress'){
                setCashCollateralCaseInProgress.add(caseObj.id);
            }
            //CH05: Start
            System.debug('Cash Collateral LMT Increase Sub-status:'+caseObj.Sub_Status__c);
            if(caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && caseObj.Sub_Status__c == 'In-Progress'){
                setCashCollateralLimitIncreaseCaseInProgress.add(caseObj.id);
            }
            //CH05: END
        }
        if(!setCashCollateralCaseInProgress.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseCreation(setCashCollateralCaseInProgress);
        }
        //CH05: Start
        if(!setCashCollateralLimitIncreaseCaseInProgress.isEmpty()){
            System.debug('Testing for Future Call for Cash Collateral Limit Increase');
            CreditCardCashCollateral.CashCollateralCaseCreation(setCashCollateralLimitIncreaseCaseInProgress);

        }
        //CH05: END
    }
    
    public static void handlerBeforeCaseCreation(List<Case> lstCase){
         //CH03: Start
        //Set<Id> accIdset = new Set<Id>();
        //Map<Id,Account> mapAccount = new Map<Id,Account>();
        //CH03: END
        for(Case cs : lstCase){
            if(cs.Type == 'Credit Card Cash Collateral Application' && cs.Sub_Type__c == 'New Cash Collateral'){
                if(cs.cc_Requested_Card_Type__c != null &&  cs.cc_Requested_Card_Type__c != '')
                    cs.cc_Approved_Requested_Card_Type__c = cs.cc_Requested_Card_Type__c;
                if(cs.cc_Name_on_the_Card__c != null &&  cs.cc_Name_on_the_Card__c != '')
                    cs.cc_Approved_Name_on_the_card__c = cs.cc_Name_on_the_Card__c;
                if(cs.cc_Embossing_Line_4__c != null &&  cs.cc_Embossing_Line_4__c != '')
                    cs.cc_Approved_Embossing_line_4__c = cs.cc_Embossing_Line_4__c;
                if(cs.cc_Balance_Transfer_Card_Provider__c != null && cs.cc_Balance_Transfer_Card_Provider__c != '')
                    cs.cc_Approved_Balance_Transfer_Card_Provi__c = cs.cc_Balance_Transfer_Card_Provider__c;
                if(cs.cc_Balance_Transfer_Card_Number__c != null && cs.cc_Balance_Transfer_Card_Number__c != ''){
                    cs.cc_Approved_Balance_Transfer_Card_Number__c = cs.cc_Balance_Transfer_Card_Number__c;
                    cs.sys_Balance_Transfer_Card_Number__c = cs.cc_Balance_Transfer_Card_Number__c;
                    if(cs.sys_Balance_Transfer_Card_Number__c != '' && cs.sys_Balance_Transfer_Card_Number__c != null){
                        cs.cc_First_6_Digit__c = cs.sys_Balance_Transfer_Card_Number__c.substring(0,6);
                        cs.cc_Last_4_Digit__c = cs.sys_Balance_Transfer_Card_Number__c.substring(12,16);
                    }
                }
                if(cs.cc_Balance_Transfer_Amount__c != null)
                    cs.cc_Approved_Balance_Transfer_Amount__c = cs.cc_Balance_Transfer_Amount__c;
                if(cs.cc_Balance_Transfer_Type__c != null)
                    cs.cc_Approved_Transfer_Type__c = cs.cc_Balance_Transfer_Type__c;
                
                
                if(cs.ccol_Hold_Account__c != null && cs.ccol_Hold_Account__c != '')
                    cs.ccol_Approved_Hold_Account__c = cs.ccol_Hold_Account__c;
                if(cs.ccol_Hold_Account_IBAN__c != null && cs.ccol_Hold_Account_IBAN__c != '')
                    cs.ccol_Approved_Hold_Account_IBAN__c = cs.ccol_Hold_Account_IBAN__c;
                if(cs.cc_Requested_Credit_Limit__c != null)
                    cs.cc_Approved_Credit_Limit__c = cs.cc_Requested_Credit_Limit__c;
                
                //if(cs.ccol_Hold_Amount__c != null)
                   // cs.ccol_Approved_Hold_Amount__c = cs.ccol_Hold_Amount__c;
                   //CH03: Start
                    //accIdset.add(cs.AccountId);
                  //CH03: END
                
            }
             //CH05: Start
            if(cs.Type == 'Cash Collateral Credit Limit Increase Application' && cs.Sub_Type__c == 'Cash Collateral Credit Limit Increase'){
        if(cs.ccol_Hold_Account__c != null && cs.ccol_Hold_Account__c != '')
                    cs.ccol_Approved_Hold_Account__c = cs.ccol_Hold_Account__c;
                if(cs.ccol_Hold_Account_IBAN__c != null && cs.ccol_Hold_Account_IBAN__c != '')
                    cs.ccol_Approved_Hold_Account_IBAN__c = cs.ccol_Hold_Account_IBAN__c;
                if(cs.cc_Requested_Credit_Limit__c != null)
                    cs.cc_Approved_Credit_Limit__c = cs.cc_Requested_Credit_Limit__c;                
            }
            //CH05: END
        }
         //CH03: Start
        /*if(!accIdset.isEmpty()){
           
            for(Account acct : [Select Id,ID_Type__pc,ID_Number__pc,ID_Expiry_Date__pc from Account where ID_Type__pc =: 'Bahraini ID' AND Id IN: accIdset]){
                mapAccount.put(acct.Id,acct);
            }
            if(!mapAccount.isEmpty()){
                for(Case c : lstCase){
                    if(c.Type == 'Credit Card Cash Collateral Application' && c.Sub_Type__c == 'New Cash Collateral'){
                        if(mapAccount.containsKey(c.AccountId) && !mapAccount.isEmpty()){
                            Account a = mapAccount.get(c.AccountId);
                            c.cc_CPR_Number__c = a.ID_Number__pc;
                            c.cc_CPR_Expiry_Date__c = a.ID_Expiry_Date__pc;
                        }
                    }
                }
            }
        }*/
        //CH03: END   
        
    }
    public static void handlerBeforeCaseUpdate(List<Case> lstCase){
        for(Case caseObj : lstCase){
           Case caseOldObj = (Case)trigger.oldMap.get(caseObj.id);
           //CH05: Added Type and Sub Type related to Cash Collateral Limit Increase in if block
           if((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') ||  (caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')){
               if(caseObj.ccol_Hold_Amount__c != null && caseOldObj.ccol_Hold_Amount__c != caseObj.ccol_Hold_Amount__c ){
                   caseObj.ccol_Approved_Hold_Amount__c = caseObj.ccol_Hold_Amount__c;
               }
           }
            //CH01: Start
            //CH05: Added Type and Sub Type related to Cash Collateral Limit Increase in if block
            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') ||(caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) && checkRecursive.runOnce()){
                if(caseOldObj.cc_Credit_Pre_Screening_Result__c != caseObj.cc_Credit_Pre_Screening_Result__c 
                   && (caseObj.cc_Credit_Pre_Screening_Result__c != '' || caseObj.cc_Credit_Pre_Screening_Result__c != null )){
                       caseObj.cc_Credit_Pre_Screening_by__c = UserInfo.getUserId();
                       System.debug('Inside Pre-screener owner Updated by value in Cash Collateral');
                   }
                
                if(caseOldObj.cc_Credit_Approval_Result__c != caseObj.cc_Credit_Approval_Result__c 
                   && (caseObj.cc_Credit_Approval_Result__c != '' || caseObj.cc_Credit_Approval_Result__c != null)){
                       caseObj.cc_Credit_Approved_by__c = UserInfo.getUserId();
                        System.debug('Inside Approver owner Updated by value in Cash Collateral');
                   }
                if(caseOldObj.cc_Business_Approval_Result__c != caseObj.cc_Business_Approval_Result__c 
                   && (caseObj.cc_Business_Approval_Result__c != '' || caseObj.cc_Business_Approval_Result__c != null)){
                       caseObj.cc_Business_Approval_by__c = UserInfo.getUserId();
                        System.debug('Inside Business owner Updated by value in Cash Collateral');
                   }
                 if(caseOldObj.cc_CEO_Result__c != caseObj.cc_CEO_Result__c 
                   && (caseObj.cc_CEO_Result__c != '' || caseObj.cc_CEO_Result__c != null)){
                       caseObj.cc_CEO_Result_by__c = UserInfo.getUserId();
                       System.debug('Inside CEO owner Updated by value in Cash Collateral');
                   }
                 if(caseOldObj.cc_Service_Centre_Result__c != caseObj.cc_Service_Centre_Result__c 
                   && (caseObj.cc_Service_Centre_Result__c != '' || caseObj.cc_Service_Centre_Result__c != null)){
                       caseObj.cc_Service_Centre_by__c = UserInfo.getUserId();
                       System.debug('Inside Service center owner Updated by value in Cash Collateral');
                   }
                if(caseOldObj.cc_Signature_Verifier_Result__c != caseObj.cc_Signature_Verifier_Result__c 
                   && (caseObj.cc_Signature_Verifier_Result__c != '' || caseObj.cc_Signature_Verifier_Result__c != null)){
                       caseObj.cc_Signature_Verifier_by__c = UserInfo.getUserId();
                       System.debug('Inside signature verifier owner Updated by value in Cash Collateral');
                   }
                if(caseOldObj.cc_Operations_Result__c != caseObj.cc_Operations_Result__c 
                   && (caseObj.cc_Operations_Result__c != '' || caseObj.cc_Operations_Result__c != null)){
                       caseObj.cc_Operation_by__c = UserInfo.getUserId();
                       System.debug('Inside operations owner Updated by value in Cash Collateral');
                   }
                 if(caseOldObj.cc_Contact_Centre_Result__c != caseObj.cc_Contact_Centre_Result__c 
                   && (caseObj.cc_Contact_Centre_Result__c != '' || caseObj.cc_Contact_Centre_Result__c != null)){
                       caseObj.cc_Contact_Center_by__c = UserInfo.getUserId();
                       System.debug('Inside contact center owner Updated by value in Cash Collateral');
                   }
                 //CH05: Start
                if(caseOldObj.cc_HR_Result__c != caseObj.cc_HR_Result__c && (caseObj.cc_HR_Result__c != '' || caseObj.cc_HR_Result__c != null)){
                    caseObj.cc_HR_Verifier_by__c = UserInfo.getUserId();
                     System.debug('Inside HR owner Updated by value in Cash Collateral');
                }
                //CH05: END
                
            }
            //CH01: END
            //CH04: Start
             if(caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && ((caseOldObj.Campaign_Name__c != caseObj.Campaign_Name__c) || (caseOldObj.Campaign_Validity__c != caseObj.Campaign_Validity__c))){
                if(caseOldObj.Campaign_Name__c != caseObj.Campaign_Name__c && caseObj.Campaign_Name__c != null){
                    caseObj.Approved_Campaign_Name__c = caseObj.Campaign_Name__c;
                }
                if(caseOldObj.Campaign_Validity__c != caseObj.Campaign_Validity__c && caseObj.Campaign_Validity__c != null){
                    caseObj.Approved_Campaign_Validity__c = caseObj.Campaign_Validity__c;
                }
            }
            //CH04: END 
            
        }
        
    }
}