/**
 * @description       : This class will be a factory for test classes
 * @author            : ismael.ocana@s4g.es
 * @group             :
 * @last modified on  : 07/07/2022
 * @last modified by  : navin
 * @description		  : Correct references to Draw creation to leave Name as Autonumber and add a reference to Draw_Name__c
 * @history
 * @last modified on  : 22/10/2021
 * @last modified by  : ismael.ocana
**/
@isTest
public with sharing class TestFactory {

    public static Account createPersonAccount(String name, Decimal otp, String staffId, String employmentType, String idNumber){
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acc = new Account(
            LastName = name,
            CIF__pc =idNumber,
            RecordTypeId = devRecordTypeId,
            OTP__pc = otp,
            Staff_Id__pc = staffId,
            Id_Number__pc = idNumber,
            Employment_Type__pc = employmentType);
        return acc;
    }
    public static Contact createContact(String name){
        return new Contact(lastName = name);
    }
    public static Contact createContactOTP(String name, String idNumber){
        Contact con = createContact(name);
        con.CIF__c = idNumber;
        con.Id_Number__c = idNumber;
        return con;
    }
    public static Linked_Account__c createLinkedAccount(Id accountId){
        return new Linked_Account__c(Linked_Account__c = accountId);
    }
    public static Linked_Account__c createLinkedAccount(Id accountId, Id relationId, String field, Boolean activeStatus, String relationship, DateTime startDate, DateTime endDate){
        Linked_Account__c la = createLinkedAccount(accountId);
        la.put(field, relationId);
        la.Relationship__c = relationship;
        la.Active__c = activeStatus;
        la.Relationship_Date_Added__c = startDate;
        la.Relationship_Date_Removed__c = endDate;
        return la;
    }

    public static Lead createLead(String name, String idNumber){
        return new Lead(
            lastName = name,
            Id_Number__c = idNumber,
            Region_Flag__c = 'Bahrain',
            Proof_of_Address_ID_Number__c = '1000034'
        );
    }

    public static Draw__c createDraw(){
        return new Draw__c(
            Draw_Name__c = 'Test',
            Draw_Type__c = 'Kanz',
            Number_of_tiers__c = 3,
            Grand_Prize__c = 100000,
            //Draw_Date__c = System.today(),
            //Draw_From__c = System.today(),
            //Draw_to__c = System.today(),
            MOIC_Representative_Name__c = 'Tom Jones',
            Internal_Auditor_Name__c = 'Alanah Miles',
            External_Auditor_Name__c = 'PriceWaterHouse Coopers',
            Justification__c = 'Test'
        );
    }
    public static Prize__c createPrize(String drawId, String order){
        return new Prize__c(
            Draw__c = drawId,
            Winning_Amount__c = 1400,
            order__c = order,
            Number_of_Winners__c = 1
        );
    }

    public static Draw_Entry__c createDrawEntry(String drawId, String name, String customerId){
        return new Draw_Entry__c(
            //name = name,
            Draw__c = drawId,
            Customer__c = customerId,
            No_of_Chances__c = 6,
            Balance__c = 10000,
            Justification__c = 'Test'
        );
    }

    public static Winner__c createWinner(String prizeId, String drawEntryId, String customerId){
        return new Winner__c(
            Prize__c = prizeId,
            Draw_Entry__c = drawEntryId,
            Customer__c = customerId
        );
    }
}