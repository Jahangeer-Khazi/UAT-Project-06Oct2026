public without sharing class cc_DocuSignGetEnvelopeId {

    private static String CLASS_NAME = cc_DocuSignGetEnvelopeId.class.getName();
    
    public static void cc_DocuSignGetEnvelopeIdProcess(Set<Id> caseIds){
        Id caseId = caseIds.iterator().next();
        docuSignGetEnvelopeFuture(caseId);
    } 

    // called in creation and update
    @future(callout=true)
    public static void docuSignGetEnvelopeFuture(Id caseId){
        try{
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,Account.x_canary__pc,Account.Segment__pc,Account.Nationality__pc FROM Case WHERE Id = :caseId';
            List<Case> cases = new List<Case>((List<Case>)Database.query(soqlQuery));
            Case caseObj = cases[0];
            
            String cc_envelopeId = cc_EmbeddedSigningHandler.sendEnvelope(caseObj);
            system.debug('cc_envelopeId ==> '+cc_envelopeId);
            
            //store system log all the time
            insert SM001_ApiCalls.setSystemAction( 'Docusign Api called','cc_envelopeId ==> '+cc_envelopeId,
                                                      null,null,
                                                      caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                      'Docusign Api called : ', caseObj.Type
                                                     );
            
            if(cc_envelopeId != null){
                //store the value
                update new Case(Id=caseId,bs_Instrument_ID__c =cc_envelopeId);
                // call loan update process in queable method !!
                System.enqueueJob(new CC_CaseUpdateJob(caseObj));
            }
           
        }catch(Exception e){
            Case caseObj = [SELECT Id,Customer_CIF__c,accountId,Type FROM Case WHERE Id =: caseId];
            //store unexpected errors from system !!
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            insert SM001_ApiCalls.setSystemAction( e.getMessage(),String.valueOf(e.getStackTraceString()),
                                                  null,null,
                                                  caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                  'please check : '+CLASS_NAME+'.docuSignGetEnvelopeFuture()', caseObj.Type
                                                 );
        }

    }

    // Inner class to update
    public class CC_CaseUpdateJob implements Queueable {
        private Case caseObj;

        public CC_CaseUpdateJob(Case caseObj) {
            this.caseObj = caseObj;
        }

        public void execute(QueueableContext qc) {
            if(this.caseObj.Type == 'Credit Card Application' || this.caseObj.Type == 'Credit Limit Increase Application' ){
                System.debug('execute Queueable method initiateManualOnboarding.CCCaseUpdate --');
                initiateManualOnboarding.CCCaseUpdate(new Set<Id>{this.caseObj.Id});
            }else if (this.caseObj.Type == 'Credit Card Cash Collateral Application' || this.caseObj.Type == 'Cash Collateral Credit Limit Increase Application'){
                System.debug('execute Queueable method CreditCardCashCollateral.CashCollateralCaseUpdate --');
                CreditCardCashCollateral.CashCollateralCaseUpdate(new Set<Id>{this.caseObj.Id});
            }
        }
    }
}