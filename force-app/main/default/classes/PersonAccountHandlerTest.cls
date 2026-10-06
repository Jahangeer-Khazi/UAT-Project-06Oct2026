/**

 *
 *  Version History :
 *         #CH01 Added by OMAR AITOGRAM 20-06-2022 *** to add new field (case model) 
 *
 */
@isTest
private class PersonAccountHandlerTest {
	
    @isTest
    static void deletePersonAccountAndRelated () {
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acc = new Account(LastName='Test', FirstName='abc', RecordTypeId=devRecordTypeId);
        insert acc; 
        // CH01 Added by OMAR AITOGRAM 20-06-2022 *** to add new field (case model) -->
        Case case1 = new Case(Subject = 'Test', AccountId=acc.Id,Case_Model__c='ila');
        insert case1; 
         // CH01 END  -->
         
         
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://test.com');
        req.setBody('test-body');
        System_Action__c sys_action = SystemActionLoggerWithCase.initiateLogRequest(case1.Id, req, 'test-action');
        insert sys_action;
        
        //account delete failed, because first name incorrect
        PersonAccountHandler.deletePersonAccountAndRelated('abcd', 'Test');
        system.assertEquals(1, [select Id from account where Id= :acc.Id].size());
        
        //account delete and related success
        Id[] fixedSearchResults= new Id[1];
       	fixedSearchResults[0] = acc.Id;
       	Test.setFixedSearchResults(fixedSearchResults);
        PersonAccountHandler.deletePersonAccountAndRelated(acc.FirstName, acc.LastName); 
    }
}