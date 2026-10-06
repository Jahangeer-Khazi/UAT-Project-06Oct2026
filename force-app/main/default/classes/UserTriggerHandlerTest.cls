/*     Organization  : ABC Bank
 *     Created By    : Jahangeer Mohammed
 *     Created Date  : 01/07/2022
 *     Description   : This test class is covering the following classes and Trigeer
            1) UserTrigger 2) UserTriggerHandler
 *     Change History: 
 *         
 */
@isTest
public class UserTriggerHandlerTest {
    static testMethod void unitTest1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole ur = new UserRole(Name = 'CEO');
        insert ur;
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = ur.id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1990@testorg.com');
        //insert u;
        System.debug('User Created:'+u);
        //System.debug('User Id:'+u.Id);
        System.runAs(u){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            List<Account> accList = new List<Account>();
            Test.startTest();
            Account acc1 = new Account();
            acc1.FirstName = 'Unit';
            acc1.LastName = 'Testing';
            acc1.Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED';
            acc1.Email_Update__pc = 'test1@abc.com';
            insert acc1;
            System.debug('Inserted Account in test class:'+acc1);
            System.debug('Inserted Account created by in test class:'+acc1.CreatedBy);
            
            acc1.Email_Update__pc = 'abc@test.com';
            
            update acc1;
            //Test.stopTest();
            System.debug('Updated Account in test class:'+acc1);
            System.debug('Updated Account in Last Modified by in test class:'+acc1.LastModifiedBy);
            accList.add(acc1);
            System.debug('Account List:'+accList);
            UserTriggerHandler.SendEmailToInfosec(accList);
            Test.stopTest();
        }  
    }
    static testMethod void unitTest2(){
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole ur1 = new UserRole(Name = 'CEO');
        insert ur1;
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p1.Id, UserRoleId = ur1.id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1990@testorg.com');
        insert u1;
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='Restricted System Admin'];
        UserRole ur2 = new UserRole(Name = 'L2');
        insert ur2;
        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p2.Id, UserRoleId = ur2.id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1991@testorg.com');
        insert u2;
        System.runAs(u1){
            u2.ProfileId = p1.id;
            update u2;
        }
    }
}