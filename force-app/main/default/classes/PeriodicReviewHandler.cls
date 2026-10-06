/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date: 09-06-2022
* 		Change History: 
*	    			CH1: Added by Wissal Benqezza to update the overdue stage date in the creation of the case
*					CH02: Added by #Jahangeer Mohammed# #08-03-2023# Suspend Overdue Stages & Regenerate Wathiq Form(CRM23-183)
*					CH03: Added Logic to Check Passport documents like Face Photo & Front Photo(CRM23-234)
*					CH04: Added by #Jahangeer Mohammed# #10-09-2023# Exclude Residency Permit for GCC Countries(NBA-8829)
*					CH05: Added by #Jahangeer Mohammed# #16-09-2024# Exclude Customer Name & DOB field to update on Customer Profile(NBA-12057)
*					CH06: Added by #Jahangeer Mohammed# #23-09-2024# Restrict 3 Characters Nationality field to update on Customer Profile in Other docs and Residency Permit scenario
*/
public class PeriodicReviewHandler {
    public static void handlerBeforeCaseCreation(List<case> lstCase){
        List<Case> lstNewCase = new List<Case>();
        Set<Id> setNewAccIds = new Set<Id>();
        Map<Id,List<Case>> mapAccountContainingPeriodicReviewCase = new Map<Id,List<Case>>();
        
        for(Case caseObj : lstCase){ //For loop Start
            //////////////////////////////////////// Start: Checking for Existing Periodic Review Case If Status is Not Closed /////////////////////////////////////
            if(caseObj.RecordType_DeveloperName__c == 'Customer_Periodic_Review' && caseObj.Type == 'Periodic Review'){
                System.debug('Testing for Existing Periodic Review Case');
                //setNewCaseIds.add(caseObj.Id);
                lstNewCase.add(caseObj);
                setNewAccIds.add(caseObj.AccountId);
            }
            //////////////////////////////////////// END: Checking for Existing Periodic Review Case If Status is Not Closed /////////////////////////////////////
        } //For loop End
        
        //////////////////////////////////////// Start: Checking for Existing Periodic Review Case If Status is Not Closed /////////////////////////////////////
        System.debug('List of new Cases:'+lstNewCase);
        System.debug('List of AccountIds related to new cases:'+setNewAccIds);
        if(setNewAccIds.size()>0){
            for(Case c : [Select id,AccountId,Status from Case where Status NOT IN('Closed') AND Type = 'Periodic Review' AND AccountId IN :setNewAccIds]){
                System.debug('Periodic Review Case:'+c);
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
                    	c.addError('Please close the Existing Periodic Review Case');
                }
            }
        }
        
