/**
 * * Version History :
 *      #ch01  Added by Amina BENABDELKRIM 05-08-2022 *** to add new field (case model)
 *
 */
@isTest
public class SM001_ApiCallsTest {

    private static ApiConnection con = new ApiConnection();

    @testSetup static void setupMethode() {
        Account acc1 = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);

        Case objCase = new Case(
            sc_Card_Holder_ID_Number__c = '123',
            ContactId = acc1.PersonContactId,
            sc_Card_Holder_First_Name__c = 'test firstName',
            sc_Card_Holder_Last_Name__c = 'test lastName',
            AccountId = acc1.id,
            Case_Model__c='ila'//CH01
        );
        TestDataFactory.createSObject( objCase, 'TestFactoryDefaults.CaseDefaults',true);
    }

    @isTest
    static void getComplianceCaseStatusApiTest(){
        test.startTest();
        Case caseObj = getCreateCase();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        HttpRequest request1 = con.createRequest('GET','/api/v1/compliances',null);
        HttpResponse response = SM001_ApiCalls.getComplianceCaseStatusApi(request1,caseObj);
        System.assert(response.getStatusCode() == 200);
        test.stopTest();
    }

    @isTest
    static void callNameScreeningApiTest(){
        test.startTest();
        Case caseObj = getCreateCase();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        HttpRequest request1 = con.createRequest('POST','/api/v1/compliances/direct',null);
        HttpResponse response = SM001_ApiCalls.callNameScreeningApi(request1,caseObj);
        System.assert(response.getStatusCode() == 200);
        test.stopTest();
    }

    @isTest
    static void callApiToCreateSupplementaryCardInVPlusTest(){
        test.startTest();
        Case caseObj = getCreateCase();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        HttpRequest request1 = con.createRequest('PUT','/api/v1/credit-cards/request',null);
        HttpResponse response = SM001_ApiCalls.callApiToCreateSupplementaryCardInVPlus(request1,caseObj);
        System.assert(response.getStatusCode() == 200);
        test.stopTest();
    }

    @isTest
    static void callBlockAmountApiTest(){
        test.startTest();
        Case caseObj = getCreateCase();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        HttpRequest request1 = con.createRequest('POST','/api/v1/customer-products/amount-block',null);
        HttpResponse response = SM001_ApiCalls.callBlockAmountApi(request1,caseObj);
        System.assert(response.getStatusCode() == 200);
        test.stopTest();
    }

    @isTest
    static void callUnblockAmountApiTest(){
        test.startTest();
        Case caseObj = getCreateCase();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        HttpRequest request1 = con.createRequest('DELETE','/api/v1/customer-products/amount-block/1',null);
        HttpResponse response = SM001_ApiCalls.callUnblockAmountApi(request1,caseObj);
        System.assert(response.getStatusCode() == 200);
        test.stopTest();
    }

    @isTest
    static void setSystemActionTest(){
        Case caseObj = getCreateCase();
        System.assert( SM001_ApiCalls.setSystemAction('test','test','test','test',caseObj.Id,caseObj.AccountId,caseObj.AccountId,200,'test','test') != null );
    }

    @isTest
    static void decimalApiFormatTest(){
        System.assert( SM001_ApiCalls.decimalApiFormat(100) != null );
        System.assert( SM001_ApiCalls.decimalApiFormat(null) == 'null' );
    }

    @isTest 
    static void dateToApiDateFormatTest(){
        System.assert( SM001_ApiCalls.dateToApiDateFormat(System.today()) != null );
        System.assert( SM001_ApiCalls.dateToApiDateFormat(null) == null );
    }

    @isTest
    static void stringApiFormatTest(){
        System.assert( SM001_ApiCalls.stringApiFormat('test') != 'null' );
        System.assert( SM001_ApiCalls.stringApiFormat(null) == 'null' );
    }

    private static Case getCreateCase(){
        return [SELECT Id,ac_Iban__c,Customer_CIF__c,Status,Sub_Status__c,PrimaryCardProductConfigurationId__c,PrimaryCard__c,cc_Name_on_the_Card__c,sc_Card_Holder_Mobile_No__c,CaseExecutionNumberB__c,LetterReferenceNumberB__c,BlockAmountBHDB__c,
                                sc_Card_Holder_Email_Address__c,sc_Relationship__c,sc_Card_Holder_ID_Number__c,sc_Card_Holder_ID_Expiry_Date__c,sc_Card_Holder_Last_Name__c,AccountId,
                                sc_Card_Holder_First_Name__c,sc_Card_Holder_Date_of_Birth__c,sc_Card_Holder_Nationality__c,sc_Card_Holder_Gender__c,Account.PersonEmail,Account.CIF__pc,Case_Model__c,Sub_Type__c,Region_Flag__c,
                                ppc_Approved_Name_On_The_Card__c,ppc_Card_Holder_Age__c,ppc_Adult_Issuance_Fee__c,ppc_Adult_Issuance_VAT__c,ppc_Minor_Issuance_Fee__c,ppc_Minor_Issuance_VAT__c,Card_Product_Configuration_Id__c,ppc_OTP_MobileNo__c,
                                ppc_OTP_EmailAddress__c,sc_Jumio_Scan_Reference_Number__c,Card_Type__c,ppc_ParticipantName__c,ppc_CardDesign__c
                            FROM Case LIMIT 1];//CH01
    }
    private static Account getCreatedCustomer(){
        return [SELECT Id,CIF__pc,PersonEmail,Region_Flag__c FROM Account LIMIT 1];
    }

    @isTest
    static void callCreditCardStatementApiTest(){
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        ApiConnection.Response response = SM001_ApiCalls.callCreditCardStatementApi(con,'123456',null,'{accountId: "2660030003971549",statementType: "Statement"}');
        System.assert(response.isSuccess == true);

        ApiConnection.Response response1 = SM001_ApiCalls.callCreditCardStatementDetailsApi(con,'123456',null,'{accountId: "2660030003971549",statementType: "Statement"}');
        System.assert(response1.isSuccess == true);

        test.stopTest();
    }

    @isTest
    static void callAccountStatementsApiTest(){
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        ApiConnection.Response response = SM001_ApiCalls.callAccountStatementsApi(con,'123456','{accountId: "2660030003971549",statementType: "Statement"}');
        System.assert(response.isSuccess == true);

        ApiConnection.Response response1 = SM001_ApiCalls.callAccountStatementsDetailsApi(con,'123456','{accountId: "2660030003971549",statementType: "Statement"}');
        System.assert(response1.isSuccess == true);

        test.stopTest();
    }


     @isTest
    static void updateCreditCardRequestStatusApiTest(){
        test.startTest();
        Case caseObj = getCreateCase();
        Account acc = getCreatedCustomer();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        HttpResponse response = SM001_ApiCalls.updateCreditCardRequestStatusApi(con,caseObj,'EXPIRED');
        System.assert(response.getStatusCode() == 200);

        ApiConnection con = new ApiConnection();
        HttpRequest request = con.createRequest('GET','/api/v1/credit-cards?',null);
        

        test.stopTest();
    } 

    @isTest
    static void CreditCardStatusTest(){
        test.startTest();
        Account acc = getCreatedCustomer();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        ApiConnection con = new ApiConnection();

        HttpRequest request = con.createRequest('GET','/api/v1/credit-cards?','Jordan');
        ApiConnection.Response response = SM001_ApiCalls.getCreditCardStatusApi(con,'123456','123456','filerOption','Jordan');
        
        HttpRequest request1 = con.createRequest('GET','/api/v1/credit-cards/{cardId}/details',null);
        ApiConnection.Response response1 = SM001_ApiCalls.getCreditCardDetailsApi(con,'cardId','customerId','personEmail','Bahrain');

        test.stopTest();
    }

    @isTest
    static void accountClosureTest(){
        test.startTest();
        Case caseObj = getCreateCase();
        Account acc = getCreatedCustomer();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        HttpResponse response = SM001_ApiCalls.callAccountListApi(acc,null);
        System.assert(response.getStatusCode() == 200);

        HttpResponse response1 = SM001_ApiCalls.callValidateAccountClosureApi(caseObj);
        System.assert(response1.getStatusCode() == 200);

        ApiConnection con = new ApiConnection();
        HttpRequest request = con.createRequest('DELETE','/api/v1/customer-products/account',null);
        HttpResponse response2 = SM001_ApiCalls.callCloseAccountApi(caseObj,request);
        System.assert(response2.getStatusCode() == 200);

        test.stopTest();
    }

    //Start add 19/07/2022 by aniss
    @isTest
    static void blockUnblockAccountApiTest(){
        test.startTest();
        Case caseObj = getCreateCase();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        HttpResponse response = SM001_ApiCalls.blockUnblockAccountApi(new HttpRequest(),caseObj, 'Approved' );
        System.assert(response.getStatusCode() == 200);


        test.stopTest();
    }

    @isTest
    static void getAccountsListAllApiTest(){
        test.startTest();
        Case caseObj = getCreateCase();
        Account acc = getCreatedCustomer();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        HttpResponse response = SM001_ApiCalls.getAccountsListAllApi(new HttpRequest(),acc );
        System.assert(response.getStatusCode() == 200);

        test.stopTest();
    }

    @isTest
    static void getAccountHoldTransactionsApiTest(){
        test.startTest();
        Case caseObj = getCreateCase();
        Account acc = getCreatedCustomer();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        HttpResponse response = SM001_ApiCalls.getAccountHoldTransactionsApi(new HttpRequest(),acc , 'IBN012598451545');
        System.assert(response.getStatusCode() == 200);

        test.stopTest();
    }

    @isTest
    static void callScheduledPlaPaymentsApiTest(){
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        ApiConnection.Response response = SM001_ApiCalls.callScheduledPlaPaymentsApi(new ApiConnection(),'123456' , '{}','Bahrain');
        System.assert(response != null);

        ApiConnection.Response response1 = SM001_ApiCalls.callScheduledPlaPaymentDetailsApi(new ApiConnection(),'123456' , '1','Bahrain');
        System.assert(response1 != null);

        test.stopTest();
    }
	
    @isTest
    static void updatePrepaidCardRequestStatusApiTest(){
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        Case caseObj = getCreateCase();
        ApiConnection con = new ApiConnection();
		HttpRequest request = con.createRequest('PUT','/api/v1/credit-cards/request',null);
        try{
	        SM001_ApiCalls.updatePrepaidCardRequestStatusApi(request,caseObj , 'APPROVED');
        }catch(Exception e){
            System.debug('updatePrepaidCardRequestStatusApiTest');
        }
        test.stopTest();
    }
    
    @isTest
    static void callValidateAccountTerminationApiTest(){
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        Case caseObj = getCreateCase();
        try{
	        SM001_ApiCalls.callValidateAccountTerminationApi(caseObj );
        }catch(Exception e){
            System.debug('callValidateAccountTerminationApiTest');
        }
        test.stopTest();
    }
    
    
    @isTest
    static void smt_callCloseAccountApiTest(){
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        ApiConnection con = new ApiConnection();
		HttpRequest request = con.createRequest('PUT','/api/v1/credit-cards/request',null);
        try{
	        SM001_ApiCalls.smt_callCloseAccountApi(request,'IBANtest','123456' );
        }catch(Exception e){
            System.debug('smt_callCloseAccountApiTest');
        }
        test.stopTest();
    }
    
    //End add 19/07/2022 by aniss
    
     @isTest
    static void CustomerTotalBalanceAPITest(){
        test.startTest();
        Case caseObj = getCreateCase();
        Account acc = getCreatedCustomer();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        HttpResponse response = SM001_ApiCalls.CustomerTotalBalanceAPI(new HttpRequest(),acc );
        System.assert(response.getStatusCode() == 200);
        test.stopTest();
    }
    
          //CH03: START
       @isTest
       static void callBondSukukStatementsApiTest(){
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        ApiConnection.Response response = SM001_ApiCalls.callBondSukukStatementsApi(con,'123456','Bahrain');
        System.assert(response.isSuccess == true);

        ApiConnection.Response response1 = SM001_ApiCalls.callBondSukukStatementsDetailsApi(con,'123456','Bahrain','{accountId: "2660030003971549",statementType: "Statement"}');
        System.assert(response1.isSuccess == true);

        test.stopTest();
    }

    //CH04:Start
    @isTest
    static void MoEngageDeleteAPITest(){
        test.startTest();
        Case caseObj = getCreateCase();
        Account acc = getCreatedCustomer();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        HttpResponse response = SM001_ApiCalls.MoEngageDeleteAPI(new HttpRequest(),acc );
        System.assert(response.getStatusCode() == 200);
        test.stopTest();
    }
    
    @isTest
    static void CustomerTotalBalanceAPITest2(){
        test.startTest();
        Case caseObj = getCreateCase();
        Account acc = getCreatedCustomer();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        HttpResponse response = SM001_ApiCalls.CustomerTotalBalanceAPI(new HttpRequest(),acc );
        System.assert(response.getStatusCode() == 200);
        test.stopTest();
    }
    
    @isTest
    static void PeriodicReviewUnblockProductsApiTest(){
        test.startTest();
        Case caseObj = getCreateCase();
        Account acc = getCreatedCustomer();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        HttpResponse response = SM001_ApiCalls.PeriodicReviewUnblockProductsApi(new HttpRequest(),acc );
        System.assert(response.getStatusCode() == 200);
        test.stopTest();
    }
    
    @isTest
    static void PeriodicReviewBlockProductsApiTest(){
        test.startTest();
        Case caseObj = getCreateCase();
        Account acc = getCreatedCustomer();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        HttpResponse response = SM001_ApiCalls.PeriodicReviewBlockProductsApi(new HttpRequest(),acc,caseObj);
        System.assert(response.getStatusCode() == 200);
        test.stopTest();
    }
    
    @isTest
    static void updateCustomerDetailsAPITest(){
        test.startTest();
        Case caseObj = getCreateCase();
        Account acc = getCreatedCustomer();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        HttpResponse response = SM001_ApiCalls.updateCustomerDetailsAPI(new HttpRequest(),'' );
        System.assert(response.getStatusCode() == 200);
        test.stopTest();
    }
    
    @isTest
    static void getCreditCardStatusApiTest(){
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        ApiConnection.Response response = SM001_ApiCalls.getCreditCardStatusApi(con,'123456','123456','{accountId: "2660030003971549",statementType: "Statement"}','Bahrain');
        test.stopTest();
    }
    
    @isTest
    static void getCreditCardDetailsApiTest(){
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        ApiConnection.Response response = SM001_ApiCalls.getCreditCardDetailsApi(con,'123456','123456','{accountId: "2660030003971549",statementType: "Statement"}','Bahrain');
        test.stopTest();
    }
    
    @isTest
    static void callScheduledPlaPaymentsApiTest2(){
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        ApiConnection.Response response = SM001_ApiCalls.callScheduledPlaPaymentsApi(con,'123456','{accountId: "2660030003971549",statementType: "Statement"}','Bahrain');
        test.stopTest();
    }
    
    @isTest
    static void callScheduledPlaPaymentDetailsApiTest(){
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        ApiConnection.Response response = SM001_ApiCalls.callScheduledPlaPaymentDetailsApi(con,'123456','{accountId: "2660030003971549",statementType: "Statement"}','Bahrain');
        test.stopTest();
    }
    //CH04:End
}