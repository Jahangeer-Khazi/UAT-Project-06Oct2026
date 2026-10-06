/********************************************************************************************
* @name                 JordanCaseEmailRouterHandler
* @description          This email service class would fetch the Jordan case email thread reply and attach it to respective record
* @date                 23/12/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           02/11/2025     Initial Version
*********************************************************************************************
*/

global class JordanCaseEmailRouterHandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
    	Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        if(!String.isEmpty(email.subject) && email.subject.contains('[JL-')){
            Boolean hasAttachment = false;
            Id existingRecordId = findExistingEmailForJordanLoan(email.subject);
            EmailMessage em = new EmailMessage();
            em.FromAddress = envelope.fromAddress;
            em.ToAddress = envelope.toAddress;
            em.Subject = email.subject;
            em.TextBody = email.plainTextBody;
            em.HtmlBody = email.htmlBody;
            if(existingRecordId != null){
            	em.RelatedToId = existingRecordId;    
            }
            em.Incoming = true;
            em.Status = '3'; // Completed
            
            System.debug('Email Object ' + email);
            System.debug('Email Object Binary ' + email.binaryAttachments);
            if(email.binaryAttachments != null && !email.binaryAttachments.isEmpty()){
                List<Attachment> listAttachments = new List<Attachment>();
                for (Messaging.InboundEmail.BinaryAttachment bAttachment : email.binaryAttachments) {
                    System.debug('Email Object bAttachment ' + bAttachment);
                    
                    if (bAttachment.fileName != null && Pattern.matches('(?i)^image\\d{6}\\.png$', bAttachment.fileName)) {
                    	// Skip this inline image
                        continue;
                    }
                    Attachment attach = new Attachment();
                    attach.Name = bAttachment.fileName;
                    attach.Body = bAttachment.body;
                    attach.ParentId = existingRecordId;
                    listAttachments.add(attach);
                    hasAttachment = true;
                }
                insert listAttachments;
            }
            
            System.debug('Email text attachment Binary ' + email.textAttachments);
            // Process Text Attachments
            if (email.textAttachments != null && !email.textAttachments.isEmpty()) {
                List<Attachment> listTextAttachments = new List<Attachment>();
                for (Messaging.InboundEmail.TextAttachment tAttachment : email.textAttachments) {
                    Attachment attach = new Attachment();
                    attach.Name = tAttachment.fileName;
                    attach.Body = Blob.valueOf(tAttachment.body);
                    attach.ParentId = existingRecordId;
                    listTextAttachments.add(attach);
                    hasAttachment = true;
                }
                insert listTextAttachments;
            }
            
            
            
            insert em;
            
            System.debug('record has inserted ' + em);
            System.debug('hasAttachment ' + hasAttachment);
            //notify CRM User Queue about the attachment.
            if(hasAttachment){
                List<String> userEmailList = new List<String>();
                for(GroupMember member : [Select Id,UserOrGroupId,UserOrGroup.Email FROM GroupMember WHERE Group.DeveloperName =: Label.CRM_User_Queue]){
                    if (String.valueOf(member.UserOrGroupId).startsWith('005')) {
                        userEmailList.add(member.UserOrGroup.Email);
                    }
                }  
                
                System.debug('userEmailList ' + userEmailList);
                
                //In order to trigger the email we need a dummy contact record so I'm using Ashish's record because it would available on both UATX and PROD
            	List<Contact> contactRecordList = [Select Id FROM Contact where Firstname = 'Ashish' and LastName = 'Pandey' LIMIT 1];
            	System.debug('contactRecordList ' + contactRecordList);
                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                EmailTemplate template = [Select Id FROM EmailTemplate WHERE developername = 'JO_Jordan_Loan_Email_Attachment'];
                OrgWideEmailAddress owe = [select Id from OrgWideEmailAddress where Address =: Label.Jordan_Loan_From_Address];
                
                if(!contactRecordList.isEmpty()){
                	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(contactRecordList[0].Id);
                    mail.setWhatId(existingRecordId);
                    mail.setTemplateId(template.Id);
                    mail.setSaveAsActivity(false);
                    mail.setOrgWideEmailAddressId(owe.Id);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setToAddresses(userEmailList);
                    emails.add(mail); 
                    
                    try{
                        Messaging.SendEmailResult [] emailResult = Messaging.sendEmail(emails);
                        System.debug('Email has sent.' + emailResult[0].isSuccess());
                    }
                    catch(System.Exception e){
                        System.debug('Error 107 ' + e.getMessage());
                        throw e;
                    }
                }
                
                
            }
            
            
        }
        return result;
    }
    
    /*
     * @description -  Find existing request using subject for Jordan loan only.
     */ 
    private Id findExistingEmailForJordanLoan(string emailSubject){
        
        try {
            System.debug('emailSubject ' + emailSubject);
        	Pattern subjectPattern = Pattern.compile('\\[JL-\\s*([A-Za-z0-9]+)\\]');
            Matcher matcherSubject = subjectPattern.matcher(emailSubject);
            
            if (matcherSubject.find()) {
                String partialSubject = '%' + matcherSubject.group(1) + '%';
                System.debug('partialSubject ' + partialSubject);
                List<EmailMessage> emailList = [Select Id,RelatedToId FROM EmailMessage WHERE Subject like :partialSubject];
            
                if(emailList.isEmpty()) return null;
                
                return emailList[0].RelatedToId;
            }
            
            return null;    
        }
        catch(Exception ex){
            System.debug('Error while extracting the threadID from subject ' + ex.getMessage());
            return null;
        }        
        
    }
}