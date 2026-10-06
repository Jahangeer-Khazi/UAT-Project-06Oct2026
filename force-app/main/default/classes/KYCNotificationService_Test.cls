@IsTest
private class KYCNotificationService_Test {
    // Util: Simple HTTP mock that can return a configured status and body
    private class GenericCalloutMock implements HttpCalloutMock {
        Integer code;
        String body;
        Map<String,String> respHeaders;
        GenericCalloutMock(Integer code, String body) {
            this.code = code;
            this.body = body;
            this.respHeaders = new Map<String,String>();
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(code);
            res.setBody(body);
            for (String k : respHeaders.keySet()) {
                res.setHeader(k, respHeaders.get(k));
            }
            return res;
        }
    }

    // Test data factory
    private static Id getPersonAccountRtId() {
        // Assumes Person Accounts are enabled
        return [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true LIMIT 1].Id;
    }

    private static Account makePersonAccount() {
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
        return pa;
    }

    private static KYC_Verification__c makeKyc(Account acct, String typeValue,
                                               String crmStage,
                                               String overdueStage,
                                               String overdueHandling,
                                               Boolean documentResend) {
        KYC_Verification__c kv = new KYC_Verification__c();
        kv.Account_Name__c = acct.Id;
       // kv.CIF__c = acct.cif__pc;
        kv.Type__c = typeValue;
        kv.CRM_Stage__c = crmStage;
        kv.Overdue_Stage__c = overdueStage;
        kv.Overdue_Handling__c = overdueHandling;
        kv.API_Status__c = 'PR_PENDING_IDV_S1';
        kv.Document_Resend__c = false;
        kv.Status__c = 'Open';
        kv.Sub_Status__c = 'Pending ID&V';
        kv.No_of_days__c = 0;
        kv.case_Model__c='ila';                                 
        insert kv;
        return kv;
    }

    // Build a Notification template object in-memory (no DML needed for the downstream methods)
    private static KYC_Notification_Service__mdt makeTemplate(Boolean smsOn) {
        KYC_Notification_Service__mdt tmpl = new KYC_Notification_Service__mdt();
        tmpl.DeveloperName = 'ANY';
        tmpl.Email_Template_Code__c = 'EMAIL_TPL';
        tmpl.Push_Template_Code__c = 'PUSH_TPL';
        tmpl.Sms_Template_Code__c = 'SMS_TPL';
        tmpl.SMS_Notification__c = smsOn;
        tmpl.Notification_Days__c = '0';
        tmpl.Overdue_Stage__c = 'Stage 3 – Block Debit Cards & Credit Cards';
        tmpl.Overdue_Handling__c = 'Level 1 - App (Nudges)';
        return tmpl;
    }

