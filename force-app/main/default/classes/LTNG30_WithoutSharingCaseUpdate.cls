/**
 * @author Aniss Mbarki
 * @date Création 29/11/2022
 * @date Modification
 * @description : Update the case without sharing
 */
public without sharing class LTNG30_WithoutSharingCaseUpdate {

    @InvocableMethod(label='Update Case without Sharing' description='Update the case without sharing' )
    public static List<String> updateCaseFromFlow(List<CaseRecordDetails> caseDetails){

        List<Case> cases = new List<Case>(); 
        for(CaseRecordDetails caseRecDetail : caseDetails){
            Case  caseRec = new Case(); 
            caseRec.Id = caseRecDetail.caseId;
            if(caseRecDetail.status != null){
                caseRec.Status = caseRecDetail.status;
            }
            if(caseRecDetail.subStatus != null){
                caseRec.Sub_Status__c = caseRecDetail.subStatus;
            }
            cases.add(caseRec);
        }

        if(cases.size()>0){
            update cases;
        }
        
        return null;
    } 

    public class CaseRecordDetails {
        @InvocableVariable(label='Case Id' description='the Id of the Case' required=true)
        public String caseId;

        @InvocableVariable(label='Status' description='Status of the Case')
        public String status;

        @InvocableVariable(label='Sub Status' description='Sub Status of the Case')
        public String subStatus;
    }

    
}