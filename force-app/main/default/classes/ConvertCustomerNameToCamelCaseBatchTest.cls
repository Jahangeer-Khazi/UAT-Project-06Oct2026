/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date:28-03-2023
* 		Change History: 
* 	 							  
*/
@isTest
public class ConvertCustomerNameToCamelCaseBatchTest {
@isTest
    static void unitTest1(){
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'JOHN';
        acc.MiddleName = 'T';
        acc.LastName = 'CENA';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Segment__pc = 'Regular';
        acc.Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED';
        acc.On_boarding_type__pc = 'Manual';
        insert acc;
        acc.mkt_Customer_Name_Camel_Case__pc = '';
        update acc;
        System.debug('Customer First Name:'+acc.FirstName);
        System.debug('Ila Customer Name in test class:'+acc.Ila_Customer_Name__c);
		System.debug('Customer Name in test class:'+acc.mkt_Customer_Name_Camel_Case__pc);
        Test.startTest();
        ConvertCustomerNameToCamelCaseBatch convertCustToCamelCase = new ConvertCustomerNameToCamelCaseBatch();
        Id jobid= Database.executeBatch(convertCustToCamelCase,5);
        Test.stopTest();
    }
}