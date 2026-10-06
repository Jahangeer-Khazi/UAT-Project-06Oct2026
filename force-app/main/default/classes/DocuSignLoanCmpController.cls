public class DocuSignLoanCmpController {

    public Case caseRecord { get; set; }
    public CaseAnnex__c caseAnnexObj { get; set; }
    
    public void setCaseObject(Object obj){
        caseRecord = (Case)obj;
    }
    
    public Case getCaseObject(){
        return caseRecord;
    }
    
    public void setCaseAnnexObject(Object obj){
        caseAnnexObj = (CaseAnnex__c)obj;
    }
    
    public CaseAnnex__c getCaseAnnexObject(){
        return caseAnnexObj;
    }
    
    
    public Decimal getCurrentDBR(){
        try {
            return ((caseRecord.Total_Current_Obligations__c / caseRecord.cc_Approved_Salary__c) * 100).setScale(3);
        }
        catch(Exception ex){
            return 0;
		}
    }
    
    public Decimal getNoOfMultiples(){
        
        try {
            return (caseAnnexObj.cx_ln_Approved_Loan_Amount__c / caseRecord.cc_Approved_Salary__c).setScale(3);
        }
        catch(Exception ex){
            return 0;
		}
    }
    
    public Decimal getCoverageRatio(){
        
        try {
            return (caseRecord.ccol_Approved_Hold_Amount__c / caseAnnexObj.cx_ln_Approved_Loan_Amount__c).setScale(3);
        }
        catch(Exception ex){
            return 0;
		}
    }
}