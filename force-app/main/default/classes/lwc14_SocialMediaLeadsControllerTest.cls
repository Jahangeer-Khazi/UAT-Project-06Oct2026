@IsTest
private class lwc14_SocialMediaLeadsControllerTest {

    @TestSetup
    static void setupTestData() {
        Account emailMatch = (Account) TestDataFactory.createSObject(
            new Account(
                CIF__pc = '001',
                PersonEmail = 'sml.email.match@test.com',
                PersonMobilePhone = '97310000001',
                Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED',
                Blacklisted__c = false,
                CustomerStatus__c = null
            ),
            'TestFactoryDefaults.AccountDefaults',
            true
        );
        TestDataFactory.createSObject(
            new Account(
                CIF__pc = '002',
                PersonEmail = 'sml.phone.only@test.com',
                PersonMobilePhone = '97310000002',
                Onboarding_Stage__pc = 'MOBILE_VERIFIED',
                Blacklisted__c = true,
                CustomerStatus__c = 'Closed'
            ),
            'TestFactoryDefaults.AccountDefaults',
            true
        );

        Id ccRtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        TestDataFactory.createSObject(
            new Case(
                RecordTypeId = ccRtId,
                AccountId = emailMatch.Id,
                ContactId = emailMatch.PersonContactId,
                Case_Model__c = 'ila',
                Type = 'Credit Card Application',
                Status = 'In Progress'
            ),
            'TestFactoryDefaults.CaseDefaults',
            true
        );
        TestDataFactory.createSObject(
            new Case(
                RecordTypeId = ccRtId,
                AccountId = emailMatch.Id,
                ContactId = emailMatch.PersonContactId,
                Case_Model__c = 'ila',
                Type = 'Credit Card Application',
                Status = 'Closed',
                Sub_Status__c = 'Declined'
            ),
            'TestFactoryDefaults.CaseDefaults',
            true
        );

        try {
            insert new Customer_Product__c(
                Customer__c = emailMatch.Id,
                CIF__c = 'SMLCIF001',
                Active_Secured_Credit_Card__c = true
            );
        } catch (Exception e) {
            // Product insert is optional; matching still covers Account flags
        }
    }

    private static String toBase64(String csv) {
        return EncodingUtil.base64Encode(Blob.valueOf(csv));
    }

    @IsTest
    static void testAnalyzeValidCsvAndMatching() {
        String csv =
            'Name,Email Address,Phone,Secondary Phone,Whatsapp Number,Source,Channel\n'
            + '"Doe, John",sml.email.match@test.com,97310000001,97320000001,97330000001,Facebook,Ads\n'
            + 'Phone Match,,97310000002,97320000002,,Instagram,Organic\n'
            + 'Unknown,unknown.sml@test.com,97319999999,,,,\n'
            + ',\n';

        Test.startTest();
        List<lwc14_SocialMediaLeadsController.SocialMediaLeadAnalysis> results =
            lwc14_SocialMediaLeadsController.analyzeSocialMediaLeads(toBase64(csv), 'leads.csv');
        Test.stopTest();

        System.assertEquals(3, results.size());

        lwc14_SocialMediaLeadsController.SocialMediaLeadAnalysis emailHit;
        lwc14_SocialMediaLeadsController.SocialMediaLeadAnalysis phoneHit;
        lwc14_SocialMediaLeadsController.SocialMediaLeadAnalysis unknownHit;
        for (lwc14_SocialMediaLeadsController.SocialMediaLeadAnalysis row : results) {
            if (row.email == 'sml.email.match@test.com') {
                emailHit = row;
            } else if (row.phone == '97310000002') {
                phoneHit = row;
            } else {
                unknownHit = row;
            }
        }

        System.assertEquals('Doe, John', emailHit.name);
        System.assertEquals(true, emailHit.isCustomer);
 
        System.assertNotEquals(null, emailHit.accountId);
        System.assertEquals(true, emailHit.hasPendingCreditCard);
        System.assertEquals(true, emailHit.hasDeclinedCreditCard);

        System.assertEquals(true, phoneHit.isBlacklisted);
        System.assertEquals(true, phoneHit.terminatedRelationship);
        System.assertEquals(false, phoneHit.isCustomer);

        System.assertEquals(false, unknownHit.isCustomer);
        System.assertEquals(null, unknownHit.accountId);
    }

    @IsTest
    static void testAnalyzeAlternateHeadersQuotedAndCrlf() {
        String csv =
            'name,email,secondary phone,whatsapp number\r\n'
            + '"He said ""Hi""",alt.header@test.com,97340000001,97350000001\r\n';

        Test.startTest();
        List<lwc14_SocialMediaLeadsController.SocialMediaLeadAnalysis> results =
            lwc14_SocialMediaLeadsController.analyzeSocialMediaLeads(toBase64(csv), 'alt.csv');
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals('He said "Hi"', results[0].name);
        System.assertEquals('alt.header@test.com', results[0].email);
        System.assertEquals('97340000001', results[0].phone);
        System.assertEquals('97340000001', results[0].secondaryPhone);
        System.assertEquals('97350000001', results[0].whatsappNumber);
    }

    @IsTest
    static void testAnalyzeValidationErrors() {
        Boolean emptyThrew = false;
        Boolean headerOnlyThrew = false;
        Boolean missingColsThrew = false;
        Boolean badEncodingThrew = false;

        Test.startTest();
        try {
            lwc14_SocialMediaLeadsController.analyzeSocialMediaLeads('', 'empty.csv');
        } catch (AuraHandledException e) {
            emptyThrew = true;
        }
        try {
            lwc14_SocialMediaLeadsController.analyzeSocialMediaLeads(toBase64('Name,Email,Phone\n'), 'header.csv');
        } catch (AuraHandledException e) {
            headerOnlyThrew = true;
        }
        try {
            lwc14_SocialMediaLeadsController.analyzeSocialMediaLeads(
                toBase64('Name,Source\nJohn,Facebook\n'),
                'missing.csv'
            );
        } catch (AuraHandledException e) {
            missingColsThrew = true;
        }
        try {
            lwc14_SocialMediaLeadsController.analyzeSocialMediaLeads('@@@', 'bad.csv');
        } catch (AuraHandledException e) {
            badEncodingThrew = true;
        }
        Test.stopTest();

        System.assertEquals(true, emptyThrew);
        System.assertEquals(true, headerOnlyThrew);
        System.assertEquals(true, missingColsThrew);
        System.assertEquals(true, badEncodingThrew);
    }
 
}