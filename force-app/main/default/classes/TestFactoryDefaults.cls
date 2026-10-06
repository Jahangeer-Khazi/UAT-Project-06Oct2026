/**
 * @File Name: TestFactoryDefaults.cls
 * @Description: Default methode can be used in unit tests to create test data.
 * @Author: D&A Team
 * @Group: Apex Class
 * @History : 
 *      #CH01 : add default value for case model field HC
 * ---------------------------------------------------------------------------------------- *
 * Ver       Date     
 * 1.0     2021-12-21
 **/

@IsTest
public class TestFactoryDefaults {
    
    /******************************* RULES TO RESPECT ***********************************/
    // To specify defaults for objects, use the naming convention [ObjectName]Defaults.
    // For custom objects, omit the __c from the Object Name

    /******************************** Standard Objects **********************************/

    public class AccountDefaults implements TestDataFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object>{
                Account.FirstName => 'TestIla',
                Account.LastName => 'TestIla',
                Account.PersonEmail => 'testclass@ilatest123.com'
             };
        }
    }

    public class ContactDefaults implements TestDataFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object>{
                Contact.FirstName => 'First',
                Contact.LastName => 'Last'
            };
        }
    }

    public class OpportunityDefaults implements TestDataFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object>{
                Opportunity.Name => 'Test Opportunity',
                Opportunity.StageName => 'Closed Won',
                Opportunity.CloseDate => System.today()
            };
        }
    }

    public class CaseDefaults implements TestDataFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object>{
                Case.Subject => 'Test Case',
                Case.Description => 'desc test',
                Case.Status => 'New',
                Case.Priority => 'High',
                Case.cc_Name_on_the_Card__c => 'test',
                Case.Origin => 'CRM',
                Case.Case_Model__c => 'ila' //#CH01
            };
        }
    }

    public class UserDefaults implements TestDataFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object>{
                User.Username => randomizeString('TestUserNotif') +'@test.com',
                User.LastName => 'D&A',
                User.FirstName => 'Team',
                User.Email => 'team.da-tech@gmail.com',
                User.Alias => 'dateam',
                User.LanguageLocaleKey => 'en_US',
                User.TimeZoneSidKey => 'America/Los_Angeles',
                User.LocaleSidKey => 'en_US',
                User.EmailEncodingKey => 'UTF-8'
            };
        }
    }

    public class DrawDefaults implements TestDataFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object>{
                Draw__c.Status__c => 'New',
                Draw__c.Draw_Name__c => 'test Draw',
                Draw__c.Draw_Type__c => 'kanz',
                Draw__c.Draw_IdFromRedShift__c => '1',
                Draw__c.Draw_Date__c => System.now(),
                Draw__c.Currency__c => 'BHD',
                Draw__c.Grand_Prize__c => 1000,
                Draw__c.Total_Prize_Fund__c => 2000,
                Draw__c.Draw_Denomination__c => 50,
                Draw__c.RegionFlag__c => 'Bahrain'
            };
        }
    }

    public class PrizeDefaults implements TestDataFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object>{
                Prize__c.Winning_Amount__c => 1000,
                Prize__c.Tier__c => 'First prize',
                Prize__c.Number_of_Winners__c => 1,
                Prize__c.Order__c => '1'
            };
        }
    }

    public class DrawEntryReviewDefaults implements TestDataFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object>{
                Draw_Entry_Review__c.Category__c => 'INC',//EXC
                Draw_Entry_Review__c.CIF__c => '12345678',
                Draw_Entry_Review__c.Justification__c => 'test justif',
                Draw_Entry_Review__c.No_of_Chances__c => 5
            };
        }
    }

    public class WinnerDefaults implements TestDataFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object>{
                Winner__c.nbrOfChancesOnDraw__c => 123
            };
        }
    }
    

    //************* Useful Methods *********************************************************/
    //the method returns a unique random string
    public static String randomizeString(String name){
        String charsForRandom = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < 6) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), charsForRandom.length());
           randStr += charsForRandom.substring(idx, idx+1);
        }
        return name+randStr;
    }

    public static Id getProfileAdminId(){
        return ([SELECT Id FROM Profile 
                 WHERE name LIKE '%admin%' 
                 ORDER BY CreatedDate ASC LIMIT 1].Id);
    }

    public static id getProfileByName(String profileName){
        return ([Select Id From Profile
                Where name = :profileName].Id);
    }
}