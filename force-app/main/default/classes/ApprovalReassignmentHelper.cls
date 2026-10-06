/********************************************************************************************
* @name                 ApprovalReassignmentHelper
* @description          This helper class has invocable method, which use to reassign the approval process
* @date                 29/07/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           29/07/2025     Initial Version
*********************************************************************************************
*/

public class ApprovalReassignmentHelper {

    public class Input {
        @InvocableVariable(label='Record Id') public Id recordId;
        @InvocableVariable(label='Content Document Id') public Id contentDocumentId;
    }
    
    @InvocableMethod(label='Reassign Approval Work Item')
    public static void reassign(List<Input> inputs) {
        
        if(!inputs.isEmpty()){
            
            String recordId = inputs[0].recordId;
            String documentId = inputs[0].contentDocumentId;
            List<ProcessInstanceWorkItem> items = [SELECT Id, ActorId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkItem 
                                               WHERE ProcessInstance.TargetObjectId = :recordId];
            
            //ProcessInstance pi = [Select Id FROM ProcessInstance WHERE TargetObjectId = :recordId AND Status = 'Pending'];
            if(!items.isEmpty()){
                //items[0].ActorId = newApproverId;
                //Approval.reassignWorkItem(items[0].Id,newApproverId);
                //Recalling existing request.
                Approval.ProcessWorkItemRequest recallReq = new Approval.ProcessWorkItemRequest();
                recallReq.setComments('Recalling Approval process record to change the owner.');
                recallReq.setAction('Removed');
                recallReq.setWorkItemId(items[0].Id);
                Approval.ProcessResult recallResult = Approval.process(recallReq);

                List<New_Wavier_Approval__c> records = new List<New_Wavier_Approval__c>();
                New_Wavier_Approval__c waiverObj = new New_Wavier_Approval__c();
                waiverObj.Id = recordId;
                records.add(waiverObj);
                
                Map<Id,Id> waiverIdToContentDocumentIdMap = new Map<Id,Id>();
                
                if(!String.isEmpty(documentId)){
                    waiverIdToContentDocumentIdMap.put(documentId,recordId);
				}
                
				WaiverApprovalTriggerHelper.submitWaiverForApproval(records,waiverIdToContentDocumentIdMap);               
                //Resubmitting the new Approval requeset.
                //Approval.ProcessSubmitRequest newReq = new Approval.ProcessSubmitRequest();
                //newReq.setObjectId(recordId);
                //Approval.ProcessResult submitResult = Approval.process(newReq);
                //update items;
            }
        }
        
    }
}