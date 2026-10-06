@IsTest
private class lwc16_SocialMediaLeadsViewerCtrlTest {

    @TestSetup
    static void setupTestData() {
        Account acc = (Account) TestDataFactory.createSObject(
            new Account(CIF__pc = '001', PersonEmail = 'sml.viewer@test.com'),
            'TestFactoryDefaults.AccountDefaults',
            true
        );

        insert new List<Social_Media_Leads__c>{
            new Social_Media_Leads__c(
                Name = 'Viewer Lead One',
                Email__c = 'viewer.one@test.com',
                Mobile__c = '97360000001',
                Secondary_Phone_Number__c = '97360000002',
                Whatsapp_number__c = '97360000003',
                CIF__c = acc.CIF__pc
            ),
            new Social_Media_Leads__c(
                Name = 'Viewer Lead Two',
                Email__c = 'viewer.two@test.com',
                Mobile__c = '97360000004',
                CIF__c = 'NOMATCHCIF'
            )
        };
    }

    @IsTest
    static void testGetSocialMediaLeadsFiltersAndPaging() {
        Test.startTest();
        lwc16_SocialMediaLeadsViewerController.LeadPagedResult allRows =
            lwc16_SocialMediaLeadsViewerController.getSocialMediaLeads(10, 1, 'All', null, false);
        lwc16_SocialMediaLeadsViewerController.LeadPagedResult searched =
            lwc16_SocialMediaLeadsViewerController.getSocialMediaLeads(10, 1, 'All', 'viewer.one', false);
        lwc16_SocialMediaLeadsViewerController.LeadPagedResult unassigned =
            lwc16_SocialMediaLeadsViewerController.getSocialMediaLeads(10, 1, 'All', null, true);
        lwc16_SocialMediaLeadsViewerController.LeadPagedResult pageTwo =
            lwc16_SocialMediaLeadsViewerController.getSocialMediaLeads(1, 2, null, null, false);
        lwc16_SocialMediaLeadsViewerController.LeadPagedResult ownerFiltered =
            lwc16_SocialMediaLeadsViewerController.getSocialMediaLeads(10, 1, UserInfo.getName(), null, false);
        Test.stopTest();

        System.assert(allRows.totalItemCount >= 2);
        System.assertEquals(allRows.totalItemCount >= 2, allRows.leads.size() >= 2);
 
        System.assertEquals(false, allRows.accountIdMap.containsKey('NOMATCHCIF'));

        System.assertEquals(1, searched.totalItemCount);
        System.assertEquals('Viewer Lead One', searched.leads[0].Name);

        System.assertEquals(allRows.totalItemCount, unassigned.totalItemCount);
        System.assertEquals(1, pageTwo.leads.size());
        System.assert(ownerFiltered.totalItemCount >= 0);
    }

    @IsTest
    static void testAssignLeadsSuccessAndValidation() {
        List<Social_Media_Leads__c> leads = [
            SELECT Id, Sales_Agent__c, OwnerId
            FROM Social_Media_Leads__c
            WHERE Email__c = 'viewer.one@test.com'
        ];
        Id agentId = UserInfo.getUserId();

        Boolean invalidThrew = false;
        Boolean blankAgentThrew = false;

        Test.startTest();
        lwc16_SocialMediaLeadsViewerController.assignLeads(leads, agentId);
        try {
            lwc16_SocialMediaLeadsViewerController.assignLeads(new List<Social_Media_Leads__c>(), agentId);
        } catch (AuraHandledException e) {
            invalidThrew = true;
        }
        try {
            lwc16_SocialMediaLeadsViewerController.assignLeads(leads, '');
        } catch (AuraHandledException e) {
            blankAgentThrew = true;
        }
        Test.stopTest();

        Social_Media_Leads__c updated = [
            SELECT Sales_Agent__c, OwnerId
            FROM Social_Media_Leads__c
            WHERE Id = :leads[0].Id
        ];
        System.assertEquals(agentId, updated.Sales_Agent__c);
        System.assertEquals(agentId, updated.OwnerId);
        System.assertEquals(true, invalidThrew);
        System.assertEquals(true, blankAgentThrew);

        lwc16_SocialMediaLeadsViewerController.LeadPagedResult remainingUnassigned =
            lwc16_SocialMediaLeadsViewerController.getSocialMediaLeads(10, 1, 'All', null, true);
        System.assertEquals(1, remainingUnassigned.totalItemCount);
    }
}