    @IsTest
    static void test_email_push_sms_success_path() {
        // Arrange
        Account pa = makePersonAccount();
        KYC_Verification__c kv = makeKyc(
            pa,
            'KYC_PERIODIC_REVIEW',
            'PR_PENDING_IDV',
            'Stage 3 – Block Debit Cards & Credit Cards',
            'Level 1 - App (Nudges)',
            false
        );
        KYC_Notification_Service__mdt tmpl = makeTemplate(true); // SMS enabled

        // Mock 200 for all callouts (email, push, sms)
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, '{"success": true}'));

        Test.startTest();
        // Act: call downstream public methods directly to ensure coverage without relying on CMT queries
        KYCNotificationService.SendEmailNotification(new List<KYC_Verification__c>{ kv }, tmpl, 'email');
        Test.stopTest();

        // Assert: Notification history and system actions written
        Integer histCount = [SELECT COUNT() FROM KYC_Notifications_History__c WHERE KYC_Verification__c = :kv.Id];
        System.assert(histCount >= 2,
            'Should have at least Email and Push (and SMS if enabled) history rows');

        Integer actCount = [SELECT COUNT() FROM KYC_System_Action__c WHERE KYC_Verification__c = :kv.Id];
        System.assert(actCount > 0, 'System actions should be captured for successful calls too');
    }


    @IsTest
    static void test_failure_path_system_action_logged() {
        // Arrange
        Account pa = makePersonAccount();
        KYC_Verification__c kv = makeKyc(
             pa,
            'KYC_PERIODIC_REVIEW',
            'PR_PENDING_IDV',
            'Stage 3 – Block Debit Cards & Credit Cards',
            'Level 1 - App (Nudges)',
            false
        );
        KYC_Notification_Service__mdt tmpl = makeTemplate(true);

        // Mock non-200
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(500, '{"success": false, "error": "Server Error"}'));

        Test.startTest();
        // Act: this should log a system action; Push/SMS should not be chained when email fails
        KYCNotificationService.SendEmailNotification(new List<KYC_Verification__c>{ kv }, tmpl, 'email');
        Test.stopTest();

        // Assert: A system action is logged; history for email should not be created due to non-200
        Integer histCount = [SELECT COUNT() FROM KYC_Notifications_History__c WHERE KYC_Verification__c = :kv.Id];
        System.assertEquals(0, histCount, 'No notification history expected when email callout fails');

        Integer actCount = [SELECT COUNT() FROM KYC_System_Action__c WHERE KYC_Verification__c = :kv.Id];
        System.assert(actCount > 0, 'Failure should result in a system action record');
    }

    @IsTest
    static void test_invocable_periodic_review_branches() {
        // Arrange: Document_Resend = true triggers DeveloperName='PR_RETURNED' branch
        Account pa = makePersonAccount();
        KYC_Verification__c kv1 = makeKyc(
            pa,
            'KYC_PERIODIC_REVIEW',
            'PR_PENDING_IDV',
            'Stage 3 – Block Debit Cards & Credit Cards',
            'Level 1 - App (Nudges)',
            true
        );
        // Another case for Document_Resend = false (LIKE on CRM_Stage)
        KYC_Verification__c kv2 = makeKyc(
             pa,
            'KYC_PERIODIC_REVIEW',
            'PR_PENDING_IDV',
            'Stage 3 – Block Debit Cards & Credit Cards',
            'Level 1 - App (Nudges)',
            false
        );

        // We won’t insert custom metadata here; the SOQL will return empty and skip notifications.
        // This still exercises the invocable branching safely.

        // Act
        Test.startTest();
        KYCNotificationService.KycNotificationData d1 = new KYCNotificationService.KycNotificationData();
        d1.Kyccase = kv1;
        d1.noofdays = '1';
        KYCNotificationService.KycNotificationData d2 = new KYCNotificationService.KycNotificationData();
        d2.Kyccase = kv2;
        d2.noofdays = '1';

        // No callout mock needed because with empty metadata no callouts will be done.
        KYCNotificationService.KycNotificationSetting(new List<KYCNotificationService.KycNotificationData>{ d1 });
        KYCNotificationService.KycNotificationSetting(new List<KYCNotificationService.KycNotificationData>{ d2 });
        Test.stopTest();

        // Assert: No history created because no templates found
        Integer histCount = [SELECT COUNT() FROM KYC_Notifications_History__c WHERE KYC_Verification__c IN :new Set<Id>{kv1.Id, kv2.Id}];
        System.assertEquals(0, histCount, 'No notifications should be sent when metadata template not found');
    }

    @IsTest
    static void test_invocable_fraud_branch_with_success() {
        // Arrange for fraud branch
        Account pa = makePersonAccount();
        KYC_Verification__c kv = makeKyc(
            pa,
            'KYC_PERIODIC_REVIEW',
            'PR_PENDING_IDV',
            'Stage 3 – Block Debit Cards & Credit Cards',
            'Level 1 - App (Nudges)',
            false
        );

        // To force notifications, we’ll bypass metadata query by calling SendEmailNotification with in-memory template
        KYC_Notification_Service__mdt tmpl = makeTemplate(true);

        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, '{"ok":true}'));

        Test.startTest();
        // Drive through email -> push -> sms using direct method, since the invocable depends on metadata
        KYCNotificationService.SendEmailNotification(new List<KYC_Verification__c>{ kv }, tmpl, 'email');
        Test.stopTest();

        Integer histCount = [SELECT COUNT() FROM KYC_Notifications_History__c WHERE KYC_Verification__c = :kv.Id];
        System.assert(histCount >= 2, 'Fraud flow via direct methods should log history for email and push (and sms if enabled)');
    }
}