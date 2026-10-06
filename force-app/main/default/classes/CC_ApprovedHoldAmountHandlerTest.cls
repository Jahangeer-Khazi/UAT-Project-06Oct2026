@isTest
private class CC_ApprovedHoldAmountHandlerTest {
    
    @isTest
    static void testHandlerBeforeCaseUpdate() {
        // Create test data
        Case newCase = new Case(
            ccol_Approved_Hold_Amount__c = 1234.567
        );
        insert newCase;
        
        // Create old case data with same ID
        Case oldCase = new Case(
            Id = newCase.Id,
            ccol_Approved_Hold_Amount__c = 1000.123
        );
        
        // Update case to trigger handler
        newCase.ccol_Approved_Hold_Amount__c = 5678.901;
        
        // Simulate trigger context with proper oldMap
        Test.startTest();
        Map<Id, Case> oldMap = new Map<Id, Case>{newCase.Id => oldCase.clone(true)};
        // Set Trigger context
        //CC_ApprovedHoldAmountHandler.handlerBeforeCaseUpdate(new List<Case>{newCase});
        Test.stopTest();
    }
    
    @isTest
    static void testConvertDecimalToBahrainWords() {
        Test.startTest();
        // Test various decimal inputs
        CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(0);
        CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(15.25);
        CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(100.5);
        CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(1000.123);
        CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(123456.789);
        CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(1000000);
        CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(1000000000);
        CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(null);
        Test.stopTest();
    }
    
    @isTest
    static void testNumberToWords() {
        Test.startTest();
        // Test various number ranges
        CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(0);
        CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(15);
        CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(99);
        CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(999);
        CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(9999);
        CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(99999);
        CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(999999);
        CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(9999999);
        CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(99999999);
        CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords(999999999);
        Test.stopTest();
    }
}