        //////////////////////////////////////// END: Checking for Existing Periodic Review Case If Status is Not Closed /////////////////////////////////////
        
        
    }
    public static void handlerAfterCaseCreation(List<case> lstCase){
       
        Set<Id> accIds = new Set<Id>();
        List<Case> caseListWithoutWathiqConsentANDIDVHash = new List<Case>();
        List<Account> accLstToUpdateAsOverDue = new List<Account>();
        List<Case> caseLstToUpdateAsOverDue = new List<Case>();
        
        List<Case> checkWathiqFormListCases = new List<Case>();
        Set<Id> checkWathiqFormAccIds = new Set<Id>();
        List<Case> wathiqOrCPRFormAvailableList = new List<Case>();
        Set<Id> accIdsWithoutWathiqFormWithoutCPR = new Set<Id>();
        List<Account> accListWithoutWathiqFormWithoutCPR = new List<Account>();
        
        Map<Id,String> mapAccountRelatedWathiqForm = new Map<Id,String>();
        Map<Id,String> mapAccountRelatedFacePhoto = new Map<Id,String>();
        Map<Id,String> mapAccountRelatedFrontPhoto = new Map<Id,String>();
        Map<Id,String> mapAccountRelatedBackPhoto = new Map<Id,String>();
        List<Case> caseLstWithWathiqOrCPRForm = new List<Case>();
        
        Set<Id> setCaseIdsWithWathiqAcceptedANDIDVHashAccepted = new Set<Id>();
        Map<Id,List<Case>> mapAccountContainingPeriodicReviewCase = new Map<Id,List<Case>>();
        Set<Id> setCaseIdContainsWathiqFormOrCPRForm = new Set<Id>();
        //CH02: Start
        Set<Id> regnerateWathiqFormAccIds = new Set<Id>();
        Set<Id> regnerateWathiqFormCaseIds = new Set<Id>();
        List<Account> regnerateWathiqFormAccList = new List<Account>();
        List<Case> regnerateWathiqFormCaseList = new List<Case>();
        //CH02: END
        
        for(Case caseObj : lstCase){ //For loop Start
           ////////////////////////////////////////// Start: Wathiq Consent Accepted & ID & V & Hash Available ////////////////////////////////////////////////////
            //CH02: Start Added Force_Generate_Wathiq_Consent_Form__c in if condition
            if(caseObj.RecordType_DeveloperName__c == 'Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Wathiq_Consent__c == true &&
               caseObj.eKYC_IDandV_Document_Upload_Hash__c == true && caseObj.Force_Generate_Wathiq_Consent_Form__c == false){
                   System.debug('Wathiq accepted and ID & V Hash available');
				   setCaseIdsWithWathiqAcceptedANDIDVHashAccepted.add(caseObj.Id);
               }
            //CH02: END
            
            ////////////////////////////////////////// END: Wathiq Consent Accepted & ID & V & Hash Available ////////////////////////////////////////////////////
            
            ////////////////////////////////////////// Start: Wathiq Consent Not Accepted & ID & V & Hash is Not Available & Force Generate Wathiq Form is false ////////////////////////////////////////////////////
            //CH02: Start Added Force_Generate_Wathiq_Consent_Form__c in if condition
            if(caseObj.RecordType_DeveloperName__c == 'Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Wathiq_Consent__c == false &&
               caseObj.eKYC_IDandV_Document_Upload_Hash__c == false && caseObj.Force_Generate_Wathiq_Consent_Form__c == false){
                   System.debug('Wathiq not accepted and ID & V Hash not available & Force Generate Wathiq Form is false');
                   caseListWithoutWathiqConsentANDIDVHash.add(caseObj);
                   accIds.add(caseObj.AccountId);
               }
            //CH02: END
            ////////////////////////////////////////// END: Wathiq Consent Not Accepted & ID & V & Hash is Not Available & Force Generate Wathiq Form is false ////////////////////////////////////////////////////
            
            ////////////////////////////////////////// Start: Wathiq Consent Accepted & ID & V & Hash Not Available ////////////////////////////////////////////////////
            //CH02: Start Added Force_Generate_Wathiq_Consent_Form__c in if condition
            if(caseObj.RecordType_DeveloperName__c == 'Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Wathiq_Consent__c == true &&
               caseObj.eKYC_IDandV_Document_Upload_Hash__c == false && caseObj.Force_Generate_Wathiq_Consent_Form__c == false){
                   System.debug('Wathiq accepted and ID & V Hash not available');
				   checkWathiqFormListCases.add(caseObj);
                   checkWathiqFormAccIds.add(caseObj.AccountId);
               }
            //CH02: END
            ////////////////////////////////////////// END: Wathiq Consent Accepted & ID & V & Hash Not Available ////////////////////////////////////////////////////
            
            ///////////////////////////////////////// Start: Force Generate Wathiq Consent Form /////////////////////////////////////////////
            //CH02: Start
            if(caseObj.RecordType_DeveloperName__c == 'Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Force_Generate_Wathiq_Consent_Form__c == true){
                System.debug('Regenerate Wathiq Form Process');
                regnerateWathiqFormCaseIds.add(caseObj.Id);
                regnerateWathiqFormAccIds.add(caseObj.AccountId);
            }
            //CH02: END
            ///////////////////////////////////////// END: Force Generate Wathiq Consent Form /////////////////////////////////////////////
 
        } //For loop Ends
        
        ///////////////////////////////////////// Start: Force Generate Wathiq Consent Form /////////////////////////////////////////////
        //CH02: Start
        for(Case cse : [Select id,Force_Generate_Wathiq_Consent_Form__c,Status,Sub_Status__c from Case Where id =: regnerateWathiqFormCaseIds]){
            Case c = new Case(id = cse.id);
            c.Status = 'Pending Documents';
            if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                 c.Sub_Status__c = 'Overdue Stage 1';
            }
            else
             	c.Sub_Status__c = 'Overdue';
            c.Backend_Force_Generate_Wathiq_Consent_Fo__c = cse.Force_Generate_Wathiq_Consent_Form__c;
            regnerateWathiqFormCaseList.add(c);
        }
        for(Account acct : [Select id,pr_ReviewStatus__c,eKYC_IDandV_Document_Upload_Hash__pc from Account where id =: regnerateWathiqFormAccIds]){
            if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                acct.pr_ReviewStatus__c = 'Overdue Stage 1';
		    }
            else
                acct.pr_ReviewStatus__c = 'Overdue';
            if(acct.eKYC_IDandV_Document_Upload_Hash__pc != null){
                acct.eKYC_IDandV_Document_Upload_Hash__pc = '';
            }
            regnerateWathiqFormAccList.add(acct);

        }
        if(regnerateWathiqFormCaseList.size() > 0)
            update regnerateWathiqFormCaseList;
        if(regnerateWathiqFormAccList.size() > 0)
            update regnerateWathiqFormAccList;
        //CH02: END
        
        ///////////////////////////////////////// END: Force Generate Wathiq Consent Form /////////////////////////////////////////////

        
        ////////////////////////////////////////// Start: Wathiq Consent Accepted & ID & V & Hash Not Available ////////////////////////////////////////////////////
        Set<Id> caseIdsHavingWathiqFormOrCPRForm = new Set<Id>();
        if(checkWathiqFormAccIds.size()>0){
            Map<Id,List<Content__c>> mapAccToContent = new Map<Id,List<Content__c>>();
            Map<Id,List<Content__c>> mapAccountRelatedListFacePhoto = new Map<Id,List<Content__c>>();
            //CH03: Start
            Map<Id,List<Content__c>> mapAccountRelatedListOfPassportFacePhoto = new Map<Id,List<Content__c>>();
            Map<Id,String> mapAccountRelatedListOfPassportFrontPhoto = new Map<Id,String>();
            //CH03: END
            //CH03: Start Added Passport condition & Document_Country__c in SOQL
            List<Content__c> lstContent = [SELECT Name,Document_Type__c,Document_Expiry_Date__c,Document_Country__c, Person__c,Scan_Type__c,Validity__c,Verification_Status__c,Image_Type__c,Similarity__c FROM Content__c where 
                                           Person__c =: checkWathiqFormAccIds AND Document_Type__c IN('Wathiq Consent Form','Bahraini ID', 'Passport') order by CreatedDate ASC];
            //CH03: END
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
                        System.debug('Checking Acc related docs Map');
                        List<Content__c> cntList = mapAccToContent.get(c.AccountId);
                        if(cntList.size()>0){ //If Start
                            System.debug('Content List Related to Account:'+cntList);
                            for(Content__c ct : cntList){ //Checking Wathiq Form or CPR Form on Customer
                                if(ct.Document_Type__c == 'Wathiq Consent Form'){
                                    mapAccountRelatedWathiqForm.put(ct.Person__c,ct.Document_Type__c);
                                    break;
                                }
                                else if(ct.Document_Type__c == 'Bahraini ID' && ct.Image_Type__c == 'Face' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH' && ct.Scan_Type__c == 'POI'){
                                    //mapAccountRelatedFacePhoto.put(ct.Person__c,ct.Image_Type__c);
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
                                //CH03: Start
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
                                //CH03: END
                            }//Inner for loop End
                            caseLstWithWathiqOrCPRForm.add(c);
                            caseIdsHavingWathiqFormOrCPRForm.add(c.Id);
                        } //If END
                        else{ //This Block Executes when no documents are available on Customers
                            System.debug('No Documents found');
                            Case cs = new Case(Id = c.Id,AccountId = c.AccountId);
                            cs.pr_WathiqConsentFormRequired__c = true;
                            cs.Status = 'Pending Documents';
                            //CH02: Start
                            if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            	cs.Sub_Status__c = 'Overdue Stage 1';
                            }
                            else
                                cs.Sub_Status__c = 'Overdue';
                            //CH02: END
                            //CH1:Start
                            cs.pr_Overdue_Stage_Date__c =System.now();
                            
                            //CH1:End
                            accIdsWithoutWathiqFormWithoutCPR.add(cs.AccountId);
                            wathiqOrCPRFormAvailableList.add(cs);
                        }
                    } //If END
                    else{
                        System.debug('Need to Check Else condition for No Documents');
                        Case cs = new Case(Id = c.Id,AccountId = c.AccountId);
                        cs.pr_WathiqConsentFormRequired__c = true;
                        cs.Status = 'Pending Documents';
                        //CH02: Start
                        if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            cs.Sub_Status__c = 'Overdue Stage 1';
                         }
                         else
                            cs.Sub_Status__c = 'Overdue';
                        //CH02: END
                        //CH1:Start
                        cs.pr_Overdue_Stage_Date__c =System.now();
                        
                        //CH1:End
                        accIdsWithoutWathiqFormWithoutCPR.add(cs.AccountId);
                        wathiqOrCPRFormAvailableList.add(cs);
                    }
                } //Outer for loop END
            }
            System.debug('Case List With Wathiq & CPR Form:'+caseLstWithWathiqOrCPRForm);
            System.debug('Case Ids With Wathiq & CPR Form:'+caseIdsHavingWathiqFormOrCPRForm);

            if(caseLstWithWathiqOrCPRForm.size()>0){
                Map<Id,String> mapAccountRelatedFacePhotoWithOneRecord = new Map<Id,String>();
                Map<Id,String> mapAccountRelatedFacePhotoWithTwoRecord = new Map<Id,String>();
                Map<Id,String> mapAccountRelatedFacePhotoWithThreeOrMoreRecord = new Map<Id,String>();
                
                //CH03: Start
                Map<Id,String> mapAccountRelatedPassportFacePhotoWithOneRecord = new Map<Id,String>();
                Map<Id,String> mapAccountRelatedPassportFacePhotoWithTwoRecord = new Map<Id,String>();
                Map<Id,String> mapAccountRelatedPassportFacePhotoWithThreeOrMoreRecord = new Map<Id,String>();
                //CH03: END
                
                Map<Id,String> mapAccountRelatedFacePhotoWithOneRecordId = new Map<Id,String>();
                Map<Id,String> mapAccountRelatedFacePhotoWithTwoRecordId = new Map<Id,String>();
                Map<Id,String> mapAccountRelatedFacePhotoWithThreeOrMoreRecordId = new Map<Id,String>();
                
                //This for loop is used to store the Person AccountId based on the multiple face records
                for(Case c : caseLstWithWathiqOrCPRForm){
                    Case cs = new Case(Id = c.Id,AccountId = c.AccountId);
                    if(mapAccountRelatedListFacePhoto.containsKey(cs.AccountId)){
                        List<Content__c> lstContentFaceRecords = mapAccountRelatedListFacePhoto.get(cs.AccountId);
                        System.debug('Multiple face Record Size in case creation:'+lstContentFaceRecords.size());
                        if(lstContentFaceRecords.size() >= 3){
                            Content__c cnt = lstContentFaceRecords.get(2);
                            mapAccountRelatedFacePhotoWithThreeOrMoreRecord.put(cnt.Person__c,cnt.Image_Type__c);
                            mapAccountRelatedFacePhotoWithThreeOrMoreRecordId.put(cnt.Person__c,cnt.Id);

                        }
                        else if(lstContentFaceRecords.size() == 2){
                            Content__c cnt = lstContentFaceRecords.get(1);
                            mapAccountRelatedFacePhotoWithTwoRecord.put(cnt.Person__c,cnt.Image_Type__c);
                            mapAccountRelatedFacePhotoWithTwoRecordId.put(cnt.Person__c,cnt.Id);

                        }
                        else if(lstContentFaceRecords.size() == 1){
                            Content__c cnt = lstContentFaceRecords.get(0);
                            mapAccountRelatedFacePhotoWithOneRecord.put(cnt.Person__c,cnt.Image_Type__c);
                            mapAccountRelatedFacePhotoWithOneRecordId.put(cnt.Person__c,cnt.Id);

                        }
                    }
                    //CH03: Start
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
                    //CH03: END
                } //for loop Ends
                System.debug('Having 3 or more Face Record during Case Creation:'+mapAccountRelatedFacePhotoWithThreeOrMoreRecordId);
                System.debug('Having 2 Face Record during Case Creation:'+mapAccountRelatedFacePhotoWithTwoRecordId);
                System.debug('Having 1 Face Record during Case Creation:'+mapAccountRelatedFacePhotoWithOneRecordId);


                //This for loop is used to check the map values of Respective Content Documents with one face record or two face records or more than two face records with Person AccountId
                for(Case c : caseLstWithWathiqOrCPRForm){
                    Case cs = new Case(Id = c.Id,AccountId = c.AccountId);
                    if(mapAccountRelatedWathiqForm.containsKey(cs.AccountId)){
                        System.debug('New Case Ids created:'+cs.Id);
                        cs.Wathiq_Consent_Form_Available__c = true;
                        wathiqOrCPRFormAvailableList.add(cs);
                        setCaseIdContainsWathiqFormOrCPRForm.add(cs.Id);
                        System.debug('Wathiq Form Available on Customer Documents & Need to call API');
                        //break;
                    }
                    //CH03: Start Added a Condition related to passport
                    else if((mapAccountRelatedFrontPhoto.containsKey(cs.AccountId) && mapAccountRelatedBackPhoto.containsKey(cs.AccountId)) || (mapAccountRelatedListOfPassportFrontPhoto.containsKey(cs.AccountId))){
                        if(mapAccountRelatedFacePhotoWithThreeOrMoreRecord.containsKey(cs.AccountId) || mapAccountRelatedFacePhotoWithTwoRecord.containsKey(cs.AccountId) || mapAccountRelatedFacePhotoWithOneRecord.containsKey(cs.AccountId)){
                            cs.CPR_Form_Available__c = true;
                            wathiqOrCPRFormAvailableList.add(cs);
                            setCaseIdContainsWathiqFormOrCPRForm.add(cs.Id);
                            System.debug('CPR Form Available on Customer Documents & Need to call API');
                        }
                        //CH03: Start
                        else if(mapAccountRelatedPassportFacePhotoWithThreeOrMoreRecord.containsKey(cs.AccountId) || mapAccountRelatedPassportFacePhotoWithTwoRecord.containsKey(cs.AccountId) || mapAccountRelatedPassportFacePhotoWithOneRecord.containsKey(cs.AccountId)){
                           	cs.CPR_Form_Available__c = true;
                            wathiqOrCPRFormAvailableList.add(cs);
                            setCaseIdContainsWathiqFormOrCPRForm.add(cs.Id);
                            System.debug('Passport Available on Customer Documents & Need to call API'); 
                        }
                        //CH03: END
                        else{
                            System.debug('No Bahraini Face & Passport Face Photo Available');
                            cs.pr_WathiqConsentFormRequired__c = true;
                        	cs.Status = 'Pending Documents';
                        	//CH02: Start
                        	if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            	cs.Sub_Status__c = 'Overdue Stage 1';
                         	}
                         	else
                            	cs.Sub_Status__c = 'Overdue';
                        	//CH02: END
                        	//CH1:Start
                        	cs.pr_Overdue_Stage_Date__c =System.now();
                        	//CH1:End
                        	accIdsWithoutWathiqFormWithoutCPR.add(cs.AccountId);
                        	wathiqOrCPRFormAvailableList.add(cs);
                        }
                    }
                    //CH03: END
                    else{
                        System.debug('No Wathiq Form and CPR Form Available');
                        cs.pr_WathiqConsentFormRequired__c = true;
                        cs.Status = 'Pending Documents';
                        //CH02: Start
                        if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            cs.Sub_Status__c = 'Overdue Stage 1';
                         }
                         else
                            cs.Sub_Status__c = 'Overdue';
                        //CH02: END
                        //CH1:Start
                        cs.pr_Overdue_Stage_Date__c =System.now();
                        //CH1:End
                        accIdsWithoutWathiqFormWithoutCPR.add(cs.AccountId);
                        wathiqOrCPRFormAvailableList.add(cs);
                    }
                } //for loop Ends
            }
        }
        System.debug('Account Review Stage:'+accIdsWithoutWathiqFormWithoutCPR);
        if(accIdsWithoutWathiqFormWithoutCPR.size()>0){
            for(Account a : [Select Id,pr_ReviewStatus__c from Account where Id =:accIdsWithoutWathiqFormWithoutCPR]){
                //CH02: Start
                if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     a.pr_ReviewStatus__c = 'Overdue Stage 1';
				}
                else
                	a.pr_ReviewStatus__c = 'Overdue';
                //CH02: END
                accListWithoutWathiqFormWithoutCPR.add(a);
            }
        }
        
        ////////////////////////////////////////// END: Wathiq Consent Accepted & ID & V & Hash Not Available ////////////////////////////////////////////////////
        
        
        ////////////////////////////////////////// Start: Wathiq Consent Not Accepted & ID & V & Hash is Not Available ////////////////////////////////////////////////////
        
        if(accIds.size()>0){
            Map<Id,Account> mapAccount = new Map<Id,Account>([Select Id,pr_ReviewStatus__c from Account where Id =:accIds]);
            if(caseListWithoutWathiqConsentANDIDVHash.size()>0){
                for(Case cs : caseListWithoutWathiqConsentANDIDVHash){
                    if(mapAccount.containsKey(cs.Accountid)){
                        Account a =  mapAccount.get(cs.AccountId);
                        System.debug('Account ACC:'+a);
                        //CH02: Start
                		if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     		a.pr_ReviewStatus__c = 'Overdue Stage 1';
						}
                		else
                			a.pr_ReviewStatus__c = 'Overdue';
                		//CH02: END
                        accLstToUpdateAsOverDue.add(a);
                        Case c = new Case(Id = cs.Id);
                        c.Status = 'Pending Documents';
                        //CH02: Start
                        if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                            c.Sub_Status__c = 'Overdue Stage 1';
                         }
                         else
                            c.Sub_Status__c = 'Overdue';
                        //CH02: END
                        //CH1:Start
                        c.pr_Overdue_Stage_Date__c =System.now();
                        
                        //CH1:End
                        c.pr_WathiqConsentAcceptanceRequired__c = true;
                        //c.OwnerId = System.Label.QA_Team;
                        System.debug('Case Details----->:'+c);
                        caseLstToUpdateAsOverDue.add(c);
                    }
                }
            }
        }
        
        ////////////////////////////////////////// END: Wathiq Consent Not Accepted & ID & V & Hash is Not Available ////////////////////////////////////////////////////
        
        if(setCaseIdsWithWathiqAcceptedANDIDVHashAccepted.size()>0){
            System.debug('Wathiq Accepted and ID & V Hash Available');
            //Need to Call API Class Here
            try{
                //PeriodicReviewHandlerAPI.fetcheKYCiGAData(setCaseIdsWithWathiqAcceptedANDIDVHashAccepted);
                FetcheKYCIGADataQueuableAPI fetchiGAData = new FetcheKYCIGADataQueuableAPI(setCaseIdsWithWathiqAcceptedANDIDVHashAccepted);
                System.enqueueJob(fetchiGAData);
                
            }catch(Exception Ex){
                System.debug('Exception Message:'+Ex.getMessage());
            }
        }
        
        if(setCaseIdContainsWathiqFormOrCPRForm.size()>0){
            System.debug('Case List with having Wathiq Form or CPR Form:'+setCaseIdContainsWathiqFormOrCPRForm.size());
            System.debug('Wathiq Form Available or CPR Form Available');
            //Need to Call API Class Here
            //PeriodicReviewHandlerAPI.fetcheKYCDocumentHashValue(setCaseIdContainsWathiqFormOrCPRForm);
            if(Limits.getQueueableJobs() == 1){
                String hour = String.valueOf(Datetime.now().hour());
				//adding 2 minutes from current time to avoid too many Queuable jobs Exception
				String min = String.valueOf(Datetime.now().addMinutes(2).minute());
				String ss = String.valueOf(Datetime.now().second());
                String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                FetcheKYCDocumentHashSchedulable fetchDocumentHash = new FetcheKYCDocumentHashSchedulable(setCaseIdContainsWathiqFormOrCPRForm);
			    System.schedule('Fetch eKYC Document Hash Schedulable',nextFireTime,fetchDocumentHash);
               
            }
            else if(Limits.getQueueableJobs() < 1){
                FetcheKYCDocumentHashQueuableAPI fetchDocumentHash = new FetcheKYCDocumentHashQueuableAPI(setCaseIdContainsWathiqFormOrCPRForm);
				System.enqueueJob(fetchDocumentHash); 
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
                    String compName = 'PeriodicReviewHandler';
                    String compType = 'Apex Class';
                    String successRecordReference = String.join(new List<String>(setofSuccessFullCaseIds), ',');
                    String ObjectType = 'Case';
                    String caseCategory = 'Wathiq Acceptance Required on Customer';
                    PeriodicReviewBatchTrackerLogs.successCaselogWithCategory(compName, compType, successRecordReference,ObjectType,caseCategory);
                    
                }
                if(!setofErrorCaseIds.isEmpty()){
                    String compName = 'PeriodicReviewHandler';
                    String compType = 'Apex Class';
                    String failureRecordReference = String.join(new List<String>(setofErrorCaseIds), ',');
                    String ObjectType = 'Case';
                    String errorMessage = String.join(new List<String>(setOfErrormessage), ',');
                    PeriodicReviewBatchTrackerLogs.errorCaselog(compName, compType, failureRecordReference,errorMessage,ObjectType);
                    
                }
            }catch(Exception ex){
                String compName = 'PeriodicReviewHandler';
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
        
        System.debug('Case List Checking CPR Form/Wathiq Form Availability :'+wathiqOrCPRFormAvailableList);
        if(wathiqOrCPRFormAvailableList.size()>0){
            Set<String> setErrCaseIds = new Set<String>();
            Set<String> setofSuccessFullCaseIds = new Set<String>();
            Set<String> setofErrorCaseIds = new Set<String>();
            Set<String> setOfErrormessage = new Set<String>();
            try{
            	Database.SaveResult[] SResult = Database.update(wathiqOrCPRFormAvailableList,false);
                for(Integer i=0; i<SResult.size(); i++){
                    setErrCaseIds.add(wathiqOrCPRFormAvailableList.get(i).Id);
                    if(SResult[i].isSuccess()){
                        setofSuccessFullCaseIds.add(wathiqOrCPRFormAvailableList.get(i).Id);
                    }
                    else if(!SResult[i].isSuccess()){
                        setofErrorCaseIds.add(wathiqOrCPRFormAvailableList.get(i).Id);
                        for(Database.Error err : SResult[i].getErrors()){
                            setOfErrormessage.add(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
                if(!setofSuccessFullCaseIds.isEmpty()){
                    String compName = 'PeriodicReviewHandler';
                    String compType = 'Apex Class';
                    String successRecordReference = String.join(new List<String>(setofSuccessFullCaseIds), ',');
                    String ObjectType = 'Case';
                    String caseCategory = 'Checking CPR/Wathiq Form Availability';
                    PeriodicReviewBatchTrackerLogs.successCaselogWithCategory(compName, compType, successRecordReference,ObjectType,caseCategory);
                    
                }
                if(!setofErrorCaseIds.isEmpty()){
                    String compName = 'PeriodicReviewHandler';
                    String compType = 'Apex Class';
                    String failureRecordReference = String.join(new List<String>(setofErrorCaseIds), ',');
                    String ObjectType = 'Case';
                    String errorMessage = String.join(new List<String>(setOfErrormessage), ',');
                    PeriodicReviewBatchTrackerLogs.errorCaselog(compName, compType, failureRecordReference,errorMessage,ObjectType);
                    
                }
            }catch(Exception ex){
                String compName = 'PeriodicReviewHandler';
                String compType = 'Apex Class';
                /*for(case c : wathiqOrCPRFormAvailableList){
                    setErrCaseIds.add(c.Id);
                }*/
                String failureRecordReference = String.join(new List<String>(setErrCaseIds), ',');
                String ObjectType = 'Case';
                String errorMessage = ex.getMessage()  + ex.getStackTraceString();
                PeriodicReviewBatchTrackerLogs.errorCaselog(compName, compType, failureRecordReference,errorMessage,ObjectType); 
            }
        }
        if(accListWithoutWathiqFormWithoutCPR.size()>0)
            update accListWithoutWathiqFormWithoutCPR;
    }
    public static void handlerBeforeCaseUpdate(List<case> lstCase){
        List<eKYC_iGA_Response__c> eKYCListToUpdate = new List<eKYC_iGA_Response__c>();
		System.debug('Inside Periodic Review Before Case Update');
        for(Case caseObj : lstCase){ //for loop start
            Case caseOldObj = (Case)trigger.oldMap.get(caseobj.id);
            
            /////////////////////////////////////////// Start: QA Team is filling Re-Process Wathiq Form ///////////////////////////////////////////////////////////////////////////
            //CH02: Start
            if(caseObj.RecordType_DeveloperName__c == 'Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Force_Generate_Wathiq_Consent_Form__c == true && 
               caseObj.Re_Process_Wathiq_Form__c != caseOldObj.Re_Process_Wathiq_Form__c && caseObj.Re_Process_Wathiq_Form__c == true){
                System.debug('Before Update condition QA Team is filling the Re-Process Wathiq Form');
				caseObj.Backend_Force_Generate_Wathiq_Consent_Fo__c = false;
            }
            //CH02: END
            /////////////////////////////////////////// END: QA Team is filling Re-Process Wathiq Form ///////////////////////////////////////////////////////////////////////////

            /////////////////////////////////////////// Start: QA Team is filling Passport, Resident & Other Documents required fields /////////////////////////////////////////////
            
            if(caseObj.RecordType_DeveloperName__c == 'Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && ((caseObj.cc_Residence_Permit_No__c != caseOldObj.cc_Residence_Permit_No__c &&
               caseObj.cc_Residence_Permit_Expiry_Date__c != caseOldObj.cc_Residence_Permit_Expiry_Date__c) || (caseObj.cc_Passport_Number__c != caseOldObj.cc_Passport_Number__c &&
               caseObj.cc_Passport_Expiry_Date__c != caseOldObj.cc_Passport_Expiry_Date__c && caseObj.Document_Country__c != caseOldObj.Document_Country__c && caseObj.pcNationality__c != caseOldObj.pcNationality__c) ||
               (caseObj.pr_First_Name__c != caseOldObj.pr_First_Name__c && caseObj.pr_Middle_Name__c != caseOldObj.pr_Middle_Name__c && caseObj.pr_Last_Name__c != caseOldObj.pr_Last_Name__c  && caseObj.pcGender__c != caseOldObj.pcGender__c && caseObj.pcDate_of_Birth__c != caseOldObj.pcDate_of_Birth__c) || (caseObj.CPR_Form_Available__c != caseOldObj.CPR_Form_Available__c || caseObj.Wathiq_Consent_Form_Available__c != caseOldObj.Wathiq_Consent_Form_Available__c))){
                   System.debug('Before Update condition Checking Wathiq/CPR or Passport details or Resident details or Other details');
                   
                   if(caseObj.pr_ResidencyPermitPhotoRequired__c == true && caseObj.pr_PassportPhotoRequired__c != true && caseObj.pr_OtherDocumentsRequired__c != true && caseObj.pr_WathiqConsentFormRequired__c != true){
                       Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(caseObj.eKYC_iGA_Response__c);
                       Map<String, Object> mapJSONData = (Map<String, Object>)mapJSONResponse.get('data');
                       Map<String, Object> mapJSONIGAData = (Map<String, Object>)mapJSONData.get('igaData');
                       
                       String resPermit = 'residentPermitNo';
                       String resExpiryDate = 'residentPermitExpiry';
                       eKYC_iGA_Response__c eKYCiGA = new eKYC_iGA_Response__c(Account__c = caseObj.AccountId,Case__c = caseObj.Id);

                       if(caseObj.cc_Residence_Permit_No__c != caseOldObj.cc_Residence_Permit_No__c && caseObj.cc_Residence_Permit_No__c != null && caseObj.cc_Residence_Permit_No__c != '' &&
                          caseObj.cc_Residence_Permit_Expiry_Date__c != caseOldObj.cc_Residence_Permit_Expiry_Date__c && caseObj.cc_Residence_Permit_Expiry_Date__c != null){
                              System.debug('Changing only Resident required photo related fields');
                              if(mapJSONIGAData.containsKey(resPermit)){
                                  mapJSONIGAData.put(resPermit,caseObj.cc_Residence_Permit_No__c);
                              }else{
                                  mapJSONIGAData.put(resPermit,caseObj.cc_Residence_Permit_No__c);
                              } 
                              
                              if(mapJSONIGAData.containsKey(resExpiryDate)){
                                  String dateStr = caseObj.cc_Residence_Permit_Expiry_Date__c.format();
                                  System.debug('Salesforce Date 1:'+caseObj.cc_Residence_Permit_Expiry_Date__c);
                                  System.debug('Date String 1:'+dateStr); //"30/11/1970"
                                  mapJSONIGAData.put(resExpiryDate,dateStr);
                              }else{
                                  String dateStr = caseObj.cc_Residence_Permit_Expiry_Date__c.format();
                                  System.debug('Salesforce Date 2:'+caseObj.cc_Residence_Permit_Expiry_Date__c);
                                  System.debug('Date String 2:'+dateStr);
                                  mapJSONIGAData.put(resExpiryDate,dateStr);
                              } 
                          }
                       Map<String,Object> jsonString= mapJSONResponse;
                       System.debug('eKYC Response after Resident details update:'+JSON.serializePretty(jsonString));
                       caseObj.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                       caseObj.pr_ResidencyPermitPhotoRequired__c = false;
                       eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                       eKYCListToUpdate.add(eKYCiGA);
                   }
                   else if(caseObj.pr_ResidencyPermitPhotoRequired__c != true && caseObj.pr_PassportPhotoRequired__c == true && caseObj.pr_OtherDocumentsRequired__c != true && caseObj.pr_WathiqConsentFormRequired__c != true){
                       Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(caseObj.eKYC_iGA_Response__c);
                       Map<String, Object> mapJSONData = (Map<String, Object>)mapJSONResponse.get('data');
                       Map<String, Object> mapJSONIGAData = (Map<String, Object>)mapJSONData.get('igaData');
                       
                       String passNumber = 'passportNumber';
                       String passExpiryDate = 'passportExpiryDate';
                       String DocumentCountry = 'cardCountry';
                       String Nationality = 'nationality';
                       eKYC_iGA_Response__c eKYCiGA = new eKYC_iGA_Response__c(Account__c = caseObj.AccountId,Case__c = caseObj.Id);

                       if(caseObj.cc_Passport_Number__c != caseOldObj.cc_Passport_Number__c && caseObj.cc_Passport_Number__c != null && caseObj.cc_Passport_Number__c != '' &&
                          caseObj.cc_Passport_Expiry_Date__c != caseOldObj.cc_Passport_Expiry_Date__c && caseObj.cc_Passport_Expiry_Date__c != null &&
                          caseObj.Document_Country__c != caseOldObj.Document_Country__c && caseObj.Document_Country__c != null && caseObj.pcNationality__c != caseOldObj.pcNationality__c && caseObj.pcNationality__c != null){
                              System.debug('Changing only Passport required photo related fields');
                              
                              if(mapJSONIGAData.containsKey(passNumber)){
                                  mapJSONIGAData.put(passNumber,caseObj.cc_Passport_Number__c);
                              }else{
                                  mapJSONIGAData.put(passNumber,caseObj.cc_Passport_Number__c);
                              } 
                              
                              if(mapJSONIGAData.containsKey(passExpiryDate)){
                                  String dateStr = caseObj.cc_Passport_Expiry_Date__c.format();
                                  mapJSONIGAData.put(passExpiryDate,dateStr);
                              }else{
                                  String dateStr = caseObj.cc_Passport_Expiry_Date__c.format();
                                  mapJSONIGAData.put(passExpiryDate,dateStr);
                              }
                              
                              if(mapJSONIGAData.containsKey(DocumentCountry)){
                                  mapJSONIGAData.put(DocumentCountry,caseObj.Document_Country__c);
                              }else{
                                  mapJSONIGAData.put(DocumentCountry,caseObj.Document_Country__c);
                              }
                              
                              if(mapJSONIGAData.containsKey(Nationality)){
                                  mapJSONIGAData.put(Nationality,caseObj.pcNationality__c);
                              }else{
                                  mapJSONIGAData.put(Nationality,caseObj.pcNationality__c);
                              }
                          }
                       Map<String,Object> jsonString= mapJSONResponse;
                       System.debug('eKYC Response after passport details update:'+JSON.serializePretty(jsonString));
                       caseObj.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                       caseObj.pr_PassportPhotoRequired__c = false;
                       eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                       eKYCListToUpdate.add(eKYCiGA);
                       
                   }
                   else if(caseObj.pr_ResidencyPermitPhotoRequired__c != true && caseObj.pr_PassportPhotoRequired__c != true && caseObj.pr_OtherDocumentsRequired__c == true && caseObj.pr_WathiqConsentFormRequired__c != true){
                       Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(caseObj.eKYC_iGA_Response__c);
                       Map<String, Object> mapJSONData = (Map<String, Object>)mapJSONResponse.get('data');
                       Map<String, Object> mapJSONIGAData = (Map<String, Object>)mapJSONData.get('igaData');
                       String FName = 'enFirstName';
                       String MName = 'enMiddleName1';
                       String MName2 = 'enMiddleName2';
                       String MName3 = 'enMiddleName3';
					   String MName4 = 'enMiddleName4';
                       String LName = 'enLastName';
                       String Gender = 'gender';
                       String DOB = 'dateOfBirth';
                       eKYC_iGA_Response__c eKYCiGA = new eKYC_iGA_Response__c(Account__c = caseObj.AccountId,Case__c = caseObj.Id);

                       if(caseObj.pr_First_Name__c != caseOldObj.pr_First_Name__c && caseObj.pr_First_Name__c != '' && caseObj.pr_First_Name__c != null && 
                          caseObj.pr_Middle_Name__c != caseOldObj.pr_Middle_Name__c && caseObj.pr_Middle_Name__c != '' && caseObj.pr_Middle_Name__c != null &&
                          caseObj.pr_Last_Name__c != caseOldObj.pr_Last_Name__c && caseObj.pr_Last_Name__c != '' && caseObj.pr_Last_Name__c != null &&
						  caseObj.pcGender__c != caseOldObj.pcGender__c && caseObj.pcGender__c != null && caseObj.pcDate_of_Birth__c != caseOldObj.pcDate_of_Birth__c && caseObj.pcDate_of_Birth__c != null){
                             System.debug('Changing only Other Docs required related fields');
							 
                              if(mapJSONIGAData.containsKey(FName)){
                                  mapJSONIGAData.put(FName,caseObj.pr_First_Name__c);
                              }else{
                                  mapJSONIGAData.put(FName,caseObj.pr_First_Name__c);
                              }
                              
                              if(mapJSONIGAData.containsKey(MName)){
                                  mapJSONIGAData.put(MName,caseObj.pr_Middle_Name__c);
                              }else{
                                  mapJSONIGAData.put(MName,caseObj.pr_Middle_Name__c);
                              }
                              
                              if(caseObj.pr_Middle_Name_2__c != caseOldObj.pr_Middle_Name_2__c && caseObj.pr_Middle_Name_2__c != null ){
                                  if(mapJSONIGAData.containsKey(MName2)){
                                      mapJSONIGAData.put(MName2,caseObj.pr_Middle_Name_2__c);
                                  }else{
                                      mapJSONIGAData.put(MName2,caseObj.pr_Middle_Name_2__c);
                                  }
                              }else{
                                  mapJSONIGAData.put(MName2,'');
                              }
                              
                              if(caseObj.pr_Middle_Name_3__c != caseOldObj.pr_Middle_Name_3__c && caseObj.pr_Middle_Name_3__c != null){
                                  if(mapJSONIGAData.containsKey(MName3)){
                                      mapJSONIGAData.put(MName3,caseObj.pr_Middle_Name_3__c);
                                  }else{
                                      mapJSONIGAData.put(MName3,caseObj.pr_Middle_Name_3__c);
                                  }
                              }else{
                                   mapJSONIGAData.put(MName3,'');
                              }
                              
                              if(caseObj.pr_Middle_Name_4__c != caseOldObj.pr_Middle_Name_4__c && caseObj.pr_Middle_Name_4__c != null){
                                  if(mapJSONIGAData.containsKey(MName4)){
                                      mapJSONIGAData.put(MName4,caseObj.pr_Middle_Name_4__c);
                                  }else{
                                      mapJSONIGAData.put(MName4,caseObj.pr_Middle_Name_4__c);
                                  }
                              }else{
                                   mapJSONIGAData.put(MName4,'');
                              }
                              
                              if(mapJSONIGAData.containsKey(LName)){
                                  mapJSONIGAData.put(LName,caseObj.pr_Last_Name__c);
                              }else{
                                  mapJSONIGAData.put(LName,caseObj.pr_Last_Name__c);
                              }
                              
                              if(mapJSONIGAData.containsKey(Gender)){
                                  mapJSONIGAData.put(Gender,caseObj.pcGender__c);
                              }else{
                                  mapJSONIGAData.put(Gender,caseObj.pcGender__c);
                              }
                           
                              if(mapJSONIGAData.containsKey(DOB)){
                                  String dateStr = caseObj.pcDate_of_Birth__c.format();
								  mapJSONIGAData.put(DOB,dateStr);
                              }else{
                                  String dateStr = caseObj.pcDate_of_Birth__c.format();
								  mapJSONIGAData.put(DOB,dateStr);
                              }
                       }
                       Map<String,Object> jsonString= mapJSONResponse;
                       System.debug('eKYC Response after Other docs update:'+JSON.serializePretty(jsonString));
                       caseObj.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                       caseObj.pr_OtherDocumentsRequired__c = false;
                       eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                       eKYCListToUpdate.add(eKYCiGA);
                   }
                   /********************************************* Start: When Passport & Resident Details are filled by the QA Team **************************************************************************************/
                   else if(caseObj.pr_ResidencyPermitPhotoRequired__c == true && caseObj.pr_PassportPhotoRequired__c == true && caseObj.pr_OtherDocumentsRequired__c != true && caseObj.pr_WathiqConsentFormRequired__c != true){
                       System.debug('QA Team is inserting resident & Passport details');
                        
                       if(caseObj.cc_Passport_Number__c != caseOldObj.cc_Passport_Number__c && caseObj.cc_Passport_Number__c != null && caseObj.cc_Passport_Number__c != '' &&
                          caseObj.cc_Passport_Expiry_Date__c != caseOldObj.cc_Passport_Expiry_Date__c && caseObj.cc_Passport_Expiry_Date__c != null &&
                          caseObj.Document_Country__c != caseOldObj.Document_Country__c && caseObj.Document_Country__c != null && caseObj.pcNationality__c != caseOldObj.pcNationality__c && caseObj.pcNationality__c != null){
                              
                              Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(caseObj.eKYC_iGA_Response__c);
                              Map<String, Object> mapJSONData = (Map<String, Object>)mapJSONResponse.get('data');
                              Map<String, Object> mapJSONIGAData = (Map<String, Object>)mapJSONData.get('igaData');
                              
                              String passNumber = 'passportNumber';
                              String passExpiryDate = 'passportExpiryDate';
                              String DocumentCountry = 'cardCountry';
                              String Nationality = 'nationality';
                              eKYC_iGA_Response__c eKYCiGA = new eKYC_iGA_Response__c(Account__c = caseObj.AccountId,Case__c = caseObj.Id);
                              System.debug('Changing only Passport required photo related fields when Passport and Resident Photo Required = true');
                              
                              if(mapJSONIGAData.containsKey(passNumber)){
                                  mapJSONIGAData.put(passNumber,caseObj.cc_Passport_Number__c);
                              }else{
                                  mapJSONIGAData.put(passNumber,caseObj.cc_Passport_Number__c);
                              } 
                              
                              if(mapJSONIGAData.containsKey(passExpiryDate)){
                                  String dateStr = caseObj.cc_Passport_Expiry_Date__c.format();
                                  mapJSONIGAData.put(passExpiryDate,dateStr);
                              }else{
                                  String dateStr = caseObj.cc_Passport_Expiry_Date__c.format();
                                  mapJSONIGAData.put(passExpiryDate,dateStr);
                              }
                              
                              if(mapJSONIGAData.containsKey(DocumentCountry)){
                                  mapJSONIGAData.put(DocumentCountry,caseObj.Document_Country__c);
                              }else{
                                  mapJSONIGAData.put(DocumentCountry,caseObj.Document_Country__c);
                              }
                              
                              if(mapJSONIGAData.containsKey(Nationality)){
                                  mapJSONIGAData.put(Nationality,caseObj.pcNationality__c);
                              }else{
                                  mapJSONIGAData.put(Nationality,caseObj.pcNationality__c);
                              }
                              
                              Map<String,Object> jsonString= mapJSONResponse;
                       	  	  System.debug('eKYC Response after passport details update when Passport and Resident Photo Required = true:'+JSON.serializePretty(jsonString));
                       	      caseObj.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                              caseObj.pr_PassportPhotoRequired__c = false;
                              eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                              eKYCListToUpdate.add(eKYCiGA);
                          } //End if related to Passport Expiry details
                       
                       if(caseObj.cc_Residence_Permit_No__c != caseOldObj.cc_Residence_Permit_No__c && caseObj.cc_Residence_Permit_No__c != null && caseObj.cc_Residence_Permit_No__c != '' &&
                          caseObj.cc_Residence_Permit_Expiry_Date__c != caseOldObj.cc_Residence_Permit_Expiry_Date__c && caseObj.cc_Residence_Permit_Expiry_Date__c != null){
                              Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(caseObj.eKYC_iGA_Response__c);
                              Map<String, Object> mapJSONData = (Map<String, Object>)mapJSONResponse.get('data');
                              Map<String, Object> mapJSONIGAData = (Map<String, Object>)mapJSONData.get('igaData');
                              
                              String resPermit = 'residentPermitNo';
                              String resExpiryDate = 'residentPermitExpiry';
                              eKYC_iGA_Response__c eKYCiGA = new eKYC_iGA_Response__c(Account__c = caseObj.AccountId,Case__c = caseObj.Id);
                              System.debug('Changing only Resident required photo related fields when Passport and Resident Photo Required = true');
                              if(mapJSONIGAData.containsKey(resPermit)){
                                  mapJSONIGAData.put(resPermit,caseObj.cc_Residence_Permit_No__c);
                              }else{
                                  mapJSONIGAData.put(resPermit,caseObj.cc_Residence_Permit_No__c);
                              } 
                              
                              if(mapJSONIGAData.containsKey(resExpiryDate)){
                                  String dateStr = caseObj.cc_Residence_Permit_Expiry_Date__c.format();
                                  System.debug('Salesforce Date 1 when Passport and Resident Photo Required = true:'+caseObj.cc_Residence_Permit_Expiry_Date__c);
                                  System.debug('Date String 1 when Passport and Resident Photo Required = true:'+dateStr); //"30/11/1970"
                                  mapJSONIGAData.put(resExpiryDate,dateStr);
                              }else{
                                  String dateStr = caseObj.cc_Residence_Permit_Expiry_Date__c.format();
                                  System.debug('Salesforce Date 2 when Passport and Resident Photo Required = true:'+caseObj.cc_Residence_Permit_Expiry_Date__c);
                                  System.debug('Date String 2 when Passport and Resident Photo Required = true:'+dateStr);
                                  mapJSONIGAData.put(resExpiryDate,dateStr);
                              }
                              Map<String,Object> jsonString= mapJSONResponse;
                              System.debug('eKYC Response after Resident details update when Passport and Resident Photo Required = true:'+JSON.serializePretty(jsonString));
                              caseObj.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                              caseObj.pr_ResidencyPermitPhotoRequired__c = false;
                              eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                              eKYCListToUpdate.add(eKYCiGA);
                          } //End If related to resident Expiry details
                       
                    } //End else if
                   /********************************************* END: When Passport & Resident Details are filled by the QA Team **************************************************************************************/
 
                   /********************************************* Start: When Resident & Other Documents are filled by the QA Team ************************************************************************************************/
                   else if(caseObj.pr_ResidencyPermitPhotoRequired__c == true && caseObj.pr_PassportPhotoRequired__c != true && caseObj.pr_OtherDocumentsRequired__c == true && caseObj.pr_WathiqConsentFormRequired__c != true){
                        
                       if(caseObj.cc_Residence_Permit_No__c != caseOldObj.cc_Residence_Permit_No__c && caseObj.cc_Residence_Permit_No__c != null && caseObj.cc_Residence_Permit_No__c != '' &&
                          caseObj.cc_Residence_Permit_Expiry_Date__c != caseOldObj.cc_Residence_Permit_Expiry_Date__c && caseObj.cc_Residence_Permit_Expiry_Date__c != null){
                              Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(caseObj.eKYC_iGA_Response__c);
                              Map<String, Object> mapJSONData = (Map<String, Object>)mapJSONResponse.get('data');
                              Map<String, Object> mapJSONIGAData = (Map<String, Object>)mapJSONData.get('igaData');
                              
                              String resPermit = 'residentPermitNo';
                              String resExpiryDate = 'residentPermitExpiry';
                              eKYC_iGA_Response__c eKYCiGA = new eKYC_iGA_Response__c(Account__c = caseObj.AccountId,Case__c = caseObj.Id);
                              System.debug('Changing only Resident required photo related fields when Resident and Other docs Required = true');
                              if(mapJSONIGAData.containsKey(resPermit)){
                                  mapJSONIGAData.put(resPermit,caseObj.cc_Residence_Permit_No__c);
                              }else{
                                  mapJSONIGAData.put(resPermit,caseObj.cc_Residence_Permit_No__c);
                              } 
                              
                              if(mapJSONIGAData.containsKey(resExpiryDate)){
                                  String dateStr = caseObj.cc_Residence_Permit_Expiry_Date__c.format();
                                  System.debug('Salesforce Date 1 when Resident and Other docs Required = true:'+caseObj.cc_Residence_Permit_Expiry_Date__c);
                                  System.debug('Date String 1 when Resident and Other docs Required = true:'+dateStr); //"30/11/1970"
                                  mapJSONIGAData.put(resExpiryDate,dateStr);
                              }else{
                                  String dateStr = caseObj.cc_Residence_Permit_Expiry_Date__c.format();
                                  System.debug('Salesforce Date 2 when Resident and Other docs Required = true:'+caseObj.cc_Residence_Permit_Expiry_Date__c);
                                  System.debug('Date String 2 when Resident and Other docs Required = true:'+dateStr);
                                  mapJSONIGAData.put(resExpiryDate,dateStr);
                              }
                              Map<String,Object> jsonString= mapJSONResponse;
                              System.debug('eKYC Response after Resident details update when Resident and Other docs Required = true:'+JSON.serializePretty(jsonString));
                              caseObj.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                              caseObj.pr_ResidencyPermitPhotoRequired__c = false;
                              eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                              eKYCListToUpdate.add(eKYCiGA);
                          } //End If related to resident Expiry details
                       
                       if(caseObj.pr_First_Name__c != caseOldObj.pr_First_Name__c && caseObj.pr_First_Name__c != '' && caseObj.pr_First_Name__c != null && 
                          caseObj.pr_Middle_Name__c != caseOldObj.pr_Middle_Name__c && caseObj.pr_Middle_Name__c != '' && caseObj.pr_Middle_Name__c != null &&
                          caseObj.pr_Last_Name__c != caseOldObj.pr_Last_Name__c && caseObj.pr_Last_Name__c != '' && caseObj.pr_Last_Name__c != null &&
						  caseObj.pcGender__c != caseOldObj.pcGender__c && caseObj.pcGender__c != null && caseObj.pcDate_of_Birth__c != caseOldObj.pcDate_of_Birth__c && caseObj.pcDate_of_Birth__c != null){
                               Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(caseObj.eKYC_iGA_Response__c);
                       		   Map<String, Object> mapJSONData = (Map<String, Object>)mapJSONResponse.get('data');
                       		   Map<String, Object> mapJSONIGAData = (Map<String, Object>)mapJSONData.get('igaData');
                               String FName = 'enFirstName';
                               String MName = 'enMiddleName1';
                               String MName2 = 'enMiddleName2';
                               String MName3 = 'enMiddleName3';
					           String MName4 = 'enMiddleName4';
                               String LName = 'enLastName';
                               String Gender = 'gender';
                               String DOB = 'dateOfBirth';
                               eKYC_iGA_Response__c eKYCiGA = new eKYC_iGA_Response__c(Account__c = caseObj.AccountId,Case__c = caseObj.Id);

                              System.debug('Changing only Other Docs required related fields Resident and Other docs Required = true');
							 
                              if(mapJSONIGAData.containsKey(FName)){
                                  mapJSONIGAData.put(FName,caseObj.pr_First_Name__c);
                              }else{
                                  mapJSONIGAData.put(FName,caseObj.pr_First_Name__c);
                              }
                              
                              if(mapJSONIGAData.containsKey(MName)){
                                  mapJSONIGAData.put(MName,caseObj.pr_Middle_Name__c);
                              }else{
                                  mapJSONIGAData.put(MName,caseObj.pr_Middle_Name__c);
                              }
                              
                              if(caseObj.pr_Middle_Name_2__c != caseOldObj.pr_Middle_Name_2__c && caseObj.pr_Middle_Name_2__c != null ){
                                  if(mapJSONIGAData.containsKey(MName2)){
                                      mapJSONIGAData.put(MName2,caseObj.pr_Middle_Name_2__c);
                                  }else{
                                      mapJSONIGAData.put(MName2,caseObj.pr_Middle_Name_2__c);
                                  }
                              }else{
                                  mapJSONIGAData.put(MName2,'');
                              }
                              
                              if(caseObj.pr_Middle_Name_3__c != caseOldObj.pr_Middle_Name_3__c && caseObj.pr_Middle_Name_3__c != null){
                                  if(mapJSONIGAData.containsKey(MName3)){
                                      mapJSONIGAData.put(MName3,caseObj.pr_Middle_Name_3__c);
                                  }else{
                                      mapJSONIGAData.put(MName3,caseObj.pr_Middle_Name_3__c);
                                  }
                              }else{
                                   mapJSONIGAData.put(MName3,'');
                              }
                              
                              if(caseObj.pr_Middle_Name_4__c != caseOldObj.pr_Middle_Name_4__c && caseObj.pr_Middle_Name_4__c != null){
                                  if(mapJSONIGAData.containsKey(MName4)){
                                      mapJSONIGAData.put(MName4,caseObj.pr_Middle_Name_4__c);
                                  }else{
                                      mapJSONIGAData.put(MName4,caseObj.pr_Middle_Name_4__c);
                                  }
                              }else{
                                   mapJSONIGAData.put(MName4,'');
                              }
                              
                              if(mapJSONIGAData.containsKey(LName)){
                                  mapJSONIGAData.put(LName,caseObj.pr_Last_Name__c);
                              }else{
                                  mapJSONIGAData.put(LName,caseObj.pr_Last_Name__c);
                              }
                              
                              if(mapJSONIGAData.containsKey(Gender)){
                                  mapJSONIGAData.put(Gender,caseObj.pcGender__c);
                              }else{
                                  mapJSONIGAData.put(Gender,caseObj.pcGender__c);
                              }
                           
                              if(mapJSONIGAData.containsKey(DOB)){
                                  String dateStr = caseObj.pcDate_of_Birth__c.format();
								  mapJSONIGAData.put(DOB,dateStr);
                              }else{
                                  String dateStr = caseObj.pcDate_of_Birth__c.format();
								  mapJSONIGAData.put(DOB,dateStr);
                              }
                              Map<String,Object> jsonString= mapJSONResponse;
                       		  System.debug('eKYC Response Resident and Other docs Required = true:'+JSON.serializePretty(jsonString));
                              caseObj.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                              caseObj.pr_OtherDocumentsRequired__c = false;
                              eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                              eKYCListToUpdate.add(eKYCiGA);
                       } //End if related to Other Documents details
                   } //End of else if
                   /********************************************* END: When Resident & Other Documents are filled by the QA Team ************************************************************************************************/

                   /********************************************* Start: When Passport & Other Documents are filled by the QA Team ***********************************************************************************************/
                   else if(caseObj.pr_ResidencyPermitPhotoRequired__c != true && caseObj.pr_PassportPhotoRequired__c == true && caseObj.pr_OtherDocumentsRequired__c == true && caseObj.pr_WathiqConsentFormRequired__c != true){
                       
                       if(caseObj.cc_Passport_Number__c != caseOldObj.cc_Passport_Number__c && caseObj.cc_Passport_Number__c != null && caseObj.cc_Passport_Number__c != '' &&
                          caseObj.cc_Passport_Expiry_Date__c != caseOldObj.cc_Passport_Expiry_Date__c && caseObj.cc_Passport_Expiry_Date__c != null &&
                          caseObj.Document_Country__c != caseOldObj.Document_Country__c && caseObj.Document_Country__c != null && caseObj.pcNationality__c != caseOldObj.pcNationality__c && caseObj.pcNationality__c != null){
                              
                              Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(caseObj.eKYC_iGA_Response__c);
                              Map<String, Object> mapJSONData = (Map<String, Object>)mapJSONResponse.get('data');
                              Map<String, Object> mapJSONIGAData = (Map<String, Object>)mapJSONData.get('igaData');
                              
                              String passNumber = 'passportNumber';
                              String passExpiryDate = 'passportExpiryDate';
                              String DocumentCountry = 'cardCountry';
                              String Nationality = 'nationality';
                              eKYC_iGA_Response__c eKYCiGA = new eKYC_iGA_Response__c(Account__c = caseObj.AccountId,Case__c = caseObj.Id);
                              System.debug('Changing only Passport required photo related fields when Passport and Other Docs Required = true');
                              
                              if(mapJSONIGAData.containsKey(passNumber)){
                                  mapJSONIGAData.put(passNumber,caseObj.cc_Passport_Number__c);
                              }else{
                                  mapJSONIGAData.put(passNumber,caseObj.cc_Passport_Number__c);
                              } 
                              
                              if(mapJSONIGAData.containsKey(passExpiryDate)){
                                  String dateStr = caseObj.cc_Passport_Expiry_Date__c.format();
                                  mapJSONIGAData.put(passExpiryDate,dateStr);
                              }else{
                                  String dateStr = caseObj.cc_Passport_Expiry_Date__c.format();
                                  mapJSONIGAData.put(passExpiryDate,dateStr);
                              }
                              
                              if(mapJSONIGAData.containsKey(DocumentCountry)){
                                  mapJSONIGAData.put(DocumentCountry,caseObj.Document_Country__c);
                              }else{
                                  mapJSONIGAData.put(DocumentCountry,caseObj.Document_Country__c);
                              }
                              
                              if(mapJSONIGAData.containsKey(Nationality)){
                                  mapJSONIGAData.put(Nationality,caseObj.pcNationality__c);
                              }else{
                                  mapJSONIGAData.put(Nationality,caseObj.pcNationality__c);
                              }
                              
                              Map<String,Object> jsonString= mapJSONResponse;
                       	  	  System.debug('eKYC Response after passport details update when Passport and Other Required = true:'+JSON.serializePretty(jsonString));
                       	      caseObj.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                              caseObj.pr_PassportPhotoRequired__c = false;
                              eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                              eKYCListToUpdate.add(eKYCiGA);
                          } //End if related to Passport Expiry details
                       
                        if(caseObj.pr_First_Name__c != caseOldObj.pr_First_Name__c && caseObj.pr_First_Name__c != '' && caseObj.pr_First_Name__c != null && 
                          caseObj.pr_Middle_Name__c != caseOldObj.pr_Middle_Name__c && caseObj.pr_Middle_Name__c != '' && caseObj.pr_Middle_Name__c != null &&
                          caseObj.pr_Last_Name__c != caseOldObj.pr_Last_Name__c && caseObj.pr_Last_Name__c != '' && caseObj.pr_Last_Name__c != null &&
						  caseObj.pcGender__c != caseOldObj.pcGender__c && caseObj.pcGender__c != null && caseObj.pcDate_of_Birth__c != caseOldObj.pcDate_of_Birth__c && caseObj.pcDate_of_Birth__c != null){
                               Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(caseObj.eKYC_iGA_Response__c);
                       		   Map<String, Object> mapJSONData = (Map<String, Object>)mapJSONResponse.get('data');
                       		   Map<String, Object> mapJSONIGAData = (Map<String, Object>)mapJSONData.get('igaData');
                               String FName = 'enFirstName';
                               String MName = 'enMiddleName1';
                               String MName2 = 'enMiddleName2';
                               String MName3 = 'enMiddleName3';
					           String MName4 = 'enMiddleName4';
                               String LName = 'enLastName';
                               String Gender = 'gender';
                               String DOB = 'dateOfBirth';
                               eKYC_iGA_Response__c eKYCiGA = new eKYC_iGA_Response__c(Account__c = caseObj.AccountId,Case__c = caseObj.Id);

                              System.debug('Changing only Other Docs required related fields Passport and Other docs Required = true');
							 
                              if(mapJSONIGAData.containsKey(FName)){
                                  mapJSONIGAData.put(FName,caseObj.pr_First_Name__c);
                              }else{
                                  mapJSONIGAData.put(FName,caseObj.pr_First_Name__c);
                              }
                              
                              if(mapJSONIGAData.containsKey(MName)){
                                  mapJSONIGAData.put(MName,caseObj.pr_Middle_Name__c);
                              }else{
                                  mapJSONIGAData.put(MName,caseObj.pr_Middle_Name__c);
                              }
                              
                              if(caseObj.pr_Middle_Name_2__c != caseOldObj.pr_Middle_Name_2__c && caseObj.pr_Middle_Name_2__c != null ){
                                  if(mapJSONIGAData.containsKey(MName2)){
                                      mapJSONIGAData.put(MName2,caseObj.pr_Middle_Name_2__c);
                                  }else{
                                      mapJSONIGAData.put(MName2,caseObj.pr_Middle_Name_2__c);
                                  }
                              }else{
                                  mapJSONIGAData.put(MName2,'');
                              }
                              
                              if(caseObj.pr_Middle_Name_3__c != caseOldObj.pr_Middle_Name_3__c && caseObj.pr_Middle_Name_3__c != null){
                                  if(mapJSONIGAData.containsKey(MName3)){
                                      mapJSONIGAData.put(MName3,caseObj.pr_Middle_Name_3__c);
                                  }else{
                                      mapJSONIGAData.put(MName3,caseObj.pr_Middle_Name_3__c);
                                  }
                              }else{
                                   mapJSONIGAData.put(MName3,'');
                              }
                              
                              if(caseObj.pr_Middle_Name_4__c != caseOldObj.pr_Middle_Name_4__c && caseObj.pr_Middle_Name_4__c != null){
                                  if(mapJSONIGAData.containsKey(MName4)){
                                      mapJSONIGAData.put(MName4,caseObj.pr_Middle_Name_4__c);
                                  }else{
                                      mapJSONIGAData.put(MName4,caseObj.pr_Middle_Name_4__c);
                                  }
                              }else{
                                   mapJSONIGAData.put(MName4,'');
                              }
                              
                              if(mapJSONIGAData.containsKey(LName)){
                                  mapJSONIGAData.put(LName,caseObj.pr_Last_Name__c);
                              }else{
                                  mapJSONIGAData.put(LName,caseObj.pr_Last_Name__c);
                              }
                              
                              if(mapJSONIGAData.containsKey(Gender)){
                                  mapJSONIGAData.put(Gender,caseObj.pcGender__c);
                              }else{
                                  mapJSONIGAData.put(Gender,caseObj.pcGender__c);
                              }
                           
                              if(mapJSONIGAData.containsKey(DOB)){
                                  String dateStr = caseObj.pcDate_of_Birth__c.format();
								  mapJSONIGAData.put(DOB,dateStr);
                              }else{
                                  String dateStr = caseObj.pcDate_of_Birth__c.format();
								  mapJSONIGAData.put(DOB,dateStr);
                              }
                              Map<String,Object> jsonString= mapJSONResponse;
                       		  System.debug('eKYC Response passport and Other docs Required = true:'+JSON.serializePretty(jsonString));
                              caseObj.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                              caseObj.pr_OtherDocumentsRequired__c = false;
                              eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                              eKYCListToUpdate.add(eKYCiGA);
                       } //End if related to Other Documents details
                   }
                   /********************************************* END: When Passport & Other Documents are filled by the QA Team ***********************************************************************************************/
                   
                   /********************************************** Start: When Passport Details, Resident Details and Other Documents are filled by the QA team **********************************************************************/
                   else if(caseObj.pr_ResidencyPermitPhotoRequired__c == true && caseObj.pr_PassportPhotoRequired__c == true && caseObj.pr_OtherDocumentsRequired__c == true && caseObj.pr_WathiqConsentFormRequired__c != true){
                       
                       if(caseObj.cc_Passport_Number__c != caseOldObj.cc_Passport_Number__c && caseObj.cc_Passport_Number__c != null && caseObj.cc_Passport_Number__c != '' &&
                          caseObj.cc_Passport_Expiry_Date__c != caseOldObj.cc_Passport_Expiry_Date__c && caseObj.cc_Passport_Expiry_Date__c != null &&
                          caseObj.Document_Country__c != caseOldObj.Document_Country__c && caseObj.Document_Country__c != null && caseObj.pcNationality__c != caseOldObj.pcNationality__c && caseObj.pcNationality__c != null){
                              
                              Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(caseObj.eKYC_iGA_Response__c);
                              Map<String, Object> mapJSONData = (Map<String, Object>)mapJSONResponse.get('data');
                              Map<String, Object> mapJSONIGAData = (Map<String, Object>)mapJSONData.get('igaData');
                              
                              String passNumber = 'passportNumber';
                              String passExpiryDate = 'passportExpiryDate';
                              String DocumentCountry = 'cardCountry';
                              String Nationality = 'nationality';
                              eKYC_iGA_Response__c eKYCiGA = new eKYC_iGA_Response__c(Account__c = caseObj.AccountId,Case__c = caseObj.Id);
                              System.debug('Changing only Passport required photo related fields when Passport and Other Docs Required = true');
                              
                              if(mapJSONIGAData.containsKey(passNumber)){
                                  mapJSONIGAData.put(passNumber,caseObj.cc_Passport_Number__c);
                              }else{
                                  mapJSONIGAData.put(passNumber,caseObj.cc_Passport_Number__c);
                              } 
                              
                              if(mapJSONIGAData.containsKey(passExpiryDate)){
                                  String dateStr = caseObj.cc_Passport_Expiry_Date__c.format();
                                  mapJSONIGAData.put(passExpiryDate,dateStr);
                              }else{
                                  String dateStr = caseObj.cc_Passport_Expiry_Date__c.format();
                                  mapJSONIGAData.put(passExpiryDate,dateStr);
                              }
                              
                              if(mapJSONIGAData.containsKey(DocumentCountry)){
                                  mapJSONIGAData.put(DocumentCountry,caseObj.Document_Country__c);
                              }else{
                                  mapJSONIGAData.put(DocumentCountry,caseObj.Document_Country__c);
                              }
                              
                              if(mapJSONIGAData.containsKey(Nationality)){
                                  mapJSONIGAData.put(Nationality,caseObj.pcNationality__c);
                              }else{
                                  mapJSONIGAData.put(Nationality,caseObj.pcNationality__c);
                              }
                              
                              Map<String,Object> jsonString= mapJSONResponse;
                       	  	  System.debug('eKYC Response after passport details update when Passport and Other Required = true:'+JSON.serializePretty(jsonString));
                       	      caseObj.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                              caseObj.pr_PassportPhotoRequired__c = false;
                              eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                              eKYCListToUpdate.add(eKYCiGA);
                          } //End if related to Passport Expiry details
                       
                        if(caseObj.pr_First_Name__c != caseOldObj.pr_First_Name__c && caseObj.pr_First_Name__c != '' && caseObj.pr_First_Name__c != null && 
                          caseObj.pr_Middle_Name__c != caseOldObj.pr_Middle_Name__c && caseObj.pr_Middle_Name__c != '' && caseObj.pr_Middle_Name__c != null &&
                          caseObj.pr_Last_Name__c != caseOldObj.pr_Last_Name__c && caseObj.pr_Last_Name__c != '' && caseObj.pr_Last_Name__c != null &&
						  caseObj.pcGender__c != caseOldObj.pcGender__c && caseObj.pcGender__c != null && caseObj.pcDate_of_Birth__c != caseOldObj.pcDate_of_Birth__c && caseObj.pcDate_of_Birth__c != null){
                               Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(caseObj.eKYC_iGA_Response__c);
                       		   Map<String, Object> mapJSONData = (Map<String, Object>)mapJSONResponse.get('data');
                       		   Map<String, Object> mapJSONIGAData = (Map<String, Object>)mapJSONData.get('igaData');
                               String FName = 'enFirstName';
                               String MName = 'enMiddleName1';
                               String MName2 = 'enMiddleName2';
                               String MName3 = 'enMiddleName3';
					           String MName4 = 'enMiddleName4';
                               String LName = 'enLastName';
                               String Gender = 'gender';
                               String DOB = 'dateOfBirth';
                               eKYC_iGA_Response__c eKYCiGA = new eKYC_iGA_Response__c(Account__c = caseObj.AccountId,Case__c = caseObj.Id);

                              System.debug('Changing only Other Docs required related fields Passport and Other docs Required = true');
							 
                              if(mapJSONIGAData.containsKey(FName)){
                                  mapJSONIGAData.put(FName,caseObj.pr_First_Name__c);
                              }else{
                                  mapJSONIGAData.put(FName,caseObj.pr_First_Name__c);
                              }
                              
                              if(mapJSONIGAData.containsKey(MName)){
                                  mapJSONIGAData.put(MName,caseObj.pr_Middle_Name__c);
                              }else{
                                  mapJSONIGAData.put(MName,caseObj.pr_Middle_Name__c);
                              }
                              
                              if(caseObj.pr_Middle_Name_2__c != caseOldObj.pr_Middle_Name_2__c && caseObj.pr_Middle_Name_2__c != null ){
                                  if(mapJSONIGAData.containsKey(MName2)){
                                      mapJSONIGAData.put(MName2,caseObj.pr_Middle_Name_2__c);
                                  }else{
                                      mapJSONIGAData.put(MName2,caseObj.pr_Middle_Name_2__c);
                                  }
                              }else{
                                  mapJSONIGAData.put(MName2,'');
                              }
                              
                              if(caseObj.pr_Middle_Name_3__c != caseOldObj.pr_Middle_Name_3__c && caseObj.pr_Middle_Name_3__c != null){
                                  if(mapJSONIGAData.containsKey(MName3)){
                                      mapJSONIGAData.put(MName3,caseObj.pr_Middle_Name_3__c);
                                  }else{
                                      mapJSONIGAData.put(MName3,caseObj.pr_Middle_Name_3__c);
                                  }
                              }else{
                                   mapJSONIGAData.put(MName3,'');
                              }
                              
                              if(caseObj.pr_Middle_Name_4__c != caseOldObj.pr_Middle_Name_4__c && caseObj.pr_Middle_Name_4__c != null){
                                  if(mapJSONIGAData.containsKey(MName4)){
                                      mapJSONIGAData.put(MName4,caseObj.pr_Middle_Name_4__c);
                                  }else{
                                      mapJSONIGAData.put(MName4,caseObj.pr_Middle_Name_4__c);
                                  }
                              }else{
                                   mapJSONIGAData.put(MName4,'');
                              }
                              
                              if(mapJSONIGAData.containsKey(LName)){
                                  mapJSONIGAData.put(LName,caseObj.pr_Last_Name__c);
                              }else{
                                  mapJSONIGAData.put(LName,caseObj.pr_Last_Name__c);
                              }
                              
                              if(mapJSONIGAData.containsKey(Gender)){
                                  mapJSONIGAData.put(Gender,caseObj.pcGender__c);
                              }else{
                                  mapJSONIGAData.put(Gender,caseObj.pcGender__c);
                              }
                           
                              if(mapJSONIGAData.containsKey(DOB)){
                                  String dateStr = caseObj.pcDate_of_Birth__c.format();
								  mapJSONIGAData.put(DOB,dateStr);
                              }else{
                                  String dateStr = caseObj.pcDate_of_Birth__c.format();
								  mapJSONIGAData.put(DOB,dateStr);
                              }
                              Map<String,Object> jsonString= mapJSONResponse;
                       		  System.debug('eKYC Response passport and Other docs Required = true:'+JSON.serializePretty(jsonString));
                              caseObj.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                              caseObj.pr_OtherDocumentsRequired__c = false;
                              eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                              eKYCListToUpdate.add(eKYCiGA);
                       } //End if related to Other Documents details
                       
                       if(caseObj.cc_Residence_Permit_No__c != caseOldObj.cc_Residence_Permit_No__c && caseObj.cc_Residence_Permit_No__c != null && caseObj.cc_Residence_Permit_No__c != '' &&
                          caseObj.cc_Residence_Permit_Expiry_Date__c != caseOldObj.cc_Residence_Permit_Expiry_Date__c && caseObj.cc_Residence_Permit_Expiry_Date__c != null){
                              Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(caseObj.eKYC_iGA_Response__c);
                              Map<String, Object> mapJSONData = (Map<String, Object>)mapJSONResponse.get('data');
                              Map<String, Object> mapJSONIGAData = (Map<String, Object>)mapJSONData.get('igaData');
                              
                              String resPermit = 'residentPermitNo';
                              String resExpiryDate = 'residentPermitExpiry';
                              eKYC_iGA_Response__c eKYCiGA = new eKYC_iGA_Response__c(Account__c = caseObj.AccountId,Case__c = caseObj.Id);
                              System.debug('Changing only Resident required photo related fields when Resident and Other docs Required = true');
                              if(mapJSONIGAData.containsKey(resPermit)){
                                  mapJSONIGAData.put(resPermit,caseObj.cc_Residence_Permit_No__c);
                              }else{
                                  mapJSONIGAData.put(resPermit,caseObj.cc_Residence_Permit_No__c);
                              } 
                              
                              if(mapJSONIGAData.containsKey(resExpiryDate)){
                                  String dateStr = caseObj.cc_Residence_Permit_Expiry_Date__c.format();
                                  System.debug('Salesforce Date 1 when Resident and Other docs Required = true:'+caseObj.cc_Residence_Permit_Expiry_Date__c);
                                  System.debug('Date String 1 when Resident and Other docs Required = true:'+dateStr); //"30/11/1970"
                                  mapJSONIGAData.put(resExpiryDate,dateStr);
                              }else{
                                  String dateStr = caseObj.cc_Residence_Permit_Expiry_Date__c.format();
                                  System.debug('Salesforce Date 2 when Resident and Other docs Required = true:'+caseObj.cc_Residence_Permit_Expiry_Date__c);
                                  System.debug('Date String 2 when Resident and Other docs Required = true:'+dateStr);
                                  mapJSONIGAData.put(resExpiryDate,dateStr);
                              }
                              Map<String,Object> jsonString= mapJSONResponse;
                              System.debug('eKYC Response after Resident details update when Resident and Other docs Required = true:'+JSON.serializePretty(jsonString));
                              caseObj.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                              caseObj.pr_ResidencyPermitPhotoRequired__c = false;
                              eKYCiGA.eKYC_iGA_Response__c = JSON.serializePretty(jsonString);
                              eKYCListToUpdate.add(eKYCiGA);
                          } //End If related to resident Expiry details
                   }
                   
                   
                   /********************************************** END: When Passport Details, Resident Details and Other Documents are filled by the QA team **********************************************************************/

                   /********************************************** Start: When QA Team is Selecting Wathiq Consent Form Available or CPR Form Available to True at Documents Required Tab *****************************************************************/
                   else if(caseObj.pr_ResidencyPermitPhotoRequired__c != true && caseObj.pr_PassportPhotoRequired__c != true && caseObj.pr_OtherDocumentsRequired__c != true && caseObj.pr_WathiqConsentFormRequired__c == true /*&& checkRecursive.runOnceForPeriodicReviewCase()*/){
                       if((caseObj.CPR_Form_Available__c != caseOldObj.CPR_Form_Available__c && caseObj.CPR_Form_Available__c == true) || (caseObj.Wathiq_Consent_Form_Available__c != caseOldObj.Wathiq_Consent_Form_Available__c && caseObj.Wathiq_Consent_Form_Available__c == true)){
                           System.debug('Before Update Executes in Periodic Review');
                           caseObj.pr_WathiqConsentFormRequired__c = false;
                       }
                   }
                  /********************************************** END: When QA Team is Selecting Wathiq Consent Form Available or CPR Form Available to True at Documents Required Tab *****************************************************************/

               } 
            /////////////////////////////////////////// END: QA Team is filling Passport, Resident & Other Documents required fields /////////////////////////////////////////////
            
        } //for loop End
        if(eKYCListToUpdate.size()>0){
            try{
                insert eKYCListToUpdate;
            }catch(Exception e){
                 System.debug('Exception Message in Periodic Handler API:'+e.getMessage());
			}
        }
    }
    public static void handlerAfterCaseUpdate(List<case> lstCase){
        Set<Id> setWathiqDocUploadCaseIds = new Set<Id>();
        Set<Id> checkWathiqFormAccIds = new Set<Id>();
        List<Case> checkWathiqFormListCases = new List<Case>();
        //CH02: Start
        Set<Id> reprocessCheckWathiqFormAccIds = new Set<Id>();
		List<Case> reprocessCheckWathiqFormListCases = new List<Case>();
        Set<Id> accIdsWithoutWathiqConsentANDIDVHash = new Set<Id>();
        List<Case> caseListWithoutWathiqConsentANDIDVHash = new List<Case>();
        //CH02: END
        List<Case> lstCasesHavingAllDocs = new List<Case>();
        Set<Id> setCaseIdsHavingAllDocs = new Set<Id>();
        
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
        
        //List<Case> checkWathiqFormIfWathiqAcceptedFromApp = new List<Case>();
        //Set<Id> checkWathiqFormAccIdsIfWathiqAcceptedFromApp = new Set<Id>();

        System.debug('After Update in Periodic Review Handler');
       
        for(Case caseObj : lstCase){ //for loop start
            Case caseOldObj = (Case)trigger.oldMap.get(caseobj.id);
             System.debug('In After Update Old Status value Value:'+caseOldObj.Status);
             System.debug('In After Update New Status value:'+caseObj.Status);

             System.debug('In After Update Resident Photo Required Value value:'+caseObj.pr_ResidencyPermitPhotoRequired__c);
             System.debug('In After Update Passport Photo Required Value value:'+caseObj.pr_PassportPhotoRequired__c);
            
            //CH02: Start
            //////////////////////////////////////// Start: (Re-Process Wathiq Form) Wathiq Consent Accepted & ID & V & Hash Not Available //////////////////////////////////////////////////////
            if(caseObj.RecordType_DeveloperName__c == 'Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Force_Generate_Wathiq_Consent_Form__c == true && 
               caseOldObj.Backend_Force_Generate_Wathiq_Consent_Fo__c != caseObj.Backend_Force_Generate_Wathiq_Consent_Fo__c && caseObj.Backend_Force_Generate_Wathiq_Consent_Fo__c == false &&
               caseObj.Wathiq_Consent__c == true && caseObj.eKYC_IDandV_Document_Upload_Hash__c == false){
               	    System.debug('Backend Force Generate Wathiq Form field changes from true to false & Wathiq Consent is true and ID & V is not available'); 
               	    reprocessCheckWathiqFormListCases.add(caseObj);
                    reprocessCheckWathiqFormAccIds.add(caseObj.AccountId);
            }
            //////////////////////////////////////// END: (Re-Process Wathiq Form) Wathiq Consent Accepted & ID & V & Hash Not Available //////////////////////////////////////////////////////

            /////////////////////////////////////// Start: (Re-Process Wathiq Form) Wathiq Consent Not Accepted & ID & V & Hash Not Available //////////////////////////////////////////////////
            if(caseObj.RecordType_DeveloperName__c == 'Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Force_Generate_Wathiq_Consent_Form__c == true && 
               caseOldObj.Backend_Force_Generate_Wathiq_Consent_Fo__c != caseObj.Backend_Force_Generate_Wathiq_Consent_Fo__c && caseObj.Backend_Force_Generate_Wathiq_Consent_Fo__c == false &&
               caseObj.Wathiq_Consent__c == false && caseObj.eKYC_IDandV_Document_Upload_Hash__c == false){
               	    System.debug('Backend Force Generate Wathiq Form field changes from true to false and Wathiq Consent, ID & V is not available'); 
               	    caseListWithoutWathiqConsentANDIDVHash.add(caseObj);
                    accIdsWithoutWathiqConsentANDIDVHash.add(caseObj.AccountId);
            }
            /////////////////////////////////////// END: (Re-Process Wathiq Form) Wathiq Consent Not Accepted & ID & V & Hash Not Available //////////////////////////////////////////////////
			//CH02: END
			
            ////////////////////////////////////////// Start: Wathiq Consent Accepted & ID & V & Hash Not Available ////////////////////////////////////////////////////
            if(caseObj.RecordType_DeveloperName__c == 'Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.pr_WathiqConsentFormRequired__c != caseOldObj.pr_WathiqConsentFormRequired__c  && caseObj.pr_WathiqConsentFormRequired__c == false &&
               caseObj.Wathiq_Consent__c == true && caseObj.eKYC_IDandV_Document_Upload_Hash__c == false){
                   System.debug('Wathiq Form Required values changes from true to false');
                   checkWathiqFormListCases.add(caseObj);
                   checkWathiqFormAccIds.add(caseObj.AccountId);
               }
            ////////////////////////////////////////// END: Wathiq Consent Accepted & ID & V & Hash Not Available ////////////////////////////////////////////////////
            
            ////////////////////////////////////////// Start: Wathiq Consent Accepted & ID & V & Hash Available ////////////////////////////////////////////////////
            if(caseObj.RecordType_DeveloperName__c == 'Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Status != caseOldObj.Status && caseObj.Status == 'All Documents Uploaded' &&
               caseObj.Wathiq_Consent__c == true && caseObj.eKYC_IDandV_Document_Upload_Hash__c == true && caseObj.pr_WathiqConsentFormRequired__c  == false &&
               caseObj.pr_ResidencyPermitPhotoRequired__c == false && caseObj.pr_PassportPhotoRequired__c == false &&
               caseObj.pr_OtherDocumentsRequired__c  == false && caseObj.Wathiq_Consent_Form_Available__c == false && caseObj.CPR_Form_Available__c == false){
                   System.debug('Status Changes to All document Uploaded and customer is having all the documents');
                   lstCasesHavingAllDocs.add(caseObj);
                   setCaseIdsHavingAllDocs.add(caseObj.Id);
                   
               }
            ////////////////////////////////////////// END: Wathiq Consent Accepted & ID & V & Hash Available ////////////////////////////////////////////////////
            
            ////////////////////////////////////////// Start: Wathiq Consent Accepted from Mobile App and ID & V & Hash Not Available ////////////////////////////////////////////////////
            
            if(caseObj.RecordType_DeveloperName__c == 'Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.pr_WathiqConsentAcceptanceRequired__c == false &&
              caseOldObj.pr_WathiqConsentAcceptanceRequired__c != caseObj.pr_WathiqConsentAcceptanceRequired__c){
                System.debug('Wathiq Accepted on Account from Mobile App');
                   checkWathiqFormListCases.add(caseObj);
                   checkWathiqFormAccIds.add(caseObj.AccountId);
            }
            
            
            ////////////////////////////////////////// END: Wathiq Consent Accepted from Mobile App and ID & V & Hash Not Available ////////////////////////////////////////////////////

            ///////////////////////////////////////// Start: Wathiq Consent Accepted & ID & V & Hash Available with Wathiq Form or CPR Form required = true without contacting Customer //////////////////////////////
            if(caseObj.RecordType_DeveloperName__c == 'Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Status != caseOldObj.Status && caseObj.Status == 'All Documents Uploaded' &&
               caseObj.Wathiq_Consent__c == true && caseObj.eKYC_IDandV_Document_Upload_Hash__c == true && caseObj.pr_WathiqConsentFormRequired__c == false &&
               caseObj.pr_ResidencyPermitPhotoRequired__c == false && caseObj.pr_PassportPhotoRequired__c == false &&
               caseObj.pr_OtherDocumentsRequired__c == false && (caseObj.Wathiq_Consent_Form_Available__c == true || caseObj.CPR_Form_Available__c == true) && caseObj.eKYC_iGA_Response__c == null){
                   setCaseIdsWithWathiqAcceptedANDIDVHashAccepted.add(caseObj.Id);
                   System.debug('Wathiq Consent Accepted & ID & V & Hash Available with Wathiq Form or CPR Form = true');
               }
            ///////////////////////////////////////// END: Wathiq Consent Accepted & ID & V & Hash Available with Wathiq Form or CPR Form = true without contacting Customer //////////////////////////////
			
           ///////////////////////////////////////// Start: Wathiq Accepted & ID & V & Hash Available with Wathiq Form or CPR Form = true and eKYC iGA Response Available ///////////////////////////////////////////////
           if(caseObj.RecordType_DeveloperName__c == 'Customer_Periodic_Review' && caseObj.Type == 'Periodic Review' && caseObj.Status != caseOldObj.Status && caseObj.Status == 'All Documents Uploaded' &&
               caseObj.Wathiq_Consent__c == true && caseObj.eKYC_IDandV_Document_Upload_Hash__c == true && caseObj.pr_WathiqConsentFormRequired__c == false &&
               caseObj.pr_ResidencyPermitPhotoRequired__c == false && caseObj.pr_PassportPhotoRequired__c == false &&
               caseObj.pr_OtherDocumentsRequired__c == false && (caseObj.Wathiq_Consent_Form_Available__c == true || caseObj.CPR_Form_Available__c == true) && caseObj.eKYC_iGA_Response__c != null){
                   setCaseIdsHavingAllDocs.add(caseObj.Id);
                   System.debug('Wathiq Consent Accepted & ID & V & Hash Available with Wathiq Form or CPR Form = true and iGA Response is not blank');
           }
          ///////////////////////////////////////// END: Wathiq Accepted & ID & V & Hash Available with Wathiq Form or CPR Form = true and eKYC iGA Response Available ///////////////////////////////////////////////

        
        } //for loop End
                    
         //CH02: Start
        //////////////////////////////////////// Start: (Re-Process Wathiq Form) Wathiq Consent Accepted & ID & V & Hash Not Available //////////////////////////////////////////////////////
		if(!reprocessCheckWathiqFormAccIds.isEmpty() && !reprocessCheckWathiqFormListCases.isEmpty()){
            ReprocessWathiqForm.checkWathiqFormOrCPRFormAvailable(reprocessCheckWathiqFormListCases,reprocessCheckWathiqFormAccIds);
        }
        //////////////////////////////////////// END: (Re-Process Wathiq Form) Wathiq Consent Accepted & ID & V & Hash Not Available //////////////////////////////////////////////////////
        if(!accIdsWithoutWathiqConsentANDIDVHash.isEmpty() && !caseListWithoutWathiqConsentANDIDVHash.isEmpty()){
            ReprocessWathiqForm.casesWithoutWathiqConsentAndIDVHash(caseListWithoutWathiqConsentANDIDVHash,accIdsWithoutWathiqConsentANDIDVHash);
        }
        //CH02: END
        
         ///////////////////////////////////////// Start: Wathiq Consent Accepted & ID & V & Hash Available with Wathiq Form or CPR Form = true //////////////////////////////
         //Commented due to UATNB-55477 defect
		if(setCaseIdsWithWathiqAcceptedANDIDVHashAccepted.size()>0){
            System.debug('Set Case Id:'+setCaseIdsWithWathiqAcceptedANDIDVHashAccepted);
            //PeriodicReviewHandlerAPI.fetcheKYCiGAData(setCaseIdsWithWathiqAcceptedANDIDVHashAccepted);
            FetcheKYCIGADataQueuableAPI fetchiGAData = new FetcheKYCIGADataQueuableAPI(setCaseIdsWithWathiqAcceptedANDIDVHashAccepted);
	        System.enqueueJob(fetchiGAData);
        }
        
         ///////////////////////////////////////// END: Wathiq Consent Accepted & ID & V & Hash Available with Wathiq Form or CPR Form = true //////////////////////////////

        
        
        ////////////////////////////////////////// Start: Wathiq Consent Accepted & ID & V & Hash Not Available ////////////////////////////////////////////////////
        if(!checkWathiqFormAccIds.isEmpty()){
            Map<Id,List<Content__c>> mapAccountRelatedListFacePhoto = new Map<Id,List<Content__c>>();
            Map<Id,List<Content__c>> mapAccToContent = new Map<Id,List<Content__c>>();
            //CH03: Start
            Map<Id,List<Content__c>> mapAccountRelatedListOfPassportFacePhoto = new Map<Id,List<Content__c>>();
            Map<Id,String> mapAccountRelatedListOfPassportFrontPhoto = new Map<Id,String>();
            //CH03: END
            //CH03: Start Added Passport condition & Document_Country__c in SOQL
            List<Content__c> lstContent = [SELECT Name,Document_Type__c,Document_Expiry_Date__c,Document_Country__c, Person__c,Scan_Type__c,Validity__c,Verification_Status__c,Image_Type__c,Similarity__c FROM Content__c where 
                                           Person__c =: checkWathiqFormAccIds AND Document_Type__c IN('Wathiq Consent Form','Bahraini ID','Passport') order by CreatedDate ASC];
            //CH03: END
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
                                    //mapAccountRelatedFacePhoto.put(ct.Person__c,ct.Image_Type__c);
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
                                //CH03: Start
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
                                //CH03: END
                            }//Inner for loop End
                            caseLstWithWathiqOrCPRForm.add(c);
                        } //If END
                        else{ //This Block Executes when no documents are available on Customers
                            System.debug('After update No Documents found');
                            Case cs = new Case(Id = c.Id,AccountId = c.AccountId);
                            cs.pr_WathiqConsentFormRequired__c = true;
                            cs.Status = 'Pending Documents';
                            //cs.Sub_Status__c = 'Overdue Stage 1';
                            cs.Wathiq_Consent_Form_Available__c = false;
                            cs.CPR_Form_Available__c = false;
                            //CH1:Start
                            //cs.pr_Overdue_Stage_Date__c =System.now();
                            //CH1:End
                            accIdsWithoutWathiqFormWithoutCPR.add(cs.AccountId);
                            wathiqOrCPRFormAvailableList.add(cs);
                        }
                    } //If END
                    else{
                        System.debug('After update Need to Check Else condition for No Documents');
                        Case cs = new Case(Id = c.Id,AccountId = c.AccountId);
                        cs.pr_WathiqConsentFormRequired__c = true;
                        cs.Status = 'Pending Documents';
                        //cs.Sub_Status__c = 'Overdue Stage 1';
                        cs.Wathiq_Consent_Form_Available__c = false; 
                        cs.CPR_Form_Available__c = false;
                        //CH1:Start
                        //cs.pr_Overdue_Stage_Date__c =System.now();
                        //CH1:End
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
                
                //CH03: Start
                Map<Id,String> mapAccountRelatedPassportFacePhotoWithOneRecord = new Map<Id,String>();
                Map<Id,String> mapAccountRelatedPassportFacePhotoWithTwoRecord = new Map<Id,String>();
                Map<Id,String> mapAccountRelatedPassportFacePhotoWithThreeOrMoreRecord = new Map<Id,String>();
                //CH03: END
                
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
                    //CH03: Start
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
                    //CH03: END
                } //for loop Ends
                System.debug('Having 3 or more Face Record during Case update:'+mapAccountRelatedFacePhotoWithThreeOrMoreRecordId);
  				System.debug('Having 2 Face Record during Case update:'+mapAccountRelatedFacePhotoWithTwoRecordId);
  				System.debug('Having 1 Face Record during Case update:'+mapAccountRelatedFacePhotoWithOneRecordId);
               
                //This for loop is used to check the map values of Respective Content Documents with one face record or two face records or more than two face records with Person AccountId
				for(Case c : caseLstWithWathiqOrCPRForm){
                    Case cs = new Case(Id = c.Id,AccountId = c.AccountId);
                    if(mapAccountRelatedWathiqForm.containsKey(cs.AccountId)){
                        //cs.Wathiq_Consent_Form_Available__c = true;
                        wathiqOrCPRFormAvailableList.add(cs);
                        setCaseIdContainsWathiqFormOrCPRForm.add(cs.Id);
                        System.debug('After update Wathiq Form Available on Customer Documents & Need to call API');
                        //break;
                    }
                    //CH03: Start Added a Condition related to passport
                    else if((mapAccountRelatedFrontPhoto.containsKey(cs.AccountId) && mapAccountRelatedBackPhoto.containsKey(cs.AccountId)) || (mapAccountRelatedListOfPassportFrontPhoto.containsKey(cs.AccountId))){
                        if(mapAccountRelatedFacePhotoWithThreeOrMoreRecord.containsKey(cs.AccountId) || mapAccountRelatedFacePhotoWithTwoRecord.containsKey(cs.AccountId) || mapAccountRelatedFacePhotoWithOneRecord.containsKey(cs.AccountId)){
                            //cs.CPR_Form_Available__c = true;
                            wathiqOrCPRFormAvailableList.add(cs);
                            setCaseIdContainsWathiqFormOrCPRForm.add(cs.Id);
                            System.debug('After Upadte CPR Form Available on Customer Documents & Need to call API');
                        }
                        //CH03: Start
                        else if(mapAccountRelatedPassportFacePhotoWithThreeOrMoreRecord.containsKey(cs.AccountId) || mapAccountRelatedPassportFacePhotoWithTwoRecord.containsKey(cs.AccountId) || mapAccountRelatedPassportFacePhotoWithOneRecord.containsKey(cs.AccountId)){
                           	cs.CPR_Form_Available__c = true;
                            wathiqOrCPRFormAvailableList.add(cs);
                            setCaseIdContainsWathiqFormOrCPRForm.add(cs.Id);
                            System.debug('Passport Available on Customer Documents & Need to call API'); 
                        }
                        //CH03: END
                        else{
                            System.debug('No Bahraini Face & Passport Face Photo Available');
                            cs.pr_WathiqConsentFormRequired__c = true;
                        	cs.Status = 'Pending Documents';
                        	//cs.Sub_Status__c = 'Overdue Stage 1';
                            cs.CPR_Form_Available__c = false;
                            cs.Wathiq_Consent_Form_Available__c = false;
                            //CH1:Start
                        	//cs.pr_Overdue_Stage_Date__c =System.now();
                        	//CH1:End
                        	accIdsWithoutWathiqFormWithoutCPR.add(cs.AccountId);
                        	wathiqOrCPRFormAvailableList.add(cs);
                        }
                    }
                    else{
                        System.debug('After Upadte No Wathiq Form and CPR Form Available');
                        cs.pr_WathiqConsentFormRequired__c = true;
                        cs.Status = 'Pending Documents';
                        //cs.Sub_Status__c = 'Overdue Stage 1';
                        cs.Wathiq_Consent_Form_Available__c = false;
						cs.CPR_Form_Available__c = false;
                        //CH1:Start
                        //cs.pr_Overdue_Stage_Date__c =System.now();
                        //CH1:End
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
                    //CH02: Start
                	if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     	a.pr_ReviewStatus__c = 'Overdue Stage 1';
					}
                	else
                		a.pr_ReviewStatus__c = 'Overdue';
                	//CH02: END
                    accListWithoutWathiqFormWithoutCPR.add(a);
                }
             }
        }
        
        if(setCaseIdContainsWathiqFormOrCPRForm.size()>0){
            System.debug('Wathiq Form Available or CPR Form Available');
            //Need to Call API Class Here
           // PeriodicReviewHandlerAPI.fetcheKYCDocumentHashValue(setCaseIdContainsWathiqFormOrCPRForm);
            FetcheKYCDocumentHashQueuableAPI fetchDocumentHash = new FetcheKYCDocumentHashQueuableAPI(setCaseIdContainsWathiqFormOrCPRForm);
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
        ////////////////////////////////////////// END: Wathiq Consent Accepted & ID & V & Hash Not Available ////////////////////////////////////////////////////
        
        ////////////////////////////////////////// Start: Wathiq Consent Accepted & ID & V & Hash Available ////////////////////////////////////////////////////
        List<Case> caseListToUpdate = new List<Case>();
        List<Account> accListToUpdate = new List<Account>();
        Set<Id> setCaseIdsHavingWathiqOrCPRWithEmptyeKYCiGAResponse = new Set<Id>();
        if(setCaseIdsHavingAllDocs.size() > 0){
            List<Case> caseList = [Select Id,AccountId,Customer_CIF__c,cc_ID_Number__c,IDandV_Document_Upload_Hash__c,Region_Flag__c,
                                   Account.iGA_Passport_Number__pc,Account.PersonEmail,Account.CIF__pc,pr_ResidencyPermitPhotoRequired__c, 
                                   Account.Due_Diligence_Category__pc,pr_Overdue_Stage_Date__c,eKYC_iGA_Response__c,Account.ID_Nationality__pc from Case where Id IN : setCaseIdsHavingAllDocs];
            if(caseList.size() > 0){
                for(Case c : caseList){ //for loop start
                    //Account a = new Account(Id = cse.AccountId);
                    //Case c = new Case(Id = cse.Id,AccountId = cse.AccountId,eKYC_iGA_Response__c = cse.eKYC_iGA_Response__c);
                    
                    if(String.isNotBlank(c.eKYC_iGA_Response__c)){
                        Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(c.eKYC_iGA_Response__c);// meta, data
                        Map<String, Object> mapJSONData = (Map<String, Object>)mapJSONResponse.get('data');
                        Map<String, Object> mapJSONIGAData = (Map<String, Object>)mapJSONData.get('igaData');
                        Map<String, Object> mapJSONemploymentInfo = (Map<String, Object>)mapJSONIGAData.get('employmentInfo');
                        Map<String, Object> mapJSONcustomerAddress = (Map<String, Object>)mapJSONIGAData.get('customerAddress');
                        Map<String, object> mapJSONemployerAddress = (Map<String, Object>)mapJSONemploymentInfo.get('employerAddress');
                        
                        System.debug('JSON Response in After Update Trigger:'+mapJSONResponse);
                        String nationality = (string)mapJSONIGAData.get('nationality');
                        String passportNumber = (string)mapJSONIGAData.get('passportNumber');
                        String passportExpiryDate =  (string)mapJSONIGAData.get('passportExpiryDate');
                        String residentNumber = (string)mapJSONIGAData.get('residentPermitNo');
                        System.debug('Resident Number from case iGA Field:'+residentNumber);
                        String residentExpiryDate = (string)mapJSONIGAData.get('residentPermitExpiry');
                        System.debug('Resident Expiry Date from case iGA Field:'+residentExpiryDate);
                        System.debug('Passport Expiry Date from case iGA Field:'+passportExpiryDate);
                        String cardCountry = (string)mapJSONIGAData.get('cardCountry');
                        String gender = (string)mapJSONIGAData.get('gender');
                        
                        String dataOfBirth = (string)mapJSONIGAData.get('dateOfBirth');
                        
                        Date passportDateExpiry;
                        Date residentDateExpiry;
                       
                        Date dob;
                       
                        if(String.isNotBlank(passportExpiryDate)){
                            passportDateExpiry = Date.parse(passportExpiryDate);
                        }
                        if(String.isNotBlank(residentExpiryDate)){
                            residentDateExpiry = Date.parse(residentExpiryDate);
                        }
                        
                        if(String.isNotBlank(dataOfBirth)){
                            dob = Date.parse(dataOfBirth);
                        }
                        
                        System.debug('Resident Expiry Date After Conversion:'+residentDateExpiry);
                        
                        Integer trackFullName = 0;
                        String fullName = (string)mapJSONIGAData.get('enFirstName');
                        String middleName1 = (string)mapJSONIGAData.get('enMiddleName1');
                        String middleName2 = (string)mapJSONIGAData.get('enMiddleName2');
                        String middleName3 = (string)mapJSONIGAData.get('enMiddleName3');
                        String middleName4 = (string)mapJSONIGAData.get('enMiddleName4');
                        String lastName = (string)mapJSONIGAData.get('enLastName');
                        
                        if(fullName != '' && fullName !=null)
                            trackFullName++;
                        if(middleName1 != '' && middleName1 !=null)
                            trackFullName++;
                        if(middleName2 != '' && middleName2 !=null)
                            trackFullName++;
                        if(middleName3 != '' && middleName3 !=null)
                            trackFullName++;
                        if(middleName4 != '' && middleName4 !=null)
                            trackFullName++;
                        if(lastName != '' && lastName !=null)
                            trackFullName++;
                        System.debug('Tracking Full Name Count:'+trackFullName);
                        String cardCountryISO = '';
                        //CH04: Start
                        List<String> rpExclusionList = System.Label.RP_EXCLUSION_LIST.split(',');
                        if(rpExclusionList.contains(nationality) && nationality != '' && nationality != null){
                            Account a = new Account(Id = c.AccountId);
                            System.debug('BAHRAINI CUSTOMER No need to Check Gender, DOB and Name case iGA Field');
                           //CH04: Start
                            if(String.isNotBlank((string)mapJSONIGAData.get('cardCountry2Digits'))){
								cardCountryISO = (string)mapJSONIGAData.get('cardCountry2Digits');
								if(c.Account.ID_Nationality__pc != cardCountryISO){
									a.ID_Nationality__pc = cardCountryISO;
								}
							}
                            
                            //if(String.isNotBlank((string)mapJSONIGAData.get('cardCountry')))
                                //a.ID_Nationality__pc = (string)mapJSONIGAData.get('cardCountry');
                            //CH04: END
                            String arabFName = '';
                            String arabMName1 = '';
                            String arabMName2 = '';
                            String arabMName3 = '';
                            String arabMName4 = '';
                            String arabLName = '';
                                 
                            if(String.isNotBlank((string)mapJSONIGAData.get('arFirstName'))){
                                arabFName =  (string)mapJSONIGAData.get('arFirstName');
                            }
                            if(String.isNotBlank((string)mapJSONIGAData.get('arMiddleName1'))){
                                arabMName1 =  (string)mapJSONIGAData.get('arMiddleName1');
                            }
                            if(String.isNotBlank((string)mapJSONIGAData.get('arMiddleName2'))){
                                arabMName2 =  (string)mapJSONIGAData.get('arMiddleName2');
                            }
                            if(String.isNotBlank((string)mapJSONIGAData.get('arMiddleName3'))){
                                arabMName3 =  (string)mapJSONIGAData.get('arMiddleName3');
                            }
                            if(String.isNotBlank((string)mapJSONIGAData.get('arMiddleName4'))){
                                arabMName4 =  (string)mapJSONIGAData.get('arMiddleName4');
                            }
                            if(String.isNotBlank((string)mapJSONIGAData.get('arLastName'))){
                                arabLName =  (string)mapJSONIGAData.get('arLastName');
                            } 
                                
                            a.Arabic_Name__pc = arabFName + ' '+arabMName1 + ' '+arabMName2 + ' '+arabMName3 + ' '+arabMName4 + ' '+arabLName;
							 
                            //if(String.isNotBlank((string)mapJSONIGAData.get('arFirstName')) || String.isNotBlank((string)mapJSONIGAData.get('arMiddleName1')) || String.isNotBlank((string)mapJSONIGAData.get('arMiddleName2')) || String.isNotBlank((string)mapJSONIGAData.get('arMiddleName3')) || String.isNotBlank((string)mapJSONIGAData.get('arMiddleName4')) || String.isNotBlank((string)mapJSONIGAData.get('arLastName')) )
								//a.Arabic_Name__pc = (string)mapJSONIGAData.get('arFirstName') +' ' +(string)mapJSONIGAData.get('arMiddleName1') + ' ' +(string)mapJSONIGAData.get('arMiddleName2') + ' ' +(string)mapJSONIGAData.get('arMiddleName3') + ' ' +(string)mapJSONIGAData.get('arMiddleName4')  + ' ' +(string)mapJSONIGAData.get('arLastName');
							//CH05: Start
                            //Account_Info_cannot_be_edited_directly Validation is restricting to update Account name
                            /*if(String.isNotBlank((string)mapJSONIGAData.get('enFirstName')))
                            	a.FirstName = (string)mapJSONIGAData.get('enFirstName');
							
                            String midName1 = '';
                            String midName2 = '';
                            String midName3 = '';
                            String midName4 = '';
                                 
                            if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName1'))){
                                midName1 = (string)mapJSONIGAData.get('enMiddleName1');
                            }
                            if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName2'))){
                                midName2 = (string)mapJSONIGAData.get('enMiddleName2');
                            }
                            if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName3'))){
                                midName3 = (string)mapJSONIGAData.get('enMiddleName3');
                            }
                            if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName4'))){
                                midName4 = (string)mapJSONIGAData.get('enMiddleName4');
                            }
                            a.MiddleName = midName1 + ' ' +midName2 + ' '+midName3 + ' '+midName4;*/
                            //CH05: END
                            //if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName1')) || String.isNotBlank((string)mapJSONIGAData.get('enMiddleName2')) || String.isNotBlank((string)mapJSONIGAData.get('enMiddleName3')) || String.isNotBlank((string)mapJSONIGAData.get('enMiddleName4')))
								//a.MiddleName = (string)mapJSONIGAData.get('enMiddleName1') +' ' +(string)mapJSONIGAData.get('enMiddleName2') +' ' +(string)mapJSONIGAData.get('enMiddleName3') + ' '+(string)mapJSONIGAData.get('enMiddleName4');
							//CH05: Start
                            /*if(String.isNotBlank((string)mapJSONIGAData.get('enLastName')))
                            	a.LastName = (string)mapJSONIGAData.get('enLastName');*/
                            //CH05: END
                            if(String.isNotBlank((string)mapJSONIGAData.get('gender')))
                            	a.Gender__pc = (string)mapJSONIGAData.get('gender');
                            //CH05: Start
                            //a.PersonBirthdate = dob;
                            //CH05: END
                            //CH06: Start
                            Integer nationalityLength;
                            if(String.isNotBlank((string)mapJSONIGAData.get('nationality'))){
                                nationalityLength = ((string)mapJSONIGAData.get('nationality')).length();
                                System.debug('Nationality Length in Update case record 1:'+nationalityLength);
                            	if(nationalityLength == 2){
                                    a.Nationality__pc = (string)mapJSONIGAData.get('nationality');
                                }
                            	else if(nationalityLength == 3){
                                	a.Nationality__pc = (string)mapJSONIGAData.get('customerNationalityTwoChars');
                            	}
                            }
                            //CH06: END
                            //if(String.isNotBlank((string)mapJSONIGAData.get('customerNationalityTwoChars')))
                                //a.Nationality__pc = (string)mapJSONIGAData.get('customerNationalityTwoChars');
                            
                            if(String.isNotBlank((string)mapJSONemploymentInfo.get('employerName')))
                            	a.Employer_Name__pc = (string)mapJSONemploymentInfo.get('employerName');
                            if(String.isNotBlank((string)mapJSONemployerAddress.get('flatNumber')) || String.isNotBlank((string)mapJSONemployerAddress.get('buildingNumber')) || String.isNotBlank((string)mapJSONemployerAddress.get('buildingAlpha')) || String.isNotBlank((string)mapJSONemployerAddress.get('roadNumber')) || String.isNotBlank((string)mapJSONemployerAddress.get('blockNumber')))
                            	a.Employer_Address__pc = 'Flat ' + (string)mapJSONemployerAddress.get('flatNumber') + ', Bldng '+(string)mapJSONemployerAddress.get('buildingNumber') +' '+(string)mapJSONemployerAddress.get('buildingAlpha') +', Rd no '+(string)mapJSONemployerAddress.get('roadNumber') + ''+(string)mapJSONemployerAddress.get('blockNumber');
                            
                            if(String.isNotBlank((string)mapJSONIGAData.get('maritalStatus')))
                            	a.Marital_Status__pc = (string)mapJSONIGAData.get('maritalStatus');
                            if(String.isNotBlank((string)mapJSONIGAData.get('passportNumber')))
                            	a.Passport_Number__pc = (string)mapJSONIGAData.get('passportNumber');
                            if(String.isNotBlank((string)mapJSONIGAData.get('passportExpiryDate')))
                            	a.Passport_Expiry_Date__pc = passportDateExpiry;
                            if(String.isNotBlank((string)mapJSONIGAData.get('residentPermitNo')))
                            	a.Residency_Permit_Number__pc = (string)mapJSONIGAData.get('residentPermitNo');
                            if(String.isNotBlank((string)mapJSONIGAData.get('residentPermitExpiry')))
                            	a.Residency_Permit_Expiry__pc = residentDateExpiry;
                            
                            if(c.Account.Due_Diligence_Category__pc == 'Standard Due Diligence'){
                                a.pr_NextReviewDate__c = System.today() + 1095;
                            }
                            else if(c.Account.Due_Diligence_Category__pc == 'Enhanced Due Diligence'){
                                a.pr_NextReviewDate__c = System.today() + 365;
                            }
                            a.Bypass_Validations__pc = true;
                            a.pr_ReviewStatus__c = 'Completed';
                            System.debug('Account acc:'+a);
                            accListToUpdate.add(a);
                            //objCase.eKYC_iGA_Response__c = response.getBody();
                            c.Sub_Status__c = 'Completed';
                            c.Status = 'Closed';
                            caseListToUpdate.add(c);
                        }
                        //CH04: END
                        //CH04: Start
                        else if(!rpExclusionList.contains(nationality) && nationality != '' && nationality != null){
                            System.debug('NON BAHRAINI CUSTOMER CHECK PASSPORT & RESIDENT EXPIRY');
                            Account a = new Account(Id = c.AccountId);
                            //Account a = new Account();
                            //a.Id = c.AccountId;
                            if(passportDateExpiry != null && passportNumber != '' && passportNumber != null && residentDateExpiry != null && residentNumber != '' && residentNumber != null && trackFullName > 1){
                                
                                //////////////////////////////// Fetching the Latest Wathiq data from case iGA Field //////////////////////////////
                                if(passportDateExpiry > System.today().addDays(45) && residentDateExpiry > System.today().addDays(45) && gender != '' &&  gender != null  && dataOfBirth != '' && dataOfBirth != null){
                                    System.debug('Passport & Resident Permit Not Expire case iGA Field');
                                    
                                    //Mapping of IGA Fields on eKYC Section & Main Field
                                    //CH04: Start
                                    //if(String.isNotBlank((string)mapJSONIGAData.get('cardCountry')))
                                    	//a.ID_Nationality__pc = (string)mapJSONIGAData.get('cardCountry');
                                    if(String.isNotBlank((string)mapJSONIGAData.get('cardCountry2Digits'))){
										cardCountryISO = (string)mapJSONIGAData.get('cardCountry2Digits');
										if(c.Account.ID_Nationality__pc != cardCountryISO){
											a.ID_Nationality__pc = cardCountryISO;
										}
                                    }
                                    //CH04: END
                                    String arabFName = '';
                               	    String arabMName1 = '';
                                	String arabMName2 = '';
                                	String arabMName3 = '';
                                	String arabMName4 = '';
                                	String arabLName = '';
                                 
                                	if(String.isNotBlank((string)mapJSONIGAData.get('arFirstName'))){
                                    	arabFName =  (string)mapJSONIGAData.get('arFirstName');
                                	}
                                	if(String.isNotBlank((string)mapJSONIGAData.get('arMiddleName1'))){
                                    	arabMName1 =  (string)mapJSONIGAData.get('arMiddleName1');
                                	}
                                	if(String.isNotBlank((string)mapJSONIGAData.get('arMiddleName2'))){
                                    	arabMName2 =  (string)mapJSONIGAData.get('arMiddleName2');
                                	}
                                	if(String.isNotBlank((string)mapJSONIGAData.get('arMiddleName3'))){
                                    	arabMName3 =  (string)mapJSONIGAData.get('arMiddleName3');
                                	}
                                	if(String.isNotBlank((string)mapJSONIGAData.get('arMiddleName4'))){
                                    	arabMName4 =  (string)mapJSONIGAData.get('arMiddleName4');
                                	}
                                	if(String.isNotBlank((string)mapJSONIGAData.get('arLastName'))){
                                    	arabLName =  (string)mapJSONIGAData.get('arLastName');
                                	} 
                                
                                	a.Arabic_Name__pc = arabFName + ' '+arabMName1 + ' '+arabMName2 + ' '+arabMName3 + ' '+arabMName4 + ' '+arabLName;
                                    
                                    //if(String.isNotBlank((string)mapJSONIGAData.get('arFirstName')) || String.isNotBlank((string)mapJSONIGAData.get('arMiddleName1')) || String.isNotBlank((string)mapJSONIGAData.get('arMiddleName2')) || String.isNotBlank((string)mapJSONIGAData.get('arMiddleName3')) || String.isNotBlank((string)mapJSONIGAData.get('arMiddleName4')) || String.isNotBlank((string)mapJSONIGAData.get('arLastName')) )
                                    	//a.Arabic_Name__pc = (string)mapJSONIGAData.get('arFirstName') +' ' +(string)mapJSONIGAData.get('arMiddleName1') + ' ' +(string)mapJSONIGAData.get('arMiddleName2') + ' ' +(string)mapJSONIGAData.get('arMiddleName3') + ' ' +(string)mapJSONIGAData.get('arMiddleName4')  + ' ' +(string)mapJSONIGAData.get('arLastName');

                                    //CH05: Start
                                    //Account_Info_cannot_be_edited_directly Validation is restricting to update Account name
                                    /*if(String.isNotBlank((string)mapJSONIGAData.get('enFirstName')))
                                    	a.FirstName = (string)mapJSONIGAData.get('enFirstName');
									
                                    String midName1 = '';
                                	String midName2 = '';
                                	String midName3 = '';
                                	String midName4 = '';
                                 
                                 	if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName1'))){
                                     	midName1 = (string)mapJSONIGAData.get('enMiddleName1');
                                 	}
                                 	if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName2'))){
                                     	midName2 = (string)mapJSONIGAData.get('enMiddleName2');
                                 	}
                                 	if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName3'))){
                                     	midName3 = (string)mapJSONIGAData.get('enMiddleName3');
                                 	}
                                 	if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName4'))){
                                     	midName4 = (string)mapJSONIGAData.get('enMiddleName4');
                                 	}
                                	a.MiddleName = midName1 + ' ' +midName2 + ' '+midName3 + ' '+midName4;*/
                                    //CH05: END
                                    //if(String.isNotBlank((string)mapJSONIGAData.get('enMiddleName1')) || String.isNotBlank((string)mapJSONIGAData.get('enMiddleName2')) || String.isNotBlank((string)mapJSONIGAData.get('enMiddleName3')) || String.isNotBlank((string)mapJSONIGAData.get('enMiddleName4')))
										//a.MiddleName = (string)mapJSONIGAData.get('enMiddleName1') +' ' +(string)mapJSONIGAData.get('enMiddleName2') +' ' +(string)mapJSONIGAData.get('enMiddleName3') + ' '+(string)mapJSONIGAData.get('enMiddleName4');
									//CH05: Start
                                    /*if(String.isNotBlank((string)mapJSONIGAData.get('enLastName')))
                                    	a.LastName = (string)mapJSONIGAData.get('enLastName');*/
                                    //CH05: END
                                    if(String.isNotBlank((string)mapJSONIGAData.get('gender')))
                                    	a.Gender__pc = (string)mapJSONIGAData.get('gender');
                                    //CH05: Start
                                    //a.PersonBirthdate = dob;
                                    //CH05: END
                                    
                                    //CH06: Start
                            		Integer nationalityLength;
                            		if(String.isNotBlank((string)mapJSONIGAData.get('nationality'))){
                                		nationalityLength = ((string)mapJSONIGAData.get('nationality')).length();
                                		System.debug('Nationality Length in Update case record 2:'+nationalityLength);
                            			if(nationalityLength == 2){
                                    		a.Nationality__pc = (string)mapJSONIGAData.get('nationality');
                                		}
                            			else if(nationalityLength == 3){
                                			a.Nationality__pc = (string)mapJSONIGAData.get('customerNationalityTwoChars');
                            			}
                            		}
                            	 	//CH06: END
                                    
                                    //if(String.isNotBlank((string)mapJSONIGAData.get('customerNationalityTwoChars')))
                                 		//a.Nationality__pc = (string)mapJSONIGAData.get('customerNationalityTwoChars'); 	
                                    
                                    if(String.isNotBlank((string)mapJSONemploymentInfo.get('employerName')))
                                    	a.Employer_Name__pc = (string)mapJSONemploymentInfo.get('employerName');
                                    if(String.isNotBlank((string)mapJSONemployerAddress.get('flatNumber')) || String.isNotBlank((string)mapJSONemployerAddress.get('buildingNumber')) || String.isNotBlank((string)mapJSONemployerAddress.get('buildingAlpha')) || String.isNotBlank((string)mapJSONemployerAddress.get('roadNumber')) || String.isNotBlank((string)mapJSONemployerAddress.get('blockNumber')))
										a.Employer_Address__pc = 'Flat ' + (string)mapJSONemployerAddress.get('flatNumber') + ', Bldng '+(string)mapJSONemployerAddress.get('buildingNumber') +' '+(string)mapJSONemployerAddress.get('buildingAlpha') +', Rd no '+(string)mapJSONemployerAddress.get('roadNumber') + ''+(string)mapJSONemployerAddress.get('blockNumber');
									if(String.isNotBlank((string)mapJSONIGAData.get('maritalStatus')))
                                    	a.Marital_Status__pc = (string)mapJSONIGAData.get('maritalStatus');
                                    if(String.isNotBlank((string)mapJSONIGAData.get('passportNumber')))
                                    	a.Passport_Number__pc = (string)mapJSONIGAData.get('passportNumber');
                                    if(String.isNotBlank((string)mapJSONIGAData.get('passportExpiryDate')))
                                    	a.Passport_Expiry_Date__pc = passportDateExpiry;
                                    if(String.isNotBlank((string)mapJSONIGAData.get('residentPermitNo')))
                                    	a.Residency_Permit_Number__pc = (string)mapJSONIGAData.get('residentPermitNo');
                                    if(String.isNotBlank((string)mapJSONIGAData.get('residentPermitExpiry')))
                                    	a.Residency_Permit_Expiry__pc = residentDateExpiry;
                                    
                                    if(c.Account.Due_Diligence_Category__pc == 'Standard Due Diligence'){
                                        a.pr_NextReviewDate__c = System.today() + 1095;
                                    }
                                    else if(c.Account.Due_Diligence_Category__pc == 'Enhanced Due Diligence'){
                                        a.pr_NextReviewDate__c = System.today() + 365;
                                    }
                                    a.Bypass_Validations__pc = true;
                                    a.pr_ReviewStatus__c = 'Completed';
                                    System.debug('Account acc:'+a);
                                    accListToUpdate.add(a);
                                    //c.eKYC_iGA_Response__c = response.getBody();
                                    c.Sub_Status__c = 'Completed';
                                    c.Status = 'Closed';
                                    caseListToUpdate.add(c);
                                }
                                //////////////////////////////// Fetching the Latest Wathiq data from case iGA Field //////////////////////////////
                                
                                ///////////////////////////////// Checking Gender, DateofBirth missing from case iGA Field ///////////////////////////////////////
                                /*if(passportDateExpiry > System.today().addDays(45) && residentDateExpiry > System.today().addDays(45) && (gender == '' || gender == null || dataOfBirth == '' || dataOfBirth == null)){
                                    System.debug('Other Documents are required case iGA Field');
                                    a.Id = c.AccountId;
                                    a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                    accListToUpdate.add(a);
                                    c.pr_OtherDocumentsRequired__c = true;
                                    c.Status = 'Pending Documents';
                                    c.Sub_Status__c = 'Overdue Stage 1';
                                    c.pr_Overdue_Stage_Date__c =System.now();
                                    caseListToUpdate.add(c);
                                }*/
                                ///////////////////////////////// Checking Gender, DateofBirth missing from case iGA Field ///////////////////////////////////////
                                
                                ////////////////////////////////// Checking Resident Expiry Date < Today ///////////////////////////////////////////////
                                if(passportDateExpiry > System.today().addDays(45) && residentDateExpiry <= System.today().addDays(45) && gender != '' && gender != null && dataOfBirth != '' && dataOfBirth != null){
                                    System.debug('Resident Permit Expire is less then today');
                                    a.Id = c.AccountId;
                                    //CH02: Start
                					if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     					a.pr_ReviewStatus__c = 'Overdue Stage 1';
									}
                					else
                						a.pr_ReviewStatus__c = 'Overdue';
                					//CH02: END
                                    accListToUpdate.add(a);
                                    c.pr_ResidencyPermitPhotoRequired__c = true;
                                    c.Status = 'Pending Documents';
                                    //c.Sub_Status__c = 'Overdue Stage 1';
                                    //c.pr_Overdue_Stage_Date__c =System.now();
                                    caseListToUpdate.add(c);
                                }
                                ////////////////////////////////// Checking Resident Expiry Date < Today ///////////////////////////////////////////////
                                
                                ///////////////////////////////// Checking Resident Expiry Date < Today & Gender, DateofBirth missing from case iGA Field///////////////////////////////////////////////////////////////////////////    
                                /*if(passportDateExpiry > System.today().addDays(45) && residentDateExpiry <= System.today().addDays(45) && (gender == '' || gender == null || dataOfBirth == '' || dataOfBirth == null)){
                                    System.debug('Resident Permit Expire');
                                    System.debug('Other Documents are required');
                                    a.Id = c.AccountId;
                                    a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                    accListToUpdate.add(a);
                                    c.pr_ResidencyPermitPhotoRequired__c = true;
                                    c.pr_OtherDocumentsRequired__c = true;
                                    c.Status = 'Pending Documents';
                                    c.Sub_Status__c = 'Overdue Stage 1';
                                    c.pr_Overdue_Stage_Date__c =System.now();
                                    caseListToUpdate.add(c);
                                }*/
                                ///////////////////////////////// Checking Resident Expiry Date < Today & CardCountry, Gender, DateofBirth missing from case iGA Field///////////////////////////////////////////////////////////////////////////    
                                
                                ////////////////////////////////// Checking passport Expiry Date < Today ///////////////////////////////////////////////
                                if(passportDateExpiry <= System.today().addDays(45) && residentDateExpiry > System.today().addDays(45) && gender != '' && gender != null && dataOfBirth != '' && dataOfBirth != null){
                                    System.debug('Passport Expire date is less then today');
                                    a.Id = c.AccountId;
                                    //CH02: Start
                					if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     					a.pr_ReviewStatus__c = 'Overdue Stage 1';
									}
                					else
                						a.pr_ReviewStatus__c = 'Overdue';
                					//CH02: END
                                    accListToUpdate.add(a);
                                    c.pr_PassportPhotoRequired__c = true;
                                    c.Status = 'Pending Documents';
                                    //c.Sub_Status__c = 'Overdue Stage 1';
                                    //c.pr_Overdue_Stage_Date__c =System.now();
                                    caseListToUpdate.add(c);
                                }
                                ////////////////////////////////// Checking passport Expiry Date < Today ///////////////////////////////////////////////
                                
                                ///////////////////////////////// Checking passport Expiry Date < Today & Gender, DateofBirth missing from case iGA Field///////////////////////////////////////////////////////////////////////////    
                                /*if(passportDateExpiry <= System.today().addDays(45) && residentDateExpiry > System.today().addDays(45) && (gender == '' || gender == null || dataOfBirth == '' || dataOfBirth == null)){
                                    System.debug('Passport Expires');
                                    System.debug('Other Documents are required');
                                    a.Id = c.AccountId;
                                    a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                    accListToUpdate.add(a);
                                    c.pr_PassportPhotoRequired__c = true;
                                    c.pr_OtherDocumentsRequired__c = true;
                                    c.Status = 'Pending Documents';
                                    c.Sub_Status__c = 'Overdue Stage 1';
                                    c.pr_Overdue_Stage_Date__c =System.now();
                                    caseListToUpdate.add(c);
                                }*/
                                ///////////////////////////////// Checking passport Expiry Date < Today & CardCountry, Gender, DateofBirth missing from case iGA Field///////////////////////////////////////////////////////////////////////////    
                                
                                ///////////////////////////////// Checking passport Expiry & Ressident Expiry < Today ////////////////////////////////////////////     
                                if(passportDateExpiry <= System.today().addDays(45) && residentDateExpiry <= System.today().addDays(45) && gender != '' && gender != null && dataOfBirth != '' && dataOfBirth != null){
                                    System.debug('Passport & Resident Permit Expire');
                                    a.Id = c.AccountId;
                                    //CH02: Start
                					if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                     					a.pr_ReviewStatus__c = 'Overdue Stage 1';
									}
                					else
                						a.pr_ReviewStatus__c = 'Overdue';
                					//CH02: END
                                    accListToUpdate.add(a);
                                    c.pr_PassportPhotoRequired__c = true;
                                    c.pr_ResidencyPermitPhotoRequired__c = true;
                                    c.Status = 'Pending Documents';
                                    //c.Sub_Status__c = 'Overdue Stage 1';
                                    //c.pr_Overdue_Stage_Date__c =System.now();
                                    caseListToUpdate.add(c);
                                }
                                ///////////////////////////////// Checking passport Expiry & Resident Expiry < Today ////////////////////////////////////////////     
                                
                            }
                            
                            //////////////////////////////////// Checking Full Name Tracking ///////////////////////////////////////////////////
                            /*else if(passportDateExpiry != null && passportNumber != '' && passportNumber != null && residentDateExpiry != null && residentNumber != '' && residentNumber != null && trackFullName <= 1){
                                a.Id = c.AccountId;
                                a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                accListToUpdate.add(a);
                                c.pr_OtherDocumentsRequired__c = true;
                                c.Status = 'Pending Documents';
                                c.Sub_Status__c = 'Overdue Stage 1';
                                c.pr_Overdue_Stage_Date__c =System.now();
                                caseListToUpdate.add(c);
                            }*/
                            //////////////////////////////////// Checking Full Name Tracking ///////////////////////////////////////////////////
                            
                            /////////////////////// Checking Passport Expiry or Passport Number Missing from case iGA Field //////////////////////////////
                            /*else if((passportDateExpiry == null || passportNumber == '' || passportNumber == null) &&
                                    (residentDateExpiry != null && residentNumber != '' && residentNumber != null) && trackFullName > 1){
                                        System.debug('Passport Expiry Date is Blank from API OR Parameter Missing');
                                        a.Id = c.AccountId;
                                        a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                        accListToUpdate.add(a);
                                        c.pr_PassportPhotoRequired__c = true;
                                        c.Status = 'Pending Documents';
                                        c.Sub_Status__c = 'Overdue Stage 1';
                                        c.pr_Overdue_Stage_Date__c =System.now();
                                        caseListToUpdate.add(c);
                                    }*/
                            ///////////////////// Checking Passport Expiry or Passport Number Missing from case iGA Field //////////////////////////////
                            
                            ///////////////////// Checking Resident Expiry or Resident Number Missing from case iGA Field /////////////////////////////
                            /*else if((residentDateExpiry == null || residentNumber == '' || residentNumber == null) &&
                                    (passportDateExpiry != null && passportNumber != '' && passportNumber != null ) && trackFullName > 1){
                                        System.debug('Resident Expiry Date is Blank from API OR Parameter Missing');
                                        a.Id = c.AccountId;
                                        a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                        accListToUpdate.add(a);
                                        c.pr_ResidencyPermitPhotoRequired__c = true;
                                        c.Status = 'Pending Documents';
                                        c.Sub_Status__c = 'Overdue Stage 1';
                                        c.pr_Overdue_Stage_Date__c =System.now();
                                        caseListToUpdate.add(c);
                                    }*/
                            ///////////////////// Checking Resident Expiry or Resident Number Missing from case iGA Field/////////////////////////////
                            
                            ////////////////////// Checking Passport Expiry or Passport Number and Resident Number or Resident Expiry is Missing from case iGA Field ////////////////////////////////////////////////////
                            /*else if((residentDateExpiry == null || residentNumber == '' || residentNumber == null) &&
                                    (passportDateExpiry == null || passportNumber == '' || passportNumber == null ) && trackFullName > 1){
                                        System.debug('Any One Resident Expiry Date, Passport Expiry Date, Resident Number & Passport Number is Blank from API OR Parameter Missing');
                                        a.Id = c.AccountId;
                                        a.pr_ReviewStatus__c = 'Overdue Stage 1';
                                        accListToUpdate.add(a);
                                        c.pr_ResidencyPermitPhotoRequired__c = true;
                                        c.pr_PassportPhotoRequired__c = true;
                                        c.Status = 'Pending Documents';
                                        c.Sub_Status__c = 'Overdue Stage 1';
                                        c.pr_Overdue_Stage_Date__c =System.now();
                                        caseListToUpdate.add(c);
                                    }*/
                            ////////////////////// Checking Passport Expiry or Passport Number and Resident Number or Resident Expiry is Missing from case iGA Field ////////////////////////////////////////////////////
                            
                        }
                        //CH04: END
                        ///////////////////////// Checking if Nationality or cardCountry is Missing or null from case iGA Field /////////////////////////////////////////////
                        /*else if(nationality == null || nationality == '' || cardCountry == null || cardCountry == ''){
                            Account a = new Account(Id = c.AccountId);
                            a.Id = c.AccountId;
                            a.pr_ReviewStatus__c = 'Overdue Stage 1';
                            accListToUpdate.add(a);
                            c.pr_PassportPhotoRequired__c = true;
                            c.Status = 'Pending Documents';
                            c.Sub_Status__c = 'Overdue Stage 1';
                            c.pr_Overdue_Stage_Date__c =System.now();
                            caseListToUpdate.add(c);
                        }*/
                        ///////////////////////// Checking if Nationality or cardCountry is Missing or null from case iGA Field /////////////////////////////////////////////
                        
                        
                    }
                    else if(String.isBlank(c.eKYC_iGA_Response__c)){
                        System.debug('Wathiq Form or CPR Form Available but eKYC iGA Response field is blank');
                        setCaseIdsHavingWathiqOrCPRWithEmptyeKYCiGAResponse.add(c.Id);
                        System.debug('Case Ids ***********'+setCaseIdsHavingWathiqOrCPRWithEmptyeKYCiGAResponse);
                    }
                } //for loop End
            }
        }
        try{
            if(accListToUpdate.size()>0){
                System.debug('AccList Size:'+accListToUpdate.size());
                System.debug('AccList to Update:'+accListToUpdate);
                //Database.update(accListToUpdate,false);
                update accListToUpdate;
            }
            if(caseListToUpdate.size()>0){
                //Database.update(caseListToUpdate,false);
                update caseListToUpdate;
            }
            if(setCaseIdsHavingWathiqOrCPRWithEmptyeKYCiGAResponse.size()>0){
                //PeriodicReviewHandlerAPI.fetcheKYCiGAData(setCaseIdsHavingWathiqOrCPRWithEmptyeKYCiGAResponse);
                FetcheKYCIGADataQueuableAPI fetchiGAData = new FetcheKYCIGADataQueuableAPI(setCaseIdsHavingWathiqOrCPRWithEmptyeKYCiGAResponse);
	            System.enqueueJob(fetchiGAData);
			}
        }catch(Exception e){
            System.debug('Exception Message in Periodic Handler API:'+e.getMessage());
        }
        
        ////////////////////////////////////////// END: Wathiq Consent Accepted & ID & V & Hash Available ////////////////////////////////////////////////////
        
        
    }
}