/*     Organization : ABC Bank
*      Created By:
*      Created Date:12/12/2022
*      Description:Test class for BatchSalesEmailNotification
*/

@isTest
public class BatchSalesEmailNotificationTest {
    
    
    @isTest
    Static void scoreCardDetails(){
        User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name ='System Administrator'].Id,
     LastName = 'last',
     Email = 'puser000@amamama.com',
     Username = 'puser000@amamama.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US'
);
        Score_Card_Metrics__c scm = New Score_Card_Metrics__c();
        scm.Target_No_of_Calls__c=200;
        scm.Avg_No_of_Calls_Per_Agent__c=40;
        scm.Target_Approval_Limit__c=2000;
        scm.Targeted_No_of_Cards__c=4;
        scm.Target_Strike_Rate__c=32;
        insert scm;
        Date d = Date.today();
        Integer y = d.year();
        Integer m = d.month();
        Integer da = d.day();
        DateTime dt = DateTime.newInstance(y,m,da);
        String mnth=dt.format('MMMM');
        Integer yr = System.Today().Year();
        String mntyrString = mnth+' '+yr;
        Score_Card__c sc= New Score_Card__c();
        //sc.Month_Year__c=mntyrString;
        sc.Month_Year_text__c=mntyrString;
        sc.Sales_Agent__c=u.id;
        sc.Score_Card_Metrics__c=scm.Id;
        sc.Scored__c=4;
        sc.Supplementary_Card_Count__c=2;
        //  sc.Supplementary_Inc__c=3;
        sc.Total_Approved_Credit_Limit_Number__c=12000.00;
        sc.Total_Approved_Credit_Limit__c='12000';
        sc.Today_s_Call_Count__c=10;
        sc.Total_Calls_uptoDate__c=50;
        sc.Applied_against_Al_Kanz_Approved__c=5;
        sc.Applied_against_salary_Approved__c=6;
        sc.Today_s_No_answer__c=3;
        sc.Month_s_No_answer__c=8;
        sc.Today_s_Interested_Follow_up__c=3;
        sc.Month_s_Interested_Follow_up__c=9;
        sc.Today_s_Not_interested__c=4;
        sc.Month_s_Not_interested__c=9;
        sc.Today_s_Applied_against_salary_Approved__c=500;
        sc.Today_s_Applied_against_Al_Kanz_Approve__c=800;
        sc.Today_s_Approved_limit__c=1400;
        sc.Today_s_Supplementary__c=4;
        // sc.Logging_Date__c=System.today();
        // sc.Incentive_Amount__c=340;
        sc.Calculated_Incentive_Amount__c=300;
        sc.Today_s_Folow_up__c =4;
        sc.Month_s_Follow_up__c=10;
        insert sc;
        
        Test.startTest();
           BatchSalesEmailNotification BSE = New BatchSalesEmailNotification();
           database.executeBatch(BSE);
        Test.stopTest();
    }
}