/********************************************************************************************
* @name                 WalkInCustomerSurveyController
* @description          This controller would responsible to fetch the case id and pass it to LWC 
* @date                 09/04/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           09/04/2025     Initial Version
*********************************************************************************************
*/

public without sharing class WalkInCustomerSurveyController {

    public enum SurveyStatus { LINK_EXPIRED, SURVEY_SUBMITTED, INVALID_CASE, ERROR, SURVEY_YET_TO_SUBMIT }
    public String caseId { get; set; }
    public String rating { get; set; }
    public String optionalComment { get; set; }
    public Boolean isIssueFixed { get; set; }
    public Boolean showSubmitButton { get; set; }
    public Boolean isArabic { get; set; }
    public String textDesc { get; set; }
    
    public WalkInCustomerSurveyController() {
        ApexPages.currentPage().getHeaders().put('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0');
        ApexPages.currentPage().getHeaders().put('Pragma', 'no-cache');
        ApexPages.currentPage().getHeaders().put('Expires', '0');
        caseId = ApexPages.currentPage().getParameters().get('id');
        textDesc = '';
        showSubmitButton = true;
    }
    
    public PageReference validateSurveyRequest(){
        isArabic = false;
        caseId = ApexPages.currentPage().getParameters().get('id');
        if(!String.isBlank(caseId)){
            PageReference newPage;
            SurveyStatus surveyStatus = ValidateCase();
            System.debug('survey status ' + surveyStatus);
            switch on surveyStatus {
                when LINK_EXPIRED {
                    newPage = isArabic ? Page.survey_expired_ar : Page.survey_expired;
                }
                when SURVEY_SUBMITTED {
                    newPage = isArabic ? Page.survey_submitted_ar : Page.survey_submitted;
                }
                when INVALID_CASE, ERROR {
                    newPage = isArabic ? Page.survey_error_ar : Page.survey_error;
                }
            }

            if(newPage != null){
                newPage.setRedirect(true);
                return newPage;
            }
            //else : The survey has not submitted by customer so no action needs to be taken.
        }
        else {
            PageReference errorPage = isArabic ? Page.survey_error_ar : Page.survey_error;
            errorPage.setRedirect(true);
            return errorPage;
        }
        
        return null;
    }
    
    public SurveyStatus ValidateCase(){
        
        try {
            List<Walkin_Customer_Survey_Response__c> records = [Select Id FROM Walkin_Customer_Survey_Response__c 
                                                        WHERE Case__c =: caseId LIMIT 1];
            
            List<Case> caseRecord = [Select Id,ClosedDate,Account.Language_Preference__pc,RecordType.DeveloperName
                                         FROM Case WHERE Id =: caseId 
                                         AND RecordType.DeveloperName IN ('Walkin_Customers','Service_Request','Complaint')
                                         AND Status = 'Closed' LIMIT 1];
            
            if(!caseRecord.isEmpty()){
                Account acct = caseRecord[0].Account;
                if(acct != null && !String.isBlank(acct.Language_Preference__pc) && acct.Language_Preference__pc == 'Arabic'){
                    isArabic = true;
                }
                
                if(caseRecord[0].RecordType.DeveloperName == 'Walkin_Customers'){
                    if(isArabic){
                        textDesc = Label.CSAT_Welcome_Walkin_Pg_Desc_AR;
                    }
                    else {
                    	textDesc = Label.CSAT_Welcome_Walkin_Pg_Desc_EN;    
                    }
                }
                else {
                    isArabic = false;
                    if(isArabic){
                        textDesc = Label.CSAT_Welcome_Support_Pg_Desc_AR;
                    }
                    else {
                    	textDesc = Label.CSAT_Welcome_Support_Pg_Desc_EN;    
                    }
                }
            }
            
            
            
            //if records is empty that means survey has not been submitted.
            if(records.isEmpty()){
                
                if(!caseRecord.isEmpty()){
                    
                    
                    
                    Date caseClosedDate = caseRecord[0].ClosedDate.date();
                    Date todaysDate = Date.today();
                    Integer daysDiff = caseClosedDate.daysBetween(todaysDate);
                    Integer linkExpireInDays = 0;
                    if(Label.Survey_Link_Expires_In_Days.isNumeric()){
                        linkExpireInDays = Integer.valueOf(Label.Survey_Link_Expires_In_Days);
                    }
                    if(daysDiff > linkExpireInDays){
                        return SurveyStatus.LINK_EXPIRED;
                    }
                    else {
                        return SurveyStatus.SURVEY_YET_TO_SUBMIT;
                    }
                }
                else {
                    return SurveyStatus.INVALID_CASE;
                }
            }
            else {
                return SurveyStatus.SURVEY_SUBMITTED;   
            }
        }
        catch(Exception ex){
            return SurveyStatus.ERROR;
        }
    }
    
    public PageReference saveSurveyRequest(){
        PageReference pgReference = validateSurveyRequest();
        
        //checking if the survey already submitted or not.
        if(pgReference != null){
            return pgReference;
        }
        
        PageReference errorPage = Page.survey_error;
        
        List<Case> caseRecord = [Select Id FROM Case WHERE Id =:caseId LIMIT 1];
        System.debug('146 caseRecord ' + caseRecord);
        if(!caseRecord.isEmpty()){
            try {
                
                List<Walkin_Customer_Survey_Response__c> records = [Select Id FROM Walkin_Customer_Survey_Response__c 
                                                        WHERE Case__c =: caseId LIMIT 1];
                System.debug('152 records ' + records);
                if(records.isEmpty()){
                	Walkin_Customer_Survey_Response__c obj = new Walkin_Customer_Survey_Response__c();
                    obj.Case__c = caseId;
                    obj.Issue_Resolve__c = isIssueFixed;
                    obj.Ratings__c = rating;
                    obj.Comments__c = optionalComment;
                    insert obj;
                    PageReference thanksPage = isArabic ? Page.survey_thanks_ar : Page.survey_thanks;
                    thanksPage.setRedirect(true);
                    return thanksPage;    
                }
                else {
                    PageReference surveySubmittedPage = isArabic ? Page.survey_submitted_ar : Page.survey_submitted;
                    surveySubmittedPage.setRedirect(true);
                    return surveySubmittedPage;
                }
            }
            catch(Exception ex){
                errorPage.setRedirect(true);
                return errorPage;
            }
        }
        else {
            errorPage.setRedirect(true);
            return errorPage;
        }
    }
}