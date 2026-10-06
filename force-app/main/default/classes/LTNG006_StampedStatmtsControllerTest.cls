@isTest
public class LTNG006_StampedStatmtsControllerTest {
    static Account accObj;
    static{
        accObj = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
    }
    
    @isTest
    public static void loadAccountStatementsTest(){  
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            LTNG006_StampedStatementsController.loadAccountStatements(accObj.CIF__pc,'{accountId: "2660030003971549",statementType: "Statement"}');
        Test.stopTest();
    }

    @isTest
    public static void getAccountStatementDetailsTest(){  
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            LTNG006_StampedStatementsController.getAccountStatementDetails(accObj.CIF__pc,'{"accountId": "2660030003971549","statementDate": "2019-01-31","statementType": "Statement"}');
        Test.stopTest();
    }

    @isTest
    public static void stampedStatementVisibilityTest(){  
        Test.startTest();
            LTNG006_StampedStatementsController.stampedStatementVisibility(accObj.Id);
        Test.stopTest();
    }

}