/********************************************************************************************
* @name                 SendEmailWaiverQueueable
* @description          This class would use to send a waiver email including the attachment (if the size is more than 5mb).
						Code coverage of this class is done under WaiverApprovalTriggerHandlerTest
* @date                 26/01/2026
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           26/01/2026     Initial Version
*********************************************************************************************
*/

public class SendEmailWaiverQueueable implements Queueable {

    private Id waiverId;
    private Id documentId;
    private Id waiverTemplateId;
    private String userEmail;
    
    public SendEmailWaiverQueueable(Id waiverId,Id documentId,Id waiverTemplateId,String userEmail){
    	this.waiverId = waiverId;
        this.documentId = documentId;
        this.waiverTemplateId = waiverTemplateId;
        this.userEmail = userEmail;
    }
    
    public void execute(QueueableContext context) {
    	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId(Label.Email_Contact_ID_Waiver_Approval); // User, Contact, or Lead
        email.setTemplateId(waiverTemplateId);
        email.setToAddresses(new String[]{ userEmail });
        email.setWhatId(waiverId); // Record related to template
        email.setSaveAsActivity(false);
        email.setTreatTargetObjectAsRecipient(false);
        email.setReplyTo(Label.Waiver_Email_Service_Email);
        
        ContentVersion cv = [SELECT Id, Title, VersionData, FileType 
                             FROM ContentVersion 
                             WHERE ContentDocumentId =:documentId];
        
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(cv.Title + '.' + cv.FileType);
        efa.setBody(cv.VersionData);
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { efa });
        
        try{
            Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            System.debug('Email has sent.' + result[0].isSuccess());
        }
        catch(System.Exception e){
            System.debug('Error ' + e.getMessage());
        }
    }
}