public class InvestmentQuestionnaireHelper {
    
    // Queue/Group name for Investment Questionnaire Review Maker
    private static final String REVIEW_MAKER_QUEUE_NAME = 'Investment Questionnaire Review Maker';
    public static Boolean isCaseCreated = false;
    
    public static Map<String, Id> getAccountIdsByCIF(Set<String> cifValues) {
        System.debug('🔍 Getting Account IDs for CIF values: ' + cifValues);
        Map<String, Id> cifToAccountId = new Map<String, Id>();
        
        if (!cifValues.isEmpty()) {
            List<Account> accounts = [SELECT Id, CIF__pc FROM Account WHERE CIF__pc IN :cifValues];
            System.debug('📊 Found ' + accounts.size() + ' accounts');
            
            for (Account acc : accounts) {
                cifToAccountId.put(acc.CIF__pc, acc.Id);
                System.debug('   Mapped CIF ' + acc.CIF__pc + ' to Account ID: ' + acc.Id);
            }
            
            // Check for CIF values not found
            for (String cif : cifValues) {
                if (!cifToAccountId.containsKey(cif)) {
                    System.debug('⚠️ No account found for CIF: ' + cif);
                }
            }
        }
        
        return cifToAccountId;
    }
    
    public static List<Questionnaire_Response__c> createQuestionnaireResponses(
        Investment_Questionnaire__c questionnaire, 
        Id accountId
    ) {
        System.debug('📝 Creating responses for questionnaire: ' + questionnaire.Id);
        System.debug('   Account ID: ' + accountId);
        
        List<Questionnaire_Response__c> responses = new List<Questionnaire_Response__c>();
        
        if (String.isBlank(questionnaire.Investment_Questionnaire_JSON__c)) {
            System.debug('❌ Investment_Questionnaire_JSON__c is blank for questionnaire: ' + questionnaire.Id);
            return responses;
        }
        
        System.debug('   JSON field length: ' + questionnaire.Investment_Questionnaire_JSON__c.length());
        System.debug('   JSON preview: ' + questionnaire.Investment_Questionnaire_JSON__c.left(200));
        
        try {
            Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(
                questionnaire.Investment_Questionnaire_JSON__c
            );
            
            System.debug('   Successfully deserialized JSON');
            System.debug('   JSON keys: ' + jsonData.keySet());
            
            List<Object> questions = (List<Object>) jsonData.get('questions');
            
            if (questions != null) {
                System.debug('   Found ' + questions.size() + ' questions');
                
                for (Integer i = 0; i < questions.size(); i++) {
                    Object questionObj = questions[i];
                    Map<String, Object> questionMap = (Map<String, Object>) questionObj;
                    
                    System.debug('   Processing question ' + (i + 1) + ': ' + questionMap.get('questionId'));
                    
                    // Process options array into numbered list
                    String optionsFormatted = '';
                    List<Object> optionsList = (List<Object>) questionMap.get('options');
                    if (optionsList != null && !optionsList.isEmpty()) {
                        for (Integer j = 0; j < optionsList.size(); j++) {
                            optionsFormatted += (j + 1) + '. ' + optionsList.get(j) + '\n';
                        }
                        System.debug('      Options: ' + optionsFormatted);
                    }
                    
                    Questionnaire_Response__c response = new Questionnaire_Response__c(
                        Investment_Questionnaire__c = questionnaire.Id,
                        Customer__c = accountId,
                        Question_Number__c = (Integer) questionMap.get('questionId'),
                        Question__c = (String) questionMap.get('questionText'),
                        Answer_Type__c = (String) questionMap.get('type'),
                        Category__c = (String) questionMap.get('category'),
                        Requires_Manual_Approval__c = (Boolean) questionMap.get('manualApprovalRequired'),
                        Options__c = optionsFormatted
                    );
                    
                    // Handle answer
                    if (questionMap.containsKey('selectedAnswer')) {
                        response.Selected_Answer__c = (String) questionMap.get('selectedAnswer');
                        System.debug('      Single answer: ' + response.Selected_Answer__c);
                    } else if (questionMap.containsKey('selectedAnswers')) {
                        List<Object> selectedAnswers = (List<Object>) questionMap.get('selectedAnswers');
                        if (selectedAnswers != null && !selectedAnswers.isEmpty()) {
                            response.Selected_Answer__c = String.join(selectedAnswers, '; ');
                            System.debug('      Multi answers: ' + response.Selected_Answer__c);
                        }
                    }
                    
                    responses.add(response);
                }
            } else {
                System.debug('❌ No questions array found in JSON');
            }
            
        } catch (Exception e) {
            System.debug('❌ Error processing questionnaire: ' + questionnaire.Id);
            System.debug('   Error Type: ' + e.getTypeName());
            System.debug('   Error Message: ' + e.getMessage());
            System.debug('   Line Number: ' + e.getLineNumber());
            System.debug('   Stack Trace: ' + e.getStackTraceString());
        }
        
        System.debug('📊 Total responses created: ' + responses.size());
        return responses;
    }
    
