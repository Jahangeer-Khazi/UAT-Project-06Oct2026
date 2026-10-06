@isTest
public class KYCFormUpdateCustomerTest {
     @testSetup
    static void setupData() {

        // Create Account
        Account acc = new Account(FirstName = 'Test',LastName = 'Ila',PersonEmail = 'testclass@ilatest123.com',Region_Flag__c = 'Bahrain',Subscription_Model__pc = 'ila');
        insert acc;

        // Create KYC Verification
        KYC_Verification__c kyc = new KYC_Verification__c(Account_Name__c = acc.Id,Case_Model__c = 'ila');
        insert kyc;

        // Create KYC Form
        KYC_Form__c form = new KYC_Form__c(
            KYC_Verification__c = kyc.Id,
            Account_Usage_Reason__c = 'Saving',
            Employment_Status__c = 'Employed',
            Employer_Name__c = 'ABC Pvt Ltd',
            Business_Industry__c = 'Banking',
            Employment_Country__c = 'India',
            Occupation__c = 'Engineer',
            Source_of_Funds__c = 'Salary',
            Gross_Monthly_Income__c = '500',
            Expected_Monthly_Deposits__c = 50000,
            Applicable_Residency_Tax__c = 'Yes',
            Tax_Country_1__c = 'India',
            Tax_Country_1_ID__c = 'TAX123',
            Tax_Country_2__c = 'USA',
            Tax_Country_2_ID__c = 'USA123',
            Tax_Country_3__c = 'UK',
            Tax_Country_3_ID__c = 'UK123',
            Tax_Country_4__c = 'Canada',
            Tax_Country_4_ID__c = 'CAN123',
            US_Indicia__c = true,
            FATCA_Customer__c = true,
            FATCA_Declaration_Document_Type__c = 'W9',
            FATCA_Declaration_Timestamp__c = System.now(),

            Estimated_Net_Worth__c = '0-499999',
            Monthly_Salary__c = '0-499',
            Annual_Dividends__c = 10000,
            Monthly_Rental_Income__c = 15000,
            Investments__c = 500000,
            Monthly_Business_Proceeds__c = 25000,
            Inheritance__c = 200000,
            Submitted_By__c = 'Customer',
            Submitted_On__c = Date.today()
        );

        insert form;
    }

    @isTest
    static void testUpdateKycFormCustomer() {

        KYC_Verification__c kyc = [SELECT Id, Account_Name__c FROM KYC_Verification__c LIMIT 1];

        Test.startTest();

        Account resultAcc = KYCFormUpdateCustomer.updateKycFormCustomer(kyc);

        Test.stopTest();

        
    }

    @isTest
    static void testInsertSourceofWealth() {

        KYC_Verification__c kyc = [SELECT Id, Account_Name__c FROM KYC_Verification__c LIMIT 1];

        Test.startTest();

        Source_of_Wealth__c sow = KYCFormUpdateCustomer.insertSourceofWealth(kyc);

        Test.stopTest();

        
    }

    @isTest
    static void testUpdateKycFormCustomerNoKycForm() {

        KYC_Verification__c kyc =[SELECT Id, Account_Name__c FROM KYC_Verification__c LIMIT 1];

        Test.startTest();

        Account result = KYCFormUpdateCustomer.updateKycFormCustomer(kyc);

        Test.stopTest();

    }

    @isTest
    static void testInsertSourceofWealthNoKycForm() {

        KYC_Verification__c kyc = [SELECT Id, Account_Name__c FROM KYC_Verification__c LIMIT 1];

        Test.startTest();

        Source_of_Wealth__c sow = KYCFormUpdateCustomer.insertSourceofWealth(kyc);

        Test.stopTest();

    }

}