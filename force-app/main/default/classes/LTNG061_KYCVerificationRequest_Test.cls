@IsTest
private class LTNG061_KYCVerificationRequest_Test {
    
    @testSetup
    static void setupData() {
        // Create an Account for KYC linking
        Account pa = new Account();
        pa.RecordTypeId = getPersonAccountRtId();
        pa.LastName = 'Test Person';
        pa.PersonEmail = 'customer@example.com';
       // pa.Subscription_Model__pc='ila';
        // Custom Person Account fields accessed via __pc in queries:
        // Set them on Account by using the Contact-side person fields where applicable
        pa.put('CIF__pc', 'CIF123');                // custom person contact field
        pa.put('Region_Flag__pc','Bahrain');            // example region
        pa.put('Subscription_Model__pc', 'ila');
        pa.put('x_canary__pc', 'test-canary');
        pa.put('Mobile_Phone_Check__pc', '+97336000000');
        insert pa;
    }
   // Test data factory
    private static Id getPersonAccountRtId() {
        // Assumes Person Accounts are enabled
        return [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true LIMIT 1].Id;
    }
    @IsTest
    static void test_getKycRecordType() {
        // Act
        Test.startTest();
        Id rtIdFromMethod = LTNG061_KYCVerificationRequest.getKycRecordType();
        Test.stopTest();

        // Arrange expected via Schema (same source of truth as the method)
        Id expectedRtId = Schema.SObjectType.KYC_Verification__c
            .getRecordTypeInfosByDeveloperName()
            .get('KYC_Verification')
            .getRecordTypeId();

        // Assert
        System.assertNotEquals(null, rtIdFromMethod, 'Record Type Id should not be null');
        System.assertEquals(expectedRtId, rtIdFromMethod, 'Should return KYC_Verification record type Id');
    }

    @IsTest
    static void test_getTypeBasedRecordType_periodicReview() {
        // Act
        Test.startTest();
        Id rtId = LTNG061_KYCVerificationRequest.getTypeBasedRecordType('KYC_PERIODIC_REVIEW');
        Test.stopTest();

        Id expectedRtId = Schema.SObjectType.KYC_Verification__c
            .getRecordTypeInfosByDeveloperName()
            .get('KYC_Verification')
            .getRecordTypeId();

        // Assert
        System.assertEquals(expectedRtId, rtId, 'Periodic review should map to KYC_Verification record type');
    }

    @IsTest
    static void test_getTypeBasedRecordType_otherType() {
        // Act
        Test.startTest();
        Id rtId = LTNG061_KYCVerificationRequest.getTypeBasedRecordType('ANY_OTHER_TYPE');
        Test.stopTest();

        Id expectedRtId = Schema.SObjectType.KYC_Verification__c
            .getRecordTypeInfosByDeveloperName()
            .get('Suspected_Identity_Fraud')
            .getRecordTypeId();

        // Assert
        System.assertEquals(expectedRtId, rtId, 'Non-periodic type should map to Suspected_Identity_Fraud record type');
    }

    @IsTest
    static void test_validateCaseCreationRequest_true_whenNoOpenKyc() {
        // Arrange
        Account acc = [SELECT Id FROM Account LIMIT 1];

        // Act
        Test.startTest();
        Boolean canCreate = LTNG061_KYCVerificationRequest.validateCaseCreationRequest(acc.Id);
        Test.stopTest();

        // Assert: no open KYC exists, should allow creation
        System.assertEquals(true, canCreate, 'Should allow case creation when there is no open KYC for the account');
    }

    @IsTest
    static void test_validateCaseCreationRequest_false_whenOpenKycExists() {
        // Arrange
        Account acc = [SELECT Id FROM Account LIMIT 1];

        // Create an open KYC_Verification__c for the same account
        Id kycRtId = Schema.SObjectType.KYC_Verification__c
            .getRecordTypeInfosByDeveloperName()
            .get('KYC_Verification')
            .getRecordTypeId();

        KYC_Verification__c kyc = new KYC_Verification__c();
        // Populate likely required fields; adjust if your org enforces additional required fields.
       // kyc.Name = 'Test KYC';
        kyc.Account_Name__c = acc.Id;
        kyc.Status__c = 'Open';
        kyc.RecordTypeId = kycRtId;
        kyc.case_Model__c='ila';
        insert kyc;

        // Act
        Test.startTest();
        Boolean canCreate = LTNG061_KYCVerificationRequest.validateCaseCreationRequest(acc.Id);
        Test.stopTest();

        // Assert: open KYC exists, should NOT allow creation
        System.assertEquals(false, canCreate, 'Should not allow case creation when an open KYC exists for the account');
    }
}