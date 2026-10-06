/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date: 26-10-2025
* 		Change History: 
*	     
*/
public class KYCVerificationHandler{
    public static void handlerBeforeKYCCreation(List<KYC_Verification__c> lstKYC){
        String CRM_Stage;
        String KycStatus;
        List<KYC_Verification__c> KycVerification = new List<KYC_Verification__c>();
        List<KYC_Notification_Service__mdt> Notificationsettings = new List<KYC_Notification_Service__mdt>();
        for(KYC_Verification__c kyc : lstKYC){
            if(kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.Sub_Type__c == 'Custom Configurations'){ 
                 Account ac = [Select Id,VVIP__pc,Segment__pc,Nationality__pc,Documents_Status__pc from Account where Id=:kyc.Account_Name__c];
                 kyc.Silent_Case__c=ac.VVIP__pc;
                
                if(kyc.Overdue_Stage__c==null){
                    	List<KYC_Stage_API_Status_Mapping__mdt> settings = [
            			SELECT API_Status__c, Overdue_Stage__c, Sub_Status__c, Account_Debits_App_Access__c,Block_Credit_Cards__c,Block_Debit_Card__c,Block_App_Access__c
            			FROM KYC_Stage_API_Status_Mapping__mdt WHERE Overdue_Stage_Enable_L3__c = false AND Overdue_Handling__c=:kyc.Overdue_Handling__c LIMIT 1];
                		kyc.Overdue_Stage__c=settings[0].Overdue_Stage__c;
                }
                if((kyc.Overdue_Handling__c!='Level 1 - App (Nudges)')){
                    Notificationsettings = [
                        SELECT Notification_Days__c FROM KYC_Notification_Service__mdt WHERE Overdue_Handling__c=:kyc.Overdue_Handling__c AND Overdue_Stage__c=:kyc.Overdue_Stage__c AND Notification_Days__c='0'  LIMIT 1];
                    kyc.No_of_days__c=Integer.ValueOf(Notificationsettings[0].Notification_Days__c);
                    kyc.Next_Notification_Date__c=System.today().addDays(Integer.ValueOf(Notificationsettings[0].Notification_Days__c));
                }
                
                ////////////////////////////////////////////////////////////// Start: Enable Overdue Stage for Custom Configuration /////////////////////////////////////////////////////////////////////////////
                if(System.Label.ENABLE_OVERDUE_STAGE_KYC.equalsIgnoreCase('true') || Test.isRunningTest()){
                    
                    //////////////////////////////////////////////////////////// Start: Populating Overdue Stage Date/Time for Level 3 and No Restriction /////////////////////////////////////////////////////
                    if(kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.Sub_Type__c == 'Custom Configurations' && kyc.Overdue_Handling__c == 'Level 3 - App (Nudges & Splash), Notifications & Restrictions' && kyc.Overdue_Stage__c == 'Stage 1 – No Restrictions'){
                        kyc.Overdue_Stage_Date_Time__c = System.now();
                        kyc.Overdue_Stage_Enable_L3__c = true;
                    }
                    //////////////////////////////////////////////////////////// END: Populating Overdue Stage Date/Time for Level 3 and No Restriction /////////////////////////////////////////////////////
                    
                    //////////////////////////////////////////////////////////// Start: Populating Overdue Stage 2 Date/Time for Level 3 and Block Debit Cards /////////////////////////////////////////////////////
                    if(kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.Sub_Type__c == 'Custom Configurations' && kyc.Overdue_Handling__c == 'Level 3 - App (Nudges & Splash), Notifications & Restrictions' && kyc.Overdue_Stage__c == 'Stage 2 – Block Debit Cards'){
                        kyc.Overdue_Stage_2_Date_Time__c = System.now();
                        kyc.Overdue_Stage_Enable_L3__c = true;
                    }
                    //////////////////////////////////////////////////////////// END: Populating Overdue Stage 2 Date/Time for Level 3 and Block Debit Cards /////////////////////////////////////////////////////
                    
                    //////////////////////////////////////////////////////////// Start: Populating Overdue Stage 3 Date/Time for Level 3 and Block Debit Cards /////////////////////////////////////////////////////
                    if(kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.Sub_Type__c == 'Custom Configurations' && kyc.Overdue_Handling__c == 'Level 3 - App (Nudges & Splash), Notifications & Restrictions' && kyc.Overdue_Stage__c == 'Stage 3 – Block Debit Cards & Credit Cards'){
                        kyc.Overdue_Stage_3_Date_Time__c = System.now();
                        kyc.Overdue_Stage_Enable_L3__c = true;
                    }
                    //////////////////////////////////////////////////////////// END: Populating Overdue Stage 3 Date/Time for Level 3 and Block Debit Cards /////////////////////////////////////////////////////
                    
                }
                ////////////////////////////////////////////////////////////// END: Enable Overdue Stage for Custom Configuration /////////////////////////////////////////////////////////////////////////////
                
                
                ///////////////////////////////////////////////////////////// Start: ID & V Required Or Default on Kyc Creation /////////////////////////////////////////////////////////////////////
                if((kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.Sub_Type__c == 'Custom Configurations' && kyc.ID_V_Required__c == 'Yes') || (kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.Sub_Type__c == 'Default Configurations')){
                    kyc.ID_V_Status__c = 'In-Progress';
                    kyc.Sub_Status__c = 'Pending ID&V';
                    kyc.KYC_Verification_Result__c='ID&V Pending';
                    kyc.CRM_Stage__c = 'PR_PENDING_IDV';
                    kyc.Waiting_Customer_Feedback__c=true;
                    kyc.ID_V_Required_Reason__c='Forced';
                    kyc.OwnerId = System.label.KYC_Verification_Periodic_Review_Queue;
                    
                    if(kyc.Sub_Type__c == 'Custom Configurations' && (kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' || kyc.Review_Personal_Information_Required__c == 'Default')){
                        kyc.KYC_Form_Status__c = 'Pending';
                        kyc.KYC_Form_Tax_Status__c = 'Skipped';
                    }
                    if(kyc.Sub_Type__c == 'Custom Configurations' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration'){
                        kyc.KYC_Form_Status__c = 'Skipped';
                        kyc.KYC_Form_Tax_Status__c = 'Pending';
                    }
                    if(kyc.Sub_Type__c == 'Custom Configurations' && kyc.Review_Personal_Information_Required__c == 'No'){
                        kyc.KYC_Form_Status__c = 'Skipped';
                        kyc.KYC_Form_Tax_Status__c = 'Skipped';
                    }
                    if(kyc.Sub_Type__c == 'Custom Configurations' && kyc.Upload_Documents_Required__c == 'Yes'){
                        kyc.KYC_Upload_Document_Status__c = 'Pending'; 
                    }
                    if(kyc.Sub_Type__c == 'Custom Configurations' && (kyc.Upload_Documents_Required__c == 'No' || kyc.Upload_Documents_Required__c == 'Default')){
                        kyc.KYC_Upload_Document_Status__c = 'Skipped'; 
                    }
                }
                ///////////////////////////////////////////////////////////// END:  ID & V Required Or Default on Kyc Creation /////////////////////////////////////////////////////////////////////
                
                
                ///////////////////////////////////////////////////////////// Start: Personal Information Required(Full KYC Form) /////////////////////////////////////////////////////////////////////
                else if(kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.Sub_Type__c == 'Custom Configurations' && kyc.ID_V_Required__c == 'No' && (kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' || kyc.Review_Personal_Information_Required__c == 'Default')){
                    kyc.KYC_Form_Status__c = 'In-Progress';
                    kyc.KYC_Verification_Result__c='KYC Form Pending';
                    kyc.KYC_Form_Tax_Status__c = 'Skipped';
                    kyc.Sub_Status__c = 'Pending KYC - Full Form';
                    kyc.CRM_Stage__c = 'PR_PENDING_FORM';
                    kyc.Waiting_Customer_Feedback__c=true;
                    kyc.OwnerId = System.label.KYC_Verification_Periodic_Review_Queue;
                    
                    if(kyc.Sub_Type__c == 'Custom Configurations' && kyc.ID_V_Required__c == 'No'){
                        kyc.ID_V_Status__c = 'Skipped';
                    }
                    if(kyc.Sub_Type__c == 'Custom Configurations' && kyc.Upload_Documents_Required__c == 'Yes'){
                        kyc.KYC_Upload_Document_Status__c = 'Pending';  
                    }
                    if(kyc.Sub_Type__c == 'Custom Configurations' && kyc.Upload_Documents_Required__c == 'No'){
                        kyc.KYC_Upload_Document_Status__c = 'Skipped';  
                    }
                    
                }
                ///////////////////////////////////////////////////////////// END: Personal Information Required(Full KYC Form) /////////////////////////////////////////////////////////////////////
                
                ///////////////////////////////////////////////////////////// Start: Personal Information Required(Only Tax Declaration) /////////////////////////////////////////////////////////////////////
                else if(kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.Sub_Type__c == 'Custom Configurations' && kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration'){
                    kyc.KYC_Form_Status__c = 'Skipped';
                    kyc.KYC_Verification_Result__c='KYC Form Pending';
                    kyc.KYC_Form_Tax_Status__c = 'In-Progress';
                    kyc.Sub_Status__c = 'Pending KYC - Tax Only';
                    kyc.CRM_Stage__c = 'PR_PENDING_TAX';
                    kyc.Waiting_Customer_Feedback__c=true;
                    kyc.OwnerId = System.label.KYC_Verification_Periodic_Review_Queue;
                    
                    if(kyc.Sub_Type__c == 'Custom Configurations' && kyc.ID_V_Required__c == 'No'){
                        kyc.ID_V_Status__c = 'Skipped';
                    }
                    if(kyc.Sub_Type__c == 'Custom Configurations' && kyc.Upload_Documents_Required__c == 'Yes'){
                        kyc.KYC_Upload_Document_Status__c = 'Pending';  
                    }
                    if(kyc.Sub_Type__c == 'Custom Configurations' && kyc.Upload_Documents_Required__c == 'No'){
                        kyc.KYC_Upload_Document_Status__c = 'Skipped';  
                    }
                }
                ///////////////////////////////////////////////////////////// END: Personal Information Required(Only Tax Declaration) /////////////////////////////////////////////////////////////////////
                
                ///////////////////////////////////////////////////////////// Start: Upload Documents Required /////////////////////////////////////////////////////////////////////
                else if(kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.Sub_Type__c == 'Custom Configurations' && kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'No' && kyc.Upload_Documents_Required__c == 'Yes'){
                    kyc.KYC_Upload_Document_Status__c = 'In-Progress';
                    kyc.KYC_Verification_Result__c='Documents Pending';
                    kyc.KYC_Form_Status__c = 'Skipped';
                    kyc.KYC_Form_Tax_Status__c = 'Skipped';
                    kyc.ID_V_Status__c = 'Skipped';
                    kyc.Sub_Status__c = 'Pending Upload Documents';
                    kyc.CRM_Stage__c = 'PR_PENDING_UPLOAD';
                    kyc.Waiting_Customer_Feedback__c=true;
                    kyc.OwnerId = System.label.KYC_Verification_Periodic_Review_Queue;
                    
                }
                ///////////////////////////////////////////////////////////// END: Upload Documents Required /////////////////////////////////////////////////////////////////////
                
            }
            ///////////////////////////////////////////////////////////// Start: Default Configuration Logic ///////////////////////////////////////////////////////////////////

            else if(kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.Sub_Type__c == 'Default Configurations'){
                Set<String>DocSet = New set<String>();
                String exclNationality = System.Label.ID_V_Excluded_Nationalities;
                String gccNationality = System.Label.GCC_Nationalities;
                List<String>ExgccNationality =gccNationality.split(';');
                List<String>ExcNationality=exclNationality.split(';');
                Account ac = [Select Id,VVIP__pc,Segment__pc,Nationality__pc,Documents_Status__pc,Passport_Expiry_Date__pc,Residency_Permit_Expiry__pc from Account where Id=:kyc.Account_Name__c];
                System.debug('kyc.Account_Name__c'+ac.VVIP__pc);
                System.debug('kyc.Account_Name__c'+ac.Segment__pc);
                System.debug('kyc.Account_Name__c'+ac.Nationality__pc);
                //  System.debug('kyc.Account_Name__c'+kyc.Account_Name__r.VVIP__pc);
                List<KYC_Verification_Default_Configuration__mdt> settings =new List<KYC_Verification_Default_Configuration__mdt>();
                if(ExcNationality.Contains(ac.Nationality__pc)){
                     kyc.Upload_Documents_Required__c = 'No';
                }
                if((ac.Passport_Expiry_Date__pc == null || ac.Passport_Expiry_Date__pc < System.today()) && !ExcNationality.Contains(ac.Nationality__pc)){
                    System.debug('inside PP');
                    kyc.Document_Passport__c = true;
                    kyc.Upload_Documents_Required__c = 'Yes';
                    DocSet.add('PASSPORT');
                }
                if((ac.Residency_Permit_Expiry__pc == null || ac.Residency_Permit_Expiry__pc < System.today()) && !ExcNationality.Contains(ac.Nationality__pc) && !ExgccNationality.Contains(ac.Nationality__pc)){
                    kyc.Document_Residence_Permit__c = true;
                    kyc.Upload_Documents_Required__c = 'Yes';
                    DocSet.add('RESIDENT_PERMIT');
                }
            //    if(ac.Passport_Expiry_Date__pc != null && ac.Passport_Expiry_Date__pc > System.today() && !ExcNationality.Contains(ac.Nationality__pc)){
                //     kyc.Document_Passport__c = false;
                  //   kyc.Upload_Documents_Required__c = 'No';
            //    }
            //    if(ac.Residency_Permit_Expiry__pc != null && ac.Residency_Permit_Expiry__pc > System.today() && !ExcNationality.Contains(ac.Nationality__pc)){
                //    kyc.Document_Residence_Permit__c = false;
                    //kyc.Upload_Documents_Required__c = 'No';
            //    }
                
                 
                if(ac.VVIP__pc==True){
                    settings = [
                        SELECT Block_Account_Debits__c,Sub_Status__c, Block_App_Access__c, Block_Credit_Cards__c, Block_Debit_Cards__c,Document_FATCA_Declaration__c,Document_Passport__c,Document_Proof_of_Address__c,Document_Residence_Permit__c,ID_V_Required__c,
                        Nationality__c,Overdue_Handling__c,Overdue_Stage__c,Review_Personal_Information_Required__c,Segment__c,Update_eKYC_iGA_Data__c,Upload_Documents_Required__c,VVIP__c FROM KYC_Verification_Default_Configuration__mdt 
                        WHERE  VVIP__c=:ac.VVIP__pc LIMIT 1];
                }else if(ac.Segment__pc=='Staff'){
                    
                    //       if(setting){
                    settings = [
                        SELECT Block_Account_Debits__c,Sub_Status__c, Block_App_Access__c, Block_Credit_Cards__c, Block_Debit_Cards__c,Document_FATCA_Declaration__c,Document_Passport__c,Document_Proof_of_Address__c,Document_Residence_Permit__c,ID_V_Required__c,
                        Nationality__c,Overdue_Handling__c,Overdue_Stage__c,Review_Personal_Information_Required__c,Segment__c,Update_eKYC_iGA_Data__c,Upload_Documents_Required__c,VVIP__c FROM KYC_Verification_Default_Configuration__mdt 
                        WHERE Segment__c =:ac.Segment__pc LIMIT 1];
                }else if(ac.Nationality__pc=='BH'){
                    settings = [
                        SELECT Block_Account_Debits__c,Sub_Status__c, Block_App_Access__c, Block_Credit_Cards__c, Block_Debit_Cards__c,Document_FATCA_Declaration__c,Document_Passport__c,Document_Proof_of_Address__c,Document_Residence_Permit__c,ID_V_Required__c,
                        Nationality__c,Overdue_Handling__c,Overdue_Stage__c,Review_Personal_Information_Required__c,Segment__c,Update_eKYC_iGA_Data__c,Upload_Documents_Required__c,VVIP__c FROM KYC_Verification_Default_Configuration__mdt 
                        WHERE Nationality__c =: ac.Nationality__pc  LIMIT 1];
                }else{
                    settings = [
                        SELECT Block_Account_Debits__c,Sub_Status__c, Block_App_Access__c, Block_Credit_Cards__c, Block_Debit_Cards__c,Document_FATCA_Declaration__c,Document_Passport__c,Document_Proof_of_Address__c,Document_Residence_Permit__c,ID_V_Required__c,
                        Nationality__c,Overdue_Handling__c,Overdue_Stage__c,Review_Personal_Information_Required__c,Segment__c,Update_eKYC_iGA_Data__c,Upload_Documents_Required__c,VVIP__c FROM KYC_Verification_Default_Configuration__mdt 
                        WHERE Segment__c =:ac.Segment__pc AND Nationality__c ='' LIMIT 1];
                }
                System.debug('setting'+settings);
                if(!settings.isEmpty()){
                    kyc.ID_V_Required__c=settings[0].ID_V_Required__c;
                    kyc.sub_status__c=settings[0].Sub_Status__c;
                    kyc.Review_Personal_Information_Required__c=settings[0].Review_Personal_Information_Required__c;
                    kyc.Update_eKYC_iGA_Data__c=settings[0].Update_eKYC_iGA_Data__c;
                    //kyc.Upload_Documents_Required__c=settings[0].Upload_Documents_Required__c;
                    kyc.Overdue_Stage__c=settings[0].Overdue_Stage__c;
                    kyc.Overdue_Handling__c=settings[0].Overdue_Handling__c;
                    kyc.Block_Account_Debits__c=settings[0].Block_Account_Debits__c;
                    kyc.Block_App_Access__c=settings[0].Block_App_Access__c;
                    kyc.Block_Credit_Cards__c=settings[0].Block_Credit_Cards__c;
                    kyc.Block_Debit_Cards__c=settings[0].Block_Debit_Cards__c;
                    String Doclist;
                    if(settings[0].Document_FATCA_Declaration__c){
                        DocSet.add('FATCA_DECLARATION');
                        Doclist='FATCA_DECLARATION;';
                    }
                    if(settings[0].Document_Passport__c){
                        Doclist=Doclist+'PASSPORT;';
                        DocSet.add('PASSPORT');
                    }
                    if(settings[0].Document_Proof_of_Address__c){
                        Doclist=Doclist+'PROOF_OF_ADDRESS;';
                        DocSet.add('PROOF_OF_ADDRESS');
                    }
                    if(settings[0].Document_Residence_Permit__c){
                        Doclist=Doclist+'RESIDENT_PERMIT;';
                         DocSet.add('RESIDENT_PERMIT');
                    }
                   // kyc.Document_FATCA_Declaration__c=settings[0].Document_FATCA_Declaration__c;
                   // kyc.Document_Passport__c=settings[0].Document_Passport__c;
                   // kyc.Document_Proof_of_Address__c=settings[0].Document_Proof_of_Address__c;
                   // kyc.Document_Residence_Permit__c=settings[0].Document_Residence_Permit__c;
                   // 
                    if(!DocSet.isEmpty()){
                        List<String> DList = new List<String>(DocSet);
                        String dresult = String.join(DList, ';');
                         kyc.Document_List__c=dresult;
                    }else{
                        kyc.Upload_Documents_Required__c = 'No';
                    }
                    /*if(String.isNotBlank(Doclist)){
                        kyc.Document_List__c=Doclist;
                    }*/                   
                    kyc.Waiting_Customer_Feedback__c=true;
                    kyc.Silent_Case__c=ac.VVIP__pc;
                }
                if(ac.Documents_Status__pc=='Missing'){
                    kyc.ID_V_Required__c = 'Yes';
                    kyc.KYC_Verification_Result__c='ID&V Pending';
                    kyc.ID_V_Required_Reason__c='Missing Documents';
                }else if(ac.Documents_Status__pc=='Complete'&& ExcNationality.Contains(ac.Nationality__pc)){
                    kyc.ID_V_Required__c = 'No';
                     kyc.KYC_Verification_Result__c='KYC Form Pending';
                     kyc.ID_V_Required_Reason__c ='Complete Documents & Excluded Nationality';
                }else if(ac.Documents_Status__pc=='Complete'&& !ExcNationality.Contains(ac.Nationality__pc)){
                    kyc.ID_V_Required__c = 'Yes';
                    kyc.KYC_Verification_Result__c='ID&V Pending';
                    kyc.ID_V_Required_Reason__c='Complete Documents & Non-Excluded Nationality';
                }else if(ac.Documents_Status__pc=='Unable to Verify'){
                    kyc.ID_V_Required__c = 'No'; 
                    kyc.KYC_Verification_Result__c='KYC Form Pending';
                    kyc.ID_V_Required_Reason__c='Unable to Perform ID&V (Manually Onboarded Using Non-BH Documents)';
                }
                ///////////////////////////////////////////////////////////// Start: ID & V Required Or Default on Kyc Creation /////////////////////////////////////////////////////////////////////
                if((kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.ID_V_Required__c == 'Yes')){
                    kyc.ID_V_Status__c = 'In-Progress';
                    kyc.CRM_Stage__c='PR_PENDING_IDV';
                    if(kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form'){
                        kyc.KYC_Form_Status__c = 'Pending';
                        kyc.KYC_Form_Tax_Status__c = 'Skipped';
                    }
                    if(kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration'){
                        kyc.KYC_Form_Status__c = 'Skipped';
                        kyc.KYC_Form_Tax_Status__c = 'Pending';
                    }
                    if(kyc.Review_Personal_Information_Required__c == 'No'){
                        kyc.KYC_Form_Status__c = 'Skipped';
                        kyc.KYC_Form_Tax_Status__c = 'Skipped';
                    }
                    if(kyc.Upload_Documents_Required__c == 'Yes'){
                        kyc.KYC_Upload_Document_Status__c = 'Pending'; 
                    }
                    if((kyc.Upload_Documents_Required__c == 'No' || kyc.Upload_Documents_Required__c == 'Default')){
                        kyc.KYC_Upload_Document_Status__c = 'Skipped'; 
                    }
                }
                ///////////////////////////////////////////////////////////// END:  ID & V Required Or Default on Kyc Creation /////////////////////////////////////////////////////////////////////
                
                
                ///////////////////////////////////////////////////////////// Start: Personal Information Required(Full KYC Form) /////////////////////////////////////////////////////////////////////
                else if(kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.ID_V_Required__c == 'No' && (kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' || kyc.Review_Personal_Information_Required__c == 'Default')){
                    kyc.KYC_Form_Status__c = 'In-Progress';
                    kyc.KYC_Form_Tax_Status__c = 'Skipped';
                    kyc.Sub_Status__c = 'Pending KYC - Full Form';
                    kyc.CRM_Stage__c = 'PR_PENDING_FORM';
                    kyc.OwnerId = System.label.KYC_Verification_Periodic_Review_Queue;
                    
                    if(kyc.ID_V_Required__c == 'No'){
                        kyc.ID_V_Status__c = 'Skipped';
                    }
                    if(kyc.Upload_Documents_Required__c == 'Yes'){
                        kyc.KYC_Upload_Document_Status__c = 'Pending';  
                    }
                    if(kyc.Upload_Documents_Required__c == 'No'){
                        kyc.KYC_Upload_Document_Status__c = 'Skipped';  
                    }
                    
                }
                ///////////////////////////////////////////////////////////// END: Personal Information Required(Full KYC Form) /////////////////////////////////////////////////////////////////////
                
                ///////////////////////////////////////////////////////////// Start: Personal Information Required(Only Tax Declaration) /////////////////////////////////////////////////////////////////////
                else if(kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration'){
                    kyc.KYC_Form_Status__c = 'Skipped';
                    kyc.KYC_Form_Tax_Status__c = 'In-Progress';
                    kyc.Sub_Status__c = 'Pending KYC - Tax Only';
                    kyc.CRM_Stage__c = 'PR_PENDING_TAX';
                    kyc.OwnerId = System.label.KYC_Verification_Periodic_Review_Queue;
                    
                    if(kyc.ID_V_Required__c == 'No'){
                        kyc.ID_V_Status__c = 'Skipped';
                    }
                    if(kyc.Upload_Documents_Required__c == 'Yes'){
                        kyc.KYC_Upload_Document_Status__c = 'Pending';  
                    }
                    if(kyc.Upload_Documents_Required__c == 'No'){
                        kyc.KYC_Upload_Document_Status__c = 'Skipped';  
                    }
                }
                ///////////////////////////////////////////////////////////// END: Personal Information Required(Only Tax Declaration) /////////////////////////////////////////////////////////////////////
                
                ///////////////////////////////////////////////////////////// Start: Upload Documents Required /////////////////////////////////////////////////////////////////////
                else if(kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.ID_V_Required__c == 'No' && kyc.Review_Personal_Information_Required__c == 'No' && kyc.Upload_Documents_Required__c == 'Yes'){
                    kyc.KYC_Upload_Document_Status__c = 'In-Progress';
                    kyc.KYC_Form_Status__c = 'Skipped';
                    kyc.KYC_Form_Tax_Status__c = 'Skipped';
                    kyc.ID_V_Status__c = 'Skipped';
                    kyc.Sub_Status__c = 'Pending Upload Documents';
                    kyc.CRM_Stage__c = 'PR_PENDING_UPLOAD';
                    kyc.OwnerId = System.label.KYC_Verification_Periodic_Review_Queue;
                    
                }
                ///////////////////////////////////////////////////////////// END: Upload Documents Required /////////////////////////////////////////////////////////////////////
                if((kyc.Overdue_Handling__c!='Level 1 - App (Nudges)')){
                    Notificationsettings = [
                        SELECT Notification_Days__c FROM KYC_Notification_Service__mdt WHERE Overdue_Handling__c=:kyc.Overdue_Handling__c AND Overdue_Stage__c=:kyc.Overdue_Stage__c AND Notification_Days__c='0'  LIMIT 1];
                    kyc.No_of_days__c=Integer.ValueOf(Notificationsettings[0].Notification_Days__c);
                    kyc.Next_Notification_Date__c=System.today().addDays(Integer.ValueOf(Notificationsettings[0].Notification_Days__c));
                }
                ////////////////////////////////////////////////////////////// Start: Enable Overdue Stage for Default Configuration /////////////////////////////////////////////////////////////////////////////
                if(System.Label.ENABLE_OVERDUE_STAGE_KYC.equalsIgnoreCase('true')){
                    
                    //////////////////////////////////////////////////////////// Start: Populating Overdue Stage Date/Time for Level 3 and No Restriction /////////////////////////////////////////////////////
            		if(kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.Sub_Type__c == 'Default Configurations' && kyc.Overdue_Handling__c == 'Level 3 - App (Nudges & Splash), Notifications & Restrictions' && kyc.Overdue_Stage__c == 'Stage 1 – No Restrictions'){
                		kyc.Overdue_Stage_Date_Time__c = System.now();
                		kyc.Overdue_Stage_Enable_L3__c = true;
            		}
            		//////////////////////////////////////////////////////////// END: Populating Overdue Stage Date/Time for Level 3 and No Restriction /////////////////////////////////////////////////////

                    
                }
               ////////////////////////////////////////////////////////////// END: Enable Overdue Stage for Default Configuration /////////////////////////////////////////////////////////////////////////////

                
            }
            ///////////////////////////////////////////////////////////// END: Default Configuration Logic ///////////////////////////////////////////////////////////////////

           //////////////////////////////////////////////////////////////// Start: Suspected Identity Fraud //////////////////////////////////////////////////////////////////
			else if(kyc.Type__c == 'KYC_SUSPECTED_IDENTITY_FRAUD'){
                 Account ac = [Select Id,VVIP__pc,Segment__pc,Nationality__pc,Documents_Status__pc from Account where Id=:kyc.Account_Name__c];
                  List<KYC_Suspect_Identify_Fraud__mdt> Identifysettings =new List<KYC_Suspect_Identify_Fraud__mdt>();
                if(ac.Documents_Status__pc=='Complete' || ac.Documents_Status__pc=='Missing'){
                    Identifysettings=[Select ID_V_Required__c,Type__c,Sub_Status__c,CRM_Stage__c,Block_Debit_Cards__c,Block_Credit_Cards__c,Block_App_Access__c,Block_Account_Debits__c,API_Status__c From KYC_Suspect_Identify_Fraud__mdt where Block_Debit_Cards__c=:kyc.Block_Debit_Cards__c AND Block_Credit_Cards__c=:kyc.Block_Credit_Cards__c AND Block_App_Access__c=:kyc.Block_App_Access__c And Block_Account_Debits__c=:kyc.Block_Account_Debits__c];
                    kyc.ID_V_Status__c = 'In-Progress';
                    kyc.Sub_Status__c = Identifysettings[0].Sub_Status__c;
                    kyc.CRM_Stage__c = Identifysettings[0].CRM_Stage__c;
                    kyc.ID_V_Required_Reason__c='Suspected Identity Fraud';
                    //kyc.OwnerId = System.label.KYC_Verification_Periodic_Review_Queue;
                    kyc.OwnerId = System.label.Suspected_Identity_Fraud_Queue;
                    kyc.Status__c='Open';
                    kyc.ID_V_Required__c='Yes'; 
                    kyc.API_Status__c=Identifysettings[0].API_Status__c;
                    kyc.Overdue_Handling__c='Level 3 - App (Nudges & Splash), Notifications & Restrictions';
                    kyc.Overdue_Stage__c='Stage 4 – Block Debit Cards, Credit Cards, Account Debits & App Access';
                    kyc.KYC_Verification_Result__c='ID&V Pending';
                    kyc.Waiting_Customer_Feedback__c=true;
                    Notificationsettings = [
            		SELECT Notification_Days__c FROM KYC_Notification_Service__mdt WHERE Overdue_Handling__c=:kyc.Overdue_Handling__c AND Overdue_Stage__c=:kyc.Overdue_Stage__c AND Notification_Days__c='0'  LIMIT 1];
                	kyc.No_of_days__c=Integer.ValueOf(Notificationsettings[0].Notification_Days__c);
                    kyc.Next_Notification_Date__c=System.today().addDays(Integer.ValueOf(Notificationsettings[0].Notification_Days__c));
                }else{
                    kyc.ID_V_Required__c='No';
                    kyc.API_Status__c='FRAUD_CANCELED';
                    kyc.ID_V_Status__c ='Skipped';
                    kyc.Sub_Status__c ='Canceled';
                    kyc.CRM_Stage__c = 'FRAUD_CANCELED';
                    kyc.ID_V_Required_Reason__c='Unable to Perform ID&V (Manually Onboarded Using Non-BH Documents)';
                    kyc.OwnerId = System.label.KYC_Verification_Periodic_Review_Queue;
                    kyc.Status__c='Closed';
                }
            }
            //////////////////////////////////////////////////////////////// END: Suspected Identity Fraud /////////////////////////////////////////////////////////////////

        }
        
    }
    public static void handlerBeforeKYCUpdate(List<KYC_Verification__c> lstKYC){
        
        for(KYC_Verification__c kycNewObj : lstKYC){
            KYC_Verification__c kycOldObj = (KYC_Verification__c)trigger.oldMap.get(kycNewObj.id);
            if(kycNewObj.KYC_Verification_Result__c !='' && (kycOldObj.KYC_Verification_Result__c != kycNewObj.KYC_Verification_Result__c)){
               if(kycNewObj.KYC_Verification_Result__c == 'ID&V Skipped'){
                    kycNewObj.ID_V_Status__c = 'Skipped';
                }
                else if(kycNewObj.KYC_Verification_Result__c == 'KYC Form Skipped'){
                    kycNewObj.KYC_Form_Status__c = 'Skipped';
                    kycNewObj.KYC_Form_Tax_Status__c = 'Skipped';
                }
                else if(kycNewObj.KYC_Verification_Result__c == 'Documents Returned'){
                    kycNewObj.KYC_Upload_Document_Status__c = 'In-Progress';
                    kycNewObj.Sub_Status__c = 'Pending Upload Documents';
                    kycNewObj.Waiting_Customer_Feedback__c = true;
                    kycNewobj.Document_Resend__c=true;
                }else if(kycNewObj.KYC_Verification_Result__c == 'Documents Skipped'){
                    //kycNewObj.KYC_Upload_Document_Status__c = 'In-Progress'; //UATNB-210495
                    kycNewObj.KYC_Upload_Document_Status__c = 'Skipped';
                }
            }
            if((kycNewObj.Overdue_Handling__c!='Level 1 - App (Nudges)') && (kycNewObj.Type__c=='KYC_PERIODIC_REVIEW')){
                 List<KYC_Notification_Service__mdt> Notificationsettings = [
            			SELECT Notification_Days__c FROM KYC_Notification_Service__mdt WHERE Overdue_Handling__c=:kycNewObj.Overdue_Handling__c AND Overdue_Stage__c=:kycNewObj.Overdue_Stage__c and Notification_Days__c=:String.valueOf(kycNewObj.No_of_days__c)  LIMIT 1];
                if(!Notificationsettings.isEmpty()){
                    kycNewObj.No_of_days__c=Integer.ValueOf(Notificationsettings[0].Notification_Days__c);
                    kycNewObj.Next_Notification_Date__c=System.today().addDays(Integer.ValueOf(Notificationsettings[0].Notification_Days__c));
                }
                		
            }
            
        }
    }
    public static void handlerAfterKYCCreation(List<KYC_Verification__c> lstKYC){
        set<Id> setIdsRequiredIDV = new set<Id>();
        set<Id> setIdsRequiredKYCFullForm = new set<Id>();
        set<Id> setIdsRequiredKYCTaxForm = new set<Id>();
        set<Id> setIdsUploadDocuments = new set<Id>();
        for(KYC_Verification__c kyc : lstKYC){
            ///////////////////////////////////////////////////////////// ID & V Required Or Default on Kyc Creation /////////////////////////////////////////////////////////////////////
            if((kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.ID_V_Required__c == 'Yes')){
                setIdsRequiredIDV.add(kyc.Id);
            }
            else if((kyc.Type__c == 'KYC_SUSPECTED_IDENTITY_FRAUD' && kyc.ID_V_Required__c == 'Yes')){
                setIdsRequiredIDV.add(kyc.Id);
            }
            ///////////////////////////////////////////////////////////// ID & V Not Required & eKYC Not Required on Kyc Creation /////////////////////////////////////////////////////////////////////
            else if(kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.ID_V_Required__c == 'No' && kyc.eKYC_Required__c == false && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form' && kyc.Upload_Documents_Required__c == 'No'){
                setIdsRequiredKYCFullForm.add(kyc.Id);
            }
            else if(kyc.Type__c == 'KYC_PERIODIC_REVIEW'  && kyc.ID_V_Required__c == 'No' && kyc.eKYC_Required__c == false && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && kyc.Upload_Documents_Required__c == 'No'){
                setIdsRequiredKYCTaxForm.add(kyc.Id);
            }
            else if(kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.ID_V_Required__c == 'No' && kyc.eKYC_Required__c == false && kyc.Review_Personal_Information_Required__c == 'Yes - Full KYC Form'&& kyc.Upload_Documents_Required__c == 'Yes' 
                 /*   (kyc.Document_Passport__c == true || kyc.Document_Proof_of_Address__c == true || kyc.Document_Residence_Permit__c == true || kyc.Document_FATCA_Declaration__c == true)*/){
                        setIdsRequiredKYCFullForm.add(kyc.Id);
                   }
            else if(kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.ID_V_Required__c == 'No' && kyc.eKYC_Required__c == false && kyc.Review_Personal_Information_Required__c == 'Yes - Only Tax Declaration' && kyc.Upload_Documents_Required__c == 'Yes' 
               /*  (kyc.Document_Passport__c == true || kyc.Document_Proof_of_Address__c == true || kyc.Document_Residence_Permit__c == true || kyc.Document_FATCA_Declaration__c == true)*/){
                        setIdsRequiredKYCTaxForm.add(kyc.Id);
                   }
            ///////////////////////////////////////////////////////////// ID & V Not Required & eKYC Not Required on Kyc Creation /////////////////////////////////////////////////////////////////////
            
            ///////////////////////////////////////////////////////////// ID & V Not Required, eKYC Not Required and KYC Form Not Required on Kyc Creation /////////////////////////////////////////////////////////////////////
            else if(kyc.Type__c == 'KYC_PERIODIC_REVIEW' && kyc.ID_V_Required__c == 'No' && kyc.eKYC_Required__c == false && kyc.Review_Personal_Information_Required__c == 'No' && kyc.Upload_Documents_Required__c == 'Yes'
                    /*&&
                    (kyc.Document_Passport__c == true || kyc.Document_Proof_of_Address__c == true || kyc.Document_Residence_Permit__c == true || kyc.Document_FATCA_Declaration__c == true)*/){
                        setIdsUploadDocuments.add(kyc.Id);
                    }
            ///////////////////////////////////////////////////////////// ID & V Not Required, eKYC Not Required and KYC Form Not Required on Kyc Creation /////////////////////////////////////////////////////////////////////
            
            
        }//for loop Ends
        if(setIdsRequiredIDV.size()>0){
            //Call Queueable Method to display Nudge on the Mobile App
            KYCVerificationHandlerCreationAPI kycVerif = new KYCVerificationHandlerCreationAPI(setIdsRequiredIDV);
            System.enqueueJob(kycVerif);
        }
        if(setIdsRequiredKYCFullForm.size()>0){
            //Call Queueable Method to display Nudge on the Mobile App
            KYCVerificationHandlerCreationAPI kycVerif = new KYCVerificationHandlerCreationAPI(setIdsRequiredKYCFullForm);
            System.enqueueJob(kycVerif);
        }
        if(setIdsRequiredKYCTaxForm.size()>0){
            //Call Queueable Method to display Nudge on the Mobile App
            KYCVerificationHandlerCreationAPI kycVerif = new KYCVerificationHandlerCreationAPI(setIdsRequiredKYCTaxForm);
            System.enqueueJob(kycVerif);
        }
        if(setIdsUploadDocuments.size()>0){
            //Call Queueable Method to display Nudge on the Mobile App
            KYCVerificationHandlerCreationAPI kycVerif = new KYCVerificationHandlerCreationAPI(setIdsUploadDocuments);
            System.enqueueJob(kycVerif);
        }
    }
    public static void handlerAfterKYCUpdate(List<KYC_Verification__c> lstKYC){
        set<Id> setIdsRequiredIDV = new set<Id>();
        set<Id> setIdsRequiredKYCFullForm = new set<Id>();
        set<Id> setIdsRequiredKYCTaxForm = new set<Id>();
        set<Id> setIdsUploadDocuments = new set<Id>();
        List<Account> accList = new List<Account>();
        List<Source_of_Wealth__c> sowList = new List<Source_of_Wealth__c>();
        List<KYC_System_Action__c> lstSA = new List<KYC_System_Action__c>();
        System.debug('After Update Trigger Fires');
        Source_of_Wealth__c sow;
        for(KYC_Verification__c kycNewObj : lstKYC){
            if(kycNewObj.Type__c=='KYC_PERIODIC_REVIEW'){
            KYC_Verification__c kycOldObj = (KYC_Verification__c)trigger.oldMap.get(kycNewObj.id);
            System.debug('kycOldObjID_V_Status__c'+kycOldObj.ID_V_Status__c); 
            System.debug('kycNewObjID_V_Status__c'+kycNewObj.ID_V_Status__c);
            System.debug('kycOldObjID_V_Status__c'+kycOldObj.Overdue_stage__c); 
            System.debug('kycNewObjID_V_Status__c'+kycNewObj.Overdue_stage__c);
            System.debug('kycNewObj'+((kycOldObj.Overdue_stage__c!=kycNewObj.Overdue_stage__c) && (kycNewObj.ID_V_Status__c != 'Success')));
            ///////////////////////////////////////////////////////////// ID&V Required on Kyc Creation or DefaultConfiguration /////////////////////////////////////////////////////////////////////
            if(kycNewObj.Type__c == 'KYC_PERIODIC_REVIEW' && (( kycNewObj.ID_V_Required__c == 'Yes') || kycNewObj.Sub_Type__c == 'Default Configuration') && ((kycOldObj.ID_V_Status__c != kycNewObj.ID_V_Status__c)||(kycOldObj.Overdue_stage__c!=kycNewObj.Overdue_stage__c)) && (kycNewObj.ID_V_Status__c != 'Success' && kycNewObj.ID_V_Status__c != 'Skipped' && kycNewObj.ID_V_Status__c != 'Failed' && kycNewObj.ID_V_Status__c != 'In-Progress')){
                System.debug('ID&V Status Update by the API 2');
                setIdsRequiredIDV.add(kycNewObj.Id); 
            }
            ///////////////////////////////////////////////////////////// ID&V Required on Kyc Creation or DefaultConfiguration/////////////////////////////////////////////////////////////////////
            
            ///////////////////////////////////////////////////////////// ID&V Required on Kyc Creation and API Will Update the ID&V Status as Success or Skipped /////////////////////////////////////////////////////////////////////
            else if(kycNewObj.Type__c == 'KYC_PERIODIC_REVIEW' &&  kycNewObj.ID_V_Required__c == 'Yes' && kycOldObj.ID_V_Status__c != kycNewObj.ID_V_Status__c && (kycNewObj.ID_V_Status__c == 'Success' || kycNewObj.ID_V_Status__c == 'Skipped') && kycNewObj.eKYC_Required__c == false){
                System.debug('ID&V Status Update by the API');
                setIdsRequiredIDV.add(kycNewObj.Id);
            }
            ///////////////////////////////////////////////////////////// ID&V Required on Kyc Creation and API Will Update the ID&V Status as Success or Skipped /////////////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////// Start: KYC Full Form Status Update by the API //////////////////////////////////////////////////////
            //UATNB-210254 Added Jahangeer Mohammed isQueuable in if condition
            //UATNB-210254: Start
         //   else if(kycNewObj.Type__c == 'KYC_PERIODIC_REVIEW'  && ((kycOldObj.KYC_Form_Status__c != kycNewObj.KYC_Form_Status__c)||(kycOldObj.Overdue_stage__c!=kycNewObj.Overdue_stage__c)) && (kycNewObj.KYC_Form_Status__c != 'Success' && kycNewObj.KYC_Form_Status__c != 'Skipped') && kycNewObj.eKYC_Required__c == false && !System.isQueueable()){
            else if(kycNewObj.Type__c == 'KYC_PERIODIC_REVIEW'  && ((kycOldObj.KYC_Form_Status__c != kycNewObj.KYC_Form_Status__c)||(kycOldObj.Overdue_stage__c!=kycNewObj.Overdue_stage__c)) && (kycNewObj.KYC_Form_Status__c != 'Success' && kycNewObj.KYC_Form_Status__c != 'Skipped') && kycNewObj.eKYC_Required__c == false){
                System.debug('KYC Full Form Status Update by the API');
                setIdsRequiredKYCFullForm.add(kycNewObj.Id);
            }
            //UATNB-210254: END
            ////////////////////////////////////////////////////////////// END: KYC Full Form Status Update by the API //////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////// Start: KYC Full Form Status Update by the API //////////////////////////////////////////////////////
            else if(kycNewObj.Type__c == 'KYC_PERIODIC_REVIEW' && kycOldObj.KYC_Form_Status__c != kycNewObj.KYC_Form_Status__c && (kycNewObj.KYC_Form_Status__c == 'Success' || kycNewObj.KYC_Form_Status__c == 'Skipped') && kycNewObj.eKYC_Required__c == false){
                System.debug('KYC Full Form Status Update by the API');
                setIdsRequiredKYCFullForm.add(kycNewObj.Id);
                         if(kycNewObj.KYC_Form_Status__c == 'Success'){
                        try{
                            Account accToUpdate = KYCFormUpdateCustomer.updateKycFormCustomer(kycNewObj);
                            if(accToUpdate != null){
                                accList.add(accToUpdate);
                            }
                            //UATNB-210426: Start
                            if(kycNewObj.Due_Diligence_Category__c != 'Standard Due Diligence'){
                                sow = KYCFormUpdateCustomer.insertSourceofWealth(kycNewObj);
                                if(sow != null){
                                    sowList.add(sow); 
                                } 
                            }
                            //UATNB-210426: END
                            
                        }
                        catch(Exception ex) {
                            lstSA.add(KYCVerificationService.buildExceptionAction(ex, kycNewObj));
                        }
                        
                    }
            }
            ////////////////////////////////////////////////////////////// END: KYC Full Form Status Update by the API //////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////// Start: KYC Tax Form Status Update by the API //////////////////////////////////////////////////////
            //UATNB-210254 Added Jahangeer Mohammed isQueuable in if condition
            //UATNB-210254: Start
            else if(kycNewObj.Type__c == 'KYC_PERIODIC_REVIEW' && ((kycOldObj.KYC_Form_Tax_Status__c != kycNewObj.KYC_Form_Tax_Status__c)||(kycOldObj.Overdue_stage__c!=kycNewObj.Overdue_stage__c)) && (kycNewObj.KYC_Form_Tax_Status__c != 'Success' || kycNewObj.KYC_Form_Tax_Status__c != 'Skipped') && kycNewObj.eKYC_Required__c == false && !System.isQueueable()){
                System.debug('TAX Form Status Update by the API');
                setIdsRequiredKYCTaxForm.add(kycNewObj.Id);
            }
            //UATNB-210254: Start
            ////////////////////////////////////////////////////////////// END: KYC Tax Form Status Update by the API //////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////// Start: KYC Tax Form Status Update by the API //////////////////////////////////////////////////////
            else if(kycNewObj.Type__c == 'KYC_PERIODIC_REVIEW'  && kycOldObj.KYC_Form_Tax_Status__c != kycNewObj.KYC_Form_Tax_Status__c && (kycNewObj.KYC_Form_Tax_Status__c == 'Success' || kycNewObj.KYC_Form_Tax_Status__c == 'Skipped') && kycNewObj.eKYC_Required__c == false){
                System.debug('TAX Form Status Update by the API');
                setIdsRequiredKYCTaxForm.add(kycNewObj.Id);
                 if(kycNewObj.KYC_Form_Tax_Status__c == 'Success'){
                        try{
                            Account accToUpdate = KYCFormUpdateCustomer.updateKycFormCustomer(kycNewObj);
                            if(accToUpdate != null){
                                accList.add(accToUpdate);
                            }
                            //UATNB-210426: Start
                            if(kycNewObj.Due_Diligence_Category__c != 'Standard Due Diligence'){
                                sow = KYCFormUpdateCustomer.insertSourceofWealth(kycNewObj);
                                if(sow != null){
                                    sowList.add(sow); 
                                } 
                            }
                            //UATNB-210426: END
                            
                        }
                        catch(Exception ex) {
                            lstSA.add(KYCVerificationService.buildExceptionAction(ex, kycNewObj));
                        }
                        
                    }
            }
            ////////////////////////////////////////////////////////////// END: KYC Tax Form Status Update by the API //////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////// Start: Upload Document Status Update by the API //////////////////////////////////////////////////////
            //UATNB-210254 Added Jahangeer Mohammed isQueuable in if condition
            //UATNB-210254: Start
            else if(kycNewObj.Type__c == 'KYC_PERIODIC_REVIEW'  && ((kycOldObj.KYC_Upload_Document_Status__c != kycNewObj.KYC_Upload_Document_Status__c)||(kycOldObj.Overdue_stage__c!=kycNewObj.Overdue_stage__c)) && (kycNewObj.KYC_Upload_Document_Status__c != 'Success' && kycNewObj.KYC_Upload_Document_Status__c != 'Skipped') && kycNewObj.eKYC_Required__c == false && !System.isQueueable()){
                System.debug('Upload Document Status Update by the API');
                setIdsUploadDocuments.add(kycNewObj.Id);
                 /* try{
                        Kyc_Verification__c ku = New Kyc_Verification__c();
                            ku.Id=kycNewObj.Id;
                            ku.Document_Resend__c=false;
                        update ku;
                         } catch(Exception ex) {
                            lstSA.add(KYCVerificationService.buildExceptionAction(ex, kycNewObj));
                     }*/
                 
            }
            //UATNB-210254: END
            //            //UATNB-210254: Start
            else if(kycNewObj.Type__c == 'KYC_PERIODIC_REVIEW'  && kycOldObj.KYC_Verification_Result__c =='Documents Returned' && (kycNewObj.KYC_Upload_Document_Status__c != 'Success' && kycNewObj.KYC_Upload_Document_Status__c != 'Skipped') && kycNewObj.Document_Resend__c == true){
                System.debug('Upload Document Status Update by the API');
                setIdsUploadDocuments.add(kycNewObj.Id);
                  try{
                        Kyc_Verification__c ku = New Kyc_Verification__c();
                            ku.Id=kycNewObj.Id;
                            ku.Document_Resend__c=false;
                        update ku;
                         } catch(Exception ex) {
                            lstSA.add(KYCVerificationService.buildExceptionAction(ex, kycNewObj));
                     }
                 
            }
            //UATNB-210254: END
            ////////////////////////////////////////////////////////////// END: Upload Document Status Update by the API //////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////// Start: Upload Document Status Update by the API //////////////////////////////////////////////////////
            else if(kycNewObj.Type__c == 'KYC_PERIODIC_REVIEW'  && ((kycOldObj.KYC_Upload_Document_Status__c != kycNewObj.KYC_Upload_Document_Status__c)) && (kycNewObj.KYC_Upload_Document_Status__c == 'Success' || kycNewObj.KYC_Upload_Document_Status__c == 'Skipped') && kycNewObj.eKYC_Required__c == false){
                System.debug('Upload Document Status Update by the API');
                setIdsUploadDocuments.add(kycNewObj.Id);
            } 
            else if(kycNewObj.Type__c == 'KYC_PERIODIC_REVIEW'  && (kycOldObj.KYC_Verification_Result__c != kycNewObj.KYC_Verification_Result__c) && (kycNewObj.KYC_Verification_Result__c == 'Documents Completed') && kycNewObj.eKYC_Required__c == false){
                System.debug('Upload Document Status Update by the API- Completed');
                setIdsUploadDocuments.add(kycNewObj.Id);
                ///////////////////////////////////////////////////UATNB-213257////////////////////////////
                if(kycNewObj.KYC_Form_Tax_Status__c == 'Success'){
                        try{
                            Account accToUpdate = KYCFormUpdateCustomer.updateKycFormCustomer(kycNewObj);
                            System.debug('accList'+accToUpdate);
                            if(accToUpdate != null){
                                accList.add(accToUpdate);
                            }
                            
                        }
                        catch(Exception ex) {
                            lstSA.add(KYCVerificationService.buildExceptionAction(ex, kycNewObj));
                        }
                        
                    }
                     if(kycNewObj.KYC_Form_Status__c == 'Success'){
                        try{
                            Account accToUpdate = KYCFormUpdateCustomer.updateKycFormCustomer(kycNewObj);
                            System.debug('accList2'+accToUpdate);
                            if(accToUpdate != null){
                                accList.add(accToUpdate);
                            }
                            
                        }
                        catch(Exception ex) {
                            lstSA.add(KYCVerificationService.buildExceptionAction(ex, kycNewObj));
                        }
                        
                    }
                //////////////////////////////////////////////////////////UATNB-213257/////////////////////////////////////////////////////////////////////////////
            }
            ////////////////////////////////////////////////////////////// END: Upload Document Status Update by the API //////////////////////////////////////////////////////
             /*   else if(kycNewObj.Type__c == 'KYC_PERIODIC_REVIEW'  && (kycOldObj.Document_Resend__c != kycNewObj.Document_Resend__c) && (kycNewObj.KYC_Verification_Result__c == 'Documents Returned') && kycNewObj.Document_Resend__c == true){
                    try{
                        Kyc_Verification__c ku = New Kyc_Verification__c();
                            ku.Document_Resend__c=false;
                        update ku;
                         } catch(Exception ex) {
                            lstSA.add(KYCVerificationService.buildExceptionAction(ex, kycNewObj));
                        }
                    }*/
                //////////////////////////////////////////////////////////UATNB-213257/////////////////////////////////////////////////////////////////////////////
            
        } 
        else if(kycNewObj.Type__c == 'KYC_SUSPECTED_IDENTITY_FRAUD'){
             KYC_Verification__c kycOldObj = (KYC_Verification__c)trigger.oldMap.get(kycNewObj.id);
                if(kycNewObj.Type__c == 'KYC_SUSPECTED_IDENTITY_FRAUD' && kycNewObj.ID_V_Required__c == 'Yes' && kycOldObj.ID_V_Status__c != kycNewObj.ID_V_Status__c && (kycNewObj.ID_V_Status__c == 'Success' || kycNewObj.ID_V_Status__c == 'Skipped')){
                    System.debug('ID&V Status Update by the API');
                    setIdsRequiredIDV.add(kycNewObj.Id);
                }
            }
        }
        if(setIdsRequiredIDV.size()>0){
            //Call Queueable Method to display Nudge on the Mobile App
            KYCVerificationHandlerUpdateAPI kycVerif = new KYCVerificationHandlerUpdateAPI(setIdsRequiredIDV);
            System.enqueueJob(kycVerif);
        }
        if(setIdsRequiredKYCFullForm.size()>0){
            //Call Queueable Method to display Nudge on the Mobile App
            KYCVerificationHandlerUpdateAPI kycVerif = new KYCVerificationHandlerUpdateAPI(setIdsRequiredKYCFullForm);
            System.enqueueJob(kycVerif);
        }
        if(setIdsRequiredKYCTaxForm.size()>0){
            //Call Queueable Method to display Nudge on the Mobile App
            KYCVerificationHandlerUpdateAPI kycVerif = new KYCVerificationHandlerUpdateAPI(setIdsRequiredKYCTaxForm);
            System.enqueueJob(kycVerif);
        }
        if(setIdsUploadDocuments.size()>0){
            //Call Queueable Method to display Nudge on the Mobile App
            KYCVerificationHandlerUpdateAPI kycVerif = new KYCVerificationHandlerUpdateAPI(setIdsUploadDocuments);
            System.enqueueJob(kycVerif);
        }
        //UATNB-210370: Start
        if(!accList.isEmpty()){
            Database.SaveResult[] results = Database.update(accList, false);
			for(Integer i = 0; i < results.size(); i++){
                if(!results[i].isSuccess()){
                    for(Database.Error err : results[i].getErrors()){
                        System.debug('error##'+err.getMessage());
                        lstSA.add(KYCVerificationService.buildErrorActionAcct(err.getMessage()));
                    }
                }
            }
            
        }
        if(!sowList.isEmpty()){
            Database.SaveResult[] results = Database.insert(sowList, false);
			for(Integer i = 0; i < results.size(); i++){
                if(!results[i].isSuccess()){
                    for(Database.Error err : results[i].getErrors()){
                        lstSA.add(KYCVerificationService.buildErrorActionAcct(err.getMessage()));
                    }
                }
            }
        }
        if(!lstSA.isEmpty()){
            insert lstSA;
        }
        //UATNB-210370: Start
    }
    
}