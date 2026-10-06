/********************************************************************************************
* @name                 WaiverEmailHandler
* @description          This email service handler class is responsible for 'approval request' reply email,
*						it would check email body and extract the New Waiver record name and Approve or Reject based on email response.
*						Code coverage of this class is done under WaiverApprovalTriggerHandlerTest
* @date                 23/12/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           23/12/2025     Initial Version
*********************************************************************************************
*/

global class WaiverEmailHandler implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        //email.subject.contains('Wavier Approval Request') &&
        if(!String.isEmpty(email.subject) && !String.isEmpty(envelope.fromAddress)){
            
            System.debug('envelope from address ' + envelope.fromAddress);
            System.debug('InboundEmail from address ' + email.fromAddress);
            if(email.plainTextBody != null){
                system.debug('TrimmedLine body ' + email.plainTextBody);
                String[] emailBodylines = email.plainTextBody.split('\r?\n');
                Integer lineCounter = 0;
                String status = '';
                String comment = '';
                String waiverRecordName = '';
                for (String line : emailBodylines) {
                    String trimmedLine = line.trim();
                    if(lineCounter == 0){
                        //Check whether the record is approve or reject
                        system.debug('TrimmedLine approve/reject ' + trimmedLine);
                        status = trimmedLine;
                        lineCounter++;
                    }
                    else if(lineCounter == 1){
                        //Check whether the approve or reject comment.
                        system.debug('TrimmedLine comment ' + trimmedLine);
                        comment = trimmedLine;
                        lineCounter++;
                    }
                    
                    if(trimmedLine.contains('Object Record Number')){
                        system.debug('TrimmedLine ' + trimmedLine);
                        String[] recordParts = trimmedLine.split('Object Record Number - ');
                        system.debug('recordParts ' + recordParts);
                        waiverRecordName = recordParts[1].trim();
                        //waiverRecordName = trimmedLine.replace('*   Object Record Number - ','');
                        system.debug('Waiver Name ' + waiverRecordName);
                        break;
                    }
                }
                
                if(waiverRecordName != ''){
                    
                    //user might reply either @ilabank or @bank-abc.com
                    String[] emailParts = envelope.fromAddress.split('@');
                    
                    List<String> userEmails = new List<String>();
                    
                    //If user has email address @ilabank.com or @bank-abc.com domain, 
                    //then it might possible user has one of the email associated with so generating both the emails
                    if(emailParts[1] == 'ilabank.com' || emailParts[1] == 'bank-abc.com'){
                    	userEmails.add(emailParts[0] + '@ilabank.com');
	                    userEmails.add(emailParts[0] + '@bank-abc.com');    
                    }
                    else {
    					userEmails.add(envelope.fromAddress);
                    }
                    
                    New_Wavier_Approval__c waiverObj = [Select Id,CreatedById FROM New_Wavier_Approval__c WHERE Name =:waiverRecordName];
                    User approvalUser = [Select Id,Name FROM User WHERE Email IN:userEmails LIMIT 1];
                    
                    System.debug('waiverObj.CreatedById ' + waiverObj.CreatedById);
                    System.debug('approvalUser.Id ' + approvalUser.Id);
                    
                    //Checking if maker and checker are not same.
                    if(waiverObj.CreatedById != approvalUser.Id){
                        
                        List<ProcessInstanceWorkitem> workItems = [SELECT Id,ActorId FROM ProcessInstanceWorkitem 
                                                        WHERE ProcessInstance.TargetObjectId =: waiverObj.Id]; 
                                                        //AND ActorId =:approvalUser.Id];
                    
                        if(!workItems.isEmpty()){
                            
                        	if(status.containsIgnoreCase('approve') || status.containsIgnoreCase('yes')){ //it can be approve/approved/yes
                                status = 'Approve';
                            }
                            else if(status.containsIgnoreCase('reject') || status.containsIgnoreCase('no')){ //it can be reject/rejected/no
                                status = 'Reject';
                            }
                            
                            Approval.ProcessWorkitemRequest approvalReq = new Approval.ProcessWorkitemRequest();
                            approvalReq.setWorkItemId(workItems[0].Id);
                            approvalReq.setAction(status);
                            approvalReq.setComments(comment);
                            Approval.ProcessResult approvalResult = Approval.process(approvalReq); 
                            waiverObj.Approved_By__c = approvalUser.Name;
                            update waiverObj;
                        }
                        else {
                            //Sending acknowledge email.
                            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'donotreply@ilabank.com'];
                            EmailTemplate waiverTemplates = [SELECT Id,HTMLValue from EmailTemplate 
                                                             WHERE developername = 'Wavier_Approval_Acknowledge'];
                            
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
							
                            mail.setWhatId(waiverObj.Id);
                            mail.setTemplateId(waiverTemplates.Id);
                            mail.setTargetObjectId(Label.Email_Contact_ID_Waiver_Approval);
                            mail.setOrgWideEmailAddressId(owea[0].Id);
                            mail.setToAddresses( new List<String>{ envelope.fromAddress });
                            mail.setTreatTargetObjectAsRecipient(false);
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                            
                            //waiverObj.Email_Approver_User__c  = approvalUser.Id;
                            //update waiverObj;
                        }
                    }
                    else {
                        System.debug('Maker and Checker must not be same.');
                        //TODO: we might need send an email to approver, when maker and checker are same.
                    }
                }
            }
        }
        return result;
    }
}