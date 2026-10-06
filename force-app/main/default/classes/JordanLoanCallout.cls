/********************************************************************************************
* @name                 JordanLoanCallout
* @description          Queueable class for calling the api from JordanLoanTriggerHandler
* @date                 19/04/2026
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           19/04/2026     Initial Version
*********************************************************************************************
*/

public class JordanLoanCallout implements Queueable, Database.AllowsCallouts {

    Jordan_Loan__c jrloan;
    public JordanLoanCallout(Jordan_Loan__c jrloan) {
        this.jrloan = jrloan;
    }
    
    public void execute(QueueableContext context) {
    	ApiConnection con = new ApiConnection();
        String path = '/api/v1/loan-jo/' + jrloan.Id;
        Boolean jLoanApplicationRef = String.isBlank(jrloan.RLOS_Application_Ref__c)?true:false;
        HttpRequest request = con.createRequest('PATCH', path, jrloan.CIF__c, 'Jordan');
        String body;
        if(jLoanApplicationRef){
        body = '{"subject": "' + jrloan.Subject__c +
                        '","description": "' + jrloan.Description__c +
                        '","cif": "' + jrloan.CIF__c +
                        '","origin": "' + jrloan.Origin__c + 
            			'","status": "' + jrloan.Status__c + 
            			'","subStatus": "' + jrloan.Sub_Status__c + 
            			'","type": "' + jrloan.Type__c + 
            			'","subType": "' + jrloan.Sub_Type__c + 
            			'","nature": "' + jrloan.Case_Nature__c + 
            			'","applicantEmail": "' + jrloan.Email__c + 
            			'","applicantMobile": "' + jrloan.Mobile__c + 
            			'","rejectionReason": "' + jrloan.Rejection_Cancelation_Reason__c + 
            			'","rejectionReasonDetails": "' + jrloan.Rejection_Cancelation_Reason_Details__c + 
            			'","requestedAmount": "' + jrloan.Requested_Amount__c + 
            			'","requestedProduct": "' + jrloan.Requested_Product__c + 
            			'","requestedTerm": "' + jrloan.Requested_Term__c + 
               			'","applicationReference": '+ null + 
            			',"requestedMonthlyInstallment": "' + jrloan.Requested_Installment__c + 
            			'","approvedMonthlyInstallment": "' + jrloan.Approved_Amount__c + 
            			'","requestedVisitTime": "' + jrloan.Preferred_Visit_Time__c + 
            			'","applicantGrossMonthlyIncome": "' + jrloan.Declared_Gross_Monthly_Income__c + 
            			'","calculatedInterestRate": "' + jrloan.App_Calculator_Rate__c + 
            			'","calculatedInterestAmount": "' + jrloan.App_Calculator_Interest_Amount__c + '"}';
        }else{
                   body = '{"subject": "' + jrloan.Subject__c +
                        '","description": "' + jrloan.Description__c +
                        '","cif": "' + jrloan.CIF__c +
                        '","origin": "' + jrloan.Origin__c + 
            			'","status": "' + jrloan.Status__c + 
            			'","subStatus": "' + jrloan.Sub_Status__c + 
            			'","type": "' + jrloan.Type__c + 
            			'","subType": "' + jrloan.Sub_Type__c + 
            			'","nature": "' + jrloan.Case_Nature__c + 
            			'","applicantEmail": "' + jrloan.Email__c + 
            			'","applicantMobile": "' + jrloan.Mobile__c + 
            			'","rejectionReason": "' + jrloan.Rejection_Cancelation_Reason__c + 
            			'","rejectionReasonDetails": "' + jrloan.Rejection_Cancelation_Reason_Details__c + 
            			'","requestedAmount": "' + jrloan.Requested_Amount__c + 
            			'","requestedProduct": "' + jrloan.Requested_Product__c + 
            			'","requestedTerm": "' + jrloan.Requested_Term__c + 
                        '","applicationReference": "'+ jrloan.RLOS_Application_Ref__c + 
            			'","requestedMonthlyInstallment": "' + jrloan.Requested_Installment__c +
            			'","approvedMonthlyInstallment": "' + jrloan.Approved_Amount__c + 
            			'","requestedVisitTime": "' + jrloan.Preferred_Visit_Time__c + 
            			'","applicantGrossMonthlyIncome": "' + jrloan.Declared_Gross_Monthly_Income__c + 
            			'","calculatedInterestRate": "' + jrloan.App_Calculator_Rate__c + 
            			'","calculatedInterestAmount": "' + jrloan.App_Calculator_Interest_Amount__c + '"}';
        }
        
        request.setBody(body);
        request.setTimeout(120000);
        System.debug('jordan api request ' + request);
        System.debug('jordan api request body ' + request.getBody());
        ApiConnection.Response response = con.makeCallout(request);
        System.debug('response jordan status ' + response);
        
        if (!response.isSuccess){
            System_Action__c logObject = new System_Action__c();
            logObject.Jordan_Loan__c  = jrloan.Id;
        	logObject.Account__c = jrloan.Customer__c;
            logObject.Action__c = 'Jordan Loan Status Change API';
            logObject.Endpoint__c = '/api/v1/loan-jo/' + jrloan.Id;
            logObject.Method__c = 'PATCH';
            logObject.Request_Body__c  = request.getBody();
            logObject.Response_Body__c = JSON.serializePretty(response.errorData);
            insert logObject;
        }
    }
}