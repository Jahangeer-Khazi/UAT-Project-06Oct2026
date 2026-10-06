public with sharing class SironTCRIntegration {

    private static ApiConnection con = new ApiConnection();

    public class FlowInputs {
        @InvocableVariable(label='Customer Id' description='The ID of the Customer' required=true)
        public String customerId;
    }

    @InvocableMethod(label='Call SironTCR API')
    public static List<String> updateCustomerInSiron(List<FlowInputs> inputs) {
        List<String> results = new List<String>();
        List<String> customerIds = new List<String>();

        for (FlowInputs input : inputs) {
            customerIds.add(input.customerId);
            results.add('Callout initiated for ' + input.customerId );
        }

        // Call the future method once with all customerIds
        updateCustomerInSironFutureMethod(customerIds);
        return results;
    }

    @future(callout=true)
    public static void updateCustomerInSironFutureMethod(List<String> customerIds) {
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Account> customers = new List<Account>();

        if (customerIds != null && customerIds.size() > 0) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Account');
            
            String soqlQuery = 'SELECT ' + fields + ' FROM Account WHERE Id IN :customerIds';
            customers = new List<Account>((List<Account>)Database.query(soqlQuery));
        }
        

        for (Account acc : customers) {
            // Build HTTP request
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req = con.createRequest('PUT', '/api/v1/compliances/update', acc.Region_Flag__pc);
            req.setHeader('userId', acc.PersonEmail);
            req.setHeader('customerId', acc.CIF__pc);
            req.setTimeout(60000);

            // Create JSON payload
            Map<String, Object> payload = new Map<String, Object>();
            payload.put('nationality', acc.Nationality__pc);
            payload.put('employmentStatus', acc.Employment_Status__pc);
            payload.put('salary', acc.Gross_Monthly_Income__pc);
            payload.put('usIndicia', acc.US_Indicia__pc);
            payload.put('expectedMonthlyDeposit', acc.Expected_Monthly_deposits__pc);

            Map<String, Object> customerName = new Map<String, Object>();
            customerName.put('firstName', acc.FirstName);
            customerName.put('middleName', acc.MiddleName);
            customerName.put('lastName', acc.LastName);
            payload.put('customerName', customerName);

            Map<String, Object> mobileNumber = new Map<String, Object>();
            mobileNumber.put('countryCode', acc.Mobile_Country_Code__pc);
            mobileNumber.put('mobileNumber', acc.PersonMobilePhone);
            payload.put('mobileNumber', mobileNumber);

            Map<String, Object> address = new Map<String, Object>();
            address.put('mailStreet', acc.PersonMailingStreet);
            address.put('mailCity', acc.PersonMailingCity);
            address.put('mailCountry', acc.PersonMailingCountry);
            payload.put('address', address);

            String jsonPayload = JSON.serialize(payload);
            req.setBody(jsonPayload);

            system.debug('request endpoint: ' + req.getEndpoint() );
            system.debug('request body :' + req.getBody());
            try {
                // Send HTTP request
                HttpResponse res = http.send(req);

                if (res.getStatusCode() != 200) {
                    System.debug('Error while updating customer in SironTCR: ' + customer.Id);
                    System.debug('Error Response in Update SironTCR API:'+res.getBody());
                    lstSA.add(createSystemAction(req.getBody(),res.getBody(),req.getEndpoint(),acc.CIF__pc,acc.id,res.getStatusCode(),'PUT','Update Siron TCR API'));
                
                } else {
                    System.debug('Success Response in Update SironTCR API:'+res.getBody());
                }
            } catch (Exception e) {
                System.debug('Exception occurred : ' + e.getStackTraceString());
                System.debug('Exception occurred for customer ' + acc.Id + ': ' + e.getMessage());
            }

            if(lstSA.size()>0){
                insert lstSA;
            }
        }
    }

    private static System_Action__c createSystemAction(final String reqBody, final String resBody, final String path, final String custId, final Id AccId, final Integer statCode, final String method, final String strAction) {
        System_Action__c action = new System_Action__c();
        action.Account_Number__c = custId;
        action.Account__c = AccId;
        action.Endpoint__c = path;
        action.Method__c = method;
        action.HTTP_Response_Code__c = statCode;
        action.Origin__c = 'CRM';
        action.Request_Body__c = reqBody;
        action.Response_Body__c = resBody;
        action.Target__c = 'Orchestration Layer';
        action.Action__c = strAction;
        
        return action;
        
    }
}