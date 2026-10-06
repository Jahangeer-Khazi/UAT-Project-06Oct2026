/**
 *  @author: Jayanth Manickam
 *  @date: 2024-09-24  
 *  @description:
 *      Test Class for "LTNG054_BondSukukStatementsController"
 *      
 *      
 */
@istest
public class LTNG054_BondSukukStatementsCntrlTest {
    static Account accObj;
    static{
        accObj = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
    }
    @isTest
    public static void loadBondSukukStatementsTest(){  
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            LTNG054_BondSukukStatementsController.loadBondSukukStatements(accObj.CIF__pc,'Bahrain');
        Test.stopTest();
    }

    @isTest
    public static void getBondSukukStatementDetailsTest(){  
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            LTNG054_BondSukukStatementsController.getBondSukukStatementDetails(accObj.CIF__pc,'Bahrain','{"accountId": "2660030003971549","statementDate": "2019-01-31","statementType": "Statement"}');
        Test.stopTest();
    }

    @isTest
    public static void BondSukukStatementVisibilityTest(){  
        Test.startTest();
            LTNG054_BondSukukStatementsController.BondSukukStatementVisibility(accObj.Id);
        Test.stopTest();
    }
}