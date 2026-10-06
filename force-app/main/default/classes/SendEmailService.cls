public without sharing class SendEmailService {
    
    public class EmailParamsWrapper {
        @InvocableVariable(label='Case Id' description='the Id of the Case' required=true)
        public String caseId;
        
        @InvocableVariable(label='EmailTemplateDeveloperName' description='Email Template DeveloperName to be sent' required=true)
        public String EmailTemplateDeveloperName;
        
        // @InvocableVariable(label='recipient' description='Optional. A list of email addresses or object IDs of the contacts, leads, and users you’re sending the email to' required=true)
        // public List<String> recipient;

        @InvocableVariable(label='recipient' description='Optional. email address or object ID of the contact, lead, and user you’re sending the email to' required=true)
        public String recipient;

        @InvocableVariable(label='AdditionalEmails' description='Optional. A list of carbon copy (CC) addresses or object IDs of the contacts, leads, and users you’re sending the email to')
        public List<String> AdditionalEmails	;

        @InvocableVariable(label='FromOrgWideAddress' description='It is Optional: From Org Wide Address  (ex: support@ilabank.com)')
        public String FromOrgWideAddress	;
    }

    
    @InvocableMethod(label='Send Email from email template' description='Send Email from email template and merge fields from Case and CaseAnnex__c' callout=true )
    public static List<String> SendEmailFromTemplate(List<EmailParamsWrapper> emailParamsList){

        EmailParamsWrapper emailParams = emailParamsList.get(0);
        system.debug('emailParams : ' + emailParams);
        String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
        // Get records with all fields
        List<Case> cases = new List<Case>();
        List<CaseAnnex__c> CaseAnnexs = new List<CaseAnnex__c>();
        
        String caseId = emailParams.caseId;
        system.debug('emailParams caseId: ' + caseId);
        
        String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc FROM Case WHERE Id =: caseId';
        cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        Case caseObj = cases[0];
        
        String caseAnnexId = caseObj.CaseAnnex__c;
        String caseAnnexfields = DM000_sObjectDescriber.constructFieldListForQueryFrom('CaseAnnex__c');   
        String caseAnnexsoqlQuery = 'SELECT ' + caseAnnexfields + ' FROM CaseAnnex__C WHERE Id =:caseAnnexId';
        CaseAnnexs = new List<CaseAnnex__c>((List<CaseAnnex__c>)Database.query(caseAnnexsoqlQuery));
        CaseAnnex__c caseAnnexRecord = CaseAnnexs[0];
        
        //#CH02 : start add tracking notifications
        List<NotificationsTracking__c> lstSA = new List<NotificationsTracking__c>();
        DateTime nowDate = System.now();
        String channel = 'Email';
        String functionApex ='"Loans Notifications Flow" > SendEmailService.SendEmailFromTemplate()';
        String description;
        String notifType = 'Reminder';
        String product;

        if (caseAnnexRecord.cx_ln_Reminder_1_Datetime__c != null) {
            Long diffMs = nowDate.getTime() - caseAnnexRecord.cx_ln_Reminder_1_Datetime__c.getTime();
            if (diffMs >= 0 && diffMs <= 160000) {
                description = 'Reminder 1 - Email Sent';
            }
        }
        if (caseAnnexRecord.cx_ln_Reminder_2_Datetime__c != null && description==null) {
            Long diffMs = nowDate.getTime() - caseAnnexRecord.cx_ln_Reminder_2_Datetime__c.getTime();
            if (diffMs >= 0 && diffMs <= 160000) {
                description = 'Reminder 2 - Email Sent';
            }
        }
        if (caseAnnexRecord.cx_ln_Reminder_3_Datetime__c != null && description==null) {
            Long diffMs = nowDate.getTime() - caseAnnexRecord.cx_ln_Reminder_3_Datetime__c.getTime();
            if (diffMs >= 0 && diffMs <= 160000) {
                description = 'Reminder 3 - Email Sent';
            }
        }
        if (caseAnnexRecord.cx_ln_expiry_Datetime__c != null && description==null) {
            Long diffMs = nowDate.getTime() - caseAnnexRecord.cx_ln_expiry_Datetime__c.getTime();
            if (diffMs >= 0 && diffMs <= 160000) {
                description = 'Expired Email Sent';
            }
        }

        if(description == null){
            description = 'Email Sent -- '+ nowDate + ' GMT';
            notifType = 'Immediate';
        }
        if(caseObj.RecordType_DeveloperName__c == 'Loan_Application'){product = 'Loans';}
        String statusStr = caseObj.Status;
        String subStatusStr = caseObj.Sub_Status__c;
        //#CH02 : End

        // Get email template
        List<EmailTemplate> emTempList = [select DeveloperName, HtmlValue, Subject from EmailTemplate where DeveloperName  =: emailParams.EmailTemplateDeveloperName ];

        if(emTempList.size() == 0){
            return  new List<String> { 'EmailTemplate not found, please check DeveloperName : '+ emailParams.EmailTemplateDeveloperName+'\n' } ;
        }

        EmailTemplate emTemp = emTempList[0];
        if (caseObj != null && caseAnnexRecord != null && emTemp != null) {
            
            try {

                // Process Subject Merged Fields
                String processedSubject = replaceMergeFields(emTemp.Subject,  caseObj, caseAnnexRecord );
                // Process HtmlValue Merged Fields
                String processedHtmlValue = replaceMergeFields(emTemp.HtmlValue,  caseObj, caseAnnexRecord );
                // Handle From address
                OrgWideEmailAddress defaultowea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'support@ilabank.com' LIMIT 1];
                OrgWideEmailAddress owea = new OrgWideEmailAddress ();
                owea = defaultowea;

                if (emailParams.FromOrgWideAddress != null && emailParams.FromOrgWideAddress != '') {
                    List<OrgWideEmailAddress> oweaList = [SELECT Id FROM OrgWideEmailAddress WHERE Address =: emailParams.FromOrgWideAddress];
                    if (oweaList.size() > 0) { 
                        owea = oweaList[0];
                    }
                } else {
                    
                    if (caseObj.Region_Flag__c == 'Jordan' ) {
                        List<OrgWideEmailAddress> oweaList = [SELECT Id FROM OrgWideEmailAddress WHERE Address ='supportjo@ilabank.com'];
                        if (oweaList.size() > 0) { 
                            owea = oweaList[0];
                        }
                    } else if (caseObj.Region_Flag__c == 'Bahrain' && caseObj.case_model__c == 'Alburaq' ) {
                        List<OrgWideEmailAddress> oweaList = [SELECT Id FROM OrgWideEmailAddress WHERE Address ='support.alburaq@ilabank.com'];
                        if (oweaList.size() > 0) { 
                            owea = oweaList[0];
                        }
                    }
                }
    
                // Prepare Email
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                // email.setToAddresses(new String[]{'elmustapha.elgarni@da-tech.ma'});
                email.setToAddresses(new String[]{emailParams.recipient});
                email.setSubject(processedSubject);
                email.setHtmlBody(processedHtmlValue);
                email.setOrgWideEmailAddressId(owea.Id);

                if (emailParams.AdditionalEmails != null && emailParams.AdditionalEmails.size() > 0) {
                    email.setCcAddresses(emailParams.AdditionalEmails);
                }
    
                Messaging.sendEmail(new List<Messaging.Email>{email});
                System.debug('Email sent');

                //#CH02 : start add tracking notifications
                lstSA.add(NotificationTrackingService.setNotifTracking( functionApex,caseObj.Id,channel,description,null,null,null,null,
                                             notifType,product,null,null,nowDate,statusStr,subStatusStr,emailParams.EmailTemplateDeveloperName
                )); 
                insert lstSA;
                //#CH02 : End

            } catch(Exception e) {
                System.debug('Error sending email: ' + e.getMessage());
                // Consider adding error handling logic here
                //#CH02 : start add tracking notifications
                lstSA.add(NotificationTrackingService.setNotifTracking( functionApex,caseObj.Id,channel,description,null,'Error Message : ' +e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString()),null,null,
                                             notifType,product,null,null,nowDate,statusStr,subStatusStr,emailParams.EmailTemplateDeveloperName
                )); 
                insert lstSA;
                //#CH02 : End
            }
        }


        // Return
        List<String> strLst = new List<String>();
        for(EmailParamsWrapper qst : emailParamsList){
            strLst.add(qst.caseId);
        }
        return strLst;
    } 

    public static String replaceMergeFields(String template, Case caseRecord, caseAnnex__c caseAnnex) {
        if (String.isBlank(template)) return template;
        
        Pattern pattern = Pattern.compile('\\{!([^}]+)\\}');
        Matcher matcher = pattern.matcher(template);
        String result = template;
    
        // Store replacements first to avoid concurrent modification
        Map<String, String> replacements = new Map<String, String>();
        
        while (matcher.find()) {
            String fullFieldPath = matcher.group(1);
            if (!replacements.containsKey(fullFieldPath)) {
                if (fullFieldPath == 'Case.Thread_Id'){
                    replacements.put(fullFieldPath, generateThreadId(caseRecord.Id));
                    continue;
                }
                replacements.put(fullFieldPath, getFieldValue(fullFieldPath, caseRecord, caseAnnex));
            }
        }
    
        // Perform all replacements
        for (String key : replacements.keySet()) {
            result = result.replaceAll('\\{!' + key + '\\}', replacements.get(key));
        }
        
        return result;
    }
    private static String getFieldValue(String fullFieldPath, Case c, CaseAnnex__c ca) {
        try {
            String[] parts = fullFieldPath.split('\\.');
            if (parts.size() != 2) {
                System.debug('Invalid merge field format: ' + fullFieldPath);
                return '';
            }
            
            String objectName = parts[0];
            String fieldName = parts[1];
            
            // Case-insensitive comparison for object names
            if (objectName.equalsIgnoreCase('Case') && c != null) {
                //#CH01 Start
                Map<String, Schema.SObjectField> caseFields = Schema.SObjectType.Case.fields.getMap();
                if (!caseFields.containsKey(fieldName)) {
                    System.debug('Field not found on Case: ' + fieldName);
                    return '';
                }

                Schema.DescribeFieldResult fieldDescribe = caseFields.get(fieldName).getDescribe();
                Object rawValue = c.get(fieldName);
                if (rawValue == null) {
                    return '';
                }
    
                // If it's a picklist, return the label instead of the API value
                if (fieldDescribe.getType() == Schema.DisplayType.Picklist) {
                    String storedValue = String.valueOf(rawValue);
    
                    for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                        if (entry.getValue() == storedValue) {
                            return entry.getLabel();
                        }
                    }
                    // fallback if value not found in describe metadata
                    return storedValue;
                }
    
                return String.valueOf(rawValue);
                //#CH01 End
            }
            else if (objectName.equalsIgnoreCase('CaseAnnex__c') && ca != null) {
                Object value = ca.get(fieldName);
                return value != null ? String.valueOf(value) : '';
            }
            
            System.debug('Object not found: ' + objectName);
            return '';
            
        } catch(Exception e) {
            System.debug('Error getting field value for ' + fullFieldPath + ': ' + e.getMessage());
            return '';
        }
    }

    public static String generateThreadId(Id caseId) {
        // Get the short 15-character version of Case Id (just in case it's 18-char)
        Id orgId =  UserInfo.getOrganizationId();

        String caseId15 = String.valueof(caseId).substring(0, 15);
        String orgId15 = String.valueof(orgId).substring(0, 15);

        // Build Org key: first 5 + last 5 of orgId
        String orgKey = orgId15.substring(0, 5) + orgId15.substring(10, 15);

        // Build Case key: first 5 + characters 10 to 14
        String caseKey = caseId15.substring(0, 5) + caseId15.substring(9, 15);

        // Format Thread Id
        String threadId = 'ref:!' + orgKey + '.!' + caseKey + ':ref';
        return threadId;
    }

    
    //Aniss #CH01
    //send email with attachment for regionFlag Bahrain for Credit cards In-App Process ...
    public static void CC_sendEmailWithAtachements(Case caseRecord, String emailTemplateDeveloperName, List<String> wordList) {
        System.debug('CC_sendEmailWithAtachements ---> ');
        // Template ID
        EmailTemplate emTemp = [SELECT DeveloperName, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = :emailTemplateDeveloperName LIMIT 1];

        Set<Id> contentDocumentToSendIds = new Set<Id>();
        
        // Process Subject Merged Fields
        String processedSubject = SendEmailService.replaceMergeFields(emTemp.Subject,  caseRecord, null );//no caseAnnex record for creditCard scenarios
        
        // Process HtmlValue Merged Fields
        String processedHtmlValue = SendEmailService.replaceMergeFields(emTemp.HtmlValue,  caseRecord, null );//no caseAnnex record for creditCard scenarios
        
        // Query related content document links
        List<ContentDocumentLink> contentDocumentLinks = [  SELECT ContentDocumentId
                                                            FROM ContentDocumentLink
                                                            WHERE LinkedEntityId = :caseRecord.Id];

        Set<Id> relatedContentDocIds = new Set<Id>();
        for (ContentDocumentLink cdl : contentDocumentLinks) {
            relatedContentDocIds.add(cdl.ContentDocumentId);
        }
        // Query the content document and check title
        List<ContentDocument> contentDocList = [SELECT Id, Title,createdDate FROM ContentDocument WHERE Id IN :relatedContentDocIds order by createdDate desc];
        Integer nbrOfCertificateofcompletion = 0;
        for(ContentDocument contDoc:contentDocList){
            for (String word : wordList) {
                if (contDoc.Title != null && contDoc.Title.toLowerCase().contains(word.toLowerCase()) && !contDoc.Title.toLowerCase().contains('unsigned') ) {
                    if(contDoc.Title.toLowerCase().contains('certificateofcompletion')){
                        nbrOfCertificateofcompletion ++;
                    }
                    if(nbrOfCertificateofcompletion < 2){ //to avoid sending duplicate files
                        contentDocumentToSendIds.add(contDoc.Id);
                        System.debug('CC Document to be sent Title --> '+ contDoc.Title.toLowerCase() + ' Date --> '+ contDoc.createdDate);
                    }
                    break;
                }
            }

            if(nbrOfCertificateofcompletion > 1){ //to avoid sending duplicate files
                break;
            }
        }
        
        // Send emails with attachments
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        // Query the content versions for the content documents
        List<ContentVersion> contentVersions = [SELECT Id, Title, FileExtension
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId IN :contentDocumentToSendIds 
                                                AND IsLatest = true];
        
        List<Id> entityAttachmentIds = new List<Id>();
        for (ContentVersion cv : contentVersions) {
            entityAttachmentIds.add(cv.Id); // attach by ContentVersion Id
        }
        
        // Create the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(processedSubject);
        email.setHtmlBody(processedHtmlValue);
        email.setTargetObjectId(caseRecord.account.PersonContactId );
        email.setEntityAttachments(entityAttachmentIds);// no need for this line: email.setFileAttachments(attachments);
        
        // Get org wide address
        OrgWideEmailAddress[] oweaIla = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'support@ilabank.com'];
        email.setOrgWideEmailAddressId(oweaIla.get(0).Id);
        emails.add(email);
        // Send the emails
        if (!emails.isEmpty() && !String.isBlank(processedHtmlValue)) {
            Messaging.sendEmail(emails);
            System.debug('CC_sendEmailWithAtachements Email sent success---> ');
            
        }
    }
    //#CH01 End
}