/**
* @author Jayanth Manickam
* @date Création 02/03/2022
* @date Modification
* @description :Contains functions called in 'bankStatementController' 
*/

public class bankStatementController {
    public string ReqID {get;set;}
    public Case RequestDetail {get;set;}
    public Boolean formatPrinted{get;set;}
    public Boolean formatElectronic{get;set;}
    public String regionCurrency{get;set;}
    public bankStatementController()
    {
        ReqId = Apexpages.currentPage().getparameters().get('recordId');    
        LoadData();
    }
    private void LoadData()
    {
        //Load the related time entry records from the database.
      RequestDetail = [select id,Account.Name,Customer_CIF__c,ac_Iban__c,PrimaryMaskedCardNumber__c,From_Date__c,To_Date__c,Delivery_Preference__c,Calculated_Fees__c,Debit_Account_IBAN__c,region_flag__c,Currency__c,case_Model__c,Sub_Type__c,cc_Credit_Card_PCI_Number__c from case Where Id=:ReqId order by ID DESC];
        if(RequestDetail.Delivery_Preference__c=='Printed'){
            formatPrinted=true;
            formatElectronic=false;
        }else{
            formatPrinted=false;
            formatElectronic=true;
        }
        if(RequestDetail.region_flag__c=='Bahrain'){
            regionCurrency='BHD';
        }else{
            regionCurrency='JOD';
        }
    }
}