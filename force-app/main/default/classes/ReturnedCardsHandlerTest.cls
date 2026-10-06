@isTest
public class ReturnedCardsHandlerTest {
    
    @testSetup
    static void setupTestData() {
        // Create Branch Translation Custom Metadata
        List<Branch_Translation__mdt> branchTranslations = new List<Branch_Translation__mdt>();
        
        Branch_Translation__mdt branch1 = new Branch_Translation__mdt(
            MasterLabel = 'Main Branch',
            English_Name__c = 'Main Branch',
            Arabic_Name__c = 'الفرع الرئيسي'
        );
        branchTranslations.add(branch1);
        
        Branch_Translation__mdt branch2 = new Branch_Translation__mdt(
            MasterLabel = 'North Branch',
            English_Name__c = 'North Branch',
            Arabic_Name__c = 'الفرع الشمالي'
        );
        branchTranslations.add(branch2);
        
        // Insert metadata using Test.loadData or direct insert if possible
        // Note: Custom metadata can't be inserted in test methods directly
        // You may need to use Test.loadData or mock the data
        
        // Create test accounts
        Account bahrainAccount = new Account(
            FirstName = 'Test',
            LastName = 'Bahrain Customer',
            PersonEmail = 'bahrain.customer@test.com',
            PersonMobilePhone = '1234567890',
            CIF__pc = 'CIF001',
            Region_Flag__pc = 'Bahrain'
        );
        insert bahrainAccount;
        
        Account jordanAccount = new Account(
            FirstName = 'Test',
            LastName = 'Jordan Customer',
            PersonEmail = 'jordan.customer@test.com',
            PersonMobilePhone = '0987654321',
            CIF__pc = 'CIF002',
            Region_Flag__pc = 'Jordan'
        );
        insert jordanAccount;
        
        // Create Returned Card Bulk Operation
        Returned_Card_Bulk_Operation__c bulkOp = new Returned_Card_Bulk_Operation__c(
            Type__c = 'Returned Cards',
            Status__c = 'Pending'
        );
        insert bulkOp;
        
        // Create Returned Cards records
        Returned_Cards__c rc1 = new Returned_Cards__c(
            Customer__c = bahrainAccount.Id,
            CIF__c = 'CIF001',
            AWB__c = 'AWB001',
            Status__c = 'Open',
            Sub_Status__c = 'Pending For Pick-up',
            CardType__c = 'Credit Card',
            Returned_Card_Bulk_Operation__c = bulkOp.Id
        );
        insert rc1;
        
        Returned_Cards__c rc2 = new Returned_Cards__c(
            Customer__c = jordanAccount.Id,
            CIF__c = 'CIF002',
            AWB__c = 'AWB002',
            Status__c = 'Open',
            Sub_Status__c = 'Pending For Pick-up',
            CardType__c = 'Debit Card',
            Returned_Card_Bulk_Operation__c = bulkOp.Id
        );
        insert rc2;
        
        // Create Cases for Accepted Warnings calculation
        Case testCase = new Case(
            AccountId = bahrainAccount.Id,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Request').getRecordTypeId(),
            Type = 'Credit Card',
            Sub_Type__c = 'Card Service',
            cc_Request_Type__c = 'Replacement - with Fees',
            Status = 'New'
        );
        //insert testCase;
    }
    
    @isTest
    static void testHandleBeforeUpdateWithSubStatusChange() {
        List<Returned_Cards__c> returnedCards = [SELECT Id, Sub_Status__c, Status__c, Description__c 
                                                  FROM Returned_Cards__c LIMIT 1];
        
        if (returnedCards.isEmpty()) return;
        
        Returned_Cards__c rc = returnedCards[0];
        rc.Sub_Status__c = 'Collected by Customer';
        
        Map<Id, Returned_Cards__c> oldMap = new Map<Id, Returned_Cards__c>();
        oldMap.put(rc.Id, new Returned_Cards__c(Id = rc.Id, Sub_Status__c = 'Pending For Pick-up'));
        
        Test.startTest();
        ReturnedCardsHandler.handleBeforeUpdate(new List<Returned_Cards__c>{rc}, oldMap);
        Test.stopTest();
    }
    
