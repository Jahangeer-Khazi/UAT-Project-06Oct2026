/**
* 
*  Change History :     
*         #CH01 : #D&A Team #24-06-2022# Added alburaq logic.
*/
public with sharing class LTNG003_BlockUnblockProcessController {
    
    @AuraEnabled
	public static Id getBlockUnblockCaseRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('AmountBlockingUnblockingDirective').getRecordTypeId();
    }

    @AuraEnabled
	public static List<BlockAmountDetails> getExistingCbbBlocksViaApi(String accountId,String caseModel) {
        ApiConnection con = new ApiConnection();

        System.debug('===========++>  '+accountId);
        List<BlockAmountDetails> blockAmounts = new List<BlockAmountDetails>();
        if(accountId != null && accountId != '' ){
            List<System_Action__c> lstSA = new List<System_Action__c>();
            Account accObj = [SELECT Id, CIF__pc,PersonEmail,Region_Flag__c FROM Account WHERE Id=: accountId];
    
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //#CH01 Start
            String regionName = accObj.Region_Flag__c;
            if(caseModel == 'alburaq'){
                regionName += '_alburaq';
            }
        
            request = con.createRequest('GET','/api/v1/customer-products/amount-block',regionName);
            //#CH01 End
    
            request.setHeader('userId', accObj.PersonEmail);
            request.setHeader('customerId', accObj.CIF__pc);
    
            system.debug('---> Request --> '+request.getBody());
            HttpResponse response = http.send(request);

            if (response.getStatusCode() != 200 ) {
                String errorMsg = 'The status code returned was not expected when we are calling Get Blocked Amounts API : ' + response.getStatusCode();
                System.debug(errorMsg);
                throw new AuraHandledException(errorMsg);
            }else {
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                List<Object> blockAmountList = (List<Object>)m1.get('blockAmountDetailsList'); 
                for(Object blockAmount : blockAmountList){
                    Map<String,Object> mapblockAmount = (Map<String, Object>)blockAmount;
                    blockAmounts.add( new BlockAmountDetails(
                        String.valueOf(mapblockAmount.get('blockid')) , 
                        Decimal.valueOf(String.valueOf(mapblockAmount.get('blockedAmount'))) , 
                        String.valueOf(mapblockAmount.get('caseNumber')) , 
                        String.valueOf(mapblockAmount.get('letterReferenceNumber')))
                    );
                }
            }
        }
        
        return blockAmounts;
    }

    public class BlockAmountDetails {     
        @AuraEnabled 
        public String blockId {get; set;}

        @AuraEnabled 
        public Decimal blockedAmount {get; set;}
        
        @AuraEnabled 
        public String caseNumber {get; set;}
        
        @AuraEnabled 
        public String letterReferenceNumber {get; set;}
         
        public BlockAmountDetails(String blockId,Decimal blockedAmount,String caseNumber,String letterReferenceNumber){
            this.blockId = blockId;
            this.blockedAmount = blockedAmount;
            this.caseNumber = caseNumber;
            this.letterReferenceNumber = letterReferenceNumber;
        }
    }
}