    public static void createManualApprovalCases(Set<Id> questionnaireIds, List<Investment_Questionnaire__c> questionnaires, Id accId) {
        System.debug('📋 Creating manual approval cases for questionnaires: ' + questionnaireIds);
        System.debug('   Using Account ID: ' + accId);
        
        isCaseCreated = true;
        
        // Get Record Type Id for Investment Questionnaire Review
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('Investment_Questionnaire_Review')?.getRecordTypeId();
        
        if (caseRecordTypeId == null) {
            System.debug('❌ Record Type "Investment_Questionnaire_Review" not found');
            isCaseCreated = false;
            return;
        }
        System.debug('   Record Type ID: ' + caseRecordTypeId);
        
        // Get Queue/Group Id for Investment Questionnaire Review Maker
        List<Group> queueList = [SELECT Id, Name FROM Group 
                                 WHERE Type = 'Queue' 
                                 AND Name = :REVIEW_MAKER_QUEUE_NAME 
                                 LIMIT 1];
        
        Id reviewMakerQueueId = queueList.isEmpty() ? null : queueList[0].Id;
        
        if (reviewMakerQueueId == null) {
            System.debug('❌ Queue "' + REVIEW_MAKER_QUEUE_NAME + '" not found');
            isCaseCreated = false;
        } else {
            System.debug('   Queue ID: ' + reviewMakerQueueId);
        }
        
        // Map to quickly access questionnaire records by Id
        Map<Id, Investment_Questionnaire__c> questionnaireMap = new Map<Id, Investment_Questionnaire__c>(questionnaires);
        
        List<Case> casesToInsert = new List<Case>();
        
        for (Id questionnaireId : questionnaireIds) {
            Investment_Questionnaire__c questionnaire = questionnaireMap.get(questionnaireId);
            
            // Build description with questionnaire details
            String caseDescription = 'New Investment Questionnaire Review\n' +
                'Questionnaire ID: ' + questionnaireId + '\n' +
                'CIF: ' + questionnaire.CIF__c + '\n' +
                'Product Type: ' + questionnaire.Product_Type__c;
            
            Case newCase = new Case(
                RecordTypeId = caseRecordTypeId,
                Type = 'New Investment Questionnaire Review',
                Origin = 'App',
                Subject = 'Investment Questionnaire Review',
                Description = caseDescription,
                Status = 'Open',
                Case_Nature__c = 'Gold & Silver Accounts',
                AccountId = accId
            );
            
            // Set custom fields if they exist
            if (Schema.sObjectType.Case.fields.getMap().containsKey('Nature__c')) {
                newCase.put('Nature__c', 'Gold & Silver Accounts');
            } else {
                System.debug('⚠️ Field Nature__c does not exist on Case');
            }
            
            if (Schema.sObjectType.Case.fields.getMap().containsKey('Sub_Status__c')) {
                newCase.put('Sub_Status__c', 'In-Progress');
            } else {
                System.debug('⚠️ Field Sub_Status__c does not exist on Case');
            }
            
            if (Schema.sObjectType.Case.fields.getMap().containsKey('Investment_Questionnaire__c')) {
                newCase.put('Investment_Questionnaire__c', questionnaireId);
            } else {
                System.debug('⚠️ Field Investment_Questionnaire__c does not exist on Case');
            }
            
            newCase.OwnerId = reviewMakerQueueId;
            
            casesToInsert.add(newCase);
            System.debug('   Created case for questionnaire: ' + questionnaireId);
        }
        
        if (!casesToInsert.isEmpty()) {
            try {
                insert casesToInsert;
                System.debug('✅ Successfully inserted ' + casesToInsert.size() + ' cases');
                
                // Log inserted case IDs
                Set<Id> caseIds = new Set<Id>();
                for (Case c : casesToInsert) {
                    caseIds.add(c.Id);
                }
                System.debug('   Case IDs: ' + caseIds);
                
            } catch (Exception e) {
                System.debug('❌ Error creating cases: ' + e.getMessage());
                System.debug('   Error Type: ' + e.getTypeName());
                System.debug('   Stack Trace: ' + e.getStackTraceString());
                isCaseCreated = false;
            }
        } else {
            isCaseCreated = false;
        }
    }
    
    public static void updateAccountGoldSilverStatus(Map<Id, Id> accountIdsMap) {
        System.debug('🔄 Updating Account Gold_Silver_Questionnaire_Status__c to "Under Review"');
        
        List<Account> accountsToUpdate = new List<Account>();
        
        for (Id accountId : accountIdsMap.values()) {
            Account updateRecord = new Account(
                Id = accountId,
                Gold_Silver_Submission_Date__c = System.now()
            );
            
            System.debug('isCaseCreated -->'+isCaseCreated);
            if(isCaseCreated) {
                updateRecord.Gold_Silver_Questionnaire_Status__c = 'Under Review';
            } else {
                updateRecord.Gold_Silver_Questionnaire_Status__c = 'Approved';
            }
            
            accountsToUpdate.add(updateRecord);
            System.debug('   Will update Account ' + accountId + ' status to Under Review');
        }
        
        if (!accountsToUpdate.isEmpty()) {
            try {
                update accountsToUpdate;
                System.debug('✅ Successfully updated ' + accountsToUpdate.size() + ' Account statuses');
            } catch (DmlException e) {
                System.debug('❌ Error updating Account statuses: ' + e.getMessage());
            }
        }
    }
    
    public static void resetCaseCreatedFlag() {
        isCaseCreated = false;
        System.debug('🔄 Reset isCaseCreated flag to false');
    }
}