/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 29-03-2023
*       Change History: 
* 						CH01: Added Logic to Check Passport documents like Face Photo & Front Photo(CRM23-234)
*        
*/
public class ReprocessWathiqForm {
    public static void checkWathiqFormOrCPRFormAvailable(List<Case> checkWathiqFormListCases, Set<Id> checkWathiqFormAccIds){
        Map<Id,String> mapAccountRelatedWathiqForm = new Map<Id,String>();
        Map<Id,String> mapAccountRelatedFacePhoto = new Map<Id,String>();
        Map<Id,String> mapAccountRelatedFrontPhoto = new Map<Id,String>();
        Map<Id,String> mapAccountRelatedBackPhoto = new Map<Id,String>();
        
        List<Case> caseLstWithWathiqOrCPRForm = new List<Case>();
        Set<Id> accIdsWithoutWathiqFormWithoutCPR = new Set<Id>();
        List<Case> wathiqOrCPRFormAvailableList = new List<Case>();
        Set<Id> setCaseIdContainsWathiqFormOrCPRForm = new Set<Id>();
        List<Account> accListWithoutWathiqFormWithoutCPR = new List<Account>();
        Set<Id> setCaseIdsWithWathiqAcceptedANDIDVHashAccepted = new Set<Id>();
        Map<Id,Boolean> mapRelatedToWathiqFormAvailable = new Map<Id,Boolean>();
        Map<Id,Boolean> mapRelatedToCPRFormAvailable = new Map<Id,Boolean>();
        
        if(!checkWathiqFormAccIds.isEmpty()){
            Map<Id,List<Content__c>> mapAccountRelatedListFacePhoto = new Map<Id,List<Content__c>>();
            Map<Id,List<Content__c>> mapAccToContent = new Map<Id,List<Content__c>>();
            //CH01: Start
            Map<Id,List<Content__c>> mapAccountRelatedListOfPassportFacePhoto = new Map<Id,List<Content__c>>();
            Map<Id,String> mapAccountRelatedListOfPassportFrontPhoto = new Map<Id,String>();
            //CH01: END
            //CH01: Start Added Passport condition & Document_Country__c in SOQL
            List<Content__c> lstContent = [SELECT Name,Document_Type__c,Document_Expiry_Date__c,Document_Country__c, Person__c,Scan_Type__c,Validity__c,Verification_Status__c,Image_Type__c,Similarity__c FROM Content__c where 
                                           Person__c =: checkWathiqFormAccIds AND Document_Type__c IN('Wathiq Consent Form','Bahraini ID','Passport') order by CreatedDate ASC];
            //CH01: END
            if(lstContent.size()>0){ //Checking for List of Content/Documents related to the Customer
                for(Content__c ct : lstContent){ //Content For Loop Start
                    if(mapAccToContent.containsKey(ct.Person__c)){
                        List<Content__c> contentList =  mapAccToContent.get(ct.Person__c);
                        contentList.add(ct);
                        mapAccToContent.put(ct.Person__c,contentList);
                    }
                    else{
                        mapAccToContent.put(ct.Person__c,new List<Content__c>{ct});
                    }
                } //Content For Loop END
            } //if End
            if(checkWathiqFormListCases.size()>0){
                for(Case c : checkWathiqFormListCases){ //Outer for loop Start
                    if(mapAccToContent.size()>0 && mapAccToContent.containsKey(c.AccountId)){ //Checking Documents related AccountId with Case related Account Id.
                        System.debug('After Update Checking Acc related docs Map');
                        List<Content__c> cntList = mapAccToContent.get(c.AccountId);
                        if(cntList.size()>0){ //If Start
                            System.debug('After Update Content List Related to Account:'+cntList);
                            for(Content__c ct : cntList){ //Checking Wathiq Form or CPR Form on Customer
                                if(ct.Document_Type__c == 'Wathiq Consent Form'){
                                    mapAccountRelatedWathiqForm.put(ct.Person__c,ct.Document_Type__c);
                                    break;
                                }
                                else if(ct.Document_Type__c == 'Bahraini ID' && ct.Image_Type__c == 'Face' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH' && ct.Scan_Type__c == 'POI'){
                                    if(mapAccountRelatedListFacePhoto.containsKey(ct.Person__c)){
                                        List<Content__c> contentListRecordsHavingMultipleFaces =  mapAccountRelatedListFacePhoto.get(ct.Person__c); 
                                        contentListRecordsHavingMultipleFaces.add(ct);
                                        mapAccountRelatedListFacePhoto.put(ct.Person__c,contentListRecordsHavingMultipleFaces);
                                    }
                                    else{
                                        mapAccountRelatedListFacePhoto.put(ct.Person__c,new List<Content__c>{ct});
                                    }
                                    
                                }
                                else if(ct.Document_Type__c == 'Bahraini ID' && ct.Image_Type__c == 'Front' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH' && ct.Scan_Type__c == 'POI'){
                                    mapAccountRelatedFrontPhoto.put(ct.Person__c,ct.Image_Type__c);
                                }
                                else if(ct.Document_Type__c == 'Bahraini ID' && ct.Image_Type__c == 'Back' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH' && ct.Scan_Type__c == 'POI'){
                                    mapAccountRelatedBackPhoto.put(ct.Person__c,ct.Image_Type__c);
                                }
                                //CH01: Start
                                else if(ct.Document_Type__c == 'Passport' && ct.Image_Type__c == 'Face' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH' && ct.Document_Country__c == 'BH' && ct.Scan_Type__c == 'POI'){
                                    if(mapAccountRelatedListOfPassportFacePhoto.containsKey(ct.Person__c)){
                                        List<Content__c> contentListRecordsHavingMultipleFacesOfPassport =  mapAccountRelatedListOfPassportFacePhoto.get(ct.Person__c); 
                                    	contentListRecordsHavingMultipleFacesOfPassport.add(ct);
                                        mapAccountRelatedListOfPassportFacePhoto.put(ct.Person__c,contentListRecordsHavingMultipleFacesOfPassport);
                                    }
                                    else{
                                        mapAccountRelatedListOfPassportFacePhoto.put(ct.Person__c,new List<Content__c>{ct});
                                    }
                                }
                                else if(ct.Document_Type__c == 'Passport' && ct.Image_Type__c == 'Front' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH' && ct.Document_Country__c == 'BH' && ct.Scan_Type__c == 'POI'){
                                    mapAccountRelatedListOfPassportFrontPhoto.put(ct.Person__c,ct.Image_Type__c);
                                }
                                //CH01: END
                            }//Inner for loop End
                            caseLstWithWathiqOrCPRForm.add(c);
                        } //If END
                        else{ //This Block Executes when no documents are available on Customers
                            System.debug('After update No Documents found');
                            Case cs = new Case(Id = c.Id,AccountId = c.AccountId);
                            cs.pr_WathiqConsentFormRequired__c = true;
                            cs.Status = 'Pending Documents';
                            cs.Wathiq_Consent_Form_Available__c = false;
                            cs.CPR_Form_Available__c = false;
                            
                            accIdsWithoutWathiqFormWithoutCPR.add(cs.AccountId);
                            wathiqOrCPRFormAvailableList.add(cs);
                        }
                    } //If END
                    else{
                        System.debug('After update Need to Check Else condition for No Documents');
                        Case cs = new Case(Id = c.Id,AccountId = c.AccountId);
                        cs.pr_WathiqConsentFormRequired__c = true;
                        cs.Status = 'Pending Documents';
                        cs.Wathiq_Consent_Form_Available__c = false; 
                        cs.CPR_Form_Available__c = false;
                        
                        accIdsWithoutWathiqFormWithoutCPR.add(cs.AccountId);
                        wathiqOrCPRFormAvailableList.add(cs);
                    }
                } //Outer for loop END
            }
            System.debug('After update Case List With Wathiq & CPR Form:'+caseLstWithWathiqOrCPRForm);
            if(caseLstWithWathiqOrCPRForm.size()>0){
                Map<Id,String> mapAccountRelatedFacePhotoWithOneRecord = new Map<Id,String>();
                Map<Id,String> mapAccountRelatedFacePhotoWithTwoRecord = new Map<Id,String>();
                Map<Id,String> mapAccountRelatedFacePhotoWithThreeOrMoreRecord = new Map<Id,String>();
                
                //CH01: Start
                Map<Id,String> mapAccountRelatedPassportFacePhotoWithOneRecord = new Map<Id,String>();
                Map<Id,String> mapAccountRelatedPassportFacePhotoWithTwoRecord = new Map<Id,String>();
                Map<Id,String> mapAccountRelatedPassportFacePhotoWithThreeOrMoreRecord = new Map<Id,String>();
                //CH01: END
                
                Map<Id,String> mapAccountRelatedFacePhotoWithOneRecordId = new Map<Id,String>();
                Map<Id,String> mapAccountRelatedFacePhotoWithTwoRecordId = new Map<Id,String>();
                Map<Id,String> mapAccountRelatedFacePhotoWithThreeOrMoreRecordId = new Map<Id,String>();
                //This for loop is used to store the Person AccountId based on the multiple face records
                for(Case c : caseLstWithWathiqOrCPRForm){
                    Case cs = new Case(Id = c.Id,AccountId = c.AccountId);
                    if(mapAccountRelatedListFacePhoto.containsKey(cs.AccountId)){
                        List<Content__c> lstContentFaceRecords = mapAccountRelatedListFacePhoto.get(cs.AccountId);
                        System.debug('Multiple face Record Size in case update:'+lstContentFaceRecords.size());
                        if(lstContentFaceRecords.size() >= 3){
                            Content__c cnt = lstContentFaceRecords.get(2);
                            mapAccountRelatedFacePhotoWithThreeOrMoreRecord.put(cnt.Person__c,cnt.Image_Type__c);
                            mapAccountRelatedFacePhotoWithThreeOrMoreRecordId.put(cnt.Person__c,cnt.Id);
                            System.debug('Face photo with three or more record:'+mapAccountRelatedFacePhotoWithThreeOrMoreRecord);
                        }
                        else if(lstContentFaceRecords.size() == 2){
                            Content__c cnt = lstContentFaceRecords.get(1);
                            mapAccountRelatedFacePhotoWithTwoRecord.put(cnt.Person__c,cnt.Image_Type__c);
                            mapAccountRelatedFacePhotoWithTwoRecordId.put(cnt.Person__c,cnt.Id);
                            System.debug('Face photo with two record:'+mapAccountRelatedFacePhotoWithTwoRecord);
                        }
                        else if(lstContentFaceRecords.size() == 1){
                            Content__c cnt = lstContentFaceRecords.get(0);
                            mapAccountRelatedFacePhotoWithOneRecord.put(cnt.Person__c,cnt.Image_Type__c);
                            mapAccountRelatedFacePhotoWithOneRecordId.put(cnt.Person__c,cnt.Id);
                            System.debug('Face photo with one record:'+mapAccountRelatedFacePhotoWithOneRecord);
                        }
                    }
                    //CH01: Start
                    if(mapAccountRelatedListOfPassportFacePhoto.containsKey(cs.AccountId)){
                       List<Content__c> lstContentPassportFaceRecords = mapAccountRelatedListOfPassportFacePhoto.get(cs.AccountId); 
                       System.debug('Multiple face Record for Passport Size in case creation:'+lstContentPassportFaceRecords.size());
                       	if(lstContentPassportFaceRecords.size() >= 3){
                            Content__c cnt = lstContentPassportFaceRecords.get(2);
                            mapAccountRelatedPassportFacePhotoWithThreeOrMoreRecord.put(cnt.Person__c,cnt.Image_Type__c);
                            
					    }
                        else if(lstContentPassportFaceRecords.size() == 2){
                            Content__c cnt = lstContentPassportFaceRecords.get(1);
                            mapAccountRelatedPassportFacePhotoWithTwoRecord.put(cnt.Person__c,cnt.Image_Type__c);
                        }
                        else if(lstContentPassportFaceRecords.size() == 1){
                            Content__c cnt = lstContentPassportFaceRecords.get(0);
                            mapAccountRelatedPassportFacePhotoWithOneRecord.put(cnt.Person__c,cnt.Image_Type__c);
                        }
                        
                    }
                    //CH01: END
                } //for loop Ends
                System.debug('Having 3 or more Face Record during Case update:'+mapAccountRelatedFacePhotoWithThreeOrMoreRecordId);
                System.debug('Having 2 Face Record during Case update:'+mapAccountRelatedFacePhotoWithTwoRecordId);
                System.debug('Having 1 Face Record during Case update:'+mapAccountRelatedFacePhotoWithOneRecordId);
                
                //This for loop is used to check the map values of Respective Content Documents with one face record or two face records or more than two face records with Person AccountId
                for(Case c : caseLstWithWathiqOrCPRForm){
                    Case cs = new Case(Id = c.Id,AccountId = c.AccountId);
                    if(mapAccountRelatedWathiqForm.containsKey(cs.AccountId)){
                        //cs.Wathiq_Consent_Form_Available__c = true;
                        mapRelatedToWathiqFormAvailable.put(cs.Id,true);
                        wathiqOrCPRFormAvailableList.add(cs);
                        setCaseIdContainsWathiqFormOrCPRForm.add(cs.Id);
                        System.debug('After update Wathiq Form Available on Customer Documents & Need to call API');
                        //break;
                    }
                    //CH01: Start Added a Condition related to passport
                    else if((mapAccountRelatedFrontPhoto.containsKey(cs.AccountId) && mapAccountRelatedBackPhoto.containsKey(cs.AccountId)) || (mapAccountRelatedListOfPassportFrontPhoto.containsKey(cs.AccountId))){
                        if(mapAccountRelatedFacePhotoWithThreeOrMoreRecord.containsKey(cs.AccountId) || mapAccountRelatedFacePhotoWithTwoRecord.containsKey(cs.AccountId) || mapAccountRelatedFacePhotoWithOneRecord.containsKey(cs.AccountId)){
                            //cs.CPR_Form_Available__c = true;
                            mapRelatedToCPRFormAvailable.put(cs.Id,true);
                            wathiqOrCPRFormAvailableList.add(cs);
                            setCaseIdContainsWathiqFormOrCPRForm.add(cs.Id);
                            System.debug('After Update CPR Form Available on Customer Documents & Need to call API');
                        }
                        //CH01: Start
                        else if(mapAccountRelatedPassportFacePhotoWithThreeOrMoreRecord.containsKey(cs.AccountId) || mapAccountRelatedPassportFacePhotoWithTwoRecord.containsKey(cs.AccountId) || mapAccountRelatedPassportFacePhotoWithOneRecord.containsKey(cs.AccountId)){
                           	//cs.CPR_Form_Available__c = true;
                           	mapRelatedToCPRFormAvailable.put(cs.Id,true);
                            wathiqOrCPRFormAvailableList.add(cs);
                            setCaseIdContainsWathiqFormOrCPRForm.add(cs.Id);
                            System.debug('Passport Available on Customer Documents & Need to call API'); 
                        }
                        //CH01: END
                        else{
                            System.debug('No Bahraini Face Photo Available');
                            cs.pr_WathiqConsentFormRequired__c = true;
                            cs.Status = 'Pending Documents';
                            cs.CPR_Form_Available__c = false;
                            cs.Wathiq_Consent_Form_Available__c = false;
                            
                            accIdsWithoutWathiqFormWithoutCPR.add(cs.AccountId);
                            wathiqOrCPRFormAvailableList.add(cs);
                        }
                    }
                    else{
                        System.debug('After Upadte No Wathiq Form and CPR Form Available');
                        cs.pr_WathiqConsentFormRequired__c = true;
                        cs.Status = 'Pending Documents';
                        cs.Wathiq_Consent_Form_Available__c = false;
                        cs.CPR_Form_Available__c = false;
                        
                        accIdsWithoutWathiqFormWithoutCPR.add(cs.AccountId);
                        wathiqOrCPRFormAvailableList.add(cs);
                    }
                }//for loop Ends
            }
        }
        System.debug('After update Account Review Stage:'+accIdsWithoutWathiqFormWithoutCPR);
        if(accIdsWithoutWathiqFormWithoutCPR.size()>0){
            for(Account a : [Select Id,pr_ReviewStatus__c from Account where Id =:accIdsWithoutWathiqFormWithoutCPR]){
                if(a.pr_ReviewStatus__c == '' || a.pr_ReviewStatus__c == null){
                   if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                        a.pr_ReviewStatus__c = 'Overdue Stage 1';
                    }
                    else{
                        a.pr_ReviewStatus__c = 'Overdue';
                    }
                    accListWithoutWathiqFormWithoutCPR.add(a);
                }
            }
        }
        
