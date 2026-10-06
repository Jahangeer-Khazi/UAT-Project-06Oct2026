/**
 * @description       : 
 * @author            : Navin Muneesamy
 * @group             : 
 * @last modified on  : 12/01/2022
 * @last modified by  : Navin Muneesamy
**/
@isTest
public with sharing class ShuffleDrawTest {   

    private static final Integer ENTRIES_NUM = 5;
    private static final Integer PRIZES_NUM = 3;
    private static final Decimal CIF_NUM = 12345679;
    private static final String TEST_NAME = 'Test ';
    private static final Decimal OTP = 1111111;
    private static final String STAFF_ID = '1111111';
    private static final String EMPLOYMENT_TYPE = 'Staff';

    @TestSetup
    static void createData(){

        //creating customers
        List<Account> accList = new List<Account>();
        for(Integer i = 0; i < ENTRIES_NUM; i++){
            accList.add(TestFactory.createPersonAccount(TEST_NAME + 1, OTP, STAFF_ID, EMPLOYMENT_TYPE, String.valueOf(CIF_NUM + i)));
        }
        insert accList;

        //creating draw
        Draw__c draw = TestFactory.createDraw();
        insert draw;
        
        //create draw entries
        List<Draw_Entry__c> deList = new List<Draw_Entry__c>();
        for(Integer i = 0; i < ENTRIES_NUM; i++){
            deList.add(TestFactory.createDrawEntry((String) draw.Id, 'Test ' + 1, (String)accList.get(i).Id));
        }
        insert deList;
    }
    
    @isTest
    static void testInit(){

        Draw__c draw = [SELECT ID FROM Draw__c LIMIT 1];
        List<Id> drawList = new List<Id>();
		drawList.add(draw.Id);        
        
        List<Draw_Entry__c> drawEntriesList = [Select Id From Draw_Entry__c Where Draw__c = :draw.Id];
        
        Test.startTest();
        ShuffleDraw.shuffleDrawEntries(drawList);
        Test.stopTest();
        
        List<Draw_Entry__c> drawEntriesafterList = [Select Id From Draw_Entry__c Where Draw__c = :draw.Id];

        System.assertNotEquals(drawEntriesafterList.size(), drawEntriesList.size(), 'The Draw Entries are equal and therefore fail the assertion as there are chances more than 1.');
    }
    
}