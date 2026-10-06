public class DeclineReasonMapping {
    public static String fetchDeclineMappingValue(String caseId){
        Case cse = [Select Id,cc_Approver_Decline_Reason__c,cc_Business_team_Decline_Reason__c,cc_CEO_Decline_Reason__c,cc_Credit_Fraud_Team_Decline_Reason__c,cc_Evaluator_Decline_Reason__c,
                   cc_Pre_screener_Decline_Reason__c,cc_Verifier_Decline_Reason__c from Case Where id =: caseId];
        
        String declineReason;
        if(cse.cc_Approver_Decline_Reason__c != null){
            declineReason = cse.cc_Approver_Decline_Reason__c;
        }else if(cse.cc_Business_team_Decline_Reason__c != null){
            declineReason = cse.cc_Business_team_Decline_Reason__c;
        }else if(cse.cc_CEO_Decline_Reason__c != null){
             declineReason = cse.cc_CEO_Decline_Reason__c;
        }else if(cse.cc_Credit_Fraud_Team_Decline_Reason__c != null){
             declineReason = cse.cc_Credit_Fraud_Team_Decline_Reason__c;
        }else if(cse.cc_Evaluator_Decline_Reason__c != null){
            declineReason = cse.cc_Evaluator_Decline_Reason__c;
        }else if(cse.cc_Pre_screener_Decline_Reason__c != null){
           declineReason = cse.cc_Pre_screener_Decline_Reason__c; 
        }else if(cse.cc_Verifier_Decline_Reason__c != null){
            declineReason = cse.cc_Verifier_Decline_Reason__c;
        }
        if(declineReason != null){
            List<String> declineReasonList = declineReason.split(';');
            List<Decline_Reason_Mapping__mdt> dMap = [Select Label,Decline_Reason_Mapping_Value__c from Decline_Reason_Mapping__mdt];
            Map<String,String> declineMapping = new Map<String, String>();
            Set<String> lstMappingValues = new Set<String>();
            for(Decline_Reason_Mapping__mdt dm : dMap){
                declineMapping.put(dm.Label,dm.Decline_Reason_Mapping_Value__c);
            }//for Ends
            if(declineReasonList.size()>0){
                for(String decReason : declineReasonList){
                    String getMappingValue;
                    if(declineMapping.containsKey(decReason)){
                        getMappingValue = declineMapping.get(decReason);
                        lstMappingValues.add(getMappingValue);
                    }
                }
            }//If Ends
            System.debug('Decline Reason Mapping Values:'+lstMappingValues);
            String apiMappingValue = String.join(new List<String>(lstMappingValues), ';');
            System.debug('Decline Reason Mapping Values Semicolon Separated:'+apiMappingValue);
            return apiMappingValue;
        }
        else{
            System.debug('Getting Blank values from Decline Reason Field');
            return '';
        }
        
    }

}