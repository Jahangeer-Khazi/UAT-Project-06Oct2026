/**
* @author Aniss Mbarki
* @date Création 11/10/2024
* @date Modification
* @description : to handle credit card Comment Cleaning for Jordan
*/
public without sharing class cc_CommentCleaning {
    
    private static String CLASS_NAME = cc_CommentCleaning.class.getName();
    private static List<System_Action__c> lstSA = new List<System_Action__c>();
    private static Map<String, Schema.SObjectField> caseFieldMap = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap();
    private static List<CaseComment> lstComment = new List<CaseComment>();

    @InvocableMethod(label='credit card Comment Cleaning for Jordan' description='credit card Comment Cleaning for Jordan')
    public static List<String> commentCleaningFromFlow(List<Case> cases)
    {
        Case caseObj = cases.get(0);
        try{

            String commentFieldsToClean_JO = system.Label.CommentFieldsToClean_JO;
            List<String> commentFields = commentFieldsToClean_JO.split(';');

            for(String fieldApiName : commentFields){
                String commentResult = (String)caseObj.get(fieldApiName);
                if( commentResult != null ){
                    CaseComment resultComm = new CaseComment( ParentID=caseObj.id, CommentBody= getCaseFieldLabelBasedOnApiName(fieldApiName) + ' - '+ commentResult );
                    System.debug('commentCleaningFromFlow --->>'+resultComm);
                    lstComment.add(resultComm);
                    caseObj.put(fieldApiName,null);
                }
            }

            if(lstComment != null && lstComment.size()>0){
                insert lstComment;
                update caseObj;
            }
            
        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            insert SM001_ApiCalls.setSystemAction( e.getMessage(),String.valueOf(e.getStackTraceString()),
                                                  null,null,
                                                  caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                  'please check : '+CLASS_NAME+'.commentCleaningFromFlow()', caseObj.Type
                                                 );
        }
        
        List<String> strLst = new List<String>();
        for(Case cs : cases){
            strLst.add(cs.Id);
        }
        return strLst;
    }

    // Method to get the field label from the Case base on field API name
    public static String getCaseFieldLabelBasedOnApiName(String fieldApiName) {
        // Check if the field exists and return its label
        if (caseFieldMap.containsKey(fieldApiName)) {
            return caseFieldMap.get(fieldApiName).getDescribe().getLabel();
        } else {
            return null;
        }
    }
}