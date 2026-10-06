/********************************************************************************************
* @name                 CustomEmailComposerController
* @description          Email composer class would be responsible to send an email and return the jordan loan record.
* @date                 12/01/2026
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           12/01/2026     Initial Version
*********************************************************************************************
*/


public class CustomEmailComposerController {

    public static Boolean bypassTrigger = false;
    
    @AuraEnabled
    public static void sendEmail(String toAddress, String ccAddress, String subject, String body,String recordId) {
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        	OrgWideEmailAddress owe = [select Id from OrgWideEmailAddress where Address =: Label.Jordan_Loan_From_Address];
            String[] fromAddresses = new String[] {Label.Jordan_Reply_To_Email};
            String[] toAddresses = new String[] {toAddress};
            mail.setToAddresses(toAddresses);
            if(!String.isEmpty(Label.Jordan_Reply_To_Email)){
            	mail.setReplyTo(Label.Jordan_Reply_To_Email);
            }
            
            if(!String.isEmpty(ccAddress)){
                String[] ccAddresses = new String[] {ccAddress};
                mail.setCcAddresses(ccAddresses);
            }
            
            mail.setWhatId(recordId);
            mail.setSubject(subject);
            mail.setHtmlBody(body);
            mail.setOrgWideEmailAddressId(owe.Id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        }
        catch(Exception ex){
            
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getJordanCase(String recordId) {
		Map<String,Object> mapOfData = new Map<String,Object>();
        Jordan_Loan__c jordanLoan = [Select Id,Name,Customer__r.personEmail,Customer__r.Name 
                                     FROM Jordan_Loan__c 
                                     WHERE Id =:recordId LIMIT 1];
        
        String template = '';
        List<EmailTemplate> templates = [Select Id,HtmlValue FROM EmailTemplate WHERE DeveloperName = 'Documents_Required' LIMIT 1];
        
        //Contact_First_Name__c 
        if(!templates.isEmpty()){
            template = templates[0].HtmlValue;
        }
        
        mapOfData.put('jordanCase',jordanLoan);
        mapOfData.put('htmlTemplate',template);
        return mapOfData;
    }
    
    @AuraEnabled
    public static String updateQueueOwner(Id recordId,String queueName) {
        Map<String,Id> jordanQueueMap = new Map<String,Id>();
        for(Group grp : [Select Id,DeveloperName FROM Group WHERE DeveloperName IN ('Jordan_Ultimate_LOS_Backoffice','Jordan_LOS_Backoffice_queue','Jordan_Loans_Queue')]){
            jordanQueueMap.put(grp.DeveloperName,grp.Id);
        }

		Jordan_Loan__c jrLoan = [Select Id,Segment__c FROM Jordan_Loan__c WHERE Id =:recordId LIMIT 1];
        
        if(queueName == 'Jordan Loans Queue'){
            jrLoan.OwnerId = jordanQueueMap.get('Jordan_Loans_Queue');
        }
        else {
        	
        	if(jrLoan.Segment__c == 'Ultimate'){
                jrLoan.OwnerId = jordanQueueMap.get('Jordan_Ultimate_LOS_Backoffice');
            }
            else {
                jrLoan.OwnerId = jordanQueueMap.get('Jordan_LOS_Backoffice_queue');
            }
        }
        
        try {
            CustomEmailComposerController.bypassTrigger = true;
            update jrLoan;
            return 'success';
        }
        catch(Exception ex){
            return ex.getMessage();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getHtmlTemplate() {
		
        List<EmailTemplate> templates = [Select Id,HtmlValue FROM EmailTemplate WHERE DeveloperName = 'Documents_Required' LIMIT 1];
        
        //Contact_First_Name__c 
        if(!templates.isEmpty()){
            return templates[0].HtmlValue;
        }
        else {
        	return '';    
        }
    }
}