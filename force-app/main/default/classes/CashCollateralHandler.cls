/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 13-01-2022
*       Change History: 
*          #CH01# #Jahangeer Mohammed# #26-04-2022# Added Logic to populate user for Cash Collateral Application. 
*          #CH02# #Jahangeer Mohammed# #15-05-2022# Added extra brackets in If condition for Decline & Cancelled by Customer(PI-1564)
*          #CH03# #Jahangeer Mohammed #28-06-2022# Added Logic to Populate CPR Number & CPR Expiry(NBA-5692 & NBA-5693)
*          #CH04# #Jahangeer Mohammed# #15-08-2022# Added Logic to Populate Approved Campaign Name as per ticket(NBA-5719)
*          #CH05# #Jahangeer Mohammed# #08-09-2022# Added Logic for Cash Collateral Limit Increase Application(NBA-6043)
*          #CH06# #Jahangeer Mohammed# #21-11-2022# Added Logic for Cancelled by Customer for Cash Collateral Limit Increase Process(NBA-6559)
*          #CH07# #Jahangeer Mohammed# #10-04-2023# Restrict Cash Collateral Applications to Bahrain Region
           #CH08# #Jayanth# #02-05-2023# Adding CashCollaterallimit Increase Application to Jordan
*          #CH09# #Jahangeer Mohammed# #20-05-2024# Added Decline & Cancelled by Customer in Signature Verifier Phase(NBA-11053)
*          #CH10# #Jahangeer Mohammed# #29-10-2024# Added Logic to add Alias Name as API/Manual based on the Last Modified User
*          #CH11# #Jahangeer Mohammed# #21-11-2024# Added Logic to populate Approved Requested Card Type for Cash Collateral Limit Increase Application
           #CH12# #Jahangeer Mohammed# #30-12-2024# Added Logic to add Co-Branded Cards(NBA-12524)
           #CH13# #Jahangeer Mohammed# #23-02-2025# Added Logic to add STP Decisoning(NBA-13287)
		   #CH14# #Jahangeer Mohammed# #10-12-2025# Added Logic to add STP Decisoning for GCC(NBA-15138)
           #CH15# #Aniss Mbarki# 22-12-2025# Added Logic for Credit Card - In-App DocuSign Documents Signing  (NBA-13727)
*/
public class CashCollateralHandler {
    
