trigger GoldAndSilverInvestmentQuestionnaireTrigger on Investment_Questionnaire__c (before insert, after insert) {
    
    if (Trigger.isBefore && Trigger.isInsert) {
        System.debug('🔵 BEFORE INSERT Trigger started. Number of records: ' + Trigger.new.size());
        
        // Get all CIF values from the new questionnaires
        Set<String> cifValues = new Set<String>();
        Map<String, Investment_Questionnaire__c> cifToQuestionnaireMap = new Map<String, Investment_Questionnaire__c>();
        
        for (Investment_Questionnaire__c questionnaire : Trigger.new) {
            if (String.isNotBlank(questionnaire.CIF__c)) {
                cifValues.add(questionnaire.CIF__c);
                cifToQuestionnaireMap.put(questionnaire.CIF__c, questionnaire);
            } else {
                questionnaire.addError('CIF__c is required for Investment Questionnaire');
            }
        }
        
        // Check if there are existing questionnaires for these CIFs
        if (!cifValues.isEmpty()) {
            List<Investment_Questionnaire__c> existingQuestionnaires = [SELECT Id, CIF__c, CreatedDate 
                                                                        FROM Investment_Questionnaire__c 
                                                                        WHERE CIF__c IN :cifValues 
                                                                        ORDER BY CreatedDate DESC];
            
            // Create a set of CIFs that already have questionnaires
            Set<String> existingCIFs = new Set<String>();
            for (Investment_Questionnaire__c existing : existingQuestionnaires) {
                existingCIFs.add(existing.CIF__c);
            }
            
            // Add errors for duplicate questionnaires
            for (String cif : existingCIFs) {
                Investment_Questionnaire__c duplicateQuestionnaire = cifToQuestionnaireMap.get(cif);
                if (duplicateQuestionnaire != null) {
                    duplicateQuestionnaire.addError('An Investment Questionnaire already exists for CIF: ' + cif + 
                                                    '. Only one questionnaire is allowed per customer.');
                }
            }
        }
        
        System.debug('🔵 BEFORE INSERT Trigger completed');
    }
    
    if (Trigger.isAfter && Trigger.isInsert) {
        // Reset flag at start of trigger execution
        InvestmentQuestionnaireHelper.resetCaseCreatedFlag();
        
        System.debug('🔵 Trigger started. Number of records: ' + Trigger.new.size());
        
        // Collect CIF values
        Set<String> cifValues = new Set<String>();
        for (Investment_Questionnaire__c questionnaire : Trigger.new) {
            System.debug('📄 Processing questionnaire - Id: ' + questionnaire.Id + ', CIF: ' + questionnaire.CIF__c);
            if (String.isNotBlank(questionnaire.CIF__c)) {
                cifValues.add(questionnaire.CIF__c);
            } else {
                System.debug('⚠️ CIF__c is blank for questionnaire: ' + questionnaire.Id);
            }
        }
        
        System.debug('🔍 Collected CIF values: ' + cifValues);
        
        // Get Account mappings
        Map<String, Id> cifToAccountId = InvestmentQuestionnaireHelper.getAccountIdsByCIF(cifValues);
        System.debug('🏦 Account mappings found: ' + cifToAccountId);
        
        // Update parent records with Customer__c field
        List<Investment_Questionnaire__c> questionnairesToUpdate = new List<Investment_Questionnaire__c>();
        Set<Id> uniqueAccountIds = new Set<Id>(); // Track unique accounts to update
        
        // Store accountId for each questionnaire
        Map<Id, Id> questionnaireToAccountMap = new Map<Id, Id>();
        
        for (Investment_Questionnaire__c questionnaire : Trigger.new) {
            Id accountId = cifToAccountId.get(questionnaire.CIF__c);
            if (accountId != null) {
                // Store mapping for later use
                questionnaireToAccountMap.put(questionnaire.Id, accountId);
                
                // Create a new instance for update (don't modify trigger.new directly)
                Investment_Questionnaire__c updateRecord = new Investment_Questionnaire__c(
                    Id = questionnaire.Id,
                    Customer__c = accountId
                );
                questionnairesToUpdate.add(updateRecord);
                uniqueAccountIds.add(accountId); // Collect unique Account IDs
                System.debug('✅ Will update questionnaire ' + questionnaire.Id + ' with Customer__c: ' + accountId);
            } else {
                System.debug('⚠️ No account found for CIF: ' + questionnaire.CIF__c + ' - Customer__c will remain null');
            }
        }
        
        // Update parent records
        if (!questionnairesToUpdate.isEmpty()) {
            System.debug('💾 Updating ' + questionnairesToUpdate.size() + ' parent records with Customer__c');
            try {
                update questionnairesToUpdate;
                System.debug('✅ Successfully updated parent records');
            } catch (DmlException e) {
                System.debug('❌ Error updating parent records: ' + e.getMessage());
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    System.debug('   DML Error ' + i + ': ' + e.getDmlMessage(i));
                }
            }
        }
        
        // Create child records
        List<Questionnaire_Response__c> responsesToInsert = new List<Questionnaire_Response__c>();
        // Set to track which parent questionnaires need case creation
        Set<Id> questionnaireIdsNeedingCase = new Set<Id>();
        // Track which account each questionnaire belongs to
        Id accountIdForCases = null;
        
        for (Investment_Questionnaire__c questionnaire : Trigger.new) {
            System.debug('🔄 Processing questionnaire for child records: ' + questionnaire.Id);
            
            // Get accountId from the map we created
            Id accountId = questionnaireToAccountMap.get(questionnaire.Id);
            System.debug('   Account ID for CIF ' + questionnaire.CIF__c + ': ' + accountId);
            
            // Only process if we found a matching Account
            if (accountId != null) {
                List<Questionnaire_Response__c> questionnaireResponses = 
                    InvestmentQuestionnaireHelper.createQuestionnaireResponses(questionnaire, accountId);
                
                System.debug('   Created ' + questionnaireResponses.size() + ' response records');
                
                // Check if any response requires manual approval
                for (Questionnaire_Response__c response : questionnaireResponses) {
                    if (response.Requires_Manual_Approval__c == true) {
                        questionnaireIdsNeedingCase.add(questionnaire.Id);
                        // Store the accountId for this questionnaire
                        accountIdForCases = accountId;
                        System.debug('   ⚠️ Manual approval required for question: ' + response.Question_Number__c);
                        break; // No need to check further for this questionnaire
                    }
                }
                
                responsesToInsert.addAll(questionnaireResponses);
            } else {
                System.debug('❌ No account found for CIF: ' + questionnaire.CIF__c + ' - Cannot create child records');
            }
        }
        
        // Insert all child records
        if (!responsesToInsert.isEmpty()) {
            System.debug('💾 Inserting ' + responsesToInsert.size() + ' child records');
            try {
                insert responsesToInsert;
                System.debug('✅ Successfully inserted child records');
                
                // Log the inserted records
                Set<Id> insertedIds = new Set<Id>();
                for (Questionnaire_Response__c resp : responsesToInsert) {
                    insertedIds.add(resp.Id);
                }
                System.debug('📊 Inserted response IDs: ' + insertedIds);
                
            } catch (DmlException e) {
                System.debug('❌ Error inserting child records: ' + e.getMessage());
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    System.debug('   DML Error ' + i + ': ' + e.getDmlMessage(i));
                }
            }
        } else {
            System.debug('⚠️ No child records to insert');
        }
        
        // FIRST: Create cases for questionnaires that need manual approval
        // This sets isCaseCreated = true if cases are created successfully
        if (!questionnaireIdsNeedingCase.isEmpty()) {
            System.debug('📋 Creating cases for ' + questionnaireIdsNeedingCase.size() + ' questionnaires');
            InvestmentQuestionnaireHelper.createManualApprovalCases(questionnaireIdsNeedingCase, Trigger.new, accountIdForCases);
        } else {
            System.debug('📋 No cases needed (no manual approval required)');
            // Explicitly set isCaseCreated to false when no cases are needed
            InvestmentQuestionnaireHelper.isCaseCreated = false;
        }
        
        // THEN: Update Account statuses (now isCaseCreated will have the correct value)
        if (!uniqueAccountIds.isEmpty()) {
            // Convert Set to Map for the helper method (value can be anything, we just need the IDs)
            Map<Id, Id> accountIdMap = new Map<Id, Id>();
            for (Id accountId : uniqueAccountIds) {
                accountIdMap.put(accountId, accountId);
            }
            InvestmentQuestionnaireHelper.updateAccountGoldSilverStatus(accountIdMap);
        }
        
        System.debug('🔵 Trigger completed. Final isCaseCreated value: ' + InvestmentQuestionnaireHelper.isCaseCreated);        
    }
    
}