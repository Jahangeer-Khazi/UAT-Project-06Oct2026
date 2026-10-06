/********************************************************************************************
* @name                 WaiverApprovalTriggerHelper
* @description          Helper class for WaiverApprovalTriggerHandler.
* @date                 08/01/2026
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           08/01/2026     Initial Version
*********************************************************************************************
*/

public class WaiverApprovalTriggerHelper {

    public static void submitWaiverForApproval(Map<Id,New_Wavier_Approval__c> waiverMap,Set<Id> documentIds){
        
		Set<Id> waiverOwnerIds = new Set<Id>();        
        for(New_Wavier_Approval__c waiver : waiverMap.values()){
            
            if(waiver.OwnerId.getSObjectType() == Group.SObjectType){
                waiverOwnerIds.add(waiver.OwnerId);
            }
            
            //Create approval request for Waiver
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Auto submitted through trigger.');
            req.setProcessDefinitionNameOrId('Wavier_Approval_Process');
            req.setObjectId(waiver.id);
        	// Submit on behalf of a logged-in user
        	req.setSubmitterId(UserInfo.getUserId()); 
            Approval.ProcessResult processResult = Approval.process(req);
        }
        
        //sending an email to all the queue members
        sendEmailToApprover(waiverOwnerIds,waiverMap.values(),documentIds,false);
    }
    
    public static void reassignWaiver(List<New_Wavier_Approval__c> records,Set<Id> documentIds){
        Set<Id> waiverOwnerIds = new Set<Id>();
        Set<Id> waiverIds = new Set<Id>();
        for(New_Wavier_Approval__c waiver : records){
            if(waiver.OwnerId.getSObjectType() == Group.SObjectType){
                waiverOwnerIds.add(waiver.OwnerId);
                waiverIds.add(waiver.Id);
            }
        }
        
        Map<Id,ProcessInstanceWorkitem> waiverIdToWorkItemMap = new Map<Id,ProcessInstanceWorkitem>();
        for(ProcessInstanceWorkitem workItem :[SELECT Id,ActorId,Actor.Email,ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :waiverIds]){
            waiverIdToWorkItemMap.put(workItem.ProcessInstance.TargetObjectId,workItem);
        }
        
        List<ProcessInstanceWorkitem> itemsToUpdate = new List<ProcessInstanceWorkitem>();
        if(!waiverIdToWorkItemMap.isEmpty()){
            for(New_Wavier_Approval__c waiver : records){
                ProcessInstanceWorkitem workItem = waiverIdToWorkItemMap.get(waiver.Id);
                workItem.ActorId = waiver.OwnerId;
                itemsToUpdate.add(workItem);
            }
        }
        
        if(!itemsToUpdate.isEmpty()){
            update itemsToUpdate;
        }
        
        //sending an email to all the queue members
        sendEmailToApprover(waiverOwnerIds,records,documentIds,false);    
    }
    
    public static void sendEmailToApprover(Set<Id> waiverOwnerIds,List<New_Wavier_Approval__c> records,Set<Id> documentIds,Boolean isReminderEmail){
        Map<Id,List<String>> groupIdToUserListMap = new Map<Id,List<String>>();
        
        EmailTemplate waiverTemplates = [SELECT Id from EmailTemplate
                                         where developername = 'Wavier_Approval_Initial_Template'];
        
        Map<Id,ContentVersion> contentversionMap = new Map<Id,ContentVersion>();
        for(ContentVersion cv : [SELECT Id, Title, VersionData,ContentSize, FileType,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: documentIds]){
            contentversionMap.put(cv.ContentDocumentId,cv);
        }
        
        for(GroupMember member : [SELECT GroupId,UserOrGroupId,UserOrGroup.Email FROM GroupMember WHERE GroupId IN :waiverOwnerIds]){
            if(!groupIdToUserListMap.containsKey(member.GroupId)){
                groupIdToUserListMap.put(member.GroupId,new List<String>());
            }
            groupIdToUserListMap.get(member.GroupId).add(member.UserOrGroup.Email);
        }
        
        for(New_Wavier_Approval__c waiver : records){
            List<String> userEmails = groupIdToUserListMap.get(waiver.OwnerId);
            
            if(Test.isRunningTest()){
				User u = [Select Id,Email FROM User where username = 'testapproval_Waiver@test.com' LIMIT 1];	
                userEmails = new List<String>();
                userEmails.add(u.Email);
        	}
            
            //TODO: below code would be implemented for sending large size file through email
            /*
            ContentVersion waiverFile = contentversionMap.get(waiver.contentDocumentId__c);
            if(waiverFile != null && waiverFile.ContentSize > 5248000){
                //if file size is more than 5 mb then email would be send through queueable class.
                //Id waiverId,Id documentId,Id waiverTemplateId,String userEmail
                SendEmailWaiverQueueable(waiver.Id,waiver.contentDocumentId__c,waiverTemplates.Id,'<useremail>');
            }
            else {
                    //normal email 
           	}*/
            
            System.debug('groupIdToUserListMap ' + groupIdToUserListMap);
            System.debug('userEmails ' + userEmails);
            
            Boolean setActivity = true;
            for(String userEmail :userEmails){
            	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String[] fromAddresses = new String[] { Label.Waiver_Email_Service_Email };
                email.setTargetObjectId(Label.Email_Contact_ID_Waiver_Approval); // User, Contact, or Lead
                email.setTemplateId(waiverTemplates.Id);
                email.setToAddresses(new String[]{ userEmail });
				email.setWhatId(waiver.Id); // Record related to template
                email.setSaveAsActivity(setActivity);
                email.setTreatTargetObjectAsRecipient(false);
                email.setReplyTo(fromAddresses[0]);
                
                //file will be attached if file is there
                if(!String.isBlank(waiver.ContentDocumentId__c) && contentversionMap.containsKey(waiver.ContentDocumentId__c)){
                	ContentVersion cv = contentversionMap.get(waiver.contentDocumentId__c);
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(cv.Title + '.' + cv.FileType);
                    efa.setBody(cv.VersionData);
                    email.setFileAttachments(new Messaging.EmailFileAttachment[] { efa });
                }
                
                try{
                    Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                    setActivity = false;
                    System.debug('Email has sent.' + result[0].isSuccess());
                    System.debug('Email sent to the email adress - ' + email);
                }
                catch(System.Exception e){
                    System.debug('Error when sending email - ' + e.getMessage());
                    throw e;
                }
            }
        }
    }
}