public class ConvertCreditCardHandler {
    public static void handlerBeforeCaseCreation(List<Case> lstCase){
        for(Case cs : lstCase){
            if(cs.Type == 'Convert Credit Card Nature Application' && cs.Sub_Type__c == 'Convert to Unsecured' && cs.Region_Flag__c == 'Bahrain'){
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
                if(cs.ccol_Hold_Account_IBAN__c != null)
                    cs.ccol_Approved_Hold_Account_IBAN__c = cs.ccol_Hold_Account_IBAN__c;
                if(cs.ccol_Hold_Account__c != null)
                    cs.ccol_Approved_Hold_Account__c = cs.ccol_Hold_Account__c;
            }
            if(cs.Sub_Status__c == 'Pending'){
                System.debug('Before creation of Credit Card Case checking Last Sub status Change for Pending');
                cs.cc_Last_Sub_Status_Changed_Pending__c = 'Not Changed';
                cs.LastCaseSubStatusChanged__c = System.now();
            }
        }//for loop Ends
    }
    public static void handlerBeforeCaseUpdate(List<Case> lstCase){
        for(Case caseObj : lstCase){
            Case caseOldObj = (Case)trigger.oldMap.get(caseObj.id);
            if(caseObj.Type == 'Convert Credit Card Nature Application' && caseObj.Sub_Type__c == 'Convert to Unsecured' && caseObj.Region_Flag__c == 'Bahrain' && checkRecursive.runOnce()){
                if(caseOldObj.cc_Credit_Pre_Screening_Result__c != caseObj.cc_Credit_Pre_Screening_Result__c 
                   && (caseObj.cc_Credit_Pre_Screening_Result__c != '' || caseObj.cc_Credit_Pre_Screening_Result__c != null )){
                       caseObj.cc_Credit_Pre_Screening_by__c = UserInfo.getUserId();
                       System.debug('Inside Pre-screener owner Updated by value');
                   }
                if(caseOldObj.cc_Credit_Evaluation_Result__c != caseObj.cc_Credit_Evaluation_Result__c 
                   && (caseObj.cc_Credit_Evaluation_Result__c != '' || caseObj.cc_Credit_Evaluation_Result__c != null)){
                       caseObj.cc_Credit_Evaluation_by__c = UserInfo.getUserId();
                       System.debug('Inside Evaluator owner Updated by value');
                   }
                if(caseOldObj.cc_Credit_Verification_Result__c != caseObj.cc_Credit_Verification_Result__c 
                   && (caseObj.cc_Credit_Verification_Result__c != '' || caseObj.cc_Credit_Verification_Result__c != null)){
                       caseObj.cc_Credit_Verified_by__c = UserInfo.getUserId();
                       System.debug('Inside verifier owner Updated by value');
                   }
                
                if(caseOldObj.cc_Credit_Approval_Result__c != caseObj.cc_Credit_Approval_Result__c 
                   && (caseObj.cc_Credit_Approval_Result__c != '' || caseObj.cc_Credit_Approval_Result__c != null)){
                       caseObj.cc_Credit_Approved_by__c = UserInfo.getUserId();
                       System.debug('Inside Approver owner Updated by value');
                   }
                if(caseOldObj.cc_Business_Approval_Result__c != caseObj.cc_Business_Approval_Result__c 
                   && (caseObj.cc_Business_Approval_Result__c != '' || caseObj.cc_Business_Approval_Result__c != null)){
                       caseObj.cc_Business_Approval_by__c = UserInfo.getUserId();
                       System.debug('Inside Business owner Updated by value');
                   }
                if(caseOldObj.cc_CEO_Result__c != caseObj.cc_CEO_Result__c 
                   && (caseObj.cc_CEO_Result__c != '' || caseObj.cc_CEO_Result__c != null)){
                       caseObj.cc_CEO_Result_by__c = UserInfo.getUserId();
                       System.debug('Inside CEO owner Updated by value');
                   }
                if(caseOldObj.cc_Service_Centre_Result__c != caseObj.cc_Service_Centre_Result__c 
                   && (caseObj.cc_Service_Centre_Result__c != '' || caseObj.cc_Service_Centre_Result__c != null)){
                       caseObj.cc_Service_Centre_by__c = UserInfo.getUserId();
                       System.debug('Inside Service center owner Updated by value');
                   }
                if(caseOldObj.cc_Signature_Verifier_Result__c != caseObj.cc_Signature_Verifier_Result__c 
                   && (caseObj.cc_Signature_Verifier_Result__c != '' || caseObj.cc_Signature_Verifier_Result__c != null)){
                       caseObj.cc_Signature_Verifier_by__c = UserInfo.getUserId();
                       System.debug('Inside signature verifier owner Updated by value');
                   }
                if(caseOldObj.cc_Operations_Result__c != caseObj.cc_Operations_Result__c 
                   && (caseObj.cc_Operations_Result__c != '' || caseObj.cc_Operations_Result__c != null)){
                       caseObj.cc_Operation_by__c = UserInfo.getUserId();
                       System.debug('Inside operations owner Updated by value');
                   }
                if(caseOldObj.cc_Contact_Centre_Result__c != caseObj.cc_Contact_Centre_Result__c 
                   && (caseObj.cc_Contact_Centre_Result__c != '' || caseObj.cc_Contact_Centre_Result__c != null)){
                       caseObj.cc_Contact_Center_by__c = UserInfo.getUserId();
                       System.debug('Inside contact center owner Updated by value');
                   }
            } //if Ends
            if(caseObj.Type == 'Convert Credit Card Nature Application' && caseObj.Sub_Type__c == 'Convert to Unsecured' ){
                if(caseObj.Basic_Salary__c == null){
                        caseObj.Basic_Salary__c = 0;
                    }
                    if(caseObj.Fixed_Allowances__c == null){
                        caseObj.Fixed_Allowances__c = 0;
                    }
                    if(caseObj.Variable_Allowances__c == null){
                        caseObj.Variable_Allowances__c = 0;
                    }
                    if(caseObj.Business_Income__c == null){
                        caseObj.Business_Income__c = 0;
                    }
                if(caseOldObj.Basic_Salary__c != caseObj.Basic_Salary__c || caseOldObj.Fixed_Allowances__c != caseObj.Fixed_Allowances__c || caseOldObj.Variable_Allowances__c != caseObj.Variable_Allowances__c || caseOldObj.Business_Income__c != caseObj.Business_Income__c){                  
                    caseObj.cc_Approved_Salary__c=caseObj.Basic_Salary__c + caseObj.Fixed_Allowances__c + caseObj.Variable_Allowances__c + caseObj.Business_Income__c;
                }
                if(caseObj.cc_Approved_Salary__c == 0){
                        caseObj.cc_Final_DBR__c = 0;
                }else{
                        caseObj.cc_Final_DBR__c = (caseObj.Final_Total_Obligations__c/ caseObj.cc_Approved_Salary__c)*100;
                }
            
                if(caseOldObj.cc_Credit_Bureau_Score__c != caseObj.cc_Credit_Bureau_Score__c && caseObj.cc_Credit_Bureau_Score__c > 850){
                    caseObj.addError('cc_Credit_Bureau_Score__c','Credit Score should be greater than or equal to 300 and less than or equal to 850');
                }
                else if(caseOldObj.cc_Credit_Bureau_Score__c != caseObj.cc_Credit_Bureau_Score__c && caseObj.cc_Credit_Bureau_Score__c < 300 && caseObj.cc_Credit_Bureau_Score__c > 0){
                    caseObj.addError('cc_Credit_Bureau_Score__c','Credit Score should be greater than or equal to 300 and less than or equal to 850');
                }
                else if(caseOldObj.cc_Credit_Bureau_Score__c != caseObj.cc_Credit_Bureau_Score__c && caseObj.cc_Credit_Bureau_Score__c == 0){
                    caseObj.cc_Credit_Bureau_Risk_Rating__c = '';
                }
                
                if(caseObj.cc_Credit_Bureau_Score__c >= 300 && caseObj.cc_Credit_Bureau_Score__c <= 449 && caseOldObj.cc_Credit_Bureau_Score__c != caseObj.cc_Credit_Bureau_Score__c){
                    caseObj.cc_Credit_Bureau_Risk_Rating__c = 'High Risk 300-450';
                }
                else if(caseObj.cc_Credit_Bureau_Score__c >= 450 && caseObj.cc_Credit_Bureau_Score__c <= 549 && caseOldObj.cc_Credit_Bureau_Score__c != caseObj.cc_Credit_Bureau_Score__c){
                    caseObj.cc_Credit_Bureau_Risk_Rating__c = 'Medium to High Risk 450-550';
                }
                else if(caseObj.cc_Credit_Bureau_Score__c >= 550 && caseObj.cc_Credit_Bureau_Score__c <= 649 && caseOldObj.cc_Credit_Bureau_Score__c != caseObj.cc_Credit_Bureau_Score__c){
                    caseObj.cc_Credit_Bureau_Risk_Rating__c = 'Medium Risk 550-650';
                }
                else if(caseObj.cc_Credit_Bureau_Score__c >= 650 && caseObj.cc_Credit_Bureau_Score__c <= 749 && caseOldObj.cc_Credit_Bureau_Score__c != caseObj.cc_Credit_Bureau_Score__c){
                    caseObj.cc_Credit_Bureau_Risk_Rating__c = 'Medium to Low Risk 650-750';
                }
                else if(caseObj.cc_Credit_Bureau_Score__c >= 750 && caseObj.cc_Credit_Bureau_Score__c <= 850 && caseOldObj.cc_Credit_Bureau_Score__c != caseObj.cc_Credit_Bureau_Score__c){
                    caseObj.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
                }
                else if(caseObj.cc_Credit_Bureau_Score__c == 0 && caseObj.cc_Credit_Bureau_Risk_Rating__c != 'Zero Score - 1st Facility' && caseObj.cc_Credit_Bureau_Risk_Rating__c != 'Zero Score - With Credit History' && caseObj.cc_Credit_Bureau_Risk_Rating__c != '' && caseObj.cc_Credit_Bureau_Risk_Rating__c != caseOldObj.cc_Credit_Bureau_Risk_Rating__c ){
                    caseObj.addError('cc_Credit_Bureau_Risk_Rating__c','Please select Zero Score option on Credit Bureau Risk Rating field');
                }
               
            }
            if(caseObj.Type == 'Convert Credit Card Nature Application' && caseObj.Sub_Type__c == 'Convert to Unsecured' && caseOldObj.Sub_Status__c != caseObj.Sub_Status__c &&
               (caseObj.Sub_Status__c == 'Pending' || caseObj.Sub_Status__c == 'Discrepancies' || caseObj.Sub_Status__c == 'Follow Up') && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Checking Sub Status values from Other State ------> Pending');
                   caseObj.cc_Last_Sub_Status_Changed_Pending__c = 'Not Changed';
                   caseObj.LastCaseSubStatusChanged__c = System.now();
               }
            
            if(caseObj.Type == 'Convert Credit Card Nature Application' && caseObj.Sub_Type__c == 'Convert to Unsecured' && caseOldObj.Sub_Status__c != caseObj.Sub_Status__c &&
               (caseObj.Sub_Status__c != 'Pending' && caseObj.Sub_Status__c != 'Discrepancies' && caseObj.Sub_Status__c != 'Follow Up')  && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Checking Sub Status values from Pending ------> Other State');
                   caseObj.cc_Last_Sub_Status_Changed_Pending__c = 'Changed';
                   caseObj.LastCaseSubStatusChanged__c = System.now();
               }
        } //for loop Ends
    }
     public static void handlerAfterCaseUpdate(List<Case> lstCase){
         List<CaseComment> lstComment = new List<CaseComment>();
         List<case> lstUpdatecase = new List<case>();

         for(Case caseObj : lstCase){
            Case caseOldObj = (Case)trigger.oldMap.get(caseObj.id);
            Case cse = new Case(Id = caseObj.Id);
            if(caseObj.Type == 'Convert Credit Card Nature Application' && caseObj.Sub_Type__c == 'Convert to Unsecured' && caseObj.cc_Credit_Pre_Screener_Comments__c !=caseOldObj.cc_Credit_Pre_Screener_Comments__c && caseObj.cc_Credit_Pre_Screener_Comments__c != null && caseObj.cc_Credit_Pre_Screener_Comments__c != '' )
            {
                System.debug('Inside Prescreener Comments');
                CaseComment preScreenerComments = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Pre-Screener Comments - '+ caseObj.cc_Credit_Pre_Screener_Comments__c);
                lstComment.add(preScreenerComments);
                cse.cc_Credit_Pre_Screener_Comments__c = '';
                lstUpdatecase.add(cse);
            }
            if(caseObj.Type == 'Convert Credit Card Nature Application' && caseObj.Sub_Type__c == 'Convert to Unsecured' && caseObj.cc_Credit_Evaluator_Comments__c !=caseOldObj.cc_Credit_Evaluator_Comments__c && caseObj.cc_Credit_Evaluator_Comments__c != null && caseObj.cc_Credit_Evaluator_Comments__c != '' )
            {
                System.debug('Inside Evaluator Comments');
                CaseComment EvalComm = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Evaluator Comments - '+ caseObj.cc_Credit_Evaluator_Comments__c);
                lstComment.add(EvalComm);
                cse.cc_Credit_Evaluator_Comments__c = '';
                lstUpdatecase.add(cse);
            }
            if(caseObj.Type == 'Convert Credit Card Nature Application' && caseObj.Sub_Type__c == 'Convert to Unsecured' && caseObj.cc_Credit_Verifier_Comments__c !=caseOldObj.cc_Credit_Verifier_Comments__c && caseObj.cc_Credit_Verifier_Comments__c != null && caseObj.cc_Credit_Verifier_Comments__c != '')
            {
                System.debug('Inside Verifier Comments');
                CaseComment VerifierComm = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Verifier Comments - '+ caseObj.cc_Credit_Verifier_Comments__c);
                lstComment.add(VerifierComm);
                cse.cc_Credit_Verifier_Comments__c = '';
                lstUpdatecase.add(cse);
            }
            if(caseObj.Type == 'Convert Credit Card Nature Application' && caseObj.Sub_Type__c == 'Convert to Unsecured' && caseObj.cc_Credit_Approver_Comments__c != caseOldObj.cc_Credit_Approver_Comments__c  && caseObj.cc_Credit_Approver_Comments__c != null && caseObj.cc_Credit_Approver_Comments__c  != '')
            {
                System.debug('Inside Approver Comments');
                CaseComment approvalComments  = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Approver Comments - '+ caseObj.cc_Credit_Approver_Comments__c);
                lstComment.add(approvalComments);
                cse.cc_Credit_Approver_Comments__c = '';
                lstUpdatecase.add(cse);
            } 
            if(caseObj.Type == 'Convert Credit Card Nature Application' && caseObj.Sub_Type__c == 'Convert to Unsecured' && caseObj.cc_Service_Centre_Comments__c != caseOldObj.cc_Service_Centre_Comments__c  && caseObj.cc_Service_Centre_Comments__c != null && caseObj.cc_Service_Centre_Comments__c != '')
            {
                System.debug('Inside Service Centre Comments');
                CaseComment serviceCentreComments  = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Service Centre Comments - '+ caseObj.cc_Service_Centre_Comments__c);
                lstComment.add(serviceCentreComments);
                cse.cc_Service_Centre_Comments__c = '';
                lstUpdatecase.add(cse);
            }
            if(caseObj.Type == 'Convert Credit Card Nature Application' && caseObj.Sub_Type__c == 'Convert to Unsecured' && caseObj.cc_Contact_Centre_Comments__c != caseOldObj.cc_Contact_Centre_Comments__c && caseObj.cc_Contact_Centre_Comments__c != null && caseObj.cc_Contact_Centre_Comments__c != '' )
            {
                System.debug('Inside Contact Centre Comments');
                CaseComment contactCentreComments  = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Contact Centre Comments - '+ caseObj.cc_Contact_Centre_Comments__c);
                lstComment.add(contactCentreComments);
                cse.cc_Contact_Centre_Comments__c = '';
                lstUpdatecase.add(cse);
            }
            if(caseObj.Type == 'Convert Credit Card Nature Application' && caseObj.Sub_Type__c == 'Convert to Unsecured' && caseObj.cc_Signature_Verification_Comments__c != caseOldObj.cc_Signature_Verification_Comments__c  && caseObj.cc_Signature_Verification_Comments__c != null && caseObj.cc_Signature_Verification_Comments__c  != '')
            {
                System.debug('Inside Signature Verifier Comments');
                CaseComment signatureVerifierComments  = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Signature Verifier Comments - '+ caseObj.cc_Signature_Verification_Comments__c );
                lstComment.add(signatureVerifierComments);
                cse.cc_Signature_Verification_Comments__c = '';
                lstUpdatecase.add(cse);
                
            }
            if(caseObj.Type == 'Convert Credit Card Nature Application' && caseObj.Sub_Type__c == 'Convert to Unsecured' && caseObj.cc_Credit_Business_Team_Comments__c !=caseOldObj.cc_Credit_Business_Team_Comments__c && caseObj.cc_Credit_Business_Team_Comments__c != null && caseObj.cc_Credit_Business_Team_Comments__c != '')
            {
                System.debug('Inside Business Team Comments');
                CaseComment BusinessComm = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Business Team Comments - '+ caseObj.cc_Credit_Business_Team_Comments__c);
                lstComment.add(BusinessComm);
                cse.cc_Credit_Business_Team_Comments__c = '';
                lstUpdatecase.add(cse);
            }
            if(caseObj.Type == 'Convert Credit Card Nature Application' && caseObj.Sub_Type__c == 'Convert to Unsecured' && caseObj.cc_CEO_Comments__c !=caseOldObj.cc_CEO_Comments__c && caseObj.cc_CEO_Comments__c != null && caseObj.cc_CEO_Comments__c != '')
            {
                System.debug('Inside CEO Comments');
                CaseComment ceoComments = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit CEO Comments - '+ caseObj.cc_CEO_Comments__c);
                lstComment.add(ceoComments);
                cse.cc_CEO_Comments__c = '';
                lstUpdatecase.add(cse);
            }
         } //for loop Ends
         if(!lstComment.isEmpty()){
            insert lstComment;
        }
         if(!lstUpdatecase.isEmpty()){
             update lstUpdatecase;
         }
     }
}