/********************************************************************************************
* @name                 JordanLoanTriggerHandler
* @description          Handler class for Jordan trigger.
* @date                 23/12/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           16/11/2025     Initial Version
*********************************************************************************************
*/

public class JordanLoanTriggerHandler {

    public static String SERVICE_QUEUE = 'ila_Service_Center_Queue';
    public static String CONSUMER_CREDIT_QUEUE = 'Consumer_Credit_Queue';
    public static String JORDAN_LOANS_QUEUE = 'Jordan_Loans_Queue';
    public static String JORDAN_LOANS_ULTIMATE_LOS_BACKOFFICE = 'Jordan_Ultimate_LOS_Backoffice';
    public static String JORDAN_LOANS_LOS_BACKOFFICE = 'Jordan_LOS_Backoffice_queue';
    public static String JORDAN_LOANS_CREDIT_OPERATION = 'Jordan_Loans_Credit_Operations';
    public static String JORDAN_ULTIMATE_LOANS_QUEUE = 'Jordan_Ultimate_Loans_Queue';
    
    public static void beforeInsert(List<Jordan_Loan__c> records){
        //Checking if CIF is populated while creating the new case, 
        //if it is populated then respective customer would fetch and attached to the record.
        try {
            
            //Fetching Jordan Loan Queue for updating the Owner
            List<String> jordanQueueNames = new List<String>();
        	jordanQueueNames.add(JORDAN_LOANS_QUEUE);
            jordanQueueNames.add(JORDAN_ULTIMATE_LOANS_QUEUE);
            Map<String,String> jordanQueueMap = new Map<String,String>();
            
            for(Group grp : [Select Id,DeveloperName FROM Group WHERE DeveloperName IN :jordanQueueNames]){
                jordanQueueMap.put(grp.DeveloperName,grp.Id);
            }
            
            Set<String> setOfCustomerCIFs = new Set<String>();
            for (Jordan_Loan__c jrloan : records) {
                if(!String.isEmpty(jrloan.CIF__c)){
                    setOfCustomerCIFs.add(jrloan.CIF__c);
                }
                
                System.debug('jrloan.Segment__c ' + jrloan.Segment__c);
                if(!jordanQueueMap.isEmpty()){
                    if(jrloan.Segment__c == 'Ultimate'){
                    	jrloan.OwnerId = jordanQueueMap.get(JORDAN_ULTIMATE_LOANS_QUEUE);
                	}
                    else {
                        jrloan.OwnerId = jordanQueueMap.get(JORDAN_LOANS_QUEUE);
                    }
                }
                
                jrloan.Status__c  = 'New'; //Status will always be a new once the record is created.
                jrloan.Sub_Status__c = 'In-Progress';
                jrloan.Application_Stage__c = 'New';
            }
            
            if(!setOfCustomerCIFs.isEmpty()){
                Map<String,Id> mapOfCIFToCustomerId = new Map<String,Id>();
                for(Account acct : [Select Id,CIF__pc FROM Account WHERE CIF__pc IN: setOfCustomerCIFs]){
                    if(!mapOfCIFToCustomerId.containsKey(acct.CIF__pc)){
                        mapOfCIFToCustomerId.put(acct.CIF__pc,acct.Id);
                    }
                }
                
                if(!mapOfCIFToCustomerId.isEmpty()){
                    for (Jordan_Loan__c jrloan : records) {
                        if(mapOfCIFToCustomerId.containsKey(jrloan.CIF__c)){
                            jrloan.Customer__c = mapOfCIFToCustomerId.get(jrloan.CIF__c);
                        }
                    }
                }
            }
            
        }
        catch(Exception ex){
            
        }
    }
    
