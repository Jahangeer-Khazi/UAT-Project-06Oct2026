public class LoanCalculationSummaryController {

    public CaseAnnex__c caseAnnexObj { get; set; }
    public List<LoanDocuSignDocumentListController.DocuSignWrapper> docList {get;set;}
    public List<LoanDocuSignDocumentListController.DocuSignWrapper> docuSignList {get;set;}
    static Id caseId = ApexPages.currentPage().getParameters().get('id');
    
    public LoanCalculationSummaryController(ApexPages.StandardController controller){
        caseAnnexObj = [SELECT Id,cx_ln_Approved_Loan_Amount__c,cx_ln_Product__c, cx_ln_Document_Verifier_OBL_Result__c, 
                        cx_ln_Document_Verifier_OBL_Result_By__c,cx_ln_DocumentVerifierOBLResult_DateTime__c,
                        cx_ln_Document_Verifier_Result__c,cx_ln_Document_Verifier_Result_By__c,
                        cx_ln_Document_Verifier_Result_Date_Time__c,cx_ln_DocumentVerifierNDLResult__c,
                        cx_ln_Document_Verifier_NDL_Result_By__c,cx_ln_DocumentVerifierNDLResult_DateTime__c
                        FROM CaseAnnex__c WHERE Case__c =: caseId LIMIT 1];
        
        docList = LoanDocuSignDocumentListController.getDocumentList(caseId,true);
        docuSignList = LoanDocuSignDocumentListController.getDocumentList(caseId,false);
        System.debug('docList ' + docList.size());
        System.debug('docuSignList ' + docuSignList.size());
    }
    
    /*public List<LoanDocuSignDocumentListController.DocuSignWrapper> getDocuSignDocumentList(){
        System.debug('docuSignDocumentList ');
        System.debug('docuSignDocumentList ' + docList);
        List<LoanDocuSignDocumentListController.DocuSignWrapper> docuSignList = new List<LoanDocuSignDocumentListController.DocuSignWrapper>();
        for(LoanDocuSignDocumentListController.DocuSignWrapper doc : docList){
            System.debug('doc.documentType ' + doc.documentType);
            //if(doc.documentType == 'DocuSign Document'){
            if(doc.documentType == 'DocuSign Document' || doc.documentType == 'DocuSign Document'){
            	docuSignList.add(doc);    
            }
        }
        return docuSignList;
    }*/
}