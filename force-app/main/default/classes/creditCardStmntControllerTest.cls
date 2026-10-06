@isTest
public class creditCardStmntControllerTest {
    static Account accObj;
    static{
        accObj = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
    }
    
    @isTest
    public static void loadCreditCardStatementTest(){  
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            creditCardStmntController.loadCreditCardStatement(accObj.CIF__pc,null,null,'{pciNumber: "2660030003971549",statementType: "Statement"}');
        Test.stopTest();
    }

    @isTest
    public static void getCardStatementsTest(){  
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            creditCardStmntController.getCardStatements(accObj.CIF__pc,null,null,'{"pciNumber": "2660030003971549","statementDate": "2019-01-31","statementType": "Statement"}');
        Test.stopTest();
    }

}