    public static void afterInsert(List<Jordan_Loan__c> records){
        try{
        
            //Checking if the Jordan case has customer associated or not.
            Set<Id> setOfCustomerIds = new Set<Id>();
            for (Jordan_Loan__c jrloan : records) {
                if(!String.isEmpty(jrloan.Customer__c)){
                    setOfCustomerIds.add(jrloan.Customer__c);
                }
            }
            
            OrgWideEmailAddress owe = [select Id from OrgWideEmailAddress where Address =: Label.Jordan_Loan_From_Address];
            
            if(!setOfCustomerIds.isEmpty()){
                
                EmailTemplate template = [Select Id 
                                      FROM EmailTemplate 
                                      WHERE developername = 'Jordan_Loan_Case_Creation_Template'];
                
                Map<Id,Id> mapOfAccountIdToPersonContactId = new Map<Id,Id>();
                for(Account acct : [Select Id,PersonContactId FROM Account WHERE Id IN: setOfCustomerIds]){
                    mapOfAccountIdToPersonContactId.put(acct.Id,acct.PersonContactId);
                }
                
                //Sending an email to customer once the record is created,
                //This can be done through flow but EmailMessagge record were not creating through flow, 
                for (Jordan_Loan__c jrloan : records) {
                    if(mapOfAccountIdToPersonContactId.containsKey(jrloan.Customer__c)){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        String[] fromAddresses = new String[] {Label.Jordan_Reply_To_Email};
                        mail.setTemplateId(template.Id);
                        mail.setTargetObjectId(mapOfAccountIdToPersonContactId.get(jrloan.Customer__c));
                        mail.setReplyTo(fromAddresses[0]);
                        mail.setWhatId(jrloan.Id);
                        mail.setOrgWideEmailAddressId(owe.Id);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });    
                    }
                }
            }
            
            //Sending an Email to All Queue Member
            Set<Id> userIds = new Set<Id>();
            for(GroupMember member : [Select Id,UserOrGroupId FROM GroupMember WHERE Group.DeveloperName =: JORDAN_LOANS_QUEUE]){
                if (String.valueOf(member.UserOrGroupId).startsWith('005')) {
                	userIds.add(member.UserOrGroupId);
                }
            }
            
