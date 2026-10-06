/*    Organization:ABC Bank
 *    Created By:Jayanth Manickam
 *    Created Date: 09-02-2022
 *    Change History: 
 *            
*/
@isTest
public class APB08_UpdateMinorIdent_DetailsTest {

    @testSetup static void setupMethode() {
        Account acc1 = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',Subscription_Model__pc='ila',Archived__pc = false,Minor__pc=True,PersonBirthdate= Date.newInstance(2000, 06, 09)), 'TestFactoryDefaults.AccountDefaults',true);
    }

    @isTest public static void batchTest(){
        Test.startTest();
        APB08_UpdateMinorIdentificationDetails crn= new APB08_UpdateMinorIdentificationDetails();
        crn.execute(null);
           // Id jobId = Database.executeBatch(crn,200);
        Test.stopTest();
    }
}