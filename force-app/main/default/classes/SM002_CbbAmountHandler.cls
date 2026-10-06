/* 
 *   Changes History :
 *    #CH01# #Hamza Chaoui# #04-07-2022# -- implement alburaq unit changes.
 */
public class SM002_CbbAmountHandler {
    
    
    public static void handleAfterCaseUpdate(List<Case> newCases, Map<Id,Case> oldMap){
        Set<Id> cbbAmountCaseIds = new Set<Id>();

        for (Case newCase : newCases) {
            Case oldCase = oldMap.get(newCase.Id) ;
            
            // if( newCase.Tech_isCbbRecordType__c == true && newCase.cc_Checker_Result__c != oldCase.cc_Checker_Result__c && 
            //     newCase.Type == 'CBB Amount block/unblock request' && newCase.Status != 'Closed'
            // ){
            //     cbbAmountCaseIds.add(newCase.Id);
            // }
        }

        // if(cbbAmountCaseIds.size() > 0){
        //     cbbAmountBUD_Process(cbbAmountCaseIds);
        // }
    }
    //Commented by Imane Tsioucha // 19/07/2024 // Field Cleaning
/*
    @future(callout=true)
    public static void cbbAmountBUD_Process(Set<Id> caseIds){
        ApiConnection con = new ApiConnection();
        List<Case> casesToUpdate = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();

        List<Case> caseList = DM002_Case.getListByIds(caseIds);
        for (Case caseObj : caseList) {
            //#CH01 Start
            String regionName = caseObj.Region_Flag__c;
            if(caseObj.Case_Model__c == 'alburaq'){
                regionName += '_alburaq';
            }
            //#CH01 END
            if(caseObj.Sub_Type__c == 'CBB Amount block'){
                if(caseObj.cc_Checker_Result__c == 'Accept'){  
                    HttpRequest request = con.createRequest('POST','/api/v1/customer-products/amount-block', regionName);//#CH01 : add "regionName"
                    HttpResponse blockAmountResp = SM001_ApiCalls.callBlockAmountApi( request, caseObj );
                    System.debug('START -- *********************************************');
                    System.debug(blockAmountResp.getStatusCode());
                    System.debug(blockAmountResp);
                    if (blockAmountResp.getStatusCode() != 200){
                        System.debug('The status code returned when calling block amount api was not expected: ' + blockAmountResp.getStatusCode() + ' ' + blockAmountResp.getStatus());
                        lstSA.add(setSystemAction( request.getBody(),blockAmountResp.getBody(),request.getEndpoint(),request.getMethod(),
                                                caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,blockAmountResp.getStatusCode(), 
                                                'CBB Amount block when Calling block amount Api', 'CBB Amount block/unblock request'
                                                ));
                    }else{
                        List<String> blockingDetails = new List<String>();
                        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(blockAmountResp.getBody());// meta, data
                        Map<String, Object> dataResp = (Map<String, Object>)m.get('data');
                        System.debug('dataResp ***********************************************************');
                        System.debug(dataResp);
                        if( dataResp.get('accounts') != null ){
                            List<Object> accountList = (List<Object>)dataResp.get('accounts'); 
                            for(Object acountInfos : accountList){
                                Map<String,Object> mapacountInfos = (Map<String, Object>)acountInfos;
                                System.debug('formatDetail **************************');
                                blockingDetails.add(formatDetailBlock(dataResp,mapacountInfos));
                            }
                        }
                        caseObj.Status = 'Closed';
                        caseObj.Sub_Status__c = 'Processed';
                        caseObj.cbb_ActualBlockedAmountB__c = (Decimal)dataResp.get('blockedAmount');
                        caseObj.cbb_RemainingBlockedAmountB__c = (Decimal)dataResp.get('reminaingAmount');
                        caseObj.cbb_BlockStatusB__c = (String)dataResp.get('blockStatus');
                              
                        if(blockingDetails.size()>0){
                            caseObj.cbb_BlockingDetailsB__c = String.join(blockingDetails,'\n');
                        }

                        casesToUpdate.add(caseObj);
                    }
                }else if(caseObj.cc_Checker_Result__c == 'Reject'){
                    caseObj.Status = 'Closed';
                    caseObj.Sub_Status__c = 'Declined';
                    casesToUpdate.add(caseObj);
                }
            }
            else if(caseObj.Sub_Type__c == 'CBB Amount unblock'){
                if(caseObj.cc_Checker_Result__c == 'Accept'){  
                    HttpRequest request = con.createRequest('DELETE','/api/v1/customer-products/amount-block/'+caseObj.cbb_BlockIdU__c, regionName);//#CH01 : add "regionName"
                  //  HttpResponse unblockAmountResp = SM001_ApiCalls.callUnblockAmountApi( request, caseObj );
                    
                    if (unblockAmountResp.getStatusCode() != 200){
                        System.debug('The status code returned when calling unblock amount api was not expected: ' + unblockAmountResp.getStatusCode() + ' ' + unblockAmountResp.getStatus());
                        lstSA.add(setSystemAction( request.getBody(),unblockAmountResp.getBody(),request.getEndpoint(),request.getMethod(),
                                                caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,unblockAmountResp.getStatusCode(), 
                                                'CBB Amount unblock when Calling unblock amount Api', 'CBB Amount block/unblock request'
                                                ));
                    }else{
                        List<String> unblockingDetails = new List<String>();
                        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(unblockAmountResp.getBody());// meta, data
                        Map<String, Object> dataResp = (Map<String, Object>)m.get('data');
                        List<Object> accountList = (List<Object>)dataResp.get('accounts'); 
                        for(Object acountInfos : accountList){
                            Map<String,Object> mapacountInfos = (Map<String, Object>)acountInfos;
                            unblockingDetails.add(formatDetailBlock(dataResp,mapacountInfos));
                        }

                        caseObj.Status = 'Closed';
                        caseObj.Sub_Status__c = 'Processed';
                        caseObj.cbb_UnblockStatusU__c = (String)dataResp.get('blockStatus');
                        //caseObj.cbb_UnblockStatusU__c = 'BLOCK_RELEASED';
    
                        if(unblockingDetails.size()>0){
                            caseObj.cbb_UnblockDetailsU__c = String.join(unblockingDetails,'\n');
                        }

                        casesToUpdate.add(caseObj);
                    }
                }else if(caseObj.cc_Checker_Result__c == 'Reject'){
                    caseObj.Status = 'Closed';
                    caseObj.Sub_Status__c = 'Declined';
                    casesToUpdate.add(caseObj);
                }
            }
        }

        if(lstSA.size()>0){
            insert lstSA;
        }
        if(casesToUpdate.size()>0){
            update casesToUpdate;
        }
    }*/