            if(!userIds.isEmpty()){
                
                EmailTemplate jordanLoanTemplate = [SELECT Id FROM EmailTemplate
                                         WHERE developername = 'Jordan_Loan_Internal_User_Template'];
                
                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                for(Jordan_Loan__c jrloan : records) {
                    for(Id userId : userIds){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTargetObjectId(userId);
                        mail.setWhatId(jrloan.Id);
                        mail.setTemplateId(jordanLoanTemplate.Id);
                        mail.setSaveAsActivity(false);
                        mail.setOrgWideEmailAddressId(owe.Id);
                        emails.add(mail);
                    }
                }
                
                try{
                    Messaging.SendEmailResult [] result = Messaging.sendEmail(emails);
                    System.debug('Email has sent.' + result[0].isSuccess());
                }
                catch(System.Exception e){
                    System.debug('Error ' + e.getMessage());
                    throw e;
                }
            }
        }
        catch(Exception ex){
            
        }
    }
    
    public static void beforeUpdate(List<Jordan_Loan__c> records,Map<Id,Jordan_Loan__c> oldMap){

        List<String> jordanQueueNames = new List<String>();
        jordanQueueNames.add(SERVICE_QUEUE);
        jordanQueueNames.add(CONSUMER_CREDIT_QUEUE);
        jordanQueueNames.add(JORDAN_LOANS_QUEUE);
        jordanQueueNames.add(JORDAN_LOANS_ULTIMATE_LOS_BACKOFFICE);
        jordanQueueNames.add(JORDAN_LOANS_LOS_BACKOFFICE);
        jordanQueueNames.add(JORDAN_LOANS_CREDIT_OPERATION);
        
        Set<String> setOfCustomerCIFs = new Set<String>();
        Map<String,Id> jordanQueueMap = new Map<String,Id>();
        //Fetching Jordan Loan Queue for updating the Owner
        List<Group> jordanQueueList = [Select Id,DeveloperName FROM Group WHERE 
                                       DeveloperName IN :jordanQueueNames];
        
        //Below code would bypass the validation for system admin or any profile specified in custom label.
        Boolean bypassValidation = false;
        
        Setting__c sysSettings = Setting__c.getInstance();
        bypassValidation = sysSettings.Bypass_Jordan_Loan_Validation__c;
        /*if(!String.isBlank(Label.Jordan_Loan_Bypass_Validation)){
            String lowerCaseProfiles = Label.Jordan_Loan_Bypass_Validation.toLowerCase();
            List<String> userProfiles = lowerCaseProfiles.split(';');
			for(User usr : [Select Id,Profile.Name FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1]){
                bypassValidation = userProfiles.contains(usr.Profile.Name.toLowerCase());
            }
        }*/
        
        for(Group grp : [Select Id,DeveloperName FROM Group WHERE DeveloperName IN :jordanQueueNames]){
            jordanQueueMap.put(grp.DeveloperName,grp.Id);
        }
        
        
        for (Jordan_Loan__c jrloan : records) {
        	Jordan_Loan__c oldRecord = oldMap.get(jrloan.Id);
            
            //CIF is updated, populate the new customer
            if(oldRecord.CIF__c != jrloan.CIF__c){
                setOfCustomerCIFs.add(jrloan.CIF__c);
            }
            
            jrloan.Application_Stage__c = 'In Progress';
            Boolean isStatusUpdateMatch = false;
            System.debug('old status ' + oldRecord.Status__c);
            System.debug('new status ' + jrloan.Status__c);
            if(oldRecord.Status__c == 'New' && jrloan.Status__c == 'Documents Required'){
                isStatusUpdateMatch = true;
                jrloan.Sub_Status__c = 'Pending';
                //Owner Queue would remain same e.g. JORDAN_LOANS_QUEUE
            }
            else if(oldRecord.Status__c == 'New' && jrloan.Status__c == 'Customer Cancelled'){
                isStatusUpdateMatch = true;
                jrloan.Sub_Status__c = 'Cancelled';
            }
            else if((oldRecord.Status__c == 'New' && jrloan.Status__c == 'Submitted') ||
                   (oldRecord.Status__c == 'Documents Required' && jrloan.Status__c == 'Submitted')){
                       isStatusUpdateMatch = true;
                jrloan.Sub_Status__c = 'In-Progress';
                if(jrloan.Segment__c == 'Ultimate'){
                	jrloan.OwnerId = jordanQueueMap.get(JORDAN_LOANS_ULTIMATE_LOS_BACKOFFICE);    
                }
                else {
                	jrloan.OwnerId = jordanQueueMap.get(JORDAN_LOANS_LOS_BACKOFFICE);    
                }
            }
            if((oldRecord.Status__c == 'New' && jrloan.Status__c == 'Customer Rejected') ||
              (oldRecord.Status__c == 'Documents Required' && jrloan.Status__c == 'Customer Rejected')){
            	jrloan.Sub_Status__c = 'Cancelled';
                isStatusUpdateMatch = true;
                if(jrloan.Segment__c == 'Ultimate'){
                	jrloan.OwnerId = jordanQueueMap.get(JORDAN_LOANS_ULTIMATE_LOS_BACKOFFICE);    
                }
                else {
                	jrloan.OwnerId = jordanQueueMap.get(JORDAN_LOANS_LOS_BACKOFFICE);
                }
            }
            else if(oldRecord.Status__c == 'Submitted' && jrloan.Status__c == 'LOS Study'){
                isStatusUpdateMatch = true;
                //Owner would remain same whatever is set on under above condition.
                jrloan.Sub_Status__c = 'In-Progress';
            }
            else if(oldRecord.Status__c == 'LOS Study' && (jrloan.Status__c == 'LOS Approved' || jrloan.Status__c == 'LOS Rejected')){
                isStatusUpdateMatch = true;
                
                if(jrloan.Segment__c == 'Ultimate'){
                	jrloan.OwnerId = jordanQueueMap.get(JORDAN_LOANS_ULTIMATE_LOS_BACKOFFICE);    
                }
                else if(jrloan.Status__c == 'LOS Approved') {
                	jrloan.OwnerId = jordanQueueMap.get(JORDAN_LOANS_QUEUE);    
                }
                else {
                	jrloan.OwnerId = jordanQueueMap.get(JORDAN_LOANS_LOS_BACKOFFICE);    
                }
                
                jrloan.Sub_Status__c = jrloan.Status__c == 'LOS Approved' ? 'Approved' : 'Declined';
                
            }
            else if(oldRecord.Status__c == 'LOS Approved' && (jrloan.Status__c == 'Process Loan Contract' || jrloan.Status__c == 'Customer Rejected')){
                isStatusUpdateMatch = true;
                
                if(jrloan.Segment__c == 'Ultimate'){
                	jrloan.OwnerId = jordanQueueMap.get(JORDAN_LOANS_ULTIMATE_LOS_BACKOFFICE);    
                }
                else {
                	jrloan.OwnerId = jordanQueueMap.get(JORDAN_LOANS_LOS_BACKOFFICE);
                }
                
                
                if(jrloan.Status__c == 'Customer Rejected'){
                	jrloan.Sub_Status__c = 'Cancelled';    
                }
            }
            else if(oldRecord.Status__c == 'Process Loan Contract' && jrloan.Status__c == 'Ready to Disburse'){
                isStatusUpdateMatch = true;
                jrloan.OwnerId = jordanQueueMap.get(JORDAN_LOANS_CREDIT_OPERATION);
            }
            else if(oldRecord.Status__c == 'Ready to Disburse' && jrloan.Status__c == 'Closed'){
                isStatusUpdateMatch = true;
                jrloan.Application_Stage__c = 'Completed';
            }
            
            if(!isStatusUpdateMatch && oldRecord.Status__c != jrloan.Status__c && !bypassValidation){
                jrloan.addError('You cannot set Status from "' + oldRecord.Status__c + '" to "' + jrloan.Status__c + '"');
            }
        }
        
        if(!setOfCustomerCIFs.isEmpty()){
            Map<String,Id> mapOfCIFToCustomerId = new Map<String,Id>();
            for(Account acct : [Select Id,CIF__pc FROM Account WHERE CIF__pc IN: setOfCustomerCIFs]){
                if(!mapOfCIFToCustomerId.containsKey(acct.CIF__pc)){
                    mapOfCIFToCustomerId.put(acct.CIF__pc,acct.Id);
                }
            }
            
            for (Jordan_Loan__c jrloan : records) {
                if(mapOfCIFToCustomerId.containsKey(jrloan.CIF__c)){
                    jrloan.Customer__c = mapOfCIFToCustomerId.get(jrloan.CIF__c);
                }
                else {
                    jrloan.Customer__c = null;
                }
            }
        }
    }
    
    public static void afterUpdate(List<Jordan_Loan__c> records,Map<Id,Jordan_Loan__c> oldMap){
        Boolean isOwnerUpdate = false;
        Map<String,String> updatedOwnersMap = new Map<String,String>();
        for (Jordan_Loan__c jrloan : records) {
        	Jordan_Loan__c oldRecord = oldMap.get(jrloan.Id);
            
            if(jrloan.Status__c != oldRecord.Status__c){
                System.enqueueJob(new JordanLoanCallout(jrloan));
            }
            
            if(jrloan.OwnerId != oldRecord.OwnerId){
                isOwnerUpdate = true;
            }
        }
        
        if(isOwnerUpdate){
            
            EmailTemplate template = [Select Id FROM EmailTemplate WHERE developername = 'JO_Jordan_Loan_Owner_Update'];
            
            List<String> userEmails = new List<String>();
            for(GroupMember member : [Select Id,UserOrGroupId,UserOrGroup.Email FROM GroupMember WHERE Group.DeveloperName =: Label.CRM_User_Queue]){
                if (String.valueOf(member.UserOrGroupId).startsWith('005')) {
                    userEmails.add(member.UserOrGroup.Email);
                }
            }
            System.debug('userEmails ' + userEmails);
            OrgWideEmailAddress owe = [select Id from OrgWideEmailAddress where Address =: Label.Jordan_Loan_From_Address];

            //In order to trigger the email we need a dummy contact record so I'm using Ashish's record because it would available on both UATX and PROD
            List<Contact> contactRecordList = [Select Id FROM Contact where Firstname = 'Ashish' and LastName = 'Pandey' LIMIT 1];
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            if(!contactRecordList.isEmpty()){
            	for(Jordan_Loan__c jrloan : records) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(contactRecordList[0].Id);
                    mail.setWhatId(jrloan.Id);
                    mail.setTemplateId(template.Id);
                    mail.setSaveAsActivity(false);
                    mail.setOrgWideEmailAddressId(owe.Id);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setToAddresses(userEmails);
                    emails.add(mail);
                }
                
                try{
                    Messaging.SendEmailResult [] result = Messaging.sendEmail(emails);
                    System.debug('userIds ' + result);
                    System.debug('Email has sent.' + result[0].isSuccess());
                }
                catch(System.Exception e){
                    System.debug('Error ' + e.getMessage());
                    throw e;
                }    
            }
        }
    }
}


/*
 if(oldRecord.Status__c == 'New' && 
               (jrloan.Status__c == 'Documents Required' || jrloan.Status__c == 'Submitted' || jrloan.Status__c == 'Customer Rejected')){
                isStatusUpdateMatch = true;
                jrloan.Application_Stage__c = 'In Progress';
                   
                   if(jrloan.Status__c == 'Documents Required'){
                       jrloan.Sub_Status__c = 'Pending';
                   }
                   else if(jrloan.Status__c == 'Customer Rejected'){
                        jrloan.Sub_Status__c = 'Cancelled';    
                    }
                   else {
                       jrloan.Sub_Status__c = 'In-Progress';
                   }
            }
 */