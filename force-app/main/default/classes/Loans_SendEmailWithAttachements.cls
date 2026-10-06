public with sharing class Loans_SendEmailWithAttachements {
    
    public class FlowInputs {
        @InvocableVariable(label='Case Id')
        public String caseId;
        
        @InvocableVariable(label='Email Template Developer Name')
        public String templateDeveloperName;
        
        @InvocableVariable(label='Keywords' description='Provide Keywords separated by ";" or keep it empty to send all related files as attachements')
        public String keywords;
    }

    
    @InvocableMethod(label='Send Email With Attachments')
    public static List<String> sendEmailWithAttachmentsMethod(List<FlowInputs> inputs) {
        system.debug('Send Email With Attachments');
        List<String> strLst = new List<String>();

        for (FlowInputs input : inputs) {
            strLst.add(input.caseId);
            sendEmailWithAtachements(input.caseId, input.templateDeveloperName, input.Keywords.split(';'));
        }
        return strLst;
    }
    

    public static void sendEmailWithAtachements(Id caseId, String emailTemplateDeveloperName, List<String> wordList) {
        
        // Template ID
        EmailTemplate emTemp = [SELECT DeveloperName, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = :emailTemplateDeveloperName LIMIT 1];

        Set<Id> contentDocumentToSendIds = new Set<Id>();
        // Retrieve case with required fields
        // Case caseRecord = [SELECT Id, AccountId, RecordType.DeveloperName, Region_Flag__c, case_model__c, Account.PersonEmail, Account.PersonContactId
        //                             FROM Case 
        //                             WHERE Id =: caseId];
        List<Case> cases = new List<Case>();
        List<CaseAnnex__c> CaseAnnexs = new List<CaseAnnex__c>();
        String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
        String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,Account.PersonContactId FROM Case WHERE Id =: caseId';
        cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        Case caseRecord = cases[0];

        String caseAnnexId = caseRecord.CaseAnnex__c;
        String caseAnnexfields = DM000_sObjectDescriber.constructFieldListForQueryFrom('CaseAnnex__c');   
        String caseAnnexsoqlQuery = 'SELECT ' + caseAnnexfields + ' FROM CaseAnnex__C WHERE Id =:caseAnnexId';
        CaseAnnexs = new List<CaseAnnex__c>((List<CaseAnnex__c>)Database.query(caseAnnexsoqlQuery));
        CaseAnnex__c caseAnnexRecord;
        if (!CaseAnnexs.isEmpty())
        {
          caseAnnexRecord = CaseAnnexs[0]; 
        }
        
        // Process Subject Merged Fields
        String processedSubject = SendEmailService.replaceMergeFields(emTemp.Subject,  caseRecord, caseAnnexRecord );
        // Process HtmlValue Merged Fields
        String processedHtmlValue = SendEmailService.replaceMergeFields(emTemp.HtmlValue,  caseRecord, caseAnnexRecord );
        
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
                        System.debug('Document to be sent Title --> '+ contDoc.Title.toLowerCase() + ' Date --> '+ contDoc.createdDate);
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
        
        /*List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        for (ContentVersion cv : contentVersions) {
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(cv.Title);
            attachment.setBody(cv.VersionData);
            attachments.add(attachment);
        }*/
        List<Id> entityAttachmentIds = new List<Id>();
        for (ContentVersion cv : contentVersions) {
            entityAttachmentIds.add(cv.Id); // attach by ContentVersion Id
        }
        
        // Create the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        //--- email.setToAddresses(new String[] { account.PersonEmail });
        // email.setTemplateId(templateId);
        // email.setWhatId(caseId);
        email.setSubject(processedSubject);
        email.setHtmlBody(processedHtmlValue);
        email.setTargetObjectId(caseRecord.account.PersonContactId );
        email.setEntityAttachments(entityAttachmentIds);// no need for this line: email.setFileAttachments(attachments);
        
        // Get org wide address
        OrgWideEmailAddress[] oweaIla = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'support@ilabank.com'];
        List<OrgWideEmailAddress> oweaAlburaq = new List<OrgWideEmailAddress>();
        if (emailTemplateDeveloperName.toLowerCase().contains('alburaq') ){
            oweaAlburaq = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'support.alburaq@ilabank.com'];
        }
        if (emailTemplateDeveloperName.toLowerCase().contains('alburaq') && oweaAlburaq !=null && oweaAlburaq.size() > 0) {
            email.setOrgWideEmailAddressId(oweaAlburaq.get(0).Id);
        } else {
            email.setOrgWideEmailAddressId(oweaIla.get(0).Id);
        }
        emails.add(email);
        // Send the emails
        if (!emails.isEmpty() && !String.isBlank(processedHtmlValue)) {
            Messaging.sendEmail(emails);
        }

    }
}