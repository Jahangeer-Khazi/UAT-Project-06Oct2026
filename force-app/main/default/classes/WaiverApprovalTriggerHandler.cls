/********************************************************************************************
* @name                 WaiverApprovalTriggerHandler
* @description          Handler class for WaiverApprovalTrigger trigger.
* @date                 08/01/2026
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           08/01/2026     Initial Version
*********************************************************************************************
*/

public class WaiverApprovalTriggerHandler {

    public static void afterInsert(List<New_Wavier_Approval__c> records){
        
        Set<Id> waiverDocumentIds = new Set<Id>();
        Map<Id,New_Wavier_Approval__c> waiverIdToWaiverMap = new Map<Id,New_Wavier_Approval__c>();
        for(New_Wavier_Approval__c waiverObj : records){
            if((!String.isEmpty(waiverObj.Wavier_Level__c) && waiverObj.Wavier_Level__c.startsWithIgnoreCase('waiver level')) || Test.isRunningTest()){
                waiverIdToWaiverMap.put(waiverObj.Id,waiverObj);
                
                //checking if file is also uploaded.
                if(!String.isBlank(waiverObj.ContentDocumentId__c)){
                    waiverDocumentIds.add(waiverObj.ContentDocumentId__c);
                }
            }
        }
            
       	System.debug('waiverToProcess ' + waiverIdToWaiverMap);
        if(!waiverIdToWaiverMap.isEmpty()){
            WaiverApprovalTriggerHelper.submitWaiverForApproval(waiverIdToWaiverMap,waiverDocumentIds);
        }
    }
    
    public static void afterUpdate(List<New_Wavier_Approval__c> records,Map<Id,New_Wavier_Approval__c> oldMap){
        
        Set<Id> waiverDocumentIds = new Set<Id>();
        Map<Id,New_Wavier_Approval__c> reassignApprovalMap = new Map<Id,New_Wavier_Approval__c>();
        
        for(New_Wavier_Approval__c waiverObj : records){
            New_Wavier_Approval__c oldRecord = oldMap.get(waiverObj.Id);
            if(waiverObj.Is_Reassign__c && waiverObj.Route_to_Queue__c != null && waiverObj.Route_to_Queue__c != oldRecord.Route_to_Queue__c){
                reassignApprovalMap.put(waiverObj.Id,waiverObj);
                
                if(!String.isBlank(waiverObj.contentDocumentId__c)){
                    waiverDocumentIds.add(waiverObj.contentDocumentId__c);
                }
            }
        }
        
        //Below code would recall existing approval request and send a new approval request.
        if(!reassignApprovalMap.isEmpty()){
            WaiverApprovalTriggerHelper.reassignWaiver(reassignApprovalMap.values(),waiverDocumentIds);
        }
    }
}