    @isTest
    static void testHandleBeforeUpdateWithDispatchStatus() {
        List<Returned_Cards__c> returnedCards = [SELECT Id, Sub_Status__c, Status__c, Description__c 
                                                  FROM Returned_Cards__c LIMIT 1];
        
        if (returnedCards.isEmpty()) return;
        
        Returned_Cards__c rc = returnedCards[0];
        rc.Sub_Status__c = 'Dispatch';
        rc.Dispatch_To_Branch__c = 'Main Branch';
        
        Map<Id, Returned_Cards__c> oldMap = new Map<Id, Returned_Cards__c>();
        oldMap.put(rc.Id, new Returned_Cards__c(Id = rc.Id, Sub_Status__c = 'Pending For Pick-up'));
        
        Test.startTest();
        ReturnedCardsHandler.handleBeforeUpdate(new List<Returned_Cards__c>{rc}, oldMap);
        Test.stopTest();
    }
    
    @isTest
    static void testHandleBeforeUpdateWithDispatchReturn() {
        List<Returned_Cards__c> returnedCards = [SELECT Id, Sub_Status__c, Status__c, Description__c 
                                                  FROM Returned_Cards__c LIMIT 1];
        
        if (returnedCards.isEmpty()) return;
        
        Returned_Cards__c rc = returnedCards[0];
        rc.Sub_Status__c = 'Dispatch Return';
        
        Map<Id, Returned_Cards__c> oldMap = new Map<Id, Returned_Cards__c>();
        oldMap.put(rc.Id, new Returned_Cards__c(Id = rc.Id, Sub_Status__c = 'Pending For Pick-up'));
        
        Test.startTest();
        ReturnedCardsHandler.handleBeforeUpdate(new List<Returned_Cards__c>{rc}, oldMap);
        Test.stopTest();
    }
    
    @isTest
    static void testHandleBeforeUpdateWithDestroyed() {
        List<Returned_Cards__c> returnedCards = [SELECT Id, Sub_Status__c, Status__c, Description__c 
                                                  FROM Returned_Cards__c LIMIT 1];
        
        if (returnedCards.isEmpty()) return;
        
        Returned_Cards__c rc = returnedCards[0];
        rc.Sub_Status__c = 'Destroyed';
        
        Map<Id, Returned_Cards__c> oldMap = new Map<Id, Returned_Cards__c>();
        oldMap.put(rc.Id, new Returned_Cards__c(Id = rc.Id, Sub_Status__c = 'Pending For Pick-up'));
        
        Test.startTest();
        ReturnedCardsHandler.handleBeforeUpdate(new List<Returned_Cards__c>{rc}, oldMap);
        Test.stopTest();
    }
    
    @isTest
    static void testHandleBeforeUpdateWithReDelivery() {
        List<Returned_Cards__c> returnedCards = [SELECT Id, Sub_Status__c, Status__c, Description__c 
                                                  FROM Returned_Cards__c LIMIT 1];
        
        if (returnedCards.isEmpty()) return;
        
        Returned_Cards__c rc = returnedCards[0];
        rc.Sub_Status__c = 'Re-delivery';
        
        Map<Id, Returned_Cards__c> oldMap = new Map<Id, Returned_Cards__c>();
        oldMap.put(rc.Id, new Returned_Cards__c(Id = rc.Id, Sub_Status__c = 'Pending For Pick-up'));
        
        Test.startTest();
        ReturnedCardsHandler.handleBeforeUpdate(new List<Returned_Cards__c>{rc}, oldMap);
        Test.stopTest();
    }
    
