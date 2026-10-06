/**
 *	@author: SP
 *	@date: 2019-09-18 
 *	@description:
 *	    Queue to callout Siron for update check case and update
 *      CRM needs to check for updates from Siron for Name Screening cases so that once the issue has been solved in Siron, the Case can be closed in CRM.
 *  Version History :
 *  2021-11-27 - #CH01# - YZ Region Name changes
 */
public class SironCaseStatus implements Queueable, Database.AllowsCallouts{
    private List<Id> runCaseIds = new List<Id>();

    public SironCaseStatus(Id[] caseIds){
        if(caseIds != null){
            this.runCaseIds = caseIds;
        }
    }

    public void execute(QueueableContext context){
        System.debug('>>>>runCaseIds'+ runCaseIds);
        //fetch all Cases with Case.Type = ‘Name Screening’ and Status != ‘Closed’ to callout 
        Case[] lstCases = [Select Type, Contact.Email, Subject, Status, Account.CIF__pc, Account.PersonEmail,
                                Child_Case_Closure_Recommendation__c, Region_Flag__c // #CH01#
                            From Case Where Type='Name Screening' AND Status != 'Closed' AND ID not in: runCaseIds Limit 1];

        Boolean isRerun = false;

        System.debug('>>>>lstCase'+ lstCases);
        if(!lstCases.isEmpty() ){
            Case caseRecord = lstCases[0];
            runCaseIds.add(caseRecord.id);

            try{
                //we will get email from both Account and Contact because we have issue that some Case has email in contact
                //but some Case has only in account
                String email = (caseRecord.Account.PersonEmail != null ? caseRecord.Account.PersonEmail : (caseRecord.Contact.Email != null ? caseRecord.Contact.Email : ''));
                isRerun = email == ''; //if the current record doesnt have email, we will go next record
                
                if(email != ''){
                    
                    //1. We send a request to Compliance Case Status API
                    ApiConnection.Response response = OnboardingCaseController.sendComplianceCheckRequest(caseRecord.id, caseRecord.Account.CIF__pc, 'Name Screening', email, caseRecord.Region_Flag__c); // #CH01#

                    //if the request for current record isn't success,
                    //we will do next record
                    isRerun = !response.isSuccess;

                    System.debug('>>>>response'+ response);
                    if(response.isSuccess){
    
                        //SP: 2019-10-07: Update response body format
                        Map<String, Object> data = response.responseData != null ? (Map<String, Object>)response.responseData : new Map<String, Object>();
                        // Map<String, Object> data = responseData.containsKey('data') ? (Map<String, Object>) responseData.get('data') : new Map<String, Object>();
                        String status = data.containsKey('status') ? (String)data.get('status'): '';
                        String decision = data.containsKey('decision') ? (String)data.get('decision') : '';
    
                        //after callout we need to run the work again to run next record, 
                        //although the previous process success or not
                        isRerun = decision.equalsIgnoreCase('pending');

                        System.debug('>>>>responseData'+ data);
                        //2. Check for “decision” != “PENDING” 
                        //3. If “decision” != “PENDING” then chain request to Continue Onboarding API
                        if(!decision.equalsIgnoreCase('pending') && !Test.isRunningTest() && (Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() > 0)){
    
                            // callout to Continue on borading,
                            //we callout using another queueable because FUTURE doesn't work in queueable
                            //We will hit error "You have uncommitted work pending. Please commit or rollback before calling out"
                            System.enqueueJob(new SironOnBoarding(caseRecord.id, runCaseIds));
                        }
                    }
                }
                 
            }catch(Exception ex){
                //if there are any error with current record,
                //go to do next record
                if((Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() > 0)){
                     System.enqueueJob(new SironCaseStatus(runCaseIds));
                }
               
            }
        }

        if(isRerun && !Test.isRunningTest() && (Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() > 0)){
            System.enqueueJob(new SironCaseStatus(runCaseIds));
        }
        
    }
}