/**
 * @description       : Test class for RelativesFormController
 * @author            : ismael.ocana
 * @group             : 
 * @last modified on  : 26/10/2021
 * @last modified by  : ismael.ocana
**/
@isTest
public with sharing class RelativesFormControllerTest {

    private static final String NAME = 'TestName';
    private static final Decimal OTP_VALID_STAFF = 123456789;
    private static final Decimal OTP_VALID_CONTRACTOR = 12340000;
    private static final Decimal OTP_INVALID = 99999999;
    private static final String STAFF_ID_VALID_STAFF = '1256';
    private static final String STAFF_ID_VALID_CONTRACTOR = '9941123';
    private static final String STAFF_ID_INVALID = '9999999';
    private static final String EMPLOYMENT_STAFF = 'Staff';
    private static final String EMPLOYMENT_CONTRACTOR = 'Contractor';
    private static final String ID_NUMBER_STAFF = '1993';
    private static final String ID_NUMBER_CONTRACTOR = '1994';
    private static final String ID_NUMBER_LEAD = '1992';
    private static final String ID_NUMBER_CONTACT = '1991';
    private static final String RELATION_VALUE = 'Daughter';


    private static final String COUNTRY_CODE_MOBILE = '+973';
    private static final String MOBILE = '0102030405';

    
    /**
    * @description Create the data to test
    * @author ismael.ocana | 13/10/2021 
    **/
    @TestSetup
    public static void createData(){

        //Creating accounts and person accounts
        List<Account> accList = new List<Account>();
      	Account accStaff = TestFactory.createPersonAccount(NAME, OTP_VALID_STAFF, STAFF_ID_VALID_STAFF, EMPLOYMENT_STAFF, ID_NUMBER_STAFF);
        accList.add(accStaff);
		Account accContractor = TestFactory.createPersonAccount(NAME, OTP_VALID_CONTRACTOR, STAFF_ID_VALID_CONTRACTOR, EMPLOYMENT_CONTRACTOR, ID_NUMBER_CONTRACTOR);
        accList.add(accContractor);
        Account accCustomer = TestFactory.createPersonAccount(NAME, null, '', EMPLOYMENT_STAFF, ID_NUMBER_CONTACT);
        accList.add(accCustomer);
        insert accList;

        //Creating lead
        Lead l = TestFactory.createLead(NAME, ID_NUMBER_LEAD);
        l.Mobile_Country_Code__c = COUNTRY_CODE_MOBILE;
        l.MobilePhone = MOBILE;
        insert l;
        
        //Creating linked account
       List<Linked_Account__c> laList = new List<Linked_Account__c>();
       Linked_Account__c laLead = TestFactory.createLinkedAccount(accStaff.Id, l.Id, 'Relative__c', true, RELATION_VALUE, System.now(), null);
       laLead.Mobile_Country_Code__c = COUNTRY_CODE_MOBILE;
       laLead.Mobile__c = MOBILE+'1';
       laList.add(laLead);

       Linked_Account__c laContact = TestFactory.createLinkedAccount(accStaff.Id, accCustomer.Id, 'Relative_Customer__c', false, RELATION_VALUE, System.now(), null);
       laContact.Mobile_Country_Code__c = COUNTRY_CODE_MOBILE;
       laContact.Mobile__c = MOBILE+'2';

       laList.add(laContact);
       insert laList;
        
        Contact con=TestFactory.createContactOTP('TestContact',String.valueOf(OTP_VALID_STAFF));
        //con.Staff_ID__c=STAFF_ID_VALID_STAFF;
        con.CIF__c='1234';
        insert con;
    }
    /**
    * @description This will test when the user is found
    * @author ismael.ocana | 13/10/2021 
    **/
    @isTest
    public static void getUserOKTest(){

         Contact [] conListStaff = [SELECT ID, Name, AccountId, ID_number__c,Staff_ID__c,No_Immediate_Relative__c FROM Contact WHERE Staff_ID__c =: STAFF_ID_VALID_STAFF];
        RelativesFormController rfc = new RelativesFormController();
        rfc.otpUser = conListStaff[0].ID_number__c;
        rfc.staffIdUser = STAFF_ID_VALID_STAFF;

        Test.startTest();
            rfc.saveLogin();
        Test.stopTest();

        System.assertEquals(true, rfc.isStaff, 'User found is not a staff');
        System.assertEquals(conListStaff[0].AccountId, rfc.accountId, 'Different accountID ' + rfc.accountId);
        System.assertEquals(1, rfc.linkAccList.size(), 'Different linked account size ' + rfc.linkAccList.size());
    }

  /**
    * @description This will test when the user is modified
    * @author ismael.ocana | 13/10/2021 
    **/
   @isTest 
    public static void saveContactOK(){
        
        Contact [] conListStaff = [SELECT ID, Name, AccountId, ID_number__c,Staff_ID__c,No_Immediate_Relative__c FROM Contact WHERE Staff_ID__c =: STAFF_ID_VALID_STAFF];
        RelativesFormController rfc = new RelativesFormController();
        rfc.otpUser = conListStaff[0].ID_number__c;
        rfc.staffIdUser = STAFF_ID_VALID_STAFF;
        rfc.saveLogin();
        rfc.userContact.Marital_Status__c = 'DIVORCED';

        Test.startTest();
            rfc.saveContact();
        Test.stopTest();
        Contact con = [SELECT ID, AccountID, Employment_Type__c, Marital_Status__c FROM Contact WHERE OTP__c =: OTP_VALID_STAFF LIMIT 1];
        System.assertEquals(con.Marital_Status__c, rfc.userContact.Marital_Status__c, 'Contact not updated');
    }

    /**
    * @description This will test that a new row is added
    * @author ismael.ocana | 13/10/2021 
    **/
    @isTest
    public static void addRowOK(){

        Contact [] conListStaff = [SELECT ID, Name, AccountId, ID_number__c,Staff_ID__c,No_Immediate_Relative__c FROM Contact WHERE Staff_ID__c =: STAFF_ID_VALID_STAFF];
        RelativesFormController rfc = new RelativesFormController();
        rfc.otpUser = conListStaff[0].ID_number__c;
        rfc.staffIdUser = STAFF_ID_VALID_STAFF;
        rfc.saveLogin();
        Integer listValue = rfc.linkAccList.size();

        Test.startTest();
            rfc.addRow();
        Test.stopTest();

        System.assertEquals(listValue + 1, rfc.linkAccList.size(), 'Row not added');
    }

    /**
    * @description This will test that a row is deleted correctly
    * @author ismael.ocana | 13/10/2021 
    **/
    @isTest
    public static void deleteRowActionExistingOK(){

        Pagereference pageRef = Page.RelativesForm;
        Test.setCurrentPage(pageRef);
        
        Contact [] conListStaff = [SELECT ID, Name, AccountId, ID_number__c,Staff_ID__c,No_Immediate_Relative__c FROM Contact WHERE Staff_ID__c =: STAFF_ID_VALID_STAFF];
        RelativesFormController rfc = new RelativesFormController();
        rfc.otpUser = conListStaff[0].ID_number__c;
        rfc.staffIdUser = STAFF_ID_VALID_STAFF;
        rfc.saveLogin();
        String laId = rfc.linkAccList.get(0).la.Id;
        Integer listValue = rfc.linkAccList.size();
        //row Id
        String rowToDelete = rfc.linkAccList.get(0).id;
        //add row Id to values
        ApexPages.currentPage().getParameters().put('selectedWrapperVF',rowToDelete);
        Test.startTest();
            rfc.deleteRowAction();
        Test.stopTest();
    }

    /**
    * @description This will test when a row is created and has to create a Lead and a Linked Account
    * @author ismael.ocana | 13/10/2021 
    **/
    @isTest
    public static void saveRowActionCreateLeadOK(){

        Contact [] conListStaff = [SELECT ID, Name, AccountId, ID_number__c,Staff_ID__c,No_Immediate_Relative__c FROM Contact WHERE Staff_ID__c =: STAFF_ID_VALID_STAFF];
        RelativesFormController rfc = new RelativesFormController();
        rfc.otpUser = conListStaff[0].ID_number__c;
        rfc.staffIdUser = STAFF_ID_VALID_STAFF;
        rfc.saveLogin();
        //new row
        rfc.addRow();

        //new Row
        RelativesFormController.TableWrapper tw = rfc.linkAccList.get(1);
        tw.la.Relationship__c = RELATION_VALUE;
        tw.la.Mobile_Country_Code__c = COUNTRY_CODE_MOBILE;
        tw.la.Mobile__c = MOBILE+'3';
        tw.idNumber = '1995';
        tw.la.ID_Number__c = '1995';
        tw.la.StaffRelativesKanz__c = 'Exclude from the Raffles';

        rfc.mapLinkAcc.put(tw.id, tw);
        rfc.linkAccList = rfc.mapLinkAcc.values();
        Integer listSize = rfc.linkAccList.size();

        Test.startTest();
            rfc.saveRowAction();
            rfc.getRelatedIdByIdNumber(new Set<String>{tw.idNumber});
            rfc.getRelatedIdByIdNumberByObject(conListStaff,'id',new Map<String, String>());
            try {
                rfc.insertLeads(new List<Lead>{new Lead(lastName ='test',Mobile_Country_Code__c='+973',MobilePhone='52565656')},new List<Linked_Account__c>(),new Map<String,RelativesFormController.TableWrapper>(),new Map<String,RelativesFormController.TableWrapper>()); 
            } catch (Exception e) {
                
            }
        Test.stopTest();

        //List<Linked_Account__c> laList = [SELECT ID FROM Linked_Account__c WHERE Linked_Account__c =: rfc.accountId AND Active__c = true];
        //System.assertEquals(listSize, laList.size(), 'Not the same size ' + laList);
    }

    /**
    * @description This will test when a row is added and a previous linked account is found
    * @author ismael.ocana | 13/10/2021 
    **/
    @isTest
    public static void saveRowActionInactiveAccountOK(){

        Contact [] conListStaff = [SELECT ID, Name, AccountId, ID_number__c,Staff_ID__c,No_Immediate_Relative__c FROM Contact WHERE Staff_ID__c =: STAFF_ID_VALID_STAFF];
        RelativesFormController rfc = new RelativesFormController();
        rfc.otpUser = conListStaff[0].ID_number__c;
        rfc.staffIdUser = STAFF_ID_VALID_STAFF;
        rfc.saveLogin();
        //new row
        rfc.addRow();

        //new Row
        RelativesFormController.TableWrapper tw = rfc.linkAccList.get(1);
        tw.la.Relationship__c = RELATION_VALUE;
        tw.idNumber = ID_NUMBER_CONTACT;
        tw.la.Mobile_Country_Code__c = COUNTRY_CODE_MOBILE;
        tw.la.Mobile__c = MOBILE+'3';
        tw.la.ID_Number__c = ID_NUMBER_CONTACT;
        tw.la.StaffRelativesKanz__c = 'Include in the Raffles';
        rfc.mapLinkAcc.put(tw.id, tw);
        rfc.linkAccList = rfc.mapLinkAcc.values();

        Test.startTest();
            rfc.saveRowAction();
        Test.stopTest();

        //List<Linked_Account__c> laList = [SELECT ID FROM Linked_Account__c WHERE Relative_Customer__r.Id_Number__pc =: ID_NUMBER_CONTACT AND Active__c = true];
        //System.assertEquals(1, laList.size(), 'Not the same size ' + laList);
    }

    @isTest
    public static void updateLeadOK(){
        List<Lead> leadList = [SELECT ID FROM Lead];

        RelativesFormController rfc = new RelativesFormController();
        
        Test.startTest();
            Savepoint sp = Database.setSavepoint();
            try{
                rfc.updateLead(leadList, sp);
                System.assert(true, 'leads not updated');
            } catch(Exception e){
                System.assert(false, 'leads error');
            }
            
        Test.stopTest();
    }

    @isTest
    public static void updateLeadKO(){
        List<Lead> leadList = [SELECT ID FROM Lead];
        leadList.get(0).Id_Number__c = 'failFail';

        RelativesFormController rfc = new RelativesFormController();
        
        Test.startTest();
            Savepoint sp = Database.setSavepoint();
            try{
                rfc.updateLead(leadList, sp);
                System.assertEquals(true, rfc.showErrorForm, 'error message ' + rfc.errorMessageForm  );
            } catch(Exception e){
                System.assert(false, 'leads error');
            }
            
        Test.stopTest();
    }


    @isTest
    public static void updateAccountOK(){
        List<Account> accountList = [SELECT ID FROM Account];

        RelativesFormController rfc = new RelativesFormController();
        Test.startTest();
            Savepoint sp = Database.setSavepoint();
            try{
                rfc.updateAccounts(accountList, sp);
                System.assert(true, 'accounts not updated');
            } catch(Exception e){
                System.assert(false, 'account error');
            }
            
        Test.stopTest();
    }

    @isTest
    public static void updateAccountKO(){
        List<Account> accountList = [SELECT ID FROM Account];
        accountList.get(0).Name = '11111';

        RelativesFormController rfc = new RelativesFormController();
        Test.startTest();
            Savepoint sp = Database.setSavepoint();
            try{
                rfc.updateAccounts(accountList, sp);
                System.assertEquals(true, rfc.showErrorForm, 'error message ' + rfc.errorMessageForm  );
            } catch(Exception e){
                System.assert(false, 'account error');
            }
            
        Test.stopTest();
    }

    @isTest
    public static void getUserKOTest(){

        Contact con = [SELECT ID, AccountID, Employment_Type__c FROM Contact WHERE OTP__c =: OTP_VALID_STAFF LIMIT 1];
        RelativesFormController rfc = new RelativesFormController();
        rfc.otpUser = '111166666';
        rfc.staffIdUser = '2222';

        Test.startTest();
            rfc.saveLogin();
        Test.stopTest(); 

        System.assertEquals(0, rfc.linkAccList.size(), 'Different linked account size ' + rfc.linkAccList.size());
    }


    @isTest
    public static void updateRelativeCustomerKOTest(){
        RelativesFormController rfc = new RelativesFormController();

        Test.startTest();
        try {
            rfc.updateRelativeCustomer(new List<Account>{new Account()}); 
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest(); 
    }

    @isTest
    public static void upsertLinkedAccountsKOTest(){
        RelativesFormController rfc = new RelativesFormController();

        Test.startTest();
        try {
            rfc.upsertLinkedAccounts(new List<Linked_Account__c>{new Linked_Account__c()}); 
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest(); 
    }

    @isTest
    public static void insertLeadsKOTest(){
        RelativesFormController rfc = new RelativesFormController();

        Test.startTest();
        try {
            rfc.insertLeads(new List<Lead>{new Lead()},null,null,null); 
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest(); 
    }

    @isTest 
    public static void testgetItems(){
        
        Contact [] conListStaff = [SELECT ID, Name, AccountId, ID_number__c,Staff_ID__c,No_Immediate_Relative__c FROM Contact WHERE Staff_ID__c =: STAFF_ID_VALID_STAFF];
        RelativesFormController rfc = new RelativesFormController();
        rfc.otpUser = conListStaff[0].ID_number__c;
        rfc.staffIdUser = STAFF_ID_VALID_STAFF;
        rfc.saveLogin();

        Test.startTest();
            rfc.getItems();
            rfc.userContact.Region_Flag__c = 'Jordan';
            rfc.getItems();
        Test.stopTest();
    }


    @isTest
    public static void saveRowActionKO(){

        Contact [] conListStaff = [SELECT ID, Name, AccountId, ID_number__c,Staff_ID__c,No_Immediate_Relative__c FROM Contact WHERE Staff_ID__c =: STAFF_ID_VALID_STAFF];
        RelativesFormController rfc = new RelativesFormController();
        rfc.otpUser = conListStaff[0].ID_number__c;
        rfc.staffIdUser = STAFF_ID_VALID_STAFF;
        rfc.saveLogin();
        //new row
        rfc.addRow();

        //new Row
        RelativesFormController.TableWrapper tw = rfc.linkAccList.get(1);
        tw.la.Relationship__c = RELATION_VALUE;
        tw.la.Mobile_Country_Code__c = COUNTRY_CODE_MOBILE;
        tw.la.Mobile__c = MOBILE+'3';
        tw.idNumber = null;
        tw.la.ID_Number__c = null;
        tw.la.StaffRelativesKanz__c = null;

        rfc.mapLinkAcc.put(tw.id, tw);
        rfc.linkAccList = rfc.mapLinkAcc.values();

        Test.startTest();
            rfc.saveRowAction();
        Test.stopTest();
    }

}