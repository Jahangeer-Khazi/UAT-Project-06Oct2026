/**
*  @author: Andrey Gavrikov (westbrook)
*  @date: 2019-02-06 11:25:59 
*  @description:
*      handler for all events on Account
*  
*  Version History :   
*  2019-02-06 - CRM-35 - AG
*  generate and set Account CIF number
*   
*        #CH01 : Swapna Added for Reset Recovery Codes
*        #CH02# #Jahangeer Mohammed# #31-05-2022# Added Logic if LastModification date change on Customer level(CRM22-108)
*        #CH03#: Duplicate Referral code retry logic
*        #CH04# #Jahangeer Mohammed# #22-11-2022# Adde Logic for Wathiq Acceptance from Mobile App for Periodic Review Project(CRM22-114)
*        #CH05# #Ashish# #30-11-2022# Added Logic for Custom History Tracking(CRM22-141)
*		 #CH06# #Jahangeer Mohammed# #15-03-2023# #Added Logic to display Customer Name in Camel Case
*		 #CH07# #Jahangeer Mohammed# #25-05-2023# Added Logic to Promote Document Country with iGA Nationality ISO(2 Digits) if both values are not same	
*		 #CH08# #ANISS MBARKI# #08-06-2023# Added Logic for PLA eligibilty (NBA-8143)
*        #CH09# #JAYANTH# #17-08-2023# FIX for PI-2591 - Multiple Prospect archival issue
*        #CH10# #Aniss# #30-01-2024# remove region flag restriction
         #CH11# #Imane Tsioucha # #17-05-2024# Added MoEngage Delete Logic
         #CH12# #Aniss #24-03-2025# PLA - Introducing Al Kanz Prizes for Staff & Relatives - Handling of Relative Lifecycle
		 #CH13# #Jahangeer Mohammed# #22-07-2025# Added Logic for Scheduling Customer Cache API (UATNB-175403, 165692)
		 #CH14# #Jahangeer Mohammed# #08-09-2026 Added Logic for Reapply Restriction Period (NBA-16360)

*/
public without sharing class AccountHandler extends BaseTriggerHandler {
    // CH05 - Start
    private static final Schema.SObjectType accountSchema = Schema.getGlobalDescribe().get('Account');
    public static Map<Id,User> staticActiveUserById;
    public static Map<Id,User> getActiveUserById(){
        if(staticActiveUserById == null){
            staticActiveUserById = new Map<Id,User>([Select id, Name, FirstName, LastName, Email, Username from User where isActive=True]);
        }
        return staticActiveUserById;
    }
    // CH05 - End
    override public void beforeInsert () {
        //... your code here
        setCifNumber((List<Account>)Trigger.new);
        //#CH03#Start
        setReferalCode((List<Account>)Trigger.new);
        //#CH03#End
    }
    
    override public void beforeUpdate () {
        // setCifNumber((List<Account>)Trigger.new); 201020 JT Commented to avoid non-sequential CIFs generated as per Case 6762
       // List<Account>IDVerif = New List<Account>();
        List<Account>NonIDVerif= New List<Account>();
        for(Account acc:(List<Account>)Trigger.new) {
            if(acc.Onboarding_Group__pc!='ID Verification'){
                NonIDVerif.add(acc);
            }
        }
       /* MapReferralCode((List<Account>)Trigger.new);
        setReferralCodeUpdate((List<Account>)Trigger.new);
        //CH04: Start
        setLastReviewUpdate((List<Account>)Trigger.new);
        //CH04: END*/
        if(!NonIDVerif.isEmpty()){
        MapReferralCode((List<Account>)Trigger.new);
        setReferralCodeUpdate((List<Account>)Trigger.new);
        setLastReviewUpdate((List<Account>)Trigger.new);
        //CH14: Start
        setReapplyingRestrictionValidity((List<Account>)Trigger.new);
        }
        //CH14: END

    }
    
    //override public void beforeDelete () {
    //... your code here
    //}
    
    override public void afterInsert () {
        startManualOnboarding((List<Account>)Trigger.new);
        updatePlaRelatives((List<Account>)Trigger.new);//#CH12
    }
    
    override public void afterUpdate () {
        // startManualOnboarding((List<Account>)Trigger.new);
      /*  List<Account>NonIDVerif= New List<Account>();
        for(Account acc:(List<Account>)Trigger.new) {
            if(acc.Onboarding_Group__pc!='ID Verification'){
                NonIDVerif.add(acc);
            }
        }
        if(!NonIDVerif.isEmpty()){*/
			 afterUpdateAccount((Map<Id,Account>)trigger.oldMap, (Map<Id,Account>)trigger.NewMap);
      //  }
       
    }
    
    //override public void afterDelete () {
    //... your code here
    //}
    
    //override public void afterUnDelete () {
    //... your code here
    //}
    
    /**
* CRM-35: generate and set Account CIF number
*/
    @TestVisible
    private static void setCifNumber(final List<Account> newRecs) {
        final List<String> cifIds = CifGenerator.createNewCifIds(newRecs);
        for(Account acc : newRecs) {
            if(String.isBlank(acc.CIF__pc) && !cifIds.isEmpty()) {
                acc.CIF__pc = cifIds[0];
                acc.Account_CIF__c =cifIds[0];
                acc.PersonBirthDate = acc.Date_of_Birth__pc;
                cifIds.remove(0);
            }
            //#CH03#Start
            /*    if (String.isBlank(acc.Referral_Code__pc)) 
                    {
                    //acc.Referral_Code__pc = CifGenerator.generateRandomString();
                    setReferalCode(newRecs,false);
             }*/
            //#CH03#End
        }
    }
    
    //#CH03#Start
    @TestVisible    
    private static void setReferalCode(List<Account> newRecs) { 
        String genRefCode = CifGenerator.generateRandomString();    
        List<Account> genAcc = [Select id from Account where Referral_Code__pc =: genRefCode LIMIT 1];  
        if(genAcc.size() == 0){ 
            newRecs[0].Referral_Code__pc = genRefCode;  
        }else{
            newRecs[0].Referral_Code__pc ='';
        }
    }
    //#CH03#End
    
    @TestVisible
    private static void setReferralCodeUpdate(final List<Account> newRecs) {
         // CH05 - Start
        List<History_Tracking__c> lstHistoryTracking = new list<History_Tracking__c>();     
        Map<id,Account> accOldMap = (Map<id,Account>)Trigger.oldMap;
        Map<id,Account> accNewMap = (Map<id,Account>)Trigger.newMap;
        Map<id,User> mapIdUser = getActiveUserById();
        String FinalTrackingList = system.Label.HT_CustomerObjectFields1 + ',' + system.Label.HT_CustomerObjectFields2 + ',' + system.Label.HT_CustomerObjectFields3;          
        List<String> finalLstLeadTrack = FinalTrackingList.split(','); 
        Set<Id> accIds = new Set<Id>();
        // CH05 - End
        
        //#CH03#Start
        List<Account>updateRefAcnt = New List<Account>();
        for(Account acc : newRecs) {
            if (String.isBlank(acc.Referral_Code__pc)) 
            {
                updateRefAcnt.add(acc);
                //acc.Referral_Code__pc = CifGenerator.generateRandomString();
            }
            // CH05 - Start
            /////////////////////////////////////////////////////////////// Custom History Tracking/ ////////////////////////////////////////////////////////////////////

            for(String str : finalLstLeadTrack)
            {
                if(acc.get(str) != accOldMap.get(acc.id).get(str))
                {
                    Schema.Describefieldresult fieldInfos = getAccFieldInfosBasedOnFieldName(str);

                    History_Tracking__c objHT = new History_Tracking__c();
                    if((string.valueOf(accOldMap.get(acc.id).get(str))!=null && string.valueOf(accOldMap.get(acc.id).get(str)).startsWith('005'))){
                        if(mapIdUser.containsKey(String.valueOf(accOldMap.get(acc.id).get(str)))){
                            objHT.Prior_Value__c = mapIdUser.get(String.valueOf(accOldMap.get(acc.id).get(str))).Name;
                        }
                    }    
                    if(string.valueOf(acc.get(str))!=null && string.valueOf(acc.get(str)).startsWith('005')){
                        if(mapIdUser.containsKey(String.valueOf(acc.get(str)))){
                            objHT.Current_Value__c = mapIdUser.get(String.valueOf(acc.get(str))).Name;
                        }
                    }
                    
                    if(((string.valueOf(accOldMap.get(acc.id).get(str))!=null && !string.valueOf(accOldMap.get(acc.id).get(str)).startsWith('005')) && string.valueOf(acc.get(str))!=null && !string.valueOf(acc.get(str)).startsWith('005')) || (string.valueOf(accOldMap.get(acc.id).get(str))==null && string.valueOf(acc.get(str))!=null) || (string.valueOf(accOldMap.get(acc.id).get(str))!=null && string.valueOf(acc.get(str))==null)){
                        if( fieldInfos != null && fieldInfos.getType() == Schema.DisplayType.DATETIME ){
                            System.debug('This field is a DATETIME : '+str);
                            if(string.valueOf(accOldMap.get(acc.id).get(str))==null && string.valueOf(acc.get(str))!=null){
                                objHT.Prior_Value__c = string.valueOf( (DateTime) accOldMap.get(acc.id).get(str));
                            }
                            else{
                                objHT.Prior_Value__c = string.valueOf( (DateTime) accOldMap.get(acc.id).get(str)+3);
                            }
                            if(string.valueOf(accOldMap.get(acc.id).get(str))!=null && string.valueOf(acc.get(str))==null){
                                objHT.Current_Value__c = string.valueOf( (DateTime) acc.get(str));
                            }
                            else{
                                objHT.Current_Value__c = string.valueOf( (DateTime) acc.get(str) +3 ); 
                            }
                            System.debug('Prior : '+objHT.Prior_Value__c);
                            System.debug(' CurrentVal : '+objHT.Current_Value__c);
                        }
                        else{
                            objHT.Prior_Value__c = string.valueOf(accOldMap.get(acc.id).get(str));
                            objHT.Current_Value__c = string.valueOf(acc.get(str));
                        }

                    }
                    objHT.Customer__c = acc.id;
                    objHT.Changed_By_User__c = UserInfo.getUserId(); 
                    objHT.Changed_Date_Time__c = system.now();
                    objHT.Field_Name__c = str;
                    lstHistoryTracking.add(objHT);
                }
            }
            
            ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            // CH05 - End
        }
        if(!updateRefAcnt.isEmpty()){
            String jsonString = json.serialize(updateRefAcnt);
            if(!System.isFuture()){
              AccountReferralCodeUpdate.processAccountReferralCode(jsonString);
            }
        }
        //#CH03#End
        // CH05 - Start
        if(lstHistoryTracking.size()>0)
            insert lstHistoryTracking;
        // CH05 - END
    }
    //CH04: Start
    private static void setLastReviewUpdate(final List<Account> newRecs){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        for(Account objAcc : newRecs){
            Account objOldAcc = (Account)trigger.oldMap.get(objAcc.id);
            if(objAcc.RecordTypeId == recordTypeId && objAcc.pr_ReviewStatus__c == 'Completed' && objOldAcc.pr_NextReviewDate__c != objAcc.pr_NextReviewDate__c && objOldAcc.pr_NextReviewDate__c != null){
                System.debug('Setting Last Review Date:'+objOldAcc.pr_NextReviewDate__c);
                objAcc.pr_Last_Review_Date__c = objOldAcc.pr_NextReviewDate__c;
            }
            //CH06: Start
            /* System.debug('Old ila customer Name in before update:'+objOldAcc.Ila_Customer_Name__c);
            System.debug('New ila customer Name in before update:'+objAcc.Ila_Customer_Name__c);
            if(objAcc.Ila_Customer_Name__c != null && objOldAcc.Ila_Customer_Name__c != objAcc.Ila_Customer_Name__c){
                objAcc.mkt_Customer_Name_Camel_Case__pc = ConvertCustomerNameToCamelCase.convert(objAcc.Ila_Customer_Name__c);
            } */
            //CH06: END
            //CH07: Start
            /*if(objAcc.RecordTypeId == recordTypeId && objAcc.iGA_Nationality_ISO_2_Digits__pc != objOldAcc.iGA_Nationality_ISO_2_Digits__pc && String.isNotBlank(objAcc.iGA_Nationality_ISO_2_Digits__pc)){
                if(objAcc.iGA_Nationality_ISO_2_Digits__pc != objAcc.ID_Nationality__pc){
                    objAcc.ID_Nationality__pc = objAcc.iGA_Nationality_ISO_2_Digits__pc;
                }
            }*/
            //CH07: END
        }
    }
    //CH04: END
    //CH14: Start
    private static void setReapplyingRestrictionValidity(final List<Account> newRecs){
       Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
       Date todayDate = Date.today();
        for(Account objAcc : newRecs){
            Account objOldAcc = (Account)trigger.oldMap.get(objAcc.id);
            if(objAcc.RecordTypeId == recordTypeId && objOldAcc.Reapplying_Restriction_Last_Update_Date__pc != objAcc.Reapplying_Restriction_Last_Update_Date__pc && objAcc.Reapplying_Restriction_Last_Update_Date__pc != null){
                Integer numberOfMonths;
                // Determine the restriction period
                if(objAcc.Reapplying_Restriction_Period__pc == '1 Month') {
                    numberOfMonths = 1;
                    
                }else if (objAcc.Reapplying_Restriction_Period__pc == '2 Months') {
                    numberOfMonths = 2;
                    
                }else if (objAcc.Reapplying_Restriction_Period__pc == '3 Months') {
                    numberOfMonths = 3;
                    
                }else if (objAcc.Reapplying_Restriction_Period__pc == '4 Months') {
                    numberOfMonths = 4;
                    
                }else if (objAcc.Reapplying_Restriction_Period__pc == '5 Months') {
                    numberOfMonths = 5;
                    
                }else if (objAcc.Reapplying_Restriction_Period__pc == '6 Months') {
                    numberOfMonths = 6;
                    
                }else if (objAcc.Reapplying_Restriction_Period__pc == '9 Months') {
                    numberOfMonths = 9;
                    
                }else if (objAcc.Reapplying_Restriction_Period__pc == '12 Months') {
                    numberOfMonths = 12;
                }
                
                // Calculate validity and checkbox only when a valid period exists
                if(numberOfMonths != null) {
                    Date restrictionStartDate = objAcc.Reapplying_Restriction_Last_Update_Date__pc.date();
                    Date validityDate = restrictionStartDate.addMonths(numberOfMonths);
                    
                    // Populate validity date
                    objAcc.CC_Reapply_Restriction_Period_Validity__pc = validityDate;
                    
                    // Check whether today is within the restriction period
                    if(todayDate >= restrictionStartDate && todayDate <= validityDate) {
                            objAcc.CC_Reapplying_Restriction_Applied__pc = true;
                    }else{
                            objAcc.CC_Reapplying_Restriction_Applied__pc = false;
                            objAcc.Reapplying_Restriction_Period__pc = '';
                            objAcc.Reapplying_Restriction_Last_Update_Date__pc = null;
                        	objAcc.CC_Reapply_Restriction_Period_Validity__pc = null;
                    }
                }
            }
        }//for loop Ends

    }
    //CH14: END
    private static void MapReferralCode(final List<Account> newRecs)
    {
        if(checkRecursive.runOnce()){
            Map<String,Account> mapSetReferredCodeandCustomer = new Map<String, Account>();
            Set<String> setReferCodeBy = new Set<String>();
            List<Account> lstReferreeAccount = new List<Account>();
            for(Account objAcc : newRecs)
            {
                if(objAcc.Referred_By__c != null && objAcc.Referred_By__c != '' )
                {
                    setReferCodeBy.add(objAcc.Referred_By__c);
                }
                system.debug('---> SET --> '+setReferCodeBy);
            }
            for(Account objAcc : [Select id,Referral_Code__pc, Referred_Customer_Count__c,Onboarding_Stage__pc  from Account where Referral_Code__pc in: setReferCodeBy])
            {
                mapSetReferredCodeandCustomer.put(objAcc.Referral_Code__pc, objAcc);
            }   
            system.debug('---> MAP --> '+mapSetReferredCodeandCustomer);
            for(Account objAcc : newRecs)
            {   
                Account objOldAcc = (Account)trigger.oldMap.get(objAcc.id);
                system.debug('---> MAP 22 --> '+mapSetReferredCodeandCustomer.get(objAcc.Referred_By__c));
                if(mapSetReferredCodeandCustomer.containsKey(objAcc.Referred_By__c))
                {
                    objAcc.Referred_By_Name__c = mapSetReferredCodeandCustomer.get(objAcc.Referred_By__c).id;
                    if(objAcc.Onboarding_Stage__pc != objOldAcc.Onboarding_Stage__pc && objAcc.Onboarding_Stage__pc == 'ACCOUNT_ACTIVATED')
                    {
                        system.debug('----> Rf count --> '+mapSetReferredCodeandCustomer.get(objAcc.Referred_By__c).Referred_Customer_Count__c);
                        mapSetReferredCodeandCustomer.get(objAcc.Referred_By__c).Referred_Customer_Count__c = mapSetReferredCodeandCustomer.get(objAcc.Referred_By__c).Referred_Customer_Count__c+1;
                        lstReferreeAccount.add(mapSetReferredCodeandCustomer.get(objAcc.Referred_By__c));
                    }
                }
                else if(objAcc.Referred_By__c != null && objAcc.Referred_By__c != ''){
                    objAcc.addError('No Customer exisits with this Referal Code');
                }
                
                
            }           
            if(lstReferreeAccount.size()>0)
                update lstReferreeAccount;
            //mapSetReferredCodeandCustomer.put(objAcc.Referred_By__c, [Select id from );
        }
    }
    
    
    private static void startManualOnboarding(final List<Account> newRecs) {
        Set<Id> setAccount = new Set<Id>();
        //CH06: Start
        /* Map<Id,Account> mapRelatedAccount = new Map<Id,Account>();
        List<Account> lstAcctToUpdate = new List<Account>(); */
        //CH06: END
        for(Account acc : newRecs) {
            if (acc.Created_from_Lead__c) 
            {
                setAccount.add(acc.id);
            }
        
            //CH06: Start
            /* if(String.isNotBlank(acc.Ila_Customer_Name__c)){
                mapRelatedAccount.put(acc.Id,acc);
            } */
            //CH06: END
        }
        //CH06: Start
         /* if(!mapRelatedAccount.isEmpty()){
          System.debug('Account List:'+mapRelatedAccount.values());
          for(Account acct : mapRelatedAccount.values()){
                System.debug('Account Id is :'+acct.Id);
                System.debug('Ila Customer Name:'+acct.Ila_Customer_Name__c);
                Account a = new Account(Id = acct.Id);
                System.debug('Account Is after attaching:'+a.Id);
                a.mkt_Customer_Name_Camel_Case__pc = ConvertCustomerNameToCamelCase.convert(acct.Ila_Customer_Name__c);
                lstAcctToUpdate.add(a);
          }
        }

        if(!lstAcctToUpdate.isEmpty()){
            update lstAcctToUpdate;
        } */
        //CH06: END
        if(!setAccount.isEmpty())
        {
            initiateManualOnboarding.ManualOnboarding(setAccount);
            
        }
    }
    //after update genric method
    private static void afterUpdateAccount(Map<Id,Account> oldmap, Map<Id,Account> newMap){
        List<Account> accsActivatedAndNotFromLead = new List<Account>();//#CH08
        List<Account> accsActivated = new List<Account>();//#CH12

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Set<Id> accountIds =  new Set<Id>();
        //CH02: Start
        Set<Id> lastModifiedDataAccountId = new Set<Id>();
        //CH02: END
        //CH04: Start
        Set<Id> accountIdsAcceptedWathiqConsentUsingApp = new Set<Id>();
        List<Account> accListAcceptedWathiqConsentUsingApp = new List<Account>();
        Map<Id,List<Case>> accRelatedPeriodicReviewCase = new Map<Id,List<Case>>();
        Set<Id> accountIdsWithReviewStatusCompleted = new Set<Id>();
        //CH04: END
        //CH01 - start
        Date today = Date.today();
        Map<Id,Boolean> updatecaseflag=new Map<Id,Boolean>();
        List<Case> updatecasesList = new List<Case>();
        //CH01 - End
        for(Account accItem : newMap.values()){
            system.debug('accItem.RecordTypeId||'+accItem.RecordTypeId);
            system.debug('oldmap.get(accItem.Id).RecordTypeId||'+oldmap.get(accItem.Id).RecordTypeId);
            system.debug('recordTypeId||'+recordTypeId);
            
            System.debug('Old Account Name in after update:'+oldmap.get(accItem.Id).Name);
            System.debug('New Account Name in after update:'+accItem.Name);
            
            System.debug('Old Last Name in after update:'+oldmap.get(accItem.Id).LastName);
            System.debug('New Last Name in after update:'+accItem.LastName);

            if(accItem.RecordTypeId == recordTypeId && accItem.RecordTypeId != oldmap.get(accItem.Id).RecordTypeId){
                accountIds.add(accItem.Id);
            }
            //CH04: Start
            ////////////////////////////////////////////// Start: Wathiq Consent Accepted from Mobile App //////////////////////////////////////////////////////////////////////////
            if(accItem.RecordTypeId == recordTypeId && accItem.Wathiq_Consent__pc != oldmap.get(accItem.Id).Wathiq_Consent__pc && accItem.Wathiq_Consent__pc == true ){
                accountIdsAcceptedWathiqConsentUsingApp.add(accItem.Id);
                accListAcceptedWathiqConsentUsingApp.add(accItem);
                System.debug('Wathiq Consent Accepted from Mobile App');
            }
            ////////////////////////////////////////////// END: Wathiq Consent Accepted from Mobile App //////////////////////////////////////////////////////////////////////////
            
            ///////////////////////////////////////////// Start: Account Review Status changes to Competed //////////////////////////////////////////////////////
            if(accItem.RecordTypeId == recordTypeId && accItem.pr_ReviewStatus__c != oldmap.get(accItem.Id).pr_ReviewStatus__c && accItem.pr_ReviewStatus__c == 'Completed'){
                accountIdsWithReviewStatusCompleted.add(accItem.Id);
                System.debug('AccountIds with Review Status completed:'+accountIdsWithReviewStatusCompleted);
            }
            ///////////////////////////////////////////// END: Account Review Status changes to Competed //////////////////////////////////////////////////////

            //CH04: END
            //CH02: Start
            System.debug('Check Recursive Run Once Value :'+checkRecursive.runOnce());
            if(accItem.RecordTypeId == recordTypeId && accItem.LastModifiedDate != oldmap.get(accItem.Id).LastModifiedDate && checkRecursive.runOnceForCache()){
                System.debug('Data has been changed');
                lastModifiedDataAccountId.add(accItem.Id);
            }
            //CH04: END
            //CH02: END
            //CH01 - start
            //#CH08 : Start
            if(accItem.Last_Date_Mobile_Changed__c!=null && oldmap.get(accItem.Id).Last_Date_Mobile_Changed__c==null 
               ||(oldmap.get(accItem.Id).Last_Date_Mobile_Changed__c!=null && accItem.Last_Date_Mobile_Changed__c!= oldmap.get(accItem.Id).Last_Date_Mobile_Changed__c)){                
                      Date mydate = accItem.Last_Date_Mobile_Changed__c;
                      Integer monthDiff = mydate.monthsBetween(today);
                      system.debug('monthDiff-->'+monthDiff);
                      if(monthDiff!=null && monthDiff<3){
                          if(!updatecaseflag.isEmpty() && !updatecaseflag.containsKey(accItem.Id)){ //CH09 -Start
                              updatecaseflag.put(accItem.Id,true);
                          }
                          else{
                              updatecaseflag.put(accItem.Id,true);
                          }
                      }
                  }
            system.debug('swapna==>'+accItem.Last_Date_Email_Changed__c);
            if(accItem.Last_Date_Email_Changed__c!=null && oldmap.get(accItem.Id).Last_Date_Email_Changed__c==null 
               ||(oldmap.get(accItem.Id).Last_Date_Email_Changed__c!=null && accItem.Last_Date_Email_Changed__c!= oldmap.get(accItem.Id).Last_Date_Email_Changed__c)
               ||(oldmap.get(accItem.Id).PersonEmail!=null && accItem.PersonEmail!= oldmap.get(accItem.Id).PersonEmail))
            {          
               if(!updatecaseflag.isEmpty() && !updatecaseflag.containsKey(accItem.Id)){  //CH09 -End
                    updatecaseflag.put(accItem.Id,true);
                }else{
                    updatecaseflag.put(accItem.Id,true);
                }
            }
           // } //#CH09 : End
            //#CH08 : Start
            //#CH10 :remove && accItem.Region_Flag__c == 'Bahrain'
            /*if( accItem.Created_from_Lead__c == false  && accItem.Onboarding_Stage__pc == 'ACCOUNT_ACTIVATED' && accItem.Onboarding_Stage__pc!= oldmap.get(accItem.Id).Onboarding_Stage__pc ){
                accsActivatedAndNotFromLead.add(accItem);
            }*/
            //#CH08 : End

             //#CH11 : Start
            
            // accItem.Archived__pc == false && 
             if((accItem.Onboarding_Stage__pc == 'ACCOUNT_ACTIVATED' && accItem.CustomerStatus__c!=oldmap.get(accItem.Id).CustomerStatus__c && accItem.CustomerStatus__c=='Closed' ))
             {
                 MoEngageDeleteCustomer MoEngageDeleteApi=new  MoEngageDeleteCustomer(new Set<Id>{accItem.Id});
                 System.enqueueJob(MoEngageDeleteApi);
             }
             //#CH11 : End

            //#CH12 : Start
            if( accItem.Onboarding_Stage__pc == 'ACCOUNT_ACTIVATED' && accItem.Onboarding_Stage__pc!= oldmap.get(accItem.Id).Onboarding_Stage__pc ){
                accsActivated.add(accItem);
            }
            //#CH12 : End

        }
         //CH04: Start
       ////////////////////////////////////////////// Start: Wathiq Consent Accepted from Mobile App //////////////////////////////////////////////////////////////////////////
        if(!accountIdsAcceptedWathiqConsentUsingApp.isEmpty()){
            //Need to Add the Logic to update the corresponding Periodic review Case
            //Checking Account is having any Periodic Review Case which are not closed
            for(Case c : [Select Id,AccountId,Status,Sub_Status__c,pr_WathiqConsentAcceptanceRequired__c from Case Where AccountId IN:(accountIdsAcceptedWathiqConsentUsingApp) AND Status NOT IN('Closed') AND Type = 'Periodic Review']){
                if(accRelatedPeriodicReviewCase.containsKey(c.AccountId)){
                   accRelatedPeriodicReviewCase.get(c.AccountId).add(c);
                }
                else{
                    accRelatedPeriodicReviewCase.put(c.AccountId,new List<Case>{c});
                }
            }
        }
        List<Case> caseLstNotRequiresWathiqAcceptance = new List<Case>();
        List<Account> lstAccountToUpdateAfterWathiqAcceptance = new List<Account>();
        if(!accRelatedPeriodicReviewCase.isEmpty() && !accListAcceptedWathiqConsentUsingApp.isEmpty()){
            for(Account acc : accListAcceptedWathiqConsentUsingApp){
                if(accRelatedPeriodicReviewCase.containsKey(acc.Id)){
                    Account accToUpdate = new Account(Id = acc.Id);
                    //accToUpdate = acc;
                    //accToUpdate.pr_ReviewStatus__c = 'In-Progress';
                    //lstAccountToUpdateAfterWathiqAcceptance.add(accToUpdate);
                    List<case> cseList = accRelatedPeriodicReviewCase.get(acc.Id);
                    System.debug('Account Related Case:'+cseList);
                    if(cseList.size()>0){
                        for(Case cse : cseList){
                            cse.pr_WathiqConsentAcceptanceRequired__c = false;
                            //cse.Status = 'In Progress';
                            //cse.Sub_Status__c = 'In-Progress';
                            caseLstNotRequiresWathiqAcceptance.add(cse);
                        }
                    }
                }
            }
            
        }
        /*if(lstAccountToUpdateAfterWathiqAcceptance.size()>0){
          System.debug('Account Review Status Update:'+lstAccountToUpdateAfterWathiqAcceptance);
          update lstAccountToUpdateAfterWathiqAcceptance; 
 
        }*/
        if(caseLstNotRequiresWathiqAcceptance.size()>0){
           System.debug('Case Review Status Update:'+caseLstNotRequiresWathiqAcceptance);
           update caseLstNotRequiresWathiqAcceptance; 
        }
        
        ////////////////////////////////////////////// END: Wathiq Consent Accepted from Mobile App //////////////////////////////////////////////////////////////////////////

        //CH04: END
        //CH01 - End
        if(!accountIds.isEmpty()){
            initiateManualOnboarding.eKYCSignCaseClosure(accountIds);
        }
        //CH01 - start
        system.debug('updatecaseflag==>'+updatecaseflag);
        if(updatecaseflag.size()>0){
            List<Case> cases=[Select Id,OwnerId from Case where accountId IN:updatecaseflag.keySet() and OwnerId!=:system.Label.RMT_Queue_Id and Type='Unblock App Access'];
            system.debug('cases==>'+cases);            
            for(Case cs:cases){
                cs.ownerId=system.Label.RMT_Queue_Id;
                updatecasesList.add(cs);
            }
            
        }
        system.debug('updatecasesList==>'+updatecasesList);  
        if(updatecasesList.size()>0){
            Database.update(updatecasesList,false);
        }
        //CH01 - End
         
        //CH04: Start
        ///////////////////////////////////////////// Start: Account Review Status changes to Completed //////////////////////////////////////////////////////
        System.debug('Number Of Queuable Jobs executed:'+Limits.getQueueableJobs());
        if(accountIdsWithReviewStatusCompleted.size()>0){
            UnBlockPeriodicReviewProductsQueuableAPI unblockAPI = new UnBlockPeriodicReviewProductsQueuableAPI(accountIdsWithReviewStatusCompleted);
            System.enqueueJob(unblockAPI);

        }
        System.debug('Number Of Queuable Jobs After Review Status executed:'+Limits.getQueueableJobs());
        ///////////////////////////////////////////// END: Account Review Status changes to Completed //////////////////////////////////////////////////////

        //CH04: END
        //CH02: Start
        if(lastModifiedDataAccountId.size()>0 && System.Label.IS_BULK_UPDATE == 'FALSE'){
            //CH04: Start Added a condition for QueableJobs in if block
            if(!test.isRunningTest() && Limits.getQueueableJobs() < 1){
                CustomerCacheQueuableAPI custCache = new CustomerCacheQueuableAPI(lastModifiedDataAccountId);
                System.enqueueJob(custCache);
            }
            //CH04: END
            //CH13: Start
            else if(Limits.getQueueableJobs() == 1 && !test.isRunningTest()){
                String hour = String.valueOf(Datetime.now().hour());
                String min = String.valueOf(Datetime.now().addMinutes(1).minute());
                String ss = String.valueOf(Datetime.now().second());
                String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                CustomerCacheSchedulable custCache = new CustomerCacheSchedulable(lastModifiedDataAccountId);
                System.schedule('Customer Cache Job Running '+system.now(),nextFireTime,custCache);
            }
            //CH13: END
            
        }
        //CH02: END

        //#CH08 :Start
        /*if( accsActivatedAndNotFromLead.size()>0 ){
            updatePLAEligibiltyFields(accsActivatedAndNotFromLead);//#CH12 : comment this bloc no need any more
        }*/
        //#CH08 :End

        //#CH12 :Start
        if( accsActivated.size()>0 ){
            updatePlaRelatives(accsActivated);//#CH12
        }
        //#CH12 :End


    }

    //#CH05 : Start
    public static Schema.Describefieldresult getAccFieldInfosBasedOnFieldName(String fieldName) {
        Map<String, Schema.SObjectField> fieldMap = accountSchema.getDescribe().fields.getMap();

        for (Schema.SObjectField sfield : fieldMap.Values()) {
            Schema.Describefieldresult dfield = sfield.getDescribe();
            if( dfield.getName().equalsIgnoreCase(fieldName) ){
                return dfield;
            }
        }
        return null;
    }
    //#CH05 : End

    //#CH08 : Start //#CH12 : comment this function no need any more
    /*public static void updatePLAEligibiltyFields( List<Account> accsActivatedAndNotFromLead ) {
        
        Set<String> idNumbers = new Set<String>();
        Set<String> mobNums = new Set<String>();
        Map<String,Account> mapAccByIdNumber = new Map<String,Account>(); 
        Map<String,Account> mapAccByMobNum = new Map<String,Account>(); 
        List<Account> accToUpdate = new List<Account>(); 
        for(Account acc : accsActivatedAndNotFromLead ){
            if(acc.Id_Number__pc != null){
                idNumbers.add(acc.Id_Number__pc);
                mapAccByIdNumber.put(acc.Id_Number__pc,acc);
            }

            if(acc.Mobile_Phone_Check__pc  != null){
                mobNums.add(acc.Mobile_Phone_Check__pc);
                mapAccByMobNum.put(acc.Mobile_Phone_Check__pc,acc);
            }
        }

        if(idNumbers.size()>0 || mobNums.size()>0){
            List<Lead> leadLst = [SELECT Id,Id_Number__c,sys_Mobile_Number__c FROM Lead WHERE RecordType.DeveloperName = 'Relative' AND ( Id_Number__c IN :idNumbers OR sys_Mobile_Number__c IN :mobNums ) ];
            for(Lead ld : leadLst){
                System.debug('Lead Founded of type Relative: '+ ld.Id );
                if( mapAccByMobNum.get(ld.sys_Mobile_Number__c) != null ){
                    System.debug('Mobile Matches --> '+ ld.sys_Mobile_Number__c );
                    Account acc = mapAccByMobNum.get(ld.sys_Mobile_Number__c);
                    Account accUpdated = new Account(Id = acc.Id);
                    accUpdated.PLA_Eligibility__pc='Yes';
                    accUpdated.PLA_Ineligibility_Reason__pc='Relatives';
                    accToUpdate.add(accUpdated);
                }
                else if( mapAccByIdNumber.get(ld.Id_Number__c) != null ){
                    System.debug('Id Number Matches --> '+ ld.Id_Number__c );
                    Account acc = mapAccByIdNumber.get(ld.Id_Number__c);
                    Account accUpdated = new Account(Id = acc.Id);
                    accUpdated.PLA_Eligibility__pc='Yes';
                    accUpdated.PLA_Ineligibility_Reason__pc='Relatives';
                    accToUpdate.add(accUpdated);
                }
            }
        }

        if( accToUpdate.size()>0 ){
            System.debug('Update Eligiilty fields for those customers -->> '+ accToUpdate);
            update accToUpdate;
        }
        
    }*/
    //#CH08 : End

    //#CH12 : Start
    public static void updatePlaRelatives(final List<Account> newRecs) {
        Map<String, String> relatedIdByIdNumber = new Map<String, String>();
        Map<String, String> relatedIdByMobileNumber = new Map<String, String>();
        Set<String> mobileNumbers = new Set<String>();
        Set<String> mobileCountryCodes = new Set<String>();

        for(Account acc : newRecs) {
            if(acc.Id_Number__pc != null){
                relatedIdByIdNumber.put(acc.Id_Number__pc,acc.Id);
            }
            if(acc.PersonMobilePhone != null && acc.Mobile_Country_Code__pc != null){
                mobileNumbers.add(acc.PersonMobilePhone);
                mobileCountryCodes.add(acc.Mobile_Country_Code__pc);
                relatedIdByMobileNumber.put(acc.Mobile_Country_Code__pc+''+acc.PersonMobilePhone,acc.Id);
            }
        }
        if(!relatedIdByIdNumber.keySet().isEmpty() || !relatedIdByMobileNumber.keySet().isEmpty() )
        {
            List<Account> accToUpdate = new List<Account>();
            List<Linked_Account__c> linkedAccToUpdate = new List<Linked_Account__c>();
            List<Linked_Account__c> lstLinkedAcc = [SELECT ID,Linked_Account__c,Relative_Customer__c,Linked_Account__r.Region_Flag__pc,Linked_Account__r.PLA_Eligibility__pc,StaffRelativesKanz__c,
                                                           Linked_Account__r.PLA_Ineligibility_Reason__pc,ID_Number__c,Mobile__c,Mobile_Country_Code__c
                                                        FROM Linked_Account__c WHERE Active__c = true AND isDeleted = false
                                                            AND ( ID_Number__c IN :relatedIdByIdNumber.keySet() 
                                                                OR  ( Mobile__c IN :mobileNumbers AND Mobile_Country_Code__c IN :mobileCountryCodes ) 
                                                            ) 
                                                    ];
            //unlink lead lookup and link  the linked account to the account lookup
            for( Linked_Account__c lnk :lstLinkedAcc ){
                String mobileNumber = lnk.Mobile_Country_Code__c+''+lnk.Mobile__c ;
                if( lnk.ID_Number__c!=null && relatedIdByIdNumber.get(lnk.ID_Number__c) != null ){
                    lnk.Relative__c = null;
                    lnk.Relative_Customer__c = relatedIdByIdNumber.get(lnk.ID_Number__c);
                    linkedAccToUpdate.add(lnk);
                }
                else if( mobileNumber !=null && relatedIdByMobileNumber.get(mobileNumber) != null ){
                    lnk.Relative__c = null;
                    lnk.Relative_Customer__c = relatedIdByMobileNumber.get(mobileNumber);
                    linkedAccToUpdate.add(lnk);
                }
            }
            
            //update the fields PLA_Eligibility__pc & PLA_Ineligibility_Reason__pc of the activated account based on region flag and other conditions
            for( Linked_Account__c lnk :linkedAccToUpdate ){
                Account accUpdated = new Account(Id = lnk.Relative_Customer__c);
                if( lnk.Linked_Account__r.Region_Flag__pc == 'Jordan' ){
                    accUpdated.PLA_Eligibility__pc='Yes';
                    if( lnk.Linked_Account__r.PLA_Eligibility__pc == 'Yes' && 
                        (lnk.Linked_Account__r.PLA_Ineligibility_Reason__pc == 'Probationary Staff' || lnk.Linked_Account__r.PLA_Ineligibility_Reason__pc == 'Resigned Staff')
                    ){
                        if(lnk.Linked_Account__r.PLA_Ineligibility_Reason__pc == 'Probationary Staff'){
                            accUpdated.PLA_Ineligibility_Reason__pc ='Probationary Relatives';
                        }else{
                            accUpdated.PLA_Ineligibility_Reason__pc ='Resigned Relatives';
                        }
                    }else{
                        accUpdated.PLA_Ineligibility_Reason__pc='Relatives';
                    }
                }else if(lnk.StaffRelativesKanz__c == 'Exclude from the Raffles' && lnk.Linked_Account__r.Region_Flag__pc != 'Jordan'){
                    accUpdated.PLA_Eligibility__pc='No';
                    accUpdated.PLA_Ineligibility_Reason__pc='Not Interested Relative';
                }
                else {//for Bahrain Staff
                    accUpdated.PLA_Eligibility__pc='Yes';
                    accUpdated.PLA_Ineligibility_Reason__pc='Relatives';
                }
                accToUpdate.add(accUpdated);
            }

            if( accToUpdate.size()>0 ){
                update accToUpdate;
            }
            if(linkedAccToUpdate.size()>0){
                update linkedAccToUpdate;
            }
        }
    }
    //#CH12 : End
}