/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 02-11-2025
*       Change History: 
*        
*/
public class KYCVerificationService {
    //Request Body Builder for KYC Case Creation
    public static Map<String, Object> buildRequestBody(KYC_Verification__c kyc){
        
        Map<String, Object> requestBody = new Map<String, Object>{
            'caseId' => kyc.Id,
                'customerId' => kyc.Account_Name__r.CIF__pc,
                'status' => kyc.Status__c
                };
                    Map<String, Object> idvRefObj = new Map<String, Object>();
        Map<String, Object> taxRefObj = new Map<String, Object>();
        Map<String, Object> docRefObj = new Map<String, Object>();
        Map<String, Object> refObj = new Map<String, Object>();
        
        /////////////////////////////////////////////////////////////////////// Start: KYC Periodic Review Logic Case Creation /////////////////////////////////////////////////////////////
        
        if(kyc.Type__c=='KYC_PERIODIC_REVIEW'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Sub_Status__c =:kyc.sub_status__c AND Overdue_Stage__c =:kyc.Overdue_Stage__c AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1];
            
            if(kyc.ID_V_Required__c == 'Yes') {
                requestBody.put('idvStatus',APIStatusUpdate(kyc.ID_V_Status__c));
                requestBody.put('idvContentReference',String.valueOf(idvRefObj));
                requestBody.put('kycVerificationType',kyc.Type__c);
                requestBody.put('kycFormStatus', APIStatusUpdate(kyc.KYC_Form_Status__c));
                requestBody.put('kycFormReference', String.valueOf(refObj));
                requestBody.put('kycFormTaxStatus',  APIStatusUpdate(kyc.KYC_Form_Tax_Status__c));
                requestBody.put('kycFormTaxReference', String.valueOf(taxRefObj));
                requestBody.put('kycUploadDocumentsStatus', APIStatusUpdate(kyc.KYC_Upload_Document_Status__c));
                requestBody.put('kycUploadDocumentsReference', String.valueOf(docRefObj));
                requestBody.put('blockDebitCards', settings[0].Block_Debit_Card__c);
                requestBody.put('blockCreditCards', settings[0].Block_Credit_Cards__c);
                requestBody.put('blockAccountDebits',settings[0].Account_Debits_App_Access__c);
                requestBody.put('blockCustomerAccounts', settings[0].Account_Debits_App_Access__c);   
                requestBody.put('blockAppAccess',settings[0].Block_App_Access__c);
                requestBody.put('subStage', settings[0].API_Status__c);
            }
            else if((kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form') && kyc.eKYC_Required__c == false && (kyc.Upload_Documents_Required__c == 'No' || kyc.Upload_Documents_Required__c == 'Yes')) {
                requestBody.put('idvStatus', 'SKIPPED');
                requestBody.put('idvContentReference',String.valueOf(idvRefObj));
                requestBody.put('kycVerificationType','KYC_PERIODIC_REVIEW');
                requestBody.put('kycFormStatus', 'PENDING');
                requestBody.put('kycFormReference', String.valueOf(refObj));
                requestBody.put('kycFormTaxStatus', 'SKIPPED');
                requestBody.put('kycFormTaxReference', String.valueOf(taxRefObj));
                requestBody.put('blockDebitCards', settings[0].Block_Debit_Card__c);
                requestBody.put('blockCreditCards', settings[0].Block_Credit_Cards__c);
                requestBody.put('blockAccountDebits',settings[0].Account_Debits_App_Access__c);
                requestBody.put('blockCustomerAccounts', settings[0].Account_Debits_App_Access__c);   
                requestBody.put('blockAppAccess',settings[0].Block_App_Access__c);
                if(kyc.Upload_Documents_Required__c == 'No'){
                    requestBody.put('kycUploadDocumentsStatus', 'SKIPPED');
                }else if(kyc.Upload_Documents_Required__c == 'Yes'){
                    requestBody.put('kycUploadDocumentsStatus', 'PENDING');
                }
                requestBody.put('kycUploadDocumentsReference', String.valueOf(docRefObj));
                requestBody.put('subStage', settings[0].API_Status__c);
            }
            else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && kyc.eKYC_Required__c == false && (kyc.Upload_Documents_Required__c == 'No' || kyc.Upload_Documents_Required__c == 'Yes')) {
                requestBody.put('idvStatus', 'SKIPPED');
                requestBody.put('idvContentReference',String.valueOf(idvRefObj));
                requestBody.put('kycVerificationType','KYC_PERIODIC_REVIEW');
                requestBody.put('kycFormStatus', 'SKIPPED');
                requestBody.put('kycFormReference', String.valueOf(refObj));
                requestBody.put('kycFormTaxStatus', 'PENDING');
                requestBody.put('kycFormTaxReference', String.valueOf(taxRefObj));
                requestBody.put('blockDebitCards', settings[0].Block_Debit_Card__c);
                requestBody.put('blockCreditCards', settings[0].Block_Credit_Cards__c);
                requestBody.put('blockAccountDebits',settings[0].Account_Debits_App_Access__c);
                requestBody.put('blockCustomerAccounts', settings[0].Account_Debits_App_Access__c);   
                requestBody.put('blockAppAccess',settings[0].Block_App_Access__c);
                if(kyc.Upload_Documents_Required__c == 'No'){
                    requestBody.put('kycUploadDocumentsStatus', 'SKIPPED');
                }else if(kyc.Upload_Documents_Required__c == 'Yes'){
                    requestBody.put('kycUploadDocumentsStatus', 'PENDING');
                }
                requestBody.put('kycUploadDocumentsReference', String.valueOf(docRefObj));
                requestBody.put('subStage', settings[0].API_Status__c);
            }
            //   else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'No' && kyc.eKYC_Required__c == false && kyc.Upload_Documents_Required__c == 'Yes' && (kyc.Document_Passport__c == true || kyc.Document_Proof_of_Address__c == true || kyc.Document_Residence_Permit__c == true || kyc.Document_FATCA_Declaration__c == true)){
            else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'No' && kyc.eKYC_Required__c == false && kyc.Upload_Documents_Required__c == 'Yes'){   
                requestBody.put('idvStatus', 'SKIPPED');
                requestBody.put('idvContentReference',String.valueOf(idvRefObj));
                requestBody.put('kycVerificationType','KYC_PERIODIC_REVIEW');
                requestBody.put('kycFormStatus', 'SKIPPED');
                requestBody.put('kycFormReference', String.valueOf(refObj));
                requestBody.put('kycFormTaxStatus', 'SKIPPED');
                requestBody.put('kycFormTaxReference', String.valueOf(taxRefObj));
                requestBody.put('kycUploadDocumentsStatus', 'PENDING');
                requestBody.put('kycUploadDocumentsReference',String.valueOf(docRefObj));
                requestBody.put('blockDebitCards', settings[0].Block_Debit_Card__c);
                requestBody.put('blockCreditCards', settings[0].Block_Credit_Cards__c);
                requestBody.put('blockAccountDebits',settings[0].Account_Debits_App_Access__c);
                requestBody.put('blockCustomerAccounts', settings[0].Account_Debits_App_Access__c);   
                requestBody.put('blockAppAccess',settings[0].Block_App_Access__c);
                requestBody.put('subStage', settings[0].API_Status__c);
            }
            KYCVerificationService.applyUploadDocumentSettings(kyc, requestBody);
        }
        /////////////////////////////////////////////////////////////////////// END: KYC Periodic Review Logic Case Creation /////////////////////////////////////////////////////////////
        
        /////////////////////////////////////////////////////////////////////// Start: Suspected Identity Fraud Logic Case Creation /////////////////////////////////////////////////////////////
        
        else{
            if(kyc.ID_V_Required__c == 'Yes') {
                requestBody.put('idvStatus',APIStatusUpdate(kyc.ID_V_Status__c));
                requestBody.put('idvContentReference',String.valueOf(idvRefObj));
                requestBody.put('kycVerificationType',kyc.Type__c);
                requestBody.put('kycFormStatus','SKIPPED');
                requestBody.put('kycFormReference', String.valueOf(refObj));
                requestBody.put('kycFormTaxStatus',  'SKIPPED');
                requestBody.put('kycFormTaxReference', String.valueOf(taxRefObj));
                requestBody.put('kycUploadDocumentsStatus', 'SKIPPED');
                requestBody.put('kycUploadDocumentsReference', String.valueOf(docRefObj));
                //Commented for the block logic
                /* if(kyc.Block_App_Access__c == true){
requestBody.put('blockDebitCards', true);
requestBody.put('blockCreditCards', true);
requestBody.put('blockAccountDebits',true);
requestBody.put('blockCustomerAccounts',true);   
requestBody.put('blockAppAccess', true);
}else if(kyc.Block_App_Access__c == false){*/
                requestBody.put('blockDebitCards', kyc.Block_Debit_Cards__c);
                requestBody.put('blockCreditCards', kyc.Block_Credit_Cards__c);
                requestBody.put('blockAccountDebits',kyc.Block_Account_Debits__c);
                requestBody.put('blockCustomerAccounts', kyc.Block_Account_Debits__c);   
                requestBody.put('blockAppAccess',kyc.Block_App_Access__c);
                // }
                requestBody.put('subStage',kyc.API_Status__c);
                
            }else{
                requestBody.put('idvStatus', 'SKIPPED');
                requestBody.put('idvContentReference',String.valueOf(idvRefObj));
                requestBody.put('kycVerificationType',kyc.Type__c);
                requestBody.put('kycFormStatus','SKIPPED');
                requestBody.put('kycFormReference', String.valueOf(refObj));
                requestBody.put('kycFormTaxStatus',  'SKIPPED');
                requestBody.put('kycFormTaxReference', String.valueOf(taxRefObj));
                requestBody.put('kycUploadDocumentsStatus', 'SKIPPED');
                requestBody.put('kycUploadDocumentsReference', String.valueOf(docRefObj));
                requestBody.put('blockDebitCards', kyc.Block_Debit_Cards__c);
                requestBody.put('blockCreditCards', kyc.Block_Credit_Cards__c);
                requestBody.put('blockAccountDebits',kyc.Block_Account_Debits__c);
                requestBody.put('blockCustomerAccounts', kyc.Block_Account_Debits__c);   
                requestBody.put('blockAppAccess',kyc.Block_App_Access__c);
                requestBody.put('subStage',kyc.API_Status__c);
            }
        }
        /////////////////////////////////////////////////////////////////////// END: Suspected Identity Fraud Logic Case Creation /////////////////////////////////////////////////////////////
        
        return requestBody;
    }
    //Request Body Builder for KYC Case Update
    public static Map<String, Object> buildRequestBodyUpdate(KYC_Verification__c kyc){
        system.debug(kyc);
        String stage;
        Map<String, Object> requestBody = new Map<String, Object>{
            'caseId' => kyc.Id,
                'customerId' => kyc.Account_Name__r.CIF__pc,
                'status' => kyc.Status__c
                };
                    Map<String, Object> idvRefObj = new Map<String, Object>();
        Map<String, Object> taxRefObj = new Map<String, Object>();
        Map<String, Object> docRefObj = new Map<String, Object>();
        Map<String, Object> refObj = new Map<String, Object>();
        
        /////////////////////////////////////////////////////////// Start: Suspected Identity Fraud Logic Case Update /////////////////////////////////////////////////////////////////////////////////
        if(kyc.Type__c == 'KYC_SUSPECTED_IDENTITY_FRAUD' && kyc.ID_V_Required__c == 'Yes' ){
            if(kyc.ID_V_Status__c == 'Success' ||kyc.ID_V_Status__c == 'Skipped'){
                
                List<KYC_Suspect_Identify_Fraud__mdt> settings = [SELECT developerName,Sub_Status__c,Type__c, API_Status__c, Block_Account_Debits__c, Block_App_Access__c, Block_Credit_Cards__c, Block_Debit_Cards__c, CRM_Stage__c, ID_V_Required__c
                                                                  FROM KYC_Suspect_Identify_Fraud__mdt WHERE Sub_Status__c = 'Completed'];
                requestBody.put('idvStatus',APIStatusUpdate(kyc.ID_V_Status__c));
                requestBody.put('idvContentReference',String.valueOf(idvRefObj));
                requestBody.put('kycVerificationType',kyc.Type__c);
                requestBody.put('kycFormStatus','SKIPPED');
                requestBody.put('kycFormReference', String.valueOf(refObj));
                requestBody.put('kycFormTaxStatus',  'SKIPPED');
                requestBody.put('kycFormTaxReference', String.valueOf(taxRefObj));
                requestBody.put('kycUploadDocumentsStatus', 'SKIPPED');
                requestBody.put('kycUploadDocumentsReference', String.valueOf(docRefObj));
                requestBody.put('subStage', settings[0].API_Status__c);
                requestBody.put('blockDebitCards',False);
                requestBody.put('blockCreditCards',False);
                requestBody.put('blockAccountDebits',False);
                requestBody.put('blockCustomerAccounts',False);   
                requestBody.put('blockAppAccess',False);
            }else if(kyc.ID_V_Status__c == 'Pending'){
                List<KYC_Suspect_Identify_Fraud__mdt> settings = [SELECT developerName,Sub_Status__c,Type__c, API_Status__c, Block_Account_Debits__c, Block_App_Access__c, Block_Credit_Cards__c, Block_Debit_Cards__c, CRM_Stage__c, ID_V_Required__c
                                                                  FROM KYC_Suspect_Identify_Fraud__mdt WHERE Sub_Status__c = 'Pending ID&V' AND API_Status__c=:kyc.API_Status__c];
                
                requestBody.put('idvStatus',APIStatusUpdate(kyc.ID_V_Status__c));
                requestBody.put('idvContentReference',String.valueOf(idvRefObj));
                requestBody.put('kycVerificationType',kyc.Type__c);
                requestBody.put('kycFormStatus','SKIPPED');
                requestBody.put('kycFormReference', String.valueOf(refObj));
                requestBody.put('kycFormTaxStatus',  'SKIPPED');
                requestBody.put('kycFormTaxReference', String.valueOf(taxRefObj));
                requestBody.put('kycUploadDocumentsStatus', 'SKIPPED');
                requestBody.put('kycUploadDocumentsReference', String.valueOf(docRefObj));
                requestBody.put('blockDebitCards', kyc.Block_Debit_Cards__c);
                requestBody.put('blockCreditCards', kyc.Block_Credit_Cards__c);
                requestBody.put('blockAccountDebits',kyc.Block_Account_Debits__c);
                requestBody.put('blockCustomerAccounts', kyc.Block_Account_Debits__c);   
                requestBody.put('blockAppAccess',kyc.Block_App_Access__c);
                requestBody.put('subStage',kyc.API_Status__c);
            }
        } 
        /////////////////////////////////////////////////////////// END: Suspected Identity Fraud Logic Case Update /////////////////////////////////////////////////////////////////////////////////
        
        /////////////////////////////////////////////////////////////////////// Start: KYC Periodic Review Logic Case Update /////////////////////////////////////////////////////////////
        
        else if(kyc.Type__c == 'KYC_PERIODIC_REVIEW'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                                                                FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c and Overdue_Handling__c=:kyc.Overdue_Handling__c  AND Sub_Status__c=:Kyc.Sub_Status__c ];
            
            requestBody.put('idvStatus',APIStatusUpdate(kyc.ID_V_Status__c));
            requestBody.put('idvContentReference',String.valueOf(idvRefObj));
            requestBody.put('kycVerificationType','KYC_PERIODIC_REVIEW');
            requestBody.put('kycFormStatus', APIStatusUpdate(kyc.KYC_Form_Status__c));
            requestBody.put('kycFormReference', String.valueOf(refObj));
            requestBody.put('kycFormTaxStatus', APIStatusUpdate(kyc.KYC_Form_Tax_Status__c));
            requestBody.put('kycFormTaxReference', String.valueOf(taxRefObj));
            requestBody.put('kycUploadDocumentsStatus', APIStatusUpdate(kyc.KYC_Upload_Document_Status__c));
            requestBody.put('kycUploadDocumentsReference', String.valueOf(docRefObj));
            KYCVerificationService.applyUploadDocumentSettings(kyc, requestBody);
            
            if(Kyc.Sub_Status__c != 'Completed'){
                requestBody.put('blockDebitCards', settings[0].Block_Debit_Card__c);
                requestBody.put('blockCreditCards', settings[0].Block_Credit_Cards__c);
                requestBody.put('blockAccountDebits',settings[0].Account_Debits_App_Access__c);
                requestBody.put('blockCustomerAccounts', settings[0].Account_Debits_App_Access__c);   
                requestBody.put('blockAppAccess',settings[0].Block_App_Access__c); 
            }else{
                requestBody.put('blockDebitCards',False);
                requestBody.put('blockCreditCards',False);
                requestBody.put('blockAccountDebits',False);
                requestBody.put('blockCustomerAccounts',False);   
                requestBody.put('blockAppAccess',False); 
            }
            
            //////////////////////////////////////////////////////////// ID&V REQUIRED = YES, ID&V Inprogress ////////////////////////////////////////////////////////
            
            if(kyc.ID_V_Required__c == 'Yes' && (kyc.ID_V_Status__c != 'Success' && kyc.ID_V_Status__c != 'Skipped')){
                system.debug('insdied'+settings[0].API_status__c);
                requestBody.put('subStage', settings[0].API_Status__c);
            }
            //////////////////////////////////////////////////////////// ID&V REQUIRED = YES, ID&V Inprogress ////////////////////////////////////////////////////////
            
            //////////////////////////////////////////////////////////// ID&V REQUIRED = YES,ID&V -SUCCESS/SKIP  NO KYC AND NO UPLOAD DOCS ////////////////////////////////////////////////////////
            
            else if(kyc.ID_V_Required__c == 'Yes'&& kyc.Review_Personal_Information_Required__c == 'No' && kyc.Upload_Documents_Required__c == 'No' && (kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped')){
                requestBody.put('subStage', 'PR_COMPLETED');
                requestBody.put('blockDebitCards',False);
                requestBody.put('blockCreditCards',False);
                requestBody.put('blockAccountDebits',False);
                requestBody.put('blockCustomerAccounts',False);   
                requestBody.put('blockAppAccess',False); 
            }
            ////////////////////////////////////////////////////////////  ID&V REQUIRED = YES,ID&V -SUCCESS/SKIP  NO KYC AND NO UPLOAD DOCS ////////////////////////////////////////////////////////
            //////////////////////////////////////////////////////////// ID&V REQUIRED = NO, KYC FULL FORM - IN PROGRESS AND NO UPLOAD DOCS ////////////////////////////////////////////////////////
            else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && (kyc.KYC_Form_Status__c != 'Success' && kyc.KYC_Form_Status__c != 'Skipped') && kyc.Upload_Documents_Required__c == 'No'){
                stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c='Pending KYC - Full Form' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                requestBody.put('subStage',stage);
            }
            //////////////////////////////////////////////////////////// ID&V REQUIRED = NO, KYC FULL FORM - IN PROGRESS AND NO UPLOAD DOCS ////////////////////////////////////////////////////////
            //////////////////////////////////////////////////////////// ID&V REQUIRED = NO, KYC FULL FORM - SUCCESS/SKIPPED AND NO UPLOAD DOCS ////////////////////////////////////////////////////////
            else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && (kyc.KYC_Form_Status__c == 'Success' || kyc.KYC_Form_Status__c == 'Skipped') && kyc.Upload_Documents_Required__c == 'No'){
                if(kyc.Upload_Documents_Required__c == 'No' && kyc.Document_Proof_of_Address__c == false && kyc.Document_FATCA_Declaration__c == false){
                    requestBody.put('subStage', 'PR_COMPLETED');
                    requestBody.put('blockDebitCards',False);
                    requestBody.put('blockCreditCards',False);
                    requestBody.put('blockAccountDebits',False);
                    requestBody.put('blockCustomerAccounts',False);   
                    requestBody.put('blockAppAccess',False); 
                } else if(kyc.Upload_Documents_Required__c == 'No' && (kyc.Document_Proof_of_Address__c == true || kyc.Document_FATCA_Declaration__c == true)){ // Tax Check need to be added
                    stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                            FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c = 'Pending Upload Documents' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                    System.debug('Custom Meta-Data Stage Value:'+stage);
                    requestBody.put('kycUploadDocumentsStatus', 'PENDING');
                    requestBody.put('subStage',stage);
                    requestBody.put('blockDebitCards', kyc.Block_Debit_Cards__c);
                    requestBody.put('blockCreditCards', kyc.Block_Credit_Cards__c);
                    requestBody.put('blockAccountDebits',kyc.Block_Account_Debits__c);
                    requestBody.put('blockCustomerAccounts',kyc.Block_Account_Debits__c);
                    requestBody.put('blockAppAccess',kyc.Block_App_Access__c);
                    KYCVerificationService.applyUploadDocumentSettings(kyc, requestBody);
                    
                }
                
            }
            //////////////////////////////////////////////////////////// ID&V REQUIRED = NO, KYC FULL FORM - SUCCESS/SKIPPED AND NO UPLOAD DOCS ////////////////////////////////////////////////////////
            //////////////////////////////////////////////////////////// ID&V REQUIRED = NO, KYC TAX ONLY - IN PROGRESS AND NO UPLOAD DOCS ////////////////////////////////////////////////////////
            else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && (kyc.KYC_Form_Tax_Status__c != 'Success' && kyc.KYC_Form_Tax_Status__c != 'Skipped') && kyc.Upload_Documents_Required__c == 'No'){
                stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c='Pending KYC - Tax Only' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                requestBody.put('subStage',stage);
            }
            //////////////////////////////////////////////////////////// ID&V REQUIRED = NO, KYC  KYC TAX ONLY - IN PROGRESS AND NO UPLOAD DOCS ////////////////////////////////////////////////////////
            //////////////////////////////////////////////////////////// ID&V REQUIRED = NO, KYC  KYC TAX ONLY - SUCCESS/SKIPPED AND NO UPLOAD DOCS ////////////////////////////////////////////////////////
            else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && (kyc.KYC_Form_Tax_Status__c == 'Success' || kyc.KYC_Form_Tax_Status__c == 'Skipped') && kyc.Upload_Documents_Required__c == 'No'){
                // Tax Check need to be added
                if(kyc.Upload_Documents_Required__c == 'No'  && kyc.Document_FATCA_Declaration__c == false){
                    requestBody.put('subStage', 'PR_COMPLETED');
                    requestBody.put('blockDebitCards',False);
                    requestBody.put('blockCreditCards',False);
                    requestBody.put('blockAccountDebits',False);
                    requestBody.put('blockCustomerAccounts',False);   
                    requestBody.put('blockAppAccess',False); 
                }else if(kyc.Upload_Documents_Required__c == 'No' && kyc.Document_FATCA_Declaration__c == true ){ // Tax Check need to be added
                    stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                            FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c = 'Pending Upload Documents' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                    System.debug('Custom Meta-Data Stage Value:'+stage);
                    requestBody.put('kycUploadDocumentsStatus', 'PENDING');
                    requestBody.put('subStage',stage);
                    requestBody.put('blockDebitCards', kyc.Block_Debit_Cards__c);
                    requestBody.put('blockCreditCards', kyc.Block_Credit_Cards__c);
                    requestBody.put('blockAccountDebits',kyc.Block_Account_Debits__c);
                    requestBody.put('blockCustomerAccounts',kyc.Block_Account_Debits__c);
                    requestBody.put('blockAppAccess',kyc.Block_App_Access__c);
                    KYCVerificationService.applyUploadDocumentSettings(kyc, requestBody);
                    
                }
            }
            //////////////////////////////////////////////////////////// ID&V REQUIRED = NO, KYC  KYC TAX ONLY - SUCCESS/SKIPPED AND NO UPLOAD DOCS ////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////// NO ID&V REQUIRED, NO KYC FORM/TAX AND UPLOAD DOCS=Yes- INPROGRESS//////////////////////////////////////////////////////////////
            else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'No' && kyc.Upload_Documents_Required__c == 'Yes' && (kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped')){
                stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c='Pending Upload Documents' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                requestBody.put('subStage',stage);
                KYCVerificationService.applyUploadDocumentSettings(kyc, requestBody);
            }
            ////////////////////////////////////////////////////////////// NO ID&V REQUIRED, NO KYC FORM/TAX AND UPLOAD DOCS=Yes- INPROGRESS//////////////////////////////////////////////////////////////
            //////////////////////////////////////////////////////////////// ID&V REQUIRED = NO, KYC FORM =NO UPLOAD DOCS=YES - SUCCESS //////////////////////////////////////////////////////////
            else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'No' && kyc.Upload_Documents_Required__c == 'Yes' && (kyc.KYC_Upload_Document_Status__c == 'Success' && kyc.KYC_Verification_Result__c!='Documents Completed')){
                stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c='In-Progress' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                requestBody.put('subStage',stage);
                 requestBody.put('blockDebitCards', kyc.Block_Debit_Cards__c);
                 requestBody.put('blockCreditCards', kyc.Block_Credit_Cards__c);
                 requestBody.put('blockAccountDebits',kyc.Block_Account_Debits__c);
                 requestBody.put('blockCustomerAccounts',kyc.Block_Account_Debits__c);
                 requestBody.put('blockAppAccess',kyc.Block_App_Access__c);
            } 
            ////////////////////////////////////////////////////////////// ID&V REQUIRED = NO, KYC FORM =NO UPLOAD DOCS=YES - SUCCESS/SKIPPED //////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////// ID&V REQUIRED = NO, KYC FORM =NO UPLOAD DOCS=YES - SUCCESS/SKIPPED //////////////////////////////////////////////////////////
            else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'No' && kyc.Upload_Documents_Required__c == 'Yes' && (kyc.KYC_Upload_Document_Status__c == 'Skipped' || kyc.KYC_Verification_Result__c=='Documents Completed')){
                requestBody.put('subStage', 'PR_COMPLETED');
                requestBody.put('blockDebitCards',False);
                requestBody.put('blockCreditCards',False);
                requestBody.put('blockAccountDebits',False);
                requestBody.put('blockCustomerAccounts',False);   
                requestBody.put('blockAppAccess',False); 
            } 
            ////////////////////////////////////////////////////////////// ID&V REQUIRED = NO, KYC FORM =NO UPLOAD DOCS=YES - SUCCESS/SKIPPED //////////////////////////////////////////////////////////
            ///////////////////////////////////////////////////////////// FULL KYC FORM WITH ID&V REQUIRED = YES AND UPLOAD DOCS = YES/NO ////////////////////////////////////////////////////
            else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && (kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Form_Status__c != 'Success' && kyc.KYC_Form_Status__c != 'Skipped'){
                //  requestBody.put('subStage', 'PR_PENDING_FORM_S1');
                stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c='Pending KYC - Full Form' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                requestBody.put('subStage',stage);
            } else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && (kyc.KYC_Form_Status__c == 'Success' || kyc.KYC_Form_Status__c == 'Skipped') && kyc.Upload_Documents_Required__c == 'No'){
                if(kyc.Upload_Documents_Required__c == 'No' && kyc.Document_Proof_of_Address__c == false && kyc.Document_FATCA_Declaration__c == false){
                    requestBody.put('subStage', 'PR_COMPLETED');
                    requestBody.put('blockDebitCards',False);
                    requestBody.put('blockCreditCards',False);
                    requestBody.put('blockAccountDebits',False);
                    requestBody.put('blockCustomerAccounts',False);   
                    requestBody.put('blockAppAccess',False); 
                } else if(kyc.Upload_Documents_Required__c == 'No' && (kyc.Document_Proof_of_Address__c == true || kyc.Document_FATCA_Declaration__c == true)){ // Tax Check need to be added
                    stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                            FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c = 'Pending Upload Documents' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                    System.debug('Custom Meta-Data Stage Value:'+stage);
                    requestBody.put('kycUploadDocumentsStatus', 'PENDING');
                    requestBody.put('subStage',stage);
                    requestBody.put('blockDebitCards', kyc.Block_Debit_Cards__c);
                    requestBody.put('blockCreditCards', kyc.Block_Credit_Cards__c);
                    requestBody.put('blockAccountDebits',kyc.Block_Account_Debits__c);
                    requestBody.put('blockCustomerAccounts',kyc.Block_Account_Debits__c);
                    requestBody.put('blockAppAccess',kyc.Block_App_Access__c);
                    KYCVerificationService.applyUploadDocumentSettings(kyc, requestBody);
                    
                }
                
            }
            else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && (kyc.KYC_Form_Status__c == 'Success' || kyc.KYC_Form_Status__c == 'Skipped') && kyc.Upload_Documents_Required__c == 'Yes' && kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped'){
                //requestBody.put('subStage', 'PR_PENDING_UPLOAD_S1');
                stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c='Pending Upload Documents' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                requestBody.put('subStage',stage);
                 KYCVerificationService.applyUploadDocumentSettings(kyc, requestBody);
            }
            //UATNB-210495 Added a condition Documents Skipped
            else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && (kyc.KYC_Form_Status__c == 'Success' || kyc.KYC_Form_Status__c == 'Skipped') && kyc.Upload_Documents_Required__c == 'Yes' && (kyc.KYC_Upload_Document_Status__c == 'Success' && kyc.KYC_Verification_Result__c!='Documents Completed' && kyc.KYC_Verification_Result__c != 'Documents Skipped')){ //UATNB-210495
                //requestBody.put('subStage', 'PR_PENDING_UPLOAD_S1');
                
                //Commented by Jahangeer Mohammed as it is not picking the correct metadata record for UATNB-210254 ID&V required = Success, KYC Form Status = Success and Upload Document Status = Success it should pick PR_IN_PROGRESS_S1
                //UATNB-210254: Start // Fixed
                stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c='In-Progress' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                requestBody.put('subStage',stage);
                 requestBody.put('blockDebitCards', kyc.Block_Debit_Cards__c);
                    requestBody.put('blockCreditCards', kyc.Block_Credit_Cards__c);
                    requestBody.put('blockAccountDebits',kyc.Block_Account_Debits__c);
                    requestBody.put('blockCustomerAccounts',kyc.Block_Account_Debits__c);
                    requestBody.put('blockAppAccess',kyc.Block_App_Access__c);
                
                //UATNB-210254: END
            }else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && (kyc.KYC_Form_Status__c == 'Success' || kyc.KYC_Form_Status__c == 'Skipped')  && (kyc.KYC_Upload_Document_Status__c == 'Skipped'||(kyc.KYC_Verification_Result__c=='Documents Completed' && kyc.KYC_Upload_Document_Status__c == 'Success'))){
                
                requestBody.put('subStage','PR_COMPLETED');
                requestBody.put('blockDebitCards',False);
                requestBody.put('blockCreditCards',False);
                requestBody.put('blockAccountDebits',False);
                requestBody.put('blockCustomerAccounts',False);   
                requestBody.put('blockAppAccess',False); 
            }else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && (kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Form_Status__c != 'Success' && kyc.KYC_Form_Status__c != 'Skipped'){
                //  requestBody.put('subStage', 'PR_PENDING_FORM_S1');
                stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c='Pending KYC - Full Form' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                requestBody.put('subStage',stage);
            }
            else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && (kyc.KYC_Form_Status__c == 'Success' || kyc.KYC_Form_Status__c == 'Skipped')&& kyc.Upload_Documents_Required__c == 'Yes' && kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped'){
                //requestBody.put('subStage', 'PR_PENDING_UPLOAD_S1');
                stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c='Pending Upload Documents' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                requestBody.put('subStage',stage);
            }
            else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && (kyc.KYC_Form_Status__c == 'Success' || kyc.KYC_Form_Status__c == 'Skipped')&& kyc.Upload_Documents_Required__c == 'Yes' && (kyc.KYC_Upload_Document_Status__c == 'Success' && kyc.KYC_Verification_Result__c!='Documents Completed')){
                stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c='In-Progress' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                requestBody.put('subStage',stage);
                 requestBody.put('blockDebitCards', kyc.Block_Debit_Cards__c);
                    requestBody.put('blockCreditCards', kyc.Block_Credit_Cards__c);
                    requestBody.put('blockAccountDebits',kyc.Block_Account_Debits__c);
                    requestBody.put('blockCustomerAccounts',kyc.Block_Account_Debits__c);
                    requestBody.put('blockAppAccess',kyc.Block_App_Access__c);
            }else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && (kyc.KYC_Form_Status__c == 'Success' || kyc.KYC_Form_Status__c == 'Skipped')  && (kyc.KYC_Upload_Document_Status__c == 'Skipped'||(kyc.KYC_Verification_Result__c=='Documents Completed' && kyc.KYC_Upload_Document_Status__c == 'Success'))){
                requestBody.put('subStage','PR_COMPLETED');
                requestBody.put('blockDebitCards',False);
                requestBody.put('blockCreditCards',False);
                requestBody.put('blockAccountDebits',False);
                requestBody.put('blockCustomerAccounts',False);   
                requestBody.put('blockAppAccess',False); 
            }  
            ///////////////////////////////////////////////////////////// FULL KYC FORM WITH ID&V REQUIRED = YES AND UPLOAD DOCS = YES/NO ////////////////////////////////////////////////////
            ///////////////////////////////////////////////////////////// TAX KYC FORM WITH ID&V REQUIRED = YES AND UPLOAD DOCS = YES/NO ////////////////////////////////////////////////////
            else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && (kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Form_Tax_Status__c != 'Success' && kyc.KYC_Form_Tax_Status__c != 'Skipped'){
                //  requestBody.put('subStage', 'PR_PENDING_FORM_S1');
                stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c='Pending KYC - Tax Only' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                requestBody.put('subStage',stage);
            } else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && (kyc.KYC_Form_Tax_Status__c == 'Success' || kyc.KYC_Form_Tax_Status__c == 'Skipped') && kyc.Upload_Documents_Required__c == 'No'){
                // Tax Check need to be added
                if(kyc.Upload_Documents_Required__c == 'No'  && kyc.Document_FATCA_Declaration__c == false){
                    requestBody.put('subStage', 'PR_COMPLETED');
                    requestBody.put('blockDebitCards',False);
                    requestBody.put('blockCreditCards',False);
                    requestBody.put('blockAccountDebits',False);
                    requestBody.put('blockCustomerAccounts',False);   
                    requestBody.put('blockAppAccess',False); 
                }else if(kyc.Upload_Documents_Required__c == 'No' && kyc.Document_FATCA_Declaration__c == true ){ // Tax Check need to be added
                    stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                            FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c = 'Pending Upload Documents' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                    System.debug('Custom Meta-Data Stage Value:'+stage);
                    requestBody.put('kycUploadDocumentsStatus', 'PENDING');
                    requestBody.put('subStage',stage);
                    requestBody.put('blockDebitCards', kyc.Block_Debit_Cards__c);
                    requestBody.put('blockCreditCards', kyc.Block_Credit_Cards__c);
                    requestBody.put('blockAccountDebits',kyc.Block_Account_Debits__c);
                    requestBody.put('blockCustomerAccounts',kyc.Block_Account_Debits__c);
                    requestBody.put('blockAppAccess',kyc.Block_App_Access__c);
                    KYCVerificationService.applyUploadDocumentSettings(kyc, requestBody);
                    
                }
            }
            else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && (kyc.KYC_Form_Tax_Status__c == 'Success' || kyc.KYC_Form_Tax_Status__c == 'Skipped')&& kyc.Upload_Documents_Required__c == 'Yes' && kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped'){
                //requestBody.put('subStage', 'PR_PENDING_UPLOAD_S1');
                stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c='Pending Upload Documents' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                requestBody.put('subStage',stage);
                 KYCVerificationService.applyUploadDocumentSettings(kyc, requestBody);
            }else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && (kyc.KYC_Form_Tax_Status__c == 'Success' || kyc.KYC_Form_Tax_Status__c == 'Skipped')&& kyc.Upload_Documents_Required__c == 'Yes' && (kyc.KYC_Upload_Document_Status__c == 'Success' && kyc.KYC_Verification_Result__c!='Documents Completed')){
                //requestBody.put('subStage', 'PR_PENDING_UPLOAD_S1');
                
                //Commented by Jahangeer Mohammed as it is not picking the correct metadata record for UATNB-210254 ID&V required = Success, KYC Form Status = Success and Upload Document Status = Success it should pick PR_IN_PROGRESS_S1
                //UATNB-210254: Start // Fixed
                stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c='In-Progress' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                requestBody.put('subStage',stage);
                 requestBody.put('blockDebitCards', kyc.Block_Debit_Cards__c);
                    requestBody.put('blockCreditCards', kyc.Block_Credit_Cards__c);
                    requestBody.put('blockAccountDebits',kyc.Block_Account_Debits__c);
                    requestBody.put('blockCustomerAccounts',kyc.Block_Account_Debits__c);
                    requestBody.put('blockAppAccess',kyc.Block_App_Access__c);
                //UATNB-210254: END
            }else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && (kyc.KYC_Form_Tax_Status__c == 'Success' || kyc.KYC_Form_Tax_Status__c == 'Skipped')  && (kyc.KYC_Upload_Document_Status__c == 'Skipped'||(kyc.KYC_Verification_Result__c=='Documents Completed' && kyc.KYC_Upload_Document_Status__c == 'Success'))){
                requestBody.put('subStage','PR_COMPLETED');
                requestBody.put('blockDebitCards',False);
                requestBody.put('blockCreditCards',False);
                requestBody.put('blockAccountDebits',False);
                requestBody.put('blockCustomerAccounts',False);   
                requestBody.put('blockAppAccess',False); 
            }else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && (kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Form_Tax_Status__c != 'Success' && kyc.KYC_Form_Tax_Status__c != 'Skipped'){
                //  requestBody.put('subStage', 'PR_PENDING_FORM_S1');
                stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c='Pending KYC - Tax Only' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                requestBody.put('subStage',stage);
            }
            else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && (kyc.KYC_Form_Tax_Status__c == 'Success' || kyc.KYC_Form_Tax_Status__c == 'Skipped')&& kyc.Upload_Documents_Required__c == 'Yes' && kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped'){
                //requestBody.put('subStage', 'PR_PENDING_UPLOAD_S1');
                stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c='Pending Upload Documents' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                requestBody.put('subStage',stage);
                 KYCVerificationService.applyUploadDocumentSettings(kyc, requestBody);
            }else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && (kyc.KYC_Form_Tax_Status__c == 'Success' || kyc.KYC_Form_Tax_Status__c == 'Skipped')&& kyc.Upload_Documents_Required__c == 'Yes' && (kyc.KYC_Upload_Document_Status__c == 'Success' && kyc.KYC_Verification_Result__c!='Documents Completed')){
                
                stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c='In-Progress' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                requestBody.put('subStage',stage);
                 requestBody.put('blockDebitCards', kyc.Block_Debit_Cards__c);
                    requestBody.put('blockCreditCards', kyc.Block_Credit_Cards__c);
                    requestBody.put('blockAccountDebits',kyc.Block_Account_Debits__c);
                    requestBody.put('blockCustomerAccounts',kyc.Block_Account_Debits__c);
                    requestBody.put('blockAppAccess',kyc.Block_App_Access__c);
            }else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && (kyc.KYC_Form_Tax_Status__c == 'Success' || kyc.KYC_Form_Tax_Status__c == 'Skipped')  && (kyc.KYC_Upload_Document_Status__c == 'Skipped'||(kyc.KYC_Verification_Result__c=='Documents Completed' && kyc.KYC_Upload_Document_Status__c == 'Success'))){
                requestBody.put('subStage','PR_COMPLETED');
                requestBody.put('blockDebitCards',False);
                requestBody.put('blockCreditCards',False);
                requestBody.put('blockAccountDebits',False);
                requestBody.put('blockCustomerAccounts',False);   
                requestBody.put('blockAppAccess',False); 
            } 
            ///////////////////////////////////////////////////////////// TAX KYC FORM WITH ID&V REQUIRED = YES AND UPLOAD DOCS = YES/NO ////////////////////////////////////////////////////
            ///////////////////////////////////////////////////////////// ID&V REQUIRED = YES AND UPLOAD DOCS = YES/NO AND KYC FORM NO////////////////////////////////////////////////////
            else if(kyc.ID_V_Required__c == 'Yes'&& (kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.Review_Personal_Information_Required__c == 'No' && kyc.Upload_Documents_Required__c=='Yes' && (kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped')){
                stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND  Sub_Status__c='Pending Upload Documents' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                requestBody.put('subStage',stage);
                 KYCVerificationService.applyUploadDocumentSettings(kyc, requestBody);
                //   requestBody.put('subStage', 'PR_COMPLETED');
            }
            else if(kyc.ID_V_Required__c == 'Yes' && (kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.Review_Personal_Information_Required__c == 'No' && kyc.Upload_Documents_Required__c=='Yes' && kyc.KYC_Upload_Document_Status__c == 'Success' && kyc.KYC_Verification_Result__c!='Documents Completed'){
                stage= [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Stage__c=:Kyc.Overdue_Stage__c AND Sub_Status__c='In-Progress' AND Overdue_Handling__c=:kyc.Overdue_Handling__c].API_Status__c;
                requestBody.put('subStage',stage);
                 requestBody.put('blockDebitCards', kyc.Block_Debit_Cards__c);
                    requestBody.put('blockCreditCards', kyc.Block_Credit_Cards__c);
                    requestBody.put('blockAccountDebits',kyc.Block_Account_Debits__c);
                    requestBody.put('blockCustomerAccounts',kyc.Block_Account_Debits__c);
                    requestBody.put('blockAppAccess',kyc.Block_App_Access__c);
            }else if(kyc.ID_V_Required__c == 'Yes' && (kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.Review_Personal_Information_Required__c == 'No' && kyc.Upload_Documents_Required__c=='Yes' && ( kyc.KYC_Upload_Document_Status__c == 'Skipped' || kyc.KYC_Verification_Result__c=='Documents Completed')){
                requestBody.put('subStage', 'PR_COMPLETED');
                requestBody.put('blockDebitCards',False);
                requestBody.put('blockCreditCards',False);
                requestBody.put('blockAccountDebits',False);
                requestBody.put('blockCustomerAccounts',False);   
                requestBody.put('blockAppAccess',False); 
            }
        }   
        /////////////////////////////////////////////////////////////// NO ID&V REQUIRED, NO KYC FORM/TAX AND UPLOAD DOCS=Yes //////////////////////////////////////////////////////////
        
        /////////////////////////////////////////////////////////////////////// END: KYC Periodic Review Logic Case Update /////////////////////////////////////////////////////////////
        
        System.debug('Request Body Map:'+requestBody);
        return requestBody;
    }
    //Apply Status Updates On Creation
    public static void updateKycStatusCreation(KYC_Verification__c kyc){
        if(kyc.Type__c == 'KYC_PERIODIC_REVIEW'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName,API_Status__c, Overdue_Stage__c,Overdue_Handling__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Sub_Status__c = :kyc.sub_status__c AND Overdue_Stage__c =: kyc.Overdue_Stage__c AND Overdue_Handling__c=: kyc.Overdue_Handling__c LIMIT 1];
            System.debug('settings##'+settings[0]);
            if(settings[0].Overdue_Handling__c == 'Level 3 - App (Nudges & Splash), Notifications & Restrictions' && settings[0].Overdue_Stage__c == 'Stage 1 – No Restrictions'){
                kyc.API_Status__c = settings[0].API_Status__c;
                kyc.Notification_L3_S1_0days__c=true;
            }
            else if(settings[0].Overdue_Handling__c == 'Level 3 - App (Nudges & Splash), Notifications & Restrictions' && settings[0].Overdue_Stage__c == 'Stage 2 – Block Debit Cards'){
                kyc.API_Status__c = settings[0].API_Status__c;
                kyc.Block_Debit_Cards__c = settings[0].Block_Debit_Card__c;
                kyc.Notification_L3_S2_0_Days__c=true;
            }
            else if(settings[0].Overdue_Handling__c == 'Level 3 - App (Nudges & Splash), Notifications & Restrictions' && settings[0].Overdue_Stage__c == 'Stage 3 – Block Debit Cards & Credit Cards'){
                kyc.API_Status__c = settings[0].API_Status__c;
                kyc.Block_Debit_Cards__c = settings[0].Block_Debit_Card__c;
                kyc.Block_Credit_Cards__c = settings[0].Block_Credit_Cards__c;
                kyc.Block_Account_Debits__c = settings[0].Account_Debits_App_Access__c;
                kyc.Notification_L3_S3_0_Days__c=true;
            }
            else if(settings[0].Overdue_Handling__c == 'Level 3 - App (Nudges & Splash), Notifications & Restrictions' && settings[0].Overdue_Stage__c == 'Stage 4 – Block Debit Cards, Credit Cards, Account Debits & App Access'){
                kyc.API_Status__c = settings[0].API_Status__c;
                kyc.Block_Debit_Cards__c = settings[0].Block_Debit_Card__c;
                kyc.Block_Credit_Cards__c = settings[0].Block_Credit_Cards__c;
                kyc.Block_Account_Debits__c = settings[0].Account_Debits_App_Access__c;
                kyc.Block_App_Access__c = settings[0].Block_App_Access__c;
                kyc.Notification_L3_S4__c=true;
            }
            else if(settings[0].Overdue_Handling__c == 'Level 1 - App (Nudges)' || settings[0].Overdue_Handling__c == 'Level 2 - App (Nudges) & Notifications'){
                kyc.API_Status__c = settings[0].API_Status__c;
                kyc.Notification_L2_0_days__c=true;
            }
            if(kyc.Overdue_Stage__c !='Stage 4 – Block Debit Cards, Credit Cards, Account Debits & App Access'){
                //UATNB-210204: Start
                if(kyc.Overdue_Handling__c != 'Level 1 - App (Nudges)'){
                    kyc.Next_Notification_Date__c=System.Today().addDays(15); 
                }
                //kyc.Next_Notification_Date__c=System.Today().addDays(15);
                //UATNB-210204: END
                //kyc.No_of_days__c=15;
            }
        }
        else if(kyc.Type__c == 'KYC_SUSPECTED_IDENTITY_FRAUD' && kyc.Overdue_Handling__c == 'Level 3 - App (Nudges & Splash), Notifications & Restrictions' && kyc.Overdue_Stage__c == 'Stage 4 – Block Debit Cards, Credit Cards, Account Debits & App Access'){
            
            List<KYC_Suspect_Identify_Fraud__mdt> Identifysettings = [Select ID_V_Required__c,Type__c,Sub_Status__c,CRM_Stage__c,Block_Debit_Cards__c,Block_Credit_Cards__c,Block_App_Access__c,Block_Account_Debits__c,API_Status__c From KYC_Suspect_Identify_Fraud__mdt where Block_Debit_Cards__c=:kyc.Block_Debit_Cards__c AND Block_Credit_Cards__c=:kyc.Block_Credit_Cards__c AND Block_App_Access__c=:kyc.Block_App_Access__c And Block_Account_Debits__c=:kyc.Block_Account_Debits__c LIMIT 1];
            kyc.Block_Debit_Cards__c = Identifysettings[0].Block_Debit_Cards__c;
            kyc.Block_Credit_Cards__c = Identifysettings[0].Block_Credit_Cards__c;
            kyc.Block_Account_Debits__c = Identifysettings[0].Block_Account_Debits__c;
            kyc.Block_App_Access__c = Identifysettings[0].Block_App_Access__c;
        }
        
        
    }
    //Apply Status Updates On Update
    public static void updateKycStatusUpdate(KYC_Verification__c kyc){
        
        if(kyc.Type__c == 'KYC_PERIODIC_REVIEW'){
            if(kyc.ID_V_Status__c == 'In-Progress'){// Request Pending with IDV -  Based on duration overduestage alone update
                List<KYC_Stage_API_Status_Mapping__mdt> settings = [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                                                                    FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Sub_Status__c = :kyc.sub_status__c AND Overdue_Stage__c =: kyc.Overdue_Stage__c AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1];
                kyc.API_Status__c = settings[0].API_Status__c;
                kyc.Block_Debit_Cards__c = settings[0].Block_Debit_Card__c;
                kyc.Block_Credit_Cards__c = settings[0].Block_Credit_Cards__c;
                kyc.Block_Account_Debits__c = settings[0].Account_Debits_App_Access__c;
                kyc.Block_App_Access__c = settings[0].Block_App_Access__c;
            }
            // In case of IDV only request - After successful IDV it will status updated to closed - doesn't required review
            else if((kyc.ID_V_Status__c == 'Success'||kyc.ID_V_Status__c == 'Skipped') && kyc.Review_Personal_Information_Required__c == 'No' && kyc.Upload_Documents_Required__c == 'No'){
                kyc.CRM_Stage__c = 'PR_COMPLETED';
                kyc.API_Status__c = 'PR_COMPLETED';
                kyc.Sub_Status__c = 'Completed';
                kyc.Waiting_Customer_Feedback__c=false;
                kyc.Status__c='Closed';
            }
            else if(/*kyc.ID_V_Required__c == 'No' &&*/ kyc.Review_Personal_Information_Required__c =='Yes - Full KYC Form' && kyc.KYC_Form_Status__c=='Success' && kyc.Upload_Documents_Required__c == 'No'){
                if(kyc.Upload_Documents_Required__c == 'No' && (kyc.Document_Proof_of_Address__c == true || kyc.Document_FATCA_Declaration__c == true)){
                    List<KYC_Stage_API_Status_Mapping__mdt> settings = [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                                                                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Sub_Status__c ='Pending Upload Documents' AND Overdue_Stage__c =: kyc.Overdue_Stage__c AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1];
                    kyc.CRM_Stage__c = 'PR_PENDING_UPLOAD';
                    kyc.API_Status__c = settings[0].API_Status__c;
                    kyc.Sub_Status__c = 'Pending Upload Documents';
                    kyc.KYC_Upload_Document_Status__c = 'In-Progress';  //Scenario: ID&V Required = No, PIR = Yes and Upload Docs = No  
                    kyc.KYC_Verification_Result__c = 'Documents Pending';
                    kyc.Upload_Documents_Required__c = 'Yes'; 
                }
                else if(kyc.Upload_Documents_Required__c == 'No' && kyc.Document_Proof_of_Address__c == false && kyc.Document_FATCA_Declaration__c == false){
                    kyc.CRM_Stage__c = 'PR_COMPLETED';
                    kyc.API_Status__c = 'PR_COMPLETED';
                    kyc.Sub_Status__c = 'Completed';
                    kyc.Waiting_Customer_Feedback__c=false;
                    kyc.KYC_Verification_Result__c = 'KYC Form Completed';
                    kyc.Status__c='Closed';
                }
                
            } 
            else if(/*kyc.ID_V_Required__c == 'No' &&*/ kyc.Review_Personal_Information_Required__c =='Yes - Only Tax Declaration' && kyc.KYC_Form_Tax_Status__c=='Success' && kyc.Upload_Documents_Required__c == 'No'){
                if(kyc.Upload_Documents_Required__c == 'No' && (kyc.Document_Proof_of_Address__c == true || kyc.Document_FATCA_Declaration__c == true)){
                    List<KYC_Stage_API_Status_Mapping__mdt> settings = [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                                                                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Sub_Status__c ='Pending Upload Documents' AND Overdue_Stage__c =: kyc.Overdue_Stage__c AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1];
                    kyc.CRM_Stage__c = 'PR_PENDING_UPLOAD';
                    kyc.API_Status__c = settings[0].API_Status__c;
                    kyc.Sub_Status__c = 'Pending Upload Documents';
                    kyc.KYC_Upload_Document_Status__c = 'In-Progress';  //Scenario: ID&V Required = No, PIR = Yes and Upload Docs = No  
                    kyc.KYC_Verification_Result__c = 'Documents Pending';
                    kyc.Upload_Documents_Required__c = 'Yes'; 
                }
                else if(kyc.Upload_Documents_Required__c == 'No' && kyc.Document_Proof_of_Address__c == false && kyc.Document_FATCA_Declaration__c == false){
                    kyc.CRM_Stage__c = 'PR_COMPLETED';
                    kyc.API_Status__c = 'PR_COMPLETED';
                    kyc.Sub_Status__c = 'Completed';
                    kyc.Waiting_Customer_Feedback__c=false;
                    kyc.KYC_Verification_Result__c = 'KYC Form Completed';
                    kyc.Status__c='Closed';
                }
            }        
            else if((kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Form_Status__c != 'Success' && kyc.KYC_Form_Status__c != 'Skipped' && 
                    (kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' ) && kyc.KYC_Upload_Document_Status__c != 'Success'){
                        
                        kyc.CRM_Stage__c = 'PR_PENDING_FORM';
                        List<KYC_Stage_API_Status_Mapping__mdt> settings = [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                                                                            FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Sub_Status__c ='Pending KYC - Full Form' AND Overdue_Stage__c =: kyc.Overdue_Stage__c AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1];
                        kyc.API_Status__c = settings[0].API_Status__c;
                        kyc.Block_Debit_Cards__c = settings[0].Block_Debit_Card__c;
                        kyc.Block_Credit_Cards__c = settings[0].Block_Credit_Cards__c;
                        kyc.Block_Account_Debits__c = settings[0].Account_Debits_App_Access__c;
                        kyc.Block_App_Access__c = settings[0].Block_App_Access__c;
                        // kyc.API_Status__c = [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        // FROM KYC_Stage_API_Status_Mapping__mdt WHERE Sub_Status__c = 'Pending KYC - Full Form' AND Overdue_Stage__c =: kyc.Overdue_Stage__c AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1].API_Status__c;
                        kyc.Sub_Status__c = 'Pending KYC - Full Form';
                        kyc.KYC_Form_Status__c = 'In-Progress';
                        kyc.Waiting_Customer_Feedback__c=true;
                        kyc.KYC_Verification_Result__c='KYC Form Pending';
                    }
            else if((kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Form_Tax_Status__c != 'Success' && kyc.KYC_Form_Tax_Status__c != 'Skipped' && 
                    kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration'  && kyc.KYC_Upload_Document_Status__c != 'Success'){
                        
                        kyc.CRM_Stage__c = 'PR_PENDING_TAX';
                        List<KYC_Stage_API_Status_Mapping__mdt> settings = [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                                                                            FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Sub_Status__c ='Pending KYC - Tax Only' AND Overdue_Stage__c =: kyc.Overdue_Stage__c AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1];
                        kyc.API_Status__c = settings[0].API_Status__c;
                        kyc.Block_Debit_Cards__c = settings[0].Block_Debit_Card__c;
                        kyc.Block_Credit_Cards__c = settings[0].Block_Credit_Cards__c;
                        kyc.Block_Account_Debits__c = settings[0].Account_Debits_App_Access__c;
                        kyc.Block_App_Access__c = settings[0].Block_App_Access__c;
                        kyc.Waiting_Customer_Feedback__c=true;
                        // kyc.API_Status__c = [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                        //  FROM KYC_Stage_API_Status_Mapping__mdt WHERE Sub_Status__c ='Pending KYC - Tax Only' AND Overdue_Stage__c =: kyc.Overdue_Stage__c AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1].API_Status__c;
                        kyc.Sub_Status__c = 'Pending KYC - Tax Only';
                        kyc.KYC_Form_Tax_Status__c = 'In-Progress';
                        kyc.KYC_Verification_Result__c='KYC Form Pending';
                    }    
            else if((kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.Review_Personal_Information_Required__c == 'No'  && kyc.Upload_Documents_Required__c == 'Yes' && (kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped')){            
                kyc.CRM_Stage__c = 'PR_PENDING_UPLOAD';
                List<KYC_Stage_API_Status_Mapping__mdt> settings = [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                                                                    FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Sub_Status__c ='Pending Upload Documents' AND Overdue_Stage__c =: kyc.Overdue_Stage__c AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1];
                kyc.API_Status__c = settings[0].API_Status__c;
                kyc.Block_Debit_Cards__c = settings[0].Block_Debit_Card__c;
                kyc.Block_Credit_Cards__c = settings[0].Block_Credit_Cards__c;
                kyc.Block_Account_Debits__c = settings[0].Account_Debits_App_Access__c;
                kyc.Block_App_Access__c = settings[0].Block_App_Access__c;
                // kyc.API_Status__c = [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                // FROM KYC_Stage_API_Status_Mapping__mdt WHERE Sub_Status__c ='Pending Upload Documents' AND Overdue_Stage__c =: kyc.Overdue_Stage__c AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1].API_Status__c;
                kyc.Sub_Status__c = 'Pending Upload Documents';
                kyc.KYC_Upload_Document_Status__c = 'In-Progress';
                kyc.Waiting_Customer_Feedback__c=true;
            }
            else if(kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && (kyc.KYC_Form_Status__c == 'Success' || kyc.KYC_Form_Status__c == 'Skipped') && kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped'){
                if(kyc.Upload_Documents_Required__c == 'Yes'){
                    kyc.CRM_Stage__c = 'PR_PENDING_UPLOAD';
                    kyc.API_Status__c = [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                                         FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Sub_Status__c = 'Pending Upload Documents' AND Overdue_Stage__c =: kyc.Overdue_Stage__c AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1].API_Status__c;
                    kyc.Sub_Status__c = 'Pending Upload Documents';
                    kyc.KYC_Upload_Document_Status__c = 'In-Progress';
                    kyc.Waiting_Customer_Feedback__c=true;
                    kyc.KYC_Verification_Result__c = 'Documents Pending';
                }
                else if(kyc.Upload_Documents_Required__c == 'No'){
                    kyc.CRM_Stage__c = 'PR_IN_PROGRESS';
                    List<KYC_Stage_API_Status_Mapping__mdt> settings = [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                                                                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Sub_Status__c ='In-Progress' AND Overdue_Stage__c =: kyc.Overdue_Stage__c AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1];
                    kyc.API_Status__c = settings[0].API_Status__c;
                    kyc.Block_Debit_Cards__c = settings[0].Block_Debit_Card__c;
                    kyc.Block_Credit_Cards__c = settings[0].Block_Credit_Cards__c;
                    kyc.Block_Account_Debits__c = settings[0].Account_Debits_App_Access__c;
                    kyc.Block_App_Access__c = settings[0].Block_App_Access__c;
                    //  kyc.API_Status__c = [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                    //            FROM KYC_Stage_API_Status_Mapping__mdt WHERE Sub_Status__c ='In-Progress' AND Overdue_Stage__c =: kyc.Overdue_Stage__c AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1].API_Status__c;
                    kyc.Sub_Status__c = 'In-Progress';
                    kyc.KYC_Upload_Document_Status__c = 'Skipped';
                    kyc.Waiting_Customer_Feedback__c=false;
                }
            }
            else if(kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && (kyc.KYC_Form_Tax_Status__c == 'Success' || kyc.KYC_Form_Tax_Status__c == 'Skipped') && (kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped')){
                if(kyc.Upload_Documents_Required__c == 'Yes'){
                    kyc.CRM_Stage__c = 'PR_PENDING_UPLOAD';
                    List<KYC_Stage_API_Status_Mapping__mdt> settings = [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                                                                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Sub_Status__c ='Pending Upload Documents' AND Overdue_Stage__c =: kyc.Overdue_Stage__c AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1];
                    kyc.API_Status__c = settings[0].API_Status__c;
                    kyc.Block_Debit_Cards__c = settings[0].Block_Debit_Card__c;
                    kyc.Block_Credit_Cards__c = settings[0].Block_Credit_Cards__c;
                    kyc.Block_Account_Debits__c = settings[0].Account_Debits_App_Access__c;
                    kyc.Block_App_Access__c = settings[0].Block_App_Access__c;
                    //     kyc.API_Status__c = [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                    //  FROM KYC_Stage_API_Status_Mapping__mdt WHERE Sub_Status__c = 'Pending Upload Documents' AND Overdue_Stage__c =: kyc.Overdue_Stage__c AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1].API_Status__c;
                    kyc.Sub_Status__c = 'Pending Upload Documents';
                    kyc.KYC_Upload_Document_Status__c = 'In-Progress';
                    kyc.Waiting_Customer_Feedback__c=false;
                    kyc.KYC_Verification_Result__c = 'Documents Pending';
                }
                else if(kyc.Upload_Documents_Required__c == 'No'){
                    kyc.CRM_Stage__c = 'PR_IN_PROGRESS';
                    List<KYC_Stage_API_Status_Mapping__mdt> settings = [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                                                                        FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Sub_Status__c ='In-Progress' AND Overdue_Stage__c =: kyc.Overdue_Stage__c AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1];
                    kyc.API_Status__c = settings[0].API_Status__c;
                    kyc.Block_Debit_Cards__c = settings[0].Block_Debit_Card__c;
                    kyc.Block_Credit_Cards__c = settings[0].Block_Credit_Cards__c;
                    kyc.Block_Account_Debits__c = settings[0].Account_Debits_App_Access__c;
                    kyc.Block_App_Access__c = settings[0].Block_App_Access__c;
                    //  kyc.API_Status__c = [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                    // FROM KYC_Stage_API_Status_Mapping__mdt WHERE Sub_Status__c = 'In-Progress' AND Overdue_Stage__c =: kyc.Overdue_Stage__c AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1].API_Status__c;
                    kyc.Sub_Status__c = 'In-Progress';
                    kyc.Waiting_Customer_Feedback__c=false;
                    kyc.KYC_Upload_Document_Status__c = 'Skipped';
                }
            }
            //  else if(kyc.KYC_Upload_Document_Status__c == 'Success' || kyc.KYC_Upload_Document_Status__c == 'Skipped'){
            else if(kyc.KYC_Upload_Document_Status__c == 'Success' && kyc.KYC_Verification_Result__c!='Documents Completed' ){
                List<KYC_Stage_API_Status_Mapping__mdt> settings = [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                                                                    FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Sub_Status__c ='In-Progress' AND Overdue_Stage__c =: kyc.Overdue_Stage__c AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1];
                kyc.API_Status__c = settings[0].API_Status__c;
                kyc.Block_Debit_Cards__c = settings[0].Block_Debit_Card__c;
                kyc.Block_Credit_Cards__c = settings[0].Block_Credit_Cards__c;
                kyc.Block_Account_Debits__c = settings[0].Account_Debits_App_Access__c;
                kyc.Block_App_Access__c = settings[0].Block_App_Access__c;
                kyc.CRM_Stage__c = 'PR_IN_PROGRESS';
                //  kyc.API_Status__c = [SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
                // FROM KYC_Stage_API_Status_Mapping__mdt WHERE Sub_Status__c ='In-Progress' AND Overdue_Stage__c =: kyc.Overdue_Stage__c AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1].API_Status__c;
                kyc.Sub_Status__c = 'In-Progress';
                kyc.KYC_Verification_Result__c='Documents Review';
            }
            else if(kyc.KYC_Upload_Document_Status__c == 'Skipped' || kyc.KYC_Verification_Result__c=='Documents Completed'){
                kyc.CRM_Stage__c = 'PR_COMPLETED';
                kyc.API_Status__c = 'PR_COMPLETED';
                kyc.Sub_Status__c = 'Completed';
                kyc.Waiting_Customer_Feedback__c=false;
                if(kyc.KYC_Upload_Document_Status__c == 'Skipped'){
                    kyc.KYC_Verification_Result__c = 'KYC Form Completed';
                }
                kyc.Status__c='Closed';
            }
            //UATNB-210254: Start Added a condition Document Review and Documents Returned in if condition
            if((kyc.Overdue_Handling__c !='Level 1 - App (Nudges)') && (kyc.KYC_Verification_Result__c != 'Documents Review') /*&& (kyc.KYC_Verification_Result__c != 'Documents Returned')*/){
                
                List<KYCNotificationService.KycNotificationData>ksd= New List<KYCNotificationService.KycNotificationData>();
                KYCNotificationService.KycNotificationData Ks= New KYCNotificationService.KycNotificationData();
                ks.Kyccase=kyc;
                ks.noofdays=(kyc.Sub_Status__c == 'Completed')?'0':String.valueOf(kyc.No_of_days__c);
                ksd.add(ks);
                System.debug('Documents Returned##'+ kyc.KYC_Verification_Result__c);
                system.debug('Document_Resend__c'+kyc.Document_Resend__c);
                 if(kyc.Sub_Status__c == 'Completed' || kyc.Document_Resend__c){
                     if(!Test.isRunningTest()) {
                            KYCNotificationService.KycNotificationSetting(ksd);
                        } 
                 }else{
                     if(kyc.Overdue_Handling__c=='Level 2 - App (Nudges) & Notifications' && kyc.No_of_days__c==0 && !kyc.Notification_L2_0_days__c){
                     if(!Test.isRunningTest()) {
                            KYCNotificationService.KycNotificationSetting(ksd);
                        }
                    kyc.Notification_L2_0_days__c=true;
                }

                 if(kyc.Overdue_Handling__c=='Level 3 - App (Nudges & Splash), Notifications & Restrictions' && kyc.Overdue_Stage__c=='Stage 1 – No Restrictions' &&  kyc.No_of_days__c==0 && !kyc.Notification_L3_S1_0days__c){
                     if(!Test.isRunningTest()) {
                         KYCNotificationService.KycNotificationSetting(ksd);
                     }
                     
                     kyc.Notification_L3_S1_0days__c=true;
                } 
 
                    if(kyc.Overdue_Handling__c=='Level 3 - App (Nudges & Splash), Notifications & Restrictions' && kyc.Overdue_Stage__c=='Stage 2 – Block Debit Cards' &&  kyc.No_of_days__c==0 && !kyc.Notification_L3_S2_0_Days__c){
                        if(!Test.isRunningTest()) {
                            KYCNotificationService.KycNotificationSetting(ksd);
                        }
                        
                      kyc.Notification_L3_S2_0_Days__c=true;
                }
  
                     if(kyc.Overdue_Handling__c=='Level 3 - App (Nudges & Splash), Notifications & Restrictions' && kyc.Overdue_Stage__c=='Stage 3 – Block Debit Cards & Credit Cards' &&  kyc.No_of_days__c==0 && !kyc.Notification_L3_S3_0_Days__c){
                     if(!Test.isRunningTest()) {
                            KYCNotificationService.KycNotificationSetting(ksd);
                        }
                     kyc.Notification_L3_S3_0_Days__c=true;                      
                }
 
                     if(kyc.Overdue_Handling__c=='Level 3 - App (Nudges & Splash), Notifications & Restrictions' && kyc.Overdue_Stage__c=='Stage 4 – Block Debit Cards, Credit Cards, Account Debits & App Access' &&  kyc.No_of_days__c==0 && !kyc.Notification_L3_S4__c){
                     if(!Test.isRunningTest()) {
                            KYCNotificationService.KycNotificationSetting(ksd);
                        }
                     kyc.Notification_L3_S4__c=true; 
                }
               }
                
            }
            //UATNB-210254: END
        }else if(kyc.Type__c == 'KYC_SUSPECTED_IDENTITY_FRAUD'){
            if(kyc.ID_V_Required__c == 'Yes' && (kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped')){
                kyc.CRM_Stage__c = 'FRAUD_COMPLETED';
                kyc.API_Status__c = 'FRAUD_COMPLETED';
                kyc.Sub_Status__c = 'Completed';
                kyc.Waiting_Customer_Feedback__c=false;
                kyc.Status__c='Closed';
                kyc.KYC_Verification_Result__c =(kyc.ID_V_Status__c=='Success')?'ID&V Completed':'ID&V Skipped';
                kyc.Waiting_Customer_Feedback__c=false;
            }  if(kyc.ID_V_Required__c == 'Yes' && kyc.ID_V_Status__c == 'Pending'){
                kyc.Sub_Status__c = 'Pending ID&V';
                kyc.Waiting_Customer_Feedback__c=true;
                kyc.KYC_Verification_Result__c = 'ID&V Pending';
            }
            if(kyc.Overdue_Handling__c == 'Level 3 - App (Nudges & Splash), Notifications & Restrictions' && kyc.Overdue_Stage__c == 'Stage 4 – Block Debit Cards, Credit Cards, Account Debits & App Access'){
                List<KYCNotificationService.KycNotificationData>ksd= New List<KYCNotificationService.KycNotificationData>();
                KYCNotificationService.KycNotificationData Ks= New KYCNotificationService.KycNotificationData();
                ks.Kyccase=kyc;
                ks.noofdays=String.valueOf(kyc.No_of_days__c);
                ksd.add(ks);
                KYCNotificationService.KycNotificationSetting(ksd);
            }
            
        }
    }
    public static Map<String, Object> buildRequestBodyUpdateAPIStages(KYC_Verification__c kyc){
        Map<String, Object> requestBody = new Map<String, Object>{
            'caseId' => kyc.Id,
                'customerId' => kyc.Account_Name__r.CIF__pc,
                'status' => kyc.Status__c
                };
                    
                    List<KYC_Stage_API_Status_Mapping__mdt> settings; 
        if(kyc.ID_V_Required__c == 'Yes' && (kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' || kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration') && kyc.Upload_Documents_Required__c == 'Yes'){
            
            if(kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form'){
                settings = [SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,ID_V_Required__c,
                            Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c,Review_Personal_Information_Required__c,Upload_Documents_Required__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND Sub_Status__c =: kyc.Sub_Status__c 
                            AND ID_V_Status__c =: kyc.ID_V_Status__c AND KYC_Form_Status__c =: kyc.KYC_Form_Status__c AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c  AND API_Status__c =: kyc.API_Status__c LIMIT 1];
                
            }else if(kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration'){
                settings = [SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,ID_V_Required__c,
                            Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c,Review_Personal_Information_Required__c,Upload_Documents_Required__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND Sub_Status__c =: kyc.Sub_Status__c 
                            AND ID_V_Status__c =: kyc.ID_V_Status__c AND KYC_Form_Tax_Status__c =: kyc.KYC_Form_Tax_Status__c AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c  AND API_Status__c =: kyc.API_Status__c LIMIT 1];
                
            }
            
        }
        else{
            settings = [SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,ID_V_Required__c,
                        Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c,Review_Personal_Information_Required__c,Upload_Documents_Required__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND Sub_Status__c =: kyc.Sub_Status__c 
                        AND ID_V_Status__c =: kyc.ID_V_Status__c AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c  AND API_Status__c =: kyc.API_Status__c LIMIT 1];
        }
        if(!settings.isEmpty()){
                    System.debug('Fetching Custom MetaData Record In Update API Status Request Body from Flow:'+settings[0]);
                    requestBody.put('subStage', settings[0].API_Status__c);
                    generateRequestBody(requestBody, settings[0], kyc);
        }

        
        return requestBody;
    }
    public static void generateRequestBody(Map<String, Object> requestBody, KYC_Stage_API_Status_Mapping__mdt setting, KYC_Verification__c kyc){
        
        Map<String, Object> idvRefObj = new Map<String, Object>();
        Map<String, Object> taxRefObj = new Map<String, Object>();
        Map<String, Object> docRefObj = new Map<String, Object>();
        Map<String, Object> refObj = new Map<String, Object>(); 
        
        requestBody.put('idvStatus',APIStatusUpdate(setting.ID_V_Status__c));
        requestBody.put('idvContentReference',String.valueOf(idvRefObj));
        requestBody.put('kycVerificationType','KYC_PERIODIC_REVIEW');
        requestBody.put('kycFormStatus', APIStatusUpdate(setting.KYC_Form_Status__c));
        requestBody.put('kycFormReference', String.valueOf(refObj));
        requestBody.put('kycFormTaxStatus', APIStatusUpdate(setting.KYC_Form_Tax_Status__c));
        requestBody.put('kycFormTaxReference', String.valueOf(taxRefObj));
        requestBody.put('kycUploadDocumentsStatus', APIStatusUpdate(setting.KYC_Upload_Document_Status__c));
        requestBody.put('kycUploadDocumentsReference', String.valueOf(docRefObj));
        requestBody.put('blockDebitCards', setting.Block_Debit_Card__c);
        requestBody.put('blockCreditCards', setting.Block_Credit_Cards__c);
        requestBody.put('blockAccountDebits',setting.Account_Debits_App_Access__c);
        requestBody.put('blockCustomerAccounts',setting.Account_Debits_App_Access__c);
        requestBody.put('blockAppAccess',setting.Block_App_Access__c);
        KYCVerificationService.applyUploadDocumentSettings(kyc, requestBody);
        
    }
    public static void generateRequestBodyDocumentComplete(Map<String, Object> requestBody, KYC_Verification__c kyc){
        
        Map<String, Object> idvRefObj = new Map<String, Object>();
        Map<String, Object> taxRefObj = new Map<String, Object>();
        Map<String, Object> docRefObj = new Map<String, Object>();
        Map<String, Object> refObj = new Map<String, Object>(); 
        
        requestBody.put('idvStatus',APIStatusUpdate(kyc.ID_V_Status__c));
        requestBody.put('idvContentReference',String.valueOf(idvRefObj));
        requestBody.put('kycVerificationType','KYC_PERIODIC_REVIEW');
        requestBody.put('kycFormStatus', APIStatusUpdate(kyc.KYC_Form_Status__c));
        requestBody.put('kycFormReference', String.valueOf(refObj));
        requestBody.put('kycFormTaxStatus', APIStatusUpdate(kyc.KYC_Form_Tax_Status__c));
        requestBody.put('kycFormTaxReference', String.valueOf(taxRefObj));
        requestBody.put('kycUploadDocumentsStatus', APIStatusUpdate(kyc.KYC_Upload_Document_Status__c));
        requestBody.put('kycUploadDocumentsReference', String.valueOf(docRefObj));
        requestBody.put('blockDebitCards',false);
        requestBody.put('blockCreditCards', false);
        requestBody.put('blockAccountDebits',false);
        requestBody.put('blockCustomerAccounts',false);
        requestBody.put('blockAppAccess',false);
        KYCVerificationService.applyUploadDocumentSettings(kyc, requestBody);
        
    }
    public static void generateRequestBodyDocumentReturned(Map<String, Object> requestBody, KYC_Verification__c kyc){
        
        Map<String, Object> idvRefObj = new Map<String, Object>();
        Map<String, Object> taxRefObj = new Map<String, Object>();
        Map<String, Object> docRefObj = new Map<String, Object>();
        Map<String, Object> refObj = new Map<String, Object>(); 
        
        requestBody.put('idvStatus',APIStatusUpdate(kyc.ID_V_Status__c));
        requestBody.put('idvContentReference',String.valueOf(idvRefObj));
        requestBody.put('kycVerificationType','KYC_PERIODIC_REVIEW');
        requestBody.put('kycFormStatus', APIStatusUpdate(kyc.KYC_Form_Status__c));
        requestBody.put('kycFormReference', String.valueOf(refObj));
        requestBody.put('kycFormTaxStatus', APIStatusUpdate(kyc.KYC_Form_Tax_Status__c));
        requestBody.put('kycFormTaxReference', String.valueOf(taxRefObj));
        requestBody.put('kycUploadDocumentsStatus', APIStatusUpdate(kyc.KYC_Upload_Document_Status__c));
        requestBody.put('kycUploadDocumentsReference', String.valueOf(docRefObj));
        requestBody.put('blockDebitCards',kyc.Block_Debit_Cards__c);
        requestBody.put('blockCreditCards', kyc.Block_Credit_Cards__c);
        requestBody.put('blockAccountDebits',kyc.Block_Account_Debits__c);
        requestBody.put('blockCustomerAccounts',kyc.Block_Account_Debits__c);
        requestBody.put('blockAppAccess',kyc.Block_App_Access__c);
        KYCVerificationService.applyUploadDocumentSettings(kyc, requestBody);
        
    }
    public static Map<String, Object> buildRequestBodyUpdateOverdue(KYC_Verification__c kyc){
        Map<String, Object> requestBody = new Map<String, Object>{
            'caseId' => kyc.Id,
                'customerId' => kyc.Account_Name__r.CIF__pc,
                'status' => kyc.Status__c
                };
                    
                    if(kyc.KYC_Verification_Result__c == 'Documents Completed'){
                        List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                            SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                            Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND 
                            KYC_Verification_Result__c =: kyc.KYC_Verification_Result__c LIMIT 1];
                        
                        System.debug('Document Completed');
                        System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
                        requestBody.put('subStage', settings[0].API_Status__c); 
                        generateRequestBodyDocumentComplete(requestBody, kyc);
                        
                    }
        else if(kyc.KYC_Verification_Result__c == 'Documents Returned' && kyc.KYC_Upload_Document_Status__c != 'Success'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND API_Status__c =: kyc.API_Status__c AND
                KYC_Verification_Result__c =: kyc.KYC_Verification_Result__c LIMIT 1];
            if(!settings.isEmpty()){
                            System.debug('Document Returned');
            System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
            requestBody.put('subStage', settings[0].Next_API_Status__c); 
            generateRequestBodyDocumentReturned(requestBody, kyc);  
            }

        }
        
        else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && (kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Form_Status__c != 'Success' && kyc.KYC_Form_Status__c != 'Skipped' && kyc.Upload_Documents_Required__c == 'No'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND ID_V_Status__c =: kyc.ID_V_Status__c  
                AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c AND API_Status__c =: kyc.API_Status__c LIMIT 1];
            
            System.debug('ID&V Status Changes to Success and Enter into KYC Full Form');
            System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
            requestBody.put('subStage', settings[0].Next_API_Status__c);
            generateRequestBody(requestBody, settings[0], kyc);
        }
        else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && (kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Form_Tax_Status__c != 'Success' && kyc.KYC_Form_Tax_Status__c != 'Skipped' && kyc.Upload_Documents_Required__c == 'No'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND ID_V_Status__c =: kyc.ID_V_Status__c  
                AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c AND API_Status__c =: kyc.API_Status__c LIMIT 1];
            
            System.debug('ID&V Status Changes to Success and Enter into KYC TAX Form');
            System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
            requestBody.put('subStage', settings[0].Next_API_Status__c);
            generateRequestBody(requestBody, settings[0], kyc);
        }
        else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'No' && (kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped' && kyc.Upload_Documents_Required__c == 'Yes'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND ID_V_Status__c =: kyc.ID_V_Status__c  
                AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c AND API_Status__c =: kyc.API_Status__c LIMIT 1];
            
            System.debug('ID&V Status Changes to Success and Enter into Upload Docs Form');
            System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
            requestBody.put('subStage', settings[0].Next_API_Status__c);
            generateRequestBody(requestBody, settings[0], kyc);
        }
        else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && (kyc.KYC_Form_Status__c == 'Success' || kyc.KYC_Form_Status__c == 'Skipped') && kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped' && kyc.Upload_Documents_Required__c == 'Yes'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND KYC_Form_Status__c =: kyc.KYC_Form_Status__c  
                AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c AND API_Status__c =: kyc.API_Status__c LIMIT 1];
            
            System.debug('KYC Form Status Changes to Success and Enter into Upload Docs Form');
            System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
            requestBody.put('subStage', settings[0].Next_API_Status__c); 
            generateRequestBody(requestBody, settings[0], kyc);
        }
        else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && (kyc.KYC_Form_Tax_Status__c == 'Success' || kyc.KYC_Form_Tax_Status__c == 'Skipped') && kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped' && kyc.Upload_Documents_Required__c == 'Yes'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND KYC_Form_Tax_Status__c =: kyc.KYC_Form_Tax_Status__c  
                AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c AND API_Status__c =: kyc.API_Status__c LIMIT 1];
            
            System.debug('KYC Tax Form Status Changes to Success and Enter into Upload Docs Form');
            System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
            requestBody.put('subStage', settings[0].Next_API_Status__c); 
            generateRequestBody(requestBody, settings[0], kyc);
        }
        else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && (kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Form_Status__c != 'Success' && kyc.KYC_Form_Status__c != 'Skipped' && kyc.Upload_Documents_Required__c == 'Yes' && kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND ID_V_Status__c =: kyc.ID_V_Status__c  
                AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c AND API_Status__c =: kyc.API_Status__c LIMIT 1];
            
            System.debug('ID&V Status Changes to Success and Enter into KYC Full Form and Upload Document Required');
            System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
            requestBody.put('subStage', settings[0].Next_API_Status__c);
            generateRequestBody(requestBody, settings[0], kyc);
        }
        else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && (kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Form_Status__c == 'Success' && kyc.Upload_Documents_Required__c == 'Yes' && kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND KYC_Form_Status__c =: kyc.KYC_Form_Status__c  
                AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c AND API_Status__c =: kyc.API_Status__c LIMIT 1];
            
            System.debug('ID&V is Success and KYC Full Form changes to success and enter into Upload Document Required');
            System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
            requestBody.put('subStage', settings[0].Next_API_Status__c);
            generateRequestBody(requestBody, settings[0], kyc);
        }
        else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && (kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Form_Tax_Status__c != 'Success' && kyc.KYC_Form_Tax_Status__c != 'Skipped' && kyc.Upload_Documents_Required__c == 'Yes' && kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND ID_V_Status__c =: kyc.ID_V_Status__c  
                AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c AND API_Status__c =: kyc.API_Status__c LIMIT 1];
            
            System.debug('ID&V Status Changes to Success and Enter into KYC Tax Form and Upload Document Required');
            System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
            requestBody.put('subStage', settings[0].Next_API_Status__c);
            generateRequestBody(requestBody, settings[0], kyc);
        }
        else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && (kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Form_Tax_Status__c == 'Success' && kyc.Upload_Documents_Required__c == 'Yes' && kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND KYC_Form_Tax_Status__c =: kyc.KYC_Form_Tax_Status__c  
                AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c AND API_Status__c =: kyc.API_Status__c LIMIT 1];
            
            System.debug('ID&V is Success and KYC Tax Form changes to success and enter into Upload Document Required');
            System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
            requestBody.put('subStage', settings[0].Next_API_Status__c);
            generateRequestBody(requestBody, settings[0], kyc);
        }
        else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'No' && kyc.Upload_Documents_Required__c == 'No' && kyc.ID_V_Status__c == 'Success'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND ID_V_Status__c =: kyc.ID_V_Status__c  
                AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c LIMIT 1];
            
            System.debug('ID&V Status Changes to Success and No Other Stages Exist');
            System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
            requestBody.put('subStage', settings[0].API_Status__c); 
            generateRequestBody(requestBody, settings[0], kyc);
        }
        else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && kyc.Upload_Documents_Required__c == 'No' && kyc.KYC_Form_Status__c == 'Success'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND KYC_Form_Status__c =: kyc.KYC_Form_Status__c  
                AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c LIMIT 1];
            
            System.debug('KYC Full Form Changes to Success and No Other Stages Exist');
            System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
            requestBody.put('subStage', settings[0].API_Status__c); 
            generateRequestBody(requestBody, settings[0], kyc);
        }
        else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && kyc.Upload_Documents_Required__c == 'No' && kyc.KYC_Form_Tax_Status__c == 'Success'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND KYC_Form_Tax_Status__c =: kyc.KYC_Form_Tax_Status__c  
                AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c LIMIT 1];
            
            System.debug('KYC Tax Form Changes to Success and No Other Stages Exist');
            System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
            requestBody.put('subStage', settings[0].API_Status__c); 
            generateRequestBody(requestBody, settings[0], kyc);
        }
        else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'No' && kyc.Upload_Documents_Required__c == 'Yes' && kyc.KYC_Upload_Document_Status__c == 'Success'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND KYC_Upload_Document_Status__c =: kyc.KYC_Upload_Document_Status__c AND Overdue_Stage__c =: kyc.Overdue_Stage__c 
                AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c LIMIT 1];
            
            System.debug('Upload document Changes to Success and No Other Stages Exist');
            System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
            requestBody.put('subStage', settings[0].API_Status__c); 
            generateRequestBody(requestBody, settings[0], kyc);
        }
        else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && kyc.Upload_Documents_Required__c == 'No' && kyc.ID_V_Status__c == 'Success' && kyc.KYC_Form_Status__c == 'Success'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND ID_V_Status__c =: kyc.ID_V_Status__c AND KYC_Form_Status__c =: kyc.KYC_Form_Status__c
                AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c LIMIT 1];
            
            System.debug('ID&V Exist and KYC Form Changes to Success');
            System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
            requestBody.put('subStage', settings[0].API_Status__c); 
            generateRequestBody(requestBody, settings[0], kyc);
        }
        else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && kyc.Upload_Documents_Required__c == 'No' && kyc.ID_V_Status__c == 'Success' && kyc.KYC_Form_Tax_Status__c == 'Success'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND ID_V_Status__c =: kyc.ID_V_Status__c AND KYC_Form_Tax_Status__c =: kyc.KYC_Form_Tax_Status__c
                AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c LIMIT 1];
            
            System.debug('ID&V Exist and KYC Tax Form Changes to Success');
            System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
            requestBody.put('subStage', settings[0].API_Status__c); 
            generateRequestBody(requestBody, settings[0], kyc);
        }
        else if(kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'No' && kyc.Upload_Documents_Required__c == 'Yes' && kyc.ID_V_Status__c == 'Success' && kyc.KYC_Upload_Document_Status__c == 'Success'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND ID_V_Status__c =: kyc.ID_V_Status__c AND KYC_Upload_Document_Status__c =: kyc.KYC_Upload_Document_Status__c AND Overdue_Stage__c =: kyc.Overdue_Stage__c 
                AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c LIMIT 1];
            
            System.debug('ID&V Exist and Upload Doc Status Changes to Success');
            System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
            requestBody.put('subStage', settings[0].API_Status__c); 
            generateRequestBody(requestBody, settings[0], kyc);
        }
        else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && kyc.Upload_Documents_Required__c == 'Yes' && kyc.KYC_Form_Status__c == 'Success' && kyc.KYC_Upload_Document_Status__c == 'Success'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND KYC_Form_Status__c =: kyc.KYC_Form_Status__c AND KYC_Upload_Document_Status__c =: kyc.KYC_Upload_Document_Status__c AND Overdue_Stage__c =: kyc.Overdue_Stage__c 
                AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c LIMIT 1];
            
            System.debug('KYC Form Exist and Upload Doc Status Changes to Success');
            System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
            requestBody.put('subStage', settings[0].API_Status__c); 
            generateRequestBody(requestBody, settings[0], kyc);
        }
        else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && kyc.Upload_Documents_Required__c == 'Yes' && kyc.KYC_Form_Tax_Status__c == 'Success' && kyc.KYC_Upload_Document_Status__c == 'Success'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND KYC_Form_Tax_Status__c =: kyc.KYC_Form_Tax_Status__c AND KYC_Upload_Document_Status__c =: kyc.KYC_Upload_Document_Status__c AND Overdue_Stage__c =: kyc.Overdue_Stage__c 
                AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c LIMIT 1];
            
            System.debug('KYC Tax Exist and Upload Doc Status Changes to Success');
            System.debug('Fetching Custom MetaData Record In Update Overdue Stage Request Body:'+settings[0]);
            requestBody.put('subStage', settings[0].API_Status__c); 
            generateRequestBody(requestBody, settings[0], kyc);
        }
        
        
        return requestBody;
        
    }
    //Apply Status Updates On Update Overdue Stage
    public static void updateKycStatusUpdateOverdueStage(KYC_Verification__c kyc){
        if(kyc.KYC_Verification_Result__c == 'Documents Completed'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND 
                KYC_Verification_Result__c =: kyc.KYC_Verification_Result__c LIMIT 1];
            
            System.debug('Fetching Custom MetaData Record In Update record Overdue Stage:'+settings[0]);
            kyc.CRM_Stage__c = 'PR_COMPLETED';
            kyc.API_Status__c = 'PR_COMPLETED';
            kyc.Sub_Status__c = 'Completed';
            kyc.Status__c = 'Closed';  //Scenario: Back Office Team Clicks on Document Completed
            System.debug('Back Office Team Clicks on Document Completed');
            
        }
        else if(kyc.KYC_Verification_Result__c == 'Documents Returned' && kyc.KYC_Upload_Document_Status__c != 'Success'){
            List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                SELECT DeveloperName, API_Status__c,CRM_Stage__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND API_Status__c =: kyc.API_Status__c AND
                KYC_Verification_Result__c =: kyc.KYC_Verification_Result__c LIMIT 1];
            
            System.debug('Fetching Custom MetaData Record In Update record Overdue Stage:'+settings[0]);
            kyc.CRM_Stage__c = settings[0].CRM_Stage__c;
            kyc.API_Status__c = settings[0].Next_API_Status__c; //Scenario: Back Office Team Clicks on Document Returned
            //   kyc.Document_Resend__c=false;
            System.debug('Back Office Team Clicks on Document Returned');
            
        }
        else if((kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Form_Status__c != 'Success' && kyc.KYC_Form_Status__c != 'Skipped' && 
                kyc.ID_V_Required__c == 'Yes' && (kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' || kyc.Review_Personal_Information_Required__c == 'Default') && kyc.Upload_Documents_Required__c == 'No'){
                    
                    List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                        SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                        Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c,Next_Sub_Status__c,CRM_Stage__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND ID_V_Status__c =: kyc.ID_V_Status__c  
                        AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c AND API_Status__c =: kyc.API_Status__c LIMIT 1];
                    
                    System.debug('Fetching Custom MetaData Record In Update record Overdue Stage:'+settings[0]);
                    
                    kyc.CRM_Stage__c = settings[0].CRM_Stage__c;
                    kyc.API_Status__c = settings[0].Next_API_Status__c;
                    kyc.Sub_Status__c = settings[0].Next_Sub_Status__c;
                    kyc.KYC_Form_Status__c = settings[0].KYC_Form_Status__c;  //Scenario: ID&V Required = Yes, PIR = Yes(Full KYC Form) and Upload Docs = No
                }
        else if((kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Form_Tax_Status__c != 'Success' && kyc.KYC_Form_Tax_Status__c != 'Skipped' && 
                kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && kyc.Upload_Documents_Required__c == 'No'){
                    
                    List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                        SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                        Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c,Next_Sub_Status__c,CRM_Stage__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND ID_V_Status__c =: kyc.ID_V_Status__c  
                        AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c AND API_Status__c =: kyc.API_Status__c LIMIT 1];
                    
                    System.debug('Fetching Custom MetaData Record In Update record Overdue Stage:'+settings[0]);
                    
                    kyc.CRM_Stage__c = settings[0].CRM_Stage__c;
                    kyc.API_Status__c = settings[0].Next_API_Status__c;
                    kyc.Sub_Status__c = settings[0].Next_Sub_Status__c;
                    kyc.KYC_Form_Tax_Status__c = settings[0].KYC_Form_Tax_Status__c;  //Scenario: ID&V Required = Yes, PIR = KYC TAX Form and Upload Docs = No
                }
        else if((kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped' && 
                kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'No' && kyc.Upload_Documents_Required__c == 'Yes'){
                    
                    List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                        SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                        Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c,Next_Sub_Status__c,CRM_Stage__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND ID_V_Status__c =: kyc.ID_V_Status__c  
                        AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c AND API_Status__c =: kyc.API_Status__c LIMIT 1];
                    
                    System.debug('Fetching Custom MetaData Record In Update record Overdue Stage:'+settings[0]);
                    
                    kyc.CRM_Stage__c = settings[0].CRM_Stage__c;
                    kyc.API_Status__c = settings[0].Next_API_Status__c;
                    kyc.Sub_Status__c = settings[0].Next_Sub_Status__c;
                    // kyc.Document_Resend__c =false;
                    kyc.KYC_Upload_Document_Status__c = settings[0].KYC_Upload_Document_Status__c;  //Scenario: ID&V Required = Yes, PIR = No and Upload Docs = Yes
                }
        else if((kyc.KYC_Form_Status__c == 'Success' || kyc.KYC_Form_Status__c == 'Skipped') && kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped' && 
                kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && kyc.Upload_Documents_Required__c == 'Yes'){
                    
                    List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                        SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                        Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c,Next_Sub_Status__c,CRM_Stage__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND KYC_Form_Status__c =: kyc.KYC_Form_Status__c  
                        AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c AND API_Status__c =: kyc.API_Status__c LIMIT 1];
                    
                    
                    System.debug('Fetching Custom MetaData Record In Update record Overdue Stage:'+settings[0]);
                    
                    kyc.CRM_Stage__c = settings[0].CRM_Stage__c;
                    kyc.API_Status__c = settings[0].Next_API_Status__c;
                    kyc.Sub_Status__c = settings[0].Next_Sub_Status__c;
                    kyc.KYC_Upload_Document_Status__c = settings[0].KYC_Upload_Document_Status__c; //Scenario: ID&V Required = No, PIR = Full KYC Form and Upload Docs = Yes
                }
        else if((kyc.KYC_Form_Tax_Status__c == 'Success' || kyc.KYC_Form_Tax_Status__c == 'Skipped') && kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped' && 
                kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && kyc.Upload_Documents_Required__c == 'Yes'){
                    
                    List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                        SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                        Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c,Next_Sub_Status__c,CRM_Stage__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND KYC_Form_Tax_Status__c =: kyc.KYC_Form_Tax_Status__c  
                        AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c AND API_Status__c =: kyc.API_Status__c LIMIT 1];
                    
                    
                    System.debug('Fetching Custom MetaData Record In Update record Overdue Stage:'+settings[0]);
                    
                    kyc.CRM_Stage__c = settings[0].CRM_Stage__c;
                    kyc.API_Status__c = settings[0].Next_API_Status__c;
                    kyc.Sub_Status__c = settings[0].Next_Sub_Status__c;
                    kyc.KYC_Upload_Document_Status__c = settings[0].KYC_Upload_Document_Status__c; //Scenario: ID&V Required = No, PIR = KYC Tax Form and Upload Docs = Yes
                }
        else if((kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Form_Status__c != 'Success' && kyc.KYC_Form_Status__c != 'Skipped' && 
                kyc.ID_V_Required__c == 'Yes' && (kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' || kyc.Review_Personal_Information_Required__c == 'Default') && kyc.Upload_Documents_Required__c == 'Yes' && kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped'){
                    
                    List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                        SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                        Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c,Next_Sub_Status__c,CRM_Stage__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND ID_V_Status__c =: kyc.ID_V_Status__c  
                        AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c AND API_Status__c =: kyc.API_Status__c LIMIT 1];
                    
                    System.debug('Fetching Custom MetaData Record In Update record Overdue Stage:'+settings[0]);
                    
                    kyc.CRM_Stage__c = settings[0].CRM_Stage__c;
                    kyc.API_Status__c = settings[0].Next_API_Status__c;
                    kyc.Sub_Status__c = settings[0].Next_Sub_Status__c;
                    kyc.KYC_Form_Status__c = settings[0].KYC_Form_Status__c;  //Scenario: ID&V Required = Yes, PIR = Yes(Full KYC Form) and Upload Docs = Yes
                }
        else if((kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Form_Status__c == 'Success' && 
                kyc.ID_V_Required__c == 'Yes' && (kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' || kyc.Review_Personal_Information_Required__c == 'Default') && kyc.Upload_Documents_Required__c == 'Yes' && kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped'){
                    
                    List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                        SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                        Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c,Next_Sub_Status__c,CRM_Stage__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND KYC_Form_Status__c =: kyc.KYC_Form_Status__c  
                        AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c AND API_Status__c =: kyc.API_Status__c LIMIT 1];
                    
                    System.debug('Fetching Custom MetaData Record In Update record Overdue Stage:'+settings[0]);
                    
                    kyc.CRM_Stage__c = settings[0].CRM_Stage__c;
                    kyc.API_Status__c = settings[0].Next_API_Status__c;
                    kyc.Sub_Status__c = settings[0].Next_Sub_Status__c;
                    kyc.KYC_Form_Status__c = settings[0].KYC_Form_Status__c;  //Scenario: ID&V Required = Yes, PIR = Yes(Full KYC Form) and Upload Docs = Yes
                    kyc.KYC_Upload_Document_Status__c = settings[0].KYC_Upload_Document_Status__c; 
                }
        else if((kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Form_Tax_Status__c != 'Success' && kyc.KYC_Form_Tax_Status__c != 'Skipped' && 
                kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && kyc.Upload_Documents_Required__c == 'Yes' && kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped'){
                    
                    List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                        SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                        Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c,Next_Sub_Status__c,CRM_Stage__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND ID_V_Status__c =: kyc.ID_V_Status__c  
                        AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c AND API_Status__c =: kyc.API_Status__c LIMIT 1];
                    
                    System.debug('Fetching Custom MetaData Record In Update record Overdue Stage:'+settings[0]);
                    
                    kyc.CRM_Stage__c = settings[0].CRM_Stage__c;
                    kyc.API_Status__c = settings[0].Next_API_Status__c;
                    kyc.Sub_Status__c = settings[0].Next_Sub_Status__c;
                    kyc.KYC_Form_Tax_Status__c = settings[0].KYC_Form_Tax_Status__c;  //Scenario: ID&V Required = Yes, PIR = Yes(KYC TAX Form) and Upload Docs = Yes
                }
        else if((kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.KYC_Form_Tax_Status__c == 'Success' && 
                kyc.ID_V_Required__c == 'Yes' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration'  && kyc.Upload_Documents_Required__c == 'Yes' && kyc.KYC_Upload_Document_Status__c != 'Success' && kyc.KYC_Upload_Document_Status__c != 'Skipped'){
                    
                    List<KYC_Stage_API_Status_Mapping__mdt> settings = [
                        SELECT DeveloperName, API_Status__c,Next_API_Status__c, Overdue_Stage__c,Overdue_Handling__c,Overdue_Stage_Enable_L3__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,
                        Block_App_Access__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c,Next_Sub_Status__c,CRM_Stage__c FROM KYC_Stage_API_Status_Mapping__mdt where Overdue_Stage_Enable_L3__c = true AND KYC_Form_Tax_Status__c =: kyc.KYC_Form_Tax_Status__c  
                        AND ID_V_Required__c =: kyc.ID_V_Required__c AND Review_Personal_Information_Required__c =: kyc.Review_Personal_Information_Required__c AND Upload_Documents_Required__c =: kyc.Upload_Documents_Required__c AND API_Status__c =: kyc.API_Status__c LIMIT 1];
                    
                    System.debug('Fetching Custom MetaData Record In Update record Overdue Stage:'+settings[0]);
                    
                    kyc.CRM_Stage__c = settings[0].CRM_Stage__c;
                    kyc.API_Status__c = settings[0].Next_API_Status__c;
                    kyc.Sub_Status__c = settings[0].Next_Sub_Status__c;
                    kyc.KYC_Form_Tax_Status__c = settings[0].KYC_Form_Tax_Status__c;  //Scenario: ID&V Required = Yes, PIR = Yes(KYC TAX Form) and Upload Docs = Yes
                    kyc.KYC_Upload_Document_Status__c = settings[0].KYC_Upload_Document_Status__c; 
                }
        else if(kyc.ID_V_Required__c == 'Yes' && kyc.ID_V_Status__c == 'Success' && kyc.Review_Personal_Information_Required__c == 'No' && kyc.Upload_Documents_Required__c == 'No'){
            kyc.CRM_Stage__c = 'PR_COMPLETED';
            kyc.API_Status__c = 'PR_COMPLETED';
            kyc.Sub_Status__c = 'Completed';
            kyc.Status__c = 'Closed';  //Scenario: ID&V Required = Yes, PIR = No and Upload Docs = No
            System.debug('ID&V Required = Yes, PIR = No and Upload Docs = No ---> ID&V Status Changes to Success');
        }
        else if(kyc.ID_V_Required__c == 'No' && (kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' || kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration') && (kyc.KYC_Form_Tax_Status__c == 'Success' || kyc.KYC_Form_Status__c == 'Success') && kyc.Upload_Documents_Required__c == 'No'){
            kyc.CRM_Stage__c = 'PR_COMPLETED';
            kyc.API_Status__c = 'PR_COMPLETED';
            kyc.Sub_Status__c = 'Completed';
            kyc.Status__c = 'Closed';  //Scenario: ID&V Required = No, PIR = Full KYC Form OR Tax Form and Upload Docs = No
            System.debug('ID&V Required = No, PIR = Full KYC Form OR Tax Form and Upload Docs = No ---> KYC Form/Tax Status Changes to Success');
        }
        else if(kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'No' && kyc.Upload_Documents_Required__c == 'Yes' && kyc.KYC_Upload_Document_Status__c == 'Success'){
            kyc.CRM_Stage__c = 'PR_IN_PROGRESS';
            if(kyc.Overdue_Stage__c == 'Stage 1 – No Restrictions'){
                kyc.API_Status__c = 'PR_IN_PROGRESS_S1';
            }else if(kyc.Overdue_Stage__c == 'Stage 2 – Block Debit Cards'){
                kyc.API_Status__c = 'PR_IN_PROGRESS_S2';
            }else if(kyc.Overdue_Stage__c == 'Stage 3 – Block Debit Cards & Credit Cards'){
                kyc.API_Status__c = 'PR_IN_PROGRESS_S3';
            }else if(kyc.Overdue_Stage__c == 'Stage 4 – Block Debit Cards, Credit Cards, Account Debits & App Access'){
                kyc.API_Status__c = 'PR_IN_PROGRESS_S4';
            }
            
            kyc.Sub_Status__c = 'In-Progress'; //Scenario: ID&V Required = No, PIR = No and Upload Docs = Yes
            System.debug('ID&V Required = No, PIR = No and Upload Docs = Yes ---> Upload Doc Status Changes to Success');
        }
        else if(kyc.ID_V_Required__c == 'Yes' && (kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && kyc.KYC_Form_Status__c == 'Success' && kyc.Upload_Documents_Required__c == 'No'){
            kyc.CRM_Stage__c = 'PR_COMPLETED';
            kyc.API_Status__c = 'PR_COMPLETED';
            kyc.Sub_Status__c = 'Completed';
            kyc.Status__c = 'Closed';  //Scenario: ID&V Required = Yes, PIR = Full KYC Form and Upload Docs = No
            System.debug('ID&V Required = Yes, PIR = Full KYC Form and Upload Docs = No ---> KYC Form Status Changes to Success');
        }
        else if(kyc.ID_V_Required__c == 'Yes' && (kyc.ID_V_Status__c == 'Success' || kyc.ID_V_Status__c == 'Skipped') && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && kyc.KYC_Form_Tax_Status__c == 'Success' && kyc.Upload_Documents_Required__c == 'No'){
            kyc.CRM_Stage__c = 'PR_COMPLETED';
            kyc.API_Status__c = 'PR_COMPLETED';
            kyc.Sub_Status__c = 'Completed';
            kyc.Status__c = 'Closed';  //Scenario: ID&V Required = Yes, PIR = KYC Tax Form and Upload Docs = No
            System.debug('ID&V Required = Yes, PIR = KYC Tax Form and Upload Docs = No ---> KYC Form Status Changes to Success');
        }
        else if(kyc.ID_V_Required__c == 'Yes' && kyc.ID_V_Status__c == 'Success' && kyc.Review_Personal_Information_Required__c == 'No' && kyc.Upload_Documents_Required__c == 'Yes' && kyc.KYC_Upload_Document_Status__c == 'Success'){
            kyc.CRM_Stage__c = 'PR_IN_PROGRESS';
            if(kyc.Overdue_Stage__c == 'Stage 1 – No Restrictions'){
                kyc.API_Status__c = 'PR_IN_PROGRESS_S1';
            }else if(kyc.Overdue_Stage__c == 'Stage 2 – Block Debit Cards'){
                kyc.API_Status__c = 'PR_IN_PROGRESS_S2';
            }else if(kyc.Overdue_Stage__c == 'Stage 3 – Block Debit Cards & Credit Cards'){
                kyc.API_Status__c = 'PR_IN_PROGRESS_S3';
            }else if(kyc.Overdue_Stage__c == 'Stage 4 – Block Debit Cards, Credit Cards, Account Debits & App Access'){
                kyc.API_Status__c = 'PR_IN_PROGRESS_S4';
            }
            kyc.Sub_Status__c = 'In-Progress'; //Scenario: ID&V Required = Yes, PIR = No and Upload Docs = Yes
            System.debug('ID&V Required = Yes, PIR = No and Upload Docs = Yes ---> Upload Doc Status Changes to Success');
        }
        else if(kyc.ID_V_Required__c == 'No' && (kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' || kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration') && (kyc.KYC_Form_Tax_Status__c == 'Success' || kyc.KYC_Form_Status__c == 'Success')  && kyc.Upload_Documents_Required__c == 'Yes' && kyc.KYC_Upload_Document_Status__c == 'Success'){
            kyc.CRM_Stage__c = 'PR_IN_PROGRESS';
            if(kyc.Overdue_Stage__c == 'Stage 1 – No Restrictions'){
                kyc.API_Status__c = 'PR_IN_PROGRESS_S1';
            }else if(kyc.Overdue_Stage__c == 'Stage 2 – Block Debit Cards'){
                kyc.API_Status__c = 'PR_IN_PROGRESS_S2';
            }else if(kyc.Overdue_Stage__c == 'Stage 3 – Block Debit Cards & Credit Cards'){
                kyc.API_Status__c = 'PR_IN_PROGRESS_S3';
            }else if(kyc.Overdue_Stage__c == 'Stage 4 – Block Debit Cards, Credit Cards, Account Debits & App Access'){
                kyc.API_Status__c = 'PR_IN_PROGRESS_S4';
            }
            kyc.Sub_Status__c = 'In-Progress'; //Scenario: ID&V Required = No, PIR = Full KYC Form || Tax Form and Upload Docs = Yes
            System.debug('ID&V Required = No, PIR = No and Upload Docs = Yes ---> Upload Doc Status Changes to Success');
        }
    }
    //System Action Builder
    public static KYC_System_Action__c buildSystemAction(String reqBody, String resBody, String path, String method, String cif, String kycId, Integer code){
        return new KYC_System_Action__c(
            Request_Body__c = reqBody,
            Response_Body__c = resBody,
            End_Point_Url__c = path,
            Method__c = method,
            Customer_CIF__c = cif,
            KYC_Verification__c = kycId,
            HTTP_Response_Code__c = code,
            Type__c = 'KYC Verification'
        );
    }
    //Exception Log Builder
    public static KYC_System_Action__c buildExceptionAction(Exception e, KYC_Verification__c kyc){
        return new KYC_System_Action__c(
            Customer_CIF__c = kyc.CIF__c,
            KYC_Verification__c = kyc.Id,
            Type__c = 'KYC Verification',
            Error_Exception_Message__c = 'Error while processing KYC verification: ' + e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString())
        );
    }
    //Error Log Builder
    public static KYC_System_Action__c buildErrorAction(String message, KYC_Verification__c kyc){
        return new KYC_System_Action__c(
            Customer_CIF__c = kyc.CIF__c,
            KYC_Verification__c = kyc.Id,
            Type__c = 'KYC Verification',
            Error_Exception_Message__c = 'Error while processing KYC verification: ' + message
        );
    }
    //Error Log Builder
    //UATNB-210370: Start
    public static KYC_System_Action__c buildErrorActionAcct(String message){
        return new KYC_System_Action__c(
            Type__c = 'KYC Verification',
            Error_Exception_Message__c = 'Error while updating Account: ' + message
        );
    }
    //UATNB-210370: END
    //Status Configure
    public static String APIStatusUpdate(String status){
        String apistatus;
        if(status=='In-Progress' || status=='Pending'){
            apistatus='PENDING';
        }else if(status=='Success'){
            apistatus='COMPLETED';
        }else if(status =='Failed'){
            apistatus='FAILED';
        }else if(status=='Skipped'){
            apistatus='SKIPPED';
        }
        return apistatus;
    }
    
    public static void applyUploadDocumentSettings(KYC_Verification__c kyc,Map<String, Object> requestBody){
        Set<String>DocSet = New set<String>();
        if (String.isNotBlank(kyc.Document_List__c)) {
            DocSet.addAll(kyc.Document_List__c.split(';'));
        }
        if(DocSet.isEmpty() && kyc.Document_Proof_of_Address__c != true && kyc.Document_FATCA_Declaration__c != true) {
            return;
        }
        if (String.isNotBlank(kyc.Document_List__c)) {
            DocSet.addAll(kyc.Document_List__c.split(';'));
        }

        if(kyc.Document_Proof_of_Address__c == true ){
            DocSet.add('PROOF_OF_ADDRESS');
        }
        if(kyc.Document_FATCA_Declaration__c == true ){
            DocSet.add('FATCA_DECLARATION');
        }

        if(!DocSet.isEmpty()){
            List<String> DList = new List<String>(DocSet);
            String dresult = String.join(DList, ';');
            kyc.Document_List__c=dresult;
        }
        Set<String> requiredDocs = new Set<String>();
        Set<String> allDocs = new Set<String>{'PASSPORT','PROOF_OF_ADDRESS','RESIDENT_PERMIT','FATCA_DECLARATION'};
            if(String.isNotBlank(String.valueOf(kyc.Document_List__c))){
                requiredDocs = new Set<String>(kyc.Document_List__c.split(';'));
            }
        
        
        /*  if(kyc.Document_Passport__c == true) {
requiredDocs.add('PASSPORT');
}
if(kyc.Document_Residence_Permit__c == true) {
requiredDocs.add('RESIDENT_PERMIT');
}
if(kyc.Document_FATCA_Declaration__c == true) {
requiredDocs.add('FATCA_DECLARATION');
}
if(kyc.Document_Proof_of_Address__c == true) {
requiredDocs.add('PROOF_OF_ADDRESS');
}*/
        //  requiredDocs.add(kyc.Document_List__c.split(';'));
        
        // Docs to skip = all - required
        allDocs.removeAll(requiredDocs);
        
        // Whatever remains should be skipped
        List<Object> skipDocs = new List<Object>();
        for (String docCode : allDocs){
            skipDocs.add(new Map<String, Object>{'documentCode' => docCode});
        }
        
        Map<String, Object> uploadDocSettings = new Map<String, Object>{
            'skipDocuments' => skipDocs
                };
                    
                    requestBody.put('kycUploadDocumentSettings', uploadDocSettings);
    }
    
}