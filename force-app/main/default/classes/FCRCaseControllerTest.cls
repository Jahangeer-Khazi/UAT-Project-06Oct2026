/**
 * @description       : 
 * @author            : Elmustapha ELGARNI
 * @group             : 
 * @last modified on  : 03-04-2024
 * @last modified by  : Elmustapha ELGARNI
**/
@isTest
public with sharing class FCRCaseControllerTest {
    
    
    @isTest
    static void testGetFCRRecordType() {
        
        Id fcrRecordTypeId = FCRCaseController.getFCRRecordType();
    }
}