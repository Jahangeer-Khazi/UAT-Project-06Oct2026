@isTest(seeAllData=False)
public class SCH_updateAttachmentDetailsTest
{
    public static testMethod void updateAttachmentDetailsTest() 
    {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) 
        {
            SCH_BatchCls_updateAttachmentDetails objBtch = new SCH_BatchCls_updateAttachmentDetails();
           
            Test.startTest(); 
            SCH_BatchCls_updateAttachmentDetails sh1 = new SCH_BatchCls_updateAttachmentDetails();
            system.schedule('Test Schedule Class','0 45 * * * ?',new SCH_BatchCls_updateAttachmentDetails());
            Test.stopTest(); 
        }
    }
}