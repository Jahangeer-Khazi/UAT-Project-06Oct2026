/**
 *  Version History :
 *         #CH01 Added by OMAR AITOGRAM 20-06-2022 *** to add new field (case model) 
 *
 */
@isTest
public class PremiumHandlerTest {
    static testMethod void PremiumTriggerHandlerTest(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Premium Retention').getRecordTypeId();
        Id invitationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Premium Invitation').getRecordTypeId();
        
        User thisUser = [Select id from User where id =: UserInfo.getUserId() limit 1];
        system.runAs(thisUser){
            Triggers__c tt = new Triggers__c();
            tt.Is_Active__c = true;
            tt.Name = 'Premium_Retention_Request__c';
            insert tt;


            Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2@ilatest.com';
            acc.Nationality__pc = 'BH';
            acc.CIF__pc = '5464546';
            acc.Segment__pc='Regular';
            insert acc;
            
            
            Account acc1 = new Account();
            acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc1.FirstName = 'Test3';
            acc1.LastName = 'Class3';
            acc1.PersonEmail = 'test3@ilatest.com';
            acc1.Nationality__pc = 'BA';
            acc1.CIF__pc = '5464547';
            acc1.Segment__pc='Staff';
            insert acc1;
            
            Account acc2 = new Account();
            acc2.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc2.FirstName = 'Test4';
            acc2.LastName = 'Class4';
            acc2.PersonEmail = 'test4@ilatest.com';
            acc2.Nationality__pc = 'BH';
            acc2.CIF__pc = '5464548';
            acc2.Segment__pc='Premium';
            insert acc2;
            
            test.startTest();
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Subject = 'Premium Retention';
            cs1.Description = 'New Premium Retention Application';
            //cs1.Type = 'Credit Card Application';
            cs1.Type = 'Premium Retention Application';
            // CH01 Added by OMAR AITOGRAM  20-06-2022 *** to add new field (case model) -->
            cs1.Case_Model__c='ila';
             // CH01 END -->
            
            cs1.Priority = 'High';
            cs1.Awaiting_Customer_Feedback__c = true;
            cs1.Origin = 'App';
            cs1.Case_nature__c = 'RC';
            cs1.AccountId = acc.Id;
            cs1.ac_RequestedBy__c = 'Customer';
            cs1.cc_Name_on_the_Card__c = 'Test';
            cs1.Total_Fees__c = 10;
            insert cs1;
            
            Case cs2 = new Case();
            cs2.RecordTypeId = invitationRecordTypeId;
            cs2.Subject = 'Premium Invitation';
            cs2.Description = 'New Premium Invitation Application';
            //cs1.Type = 'Credit Card Application';
            cs2.Type = 'Premium Invitation Application';
            // CH01 Added by OMAR AITOGRAM  20-06-2022 *** to add new field (case model) -->
            cs2.Case_Model__c='ila';
             // CH01 END -->
            
            cs2.Priority = 'High';
            cs2.Awaiting_Customer_Feedback__c = true;
            cs2.Origin = 'App';
            cs2.Case_nature__c = 'RC';
            cs2.AccountId = acc.Id;
            cs2.ac_RequestedBy__c = 'Bank / CBB';
            cs2.Discount_Amount__c = 10.00;
            cs2.Expiry_Days__c = 5;
            insert cs2;

            
            List<Premium_Retention_Request__c> premiumRetentionList=new List<Premium_Retention_Request__c>();
            
            Premium_Retention_Request__c premiumRetention=new Premium_Retention_Request__c();
            premiumRetention.CIF__c=acc.CIF__pc;
            premiumRetention.Expiry_Days__c=2;
            premiumRetention.Discount_Amount__c=20;
            premiumRetention.Type__c='Retention';
            premiumRetentionList.add(premiumRetention);
            
            Premium_Retention_Request__c premiumRetention1=new Premium_Retention_Request__c();
            premiumRetention1.CIF__c=acc1.CIF__pc;
            premiumRetention1.Expiry_Days__c=3;
            premiumRetention1.Discount_Amount__c=30;
            premiumRetention1.Type__c='Retention';
            premiumRetentionList.add(premiumRetention1);
            
            Premium_Retention_Request__c premiumInvitation=new Premium_Retention_Request__c();
            premiumInvitation.CIF__c=acc.CIF__pc;
            premiumInvitation.Expiry_Days__c=4;
            premiumInvitation.Discount_Amount__c=40;
            premiumInvitation.Type__c='Invitation';
            premiumRetentionList.add(premiumInvitation);
            
            Premium_Retention_Request__c premiumInvitation4=new Premium_Retention_Request__c();
            premiumInvitation4.CIF__c=acc.CIF__pc;
            premiumInvitation4.Expiry_Days__c=4;
            premiumInvitation4.Discount_Amount__c=40;
            premiumInvitation4.Type__c='Invitation';
            premiumRetentionList.add(premiumInvitation4);
            
            Premium_Retention_Request__c premiumInvitation1=new Premium_Retention_Request__c();
            premiumInvitation1.CIF__c=acc2.CIF__pc;
            premiumInvitation1.Expiry_Days__c=5;
            premiumInvitation1.Discount_Amount__c=50;
            premiumInvitation1.Type__c='Invitation';
            premiumRetentionList.add(premiumInvitation1);
            
             Premium_Retention_Request__c premiumRetention2=new Premium_Retention_Request__c();
            premiumRetention2.CIF__c=acc.CIF__pc;
            premiumRetention2.Expiry_Days__c=2;
            premiumRetention2.Discount_Amount__c=20;
            premiumRetention2.Type__c='Retention Rollback';
            premiumRetentionList.add(premiumRetention2);
            
            Premium_Retention_Request__c premiumInvitation3=new Premium_Retention_Request__c();
            premiumInvitation3.CIF__c=acc.CIF__pc;
            premiumInvitation3.Expiry_Days__c=5;
            premiumInvitation3.Discount_Amount__c=50;
            premiumInvitation3.Type__c='Invitation Rollback';
            premiumRetentionList.add(premiumInvitation3);
            
            
           
            
            
            /*Premium_Retention_Request__c premiumRetention1=new Premium_Retention_Request__c();
            premiumRetention1.CIF__c=acc.CIF__pc;
            premiumRetention1.Expiry_Days__c=2;
            premiumRetention1.Discount_Amount__c=20;
            premiumRetention1.Type__c='Retention Rollback';
            premiumRetentionList.add(premiumRetention);*/
            
            Database.insert(premiumRetentionList);
            test.stopTest();
        }
    }
}