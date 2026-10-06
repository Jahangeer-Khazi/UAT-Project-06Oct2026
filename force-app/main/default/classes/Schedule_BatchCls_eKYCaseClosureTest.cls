@isTest(seeAllData=False)
public class Schedule_BatchCls_eKYCaseClosureTest
{
    public static testMethod void eKYCaseClosureTEST() 
    {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) 
        {
            batchCls_eKYCCasesClosure objBtch = new batchCls_eKYCCasesClosure();
           
            Test.startTest(); 
            batchCls_eKYCCasesClosure sh1 = new batchCls_eKYCCasesClosure();
            system.schedule('Test Schedule Class','0 45 * * * ?',new Schedule_BatchCls_eKYCaseClosure());
            Test.stopTest(); 
        }
    }
}