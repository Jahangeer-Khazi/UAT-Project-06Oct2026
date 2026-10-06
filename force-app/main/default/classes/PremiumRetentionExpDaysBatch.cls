/* 		
 * 		Change History: 
 *          #CH01 : hamza chaoui 22/07/2022 -- add alburaq notification logic
 *			  
*/
global class PremiumRetentionExpDaysBatch implements Database.Batchable<sObject>,Database.Stateful {
    public List<Case> csList{set;get;}
    public List<String> emailList{set;get;}
    public PremiumRetentionExpDaysBatch(){
        //#CH01 : add Case_Model__c
        csList=[SELECT Id,Retention_Expiry_Days__c,RecordType_Name__c,Status,Sub_Status__c,CreatedDate,contactEmail,OwnerId,ContactId,Case_Model__c FROM Case where status!='Closed' and (RecordType_Name__c='Premium Retention' or RecordType_Name__c='Premium Invitation') and Retention_Expiry_Days__c<3 and Retention_Expiry_Days__c>=0];
    }
    
    global List<Case> start(DataBase.BatchableContext BC){
        return csList;
    }
     
    global void execute(Database.BatchableContext BC, List<Case> csList) {
		system.debug('csList==>'+csList);
        
        List<Case> retentionCases = new List<Case>();
        List<Case> invitationCases= new List<Case>();
        List<Case> closeCases= new List<Case>();
        for(Case cs : csList) {      
            if(cs.Retention_Expiry_Days__c==2 && cs.RecordType_Name__c=='Premium Retention')
            {
               
                retentionCases.add(cs);
            }
             if(cs.Retention_Expiry_Days__c==2 && cs.RecordType_Name__c=='Premium Invitation')
            {
                invitationCases.add(cs);
            }
            if(cs.Retention_Expiry_Days__c==0 )
            {
                cs.Status='Closed';
                cs.Sub_Status__c='Expired';
                closeCases.add(cs);
            }
                
        }
        try {

			if(retentionCases.size()>0)
            {
                retentionSendMail(retentionCases);
            }
            if(invitationCases.size()>0)
            {
                invitationSendMail(invitationCases);
            }
            if(closeCases.size()>0)
            {
                update closeCases;
            }
         
        } catch(Exception e) {
            System.debug('The status code returned was not expected: ' + e.getLineNumber() + ' ' + e.getMessage());
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
    public void retentionSendMail(List<Case> scope)
    { 
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
             EmailTemplate emailTemplate = [select Id, Body from EmailTemplate where DeveloperName = 'Premium_Retention_Pending_Customer_Reminder'];
        	 //#CH01 Start: add albraq logic
             EmailTemplate emailTemplateAlburaq = [select Id, Body from EmailTemplate where DeveloperName = 'Premium_Retention_Pending_Customer_Reminder_Alburaq'];
             //#CH01 End
             OrgWideEmailAddress owe = [select Id from OrgWideEmailAddress where Address = 'support@ilabank.com'];
        for(Case cs:scope) {
             Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
             
             //#CH01 Start: add albraq logic
            if(cs.Case_Model__c == 'alburaq'){
                email.setTemplateId(emailTemplateAlburaq.Id);
            }else{
                email.setTemplateId(emailTemplate.Id);
            }
            //#CH01 End
            email.setTemplateId(emailTemplate.Id);
            email.setToAddresses(new String[] {cs.contactEmail});
            email.setTargetObjectId(cs.ContactId);
            email.setWhatId(cs.Id);
            email.setSaveAsActivity(false);
            email.setOrgWideEmailAddressId(owe.Id);
			emails.add(email);
            
        }
        if(emails.size()>0)
        {
            Messaging.sendEmail(emails);
        }
    }
    public void invitationSendMail(List<Case> scope)
    { 
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [select Id, Body from EmailTemplate where DeveloperName = 'Premium_Invitation_Pending_Customer_Reminder'];
        OrgWideEmailAddress owe = [select Id from OrgWideEmailAddress where Address = 'support@ilabank.com'];
        for(Case cs:scope) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(emailTemplate.Id);
            email.setToAddresses(new String[] {cs.contactEmail});
            email.setTargetObjectId(cs.ContactId);
            email.setWhatId(cs.Id);
            email.setSaveAsActivity(false);
            email.setOrgWideEmailAddressId(owe.Id);
			emails.add(email);
            
        }
        if(emails.size()>0)
        {
            Messaging.sendEmail(emails);
        }
        
    }
}