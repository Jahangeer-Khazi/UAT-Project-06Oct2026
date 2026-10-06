/**
*  @author: Imane Tsioucha
*  @date: 31-05-2024  
*  @description:
*      controller for aura component "LTNG050_DisputeAgingKPI"
*     
*      
*/
public with sharing class LTNG050_DisputeAgingKPIController {
    @AuraEnabled
    public static void updateSubTypeAndComment(String recordId,String subTypeValue,String commentValue){
        try {
            Case cs=[SELECT Id,Sub_Type__c,ac_Pending_Date__c,RecordType_DeveloperName__c, Type FROM Case WHERE Id=:recordId];
            if(cs!=null){
                Integer additionalDays;
                if(cs.RecordType_DeveloperName__c == 'Case_Disputes_and_Frauds') {
                    if(subTypeValue == 'Customer Transaction & Payment Disputes- Mastercard') {
                        additionalDays = 45;
                        cs.Type = 'MasterCard';
                    } else if (subTypeValue == 'Customer Transaction & Payment Disputes- Benefit') {
                        additionalDays = 9;
                        cs.Type = 'Benefit';
                    }
                } else {
                    if (subTypeValue == 'Customer Transaction & Payment Disputes- Benfit') {
                        additionalDays = 9;
                    } else if (subTypeValue == 'Customer Transaction & Payment Disputes- Mastercard') {
                        additionalDays = 45;
                    }
                    cs.Sub_Type__c=subTypeValue;
                }
                
                if (additionalDays != null) {
                    cs.To_Date__c = Date.today().addDays(additionalDays);
                }
                
                cs.Comments=commentValue;
                cs.ac_Pending_Date__c=DateTime.now();
                System.debug('cs --->'+cs);
                update cs;
            }
            
            
        } catch (Exception e) {
            System.debug('error on updateSubTypeAndComment==>  '+e);
            
        }
        
    }
    
    @AuraEnabled
    public static Case getRecordDetails(Id recordId) {
        Case caseRecord;
        try {
            caseRecord = [
                SELECT Id, RecordType_DeveloperName__c, Type
                FROM Case
                WHERE Id = :recordId
                LIMIT 1
            ];
        } catch (Exception e) {
            // Log the error or handle it as needed
            System.debug('Error fetching case record: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while fetching case details. Please try again.');
        }
        return caseRecord;
    }
    
}