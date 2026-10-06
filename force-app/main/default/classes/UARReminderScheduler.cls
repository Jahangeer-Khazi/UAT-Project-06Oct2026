global class UARReminderScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        try {
            sendReminderEmails();
        } catch (Exception e) {
            // Handle exception if needed
        }
    }

    private void sendReminderEmails() {
        // Step 1: Query custom metadata and organize reminder configurations for days
        Map<Integer, Map<String, Map<String, String>>> reminderConfig = new Map<Integer, Map<String, Map<String, String>>>();
        Set<String> uniqueUserNames = new Set<String>();

        for (UAR_Reminder_Config__mdt config : 
             [SELECT Days_Elapsed__c, User_Name__c, Email_Template__c, Case_Model__c 
              FROM UAR_Reminder_Config__mdt WHERE Days_Elapsed__c != NULL]) {
            Integer daysElapsed = config.Days_Elapsed__c.intValue();
            if (!reminderConfig.containsKey(daysElapsed)) {
                reminderConfig.put(daysElapsed, new Map<String, Map<String, String>>());
            }
            if (!reminderConfig.get(daysElapsed).containsKey(config.Case_Model__c)) {
                reminderConfig.get(daysElapsed).put(config.Case_Model__c, new Map<String, String>());
            }
            reminderConfig.get(daysElapsed).get(config.Case_Model__c).put(config.User_Name__c, config.Email_Template__c);
            uniqueUserNames.add(config.User_Name__c);
        }

        // Step 2: Query users based on unique user names
        Map<String, User> userMap = new Map<String, User>();
        for (User u : [SELECT Id, Name, Email FROM User WHERE Name IN :uniqueUserNames]) {
            userMap.put(u.Name, u);
        }

        // Step 3: Query UAR records
        List<UAR__c> uarRecords = [SELECT Id, CreatedDate, Account__c, OwnerId, Case_Model__c FROM UAR__c WHERE CreatedDate != NULL AND CreatedDate = LAST_N_DAYS:20 ORDER BY CreatedDate DESC];
        if (uarRecords.isEmpty()) {
            return;
        }

        // Step 4: Query OrgWideEmailAddress
        OrgWideEmailAddress owe = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'support@ilabank.com' LIMIT 1];

        // Step 5: Collect account IDs from UAR records
        Set<Id> accountIds = new Set<Id>();
        for (UAR__c uar : uarRecords) {
            if (uar.Account__c != null) {
                accountIds.add(uar.Account__c);
            }
        }

        // Step 6: Query contacts for the accounts
        Map<Id, Contact> accountContacts = new Map<Id, Contact>();
        for (Contact cd : [SELECT Id, Name, Email, AccountId FROM Contact WHERE AccountId IN :accountIds]) {
            accountContacts.put(cd.AccountId, cd);
        }

        // Step 7: Pre-fetch email templates
        Map<String, Id> emailTemplateMap = new Map<String, Id>();
        for (EmailTemplate et : [SELECT Id, Name FROM EmailTemplate]) {
            emailTemplateMap.put(et.Name, et.Id);
        }

        // Step 8: Pre-fetch queue emails
        Map<Id, String> queueEmails = new Map<Id, String>();
        for (Group g : [SELECT Id, Email FROM Group WHERE Type = 'Queue' AND Email != NULL]) {
            queueEmails.put(g.Id, g.Email);
        }

        // Step 9: Process UAR records and send emails
        Datetime now = System.now();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (UAR__c uar : uarRecords) {
            Integer daysElapsed = uar.CreatedDate.date().daysBetween(now.date());
            String caseModel = determineCaseModel(uar);

            Map<String, String> userTemplates = new Map<String, String>();
            if (reminderConfig.containsKey(daysElapsed) && reminderConfig.get(daysElapsed).containsKey(caseModel)) {
                userTemplates.putAll(reminderConfig.get(daysElapsed).get(caseModel));
            }

            if (userTemplates.isEmpty()) {
                continue;
            }

            Contact contactToSend = accountContacts.get(uar.Account__c);
            if (contactToSend == null) {
                continue;
            }

            Map<String, List<String>> templateRecipients = new Map<String, List<String>>();
            for (String userName : userTemplates.keySet()) {
                User user = userMap.get(userName);
                if (user == null) continue;
                String templateName = userTemplates.get(userName);
                if (!templateRecipients.containsKey(templateName)) {
                    templateRecipients.put(templateName, new List<String>());
                }
                templateRecipients.get(templateName).add(user.Email);
            }

            if (daysElapsed == 3 || daysElapsed == 7) {
                if (queueEmails.containsKey(uar.OwnerId)) {
                    String queueEmail = queueEmails.get(uar.OwnerId);
                    if (queueEmail != null) {
                        for (String templateName : templateRecipients.keySet()) {
                            templateRecipients.get(templateName).add(queueEmail);
                        }
                    }
                } else {
                    User owner = userMap.get(uar.OwnerId);
                    if (owner != null && owner.Email != null) {
                        for (String templateName : templateRecipients.keySet()) {
                            templateRecipients.get(templateName).add(owner.Email);
                        }
                    }
                }
            }

            for (String templateName : templateRecipients.keySet()) {
                Id templateId = emailTemplateMap.get(templateName);
                if (templateId == null) continue;

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(templateId);
                email.setTargetObjectId(contactToSend.Id);
                email.setWhatId(uar.Id);
                email.setToAddresses(templateRecipients.get(templateName));
                email.setOrgWideEmailAddressId(owe.Id);
                email.setSaveAsActivity(false);
                emails.add(email);
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    private String determineCaseModel(UAR__c uar) {
        if (uar.Case_Model__c == 'ila') {
            return 'ila';
        } else if (uar.Case_Model__c == 'alburaq') {
            return 'alburaq';
        } else {
            return 'ila';
        }
    }
}