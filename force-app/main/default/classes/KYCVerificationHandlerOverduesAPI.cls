/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 13-01-2026
*       Change History: 
*        
*/
public class KYCVerificationHandlerOverduesAPI implements Queueable, Database.AllowsCallouts{
    private static ApiConnection con = new ApiConnection();
    set<Id> setKYCVerificationsIds;
    Map<String, String> details;
    
    @InvocableMethod(label='Call API for Overdue Stage Update' description='KYC Verification Update' callout=true)
    public static void updateOverdueStageFromFlow(List<kycVerification> kycDetails){
        Map<String,String> details = new Map<String,String>();
        System.debug('KYC Details:'+kycDetails);
        kycVerification kyc = kycDetails.get(0);
        System.debug('KYC Details from Flow:'+kyc);
        details.put('kycId',kyc.kycId);
        details.put('apiStatusChanged',kyc.apiStatus);
        details.put('overDueStageChanged',kyc.overDueStage);
        KYCVerificationHandlerOverduesAPI overdueAPI = new KYCVerificationHandlerOverduesAPI(new Set<Id>{kyc.kycId},details);
        System.enqueueJob(overdueAPI);
	}

	public KYCVerificationHandlerOverduesAPI(set<Id> setKYCVerificationsIds, Map<String,String> details){
        this.setKYCVerificationsIds = setKYCVerificationsIds;
        this.details = details;
    }
    public void execute(QueueableContext context){
        List<KYC_Verification__c> lstKycUpdate = new List<KYC_Verification__c>();
        List<KYC_System_Action__c> lstSA = new List<KYC_System_Action__c>();
        
        String apiStatus = details.get('apiStatusChanged');
        String overdueStage = details.get('overDueStageChanged');
        
        System.debug('Updated API Status from Flow:'+apiStatus);
        System.debug('Updated Overdue Stage from Flow:'+overdueStage);
        
        List<KYC_Verification__c> lstKYC = [Select Id,Account_Name__c,Contact_Name__c,CIF__c,Type__c,Sub_Type__c,Overdue_Handling__c,Overdue_Stage__c,API_Status__c,Account_Name__r.Region_Flag__pc,Account_Name__r.PersonEmail,Account_Name__r.CIF__pc,Overdue_Stage_Enable_L3__c,Account_Name__r.Subscription_Model__pc,Account_Name__r.x_canary__pc,Account_Name__r.Mobile_Phone_Check__pc,Next_Notification_Date__c,
                                            Sub_Status__c,Status__c,CRM_Stage__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c,Review_Personal_Information_Required__c,Block_Debit_Cards__c,Block_Credit_Cards__c,Block_App_Access__c,Block_Account_Debits__c,No_of_days__c,
                                            Document_Passport__c,Document_Proof_of_Address__c,Document_Residence_Permit__c,Document_FATCA_Declaration__c,eKYC_Required__c, eKYC_Status__c, ID_V_Required__c, Customer_Segment__c, VVIP__c,Documents_Status__c,Upload_Documents_Required__c,FATCA_Declaration_Timestamp__c from KYC_Verification__c where Id IN : setKYCVerificationsIds];
        for(KYC_Verification__c kyc : lstKYC){
             try {
                String regionName = kyc.Account_Name__r.Region_Flag__pc;
            	if(kyc.Account_Name__r.Subscription_Model__pc == 'alburaq'){
                	regionName += '_alburaq';
            	}
                HttpRequest request = con.createRequest('PUT','/api/v1/kyc-verification',regionName);
                
                if(kyc.Overdue_Stage_Enable_L3__c == true){
                     request.setBody(JSON.serialize(KYCVerificationService.buildRequestBodyUpdateAPIStages(kyc)));
 				}
                request.setHeader('userId', kyc.Account_Name__r.PersonEmail);
                request.setHeader('customerId', kyc.Account_Name__r.CIF__pc);
                request.setTimeout(70000);
				System.debug('Get Request Body:'+request.getBody());
                HttpResponse response = new Http().send(request);
                System.debug('Get Response Body:'+response.getBody());

                if(response.getStatusCode() != 200) {
                    if(kyc.Overdue_Stage_Enable_L3__c == true){
                        lstSA.add(KYCVerificationService.buildSystemAction(request.getBody(), response.getBody(), request.getEndpoint(),'PUT', kyc.CIF__c, kyc.Id, response.getStatusCode()));
                    }
                }else{
                    if(kyc.Overdue_Stage_Enable_L3__c == true){
                        lstSA.add(KYCVerificationService.buildSystemAction(request.getBody(), response.getBody(), request.getEndpoint(),'PUT', kyc.CIF__c, kyc.Id, response.getStatusCode()));
                        /*List<KYCNotificationService.KycNotificationData> ksd = New List<KYCNotificationService.KycNotificationData>();
            			KYCNotificationService.KycNotificationData Ks = New KYCNotificationService.KycNotificationData();
            			ks.Kyccase = kyc;
            			ks.noofdays = String.valueOf(kyc.No_of_days__c);
            			ksd.add(ks);
            			KYCNotificationService.KycNotificationSetting(ksd);*/
                    }
                }
            }
            catch(Exception ex) {
                lstSA.add(KYCVerificationService.buildExceptionAction(ex, kyc));
            }
        }//for loop End
        if(!lstSA.isEmpty()){
            insert lstSA;
        }

    } //execute Ends
    public class kycVerification{
        @InvocableVariable(label='kycId' description='the Id of the kyc verification' required=true)
        public String kycId;
        
        @InvocableVariable(label='apiStatus' description='API Status')
        public String apiStatus;
        
        @InvocableVariable(label='OverDue Stage' description='Overdue Stage')
        public String overDueStage;
    }

}