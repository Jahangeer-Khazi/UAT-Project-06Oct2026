public class ReturnedCardsHandler {
    
    public static Set<Id> recordsForCallout = new Set<Id>();
    public static Boolean isFromBulkOperationReject = false;
    private static Map<String, Map<String, String>> branchTranslations;

    /**
     * Initialize Branch Translation Map from Custom Metadata
     */
    @TestVisible
    private static void initBranchTranslations() {
        if (branchTranslations != null) {
            return;
        }

        branchTranslations = new Map<String, Map<String, String>>{
            'English' => new Map<String, String>(),
            'Arabic'  => new Map<String, String>()
        };

        for (Branch_Translation__mdt bt : [
            SELECT English_Name__c, Arabic_Name__c 
            FROM Branch_Translation__mdt 
            WHERE English_Name__c != null
        ]) {
            String engName = bt.English_Name__c.trim();
            String arbName = String.isNotBlank(bt.Arabic_Name__c) ? bt.Arabic_Name__c.trim() : engName;

            branchTranslations.get('English').put(engName, engName);
            branchTranslations.get('Arabic').put(engName, arbName);
        }
    }

    /**
     * Returns translated branch name based on language
     */
    @TestVisible
    private static String getTranslatedBranch(String branchName, String language) {
        if (String.isBlank(branchName)) {
            return '';
        }
        
        initBranchTranslations();
        
        if (language == 'Arabic') {
            return branchTranslations.get('Arabic').get(branchName) ?? branchName;
        }
        
        return branchName; // Default to English or original value
    }
    
    public static void handleBeforeUpdate(List<Returned_Cards__c> newList, Map<Id, Returned_Cards__c> oldMap) {
        Map<String, String> subStatusToDescription = new Map<String, String>{
            'Dispatch' => 'Card sent to another branch for customer pickup.',
                'Dispatch Return' => 'Receiving branch returns the card to the main branch.',
                'Collected by Customer' => 'Customer picked up card.',
                'Destroyed' => 'Card destroyed (Shredded) after exceeding the SLA period.',
                'Re-delivery' => 'Card is re-sent to the courier for another delivery attempt following a customer request'
                };
                    
                    Set<String> closedSubStatuses = new Set<String>{
                        'Collected by Customer',
                            'Re-delivery',
                            'Destroyed'
                            };
                                
                                for (Returned_Cards__c rc : newList) {
                                    Returned_Cards__c oldRc = oldMap.get(rc.Id);
                                    
                                    if (rc.Sub_Status__c != oldRc.Sub_Status__c && rc.Sub_Status__c != null) {
                                        
                                        if (subStatusToDescription.containsKey(rc.Sub_Status__c)) {
                                            rc.Description__c = subStatusToDescription.get(rc.Sub_Status__c);
                                        }
                                        
                                        if (closedSubStatuses.contains(rc.Sub_Status__c)) {
                                            rc.Status__c = 'Closed';
                                        } else {
                                            rc.Status__c = 'Open';
                                        }
                                        
                                        // Only add to callouts if NOT from bulk operation reject
                                        if (!isFromBulkOperationReject) {
                                            recordsForCallout.add(rc.Id);
                                        }
                                    }
                                }
    }
    
    public static void processCalloutsForRecords(Set<Id> returnedCardIds) {
        if (returnedCardIds == null || returnedCardIds.isEmpty()) {
            return;
        }
        
        List<Returned_Cards__c> returnedCards = [
            SELECT Id, Sub_Status__c, Case_Model__c, Region_Flag__c, 
            CIF__c, Customer__c, Customer__r.PersonEmail, Language_Preference__c,  
            Customer__r.PersonMobilePhone, Dispatch_To_Branch__c,
            Last_Api_Call_Status__c, CardType__c, Customer__r.Name
            FROM Returned_Cards__c 
            WHERE Id IN :returnedCardIds
        ];
        
        List<System_Action__c> systemActions = new List<System_Action__c>();
        List<Returned_Cards__c> cardsToUpdate = new List<Returned_Cards__c>();
        
        for (Returned_Cards__c rc : returnedCards) {
            try {
                String regionName = rc.Region_Flag__c;
                if (rc.Case_Model__c == 'alburaq') {
                    regionName += '_alburaq';
                }
                
                ApiConnection con = new ApiConnection();
                
                List<Map<String, String>> notificationsToSend = getNotificationsForSubStatus(rc.Sub_Status__c, rc.Region_Flag__c);
                
                Boolean allCallsSuccessful = true;
                
                for (Map<String, String> notification : notificationsToSend) {
                    String templateCode = notification.get('templateCode');
                    String notificationType = notification.get('notificationType');
                    
                    try {
                        HttpRequest request = con.createRequest('POST', '/api/v1/notifications?', regionName);
                        HttpResponse response = sendNotificationApi(request, rc, templateCode, notificationType);
                        
                        systemActions.add(createSystemAction(
                            request, response, rc, 
                            'Returned Cards ' + notificationType.toUpperCase() + ' Notification - ' + templateCode,
                            'Returned Cards'
                        ));
                        
                        if (response.getStatusCode() != 200) {
                            allCallsSuccessful = false;
                        }
                        
                    } catch (Exception e) {
                        systemActions.add(createErrorSystemAction(e, rc, notificationType + ' - ' + templateCode));
                        allCallsSuccessful = false;
                    }
                }
                
                rc.Last_Api_Call_Status__c = allCallsSuccessful ? 'Success' : 'Failed';
                cardsToUpdate.add(rc);
                
            } catch (Exception e) {
                systemActions.add(createErrorSystemAction(e, rc, 'general'));
                rc.Last_Api_Call_Status__c = 'Failed';
                cardsToUpdate.add(rc);
            }
        }
        
        if (!systemActions.isEmpty()) {
            insert systemActions;
        }
        
        if (!cardsToUpdate.isEmpty()) {
            try {
                update cardsToUpdate;
            } catch (Exception e) {
                System.debug('Update error: ' + e.getMessage());
            }
        }
    }
    
    @TestVisible
    private static List<Map<String, String>> getNotificationsForSubStatus(String subStatus, String regionName) {
        Map<String, Map<String, String>> regionTemplateConfig = new Map<String, Map<String, String>>{
            'Bahrain' => new Map<String, String>{
                'Pending For Pick-up' => 'RET_CARD_PENDING_FOR_PICKUP',
                    'Destroyed' => 'RET_CARD_DESTROY',
                    'Collected by Customer' => 'RET_CARD_COLLECTED_BY_CUSTOMER',
                    'Dispatch' => 'BAH_RET_CARD_DISPATCH',
                    'Dispatch Return' => 'BAH_RET_CARD_DISPATCH_RETURN',
                    'Re-delivery' => 'RET_CARD_RE_DELIVERY'
                    },
                        'Jordan' => new Map<String, String>{
                            'Pending For Pick-up' => 'RET_CARD_PENDING_FOR_PICKUP_JOR',
                                'Destroyed' => 'RET_CARD_DESTROY_JOR',
                                'Collected by Customer' => 'RET_CARD_COLLECTED_BY_CUSTOMER_JOR',
                                'Dispatch' => 'RET_CARD_DISPATCH_JOR',
                                'Dispatch Return' => 'RET_CARD_DISPATCH_RETURN_JOR',
                                'Re-delivery' => 'RET_CARD_RE_DELIVERY_JOR'
                                }
        };
            
            Map<String, String> defaultTemplates = new Map<String, String>{
                'Pending For Pick-up' => 'RET_CARD_PENDING_FOR_PICKUP_JOR',
                    'Destroyed' => 'RET_CARD_DESTROY_JOR',
                    'Collected by Customer' => 'RET_CARD_COLLECTED_BY_CUSTOMER_JOR',
                    'Dispatch' => 'RET_CARD_DISPATCH_JOR',
                    'Dispatch Return' => 'RET_CARD_DISPATCH_RETURN_JOR',
                    'Re-delivery' => 'RET_CARD_RE_DELIVERY_JOR'
                    };
                        
                        Map<String, List<String>> notificationTypesConfig = new Map<String, List<String>>{
                            'Pending For Pick-up' => new List<String>{'email', 'sms'},
                                'Destroyed' => new List<String>{'email', 'sms'},
                                    'Collected by Customer' => new List<String>{'email'},
                                        'Dispatch' => new List<String>{'email'},
                                            'Dispatch Return' => new List<String>{'email'},
                                                'Re-delivery' => new List<String>{'email'}
                        };
                            
                            List<Map<String, String>> notifications = new List<Map<String, String>>();
        
        String templateCode;
        
        if (regionTemplateConfig.containsKey(regionName)) {
            templateCode = regionTemplateConfig.get(regionName).get(subStatus);
        }
        
        if (String.isBlank(templateCode)) {
            templateCode = defaultTemplates.get(subStatus);
        }
        
        if (String.isNotBlank(templateCode) && notificationTypesConfig.containsKey(subStatus)) {
            for (String notificationType : notificationTypesConfig.get(subStatus)) {
                notifications.add(new Map<String, String>{
                    'templateCode' => templateCode,
                        'notificationType' => notificationType
                        });
            }
        }
        
        return notifications;
    }
    
    public static HttpResponse sendNotificationApi(HttpRequest request, Returned_Cards__c retCard, String templateCode, String notificationType) {
        request.setHeader('customerId', retCard.CIF__c);
        request.setHeader('userId', retCard.Customer__r.PersonEmail);
        
        // Create placeholder list
        List<Map<String, String>> placeholderList = new List<Map<String, String>>();
        
        String cardType = retCard.CardType__c;
        String result;  
        
        if(cardType != null) {
            String normalized = cardType.toLowerCase();
            
            if(normalized == 'credit card') {
                if(retCard.Language_Preference__c == 'English') {
                    result = 'Credit';
                } else if(retCard.Language_Preference__c == 'Arabic') {
                    result = 'الائتمانية';
                }
            } else if(normalized == 'debit card') {
                if(retCard.Language_Preference__c == 'English') {
                    result = 'Debit';
                } else if(retCard.Language_Preference__c == 'Arabic') {
                    result = 'الخصم المباشر';
                }
            }
        }
        
        placeholderList.add(new Map<String, String>{
            'fieldName' => 'CardType',
                'fieldText' => result
                });
        
        if(retCard.Sub_Status__c == 'Dispatch') {

            String branchDisplay = getTranslatedBranch(retCard.Dispatch_To_Branch__c, retCard.Language_Preference__c);

            placeholderList.add(new Map<String, String>{
                'fieldName' => 'DispatchToBranch',
                    'fieldText' => branchDisplay
                        });
            placeholderList.add(new Map<String, String>{
                'fieldName' => 'Name',
                    'fieldText' => retCard.Customer__r.Name != null ? retCard.Customer__r.Name : ''
                        });
        } 
        else if(retCard.Sub_Status__c == 'Destroyed' || 
                retCard.Sub_Status__c == 'Collected by Customer' || 
                retCard.Sub_Status__c == 'Re-delivery' || 
                retCard.Sub_Status__c == 'Pending For Pick-up' ||
                retCard.Sub_Status__c == 'Dispatch Return') {
                    placeholderList.add(new Map<String, String>{
                        'fieldName' => 'Name',
                            'fieldText' => retCard.Customer__r.Name != null ? retCard.Customer__r.Name : ''
                                });
                }
        
        Map<String, Object> bodyMap = new Map<String, Object>{
            'type' => notificationType,
                'templateCode' => templateCode,
                'subject' => null,
                'phoneNumber' => retCard.Customer__r.PersonMobilePhone,
                'placeholderReplacements' => placeholderList
                };
                    
                    String bodyTxt = JSON.serialize(bodyMap);
        request.setBody(bodyTxt);
        request.setHeader('Content-Type', 'application/json');
        
        HttpResponse response = new Http().send(request);
        return response;
    }
    
    @TestVisible
    private static System_Action__c createSystemAction(
        HttpRequest request, HttpResponse response, Returned_Cards__c rc,
        String actionName, String objectName
    ) {
        return SM001_ApiCalls.setSystemActionForReturnedCard(
            request.getBody(),
            response.getBody(),
            request.getEndpoint(),
            request.getMethod(),
            rc.Id,
            rc.CIF__c,
            rc.Customer__c,
            response.getStatusCode(),
            actionName,
            objectName
        );
    }
    
    @TestVisible
    private static System_Action__c createErrorSystemAction(Exception e, Returned_Cards__c rc, String notificationDetails) {
        String errorDescription = 'Error Message: ' + e.getMessage() + 
            '; Trace: ' + String.valueOf(e.getStackTraceString()) +
            '; Notification Details: ' + notificationDetails;
        
        return SM001_ApiCalls.setSystemActionForReturnedCard(
            null,
            errorDescription,
            null,
            null,
            rc.Id,
            rc.CIF__c,
            rc.Customer__c,
            null,
            'Returned Cards Notification Error - ' + notificationDetails,
            'Returned Cards'
        );
    }
    
    public static void calculateAcceptedWarnings(List<Returned_Cards__c> returnedCards) {
        if (isFromBulkOperationReject) {
            return;
        }
        
        try {
            Set<String> cifNumbers = new Set<String>();
            for (Returned_Cards__c rc : returnedCards) {
                if (String.isNotBlank(rc.CIF__c)) {
                    cifNumbers.add(rc.CIF__c);
                }
            }
            
            if (cifNumbers.isEmpty()) return;
            
            Map<String, Id> cifToAccountIdMap = new Map<String, Id>();
            Map<String, String> cifToRegionFlagMap = new Map<String, String>();
            for (Account acc : [SELECT Id, CIF__pc, Region_Flag__pc FROM Account 
                                WHERE CIF__pc IN :cifNumbers 
                                AND CIF__pc != null]) {
                                    cifToAccountIdMap.put(acc.CIF__pc, acc.Id);
                                    cifToRegionFlagMap.put(acc.CIF__pc, acc.Region_Flag__pc);
                                }
            
            if (cifToAccountIdMap.isEmpty()) return;
            
            Date last30Days = System.today().addDays(-30);
            DateTime last30DaysDateTime = DateTime.newInstance(last30Days.year(), last30Days.month(), last30Days.day());
            
            Map<Id, Integer> accountCaseCountMap = new Map<Id, Integer>();
            for (AggregateResult ar : [
                SELECT AccountId, COUNT(Id) caseCount
                FROM Case
                WHERE AccountId IN :cifToAccountIdMap.values()
                AND RecordType.DeveloperName = 'Request'
                AND Type IN ('Debit Card', 'Credit Card')
                AND Sub_Type__c = 'Card Service'
                AND cc_Request_Type__c IN (
                    'Replacement - with Fees',
                    'Replacement -Without Fees',
                    'New card Issuance - with Balance',
                    'New card Issuance - with no Balance',
                    'Down grade to classic',
                    'Freeze',
                    'Unfreeze'
                )
                AND CreatedDate >= :last30DaysDateTime
                GROUP BY AccountId
            ]) {
                Id accountId = (Id)ar.get('AccountId');
                Integer caseCount = (Integer)ar.get('caseCount');
                accountCaseCountMap.put(accountId, caseCount);
            }
            
            for (Returned_Cards__c rc : returnedCards) {
                if (String.isNotBlank(rc.CIF__c)) {
                    Id accountId = cifToAccountIdMap.get(rc.CIF__c);
                    if (accountId != null && accountCaseCountMap.containsKey(accountId)) {
                        rc.Accepted_Warnings__c = accountCaseCountMap.get(accountId);
                    } else {
                        rc.Accepted_Warnings__c = 0;
                    }
                    rc.RegionFlag__c = cifToRegionFlagMap.get(rc.CIF__c);
                }
            }
            
        } catch (Exception e) {
            System.debug('Error calculating Accepted_Warnings__c: ' + e.getMessage());
        }
    }
    
    public static void updateAcceptedWarningsAfterTrigger(Set<Id> returnedCardIds) {
        if (isFromBulkOperationReject) {
            return;
        }
        
        List<Returned_Cards__c> cardsToUpdate = new List<Returned_Cards__c>();
        
        List<Returned_Cards__c> returnedCards = [
            SELECT Id, CIF__c, Accepted_Warnings__c 
            FROM Returned_Cards__c 
            WHERE Id IN :returnedCardIds
            AND CIF__c != null
        ];
        
        if (returnedCards.isEmpty()) return;
        
        Set<String> cifNumbers = new Set<String>();
        for (Returned_Cards__c rc : returnedCards) {
            cifNumbers.add(rc.CIF__c);
        }
        
        Map<String, Id> cifToAccountIdMap = new Map<String, Id>();
        for (Account acc : [SELECT Id, CIF__pc FROM Account 
                            WHERE CIF__pc IN :cifNumbers 
                            AND CIF__pc != null]) {
                                cifToAccountIdMap.put(acc.CIF__pc, acc.Id);
                            }
        
        if (cifToAccountIdMap.isEmpty()) return;
        
        Date last30Days = System.today().addDays(-30);
        DateTime last30DaysDateTime = DateTime.newInstance(last30Days.year(), last30Days.month(), last30Days.day());
        
        Map<Id, Integer> accountCaseCountMap = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT AccountId, COUNT(Id) caseCount
            FROM Case
            WHERE AccountId IN :cifToAccountIdMap.values()
            AND RecordType.DeveloperName = 'Request'
            AND Type IN ('Debit Card', 'Credit Card')
            AND Sub_Type__c = 'Card Service'
            AND cc_Request_Type__c IN (
                'Replacement - with Fees',
                'Replacement -Without Fees',
                'New card Issuance - with Balance',
                'New card Issuance - with no Balance',
                'Down grade to classic',
                'Freeze',
                'Unfreeze'
            )
            AND CreatedDate >= :last30DaysDateTime
            GROUP BY AccountId
        ]) {
            Id accountId = (Id)ar.get('AccountId');
            Integer caseCount = (Integer)ar.get('caseCount');
            accountCaseCountMap.put(accountId, caseCount);
        }
        
        for (Returned_Cards__c rc : returnedCards) {
            if (String.isNotBlank(rc.CIF__c)) {
                Id accountId = cifToAccountIdMap.get(rc.CIF__c);
                Decimal currentValue = rc.Accepted_Warnings__c;
                Decimal newValue;
                
                if (accountId != null && accountCaseCountMap.containsKey(accountId)) {
                    newValue = accountCaseCountMap.get(accountId);
                } else {
                    newValue = 0;
                }
                
                if (currentValue != newValue) {
                    rc.Accepted_Warnings__c = newValue;
                    cardsToUpdate.add(rc);
                }
            }
        }
        
        if (!cardsToUpdate.isEmpty()) {
            try {
                update cardsToUpdate;
            } catch (Exception e) {
                System.debug('Error updating Returned_Cards__c: ' + e.getMessage());
            }
        }
    }
    
    public static void handleAfterDelete(List<Returned_Cards__c> deletedCards) {
        if (isFromBulkOperationReject) {
            return;
        }
        
        Set<String> affectedCIFs = new Set<String>();
        for (Returned_Cards__c rc : deletedCards) {
            if (String.isNotBlank(rc.CIF__c)) {
                affectedCIFs.add(rc.CIF__c);
            }
        }
        
        if (affectedCIFs.isEmpty()) return;
        
        List<Returned_Cards__c> remainingCards = [
            SELECT Id 
            FROM Returned_Cards__c 
            WHERE CIF__c IN :affectedCIFs
        ];
        
        if (!remainingCards.isEmpty()) {
            Set<Id> cardIds = new Set<Id>();
            for (Returned_Cards__c rc : remainingCards) {
                cardIds.add(rc.Id);
            }
            updateAcceptedWarningsAfterTrigger(cardIds);
        }
    }
    
    public static void populateSubject(List<Returned_Cards__c> records) {
        if (isFromBulkOperationReject) {
            return;
        }
        
        if (records == null || records.isEmpty()) {
            return;
        }
        
        Set<Id> bulkOpIds = new Set<Id>();
        
        for (Returned_Cards__c rc : records) {
            if (rc.Returned_Card_Bulk_Operation__c != null) {
                bulkOpIds.add(rc.Returned_Card_Bulk_Operation__c);
            }
        }
        
        if (bulkOpIds.isEmpty()) {
            return;
        }
        
        Map<Id, Returned_Card_Bulk_Operation__c> bulkOpMap = new Map<Id, Returned_Card_Bulk_Operation__c>(
            [SELECT Id, Name FROM Returned_Card_Bulk_Operation__c WHERE Id IN :bulkOpIds]
        );
        
        for (Returned_Cards__c rc : records) {
            if (rc.Returned_Card_Bulk_Operation__c != null && bulkOpMap.containsKey(rc.Returned_Card_Bulk_Operation__c)) {
                String bulkName = bulkOpMap.get(rc.Returned_Card_Bulk_Operation__c).Name;
                String cif = rc.CIF__c != null ? rc.CIF__c : '';
                
                rc.Subject__c = 'Returned Card - ' + bulkName + ' - ' + cif;
            }
        }
    }
}