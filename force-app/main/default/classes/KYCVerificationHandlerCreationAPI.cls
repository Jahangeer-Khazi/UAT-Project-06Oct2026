/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 26-10-2025
*       Change History: 
*        
*/
public class KYCVerificationHandlerCreationAPI implements Queueable, Database.AllowsCallouts{
    private static ApiConnection con = new ApiConnection();
    set<Id> setKYCVerificationsIds;
   
    public KYCVerificationHandlerCreationAPI(set<Id> setKYCVerificationsIds){
        this.setKYCVerificationsIds = setKYCVerificationsIds;
    }
    public void execute(QueueableContext context){
        List<KYC_Verification__c> lstKycUpdate = new List<KYC_Verification__c>();
        List<KYC_System_Action__c> lstSA = new List<KYC_System_Action__c>();

       List<KYC_Verification__c> lstKYC = [Select Id,case_Model__c,Account_Name__c,Contact_Name__c,CIF__c,Type__c,Sub_Type__c,Overdue_Handling__c,Overdue_Stage__c,API_Status__c,Account_Name__r.Region_Flag__pc,Account_Name__r.PersonEmail,Account_Name__r.CIF__pc,
                                          Sub_Status__c,Status__c,CRM_Stage__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c,Review_Personal_Information_Required__c,Block_Debit_Cards__c,Block_Credit_Cards__c,Block_App_Access__c,Block_Account_Debits__c, 
                                          Document_Passport__c,Document_Proof_of_Address__c,Document_Residence_Permit__c,Document_FATCA_Declaration__c,eKYC_Required__c, eKYC_Status__c, ID_V_Required__c, Customer_Segment__c, VVIP__c,Documents_Status__c,Upload_Documents_Required__c,
                                          Account_Name__r.Subscription_Model__pc,Account_Name__r.x_canary__pc,Account_Name__r.Mobile_Phone_Check__pc,No_of_days__c,Next_Notification_Date__c,Document_List__c,Document_Resend__c
                                          from KYC_Verification__c where Id IN : setKYCVerificationsIds];
        for(KYC_Verification__c kyc : lstKYC){
            try {
                String regionName = kyc.Account_Name__r.Region_Flag__pc;
            	if(kyc.case_Model__c == 'alburaq'){
                	regionName += '_alburaq';
            	}
                HttpRequest request = con.createRequest('POST','/api/v1/kyc-verification',regionName);
                request.setBody(JSON.serialize(KYCVerificationService.buildRequestBody(kyc)));
                request.setHeader('userId', kyc.Account_Name__r.PersonEmail);
                request.setHeader('customerId', kyc.Account_Name__r.CIF__pc);
                request.setTimeout(70000);
				System.debug('Request Body:'+request.getBody());
                HttpResponse response = new Http().send(request);
				System.debug('Response Body:'+response.getBody());
                if(response.getStatusCode() != 200) {
                    
                    lstSA.add(KYCVerificationService.buildSystemAction(request.getBody(), response.getBody(), request.getEndpoint(),'POST', kyc.CIF__c, kyc.Id, response.getStatusCode()));
                }else{
                   if((kyc.Overdue_Handling__c!='Level 1 - App (Nudges)')){
                    List<KYCNotificationService.KycNotificationData>ksd= New List<KYCNotificationService.KycNotificationData>();
                    KYCNotificationService.KycNotificationData Ks= New KYCNotificationService.KycNotificationData();
                    ks.Kyccase=kyc;
                    ks.noofdays=String.valueOf(kyc.No_of_days__c);
                    ksd.add(ks);
                    KYCNotificationService.KycNotificationSetting(ksd);
                   }
                    KYCVerificationService.updateKycStatusCreation(kyc);
                    lstKycUpdate.add(kyc);
                    lstSA.add(KYCVerificationService.buildSystemAction(request.getBody(), response.getBody(), request.getEndpoint(),'POST', kyc.CIF__c, kyc.Id, response.getStatusCode()));

                }
            }
            catch(Exception ex) {
                lstSA.add(KYCVerificationService.buildExceptionAction(ex, kyc));
            }
        }//for loop Ends

        // Update failed logs
        if(!lstKycUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(lstKycUpdate, false);
            for(Integer i = 0; i < results.size(); i++){
                if(!results[i].isSuccess()){
                    for(Database.Error err : results[i].getErrors()){
                        lstSA.add(KYCVerificationService.buildErrorAction(err.getMessage(), lstKycUpdate[i]));
                    }
                }
            }
        }

        if (!lstSA.isEmpty()) {
            insert lstSA;
        }
       
    }//execute Ends
     
}