    public static void handlerAfterCaseUpdate(List<Case> lstCase){
        Set<Id> setCashCollateralCaseAcceptByPrescreener = new Set<Id>();
        Set<Id> setCashCollateralCaseDiscrepancyByPrescreener = new Set<Id>();
        Set<Id> setCashCollateralCaseReferToServiceCenterByPrescreener = new Set<Id>();
        Set<Id> setCashCollateralCaseReturnToPrescreenerByServiceCenter = new Set<Id>();
        Set<Id> setCashCollateralCaseApprovedByApprover = new Set<Id>();
        Set<Id> setCashCollateralCaseApprovedByApproverInApp = new Set<Id>();//#CH15
        Set<Id> setCashCollateralCaseReferToServiceCenterByApprover = new Set<Id>();
        Set<Id> setCashCollateralCaseReturnToApproverByServiceCenter = new Set<Id>();
        Set<Id> setCashCollateralCaseAcceptBySignatureVerifierForNonBalanceTransfer = new Set<Id>();
        Set<Id> setCashCollateralCaseAcceptBySignatureVerifierForBalanceTransfer = new Set<Id>();
        Set<Id> setCashCollateralCaseResendBySignatureVerifier = new Set<Id>();
        Set<Id> setCashCollateralCaseResendBySignatureVerifierInApp = new Set<Id>();//#CH15
        Set<Id> setCashCollateralCaseReferToServiceCenterBySignatureVerifier = new Set<Id>();
        Set<Id> setCashCollateralCaseReturnToSignatureVerifierByServiceCenter = new Set<Id>();
        //CH07: Start
        Set<Id> setCashCollateralCaseAcceptByJordanSignatureVerifierForNonBalanceTransfer = new Set<Id>();
        Set<Id> setCashCollateralCaseReturnToCardAdminByServiceCenter = new Set<Id>();
        Set<Id> setCashCollateralCaseReturnToCardOperationByServiceCenter = new Set<Id>();
        Set<Id> setCashCollateralCaseAcceptedByCreditAdmin = new Set<Id>();
        Set<Id> setCashCollateralCaseReturnToSignatureVerifierByCreditAdmin = new Set<Id>();
        Set<Id> setCashCollateralCaseReferToServiceCenterByCreditAdmin = new Set<Id>();
        Set<Id> setCashCollateralCaseAcceptedByJordanCardOperation = new Set<Id>();
        Set<Id> setCashCollateralCaseReturnToCardAdminByJordanCardOperation = new Set<Id>();
        Set<Id> setCashCollateralCaseReferToServiceCenterByJordanCardOperation = new Set<Id>();
        List<CaseComment> lstComment = new List<CaseComment>();
        //CH07: END
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
        Set<Id> setCashCollateralLimitIncreaseCaseApprovedByApproverInApp = new Set<Id>();//#CH15
        Set<Id> setCashCollateralLimitIncreaseCaseReferToServiceCenterByApprover = new Set<Id>();
        Set<Id> setCashCollateralLimitIncreaseCaseAcceptBySignatureVerifier = new Set<Id>();
        Set<Id> setCashCollateralLimitIncreaseCaseResendBySignatureVerifier = new Set<Id>();
        Set<Id> setCashCollateralLimitIncreaseCaseResendBySignatureVerifierInApp = new Set<Id>();//#CH15
        set<Id> setCashCollateralLimitIncreaseCaseReturnToApproverByServiceCenter = new Set<Id>();
        set<Id> setCashCollateralLimitIncreaseCaseAcceptByHR = new Set<Id>();
        //CH05: END
        //CH06: Start
        Set<Id> setCashCollateralLimitIncreaseCaseCancelledByCustomer = new Set<Id>();
        //CH06: END
        //CH08: Start
        Set<Id> setCashCollateralLimitIncreaseCaseAcceptByCreditAdmin = new Set<Id>();
        Set<Id> setCashCollateralLimitIncreaseCaseAcceptByOperation = new Set<Id>();
        //CH08: END
        for(Case caseObj : lstCase) {
            Case caseOldObj = (Case)trigger.oldMap.get(caseobj.id);
            string recordtypeName = rt_Map.get(caseObj.RecordTypeId).getName();
            
            /************************************************************* Start : Credit-screener Stage - Cash Collateral Application Process for Bahrain & Jordan ****************************************************************************************/
            //CH07: Start Added Region Flag in the if condition
            if(caseObj.Sub_Status__c != caseOldObj.Sub_Status__c && caseObj.Sub_Status__c =='Discrepancies' && (caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') && (caseObj.Region_Flag__c == 'Bahrain' || caseObj.Region_Flag__c == 'Jordan')){
                System.debug('Dicrepancy in Documents for Cash Collateral');
                setCashCollateralCaseDiscrepancyByPrescreener.add(caseObj.id);
            }
            //CH13: Start: Added cc_Control_Type__c != 'STP' in if condition to avoid a future call for BCRB Process
            if(caseOldObj.cc_Credit_Pre_Screening_Result__c != caseObj.cc_Credit_Pre_Screening_Result__c  && caseObj.cc_Credit_Pre_Screening_Result__c =='Accept' && 
               (caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') && (caseObj.cc_Application_Stages__c == 'Credit Pre-Screening' || caseObj.cc_Application_Stages__c == 'New') && (caseObj.Region_Flag__c == 'Bahrain' || caseObj.Region_Flag__c == 'Jordan') && caseObj.cc_Control_Type__c != 'STP')
            {
                system.debug('----> Prescreener Accept in Cash Collateral --> '+caseObj);
                setCashCollateralCaseAcceptByPrescreener.add(caseObj.id);
            }
            //CH13: END
            //CH07: END
            /************************************************************* END : Credit-screener Stage - Cash Collateral Application Process  for Bahrain & Jordan ****************************************************************************************/

            //CH05: Start
            /************************************************************* Start : Credit Pre-screener Stage - Cash Collateral Limit Increase Application  *****************************************************/
            //CH07: Added Region Flag in if condition
            //CH08: Added Jordan Region Flag
            
            if(caseOldObj.cc_Credit_Pre_Screening_Result__c != caseObj.cc_Credit_Pre_Screening_Result__c  && caseObj.cc_Credit_Pre_Screening_Result__c =='Accept'  && 
               (caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase') && (caseObj.cc_Application_Stages__c == 'Credit Pre-Screening' || caseObj.cc_Application_Stages__c == 'New') && (caseObj.Region_Flag__c == 'Bahrain' ||caseObj.Region_Flag__c == 'Jordan'))
            {
                system.debug('----> Prescreener Accept in Cash Collateral limit Increase --> '+caseObj);
                setCashCollateralLimitIncreaseCaseAcceptByPrescreener.add(caseObj.id);
            }
            
            /************************************************************* END : Credit Pre-screener Stage - Cash Collateral Limit Increase Application  *****************************************************/
            //CH05: END
           
            /************************************************************* Start : Credit-screener Stage - Cash Collateral Application Process  for Bahrain & Jordan ****************************************************************************************/
            //CH07: Start Added Region Flag in the if condition
            if((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') &&
               caseObj.cc_Credit_Pre_Screening_Result__c == 'Refer to Service Center' && caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c &&
               (caseObj.cc_Application_Stages__c == 'Credit Pre-Screening' || caseObj.cc_Application_Stages__c == 'New') && (caseObj.Region_Flag__c == 'Bahrain' || caseObj.Region_Flag__c == 'Jordan')){ 
                   System.debug('Set Cases from Pre screener Queue to Service Center in Cash Collateral');
                   setCashCollateralCaseReferToServiceCenterByPrescreener.add(caseObj.id); 
               }
            //CH07: END
            /************************************************************* END : Credit-screener Stage - Cash Collateral Application Process  for Bahrain & Jordan ****************************************************************************************/

            /************************************************************* Start : Credit-Approver Stage - Cash Collateral Application Process  for Bahrain & Jordan ****************************************************************************************/

            //CH07: Added Region Flag in if condition
            if(caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' &&  caseObj.cc_Credit_Approval_Result__c == 'Approve' &&
               caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Approval' && (caseObj.Region_Flag__c == 'Bahrain' || caseObj.Region_Flag__c == 'Jordan'))
            {
                //#CH15 : Start
                if(caseObj.Region_Flag__c == 'Bahrain'){
                    if(caseObj.Resend_DocuSign__c == 'Email' ){
                        System.debug('Set Cases for Signature Verification Queue From Credit Approver in Cash Collateral');
                        setCashCollateralCaseApprovedByApprover.add(caseObj.id);
                    }else{
                        System.debug('Set Cases for Signature Verification Queue From Credit Approver in Cash Collateral In-App scenario');
                        setCashCollateralCaseApprovedByApproverInApp.add(caseObj.id);
                    }
                }else{
                    System.debug('Jordan -- Set Cases for Signature Verification Queue From Credit Approver in Cash Collateral');
                    setCashCollateralCaseApprovedByApprover.add(caseObj.id);
                }
                //#CH15 : End
            }
            //CH07: END
            /************************************************************* END : Credit-Approver Stage - Cash Collateral Application Process  for Bahrain & Jordan ****************************************************************************************/

             //CH05: Start
            /************************************************************* Start : Credit Approver Stage - Cash Collateral Limit Increase Application  *****************************************************/
            //CH07: Added Region Flag in if condition
            //CH08: Added Jordan Region Flag
            if(caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase' &&  caseObj.cc_Credit_Approval_Result__c == 'Approve' &&
            caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c &&
            caseObj.cc_Application_Stages__c == 'Credit Approval' && (caseObj.Region_Flag__c == 'Bahrain'||caseObj.Region_Flag__c == 'Jordan')){
                //#CH15 : Start
                if(caseObj.Region_Flag__c == 'Bahrain'){
                    if(caseObj.Resend_DocuSign__c == 'Email' ){
                        System.debug('Set Cases for Signature Verification Queue From Credit Approver in Cash Collateral limit Increase');
                        setCashCollateralLimitIncreaseCaseApprovedByApprover.add(caseObj.id);
                    }else{
                        System.debug('Set Cases for Signature Verification Queue From Credit Approver in Cash Collateral limit Increase');
                        setCashCollateralLimitIncreaseCaseApprovedByApproverInApp.add(caseObj.id);
                    }
                }else{
                    System.debug('Jordan -- Set Cases for Signature Verification Queue From Credit Approver in Cash Collateral limit Increase');
                    setCashCollateralLimitIncreaseCaseApprovedByApprover.add(caseObj.id);
                }
                //#CH15 : End
            }
            //CH07: Added Region Flag in if condition
            //CH08: Added Jordan Region Flag
            if((caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase') &&
               caseObj.cc_Credit_Approval_Result__c == 'Refer to Service Center' &&
               caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Approval' && (caseObj.Region_Flag__c == 'Bahrain'||caseObj.Region_Flag__c == 'Jordan')){
                   System.debug('Set Cases for Credit Card Service Center Queue From Credit Approver in cash collateral limit Increase');
                   setCashCollateralLimitIncreaseCaseReferToServiceCenterByApprover.add(caseObj.id); 
            } 
            /************************************************************* END : Credit Approver Stage - Cash Collateral Limit Increase Application  *****************************************************/
            //CH05: END
            
            /************************************************************* Start : Credit-Approver Stage - Cash Collateral Application Process  for Bahrain & Jordan ****************************************************************************************/
            //CH07: Added Region Flag in if condition
            if((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') &&
               caseObj.cc_Credit_Approval_Result__c == 'Refer to Service Center' &&
               caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Approval'  && (caseObj.Region_Flag__c == 'Bahrain' || caseObj.Region_Flag__c == 'Jordan')){
                   System.debug('Set Cases for Credit Card Service Center Queue From Credit Approver in cash collateral');
                   setCashCollateralCaseReferToServiceCenterByApprover.add(caseObj.id); 
               } 
            //CH07: END
            /************************************************************* END : Credit-Approver Stage - Cash Collateral Application Process  for Bahrain & Jordan ****************************************************************************************/

            /************************************************************* Start : Signature Verifier Stage - Cash Collateral Application Process ila Blue for Bahrain ****************************************************************************************/
            //CH07: Added Region Flag in if condition
            //CH12: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') ) &&
               caseObj.cc_Signature_Verifier_Result__c == 'Accept' &&  caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification' && (caseObj.cc_Approved_Requested_Card_Type__c != 'PLATINUM_BALANCE_TRANSFER_01' && caseObj.Is_Balance_Transfer__c == false) && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases for Credit Signature for ila blue/black for Cash Collateral'); 
                   setCashCollateralCaseAcceptBySignatureVerifierForNonBalanceTransfer.add(caseObj.id);
               }
            //CH07: END
           /************************************************************* END : Signature Verifier Stage - Cash Collateral Application Process ila Blue for Bahrain ****************************************************************************************/

           /************************************************************ Start : Signature Verifier Stage - Cash Collateral Limit Increase Application **********************************************************/
            //CH05: Start
            //CH07: Added Region Flag in if condition
            //CH08: Added Jordan Region Flag
            if(((caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase') ) &&
            caseObj.cc_Signature_Verifier_Result__c == 'Accept' &&  caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
            caseObj.cc_Application_Stages__c == 'Credit Signature Verification' && (caseObj.Region_Flag__c == 'Bahrain' || caseObj.Region_Flag__c == 'Jordan')){
                System.debug('Set Cases when signature verifier accepts for Cash Collateral limit increase'); 
                setCashCollateralLimitIncreaseCaseAcceptBySignatureVerifier.add(caseObj.id);
            }

            //CH07: Added Region Flag in if condition
            //CH08: Added Jordan Region Flag
            if(((caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) &&
               caseObj.cc_Signature_Verifier_Result__c == 'Re-Send' && caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification' && (caseObj.Region_Flag__c == 'Bahrain' || caseObj.Region_Flag__c == 'Jordan')){
                   System.debug('Set Cases Remains in for Credit Signature verifier in cash collateral limit Increase'); 
                   setCashCollateralLimitIncreaseCaseResendBySignatureVerifier.add(caseObj.id);
               }
            /************************************************************ END :  Signature Verifier Stage - Cash Collateral Limit Increase Application **********************************************************/
            //CH05: END
            
            //#CH15: Start
            if(((caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) &&
               caseObj.cc_Signature_Verifier_Result__c == 'Re-Send In-App' && caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification' && (caseObj.Region_Flag__c == 'Bahrain')){
                   System.debug('Set Cases Remains in for Credit Signature verifier in cash collateral limit Increase -- In-App -- '); 
                   setCashCollateralLimitIncreaseCaseResendBySignatureVerifierInApp.add(caseObj.id);
               }
            //#CH15: END

            // /************************************************************ Start : JO Credit Admin Stage - Cash Collateral Limit Increase Application **********************************************************/
            //  //CH08: Added Jordan Region Flag
            if(((caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) &&
              caseObj.cc_Credit_Admin_Result__c != caseOldObj.cc_Credit_Admin_Result__c && caseObj.cc_Credit_Admin_Result__c=='Accept' &&
               caseObj.cc_Application_Stages__c == 'Credit Admin' && (caseObj.Region_Flag__c == 'Jordan')){
                   System.debug('Set Cases Remains in for Credit Signature verifier in cash collateral limit Increase'); 
                   setCashCollateralLimitIncreaseCaseAcceptByCreditAdmin.add(caseObj.id);
               }
             /************************************************************ END :  JO Credit Admin Stage - Cash Collateral Limit Increase Application **********************************************************/
                        // /************************************************************ Start : JO Credit Operation Stage - Cash Collateral Limit Increase Application **********************************************************/
            //  //CH08: Added Jordan Region Flag
            if(((caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) &&
               caseObj.cc_Card_Operations_Result__c == 'Accept' && caseObj.cc_Card_Operations_Result__c != caseOldObj.cc_Card_Operations_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Operation' && (caseObj.Region_Flag__c == 'Jordan')){
                   System.debug('Set Cases Remains in for Credit Signature verifier in cash collateral limit Increase'); 
                   setCashCollateralLimitIncreaseCaseAcceptByOperation.add(caseObj.id);
               }
             /************************************************************ END :  JO Credit Operation Stage - Cash Collateral Limit Increase Application **********************************************************/
            /************************************************************* Start : Signature Verifier Stage - Cash Collateral Application Process ila Blue for Jordan ****************************************************************************************/
            //CH07: Start
            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') ) &&
               caseObj.cc_Signature_Verifier_Result__c == 'Accept' &&  caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification' && (caseObj.cc_Approved_Requested_Card_Type__c != 'PLATINUM_BALANCE_TRANSFER_01') && caseObj.Region_Flag__c == 'Jordan'){
                   System.debug('Set Cases for Credit Signature for ila blue/black for Cash Collateral Jordan'); 
                   setCashCollateralCaseAcceptByJordanSignatureVerifierForNonBalanceTransfer.add(caseObj.id);
               }
            //CH07: END
            /************************************************************* END : Signature Verifier Stage - Cash Collateral Application Process ila Blue for Jordan ****************************************************************************************/

            /************************************************************* Start : Signature Verifier Stage - Cash Collateral Application Process ila Switch for Bahrain ****************************************************************************************/
            //CH07: Added Region Flag in if condition
            //CH12: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral')) &&
               caseObj.cc_Signature_Verifier_Result__c == 'Accept' &&  caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification' && (caseObj.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || caseObj.Is_Balance_Transfer__c == true)  && caseObj.cc_Approved_Transfer_Type__c == 'Balance Transfer' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases for Credit Signature for ila switch Balance Transfer for cash collateral'); 
                   setCashCollateralCaseAcceptBySignatureVerifierForBalanceTransfer.add(caseObj.id);
               }
            //CH07: END
           /************************************************************* END : Signature Verifier Stage - Cash Collateral Application Process ila Switch for Bahrain ****************************************************************************************/
 
           /************************************************************* Start: Signature Verifier Stage - Cash Collateral Application Process for Bahrain & Jordan *************************************************************************/
            //CH05: Added Type and Sub Type related to Cash Collateral Limit Increase in if block
            //CH07: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && (caseObj.Region_Flag__c == 'Bahrain' || caseObj.Region_Flag__c == 'Jordan')) || (caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && caseObj.Region_Flag__c == 'Bahrain')) &&
               caseObj.cc_Signature_Verifier_Result__c == 'Re-Send' && caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification'){
                   System.debug('Set Cases Remains in for Credit Signature verifier in cash collateral'); 
                   setCashCollateralCaseResendBySignatureVerifier.add(caseObj.id);
               }

            //#CH15: Start
            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && (caseObj.Region_Flag__c == 'Bahrain')) || (caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && caseObj.Region_Flag__c == 'Bahrain')) &&
               caseObj.cc_Signature_Verifier_Result__c == 'Re-Send In-App' && caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification'){
                   System.debug('Set Cases Remains in for Credit Signature verifier in cash collateral -- Re-Send In-App --'); 
                   setCashCollateralCaseResendBySignatureVerifierInApp.add(caseObj.id);
            }
            //#CH15: End

            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && (caseObj.Region_Flag__c == 'Bahrain' || caseObj.Region_Flag__c == 'Jordan'))) &&
               caseObj.cc_Signature_Verifier_Result__c == 'Refer to Service Center' &&
               caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification'){ 
                   System.debug('Set Cases for Credit Card Service Center Queue From Signature Verifier in cash collateral');
                   setCashCollateralCaseReferToServiceCenterBySignatureVerifier.add(caseObj.id);
               }
            //CH07: END
            /************************************************************* END: Signature Verifier Stage - Cash Collateral Application Process for Bahrain & Jordan *************************************************************************/

            
            /********************************************************* Start : Service Center Stage - Cash Collateral Application Process  for Bahrain & Jordan *****************************************************************/
            //CH07: Added Region Flag in if condition
            if((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') &&
               caseObj.cc_Service_Centre_Result__c == 'Return to Pre-Screener' && caseObj.cc_Service_Centre_Result__c != caseOldObj.cc_Service_Centre_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre' && (caseObj.Region_Flag__c == 'Bahrain' || caseObj.Region_Flag__c == 'Jordan')){ 
                   System.debug('Set Cases Routed from Service Center to Pre-screener queue For Cash Collateral ');
                   setCashCollateralCaseReturnToPrescreenerByServiceCenter.add(caseObj.id);
               }
           
            if((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') &&
               caseObj.cc_Service_Centre_Result__c == 'Return to Approver' &&
               caseObj.cc_Service_Centre_Result__c != caseOldObj.cc_Service_Centre_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre' && (caseObj.Region_Flag__c == 'Bahrain' || caseObj.Region_Flag__c == 'Jordan')){ 
                   System.debug('Set Cases Routed from Service Center to Approval queue for cash collateral');
                   setCashCollateralCaseReturnToApproverByServiceCenter.add(caseObj.id);
               }
            //CH07: END
           /********************************************************* END : Service Center Stage - Cash Collateral Application Process  for Bahrain & Jordan *****************************************************************/

           //CH05: Start
            /************************************************************* Start : Credit Service Center Stage - Cash Collateral Limit Increase Application  *****************************************************/
            //CH07: Added Region Flag in if condition
            //CH08: Added Jordan Region Flag
            if((caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase') &&
               caseObj.cc_Service_Centre_Result__c == 'Return to Approver' &&
               caseObj.cc_Service_Centre_Result__c != caseOldObj.cc_Service_Centre_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre' && (caseObj.Region_Flag__c == 'Bahrain' || caseObj.Region_Flag__c == 'Jordan')){ 
                   System.debug('Set Cases Routed from Service Center to Approval queue for cash collateral limit increase');
                   setCashCollateralLimitIncreaseCaseReturnToApproverByServiceCenter.add(caseObj.id);
               }
           /************************************************************* END : Credit Service Center Stage - Cash Collateral Limit Increase Application  *****************************************************/
            //CH05: END
            
           /********************************************************* Start : Service Center Stage - Cash Collateral Application Process  for Bahrain & Jordan *****************************************************************/
            //CH07: Added Region Flag in if condition
            if((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') &&
               caseObj.cc_Service_Centre_Result__c == 'Return to Signature Verifier' && caseObj.cc_Service_Centre_Result__c != caseOldObj.cc_Service_Centre_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre' && (caseObj.Region_Flag__c == 'Bahrain' || caseObj.Region_Flag__c == 'Jordan')){ 
                   System.debug('Set Cases Routed from Service Center to Signature Verification queue in cash collateral');
                   setCashCollateralCaseReturnToSignatureVerifierByServiceCenter.add(caseObj.id);
               }
            //CH07: END
           /********************************************************* END : Service Center Stage - Cash Collateral Application Process  for Bahrain & Jordan *****************************************************************/
 
           /******************************************************** Start : Service Center Stage - Cash Collateral Application Process only for Jordan *************************************************************************************/
            //CH07: Start
            if(caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && caseObj.cc_Service_Centre_Result__c == 'Return to Credit Admin' &&
               caseObj.cc_Service_Centre_Result__c != caseOldObj.cc_Service_Centre_Result__c && caseObj.cc_Application_Stages__c == 'Credit Service Centre' && caseObj.Region_Flag__c == 'Jordan'){
               System.debug('Set Cases Routed from Service Center to Card Admin queue in cash collateral Jordan');
                setCashCollateralCaseReturnToCardAdminByServiceCenter.add(caseObj.id);
            }
            if(caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && caseObj.cc_Service_Centre_Result__c == 'Return to Card Operations' &&
               caseObj.cc_Service_Centre_Result__c != caseOldObj.cc_Service_Centre_Result__c && caseObj.cc_Application_Stages__c == 'Credit Service Centre' && caseObj.Region_Flag__c == 'Jordan'){
               System.debug('Set Cases Routed from Service Center to Card Operation queue in cash collateral Jordan');
                setCashCollateralCaseReturnToCardOperationByServiceCenter.add(caseObj.id);
            } 
            //CH07: END
           /******************************************************** END : Service Center Stage - Cash Collateral Application Process only for Jordan *************************************************************************************/
  
           /********************************************************* Start : Credit Admin -  Cash Collateral Application Process only for Jordan **************************************************/
           //CH07: Start
           if(caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && caseObj.cc_Credit_Admin_Result__c == 'Accept' &&
               caseObj.cc_Credit_Admin_Result__c != caseOldObj.cc_Credit_Admin_Result__c && caseObj.cc_Application_Stages__c == 'Credit Admin' && caseObj.Region_Flag__c == 'Jordan'){
               System.debug('Set Cases Routed from Card Admin to Card Operation queue in cash collateral Jordan');
                setCashCollateralCaseAcceptedByCreditAdmin.add(caseObj.id);
            } 
            if(caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && caseObj.cc_Credit_Admin_Result__c == 'Return to Signature Verification' &&
               caseObj.cc_Credit_Admin_Result__c != caseOldObj.cc_Credit_Admin_Result__c && caseObj.cc_Application_Stages__c == 'Credit Admin' && caseObj.Region_Flag__c == 'Jordan'){
               System.debug('Set Cases Routed from Card Admin to Signature Verifier queue in cash collateral Jordan');
                setCashCollateralCaseReturnToSignatureVerifierByCreditAdmin.add(caseObj.id);
            } 
            if(caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && caseObj.cc_Credit_Admin_Result__c == 'Refer to service center' &&
               caseObj.cc_Credit_Admin_Result__c != caseOldObj.cc_Credit_Admin_Result__c && caseObj.cc_Application_Stages__c == 'Credit Admin' && caseObj.Region_Flag__c == 'Jordan'){
               System.debug('Set Cases Routed from Card Admin to Service Center queue in cash collateral Jordan');
                setCashCollateralCaseReferToServiceCenterByCreditAdmin.add(caseObj.id);
            } 
           //CH07: END
           /********************************************************* END : Credit Admin -  Cash Collateral Application Process only for Jordan **************************************************/
 
           /********************************************************** Start : Jordan Card Operations - Cash Collateral Application Process only for Jordan *****************************************************/
           //CH07: Start
           if(caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && caseObj.cc_Card_Operations_Result__c == 'Accept' &&
               caseObj.cc_Card_Operations_Result__c != caseOldObj.cc_Card_Operations_Result__c && caseObj.cc_Application_Stages__c == 'Credit Operation' && caseObj.Region_Flag__c == 'Jordan'){
               System.debug('Set Cases Accepted by Jordan Card Operations in cash collateral Jordan');
                setCashCollateralCaseAcceptedByJordanCardOperation.add(caseObj.id);
            } 
            if(caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && caseObj.cc_Card_Operations_Result__c == 'Return to Credit Admin' &&
               caseObj.cc_Card_Operations_Result__c != caseOldObj.cc_Card_Operations_Result__c && caseObj.cc_Application_Stages__c == 'Credit Operation' && caseObj.Region_Flag__c == 'Jordan'){
               System.debug('Set Cases Routed from Jordan Card Operations to Card Admin queue in cash collateral Jordan');
                setCashCollateralCaseReturnToCardAdminByJordanCardOperation.add(caseObj.id);
            } 
            if(caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && caseObj.cc_Card_Operations_Result__c == 'Refer to service center' &&
               caseObj.cc_Card_Operations_Result__c != caseOldObj.cc_Card_Operations_Result__c && caseObj.cc_Application_Stages__c == 'Credit Operation' && caseObj.Region_Flag__c == 'Jordan'){
               System.debug('Set Cases Routed from Jordan Card Operations to Card Admin queue in cash collateral Jordan');
                setCashCollateralCaseReferToServiceCenterByJordanCardOperation.add(caseObj.id);
            } 
           //CH07: END 
           /********************************************************** END : Jordan Card Operations - Cash Collateral Application Process only for Jordan *****************************************************/
 
            
           /******************************************************** Start : Cash Collateral Application - Staff Process(Bahrain) ****************************************************************/
            //CH07: Added Region Flag in if condition
             //CH12: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral')) && 
               recordtypeName == 'Credit Card Cash Collateral Staff' &&         
               (caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && caseObj.cc_HR_Result__c =='Approved') && (caseObj.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || caseObj.Is_Balance_Transfer__c == true) && caseObj.cc_Approved_Transfer_Type__c == 'Balance Transfer' && caseObj.Region_Flag__c == 'Bahrain')  
            {
                System.debug('Set Cases for HR Approval Balance Transfer in cash collateral'); 
                setCashCollateralCaseAcceptByHRForBalanceTransfer.add(caseObj.id);
            }
            //CH07: Added Region Flag in if condition
             //CH12: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral')) && 
               recordtypeName == 'Credit Card Cash Collateral Staff' &&         
               (caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && caseObj.cc_HR_Result__c =='Approved') && (caseObj.cc_Approved_Requested_Card_Type__c != 'PLATINUM_BALANCE_TRANSFER_01' && caseObj.Is_Balance_Transfer__c == false) && caseObj.cc_Approved_Requested_Card_Type__c != '' && caseObj.Region_Flag__c == 'Bahrain')  
            {
                System.debug('Set Cases for HR Approval Non Balance Transfer for Cash Collateral'); 
                setCashCollateralCaseAcceptByHRForNonBalanceTransfer.add(caseObj.id);
            }
            /******************************************************** END : Cash Collateral Application - Staff Process(Bahrain) ****************************************************************/

            /************************************************************ Start: Cash Collateral Limit Increase - Staff Process(Bahrain) *************************************************************************/
            //CH05: Start
            //CH07: Added Region Flag in if condition
            if(caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && recordtypeName == 'Cash Collateral Credit Limit Increase Staff' &&
               caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && caseObj.cc_HR_Result__c =='Approved' && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Set Cases for HR Approval in Cash Collateral Credit Limit Update');
                setCashCollateralLimitIncreaseCaseAcceptByHR.add(caseObj.id);
            }
            //CH05: END
            /************************************************************ END: Cash Collateral Limit Increase - Staff Process(Bahrain) *************************************************************************/

            /******************************************************** Start : Cash Collateral Application Decline Cases(Bahrain) ***********************************************************************/
            //CH02: Added extra brackets in if condition to avoid multiple future calls.
            //CH07: Added Region Flag in if condition
            //CH09: Start: Added a condition Signature Verifier Result = Decline in if Condition
            if((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') && 
               ((caseObj.cc_CEO_Result__c != caseOldObj.cc_CEO_Result__c && caseObj.cc_CEO_Result__c == 'Decline') ||
               (caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c && caseObj.cc_Credit_Approval_Result__c =='Decline') || 
               (caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && caseObj.cc_HR_Result__c =='Decline') || 
               (caseObj.cc_Business_Approval_Result__c != caseOldObj.cc_Business_Approval_Result__c && caseObj.cc_Business_Approval_Result__c =='Decline')||
               (caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c && caseObj.cc_Signature_Verifier_Result__c =='Decline')||
               (caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c && caseObj.cc_Credit_Pre_Screening_Result__c =='Decline')) && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside Decline Condition for Cash Collateral Bahrain');
                setCashCollateralCaseDecline.add(caseObj.id);
            }
            //CH09: END
            /******************************************************** END : Cash Collateral Application Decline Cases(Bahrain) ***********************************************************************/

            /*********************************************************** Start : Cash Collateral Application Decline Cases(Jordan) *******************************************************************/
            //CH07: Start
            //CH09: Start: Added a condition Signature Verifier Result = Decline in if Condition
            if((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') && 
               ((caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c && caseObj.cc_Credit_Approval_Result__c =='Decline') || 
                (caseObj.cc_Credit_Business_Team_L2_Result__c != caseOldObj.cc_Credit_Business_Team_L2_Result__c && caseObj.cc_Credit_Business_Team_L2_Result__c == 'Decline') ||
                (caseObj.cc_Credit_Business_Team_L3_Result__c != caseOldObj.cc_Credit_Business_Team_L3_Result__c && caseObj.cc_Credit_Business_Team_L3_Result__c == 'Decline') ||
                (caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c && caseObj.cc_Signature_Verifier_Result__c =='Decline')||
                (caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c && caseObj.cc_Credit_Pre_Screening_Result__c =='Decline')) && caseObj.Region_Flag__c == 'Jordan')
            {
                System.debug('Inside Decline Condition for Cash Collateral Bahrain');
                setCashCollateralCaseDecline.add(caseObj.id);
            }
            //CH09: END
            //CH07: END            
            /*********************************************************** END : Cash Collateral Application Decline Cases(Jordan) **********************************************************************/
             //CH05: Start
            /********************************************************* Start : Cash Collateral Limit Increase Decline Cases(Bahrain) ****************************************************************/
            //CH07: Added Region Flag in if condition
            //CH08: Added Jordan Region Flag & business L2 ,L2 Decline logic
            //CH09: Start: Added a condition Signature Verifier Result = Decline in if Condition
            if((caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase') && ((caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c && caseObj.cc_Credit_Pre_Screening_Result__c =='Decline')
            || (caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c && caseObj.cc_Credit_Approval_Result__c =='Decline') || (caseObj.cc_Business_Approval_Result__c != caseOldObj.cc_Business_Approval_Result__c && caseObj.cc_Business_Approval_Result__c =='Decline') || (caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && caseObj.cc_HR_Result__c =='Decline') || (caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c && caseObj.cc_Signature_Verifier_Result__c =='Decline')
             ||(CaseObj.cc_Credit_Business_Team_L2_Result__c!= caseOldObj.cc_Credit_Business_Team_L2_Result__c && CaseObj.cc_Credit_Business_Team_L2_Result__c=='Decline') ||(CaseObj.cc_Credit_Business_Team_L2_Result__c!= caseOldObj.cc_Credit_Business_Team_L3_Result__c && CaseObj.cc_Credit_Business_Team_L3_Result__c=='Decline')) && (caseObj.Region_Flag__c == 'Bahrain' || caseObj.Region_Flag__c == 'Jordan')){
                System.debug('Inside Decline Condition for Cash Collateral limit increase');
                setCashCollateralLimitIncreaseCaseDecline.add(caseObj.id);
            }
            /********************************************************* END : Cash Collateral Limit Increase Decline Cases(Bahrain) ****************************************************************/
            //CH09: END
            //CH05: END
            //CH06: Start
            /********************************************************* Start : Cash Collateral Limit Increase Cancelled by Customer Cases(Bahrain) ****************************************************************/
            //CH07: Added Region Flag in if condition 
            //CH08: Added Jordan Region Flag
            //CH09: Start: Added a condition Signature Verifier Result = Cancelled by Customer in if Condition
            if((caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase') && 
               ((caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c && caseObj.cc_Credit_Approval_Result__c =='Cancelled by Customer') || 
               (caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && caseObj.cc_HR_Result__c =='Cancelled by Customer') || (caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c && caseObj.cc_Signature_Verifier_Result__c =='Cancelled by Customer') || 
               (caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c && caseObj.cc_Credit_Pre_Screening_Result__c =='Cancelled by Customer')) && (caseObj.Region_Flag__c == 'Bahrain'||caseObj.Region_Flag__c == 'Jordan'))
            {
                System.debug('Inside CANCEL BY Customer Condition in Cash Collateral limit increase');
                setCashCollateralLimitIncreaseCaseCancelledByCustomer.add(caseObj.id);
            }
            //CH09: END
            /********************************************************* END : Cash Collateral Limit Increase Cancelled by Customer Cases(Bahrain) ****************************************************************/
            //CH06: END
            
            /********************************************************* Start : Cash Collateral Application Cancelled by Customer Cases for Bahrain & Jordan ****************************************************************/
            //CH02: Added extra brackets in if condition to avoid multiple future calls. 
            //CH07: Added Region Flag in if condition
            //CH09: Start: Added a condition Signature Verifier Result = Cancelled by Customer in if Condition
            if((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') && 
               ((caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c && caseObj.cc_Credit_Approval_Result__c =='Cancelled by Customer') || 
               (caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && caseObj.cc_HR_Result__c =='Cancelled by Customer') || (caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c && caseObj.cc_Signature_Verifier_Result__c =='Cancelled by Customer') || 
               (caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c && caseObj.cc_Credit_Pre_Screening_Result__c =='Cancelled by Customer')) && (caseObj.Region_Flag__c == 'Bahrain' || caseObj.Region_Flag__c == 'Jordan'))
            {
                System.debug('Inside CANCEL BY Customer Condition in Cash Collateral');
                setCashCollateralCaseCancelledByCustomer.add(caseObj.id);
            }
            //CH09: END
            /********************************************************* END : Cash Collateral Application Cancelled by Customer Cases for Bahrain & Jordan ****************************************************************/

             //CH03: Start
            //CH05: Start #Added Cash Collateral Limit Increase Condition in If block
            //CH07: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') || (caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase'))  && caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c && (caseObj.cc_Credit_Approval_Result__c == 'Approve' || caseObj.cc_Credit_Approval_Result__c == 'Decline') && (caseObj.Region_Flag__c == 'Bahrain' || caseObj.Region_Flag__c == 'Jordan')){
                mapCasetoAccount.put(caseObj.Id, caseObj.AccountId);
            }
             //CH07: Added Region Flag in if condition
             if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') || (caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) && caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && (caseObj.cc_HR_Result__c == 'Approve' || caseObj.cc_HR_Result__c == 'Decline') && caseObj.Region_Flag__c == 'Bahrain'){
                mapCasetoAccountHR.put(caseObj.Id, caseObj.AccountId);
            }
            //CH05: END
           //CH03: END
           //CH07: Start
           /***************************************************************** Start : CaseFeed Logic Cash Collateral Jordan **********************************************************/
            if(caseObj.cc_Credit_Pre_Screener_Comments__c !=caseOldObj.cc_Credit_Pre_Screener_Comments__c && caseObj.cc_Credit_Pre_Screener_Comments__c != null && caseObj.cc_Credit_Pre_Screener_Comments__c != '' && ((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') ||(caseObj.Sub_Type__c =='Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) && caseObj.Region_Flag__c == 'Jordan')
            {
                System.debug('Inside Prescreener Comments Jordan');
                CaseComment preScreenerComments = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Pre-Screener Comments - '+ caseObj.cc_Credit_Pre_Screener_Comments__c);
                lstComment.add(preScreenerComments);
            }
            if(caseObj.cc_Credit_Approver_Comments__c != caseOldObj.cc_Credit_Approver_Comments__c  && caseObj.cc_Credit_Approver_Comments__c != null && caseObj.cc_Credit_Approver_Comments__c  != '' && ((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') ||(caseObj.Sub_Type__c =='Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) && caseObj.Region_Flag__c == 'Jordan')
            {
                System.debug('Inside Approver Comments Jordan');
                CaseComment approvalComments  = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Approver Comments - '+ caseObj.cc_Credit_Approver_Comments__c);
                lstComment.add(approvalComments);
            } 
            if(caseObj.cc_Service_Centre_Comments__c != caseOldObj.cc_Service_Centre_Comments__c  && caseObj.cc_Service_Centre_Comments__c != null && caseObj.cc_Service_Centre_Comments__c != '' && ((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') ||(caseObj.Sub_Type__c =='Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) && caseObj.Region_Flag__c == 'Jordan')
            {
                System.debug('Inside Service Centre Comments Jordan');
                CaseComment serviceCentreComments  = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Service Centre Comments - '+ caseObj.cc_Service_Centre_Comments__c);
                lstComment.add(serviceCentreComments);
            }
            if(caseObj.cc_Contact_Centre_Comments__c != caseOldObj.cc_Contact_Centre_Comments__c && caseObj.cc_Contact_Centre_Comments__c != null && caseObj.cc_Contact_Centre_Comments__c != '' && ((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') ||(caseObj.Sub_Type__c =='Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) && caseObj.Region_Flag__c == 'Jordan')
            {
                System.debug('Inside Contact Centre Comments Jordan');
                CaseComment contactCentreComments  = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Contact Centre Comments - '+ caseObj.cc_Contact_Centre_Comments__c);
                lstComment.add(contactCentreComments);
            }
            if(caseObj.cc_Signature_Verification_Comments__c != caseOldObj.cc_Signature_Verification_Comments__c  && caseObj.cc_Signature_Verification_Comments__c != null && caseObj.cc_Signature_Verification_Comments__c  != '' && ((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') ||(caseObj.Sub_Type__c =='Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) && caseObj.Region_Flag__c == 'Jordan')
            {
                System.debug('Inside Signature Verifier Comments Jordan');
                CaseComment signatureVerifierComments  = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Signature Verifier Comments - '+ caseObj.cc_Signature_Verification_Comments__c );
                lstComment.add(signatureVerifierComments);
            }
            if(caseObj.cc_Credit_Business_Team_L2_Comments__c != caseOldObj.cc_Credit_Business_Team_L2_Comments__c  && caseObj.cc_Credit_Business_Team_L2_Comments__c != null && caseObj.cc_Credit_Business_Team_L2_Comments__c  != '' && ((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') ||(caseObj.Sub_Type__c =='Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) && caseObj.Region_Flag__c == 'Jordan')
            {
                System.debug('Inside Business L2 Comments Jordan');
                CaseComment businessL2Comments  = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Business L2 Comments - '+ caseObj.cc_Credit_Business_Team_L2_Comments__c );
                lstComment.add(businessL2Comments);
            }
            if(caseObj.cc_Credit_Business_Team_L3_Comments__c != caseOldObj.cc_Credit_Business_Team_L3_Comments__c  && caseObj.cc_Credit_Business_Team_L3_Comments__c != null && caseObj.cc_Credit_Business_Team_L3_Comments__c  != '' && ((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') ||(caseObj.Sub_Type__c =='Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) && caseObj.Region_Flag__c == 'Jordan')
            {
                System.debug('Inside Business L3 Comments Jordan');
                CaseComment businessL3Comments  = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Business L3 Comments - '+ caseObj.cc_Credit_Business_Team_L3_Comments__c );
                lstComment.add(businessL3Comments);
            }
            if(caseObj.cc_Credit_Admin_Comments__c != caseOldObj.cc_Credit_Admin_Comments__c  && caseObj.cc_Credit_Admin_Comments__c != null && caseObj.cc_Credit_Admin_Comments__c  != '' && ((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') ||(caseObj.Sub_Type__c =='Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) && caseObj.Region_Flag__c == 'Jordan')
            {
                System.debug('Inside Credit Admin Comments Jordan');
                CaseComment creditAdminComments  = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Admin Comments - '+ caseObj.cc_Credit_Admin_Comments__c );
                lstComment.add(creditAdminComments);
            }
            if(caseObj.cc_Card_Operation_Comments__c != caseOldObj.cc_Card_Operation_Comments__c  && caseObj.cc_Card_Operation_Comments__c != null && caseObj.cc_Card_Operation_Comments__c  != '' && ((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') ||(caseObj.Sub_Type__c =='Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) && caseObj.Region_Flag__c == 'Jordan')
            {
                System.debug('Inside Credit Card Operation Jordan');
                CaseComment cardOperationComments  = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Card Operation Comments - '+ caseObj.cc_Card_Operation_Comments__c );
                lstComment.add(cardOperationComments);
            }
           /***************************************************************** END : CaseFeed Logic Cash Collateral Jordan **********************************************************/
          //CH07: END
          //
            
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
        //#CH15 : Start
        if(!setCashCollateralLimitIncreaseCaseApprovedByApproverInApp.isEmpty()){
            System.debug('Credit Card Approver for InApp Scenario Cash Collateral Limit Increase-----> '+setCashCollateralLimitIncreaseCaseApprovedByApproverInApp);
            cc_DocuSignGetEnvelopeId.cc_DocuSignGetEnvelopeIdProcess(setCashCollateralLimitIncreaseCaseApprovedByApproverInApp);
        }
        //#CH15 : End
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
        //#CH15 : Start
        if(!setCashCollateralLimitIncreaseCaseResendBySignatureVerifierInApp.isEmpty()){
            System.debug('Testing for Future Call for Cash Collateral Limit Increase when signature verifier re-send In-App');
            cc_DocuSignGetEnvelopeId.cc_DocuSignGetEnvelopeIdProcess(setCashCollateralLimitIncreaseCaseResendBySignatureVerifierInApp);
        }
        //#CH15 : End
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
        
        if(!setCashCollateralLimitIncreaseCaseAcceptByCreditAdmin.isEmpty()){
             CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralLimitIncreaseCaseAcceptByCreditAdmin);
        }
        
        if(!setCashCollateralLimitIncreaseCaseAcceptByOperation.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralLimitIncreaseCaseAcceptByOperation);
        }
        /****************************************** END : Cash Collateral Limit Increase Application API Calls  **************************************/
        
        /******************************************************* Start: Cash Collateral Application Process API Calls ********************************************************************/
        //CH07: Start
         if(!setCashCollateralCaseAcceptByJordanSignatureVerifierForNonBalanceTransfer.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseAcceptByJordanSignatureVerifierForNonBalanceTransfer);
        }
        if(!setCashCollateralCaseReturnToCardAdminByServiceCenter.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseReturnToCardAdminByServiceCenter);
        }
        if(!setCashCollateralCaseReturnToCardOperationByServiceCenter.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseReturnToCardOperationByServiceCenter);
        }
        if(!setCashCollateralCaseAcceptedByCreditAdmin.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseAcceptedByCreditAdmin);
        }
        if(!setCashCollateralCaseReturnToSignatureVerifierByCreditAdmin.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseReturnToSignatureVerifierByCreditAdmin);
        }
        if(!setCashCollateralCaseReferToServiceCenterByCreditAdmin.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseReferToServiceCenterByCreditAdmin);
        }
        if(!setCashCollateralCaseAcceptedByJordanCardOperation.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseAcceptedByJordanCardOperation);
        }
        if(!setCashCollateralCaseReturnToCardAdminByJordanCardOperation.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseReturnToCardAdminByJordanCardOperation);
        }
        if(!setCashCollateralCaseReferToServiceCenterByJordanCardOperation.isEmpty()){
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseReferToServiceCenterByJordanCardOperation);
        }
        if(!lstComment.isEmpty()){
            insert lstComment;
        }
        //CH07: END
        
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
            System.debug('Cash Collateral Cases Approved by Approver:'+setCashCollateralCaseApprovedByApprover);
            CreditCardCashCollateral.CashCollateralCaseUpdate(setCashCollateralCaseApprovedByApprover);
            if(!test.isRunningTest()){
                DocuSignApexToolKit autoSendDocSign =  new DocuSignApexToolKit(setCashCollateralCaseApprovedByApprover);
                System.enqueueJob(autoSendDocSign);
            }
        }
        //#CH15 : Start
        if(!setCashCollateralCaseApprovedByApproverInApp.isEmpty()){
            System.debug('Credit Card Approver for InApp Scenario-----> '+setCashCollateralCaseApprovedByApproverInApp);
            cc_DocuSignGetEnvelopeId.cc_DocuSignGetEnvelopeIdProcess(setCashCollateralCaseApprovedByApproverInApp);
        }
        //#CH15 : End
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

        //#CH15 : Start
        if(!setCashCollateralCaseResendBySignatureVerifierInApp.isEmpty()){
            cc_DocuSignGetEnvelopeId.cc_DocuSignGetEnvelopeIdProcess(setCashCollateralCaseResendBySignatureVerifierInApp);
        }
        //#CH15 : End

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
        /******************************************************* END Cash Collateral Application Process API Calls ********************************************************************/
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
        //CH13: Start
        Set<Id> setCashCollateralSTPCases = new Set<Id>();
        Set<Id> setCashCollateralLMTIncreaseSTPCases = new Set<Id>();
        Set<Id> setCashCollateralCaseInProgressJO = new Set<Id>();
        Set<Id> setCashCollateralLimitIncreaseCaseInProgressJO = new Set<Id>();
        Set<Id> setCashCollateralCaseCreatingThroughApp = new Set<Id>();
		//CH13: END
        for(Case caseObj : lstCase) {
            /************************************************** Start: Cash Collateral Application for Bahrain & Jordan ******************************************************/
            //CH07: Start Added Region Flag in if condition
            //CH13: Start
             if(caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && caseObj.Sub_Status__c == 'In-Progress' && caseObj.Region_Flag__c == 'Bahrain'){
                 System.debug('Cash Collateral Case Without STP Case');
                 setCashCollateralCaseInProgress.add(caseObj.id);
            }
            if(caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && caseObj.Sub_Status__c == 'In-Progress' && caseObj.Region_Flag__c == 'Jordan'){
                 System.debug('Cash Collateral Case Without STP Case');
                 setCashCollateralCaseInProgressJO.add(caseObj.id);
            }
            if(caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && caseObj.Sub_Status__c == 'Documents Received' && caseObj.Region_Flag__c == 'Bahrain'  && caseObj.cc_CC_Application_Source__c == 'API'){
                 System.debug('Cash Collateral API Case Without STP Case');
                 setCashCollateralCaseCreatingThroughApp.add(caseObj.id);
            }
            //CH13: END
            //CH07: END
            /************************************************** END: Cash Collateral Application for Bahrain & Jordan ******************************************************/

            /************************************************** Start: Cash Collateral limit increase for Bahrain ***********************************************************/ 
            //CH05: Start
            System.debug('Cash Collateral LMT Increase Sub-status:'+caseObj.Sub_Status__c);
             //CH07: Added Region Flag in if condition
            //CH13: Added a condition STP in if condition
            if(caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && caseObj.Sub_Status__c == 'In-Progress' && caseObj.Region_Flag__c == 'Bahrain'){
                setCashCollateralLimitIncreaseCaseInProgress.add(caseObj.id);
            }
            if(caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && caseObj.Sub_Status__c == 'In-Progress' && caseObj.Region_Flag__c=='Jordan'){
                setCashCollateralLimitIncreaseCaseInProgressJO.add(caseObj.id);
            }
            //CH13: END
            //CH07: END
            //CH05: END
           /************************************************** END: Cash Collateral limit increase for Bahrain ***********************************************************/ 
            
         
        }
        //CH13: Start
        //// Query custom metadata
        STP__mdt stpConfig = [SELECT Enable__c,DeveloperName FROM STP__mdt WHERE DeveloperName = 'Default' LIMIT 1];
        if(!setCashCollateralCaseInProgress.isEmpty()){
            System.debug('Cash Collateral Case Creation Without STP is:'+setCashCollateralCaseInProgress);
            CreditCardCashCollateral.CashCollateralCaseCreation(setCashCollateralCaseInProgress);
            if(stpConfig.Enable__c){
                String hour = String.valueOf(Datetime.now().hour());
                String min = String.valueOf(Datetime.now().addMinutes(1).minute());
                String ss = String.valueOf(Datetime.now().second());
                String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                FetchBcrbSchedulable fetchBCRBSTP = new FetchBcrbSchedulable(setCashCollateralCaseInProgress);
                System.schedule('BCRB STP JOB RUNNING '+system.now(),nextFireTime,fetchBCRBSTP); 
            }
           
        }
        //CH05: Start
        if(!setCashCollateralCaseCreatingThroughApp.isEmpty()){
            System.debug('Cash Collateral Case Creation through App Without STP is:'+setCashCollateralCaseCreatingThroughApp);
            if(stpConfig.Enable__c){
                String hour = String.valueOf(Datetime.now().hour());
                String min = String.valueOf(Datetime.now().addMinutes(1).minute());
                String ss = String.valueOf(Datetime.now().second());
                String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                FetchBcrbSchedulable fetchBCRBSTP = new FetchBcrbSchedulable(setCashCollateralCaseCreatingThroughApp);
                System.schedule('BCRB STP JOB RUNNING '+system.now(),nextFireTime,fetchBCRBSTP);
            }
        }
        if(!setCashCollateralLimitIncreaseCaseInProgress.isEmpty()){
            System.debug('Testing for Future Call for Cash Collateral Limit Increase');
            CreditCardCashCollateral.CashCollateralCaseCreation(setCashCollateralLimitIncreaseCaseInProgress);
            if(stpConfig.Enable__c){
                String hour = String.valueOf(Datetime.now().hour());
                String min = String.valueOf(Datetime.now().addMinutes(1).minute());
                String ss = String.valueOf(Datetime.now().second());
                String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                FetchBcrbSchedulable fetchBCRBSTP = new FetchBcrbSchedulable(setCashCollateralLimitIncreaseCaseInProgress);
                System.schedule('BCRB STP JOB RUNNING LMT INCREASE '+system.now(),nextFireTime,fetchBCRBSTP);
            }
            

        }
        if(!setCashCollateralCaseInProgressJO.isEmpty()){
            System.debug('Cash Collateral Case Creation Jordan:'+setCashCollateralCaseInProgressJO);
            CreditCardCashCollateral.CashCollateralCaseCreation(setCashCollateralCaseInProgressJO);
        }
        if(!setCashCollateralLimitIncreaseCaseInProgressJO.isEmpty()){
            System.debug('Cash Collateral limit increase Case Creation Jordan:'+setCashCollateralLimitIncreaseCaseInProgressJO);
            CreditCardCashCollateral.CashCollateralCaseCreation(setCashCollateralLimitIncreaseCaseInProgressJO);
        }
        //CH13: END
        //CH05: END
        
        
    }
    
    public static void handlerBeforeCaseCreation(List<Case> lstCase){
         //CH03: Start
        //Set<Id> accIdset = new Set<Id>();
        //Map<Id,Account> mapAccount = new Map<Id,Account>();
        //CH03: END
        for(Case cs : lstCase){
            /************************************************** Start: Cash Collateral Application for Bahrain & Jordan ******************************************************/
            //CH07: Start Added a Region Flag
            if(cs.Type == 'Credit Card Cash Collateral Application' && cs.Sub_Type__c == 'New Cash Collateral' && (cs.Region_Flag__c == 'Bahrain' || cs.Region_Flag__c == 'Jordan')){
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
                //CH13: Start
                if(cs.ccol_Hold_Amount__c != null){
                   cs.ccol_Approved_Hold_Amount__c = cs.ccol_Hold_Amount__c;
                   cs.Approved_Hold_Amount_in_words__c = CreditCardCashCollateralSTP.convertDecimalToBahrainWords(cs.ccol_Approved_Hold_Amount__c);
                }
                //CH13: END
                   //CH03: Start
                    //accIdset.add(cs.AccountId);
                  //CH03: END
                
            }
            //CH07: END
           /************************************************** END: Cash Collateral Application for Bahrain & Jordan ******************************************************/

           /************************************************** Start: Cash Collateral limit increase for Bahrain ***********************************************************/ 
            //CH07: Start Added a Region Flag
            //CH05: Start
            //CH08: Added Jordan Condition
            if(cs.Type == 'Cash Collateral Credit Limit Increase Application' && cs.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && (cs.Region_Flag__c == 'Bahrain' || cs.Region_Flag__c == 'Jordan')){
                if(cs.ccol_Hold_Account__c != null && cs.ccol_Hold_Account__c != '')
                    cs.ccol_Approved_Hold_Account__c = cs.ccol_Hold_Account__c;
                if(cs.ccol_Hold_Account_IBAN__c != null && cs.ccol_Hold_Account_IBAN__c != '')
                    cs.ccol_Approved_Hold_Account_IBAN__c = cs.ccol_Hold_Account_IBAN__c;
                if(cs.cc_Requested_Credit_Limit__c != null)
                    cs.cc_Approved_Credit_Limit__c = cs.cc_Requested_Credit_Limit__c; 
                //CH11: Start
                if(cs.cc_Requested_Card_Type__c != null &&  cs.cc_Requested_Card_Type__c != ''){
                    cs.cc_Approved_Requested_Card_Type__c = cs.cc_Requested_Card_Type__c;
                }
                //CH11: END
                //CH13: Start
                if(cs.ccol_Hold_Amount__c != null /*&& cs.cc_CC_Application_Source__c == 'API'*/){
                   cs.ccol_Approved_Hold_Amount__c = cs.ccol_Hold_Amount__c;
                   cs.Approved_Hold_Amount_in_words__c = CreditCardCashCollateralSTP.convertDecimalToBahrainWords(cs.ccol_Approved_Hold_Amount__c);
                }
                //CH13: END
            }
            //CH05: END
            //CH07: END
           /************************************************** END: Cash Collateral limit increase for Bahrain ***********************************************************/ 

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
           //CH07: Start Added a Region flag 
           if((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && (caseObj.Region_Flag__c == 'Bahrain' || caseObj.Region_Flag__c == 'Jordan')) ||  (caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')){
               if(caseObj.ccol_Hold_Amount__c != null && caseOldObj.ccol_Hold_Amount__c != caseObj.ccol_Hold_Amount__c ){
                   caseObj.ccol_Approved_Hold_Amount__c = caseObj.ccol_Hold_Amount__c;
               }
               //CH13: Start
               if(caseObj.ccol_Approved_Hold_Amount__c != null && caseOldObj.ccol_Approved_Hold_Amount__c != caseObj.ccol_Approved_Hold_Amount__c){
                   caseObj.Approved_Hold_Amount_in_words__c = CreditCardCashCollateralSTP.convertDecimalToBahrainWords(caseObj.ccol_Approved_Hold_Amount__c);
               }
               //CH13: END
           }
           //CH07: END
            //CH01: Start
            //CH05: Added Type and Sub Type related to Cash Collateral Limit Increase in if block
            //CH07: Start Added a Region Flag
            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && (caseObj.Region_Flag__c == 'Bahrain' || caseObj.Region_Flag__c == 'Jordan')) ||(caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) && checkRecursive.runOnce()){
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
                //CH07: Start
                if(caseOldObj.cc_Credit_Business_Team_L2_Result__c != caseObj.cc_Credit_Business_Team_L2_Result__c && (caseObj.cc_Credit_Business_Team_L2_Result__c != '' || caseObj.cc_Credit_Business_Team_L2_Result__c != null) && caseObj.Region_Flag__c == 'Jordan'){
                   caseObj.cc_Credit_Business_Team_L2_By__c =  UserInfo.getUserId();
                }
                if(caseOldObj.cc_Credit_Business_Team_L3_Result__c != caseObj.cc_Credit_Business_Team_L3_Result__c && (caseObj.cc_Credit_Business_Team_L3_Result__c != '' || caseObj.cc_Credit_Business_Team_L3_Result__c != null) && caseObj.Region_Flag__c == 'Jordan'){
                   caseObj.cc_Credit_Business_Team_L3_By__c =  UserInfo.getUserId();
                }
                if(caseOldObj.cc_Credit_Admin_Result__c != caseObj.cc_Credit_Admin_Result__c && (caseObj.cc_Credit_Admin_Result__c != '' || caseObj.cc_Credit_Admin_Result__c != null) && caseObj.Region_Flag__c == 'Jordan'){
                   caseObj.cc_Credit_Admin_By__c =  UserInfo.getUserId();
                }
                if(caseOldObj.cc_Card_Operations_Result__c != caseObj.cc_Card_Operations_Result__c && (caseObj.cc_Card_Operations_Result__c != '' || caseObj.cc_Card_Operations_Result__c != null) && caseObj.Region_Flag__c == 'Jordan'){
                   caseObj.cc_Card_Operations_By__c =  UserInfo.getUserId();
                }
                //CH07: END
                
            }
            //CH07: END
            //CH01: END
            //CH10: Start
            if(caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && caseOldObj.Sub_Status__c != caseObj.Sub_Status__c && caseObj.Sub_Status__c == 'Cancelled' && caseObj.Region_Flag__c == 'Bahrain'){
                if(String.valueOf(caseObj.LastModifiedByID).contains((system.Label.AWS_Integration_User_ID))){
                   caseObj.Alias_account__c = 'API'; 
                }
            }
            //CH10: END
            //CH04: Start
            //CH07: Added Region Flag in if condition
             if(caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral' && ((caseOldObj.Campaign_Name__c != caseObj.Campaign_Name__c) || (caseOldObj.Campaign_Validity__c != caseObj.Campaign_Validity__c)) && caseObj.Region_Flag__c == 'Bahrain'){
                if(caseOldObj.Campaign_Name__c != caseObj.Campaign_Name__c && caseObj.Campaign_Name__c != null){
                    caseObj.Approved_Campaign_Name__c = caseObj.Campaign_Name__c;
                }
                if(caseOldObj.Campaign_Validity__c != caseObj.Campaign_Validity__c && caseObj.Campaign_Validity__c != null){
                    caseObj.Approved_Campaign_Validity__c = caseObj.Campaign_Validity__c;
                }
            }
            //CH07: END
            //CH04: END
            //CH13: Start
            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') || (caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) && caseObj.cc_Control_Type__c != caseOldObj.cc_Control_Type__c && caseObj.cc_Control_Type__c == 'STP' && caseObj.cc_Control_Type__c != null && caseObj.Region_Flag__c == 'Bahrain'){
                if(caseObj.cc_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' && (caseObj.cc_Approved_Transfer_Type__c == '' || caseObj.cc_Approved_Transfer_Type__c == null)){
                    caseObj.cc_Approved_Transfer_Type__c = 'Balance Transfer';
                }
                if(caseObj.cc_ID_Number__c != null){
                    caseObj.cc_CPR_Number__c = caseObj.cc_ID_Number__c;
                }
                
                if (String.isNotBlank(caseObj.cc_ID_Expiry_Date__c)) {
                    try {
                        List<String> parts = caseObj.cc_ID_Expiry_Date__c.split('/');
                        Date expiryDate;
                        if (parts.size() == 3) {
                            expiryDate = Date.newInstance(Integer.valueOf(parts[2]), Integer.valueOf(parts[1]), Integer.valueOf(parts[0]));
                        } else {
                            expiryDate = Date.valueOf(caseObj.cc_ID_Expiry_Date__c);
                        }
                        System.debug('expiryDate --> ' + expiryDate);
                        caseObj.cc_CPR_Expiry_Date__c = expiryDate;
                        System.debug('caseObj.cc_CPR_Expiry_Date__c --> ' + caseObj.cc_CPR_Expiry_Date__c);
                    } catch (Exception e) {
                        System.debug('️Error parsing date: ' + e.getMessage());
                    }
                } else {
                    System.debug('️cc_ID_Expiry_Date__c is blank');
                }
                
                caseObj.cc_Credit_Pre_Screening_Result__c = 'Accept';
                caseObj.cc_Credit_Pre_Screening_by__c = UserInfo.getUserId();
                //caseObj.cc_Credit_Pre_Screening_by__c = System.Label.INTEGRATION_USER;
                caseObj.cc_Credit_Pre_Screening_Result_Date_Time__c = System.now();
                caseObj.cc_Credit_Approval_Result__c = 'Approve';
                caseObj.cc_Application_Stages__c = 'Credit Approval';
                caseObj.cc_Credit_Approved_by__c = UserInfo.getUserId();
                //caseObj.cc_Credit_Approved_by__c = System.Label.INTEGRATION_USER;
                System.debug('Before Update for STP Case');
            }
            //CH14: Start Added a condition cc_Control_Type__c != 'STP' in if condition
            if(((caseObj.Type == 'Credit Card Cash Collateral Application' && caseObj.Sub_Type__c == 'New Cash Collateral') || (caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) && caseObj.cc_Control_Type__c != caseOldObj.cc_Control_Type__c && caseObj.cc_Control_Type__c != 'STP' && caseObj.cc_Control_Type__c != null && caseObj.Region_Flag__c == 'Bahrain'){
                caseObj.ownerID = system.label.CC_Prescreener;
            }
            //CH14: END
            //CH13: END
            
        }
        
    }
}