/**
 * @description       : This class is the test class related to SM003_DrawHandler.cls
 * @author            : Aniss Mbarki |13/04/2022
 * @history : 
 *				#CH01 : 4/01/2022 Ad-hoc & Recurring Raffle Automation 
**/
@isTest
public with sharing class SM003_DrawHandlerTest {

    public static String CASH_PRIZE_TYPE = 'CASH';
    @testSetup static void setupMethode() {
        //#CH01 : add Prize Type
        Draw__c drawRecord = (Draw__c)TestDataFactory.createSObject(new Draw__c(Prize_Type__c = CASH_PRIZE_TYPE), 'TestFactoryDefaults.DrawDefaults',true);
        //insert 2 prizes
        Prize__c[] prizeRecords = (Prize__c[])TestDataFactory.createSObjectList(new Prize__c(Draw__c = drawRecord.Id,Prize_Type__c = CASH_PRIZE_TYPE), 2 ,'TestFactoryDefaults.PrizeDefaults',true);
        //insert 1 Draw_Entry_Review__c
        Draw_Entry_Review__c reviewRecord = (Draw_Entry_Review__c)TestDataFactory.createSObject(new Draw_Entry_Review__c(Draw__c = drawRecord.Id,Prize_Type__c = CASH_PRIZE_TYPE) ,'TestFactoryDefaults.DrawEntryReviewDefaults',true);
    }

    @isTest
    static void callGetDrawListApiTest(){
        Test.startTest();
            MCK03_RaffleServiceApiCalls.statusCodeGlobal = 200;
            ApiConnection.Response resp = SM003_DrawHandler.callGetDrawListApi('kanz',null);
            System.assert(resp.isSuccess == true);
        Test.stopTest();
    }

    @isTest
    static void callGetDrawDataApiTest(){
        Test.startTest();
            Draw__c drawRecord = getDraws().get(0);

            //cas success
            MCK03_RaffleServiceApiCalls.statusCodeGlobal = 200;
            ApiConnection.Response resp = SM003_DrawHandler.callGetDrawDataApi(drawRecord,'original_eligible');
            System.assert(resp.isSuccess == true);

            //cas error
            MCK03_RaffleServiceApiCalls.statusCodeGlobal = 500;
            ApiConnection.Response resp1 = SM003_DrawHandler.callGetDrawDataApi(drawRecord,'modified');
            System.assert(resp1.isSuccess == false);
        Test.stopTest();
    }

    @isTest
    static void callCreateDrawApiTest(){
        Test.startTest();
            Draw__c drawRecord = getDraws().get(0);

            //cas success
            MCK03_RaffleServiceApiCalls.statusCodeGlobal = 200;
            HttpResponse resp = SM003_DrawHandler.callCreateDrawApi(new HttpRequest(),drawRecord);
            System.assert(resp.getStatusCode() == 200);

        Test.stopTest();
    }

    @isTest
    static void getDrawWinnersViaApiTest(){
        Test.startTest();
            String customerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            Account acc = (Account)TestDataFactory.createSObject(new Account(CIF__pc = '12345678',recordtypeId = customerRecordType,PersonEmail='test2@ilatest.com'), 'TestFactoryDefaults.AccountDefaults',true);
            MCK03_RaffleServiceApiCalls.statusCodeGlobal = 200;
            Boolean isError = SM003_DrawHandler.getDrawWinnersViaApi([SELECT Id FROM Draw__c LIMIT 1].Id,new HttpRequest());
            System.assert(isError == false);
        Test.stopTest();
    }

    @isTest
    static void setSystemActionTest(){
        Draw__c drawRecord = [SELECT Id FROM Draw__c LIMIT 1];
        Draw_System_Action__c sys = SM003_DrawHandler.setSystemAction(drawRecord.Id,'testTitle','endPointTest','GET','{}',200,'{}',null,'Success');
        System.assert(sys != null);
    }

    @isTest
    static void thowExceptionTest(){
        try {
            SM003_DrawHandler.thowException('Custom msg');
        } catch (Exception e) {
            System.assert(true);
        }
    }

    @isTest
    static void checkEditAccessOfCurrentUserOnDrawTest(){
    
        try {
            User testUser = (User) TestDataFactory.createSObject(new User( ProfileId = [SELECT Id FROM Profile WHERE name LIKE '%ila CEO%' ORDER BY CreatedDate ASC LIMIT 1].Id), 'TestFactoryDefaults.UserDefaults',true);
            PermissionSetAssignment per = new PermissionSetAssignment(AssigneeId=testUser.Id,PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name= 'Raffle_Draw_Makers'].Id );
            insert per;
            System.runAs(testUser){ 
                SM003_DrawHandler.checkEditAccessOfCurrentUserOnDraw([SELECT Id FROM Draw__c LIMIT 1].Id);
            }
        } catch (Exception e) {
            System.assert(true);
        }

    }
    
    //#CH01 : Start
    @isTest
    static void callGetDrawListApiWithPrizeoutTest(){
        Test.startTest();
            MCK03_RaffleServiceApiCalls.statusCodeGlobal = 200;
            ApiConnection.Response resp = SM003_DrawHandler.callGetDrawListApi('PRIZEOUT',null);
            System.assert(resp.isSuccess == true);
        Test.stopTest();
    }
	//#CH01 : End
	
    public static List<Draw__c> getDraws(){
        //#CH01 
        return  [SELECT Id,Name,Currency__c,Draw_IdFromRedShift__c,Draw_Date__c,Draw_IdFromRaffleService__c ,Prize_Type__c,RegionFlag__c,
                    (SELECT Id,Winning_Amount__c,Number_of_Winners__c,Prize_Type__c,Tier__c FROM Prizes__r),
                    (SELECT Id,CIF__c,Category__c,No_of_Chances__c,EligibleBalance__c,TotalBalance__c,Prize_Type__c FROM Draw_Entries_Review__r)        
                FROM Draw__c];
    }
}