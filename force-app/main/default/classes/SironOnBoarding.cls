/**
 *	@author: SP
 *	@date: 2019-09-29 
 *	@description:
 *	    Queue to callout On boarding to update case when Siron success response from 
 *      Compliance Case Status API and decision != pending
 *  Version History :
 *  2021-11-27 - #CH01# - YZ Region Name changes
 */
public class SironOnBoarding implements Queueable, Database.AllowsCallouts{
    private List<Id> runCaseIds = new List<Id>();
    private ID case2Process;

    public SironOnBoarding(Id case2Process, Id[] runCaseIds) {
        this.case2Process = case2Process;

        if(runCaseIds != null){
            this.runCaseIds = runCaseIds;
        }
    }

    public void execute(QueueableContext context){
        //fetch all Cases with Case.Type = ‘Name Screening’ and Status != ‘Closed’ to callout 
        Case[] lstCase2Process = [Select Type, Contact.Email, Subject, Status, Account.CIF__pc, Account.PersonEmail,
                                        Child_Case_Closure_Recommendation__c, Region_Flag__c // #CH01#
                                    From Case Where ID =: case2Process];

        if(!lstCase2Process.isEmpty()){
            Case caseRecord = lstCase2Process[0];
            caseRecord.status = 'Closed';//we will update case to closed if continue on borading response success

            //we will get email from both Account and Contact because we have issue that some Case has email in contact
            //but some Case has only in account
            String email = (caseRecord.Account.PersonEmail != null ? caseRecord.Account.PersonEmail : (caseRecord.Contact.Email != null ? caseRecord.Contact.Email : ''));
            
            map<String, String> reqBody = new map<String, String>();
            reqBody.put('caseId', caseRecord.id);
            reqBody.put('caseStatus', 'Verified'); // JT 061019 Required value for OL
            reqBody.put('caseType', (caseRecord.Type != null ? caseRecord.Type : ''));
            reqBody.put('caseOutcome', (caseRecord.Child_Case_Closure_Recommendation__c != null ? caseRecord.Child_Case_Closure_Recommendation__c : ''));
            reqBody.put('email', (email != '' ? email : ''));

            ApiConnection.Response responseOnboarding = OnboardingCaseController.sendOnboardingContinueRequest(caseRecord.id, 
                                                                                                                caseRecord.Account.CIF__pc, 
                                                                                                                'Continue On boarding',
                                                                                                                JSON.serialize(reqBody),
                                                                                                                email,
                                                                                                                caseRecord.Region_Flag__c
                                                                                                                ) ;
            System.debug('>>>>responseOnboarding'+ responseOnboarding);
            //4. If Continue Onboarding API responds 200, we close the Case in Salesforce
            if(responseOnboarding.isSuccess){
                update caseRecord;
            }

            //after callout we need to run the work again to run next record, although the previous process success or not
            System.debug('>>>>Run SironCaseStatus again');
            if( !Test.isRunningTest() && (Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() > 0)){
                System.enqueueJob(new SironCaseStatus(runCaseIds));
            }
        }
    }
}