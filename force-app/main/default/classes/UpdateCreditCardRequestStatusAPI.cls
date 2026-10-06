public without sharing class UpdateCreditCardRequestStatusAPI {
    
    private static String CLASS_NAME = UpdateCreditCardRequestStatusAPI.class.getName();
    
    @InvocableMethod(label='Update Credit Card Request Status API' description='The purpose of this service is to Update Credit Card Request Status API' callout=true )
    public static void updateCreditCardRequestStatusApiFromFlow(List<RequestApi> reqApi){
        Set<Id> caseIds= new Set<Id>();
        String notifType = reqApi.get(0).notifType;
        for(RequestApi req : reqApi){
            caseIds.add(req.caseId);
        }
        //call future method
        updateCreditCardRequestStatusApi(new Set<Id>(caseIds),notifType);
    } 

    @future(callout=true)
    public static void updateCreditCardRequestStatusApi(Set<Id> caseIds,String notifType){

        List<Case> cases = DM002_Case.getListByIds(caseIds);
        List<Case> caseToUpdate = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();

        for(Case caseObj : cases){
            HttpResponse response = SM001_ApiCalls.updateCreditCardRequestStatusApi(new ApiConnection(),caseObj,notifType);
            if(response.getStatusCode() != 200){
                System.debug('Invalid Update Credit Card Request Status API');
            }
            else{
                System.debug('Update Credit Card Request Status API Getting Success Status Code from API');
                if(notifType == 'EXPIRED'){
                    caseObj.Sub_Status__c = 'Expired';
                    caseObj.Status = 'Closed';
                    caseToUpdate.add(caseObj);
                }else if(notifType == 'PENDING') {
                    caseObj.Sub_Status__c = 'Pending';
                    caseObj.OwnerId = System.Label.Credit_Card_Temp;
                    caseObj.Awaiting_Customer_Feedback__c = false;
                    caseToUpdate.add(caseObj);
                }
            }
        }
        
        if(caseToUpdate.size()>0){
            update caseToUpdate;
        }
    }

    public class RequestApi {
        @InvocableVariable(label='Case Id' description='the Id of the Case' required=true)
        public Id caseId;

        @InvocableVariable(label='Notification Type' description='Notification Type' required=true)
        public String notifType;
    }
}