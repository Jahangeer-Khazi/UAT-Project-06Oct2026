@isTest
public class DM002_CaseTest {

    @isTest
    public static void getListByIdsTest(){   
        
        Test.startTest();
            Account accObj = (Account)TestDataFactory.createSObject(new Account(), 'TestFactoryDefaults.AccountDefaults',true);
            Case caseObj = (Case)TestDataFactory.createSObject(new Case(ContactId = accObj.PersonContactId,AccountId = accObj.id), 'TestFactoryDefaults.CaseDefaults',true);
            List<Case> caseList = DM002_Case.getListByIds(new Set<Id>{caseObj.Id});
        Test.stopTest();
        
        System.assert(caseList.size()>0);
    }

}