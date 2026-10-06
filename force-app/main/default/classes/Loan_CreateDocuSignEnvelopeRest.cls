/**
 * @description       : global apex class to expose a web service .Once called, a new DocuSign envelope should be created with the new embedded signing method ..
 * @author            : Aniss Mbarki
 * @group             : 
 * @last modified on  : 16/02/2024
 * @last modified by  : 
 * @History : 
**/
@RestResource(urlMapping='/docusign_toolKit/*')
global with sharing class Loan_CreateDocuSignEnvelopeRest {

    @HttpPost
    global static Loan_DocuSignEnvelopeResponseWrapper createDocuSignEnvelope() {
        System.debug('***************************************============ createDocuSignEnvelope ============***************************************');
             Loan_DocuSignEnvelopeReqWrapper requestRecord = (Loan_DocuSignEnvelopeReqWrapper) JSON.deserialize(RestContext.request.requestBody.toString(), Loan_DocuSignEnvelopeReqWrapper.class);
             return Loans_ServiceManagerHandler.createDocuSignEnvelope(requestRecord);
    }
}