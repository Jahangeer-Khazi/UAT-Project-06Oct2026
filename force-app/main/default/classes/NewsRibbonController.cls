/********************************************************************************************
* @name                 NewsRibbonController
* @description          This controller is responsible to return the active message from CRM News Ribbon Obj.
* @date                 13/03/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           06/05/2025     Initial Version
*********************************************************************************************
*/

public class NewsRibbonController {

    @AuraEnabled(Cacheable=true)
    public static ApiConnection.Response getActiveNewsRibbon(Id recordId){
        final ApiConnection.Response response = new ApiConnection.Response();
        
        List<CRM_News_Ribbon__c  > records = [Select Id,Marquee_Direction__c,Message__c 
                                              FROM CRM_News_Ribbon__c 
                                              WHERE Active__c = TRUE 
                                              AND Expire_Date__c >= TODAY LIMIT 1];
        if(records.isEmpty()){
            response.isSuccess = false;
        }
        else {
            response.isSuccess = true;
            response.responseData = records;
        }
        return response;
    }
}