global class batchCls_updateCRMContnetFields implements Database.Batchable<sObject>
{
    //where Id = \'a0O1j000002s3cxEAA\'
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select id,ID_Type__c, Scan_Type__c, Document_Type__c, Document_Country__c, Proof_of_Address_ID_Type__c, Content_Created_By__c, Customer_Document_Country__c, Upload_Type__c, ID_Number__c, Document_Number__c, ID_Expiry_Date__c, Document_Expiry_Date__c from Content__c ';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<Content__c> lstContent = (List<Content__c>)scope;
        List<Content__c> newLst = new List<Content__c>();
        for(Content__c objCon:lstContent)
        {
            if(objCon.ID_Type__c != null){
                objCon.Scan_Type__c = 'POI';
                if(objCon.ID_Type__c == 'Bahraini ID'){
                    objCon.Document_Type__c = 'Bahraini ID';
                    objCon.Document_Country__c = 'BH';
                }
                if(objCon.ID_Type__c == 'Passport'){
                    objCon.Document_Type__c = 'Passport';
                    objCon.Document_Country__c = objCon.Customer_Document_Country__c;
                }
                if(objCon.ID_Type__c == 'GCC ID'){
                    objCon.Document_Type__c = 'GCC ID';
                    objCon.Document_Country__c = objCon.Customer_Document_Country__c;
                }
            }
            if(objCon.Proof_of_Address_ID_Type__c != null){
                objCon.Scan_Type__c = 'POA';
                objCon.Document_Country__c = 'BH';
                if(objCon.Proof_of_Address_ID_Type__c == 'Utility Bill')
                    objCon.Document_Type__c = 'Utility Bill';
                if(objCon.Proof_of_Address_ID_Type__c == 'Bahraini Drivers Licence')
                    objCon.Document_Type__c = 'Bahraini Drivers Licence';
                if(objCon.Proof_of_Address_ID_Type__c == 'Bank Statement')
                    objCon.Document_Type__c = 'Bank Statement';
                if(objCon.Proof_of_Address_ID_Type__c == 'CPR Extract')
                    objCon.Document_Type__c = 'CPR Extract';
                if(objCon.Proof_of_Address_ID_Type__c == 'Tenancy Agreement')
                    objCon.Document_Type__c = 'Tenancy Agreement';
                if(objCon.Proof_of_Address_ID_Type__c == 'Phone Bill')
                    objCon.Document_Type__c = 'Utility Bill';
            }
            if(objCon.Content_Created_By__c == 'AWS Integration')
                objCon.Upload_Type__c = 'Digital';
            else{
                objCon.Upload_Type__c = 'Manual';
            }
            if(objCon.ID_Number__c != null){
                objCon.Document_Number__c = objCon.ID_Number__c;
            }
            if(objCon.ID_Expiry_Date__c != null){
                objCon.Document_Expiry_Date__c = objCon.ID_Expiry_Date__c;
            }
            newLst.add(objCon);
        }
        update newLst;
    }
    public void finish(Database.BatchableContext BC) {
    }
}