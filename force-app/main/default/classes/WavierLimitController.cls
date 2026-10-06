/********************************************************************************************
* @name                 WavierLimitController
* @description          This controller is responsible to return the list of Wavier Budget list
* @date                 27/07/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           27/07/2025     Initial Version
*********************************************************************************************
*/

public class WavierLimitController {

    @AuraEnabled(Cacheable=true)
    public static ApiConnection.Response getWavierLimit(){
        
    	ApiConnection.Response response = new ApiConnection.Response();
        List<Budget_Matrix__c> listOfBudgetMatrix = new List<Budget_Matrix__c>();
        
        response.isSuccess = false;
        listOfBudgetMatrix = [SELECT Id, Name, Role_Name__c, Budget__c, Utilization__c, 
                              Remaining_Limit__c, CRM_Queue__c,Max_Waiver_Amount__c  
                              FROM Budget_Matrix__c];
        
        response.isSuccess = true;
        response.responseData = listOfBudgetMatrix;
        
        return response;
    }
    
    @AuraEnabled(Cacheable=true)
    public static ApiConnection.Response getWavierHistory(String recordId){
		ApiConnection.Response response = new ApiConnection.Response();
        response.isSuccess = false;
        List<New_Wavier_Approval__c> wavierApprovals = [Select Id,Name,Claim_Amount__c, Approval_Status__c,
                                                        CreatedBy.Name,CreatedDate
                                                        FROM New_Wavier_Approval__c
                                                       WHERE Customer__c =:recordId
                                                       ORDER BY CreatedDate Desc LIMIT 5];
        if(!wavierApprovals.isEmpty()){
            response.isSuccess = true;
            response.responseData = wavierApprovals;
        }
        return response;
    }
}