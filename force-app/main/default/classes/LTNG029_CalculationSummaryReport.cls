/**
 *  @author: Imane Tsioucha
 *  @date: 2023-03-06  
 *  @description:
 *      controller for aura component "LTNG029_CalculationSummaryReport"
 *     
 *      
 */
public with sharing class LTNG029_CalculationSummaryReport {

    @AuraEnabled
    public static String getRecordType(Id recordId){
        String VfName = '';
        Set<Id> listId=new Set<Id>();
        listId.add(recordId);
        try {
            List<Case> cases = DM002_Case.getListByIds(listId);
            for (Case cs : cases) {
                if(cs.RecordType_DeveloperName__c == 'Credit_Card_Cash_Collateral_Staff'||cs.RecordType_DeveloperName__c == 'Credit_Card_Cash_Collateral_Regular'|| cs.RecordType_DeveloperName__c == 'Cash_Collateral_Credit_Limit_Increase') VfName = 'VF03_CalculationSummaryReportPdfSecured';
                if((cs.RecordType_DeveloperName__c == 'Credit_Card' && cs.type == 'Credit Card Application') ||  cs.RecordType_DeveloperName__c == 'Credit_Limit_Increase' || cs.RecordType_DeveloperName__c == 'Convert_Credit_Card') VfName = 'VF02_CalculationSummaryReportPdf';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return VfName;
    }
}