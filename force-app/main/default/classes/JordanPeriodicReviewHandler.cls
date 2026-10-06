/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 20-11-2023
*       Change History: 
*                   
*/
public class JordanPeriodicReviewHandler {
    
    /*public static void handlerBeforeCaseCreation(List<case> lstCase){
        List<Case> lstNewCase = new List<Case>();
        Set<Id> setNewAccIds = new Set<Id>();
        Map<Id,List<Case>> mapAccountContainingPeriodicReviewCase = new Map<Id,List<Case>>();
        
        for(Case caseObj : lstCase){ //For loop Start
            
            //////////////////////////////////////// Start: Checking for Existing Jordan Periodic Review Case If Status is Not Closed /////////////////////////////////////
            
            if(caseObj.RecordType_DeveloperName__c == 'JO_Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Region_Flag__c == 'Jordan'){
                System.debug('Testing for Jordan Existing Periodic Review Case');
                lstNewCase.add(caseObj);
                setNewAccIds.add(caseObj.AccountId);
            }
            
            //////////////////////////////////////// END: Checking for Existing Jordan Periodic Review Case If Status is Not Closed /////////////////////////////////////
        } //For loop End
        
        //////////////////////////////////////// Start: Checking for Existing Jordan Periodic Review Case If Status is Not Closed /////////////////////////////////////
        System.debug('List of new Cases:'+lstNewCase);
        System.debug('List of AccountIds related to new cases:'+setNewAccIds);
        if(setNewAccIds.size()>0){
            for(Case c : [Select id,AccountId,Status from Case where Status NOT IN('Closed') AND Type = 'Periodic Review' AND AccountId IN :setNewAccIds]){
                System.debug(' Jordan Periodic Review Case:'+c);
                if(mapAccountContainingPeriodicReviewCase.containsKey(c.AccountId)){
                    mapAccountContainingPeriodicReviewCase.get(c.AccountId).add(c);
                }
                else{
                    mapAccountContainingPeriodicReviewCase.put(c.AccountId,new List<case>{c});
                }
            }
        }
        if(lstNewCase.size()>0){
            for(Case c : lstNewCase){
                if(mapAccountContainingPeriodicReviewCase.containsKey(c.AccountId)){
                    if(!test.isRunningTest())
                        c.addError('Please close the Existing Jordan Periodic Review Case');
                }
              //////////////////////////////////////// END: Checking for Existing Jordan Periodic Review Case If Status is Not Closed /////////////////////////////////////
              
              /////////////////////////////////////// Start: JO Periodic Review Cases will created with default values ////////////////////////////////////////////////////////
                else if(!mapAccountContainingPeriodicReviewCase.containsKey(c.AccountId)){
                    c.Sub_Status__c = 'Pending';
                    c.Jopr_Awaiting_Customer_Notification__c = true;
                    c.cc_Last_Sub_Status_Changed_Pending__c = 'Not Changed';
                    c.cc_Customer_Response__c = 'Customer Not Responded';
                    c.OwnerId = System.Label.Jordan_Contact_Centre_Queue;
                    //CONFIG_2 = 25 Days & CONFIG_3 = 7 Days
                    c.Jopr_Customer_Need_s_to_Respond_by__c = System.now().addDays(Integer.valueOf(System.Label.CONFIG_2));
                    System.debug('ID Type Value:'+c.ID_Type__c);
                    
                    if(c.ID_Type__c == 'Jordanian ID' || c.ID_Type__c == 'Military ID' || c.ID_Type__c == 'Gaza ID' || c.ID_Type__c == 'ID for son’s of Jordanian'){
                        
                        Date expiryDate;
                        if (String.isNotBlank(c.cc_ID_Expiry_Date__c)) {
                            List<String> parts = c.cc_ID_Expiry_Date__c.split('/');
                            if (parts.size() == 3) {
                                expiryDate = Date.newInstance(Integer.valueOf(parts[2]), Integer.valueOf(parts[1]), Integer.valueOf(parts[0]));
                            } else {
                                expiryDate = Date.valueOf(c.cc_ID_Expiry_Date__c);
                            }
                            c.Jopr_ID_or_Passport_Expiry_Date__c = expiryDate;
                        }
                        
                        ///////////////////////////////Start: Calculating Number of Days Remaining between case creation & ID Expiry Date /////////////////////////////////////////////////////////////////////
                        if(c.pr_TriggerType__c == 'Automatically' && expiryDate > System.today()){
                            Integer noOfDaysRemaining = System.today().daysBetween(expiryDate);
                            System.debug('Number of Days between ID Expiry & Case Creation Day:'+noOfDaysRemaining);
                            c.Jopr_No_of_Day_bet_ID_Exp_Case_Creation__c = noOfDaysRemaining;
                        }
                        else{
                            System.debug('Number of Days between ID Expiry & Case Creation is Zero');
                             c.Jopr_No_of_Day_bet_ID_Exp_Case_Creation__c = 0;
                        }
                        
                        ///////////////////////////////END: Calculating Number of Days Remaining between case creation & ID Expiry Date /////////////////////////////////////////////////////////////////////

                        //////////////////////////// Start: Calculating Number of Days Remaining After First Reminder(Case Creation + 7 Days) - ID Expiry Date //////////////////////////////////
                        if(c.pr_TriggerType__c == 'Automatically' && expiryDate > System.today().addDays(Integer.valueOf(System.Label.CONFIG_3))){
                            Integer noOfDays = System.today().addDays(Integer.valueOf(System.Label.CONFIG_3)).daysBetween(expiryDate);
                            System.debug('Number of Days between ID Expiry & Case Creation Plus 7 Days:'+noOfDays);
                            c.Jopr_No_of_Days_bet_ID_Expiry_First_Rem__c = noOfDays;
                        }
                        else{
                             System.debug('Number of Days between ID Expiry & First Reminder is Zero');
                             c.Jopr_No_of_Days_bet_ID_Expiry_First_Rem__c = 0;
                        }
                       //////////////////////////// END: Calculating Number of Days Remaining After First Reminder(Case Creation + 7 Days) - ID Expiry Date //////////////////////////////////

                    }
                    else if(c.ID_Type__c == 'Passport'){
                        
                        c.Jopr_ID_or_Passport_Expiry_Date__c = c.Jopr_Passport_Expiry_Date__c;
                        
                        ///////////////////////////////Start: Calculating Number of Days Remaining between case creation & Passport Expiry Date /////////////////////////////////////////////////////////////////////
                        if(c.pr_TriggerType__c == 'Automatically' && c.Jopr_Passport_Expiry_Date__c > System.today()){
                            Integer noOfDaysRemaining = System.today().daysBetween(c.Jopr_Passport_Expiry_Date__c);
                            System.debug('Number of Days between Passport Expiry & Case Creation Day:'+noOfDaysRemaining);
                            c.Jopr_No_of_Day_bet_ID_Exp_Case_Creation__c = noOfDaysRemaining;
                        }
                        else{
                            System.debug('Number of Days between Passport Expiry & Case Creation is Zero');
                            c.Jopr_No_of_Day_bet_ID_Exp_Case_Creation__c = 0;
                        }
                        
                        ///////////////////////////////END: Calculating Number of Days Remaining between case creation & Passport Expiry Date /////////////////////////////////////////////////////////////////////

                        
                        //////////////////////////// Start: Calculating Number of Days Remaining After First Reminder(Case Creation + 7 Days) - Passport Expiry Date //////////////////////////////////
                        if(c.pr_TriggerType__c == 'Automatically' && c.Jopr_Passport_Expiry_Date__c > System.today().addDays(Integer.valueOf(System.Label.CONFIG_3))){
                            Integer noOfDays = System.today().addDays(Integer.valueOf(System.Label.CONFIG_3)).daysBetween(c.Jopr_Passport_Expiry_Date__c);
                            System.debug('Number of Days between Passport Expiry:'+noOfDays);
                            c.Jopr_No_of_Days_bet_ID_Expiry_First_Rem__c = noOfDays;
                        }
                        else{
                            System.debug('Number of Days between Passport Expiry & First Reminder is Zero');
                            c.Jopr_No_of_Days_bet_ID_Expiry_First_Rem__c = 0;
                        }
                       //////////////////////////// END: Calculating Number of Days Remaining After First Reminder(Case Creation + 7 Days) - Passport Expiry Date //////////////////////////////////

                    }
                }
             /////////////////////////////////////// END: JO Periodic Review Cases will created with default values ////////////////////////////////////////////////////////

            } //For loop Ends
        }
        
        
    }
    public static void handlerAfterCaseCreation(List<case> lstCase){
        Set<Id> setCaseIdsExpired = new Set<Id>();
        Set<Id> setJordanianCaseIds = new Set<Id>();
        Set<Id> setJordanianCaseIdsAutomaticSMS = new Set<Id>();
        
        for(Case caseObj : lstCase){ //For loop Start
            
        //////////////////////////////////////// Start: Checking if ID Type == 'Jordanian ID' then calling Civil Intergration API ////////////////////////////////////////////////////////////
            
            if(caseObj.RecordType_DeveloperName__c == 'JO_Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Region_Flag__c == 'Jordan' && caseObj.ID_Type__c == 'Jordanian ID')
            {
                setJordanianCaseIds.add(caseObj.Id);
            }
            
        //////////////////////////////////////// END: Checking if ID Type == 'Jordanian ID' then calling Civil Intergration API ////////////////////////////////////////////////////////////
        
        //////////////////////////////////////// Start: Checking if Trigger Type == 'Automatic then calling SMS Notification API /////////////////////////////////////////////////////////////
                
            if(caseObj.RecordType_DeveloperName__c == 'JO_Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Region_Flag__c == 'Jordan' && caseObj.pr_TriggerType__c == 'Automatically')
            {
                setJordanianCaseIdsAutomaticSMS.add(caseObj.Id);
            }
            
        //////////////////////////////////////// Start: Checking if Trigger Type == 'Automatic then calling SMS Notification API /////////////////////////////////////////////////////////////

       } //For loop End
        
       
        ////////////////////////////////////////// Start: Calling Jordan Civil Intergration API to fetch ID Expiry Date ///////////////////////////////////////////////////////////////////////////////////
        
        if(!setJordanianCaseIds.isEmpty()){
            System.debug('We need to Call API to fetch Id Expiry Date from Civil System');
            JordanPeriodicReviewQueuableAPI fetchIDExpiry = new JordanPeriodicReviewQueuableAPI(setJordanianCaseIds);
            System.enqueueJob(fetchIDExpiry);
        }
        ////////////////////////////////////////// END: Calling Jordan Civil Intergration API to fetch ID Expiry Date ///////////////////////////////////////////////////////////////////////////////////

        ///////////////////////////////////////// Start: Scheduler Which Runs After 2 minutes if we found more then one Queuable job in a single Transaction After Case Creation /////////////////////////////////////////////
        
        if(!setJordanianCaseIdsAutomaticSMS.isEmpty()){
            if(Limits.getQueueableJobs() == 1){  
                String hour = String.valueOf(Datetime.now().hour());
                //adding 5 minutes from current time to avoid too many Queuable jobs Exception
                String min = String.valueOf(Datetime.now().addMinutes(5).minute());
                String ss = String.valueOf(Datetime.now().second());
                String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                
                JordanPeriodicReviewSMSSchedulable smsSchedule = new JordanPeriodicReviewSMSSchedulable(setJordanianCaseIdsAutomaticSMS);
                System.schedule('Jordan Periodic Review SMS Schedulable',nextFireTime,smsSchedule);
            }
            else if(Limits.getQueueableJobs() < 1){
                JordanPeriodicReviewQueuableSMSAutomatic sendSMS = new JordanPeriodicReviewQueuableSMSAutomatic(setJordanianCaseIdsAutomaticSMS);
                System.enqueueJob(sendSMS);
            }
        }
        
       ///////////////////////////////////////// END: Scheduler Which Runs After 2 minutes if we found more then one Queuable job in a single Transaction After Case Creation /////////////////////////////////////////////

    }
    public static void handlerBeforeCaseUpdate(List<case> lstCase){
        for(Case caseObj : lstCase){
            Case caseOldObj = (Case)trigger.oldMap.get(caseobj.id);
                        
            /////////////////////////////////////////// Start: Checking Status Value Changes and it should be equal to Pending to track Pause flow record ///////////////////////////////////////////////////////////////

            if(caseObj.RecordType_DeveloperName__c == 'JO_Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Region_Flag__c == 'Jordan' && caseOldObj.Sub_Status__c != caseObj.Sub_Status__c &&
              caseObj.Sub_Status__c == 'Pending'){
                
               caseObj.cc_Last_Sub_Status_Changed_Pending__c = 'Not Changed';
               caseObj.cc_Customer_Response__c = 'Customer Not Responded';
            }
            
           /////////////////////////////////////////// END: Checking Status Value Changes and it should be equal to Pending to track Pause flow record ///////////////////////////////////////////////////////////////

            /////////////////////////////////////////// Start: Checking Status Value Changes and it should not be equal to Pending to track Pause flow record ///////////////////////////////////////////////////////////////
            
            if(caseObj.RecordType_DeveloperName__c == 'JO_Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Region_Flag__c == 'Jordan' && caseOldObj.Sub_Status__c != caseObj.Sub_Status__c &&
              caseObj.Sub_Status__c != 'Pending'){
                
               caseObj.cc_Last_Sub_Status_Changed_Pending__c = 'Changed';
               caseObj.cc_Customer_Response__c = 'Customer Responded';
            }
            /////////////////////////////////////////// END: Checking Status Value Changes and it should not be equal to Pending to track Pause flow record ///////////////////////////////////////////////////////////////

            //////////////////////////////////////////// Start: Routing the case to Jordan Account Service from Jordan CC Phase //////////////////////////////////////////////////////////////////////////////////

            if(caseObj.RecordType_DeveloperName__c == 'JO_Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Region_Flag__c == 'Jordan' && caseOldObj.cc_Contact_Centre_Result__c != caseObj.cc_Contact_Centre_Result__c && caseObj.cc_Contact_Centre_Result__c != null &&
              (caseObj.cc_Contact_Centre_Result__c == 'Customer Exceeds 25 Days') || (caseObj.cc_Contact_Centre_Result__c == 'Return to Jordan Account Service')){
                
                caseObj.OwnerId = System.Label.Jordan_Account_Services_Queue;
                caseObj.cc_Contact_Centre_Date_Time__c = System.now();
                caseObj.cc_Contact_Center_by__c = UserInfo.getUserId();
                  if(caseObj.Jopr_Jordan_Account_Service_Result__c != null){
                       caseObj.Jopr_Jordan_Account_Service_Result__c = '';
                   }
            }
            
           //////////////////////////////////////////// END: Routing the case to Jordan Account Service from Jordan CC Phase //////////////////////////////////////////////////////////////////////////////////

            //////////////////////////////////////////// Start: Routing the case to Jordan CC from Jordan Account Service Phase //////////////////////////////////////////////////////////////////////////////////
            
            if(caseObj.RecordType_DeveloperName__c == 'JO_Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Region_Flag__c == 'Jordan' && caseOldObj.Jopr_Jordan_Account_Service_Result__c != caseObj.Jopr_Jordan_Account_Service_Result__c && caseObj.Jopr_Jordan_Account_Service_Result__c != null &&
               (caseObj.Jopr_Jordan_Account_Service_Result__c == 'Return to Jordan Contact Center' || caseObj.Jopr_Jordan_Account_Service_Result__c == 'Blocked')) {
                
                caseObj.OwnerId = System.Label.Jordan_Contact_Centre_Queue;
                caseObj.Jopr_Jordan_Account_Service_Date_Time__c = System.now();
                caseObj.Jopr_Jordan_Account_Service_by__c = UserInfo.getUserId();
                   if(caseObj.cc_Contact_Centre_Result__c != null){
                       caseObj.cc_Contact_Centre_Result__c = '';
                   }
            }
            
            //////////////////////////////////////////// END: Routing the case to Jordan CC from Jordan Account Service Phase //////////////////////////////////////////////////////////////////////////////////

            
            /////////////////////////////////////////// Start: Jordan CC Click on the Documents Attached Action Status Changes to Closed /////////////////////////////////////////////////////////////////////
            
            if(caseObj.RecordType_DeveloperName__c == 'JO_Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Region_Flag__c == 'Jordan' && caseOldObj.cc_Contact_Centre_Result__c != caseObj.cc_Contact_Centre_Result__c && caseObj.cc_Contact_Centre_Result__c != null &&
              caseObj.cc_Contact_Centre_Result__c == 'Document Attached'){
                
                caseObj.cc_Contact_Centre_Date_Time__c = System.now();
                caseObj.cc_Contact_Center_by__c = UserInfo.getUserId();
                caseObj.Status = 'Closed';
                caseObj.Sub_Status__c = 'Completed';
                  
            }
           /////////////////////////////////////////// END: Jordan CC Click on the Documents Attached Action Status Changes to Closed /////////////////////////////////////////////////////////////////////
            
           /////////////////////////////////////////// Start: Logic to display the 'New ID Expiry Date' field either in Read Only Mode or Edit Mode /////////////////////////////////////////////////////////
            
            if(caseObj.RecordType_DeveloperName__c == 'JO_Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseOldObj.ccjo_ID_Expiry_Date__c != caseObj.ccjo_ID_Expiry_Date__c){
                
                if(caseObj.ID_Type__c == 'Jordanian ID' && caseObj.ccjo_ID_Expiry_Date__c > System.today() && caseObj.ccjo_ID_Expiry_Date__c != null){
                    System.debug('New ID Expiry date is greater then today date');
                    caseObj.Jopr_New_ID_Expiry_Read_only__c = true;
                }
                else if(caseObj.ID_Type__c == 'Jordanian ID' && caseObj.ccjo_ID_Expiry_Date__c <= System.today() && caseObj.ccjo_ID_Expiry_Date__c != null){
                    System.debug('New ID Expiry date is less then today date');
                    caseObj.Jopr_New_ID_Expiry_Read_only__c = false;
                }
            } 
            
          /////////////////////////////////////////// END: Logic to display the 'New ID Expiry Date' field either in Read Only Mode or Edit Mode /////////////////////////////////////////////////////////

            
        } //for loop Ends
    }
    public static void handlerAfterCaseUpdate(List<case> lstCase){
        List<Account> lstAcctUpdateExpiryDate = new List<Account>();
        Map<Id,Case> mapAccountUpdateExpiryDateRelatedToCase = new Map<Id,Case>();
        Set<Id> setCaseIdsBlocked = new Set<Id>();
        List<CaseComment> lstComment = new List<CaseComment>();
        
        for(Case caseObj : lstCase){ 
            Case caseOldObj = (Case)trigger.oldMap.get(caseobj.id);
            
            /////////////////////////////////////////////// Start: Status Values Changes to Closed /////////////////////////////////////////////////////////////////////////////////////////////
            
            if(caseObj.RecordType_DeveloperName__c == 'JO_Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Region_Flag__c == 'Jordan' && caseOldObj.cc_Contact_Centre_Result__c != caseObj.cc_Contact_Centre_Result__c &&
              caseObj.cc_Contact_Centre_Result__c == 'Document Attached'){
                System.debug('Jordan CC changes the value to Document Attached ');
                mapAccountUpdateExpiryDateRelatedToCase.put(caseObj.AccountId,caseObj);
            }
            
          /////////////////////////////////////////////// END: Status Values Changes to Closed /////////////////////////////////////////////////////////////////////////////////////////////
  
         //////////////////////////////////////////////// Start: Jordan Account Service Team Clicks on Block Action //////////////////////////////////////////////////////////////////
            if(caseObj.RecordType_DeveloperName__c == 'JO_Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Region_Flag__c == 'Jordan' && caseOldObj.Jopr_Jordan_Account_Service_Result__c != caseObj.Jopr_Jordan_Account_Service_Result__c && caseObj.Jopr_Jordan_Account_Service_Result__c != null &&
              caseObj.Jopr_Jordan_Account_Service_Result__c == 'Blocked'){
                
                setCaseIdsBlocked.add(caseObj.Id);
                 
            }
        //////////////////////////////////////////////// END: Jordan Account Service Team Clicks on Block Action //////////////////////////////////////////////////////////////////

        //////////////////////////////////////////////// Start: Case Comments are added When Contact Center added some comments //////////////////////////////////////////////////////////////////
        
            if(caseObj.RecordType_DeveloperName__c == 'JO_Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Region_Flag__c == 'Jordan' && caseObj.cc_Contact_Centre_Comments__c !=caseOldObj.cc_Contact_Centre_Comments__c &&
              caseObj.cc_Contact_Centre_Comments__c != null ){
                System.debug('Inside Jordan Periodic Review Contact Comments');
                CaseComment CCComm = new CaseComment(ParentID=caseObj.id, CommentBody= 'Contact Centre Comments - '+ caseObj.cc_Contact_Centre_Comments__c);
                lstComment.add(CCComm);
            }
            
        //////////////////////////////////////////////// END: Case Comments are added When Contact Center added some comments //////////////////////////////////////////////////////////////////

         //////////////////////////////////////////////// Start: Case Comments are added When Jordan Account Service added some comments //////////////////////////////////////////////////////////////////
        
            if(caseObj.RecordType_DeveloperName__c == 'JO_Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Region_Flag__c == 'Jordan' && caseObj.Jopr_Jordan_Account_Service_Comments__c !=caseOldObj.Jopr_Jordan_Account_Service_Comments__c &&
              caseObj.Jopr_Jordan_Account_Service_Comments__c != null ){
                System.debug('Inside Jordan Periodic Review Account Service Comments');
                CaseComment CCComm = new CaseComment(ParentID=caseObj.id, CommentBody= 'Account Service Comments - '+ caseObj.Jopr_Jordan_Account_Service_Comments__c);
                lstComment.add(CCComm);
            }
            
        //////////////////////////////////////////////// END: Case Comments are added When Jordan Account Service added some comments //////////////////////////////////////////////////////////////////

        
        } //for loop Ends
        
        /////////////////////////////////////////////////// Start: Inserting Case Comments on Action ///////////////////////////////////////////////////////////////////////
            if(lstComment.size()>0){
                insert lstComment;
            }
        /////////////////////////////////////////////////// END: Inserting Case Comments on Action ///////////////////////////////////////////////////////////////////////

        
        ///////////////////////////////////////////////// Start: Status Value Changes to Closed updating New ID Expiry Date on Account //////////////////////////////////////////////////////////////
        for(Case cse : lstCase){
            if(mapAccountUpdateExpiryDateRelatedToCase.containsKey(cse.AccountId)){
                Case c = mapAccountUpdateExpiryDateRelatedToCase.get(cse.AccountId);
                Account acc = new Account();
                acc.Id = c.AccountId;
                acc.ID_Expiry_Date__pc = c.ccjo_ID_Expiry_Date__c;
                lstAcctUpdateExpiryDate.add(acc);
            }
        }//for loop Ends
        if(!lstAcctUpdateExpiryDate.isEmpty()){
            update lstAcctUpdateExpiryDate;
        }
        ///////////////////////////////////////////////// END: Status Value Changes to Closed updating New ID Expiry Date on Account //////////////////////////////////////////////////////////////

        ///////////////////////////////////////////////// Start: Call the SMS Notification API to Block a Customer and Route the case to Jordan CC /////////////////////////////////////////////////////
        
        if(!setCaseIdsBlocked.isEmpty()){
            System.debug('We need to call Notification API to Send Block SMS to a Customer');
            JordanPeriodicReviewQueuableSMSReminders sendSMSBlocked = new JordanPeriodicReviewQueuableSMSReminders(setCaseIdsBlocked);
            System.enqueueJob(sendSMSBlocked);
        }
        ///////////////////////////////////////////////// END: Call the SMS Notification API to Block a Customer and Route the case to Jordan CC /////////////////////////////////////////////////////

    }*/

}