    public static String formatDetailBlock(Map<String,Object> dataResp,Map<String,Object> mapacountInfos){
        String currentCurrency = (String) ((Map<String, Object>)dataResp.get('currency')).get('code');
        String iban = (String) mapacountInfos.get('iban');
        String accHoldAmount = String.valueOf(mapacountInfos.get('holdAmount'));
        String accHoldAmountInAccCurrency = String.valueOf(mapacountInfos.get('holdAmountInAccountCurrency'));
        System.debug('accHoldAmountInAccCurrency+++++++++++++++++++++++++++++++++++');
        System.debug(mapacountInfos);
        System.debug(accHoldAmountInAccCurrency);
        String currencyAccount = (String) ((Map<String, Object>)mapacountInfos.get('currency')).get('code');
        String holdReferenceNumber = (String) mapacountInfos.get('holdReferenceNumber');
        Decimal blockedAmmount = (Decimal)dataResp.get('blockedAmount');
        Decimal rateStr = (Decimal) mapacountInfos.get('exchangeRate');
        return '"IBAN: '+iban+' - ' + currencyAccount + ' - '+currentCurrency + ' ' + accHoldAmount +' - '+currencyAccount+' '+ accHoldAmountInAccCurrency +' - Ref: '+holdReferenceNumber+' - Rate: '+rateStr +'"';
    }

    public static System_Action__c setSystemAction(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Final Integer statCode, Final String strAction, Final String strType) {
        System_Action__c action = new System_Action__c();
        action.Account_Number__c = custId;
        action.Action__c = strAction;
        //action.Card_Number__c = objCase.cc_Requested_Card_Type__c;
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
        
        return action; 
    }
}