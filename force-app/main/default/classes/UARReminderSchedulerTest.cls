/********************************************************************************************
* @name					UARReminderSchedulerTest
* @description			UARReminderScheduler code coverage would be done through this test class
* @date					13/03/2025
* @cretaedby			Maksud
*********************************************************************************************
* version				Author				Date			Comments
* 1.0					Maksud	 		 13/03/2025		Initial Version
*********************************************************************************************
*/

@isTest
public class UARReminderSchedulerTest {

    @testSetup
    static void setupTestData(){
    	Set<String> setOfUserNames = new Set<String>();
        
        //Fetching available user name from metadata config to create those user test records.
        for(UAR_Reminder_Config__mdt config :[SELECT Days_Elapsed__c, User_Name__c, 
                                                       Email_Template__c, Case_Model__c 
                                                       FROM UAR_Reminder_Config__mdt 
                                                       WHERE Days_Elapsed__c != NULL]){
        	if(String.isNotEmpty(config.User_Name__c)){
            	setOfUserNames.add(config.User_Name__c);
        	}
        }
        
        if(!setOfUserNames.isEmpty()){
            createUsers(setOfUserNames);
        }
        
        createAccountAndContact();
        createUARRecord();
    }
    
    @isTest
    static void sendReminderEmailsTest(){
        UARReminderScheduler scheduler = new UARReminderScheduler();
        scheduler.execute(null);
    }
    
    static void createUsers(Set<String> userNames){
        List<User> listOfUsers = new List<User>();
        Id profileId = [SELECT Id FROM Profile WHERE name LIKE '%ila CEO%' ORDER BY CreatedDate ASC LIMIT 1].Id;
            
        for(String name :userNames){
            String username = name.deleteWhitespace() + 'randomuser@test.com';
            List<String> firstLastNames = name.split(' ');
            String lastName = '';
            String firstName = '';
            if(firstLastNames.size() == 2){
                firstName = firstLastNames[0];
                lastName = firstLastNames[1];
            }
            else{
                lastName = firstLastNames[0];
            }
            
            listOfUsers.add(new User(
            	UserName = userName,
                LastName = lastName,
                FirstName = firstName,
                Alias = lastName,
                Email = username,
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profileId
            ));
        }
        
        if(!listOfUsers.isEmpty()){
            insert listOfUsers;
        }
        
    }
    
    static void createUARRecord(){
       	Id accountId = [Select Id FROM Account WHERE PersonEmail = 'test2_uar@ilatest.com'].Id;
        UAR__c uar = new UAR__c(
            Account__c = accountId,
            Subject__c = 'UAR Test Sch',
            Type__c = 'Card',
            Sub_Type__c = 'Card Transactions',
            Transaction_Amount__c = 123040,
            Transaction_Date__c = Date.Today(),
            Case_Model__c = 'ila');
        insert uar;
        
        Datetime last22days = Datetime.now().addDays(-7);
		Test.setCreatedDate(uar.Id, last22days);
    }
    
    static void createAccountAndContact(){
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2_uar@ilatest.com';
        insert acc;
    }
}