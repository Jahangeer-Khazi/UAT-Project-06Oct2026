public class CaseAnnexHandler {
    public static void loanApproverApproved(Map<Id,CaseAnnex__c> newMapValues,Map<Id,CaseAnnex__c> oldMapValues){
        Set<Id> caseIds = new Set<Id>();
        Map<Id,case> mapCaseInfo = new Map<Id,case>();
        for(CaseAnnex__c cx : newMapValues.values()){
            CaseAnnex__c oldcx = oldMapValues.get(cx.Id);
            if(cx.Case__c != null && cx.cx_ln_Credit_Approval_Result__c != oldcx.cx_ln_Credit_Approval_Result__c && cx.cx_ln_Credit_Approval_Result__c != null){
                caseIds.add(cx.Case__c);
            }
        }//for loop Ends
        if(caseIds.size()>0){
            System.debug('Case Ids are:'+caseIds.size());
            System.debug('Case Ids are:'+caseIds);
            for(Case cse : [Select id,cc_Credit_Pre_Screening_by__c,cc_Credit_Verified_by__c from Case where id = :caseIds]){
                mapCaseInfo.put(cse.id,cse);
            }
        }//if Ends
        for(CaseAnnex__c cannex: newMapValues.values()){
            CaseAnnex__c oldcx = oldMapValues.get(cannex.Id);
            if(mapCaseInfo.containsKey(cannex.Case__c)){
                Case c = mapCaseInfo.get(cannex.Case__c);
                if(cannex.cx_ln_Product__c == 'Unsecured'){
                    if(c.cc_Credit_Verified_by__c == UserInfo.getUserId() && cannex.cx_ln_Credit_Approval_Result__c == 'Approve' && cannex.cx_ln_Credit_Approval_Result__c != null &&
                       cannex.cx_ln_Credit_Approval_Result__c != oldcx.cx_ln_Credit_Approval_Result__c){
                           System.debug('Case Credit Verified by:'+c.cc_Credit_Verified_by__c);
                           System.debug('Loan Approved by:'+UserInfo.getUserId());
                           cannex.cx_Is_Verfied_And_Approved_By_Same_User__c = true;
                       }
                    else{
                        cannex.cx_Is_Verfied_And_Approved_By_Same_User__c = false;
                    }
                }else if(cannex.cx_ln_Product__c == 'Secured'){
                    if(c.cc_Credit_Pre_Screening_by__c == UserInfo.getUserId() && cannex.cx_ln_Credit_Approval_Result__c == 'Approve' && cannex.cx_ln_Credit_Approval_Result__c != null &&
                       cannex.cx_ln_Credit_Approval_Result__c != oldcx.cx_ln_Credit_Approval_Result__c){
                           System.debug('Case Credit Pre-screening by:'+c.cc_Credit_Pre_Screening_by__c);
                           System.debug('Loan Approved by:'+UserInfo.getUserId());
                           cannex.cx_Is_Verfied_And_Approved_By_Same_User__c = true;  
                       }
                    else{
                        cannex.cx_Is_Verfied_And_Approved_By_Same_User__c = false; 
                    }
                    
                }
                
            }
            
        }//for loop Ends
        
    } 
}