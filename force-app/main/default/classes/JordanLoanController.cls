/********************************************************************************************
* @name                 JordanLoanController
* @description          Controller class to call the jordan loan api for RLOSInquiry.
* @date                 01/03/2026
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           01/03/2026     Initial Version
*********************************************************************************************
*/

public class JordanLoanController {

    @AuraEnabled
    public static ApiConnection.Response callRLOSInquiry(Id recordId){
    
        Jordan_Loan__c  jordanLoan = [Select Id, RLOS_Application_Ref__c,CIF__c  FROM Jordan_Loan__c WHERE Id =: recordId];
        System.debug('jordanLoan ' + jordanLoan);
        if(!String.isEmpty(jordanLoan.RLOS_Application_Ref__c)){
            
            ApiConnection con = new ApiConnection();
            
            String urlPath = '/api/v1/loan-jo/rlos/status/' + jordanLoan.RLOS_Application_Ref__c + '?unit=jor&language=en';
            HttpRequest req = con.createRequest('GET', urlPath,'');
            
            //Setting additional header params
            req.setHeader('trackingId', '39af6440-0b0a-4688-98a7-a7c99999999');
            req.setHeader('customerId', jordanLoan.CIF__c);
            req.setHeader('unit','jor');
            req.setHeader('language', 'en');
            
            System.debug('request endpoint ' + req.getEndpoint());
            Http http = new Http();
            //HttpResponse response = http.send(req);
            ApiConnection.Response response = con.makeCallout(req);
            return response;
        }
        else {
            ApiConnection.Response response = new ApiConnection.Response();
            response.isSuccess = false;
            response.responseData = '';
            response.errorData = 'RLOS Application Ref field is not populated.';
            return response;
        }   
    }
}