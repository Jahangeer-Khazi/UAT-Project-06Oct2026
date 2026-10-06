public class PlaceHoldQueueable implements Queueable, Database.AllowsCallouts {

    private Set<Id> caseIds;

    public PlaceHoldQueueable(Set<Id> caseIds) {
        this.caseIds = caseIds;
    }
    
    public void execute(QueueableContext context) {
    
        List<Id>ReleaseHold= New List<Id>();
        List<Id>PlaceHold= New List<Id>();
        For( Case caseObj :[SELECT Id,account.CIF__pc,Case_Model__c,Region_Flag__c,accountId,bs_Total_Bid_Amount__c,type,Operation_Result__c,Cc_Checker_result__c,OwnerId, Origin,bs_Investment_ID__c FROM Case WHERE Id IN:this.caseIds]){
            if(caseObj.Type=='Place Hold'){
                PlaceHold.add(caseObj.Id);
            }
            if(caseObj.Type=='Release Hold'){
                ReleaseHold.add(caseObj.Id);
            }
        }
        
        if(!PlaceHold.isEmpty()){
            processPlaceHold(PlaceHold);
        }
        if(!ReleaseHold.isEmpty()){
            processReleaseHold(ReleaseHold);
        }
    }
    
    private void processPlaceHold(List<String> caseIds){
        String CaseModel;
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> casesToUpdateList=new List<Case>();
        List<String>accntID = New List<String>();
        List<Case> caseRec= New List<Case>();
        if(!caseIds.isEmpty()){
            
            Case caseObj = [SELECT Id,Place_hold_on_all_Accounts__c,Customer_CIF__c,AccountId,Case_Model__c,Region_Flag__c,account.CIF__pc,BUA_AccountsInformation__c,RHA_HoldExpiryDate__c,RHA_HoldAmount__c,Hold_Description__c, Account.x_canary__pc FROM Case WHERE Id IN:caseIds LIMIT 1];
            
            String accountBody = '';
            if(!String.isBlank(caseObj.BUA_AccountsInformation__c)){
                //Sample account information, it contains IBAN,Currency and Account with comma separate fields
                //BH06ABCO91002011980492 - BHD - CUSTOMER_ACCOUNT,BH60ABCO91002011994458 - GBP - CUSTOMER_ACCOUNT
                
                String[] accountList = caseObj.BUA_AccountsInformation__c.split(',');
                
                for(String accountStr : accountList){
                    String[] acccountDetails = accountStr.split('-');
                    String ibanNumber = acccountDetails[0].trim();
                    String accCurrency = acccountDetails[1].trim();
                    Date todayDate = Date.today();
                    
                    String fromDate = String.valueOf(todayDate); //DateTime.newInstance(todayDate,Time.newInstance(0,0,0,0)).formatGmt('yyyy-MM-dd');
                    system.debug('todayDate ' + todayDate);
                    system.debug('fromdate ' + fromDate);
                    if(!caseObj.Place_hold_on_all_Accounts__c){
                        if(accountBody == ''){
                            accountBody = '{"iban":"'+ ibanNumber +'","amount":"'+ caseObj.RHA_HoldAmount__c +'","currency":"'+ accCurrency +'","fromDate":"'+ fromDate +'","toDate":"'+ caseObj.RHA_HoldExpiryDate__c +'","description":"'+ caseObj.Hold_Description__c +'"}';    
                        }
                        else {
                            accountBody = accountBody + ',' + '{"iban":"'+ ibanNumber +'","amount":"'+ caseObj.RHA_HoldAmount__c +'","currency":"'+ accCurrency +'","fromDate":"'+ fromDate +'","toDate":"'+ caseObj.RHA_HoldExpiryDate__c +'","description":"'+ caseObj.Hold_Description__c +'"}';    
                        }    
                    }
                    else {
                        accountBody = '{"amount":"'+ caseObj.RHA_HoldAmount__c +'","fromDate":"'+ fromDate +'","toDate":"'+ caseObj.RHA_HoldExpiryDate__c +'","description":"'+ caseObj.Hold_Description__c +'"}';
                    }
                }
            }
            accountBody = '{"allAccounts" : '+ caseObj.Place_hold_on_all_Accounts__c +',"accounts":[' + accountBody + ']}';
            
            String regionName = caseObj.Region_Flag__c;
            if(caseObj.Case_Model__c == 'alburaq'){
                regionName += '_alburaq';
            }
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            ApiConnection con = new ApiConnection();
            request = con.createRequest('POST','/api/v1/transactions/account/hold',caseObj.account.CIF__pc,regionName);
            request.setBody(accountBody);
            if(caseObj.Account.x_canary__pc != null){
                request.setHeader('x-canary', caseObj.Account.x_canary__pc);
            }
            System.debug('body ' + request.getBody());
            request.setTimeout(120000);
            HttpResponse response = http.send(request);
            System.debug('response body ' + response.getBody());
            if (response.getStatusCode() != 200) {
                System.debug('Api Error.');
                List<System_Action__c> systemActions = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'POST',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 'Account Hold Request', 'Account Hold Request');
            	caseObj.Last_Api_Call_Status__c = 'Failed';
                caseObj.Status = 'In-Progress';
                caseObj.Sub_Status__c = 'In-Progress';
                update caseObj;
                insert systemActions;
            }
            else {
                System.debug('API call successfully done.');
                Map<String,Object> apiResponseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                Map<String,Object> responseDataMap = (Map<String,Object>)apiResponseMap.get('data');
                String referenceHold = String.valueOf(responseDataMap.get('holdReference'));
                System.debug('referenceHold ' + referenceHold);
                //Updating Hold reference number.
                caseObj.ccol_Hold_Reference_Number__c = referenceHold;
                caseObj.Status = 'Closed';
                caseObj.Last_Api_Call_Status__c = 'Success';
                update caseObj;
            }
        }
    }
    
    private void processReleaseHold(List<String> caseIds){
        
    }
    
    private static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Integer statCode, Final String strAction, Final String strType) {
        List<System_Action__c> lstSA = new List<System_Action__c>();
        System_Action__c action = new System_Action__c();
        action.Account_Number__c = custId;
        action.Action__c = strAction;
        //  action.Card_Number__c = objCase.cc_Requested_Card_Type__c;
        action.Case__c = CaseId;
        action.Account__c = AccId;
        action.Endpoint__c = path;
        action.Method__c = method;
        action.HTTP_Response_Code__c = statCode;
        action.Origin__c = 'CRM';
        action.Request_Body__c = reqBody;
        action.Response_Body__c = resBody;
        action.Target__c = 'Orchestration Layer';
        action.Type__c = strType;
        lstSA.add(action);
        
        return lstSA;
        
    }
}