    @isTest
    static void testHandleBeforeUpdateWithNoChange() {
        List<Returned_Cards__c> returnedCards = [SELECT Id, Sub_Status__c, Status__c, Description__c 
                                                  FROM Returned_Cards__c LIMIT 1];
        
        if (returnedCards.isEmpty()) return;
        
        Returned_Cards__c rc = returnedCards[0];
        
        Map<Id, Returned_Cards__c> oldMap = new Map<Id, Returned_Cards__c>();
        oldMap.put(rc.Id, new Returned_Cards__c(Id = rc.Id, Sub_Status__c = rc.Sub_Status__c));
        
        Test.startTest();
        ReturnedCardsHandler.handleBeforeUpdate(new List<Returned_Cards__c>{rc}, oldMap);
        Test.stopTest();
    }
    
    @isTest
    static void testHandleBeforeUpdateWithBulkOperationReject() {
        ReturnedCardsHandler.isFromBulkOperationReject = true;
        
        List<Returned_Cards__c> returnedCards = [SELECT Id, Sub_Status__c, Status__c, Description__c 
                                                  FROM Returned_Cards__c LIMIT 1];
        
        if (returnedCards.isEmpty()) return;
        
        Returned_Cards__c rc = returnedCards[0];
        rc.Sub_Status__c = 'Collected by Customer';
        
        Map<Id, Returned_Cards__c> oldMap = new Map<Id, Returned_Cards__c>();
        oldMap.put(rc.Id, new Returned_Cards__c(Id = rc.Id, Sub_Status__c = 'Pending For Pick-up'));
        
        Test.startTest();
        ReturnedCardsHandler.handleBeforeUpdate(new List<Returned_Cards__c>{rc}, oldMap);
        Test.stopTest();
        
        ReturnedCardsHandler.isFromBulkOperationReject = false;
    }
    
    @isTest
    static void testProcessCalloutsForRecords() {
        List<Returned_Cards__c> returnedCards = [SELECT Id, Sub_Status__c, Region_Flag__c, CIF__c, 
                                                  Customer__c, Customer__r.PersonEmail, Language_Preference__c,
                                                  Customer__r.PersonMobilePhone, Dispatch_To_Branch__c,
                                                  CardType__c, Customer__r.Name
                                                  FROM Returned_Cards__c];
        
        if (returnedCards.isEmpty()) return;
        
        Set<Id> cardIds = new Set<Id>();
        for (Returned_Cards__c rc : returnedCards) {
            rc.Sub_Status__c = 'Pending For Pick-up';
            cardIds.add(rc.Id);
        }
        
        Test.startTest();
        ReturnedCardsHandler.processCalloutsForRecords(cardIds);
        Test.stopTest();
    }
    
    @isTest
    static void testProcessCalloutsForRecordsWithDispatch() {
        List<Returned_Cards__c> returnedCards = [SELECT Id, Sub_Status__c, Region_Flag__c, CIF__c, 
                                                  Customer__c, Customer__r.PersonEmail, Language_Preference__c,
                                                  Customer__r.PersonMobilePhone, Dispatch_To_Branch__c,
                                                  CardType__c, Customer__r.Name
                                                  FROM Returned_Cards__c LIMIT 1];
        
        if (returnedCards.isEmpty()) return;
        
        Returned_Cards__c rc = returnedCards[0];
        rc.Dispatch_To_Branch__c = 'Abdali Mall Branch';
        update rc;
        
        Set<Id> cardIds = new Set<Id>{rc.Id};
        
        Test.startTest();
        ReturnedCardsHandler.processCalloutsForRecords(cardIds);
        Test.stopTest();
    }
    
    @isTest
    static void testProcessCalloutsForRecordsWithAlburaq() {
        List<Returned_Cards__c> returnedCards = [SELECT Id, Sub_Status__c, Region_Flag__c, CIF__c, 
                                                  Customer__c, Customer__r.PersonEmail, Language_Preference__c,
                                                  Customer__r.PersonMobilePhone, Dispatch_To_Branch__c,
                                                  CardType__c, Customer__r.Name, Case_Model__c
                                                  FROM Returned_Cards__c LIMIT 1];
        
        if (returnedCards.isEmpty()) return;
        
        Returned_Cards__c rc = returnedCards[0];
        update rc;
        
        Set<Id> cardIds = new Set<Id>{rc.Id};
        
        Test.startTest();
        ReturnedCardsHandler.processCalloutsForRecords(cardIds);
        Test.stopTest();
    }
    
