/*
Author : Ashish Pandey
Date : 09/05/2020
Description : This is a global class to handle all Lead triggers
#CH01# Added #04-11-2021# Duplicates are now checked by region - YZ.
#CH02# Added #Jahangeer Mohammed# #17-09-2023# Logic to Check Duplicate with Person Account Email, Mobile, ID Number, & Proof of ID Number
#CH03# AITOGRAM OMAR 13/04/2026 Validates Lead records against blacklisted and closed customer accounts for jordan only  (NBA-4467)
*/

global with sharing class LeadTriggerHandler extends ABC_TriggerHandler{
    /*@AuraEnabled(cacheable=true)
    public static Lead getSingleLead() {
        return [
            SELECT Id, Name, OwnerId FROM Lead WITH SECURITY_ENFORCED LIMIT 1
        ];
    } */
    
    protected override void beforeInsert()
    {
        checkDuplicates('insert');
         // #CH03# Start
        checkBlacklistedAndClosedAccounts((List<Lead>)Trigger.new);
        // #CH03# End
    }
    protected override void afterInsert()
    { 
    }
    protected override void beforeUpdate()
    {
        beforeUpdate(trigger.new);
    }    
    protected override void afterUpdate()
    {       
        afterUpdate(trigger.new);
    }
    
    public void checkDuplicates(String DMLType)
    {
        Map<String, Set<String>> mapEmail = new Map<String, Set<String>>();
        Map<String, Set<String>> mapPhone = new Map<String, Set<String>>();
        //CH02: Start
        Map<String, Set<String>> mapPhoneWithoutCountryCode = new Map<String, Set<String>>();
        //CH02: END
        Map<String, Set<String>> mapIDNumber = new Map<String, Set<String>>();
        Map<String, Set<String>> mapPOAIDNumber = new Map<String, Set<String>>();
        
        Set<String> setEmail = new Set<String>();
        Set<String> setPhone = new Set<String>();
        //CH02: Start
        Set<String> setPhoneWithoutCountryCode = new Set<String>();
        //CH02: END
        Set<String> setIDNumber = new Set<String>();
        Set<String> setPOAIDNumber = new Set<String>();
        
        List<Lead> lstLead = new List<Lead>();
        List<Account> lstAccount = new List<Account>();
        Boolean checkDuplicate = False;
        String queryDuplicates = '';
        Set<String> querySet = new Set<String>();        
        
        if(DMLType == 'insert') // #CH01#
        {
            for(Lead objLd : (List<Lead>)Trigger.new)
            {
                if (objLd.Region_Flag__c!=null) { // #CH01#
                    if(objLd.email != null && objLd.email != ''){
                        if (mapEmail.get(objLd.Region_Flag__c)==null) {
                            setEmail = new Set<String>();
                        }
                        else {
                            setEmail = mapEmail.get(objLd.Region_Flag__c);
                        }
                        setEmail.add(objLd.email);
                        mapEmail.put(objLd.Region_Flag__c, setEmail);
                    }
                    if(objLd.MobilePhone != null && objLd.MobilePhone != ''){                    
                        if (mapPhone.get(objLd.Region_Flag__c)==null) {
                            setPhone = new Set<String>();
                            //CH02: Start
                            setPhoneWithoutCountryCode = new Set<String>();
                            //CH02: END
                        }
                        else {
                            setPhone = mapPhone.get(objLd.Region_Flag__c);
                            //CH02: Start
                            setPhoneWithoutCountryCode = mapPhoneWithoutCountryCode.get(objLd.Region_Flag__c);
                            //CH02: END
                        }
                        setPhone.add(objLd.Mobile_Country_Code__c + objLd.MobilePhone);
                        mapPhone.put(objLd.Region_Flag__c, setPhone);
                        //CH02: Start
                        setPhoneWithoutCountryCode.add(objLd.MobilePhone);
                        mapPhoneWithoutCountryCode.put(objLd.Region_Flag__c, setPhoneWithoutCountryCode);
                        //CH02: END
                    }
                    if(objLd.ID_Number__c != null && objLd.ID_Number__c != ''){                    
                        if (mapIDNumber.get(objLd.Region_Flag__c)==null) {
                            setIDNumber = new Set<String>();
                        }
                        else {
                            setIDNumber = mapIDNumber.get(objLd.Region_Flag__c);
                        }
                        setIDNumber.add(objLd.ID_Number__c);
                        mapIDNumber.put(objLd.Region_Flag__c, setIDNumber);
                    }
                    if(objLd.Proof_of_Address_ID_Number__c != null && objLd.Proof_of_Address_ID_Number__c != ''){                    
                        if (mapPOAIDNumber.get(objLd.Region_Flag__c)==null) {
                            setPOAIDNumber = new Set<String>();
                        }
                        else {
                            setPOAIDNumber = mapPOAIDNumber.get(objLd.Region_Flag__c);
                        }
                        setPOAIDNumber.add(objLd.Proof_of_Address_ID_Number__c);
                        mapPOAIDNumber.put(objLd.Region_Flag__c, setPOAIDNumber);
                    }
                }
            }
        }
        //System.debug('*** mapEmail '+mapEmail);
        //System.debug('*** mapPhone '+mapPhone);
        //System.debug('*** mapIDNumber '+mapIDNumber);
        //System.debug('*** mapPOAIDNumber '+mapPOAIDNumber);
        Set<String> regions = new Set<String>();
        if (!mapEmail.isEmpty()) {
            regions.addAll(mapEmail.keySet());
        }
        if (!mapPhone.isEmpty()) {
            regions.addAll(mapPhone.keySet());
        }
        if (!mapIDNumber.isEmpty()) {
            regions.addAll(mapIDNumber.keySet());
        }
        if (!mapPOAIDNumber.isEmpty()) {
            regions.addAll(mapPOAIDNumber.keySet());
        }
        if(!regions.isEmpty()){
            for (String region:regions) {
                // Lead query                
                queryDuplicates = '';
                if (mapEmail.get(region)!=null && !mapEmail.get(region).isEmpty()) {
                    querySet = mapEmail.get(region);
                    queryDuplicates += queryDuplicates!='' ? ' OR ' : '';
                    queryDuplicates += 'email in (\''+extractFromSet(querySet)+'\')';
                }
                if (mapPhone.get(region)!=null && !mapPhone.get(region).isEmpty()) {
                    querySet = mapPhone.get(region);
                    queryDuplicates += queryDuplicates!='' ? ' OR ' : '';
                    queryDuplicates += 'sys_Mobile_Number__c in (\''+extractFromSet(querySet)+'\')';
                }
                if (mapIDNumber.get(region)!=null && !mapIDNumber.get(region).isEmpty()) {
                    querySet = mapIDNumber.get(region);
                    queryDuplicates += queryDuplicates!='' ? ' OR ' : '';
                    queryDuplicates += 'ID_Number__c in (\''+extractFromSet(querySet)+'\')';
                }
                if (mapPOAIDNumber.get(region)!=null && !mapPOAIDNumber.get(region).isEmpty()) {
                    querySet = mapPOAIDNumber.get(region);
                    queryDuplicates += queryDuplicates!='' ? ' OR ' : '';
                    queryDuplicates += 'Proof_of_Address_ID_Number__c in (\''+extractFromSet(querySet)+'\')';
                }
                queryDuplicates += ') and Region_Flag__c=:region and isConverted = false';
                queryDuplicates = 'Select id, email, MobilePhone, ID_Number__c, Proof_of_Address_ID_Number__c, OwnerId from Lead where (' + queryDuplicates;
                //System.debug('*** queryDuplicates Lead '+queryDuplicates);
                lstLead = Database.query(queryDuplicates);                
                        
                // Account query    
                /*
                queryDuplicates = '';
                if (mapEmail.get(region)!=null && !mapEmail.get(region).isEmpty()) {
                    querySet = mapEmail.get(region);
                    queryDuplicates += queryDuplicates!='' ? ' OR ' : '';
                    queryDuplicates += 'PersonEmail in (\''+extractFromSet(querySet)+'\')';
                }
                if (mapPhone.get(region)!=null && !mapPhone.get(region).isEmpty()) {
                    querySet = mapPhone.get(region);
                    queryDuplicates += queryDuplicates!='' ? ' OR ' : '';
                    queryDuplicates += 'Mobile_Phone_Check__pc in (\''+extractFromSet(querySet)+'\')';
                }
                if (mapIDNumber.get(region)!=null && !mapIDNumber.get(region).isEmpty()) {
                    querySet = mapIDNumber.get(region);
                    queryDuplicates += queryDuplicates!='' ? ' OR ' : '';
                    queryDuplicates += 'ID_Number__pc in (\''+extractFromSet(querySet)+'\')';
                }
                if (mapPOAIDNumber.get(region)!=null && !mapPOAIDNumber.get(region).isEmpty()) {
                    querySet = mapPOAIDNumber.get(region);
                    queryDuplicates += queryDuplicates!='' ? ' OR ' : '';
                    queryDuplicates += 'Proof_of_Address_Id__pc in (\''+extractFromSet(querySet)+'\')';
                }
                queryDuplicates += ') and Region_Flag__c=:region';
                queryDuplicates = 'Select id, PersonEmail, Mobile_Phone_Check__pc, OwnerId, ID_Number__pc, Proof_of_Address_Id__pc from Account where (' + queryDuplicates;           
                //System.debug('*** queryDuplicates Account '+queryDuplicates);
                lstAccount = Database.query(queryDuplicates);
                */

                if (lstLead.size()>0 || lstAccount.size()>0) {
                    checkDuplicate = True;
                    for(Lead ld : (List<Lead>)trigger.New)
                    {
                        if(lstLead.size()>0){
                            ld.addError('Lead is already Registered as a Lead with ILA.');
                        }
                        /*else if(lstAccount.size()>0)
                        {
                            ld.addError('Lead is already Registered as a Prospect/ Customer with ILA.');
                        }*/
                    }
                }
            } //for loop Ends
        } //If Ends
        //CH02: Start
        if(System.Label.AVOID_DUPLICATE.equalsIgnoreCase('true'))
        {
            Set<String> setOfEmailsBH = new Set<String>();
            Set<String> setOfEmailsJO = new Set<String>();
            Set<String> setOfMobilesBH = new Set<String>();
            Set<String> setOfMobilesJO = new Set<String>();
            Set<String> setOfIDNumberBH = new Set<String>();
            Set<String> setOfIDNumberJO = new Set<String>();
            Set<String> setOfPOIDNumberBH = new Set<String>();
            Set<String> setOfPOIDNumberJO = new Set<String>();
            
            for(Lead leadObj : (List<Lead>)Trigger.new){
                if(leadObj.Region_Flag__c == 'Bahrain' && leadObj.Email != null && leadObj.Email != ''){
                    if(mapEmail.containsKey(leadObj.Region_Flag__c)){
                        setOfEmailsBH = mapEmail.get(leadObj.Region_Flag__c);
                    }
                }
                if(leadObj.Region_Flag__c == 'Jordan' && leadObj.Email != null && leadObj.Email != ''){
                    if(mapEmail.containsKey(leadObj.Region_Flag__c)){
                        setOfEmailsJO = mapEmail.get(leadObj.Region_Flag__c);
                    }
                }
                if(leadObj.Region_Flag__c == 'Bahrain' && leadObj.MobilePhone != null && leadObj.MobilePhone != ''){
                    if(mapPhoneWithoutCountryCode.containsKey(leadObj.Region_Flag__c)){
                        setOfMobilesBH = mapPhoneWithoutCountryCode.get(leadObj.Region_Flag__c);
                    }
                }
                if(leadObj.Region_Flag__c == 'Jordan' && leadObj.MobilePhone != null && leadObj.MobilePhone != ''){
                    if(mapPhoneWithoutCountryCode.containsKey(leadObj.Region_Flag__c)){
                        setOfMobilesJO = mapPhoneWithoutCountryCode.get(leadObj.Region_Flag__c);
                    }
                }
                if(leadObj.Region_Flag__c == 'Bahrain' && leadObj.ID_Number__c != null && leadObj.ID_Number__c != ''){
                    if(mapIDNumber.containsKey(leadObj.Region_Flag__c)){
                        setOfIDNumberBH = mapIDNumber.get(leadObj.Region_Flag__c);
                    }
                }
                if(leadObj.Region_Flag__c == 'Jordan' && leadObj.ID_Number__c != null && leadObj.ID_Number__c != ''){
                    if(mapIDNumber.containsKey(leadObj.Region_Flag__c)){
                        setOfIDNumberJO = mapIDNumber.get(leadObj.Region_Flag__c);
                    }
                }
                if(leadObj.Region_Flag__c == 'Bahrain' && leadObj.Proof_of_Address_ID_Number__c != null && leadObj.Proof_of_Address_ID_Number__c != ''){
                    if(mapPOAIDNumber.containsKey(leadObj.Region_Flag__c)){
                        setOfPOIDNumberBH = mapPOAIDNumber.get(leadObj.Region_Flag__c);
                    }
                }
                if(leadObj.Region_Flag__c == 'Jordan' && leadObj.Proof_of_Address_ID_Number__c != null && leadObj.Proof_of_Address_ID_Number__c != ''){
                    if(mapPOAIDNumber.containsKey(leadObj.Region_Flag__c)){
                        setOfPOIDNumberJO = mapPOAIDNumber.get(leadObj.Region_Flag__c);
                    }
                }
                
                
            } //for loop Ends
            
            //////////////////////////////////////////////////// Start: Checking Lead Email with Person Account Email //////////////////////////////////////////////////////////
            if(!setOfEmailsBH.isEmpty()){
                System.debug('Email in Bahrain:'+setOfEmailsBH);
                List<Account> lstAcct = [Select id,PersonEmail,Region_Flag__pc from Account where PersonEmail =: setOfEmailsBH AND Region_Flag__pc = 'Bahrain' AND Archived__pc = false AND RecordType.Name != 'Prospect'];
                System.debug('List of Account in Email:'+lstAcct);
                
                for(Lead leadObj : (List<Lead>)Trigger.new){
                    if(lstAcct.size()>0){
                        leadObj.addError('Lead is already Registered With Same Email as a Customer with ILA Bahrain.');
                    }
                }
                List<Account> lstProspectAccts = [Select id,PersonEmail,Region_Flag__pc from Account where PersonEmail =: setOfEmailsBH AND Region_Flag__pc = 'Bahrain' AND RecordType.Name != 'Customer'];
                for(Lead leadObj : (List<Lead>)Trigger.new){
                    if(lstProspectAccts.size()>0){
                        leadObj.addError('Lead is already Registered With Same Email as a Prospect with ILA Bahrain.');
                    }
                }
            }
            
            if(!setOfEmailsJO.isEmpty()){
                List<Account> lstAcctJO = [Select id,PersonEmail,Region_Flag__pc from Account where PersonEmail =: setOfEmailsJO AND Region_Flag__pc = 'Jordan' AND Archived__pc = false AND RecordType.Name != 'Prospect'];
                for(Lead leadObj : (List<Lead>)Trigger.new){
                    if(lstAcctJO.size()>0){
                        leadObj.addError('Lead is already Registered With Same Email as a Customer with ILA Jordan.');
                    }
                }
                List<Account> lstProspectAcctJO = [Select id,PersonEmail,Region_Flag__pc from Account where PersonEmail =: setOfEmailsJO AND Region_Flag__pc = 'Jordan' AND RecordType.Name != 'Customer'];
                for(Lead leadObj : (List<Lead>)Trigger.new){
                    if(lstProspectAcctJO.size()>0){
                        leadObj.addError('Lead is already Registered With Same Email as a Prospect with ILA Jordan.');
                    }
                }
            }
            //////////////////////////////////////////////////// END: Checking Lead Email with Person Account Email //////////////////////////////////////////////////////////
            
            //////////////////////////////////////////////////// Start: Checking Lead Mobile Phone with Person Account Mobile ////////////////////////////////////////////////////////////////////
            
            if(!setOfMobilesBH.isEmpty()){
                System.debug('Mobile in Bahrain:'+setOfMobilesBH);
                List<Account> lstAcct = [Select id,PersonMobilePhone,Region_Flag__pc from Account where PersonMobilePhone =: setOfMobilesBH AND Region_Flag__pc = 'Bahrain' AND Archived__pc = false AND RecordType.Name != 'Prospect'];
                System.debug('List of Account in Mobile:'+lstAcct);
                for(Lead leadObj : (List<Lead>)Trigger.new){
                    if(lstAcct.size()>0){
                        leadObj.addError('Lead is already Registered With Same Mobile as a Customer with ILA Bahrain.');
                    }
                }
                List<Account> lstProspectAccts = [Select id,PersonMobilePhone,Region_Flag__pc from Account where PersonMobilePhone =: setOfMobilesBH AND Region_Flag__pc = 'Bahrain' AND RecordType.Name != 'Customer'];
                for(Lead leadObj : (List<Lead>)Trigger.new){
                    if(lstProspectAccts.size()>0){
                        leadObj.addError('Lead is already Registered With Same Mobile as a Prospect with ILA Bahrain.');
                    }
                }
            }
            
            if(!setOfMobilesJO.isEmpty()){
                List<Account> lstAcctJO = [Select id,PersonMobilePhone,Region_Flag__pc from Account where PersonMobilePhone =: setOfMobilesJO AND Region_Flag__pc = 'Jordan' AND Archived__pc = false AND RecordType.Name != 'Prospect'];
                for(Lead leadObj : (List<Lead>)Trigger.new){
                    if(lstAcctJO.size()>0){
                        leadObj.addError('Lead is already Registered With Same Mobile as a Customer with ILA Jordan.');
                    }
                }
                List<Account> lstProspectAcctJO = [Select id,PersonMobilePhone,Region_Flag__pc from Account where PersonMobilePhone =: setOfMobilesJO AND Region_Flag__pc = 'Jordan' AND RecordType.Name != 'Customer'];
                for(Lead leadObj : (List<Lead>)Trigger.new){
                    if(lstProspectAcctJO.size()>0){
                        leadObj.addError('Lead is already Registered With Same Mobile as a Prospect with ILA Jordan.');
                    }
                }
            }
            
            //////////////////////////////////////////////////// END: Checking Lead Mobile Phone with Person Account Mobile ////////////////////////////////////////////////////////////////////
            
            /////////////////////////////////////////////////// Start: Checking Lead ID Number with Person Account ID Number ///////////////////////////////////////////////////////////////////
            
            if(!setOfIDNumberBH.isEmpty()){
                List<Account> lstAcct = [Select id,ID_Number__pc,Region_Flag__pc from Account where ID_Number__pc =: setOfIDNumberBH AND Region_Flag__pc = 'Bahrain' AND Archived__pc = false AND RecordType.Name != 'Prospect'];
                System.debug('List of Account in ID Number:'+lstAcct);
                for(Lead leadObj : (List<Lead>)Trigger.new){
                    if(lstAcct.size()>0){
                        leadObj.addError('Lead is already Registered with same ID Number as a Customer with ILA Bahrain.');
                    }
                }
                List<Account> lstProspectAccts = [Select id,ID_Number__pc,Region_Flag__pc from Account where ID_Number__pc =: setOfIDNumberBH AND Region_Flag__pc = 'Bahrain' AND RecordType.Name != 'Customer'];
                for(Lead leadObj : (List<Lead>)Trigger.new){
                    if(lstProspectAccts.size()>0){
                        leadObj.addError('Lead is already Registered with same ID Number as a Prospect with ILA Bahrain.');
                    }
                }
            } 
            
            if(!setOfIDNumberJO.isEmpty()){
                List<Account> lstAcctJO = [Select id,ID_Number__pc,Region_Flag__pc from Account where ID_Number__pc =: setOfIDNumberJO AND Region_Flag__pc = 'Jordan' AND Archived__pc = false AND RecordType.Name != 'Prospect'];
                for(Lead leadObj : (List<Lead>)Trigger.new){
                    if(lstAcctJO.size()>0){
                        leadObj.addError('Lead is already Registered with same ID Number as a Customer with ILA Jordan.');
                    }
                }
                List<Account> lstProspectAcctJO = [Select id,ID_Number__pc,Region_Flag__pc from Account where ID_Number__pc =: setOfIDNumberJO AND Region_Flag__pc = 'Jordan' AND RecordType.Name != 'Customer'];
                for(Lead leadObj : (List<Lead>)Trigger.new){
                    if(lstProspectAcctJO.size()>0){
                        leadObj.addError('Lead is already Registered with same ID Number as a Prospect with ILA Jordan.');
                    }
                }
            }
            /////////////////////////////////////////////////// END: Checking Lead ID Number with Person Account ID Number ///////////////////////////////////////////////////////////////////
            
            /////////////////////////////////////////////////// Start: Checking POID Number with Person Account POID Number //////////////////////////////////////////////////////////////////
            if(!setOfPOIDNumberBH.isEmpty()){
                List<Account> lstAcct = [Select id,Proof_of_Address_Id__pc,Region_Flag__pc from Account where Proof_of_Address_Id__pc =: setOfPOIDNumberBH AND Region_Flag__pc = 'Bahrain' AND Archived__pc = false AND RecordType.Name != 'Prospect'];
                System.debug('List of Account in ID Number:'+lstAcct);
                for(Lead leadObj : (List<Lead>)Trigger.new){
                    if(lstAcct.size()>0){
                        leadObj.addError('Lead is already Registered with same Proof of Address ID Number as a Customer with ILA Bahrain.');
                    }
                }
                List<Account> lstProspectAccts = [Select id,Proof_of_Address_Id__pc,Region_Flag__pc from Account where Proof_of_Address_Id__pc =: setOfPOIDNumberBH AND Region_Flag__pc = 'Bahrain' AND RecordType.Name != 'Customer'];
                for(Lead leadObj : (List<Lead>)Trigger.new){
                    if(lstProspectAccts.size()>0){
                        leadObj.addError('Lead is already Registered with same Proof of Address ID Number as a Prospect with ILA Bahrain.');
                    }
                }
            } 
            
            /*
            if(!setOfPOIDNumberJO.isEmpty()){
                List<Account> lstAcctJO = [Select id,Proof_of_Address_Id__pc,Region_Flag__pc from Account where Proof_of_Address_Id__pc =: setOfPOIDNumberJO AND Region_Flag__pc = 'Jordan' AND Archived__pc = false AND RecordType.Name != 'Prospect'];
                for(Lead leadObj : (List<Lead>)Trigger.new){
                    if(lstAcctJO.size()>0){
                        leadObj.addError('Lead is already Registered with same Proof of Address ID Number as a Customer with ILA Jordan.');
                    }
                }
                List<Account> lstProspectAcctJO = [Select id,Proof_of_Address_Id__pc,Region_Flag__pc from Account where Proof_of_Address_Id__pc =: setOfPOIDNumberJO AND Region_Flag__pc = 'Jordan' AND RecordType.Name != 'Customer'];
                for(Lead leadObj : (List<Lead>)Trigger.new){
                    if(lstProspectAcctJO.size()>0){
                        leadObj.addError('Lead is already Registered with same Proof of Address ID Number as a Prospect with ILA Jordan.');
                    }
                }
            } */
            
            /////////////////////////////////////////////////// END: Checking POID Number with Person Account POID Number //////////////////////////////////////////////////////////////////
        }
        //CH02: END
    }
    
    public void beforeUpdate(List<Lead> TriggerList){
        Map<Id, List<Content__c>> mapleadIDtolstContent = new Map<Id, List<Content__c>>();
        for(Lead objLd : [Select id, ownerID, Convert_Lead_to_Prospect__c, (Select id, Scan_Type__c, Upload_Type__c, Document_Type__c, has_Attachment__c from Content__r) from Lead where id in: TriggerList])
        {
            mapleadIDtolstContent.put(objLd.id, objLd.Content__r);
        }
        
        for(Lead objLd : TriggerList)
        {
            Lead oldLead = (Lead)Trigger.oldMap.get(objLd.id);
            if(oldLead.Convert_Lead_to_Prospect__c != objLd.Convert_Lead_to_Prospect__c && objLd.Convert_Lead_to_Prospect__c == true )
            {
                objLd.OwnerID = userinfo.getUserID(); 
                system.debug('---> content size 22--> '+mapleadIDtolstContent.get(objLd.id).size());
                if(mapleadIDtolstContent.get(objLd.id).size()>0)
                {
                    for(Content__c objCon : mapleadIDtolstContent.get(objLd.id))
                    {
                        if((objCon.Upload_Type__c == null || objCon.Scan_Type__c == null || objCon.Document_Type__c == null || objCon.has_Attachment__c == false))
                        {
                            objLd.addError('Please ensure that the Lead has atleast one supporting Content with \'Scan Type, Document Type, Upload Type and Attachment\' filled');
                        }
                    }
                }
                else{
                    objLd.addError('There should be atleast one supporting Content to convert the Lead to Prospect.');
                }
            }
        }
    }
    
    public void afterUpdate(List<Lead> TriggerList){
        List<Content__c> lstContent = new List<Content__c>();
        List<Content__c> tobeUpdatedlstContent = new List<Content__c>();
        set<id> convertedleadids = new set<id>();
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        List<Database.LeadConvert> leadsToBeConverted = new List<Database.LeadConvert>();
        Database.LeadConvert leadConvert;
        for(Lead objLd : TriggerList)
        {
            Lead oldLead = (Lead)Trigger.oldMap.get(objLd.id);
            if(oldLead.Convert_Lead_to_Prospect__c != objLd.Convert_Lead_to_Prospect__c && objLd.Convert_Lead_to_Prospect__c == true)
            {
                leadConvert = new database.LeadConvert();
                leadConvert.setLeadId(objLd.Id);
                leadConvert.setConvertedStatus(convertStatus.MasterLabel);
                leadConvert.setDoNotCreateOpportunity(true);
                leadsToBeConverted.add(leadConvert);
            }
        }
        if(leadsToBeConverted.size()>0)
        {
            List<Database.LeadConvertResult> leadConvertResults = Database.ConvertLead(leadsToBeConverted);
            for(Database.LeadConvertResult lCR : leadConvertResults){
                convertedleadids.add(lCR.getLeadId());
            }
            if(!convertedleadids.isEmpty())
            {
                lstContent = [select Lead__c, Lead__r.ConvertedAccountId, Person__c from Content__c where Lead__c in : convertedleadids];
      
                for(Content__c objCon: lstContent){
                    objCon.Person__c = objCon.Lead__r.ConvertedAccountId;
                    tobeUpdatedlstContent.add(objCon);
                }
                if(tobeUpdatedlstContent.size() >0){
                    update tobeUpdatedlstContent;
                }
            }
        }           
    }
    
    ////////////////////////////////// AURA enabled methods //////////////////////////////////////////
    @AuraEnabled
    public static void setOwnerAsQueue(Id recordid){
        Lead objLead = [select id,OwnerId, Email, MobilePhone, ID_Number__c, Proof_of_Address_ID_Number__c, Region_Flag__c from Lead where id =: recordid];
        String queueName = 'Manual Onboarding - Checker Queue';
        if (objLead.Region_Flag__c=='Bahrain') {
            queueName = 'Manual Onboarding - Checker Queue';        
        }
        else if (objLead.Region_Flag__c=='Jordan') {
            queueName = 'Jordan Manual Onboarding - Checker Queue'; 
        }
        Group checkerQueue = [Select Id,name from Group where Type = 'Queue' and name=:queueName];
        
        objLead.OwnerId = checkerQueue.Id;
        objLead.Status = 'Data Validation - Checker';
        objLead.Lead_Maker__c = userinfo.getUserId();
        update objLead;
    }   
    
    @AuraEnabled
    public static void setMakerQueueAsOwner(Id recIDSF, String referCommentsSF){
        Lead objLead = [select id,OwnerId, Email, MobilePhone, ID_Number__c, Proof_of_Address_ID_Number__c,Checker_s_Comment__c, Region_Flag__c from Lead where id =: recIDSF];
        String queueName = 'Manual Onboarding - Maker Queue';
        if (objLead.Region_Flag__c=='Bahrain') {
            queueName = 'Manual Onboarding - Maker Queue';        
        }
        else if (objLead.Region_Flag__c=='Jordan') {
            queueName = 'Jordan Manual Onboarding - Maker Queue'; 
        }
        Group MakerQueue = [Select Id,name from Group where Type = 'Queue' and name=:queueName];
        system.debug('---> REf Comments'+referCommentsSF);
        system.debug('---> Lead IDDD -> '+recIDSF);
        objLead.OwnerId = MakerQueue.Id;
        objLead.Status = 'Referred Back by - Checker';
        objLead.Checker_s_Comment__c = referCommentsSF;
        update objLead;
    }  
    
    @AuraEnabled
    public static void setOwnerAsSelf(Id recID){
        Lead objLead = [select id,OwnerId, Email, MobilePhone, ID_Number__c, Proof_of_Address_ID_Number__c from Lead where id =: recID];
        
        objLead.OwnerId = UserInfo.getUserId();
        //objLead.Status = 'Refer Back by Checker';
        update objLead;
    }

    private static String extractFromSet(Set<String> setItems){        
        List<String> queryList = new List<String>();
        queryList.addAll(setItems);
        return String.escapeSingleQuotes(String.join(queryList,'\',\''));
    }

      // #CH03# Start
  
    private void checkBlacklistedAndClosedAccounts(List<Lead> leadList) {
        Id manualOnboardingRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
                                       .get('Manual_Onboarding')?.getRecordTypeId();
        
        if (manualOnboardingRecTypeId == null) {
            return;
        }

        Set<String> leadEmails = new Set<String>();
        List<Lead> leadsToValidate = new List<Lead>();

        for (Lead ld : leadList) {
            if (ld.RecordTypeId == manualOnboardingRecTypeId && ld.Region_Flag__c == 'Jordan' && String.isNotBlank(ld.Email)) {
                leadEmails.add(ld.Email.toLowerCase());
                leadsToValidate.add(ld);
            }
        }
        if (leadEmails.isEmpty()) {
            return;
        }
 
        List<Account> matchingAccounts = [SELECT Id, PersonEmail 
                            FROM Account 
                            WHERE PersonEmail IN :leadEmails 
                            AND Blacklisted__c = true 
                            AND CustomerStatus__c = 'Closed'
                            AND Region_Flag__c = 'Jordan'];

        if (matchingAccounts.isEmpty()) {
            return;
        }

        Map<String, Account> matchingAccountsMap = new Map<String, Account>();
        for (Account acc : matchingAccounts) {
            if (String.isNotBlank(acc.PersonEmail)) {
                matchingAccountsMap.put(acc.PersonEmail.toLowerCase(), acc);
            }
        }

        for (Lead ld : leadsToValidate) {
            if (matchingAccountsMap.containsKey(ld.Email.toLowerCase())) {
                ld.Email.addError('This email cannot be used for onboarding because the customer is blacklisted and closed.');
            }
        }
    }
    // #CH03# End
}