        if(setCaseIdContainsWathiqFormOrCPRForm.size()>0){
            System.debug('Wathiq Form Available or CPR Form Available');
            
            FetcheKYCDocHashValueToReprocess fetchDocumentHash = new FetcheKYCDocHashValueToReprocess(setCaseIdContainsWathiqFormOrCPRForm,mapRelatedToWathiqFormAvailable,mapRelatedToCPRFormAvailable);
            System.enqueueJob(fetchDocumentHash);
        }
        try{
            if(wathiqOrCPRFormAvailableList.size()>0)
                update wathiqOrCPRFormAvailableList;
            if(accListWithoutWathiqFormWithoutCPR.size()>0)
                update accListWithoutWathiqFormWithoutCPR;
        }catch(Exception e){
            System.debug('Exception Message in Periodic Handler API:'+e.getMessage());
        }    
        
    }
    
    public static void casesWithoutWathiqConsentAndIDVHash(List<Case> caseListWithoutWathiqConsentANDIDVHash, Set<Id> accIdsWithoutWathiqConsentANDIDVHash){
        List<Case> caseLstToUpdateAsOverDue = new List<Case>();
        List<Account> accLstToUpdateAsOverDue = new List<Account>();
        if(accIdsWithoutWathiqConsentANDIDVHash.size() > 0){
            Map<Id,Account> mapAccount = new Map<Id,Account>([Select Id,pr_ReviewStatus__c from Account where Id =:accIdsWithoutWathiqConsentANDIDVHash]);
            if(caseListWithoutWathiqConsentANDIDVHash.size()>0){
                for(Case cs : caseListWithoutWathiqConsentANDIDVHash){
                    if(mapAccount.containsKey(cs.Accountid)){
                        Account a =  mapAccount.get(cs.AccountId);
                        System.debug('Account ACC:'+a);
                        if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            a.pr_ReviewStatus__c = 'Overdue Stage 1';
                        }
                        else{
                            a.pr_ReviewStatus__c = 'Overdue';
                        }
                        accLstToUpdateAsOverDue.add(a);
                        Case c = new Case(Id = cs.Id);
                        c.Status = 'Pending Documents';
                        if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            c.Sub_Status__c = 'Overdue Stage 1';
                        }
                        else{
                            c.Sub_Status__c = 'Overdue';
                        }
                        c.pr_Overdue_Stage_Date__c =System.now();
                        c.pr_WathiqConsentAcceptanceRequired__c = true;
                        System.debug('Case Details----->:'+c);
                        caseLstToUpdateAsOverDue.add(c);
                    }
                }
            }
        }
        if(accLstToUpdateAsOverDue.size()>0){
            update accLstToUpdateAsOverDue;
        }
        System.debug('Case List to update as overdue:'+caseLstToUpdateAsOverDue);
        if(caseLstToUpdateAsOverDue.size()>0){
            Set<String> setErrCaseIds = new Set<String>();
            Set<String> setofSuccessFullCaseIds = new Set<String>();
            Set<String> setofErrorCaseIds = new Set<String>();
            Set<String> setOfErrormessage = new Set<String>();
            try{
                Database.SaveResult[] SResult = Database.update(caseLstToUpdateAsOverDue,false);
                for(Integer i=0; i<SResult.size(); i++){
                    setErrCaseIds.add(caseLstToUpdateAsOverDue.get(i).Id);
                    if(SResult[i].isSuccess()){
                        setofSuccessFullCaseIds.add(caseLstToUpdateAsOverDue.get(i).Id);
                    }
                    else if(!SResult[i].isSuccess()){
                        setofErrorCaseIds.add(caseLstToUpdateAsOverDue.get(i).Id);
                        for(Database.Error err : SResult[i].getErrors()){
                            setOfErrormessage.add(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
                if(!setofSuccessFullCaseIds.isEmpty()){
                    String compName = 'ReprocessWathiqForm';
                    String compType = 'Apex Class';
                    String successRecordReference = String.join(new List<String>(setofSuccessFullCaseIds), ',');
                    String ObjectType = 'Case';
                    String caseCategory = 'Wathiq Acceptance Required on Customer';
                    PeriodicReviewBatchTrackerLogs.successCaselogWithCategory(compName, compType, successRecordReference,ObjectType,caseCategory);
                    
                }
                if(!setofErrorCaseIds.isEmpty()){
                    String compName = 'ReprocessWathiqForm';
                    String compType = 'Apex Class';
                    String failureRecordReference = String.join(new List<String>(setofErrorCaseIds), ',');
                    String ObjectType = 'Case';
                    String errorMessage = String.join(new List<String>(setOfErrormessage), ',');
                    PeriodicReviewBatchTrackerLogs.errorCaselog(compName, compType, failureRecordReference,errorMessage,ObjectType);
                    
                }
            }catch(Exception ex){
                String compName = 'ReprocessWathiqForm';
                String compType = 'Apex Class';
                /*for(case c : caseLstToUpdateAsOverDue){
                    setErrCaseIds.add(c.Id);
                }*/
                String failureRecordReference = String.join(new List<String>(setErrCaseIds), ',');
                String ObjectType = 'Case';
                String errorMessage = ex.getMessage()  + ex.getStackTraceString();
                PeriodicReviewBatchTrackerLogs.errorCaselog(compName, compType, failureRecordReference,errorMessage,ObjectType); 
            } 
        }
    }
    
}