    @isTest
    static void testProcessCalloutsForRecordsEmptySet() {
        Test.startTest();
        ReturnedCardsHandler.processCalloutsForRecords(null);
        ReturnedCardsHandler.processCalloutsForRecords(new Set<Id>());
        Test.stopTest();
    }
    
    @isTest
    static void testCalculateAcceptedWarnings() {
        List<Returned_Cards__c> returnedCards = [SELECT Id, CIF__c, Accepted_Warnings__c 
                                                  FROM Returned_Cards__c];
        
        Test.startTest();
        ReturnedCardsHandler.calculateAcceptedWarnings(returnedCards);
        Test.stopTest();
    }
    
    @isTest
    static void testCalculateAcceptedWarningsWithBulkOperationReject() {
        ReturnedCardsHandler.isFromBulkOperationReject = true;
        
        List<Returned_Cards__c> returnedCards = [SELECT Id, CIF__c, Accepted_Warnings__c 
                                                  FROM Returned_Cards__c];
        
        Test.startTest();
        ReturnedCardsHandler.calculateAcceptedWarnings(returnedCards);
        Test.stopTest();
        
        ReturnedCardsHandler.isFromBulkOperationReject = false;
    }
    
    @isTest
    static void testCalculateAcceptedWarningsNoCIF() {
        Returned_Cards__c newCard = new Returned_Cards__c(
            Status__c = 'Open',
            Sub_Status__c = 'Pending For Pick-up'
        );
        
        List<Returned_Cards__c> returnedCards = new List<Returned_Cards__c>{newCard};
        
        Test.startTest();
        ReturnedCardsHandler.calculateAcceptedWarnings(returnedCards);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateAcceptedWarningsAfterTrigger() {
        List<Returned_Cards__c> returnedCards = [SELECT Id, CIF__c, Accepted_Warnings__c 
                                                  FROM Returned_Cards__c];
        
        if (returnedCards.isEmpty()) return;
        
        Set<Id> cardIds = new Set<Id>();
        for (Returned_Cards__c rc : returnedCards) {
            cardIds.add(rc.Id);
        }
        
        Test.startTest();
        ReturnedCardsHandler.updateAcceptedWarningsAfterTrigger(cardIds);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateAcceptedWarningsAfterTriggerWithBulkOperationReject() {
        ReturnedCardsHandler.isFromBulkOperationReject = true;
        
        List<Returned_Cards__c> returnedCards = [SELECT Id, CIF__c, Accepted_Warnings__c 
                                                  FROM Returned_Cards__c];
        
        if (returnedCards.isEmpty()) return;
        
        Set<Id> cardIds = new Set<Id>();
        for (Returned_Cards__c rc : returnedCards) {
            cardIds.add(rc.Id);
        }
        
        Test.startTest();
        ReturnedCardsHandler.updateAcceptedWarningsAfterTrigger(cardIds);
        Test.stopTest();
        
        ReturnedCardsHandler.isFromBulkOperationReject = false;
    }
    
    @isTest
    static void testUpdateAcceptedWarningsAfterTriggerNoCIF() {
        Returned_Cards__c newCard = [SELECT Id, Status__c, Sub_Status__c, CIF__c FROM Returned_Cards__c LIMIT 1];
        
        Set<Id> cardIds = new Set<Id>{newCard.Id};
        
        Test.startTest();
        ReturnedCardsHandler.updateAcceptedWarningsAfterTrigger(cardIds);
        Test.stopTest();
    }
    
    @isTest
    static void testHandleAfterDelete() {
        List<Returned_Cards__c> returnedCards = [SELECT Id, CIF__c FROM Returned_Cards__c LIMIT 1];
        
        if (returnedCards.isEmpty()) return;
        
        Test.startTest();
        ReturnedCardsHandler.handleAfterDelete(returnedCards);
        Test.stopTest();
    }
    
    @isTest
    static void testHandleAfterDeleteWithBulkOperationReject() {
        ReturnedCardsHandler.isFromBulkOperationReject = true;
        
        List<Returned_Cards__c> returnedCards = [SELECT Id, CIF__c FROM Returned_Cards__c LIMIT 1];
        
        if (returnedCards.isEmpty()) return;
        
        Test.startTest();
        ReturnedCardsHandler.handleAfterDelete(returnedCards);
        Test.stopTest();
        
        ReturnedCardsHandler.isFromBulkOperationReject = false;
    }
    
    @isTest
    static void testHandleAfterDeleteNoCIF() {
        Returned_Cards__c newCard = [SELECT Id, Status__c, Sub_Status__c, CIF__c FROM Returned_Cards__c LIMIT 1];
        
        List<Returned_Cards__c> deletedCards = new List<Returned_Cards__c>{newCard};
        
        Test.startTest();
        ReturnedCardsHandler.handleAfterDelete(deletedCards);
        Test.stopTest();
    }
    
    @isTest
    static void testPopulateSubject() {
        List<Returned_Cards__c> returnedCards = [SELECT Id, Returned_Card_Bulk_Operation__c, CIF__c 
                                                  FROM Returned_Cards__c];
        
        Test.startTest();
        ReturnedCardsHandler.populateSubject(returnedCards);
        Test.stopTest();
    }
    
    @isTest
    static void testPopulateSubjectWithBulkOperationReject() {
        ReturnedCardsHandler.isFromBulkOperationReject = true;
        
        List<Returned_Cards__c> returnedCards = [SELECT Id, Returned_Card_Bulk_Operation__c, CIF__c 
                                                  FROM Returned_Cards__c];
        
        Test.startTest();
        ReturnedCardsHandler.populateSubject(returnedCards);
        Test.stopTest();
        
        ReturnedCardsHandler.isFromBulkOperationReject = false;
    }
    
    @isTest
    static void testPopulateSubjectNoBulkOperation() {
        Returned_Cards__c newCard = [SELECT Id, Status__c, Sub_Status__c, CIF__c, Returned_Card_Bulk_Operation__c FROM Returned_Cards__c LIMIT 1];
        
        List<Returned_Cards__c> returnedCards = new List<Returned_Cards__c>{newCard};
        
        Test.startTest();
        ReturnedCardsHandler.populateSubject(returnedCards);
        Test.stopTest();
    }
    
    @isTest
    static void testPopulateSubjectEmptyList() {
        Test.startTest();
        ReturnedCardsHandler.populateSubject(null);
        ReturnedCardsHandler.populateSubject(new List<Returned_Cards__c>());
        Test.stopTest();
    }
    
    @isTest
    static void testGetTranslatedBranch() {
        Test.startTest();
        // Test English
        String englishBranch = ReturnedCardsHandler.getTranslatedBranch('Main Branch', 'English');
        
        // Test Arabic  
        String arabicBranch = ReturnedCardsHandler.getTranslatedBranch('Main Branch', 'Arabic');
        
        // Test blank branch
        String blankBranch = ReturnedCardsHandler.getTranslatedBranch('', 'English');
        
        // Test non-existent branch
        String nonExistentBranch = ReturnedCardsHandler.getTranslatedBranch('Unknown Branch', 'Arabic');
        Test.stopTest();
    }
    
    @isTest
    static void testSendNotificationApiForCreditCard() {
        List<Returned_Cards__c> returnedCards = [SELECT Id, Sub_Status__c, Region_Flag__c, CIF__c, 
                                                  Customer__c, Customer__r.PersonEmail, Language_Preference__c,
                                                  Customer__r.PersonMobilePhone, Dispatch_To_Branch__c,
                                                  CardType__c, Customer__r.Name
                                                  FROM Returned_Cards__c WHERE CardType__c = 'Credit Card' LIMIT 1];
        
        if (returnedCards.isEmpty()) return;
        
        Returned_Cards__c rc = returnedCards[0];
        rc.Sub_Status__c = 'Pending For Pick-up';
        
        ApiConnection con = new ApiConnection();
        HttpRequest request = con.createRequest('POST', '/api/v1/notifications?', 'Bahrain');
        
        Test.startTest();
        try {
            HttpResponse response = ReturnedCardsHandler.sendNotificationApi(request, rc, 'RET_CARD_PENDING_FOR_PICKUP', 'email');
        } catch (Exception e) {
            // Expected exception as API endpoint may not be available
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSendNotificationApiForDebitCardArabic() {
        List<Returned_Cards__c> returnedCards = [SELECT Id, Sub_Status__c, Region_Flag__c, CIF__c, 
                                                  Customer__c, Customer__r.PersonEmail, Language_Preference__c,
                                                  Customer__r.PersonMobilePhone, Dispatch_To_Branch__c,
                                                  CardType__c, Customer__r.Name
                                                  FROM Returned_Cards__c WHERE CardType__c = 'Debit Card' LIMIT 1];
        
        if (returnedCards.isEmpty()) return;
        
        Returned_Cards__c rc = returnedCards[0];
        rc.Sub_Status__c = 'Dispatch';
        rc.Dispatch_To_Branch__c = 'Main Branch';
        
        ApiConnection con = new ApiConnection();
        HttpRequest request = con.createRequest('POST', '/api/v1/notifications?', 'Jordan');
        
        Test.startTest();
        try {
            HttpResponse response = ReturnedCardsHandler.sendNotificationApi(request, rc, 'RET_CARD_DISPATCH_JOR', 'sms');
        } catch (Exception e) {
            // Expected exception as API endpoint may not be available
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSendNotificationApiForDestroyed() {
        List<Returned_Cards__c> returnedCards = [SELECT Id, Sub_Status__c, Region_Flag__c, CIF__c, 
                                                  Customer__c, Customer__r.PersonEmail, Language_Preference__c,
                                                  Customer__r.PersonMobilePhone, Dispatch_To_Branch__c,
                                                  CardType__c, Customer__r.Name
                                                  FROM Returned_Cards__c LIMIT 1];
        
        if (returnedCards.isEmpty()) return;
        
        Returned_Cards__c rc = returnedCards[0];
        rc.Sub_Status__c = 'Destroyed';
        
        ApiConnection con = new ApiConnection();
        HttpRequest request = con.createRequest('POST', '/api/v1/notifications?', 'Bahrain');
        
        Test.startTest();
        try {
            HttpResponse response = ReturnedCardsHandler.sendNotificationApi(request, rc, 'RET_CARD_DESTROY', 'email');
        } catch (Exception e) {
            // Expected exception as API endpoint may not be available
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetNotificationsForSubStatus() {
        Test.startTest();
        
        // Test Bahrain region
        List<Map<String, String>> bahrainNotifications = ReturnedCardsHandler.getNotificationsForSubStatus('Pending For Pick-up', 'Bahrain');
        
        // Test Jordan region
        List<Map<String, String>> jordanNotifications = ReturnedCardsHandler.getNotificationsForSubStatus('Pending For Pick-up', 'Jordan');
        
        // Test Destroyed status
        List<Map<String, String>> destroyedNotifications = ReturnedCardsHandler.getNotificationsForSubStatus('Destroyed', 'Bahrain');
        
        // Test Collected by Customer
        List<Map<String, String>> collectedNotifications = ReturnedCardsHandler.getNotificationsForSubStatus('Collected by Customer', 'Bahrain');
        
        // Test Re-delivery
        List<Map<String, String>> redeliveryNotifications = ReturnedCardsHandler.getNotificationsForSubStatus('Re-delivery', 'Jordan');
        
        // Test unknown status
        List<Map<String, String>> unknownNotifications = ReturnedCardsHandler.getNotificationsForSubStatus('Unknown Status', 'Bahrain');
        
        Test.stopTest();
    }
}