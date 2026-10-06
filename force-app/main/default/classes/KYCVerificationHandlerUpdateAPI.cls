/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 03-11-2025
*       Change History: 
*        
*/
public class KYCVerificationHandlerUpdateAPI implements Queueable, Database.AllowsCallouts {
    private static ApiConnection con = new ApiConnection();
    set<Id> setKYCVerificationsIds;
   
    public KYCVerificationHandlerUpdateAPI(set<Id> setKYCVerificationsIds){
        this.setKYCVerificationsIds = setKYCVerificationsIds;
    }
    public void execute(QueueableContext context){
        List<KYC_Verification__c> lstKycUpdate = new List<KYC_Verification__c>();
        List<KYC_System_Action__c> lstSA = new List<KYC_System_Action__c>();
        
        List<KYC_Verification__c> lstKYC = [Select Id,Account_Name__c,Contact_Name__c,CIF__c,Type__c,Sub_Type__c,Overdue_Handling__c,Overdue_Stage__c,API_Status__c,Account_Name__r.Region_Flag__pc,Account_Name__r.PersonEmail,Account_Name__r.CIF__pc,Overdue_Stage_Enable_L3__c,case_Model__c,
                                            Sub_Status__c,Status__c,CRM_Stage__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c,Review_Personal_Information_Required__c,Block_Debit_Cards__c,Block_Credit_Cards__c,Block_App_Access__c,Block_Account_Debits__c, 
                                            Document_Passport__c,Document_Proof_of_Address__c,Document_Residence_Permit__c,Document_FATCA_Declaration__c,eKYC_Required__c, eKYC_Status__c, ID_V_Required__c, Customer_Segment__c, VVIP__c,Documents_Status__c,Upload_Documents_Required__c,KYC_Verification_Result__c,Account_Name__r.Subscription_Model__pc,Account_Name__r.x_canary__pc,Account_Name__r.Mobile_Phone_Check__pc,No_of_days__c,Next_Notification_Date__c,Account_Name__r.Documents_Status__pc,Document_List__c,Document_Resend__c,Notification_L2_0_days__c,
                                            Notification_L3_S1_15_days__c,Notification_L3_S1_30_days__c,Notification_L3_S1_45_days__c,Notification_L3_S1_60_days__c,Notification_L3_S1_75_days__c,Notification_L3_S1_76_days__c,Notification_L3_S2_0_Days__c,Notification_L3_S2_15_days__c,Notification_L3_S2_30_days__c,
                                            Notification_L3_S3_0_Days__c,Notification_L3_S3_15_days__c,Notification_L3_S3_30_days__c,Notification_L3_S4__c,Notification_L2_15days__c,Notification_L3_S1_0days__c,Notification_S2_0days__c from KYC_Verification__c where Id IN : setKYCVerificationsIds];
         for(KYC_Verification__c kyc : lstKYC){
            try {
                String regionName = kyc.Account_Name__r.Region_Flag__pc;
            	if(kyc.case_Model__c == 'alburaq'){
                	regionName += '_alburaq';
            	}
                HttpRequest request = con.createRequest('PUT','/api/v1/kyc-verification',regionName);
                if(kyc.Overdue_Stage_Enable_L3__c == false){
                     request.setBody(JSON.serialize(KYCVerificationService.buildRequestBodyUpdate(kyc)));
 				}
                else if(kyc.Overdue_Stage_Enable_L3__c == true){
                     request.setBody(JSON.serialize(KYCVerificationService.buildRequestBodyUpdateOverdue(kyc)));
 				}
                request.setHeader('userId', kyc.Account_Name__r.PersonEmail);
                request.setHeader('customerId', kyc.Account_Name__r.CIF__pc);
                request.setTimeout(70000);
				System.debug('Get Request Body:'+request.getBody());
                HttpResponse response = new Http().send(request);
                System.debug('Get Response Body:'+response.getBody());

                if(response.getStatusCode() != 200) {
                    lstSA.add(KYCVerificationService.buildSystemAction(request.getBody(), response.getBody(), request.getEndpoint(),'PUT', kyc.CIF__c, kyc.Id, response.getStatusCode()));
                }else{
                    if(kyc.Overdue_Stage_Enable_L3__c == false){
                        KYCVerificationService.updateKycStatusUpdate(kyc);
                        lstKycUpdate.add(kyc);
                        lstSA.add(KYCVerificationService.buildSystemAction(request.getBody(), response.getBody(), request.getEndpoint(),'PUT', kyc.CIF__c, kyc.Id, response.getStatusCode()));
                    }
                    else if(kyc.Overdue_Stage_Enable_L3__c == true){
                         KYCVerificationService.updateKycStatusUpdateOverdueStage(kyc);
                        lstKycUpdate.add(kyc);
                        lstSA.add(KYCVerificationService.buildSystemAction(request.getBody(), response.getBody(), request.getEndpoint(),'PUT', kyc.CIF__c, kyc.Id, response.getStatusCode()));
                    }

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
		if(!lstSA.isEmpty()) {
            insert lstSA;
        }
    } //execute Ends

}