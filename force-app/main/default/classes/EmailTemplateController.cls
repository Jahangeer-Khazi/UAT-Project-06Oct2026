public without sharing class EmailTemplateController {
    public static String messageId;
    
    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> getTemplatesFromSampleFolder() {
        return [SELECT Id, Name, Description, DeveloperName 
                FROM EmailTemplate 
                WHERE Folder.DeveloperName = 'Static_Templates'
                ORDER BY Name];
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCaseDetailsAndTemplates(Id recordId) {
        Case caseRecord = [SELECT Id, RecordType.DeveloperName, Type, Sub_Type__c, 
                           CC_Request_Type__c, cc_Email_Address__c, CaseNumber, SuppliedEmail
                           FROM Case 
                           WHERE Id = :recordId 
                           LIMIT 1];
        
        String toAddress = String.isBlank(caseRecord.cc_Email_Address__c)
            ? caseRecord.SuppliedEmail
            : caseRecord.cc_Email_Address__c;
        
        return new Map<String, Object>{
            'caseDetails' => new Map<String, String>{
                'recordType' => caseRecord.RecordType.DeveloperName,
                    'type' => caseRecord.Type,
                    'subType' => caseRecord.Sub_Type__c,
                    'requestType' => caseRecord.CC_Request_Type__c,
                    'toAddress' => toAddress,
                    'caseNumber' => caseRecord.CaseNumber
                    },
                        'allTemplates' => getTemplatesFromSampleFolder()
                        };
                            }
    
    @AuraEnabled
    public static void sendEmailWithAttachment(Id templateId, Id recordId, Id contentDocumentId, 
                                               String toAddress, String fromAddress, String subject) {
                                                   try {
                                                       System.debug('toAddress -->' + toAddress);
                                                       List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                                                       messageId = generateThreadId(recordId);
                                                       
                                                       // Query case details including Previous_Email__c
                                                       Case caseRecord = [
                                                           SELECT Id, Type, Sub_Type__c, CC_Request_Type__c, Previous_Email__c
                                                           FROM Case
                                                           WHERE Id = :recordId
                                                           LIMIT 1
                                                       ];
                                                       
                                                       String cleanedEmail = toAddress != null ? toAddress.trim().toLowerCase() : '';
                                                       List<Contact> contactList = [SELECT Id FROM Contact WHERE Email = :cleanedEmail LIMIT 1];
                                                       Contact dummyContact = !contactList.isEmpty() ? contactList[0] : null;
                                                       
                                                       // ✅ Enhancement: Add Previous_Email__c if criteria match and value is not null
                                                       if (
                                                           caseRecord.Type == 'Account' &&
                                                           caseRecord.Sub_Type__c == 'Profile Update' &&
                                                           caseRecord.CC_Request_Type__c == 'Email' &&
                                                           String.isNotBlank(caseRecord.Previous_Email__c) &&
                                                           (caseRecord.Previous_Email__c != toAddress)
                                                       ) {
                                                           // Append toAddress with Previous_Email__c
                                                           if (String.isNotBlank(toAddress)) {
                                                               toAddress += ',' + caseRecord.Previous_Email__c;
                                                           } 
                                                       }
                                                       
                                                       EmailTemplate template = [SELECT Id, Subject, HtmlValue, Body 
                                                                                 FROM EmailTemplate 
                                                                                 WHERE Id = :templateId];
                                                       
                                                       OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'support@ilabank.com'];
                                                       
                                                       List<String> toAddressList = new List<String>();
                                                       if (String.isNotBlank(toAddress)) {
                                                           toAddressList = toAddress.split(',');
                                                       }
                                                       
                                                       Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                                       email.setToAddresses(toAddressList);
                                                       email.setSaveAsActivity(true);
                                                       
                                                       // Check if dummyContact exists
                                                       if (dummyContact != null) {
                                                           // Use the original method with targetObjectId when contact exists
                                                           String emailBody = String.isNotBlank(template.HtmlValue) ? template.HtmlValue : template.Body;
                                                           emailBody = processMergeFields(emailBody, recordId);
                                                           
                                                           email.setWhatId(recordId);
                                                           email.setTargetObjectId(dummyContact.Id);
                                                           email.setSubject(template.Subject);
                                                           email.setTemplateId(templateId);
                                                           email.setHtmlBody(emailBody);
                                                           email.setUseSignature(false);
                                                       } else {
                                                           // Use renderStoredEmailTemplate method when no contact exists
                                                           email.setSaveAsActivity(false); // Can't save activity without a contact
                                                           email.setTargetObjectId(UserInfo.getUserId());
                                                           
                                                           // Render the email template
                                                           Messaging.SingleEmailMessage renderResult = Messaging.renderStoredEmailTemplate(
                                                               templateId,
                                                               null, // No targetObjectId (contact)
                                                               recordId // WhatId (Case)
                                                           );
                                                           
                                                           // Set the email subject and body
                                                           email.setSubject(renderResult.getSubject());
                                                           if (renderResult.getHtmlBody() != null) {
                                                               email.setHtmlBody(renderResult.getHtmlBody());
                                                           } else {
                                                               email.setPlainTextBody(renderResult.getPlainTextBody());
                                                           }
                                                       }
                                                       
                                                       if (String.isNotBlank(contentDocumentId)) {
                                                           ContentVersion cv = [SELECT VersionData, Title, FileExtension 
                                                                                FROM ContentVersion 
                                                                                WHERE ContentDocumentId = :contentDocumentId 
                                                                                AND IsLatest = true 
                                                                                LIMIT 1];
                                                           
                                                           Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                                                           attachment.setFileName(cv.Title + '.' + cv.FileExtension);
                                                           attachment.setBody(cv.VersionData);
                                                           attachments.add(attachment);
                                                       }
                                                       
                                                       if (
                                                           caseRecord.Type == 'Account' &&
                                                           caseRecord.Sub_Type__c == 'Dormant' &&
                                                           caseRecord.CC_Request_Type__c == 'Reactivation'
                                                       ) {
                                                           StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'KYC_PROFILE' LIMIT 1];
                                                           Blob fileBody = sr.Body;
                                                           
                                                           Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                                                           attachment.setFileName('KYC_PROFILE.pdf');
                                                           attachment.setBody(fileBody);
                                                           attachment.setContentType('application/pdf');
                                                           attachments.add(attachment);
                                                       }
                                                       
                                                       if (!owea.isEmpty()) {
                                                           email.setOrgWideEmailAddressId(owea[0].Id);
                                                       }
                                                       
                                                       // Finally set all attachments
                                                       if (!attachments.isEmpty()) {
                                                           email.setFileAttachments(attachments);
                                                       }
                                                       
                                                       Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
                                                       
                                                   } catch (Exception e) {
                                                       System.debug('Message -->' + e.getMessage());
                                                       System.debug('Line Number -->' + e.getLineNumber());
                                                       throw new AuraHandledException('Error sending email: ' + e.getMessage());
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
    
    @TestVisible
    private static String processMergeFields(String html, Id caseId) {
        if (String.isBlank(html)) return html;
        if (String.isBlank(caseId)) return html;
        
        try {
            Case caseRecord = [SELECT Id, Case_Model__c, Current_First_Name__c, cc_Full_Name__c,
                               bs_Total_Bid_Amount__c, RHA_AccountType__c, cc_ID_Number__c, 
                               Transaction_Date__c, Transaction_Amount__c, Transaction_Currency__c,
                               Transaction_Type__c, cc_Transaction_Reference_Number__c,
                               Merchant_Name__c, ContactEmail
                               FROM Case 
                               WHERE Id = :caseId 
                               LIMIT 1];
            
            // Create map of replacements for cleaner code
            Map<String, String> replacements = new Map<String, String>{
                '@{!Case.cc_Case_Create_Date_Time__c}' => getLogoHtml(caseRecord.Case_Model__c),
                    '{!Case.Current_First_Name__c}' => String.valueOf(caseRecord.Current_First_Name__c != null ? caseRecord.Current_First_Name__c : ''),
                    '{!Case.Contact}' => String.valueOf(caseRecord.cc_Full_Name__c != null ? caseRecord.cc_Full_Name__c : ''),
                    '{!Case.bs_Total_Bid_Amount__c}' => caseRecord.bs_Total_Bid_Amount__c != null ? String.valueOf(caseRecord.bs_Total_Bid_Amount__c) : '',
                        '{!Case.RHA_AccountType__c}' => String.valueOf(caseRecord.RHA_AccountType__c != null ? caseRecord.RHA_AccountType__c : ''),
                        '{!Case.Account}' => String.valueOf(caseRecord.cc_ID_Number__c != null ? caseRecord.cc_ID_Number__c : ''),
                        '{!Case.Transaction_Date__c}' => caseRecord.Transaction_Date__c != null ? String.valueOf(caseRecord.Transaction_Date__c) : '',
                            '{!Case.Transaction_Amount__c}' => caseRecord.Transaction_Amount__c != null ? String.valueOf(caseRecord.Transaction_Amount__c) : '',
                                '{!Case.Transaction_Currency__c}' => String.valueOf(caseRecord.Transaction_Currency__c != null ? caseRecord.Transaction_Currency__c : ''),
                                '{!Case.Transaction_Type__c}' => String.valueOf(caseRecord.Transaction_Type__c != null ? caseRecord.Transaction_Type__c : ''),
                                '{!Case.cc_Transaction_Reference_Number__c}' => String.valueOf(caseRecord.cc_Transaction_Reference_Number__c != null ? caseRecord.cc_Transaction_Reference_Number__c : ''),
                                '{!Today}' => String.valueOf(System.today()),
                                '{!Case.Merchant_Name__c}' => String.valueOf(caseRecord.Merchant_Name__c != null ? caseRecord.Merchant_Name__c : ''),
                                '{!Case.ContactEmail}' => String.valueOf(caseRecord.ContactEmail != null ? caseRecord.ContactEmail : ''),
                                '{!Case.Thread_Id}' => String.valueOf(messageId != null ? messageId : '')
                                };
                                    
                                    // Process all replacements
                                    for (String key : replacements.keySet()) {
                                        if (replacements.get(key) != null) {
                                            html = html.replace(key, replacements.get(key));
                                        }
                                    }
            
            return html;
            
        } catch (Exception e) {
            System.debug('Error processing merge fields: ' + e.getMessage());
            return html; // Return original if error occurs
        }
    }
    
    @TestVisible
    private static String getLogoHtml(String caseModel) {
        if (caseModel == 'ila') {
            return '<img src="https://images.ctfassets.net/2c8e80nprabl/5cgeqYcj46Yo7Vj76b4Pph/77905df16179591bb8a8a8b3e7d44bca/ilaemails_logo.png" ' +
                'width="50" height="auto" alt="ILA Logo" title="ILA Logo" ' +
                'style="display:block; border:0; outline:none; text-decoration:none; -ms-interpolation-mode:bicubic;">';
        } else if (caseModel == 'alburaq') {
            return '<img src="https://images.ctfassets.net/2c8e80nprabl/1Us2L0VnElhpE6VHi5AakS/f24736241fd9ef3ad5ccda277c26f424/AlBuraq_x_ila__logo___2_.png" ' +
                'width="175" height="auto" alt="Al Buraq Logo" title="Al Buraq Logo" ' +
                'style="display:block; border:0; outline:none; text-decoration:none; -ms-interpolation-mode:bicubic;">';
        }
        return '';
    }
    
    public class FileSizeResult {
        @AuraEnabled public Boolean isValid;
        @AuraEnabled public Decimal fileSize;
    }
    
    @AuraEnabled
    public static FileSizeResult checkFileSizeAndDelete(Id contentDocumentId, Decimal maxSize) {
        FileSizeResult result = new FileSizeResult();
        result.isValid = false;
        
        try {
            // Query ContentVersion to get file size
            ContentVersion cv = [
                SELECT ContentSize, ContentDocumentId 
                FROM ContentVersion 
                WHERE ContentDocumentId = :contentDocumentId 
                AND IsLatest = true
                LIMIT 1
            ];
            
            result.fileSize = cv.ContentSize;
            
            if (cv.ContentSize <= maxSize) {
                result.isValid = true;
            } else {
                // File is too large - delete it
                delete [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId];
                result.isValid = false;
            }
            
            return result;
            
        } catch(Exception e) {
            throw new AuraHandledException('Error checking file size: ' + e.getMessage());
        }
    }
    
}