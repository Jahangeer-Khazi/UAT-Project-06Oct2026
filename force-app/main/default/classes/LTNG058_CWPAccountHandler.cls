/**
 *  @author: Jayanth Manickam
 *  @date: 2025-02-24  
 *  @description:
 *      Canceled Work Permit Case to Block/Unblock Accounts"
 *
 *      
 */

public class LTNG058_CWPAccountHandler {
    
    @InvocableMethod(label='CWP Block/Unblock Account Api' description='The purpose of this service is to block accounts' callout=true )
    public static  List<String>  blockunblockAccountApiFromFlow(List<String> reqBlockUnblockAcc)
    {       
        AccountHandlerApi(reqBlockUnblockAcc);       
        return null;       
    }
    @future(callout=true)
    public static void AccountHandlerApi(List<String> CWPIds)
    {
        System.debug('unblockAccountApi*****************************');
        System.debug(CWPIds);
        List<System_Action__c> lstSA = new List<System_Action__c>();
        Canceled_WP__c caseOb = [SELECT Id, Name, Case__c, Action__c, Prior_Status__c, Status__c, Customer_CIF__c, Customer__c FROM Canceled_WP__c WHERE Id = :CWPIds LIMIT 1];
        List<Account> accs = [SELECT Id,x_canary__pc,Region_Flag__pc,subscription_Model__pc FROM Account WHERE id=:caseOb.Customer__c LIMIT 1];
        List<String>SubModels=New List <String>();
        String regionName = accs[0].Region_Flag__pc;//CH03
        if(accs[0].subscription_Model__pc == 'alburaq'){
            SubModels.add('alburaq');
            // regionName += '_alburaq';
            
        }else if(accs[0].subscription_Model__pc == 'ila'){
            SubModels.add('ila');
        }else if(accs[0].subscription_Model__pc == 'both'){
            SubModels.add('ila');
            SubModels.add('alburaq');
        }
        //toDo : use api uncomment this part
        ApiConnection con = new ApiConnection();
        for(String smodels:SubModels){
            if(smodels=='alburaq') {
                regionName += '_alburaq';
            }          
            HttpRequest request = con.createRequest('POST','/api/v1/customer-products/restriction',regionName);//CH03
            //#CH02 : start
            
            if(accs!= null && accs.size()>0){
                System.debug('x-canary added :'+accs.get(0).x_canary__pc);
                if(accs.get(0).x_canary__pc != null){
                    request.setHeader('x-canary', accs.get(0).x_canary__pc);
                }
            }
            //#CH02 : end
            String Status=(caseOb.Status__c=='COMPLETED' ||caseOb.Status__c=='RP_PENDING'||caseOb.Status__c=='IDV_PENDING')?'UNBLOCK':(caseOb.Status__c=='COMPLETED_FRAUD'||caseOb.Status__c=='RP_BLOCK'||caseOb.Status__c=='IDV_BLOCK_REVIEW'?'BLOCK':'');
            String restrictlevel =caseOb.Status__c=='COMPLETED_FRAUD'?'block_idv':(caseOb.Status__c=='IDV_BLOCK_REVIEW'?'restrict_idv':'restrict_upload');
                String type='ALL';
            request.setHeader('customerId', caseOb.Customer_CIF__c);
            String body;
            if(Status=='BLOCK'){
                 System.debug('Request'+request);
            body =  '{  "action":'+stringApiFormat(Status)+
                ',"type": '+stringApiFormat(type)+
               ',"status": '+stringApiFormat(restrictlevel)+
                '}'; 
            }else{
                  body =  '{  "action":'+stringApiFormat(Status)+
                ',"type": '+stringApiFormat(type)+
                '}'; 
            }
          
            request.setBody(body);
            System.debug(request.getBody());
            
            HttpResponse response = EM001_ApiCalls.blockUnblockAccountApi(request,200);
            Map<String, Object> deserialized = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            Map<String, Object>  validatecode = (Map<String, Object>) deserialized.get('meta');
            system.debug('deserialized'+deserialized);
            system.debug('m3'+validatecode.get('code'));
            if (response.getStatusCode() != 200 || (validatecode.get('code') !='ACCO-1011' && response.getStatusCode()== 200)) {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'POST',caseOb.Case__c,caseOb.Customer_CIF__c,caseOb.Customer__c,response.getStatusCode(), 'Cancelled Work Permit Request', 'Cancelled Work Permit Request');
            }
            
            else{
            }  
        }
    }
    public static String stringApiFormat(String input){
        if(input != null){
            return '"'+ input +'"';
        }else{
            return 'null';
        }
    }
    
     public static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Integer statCode, Final String strAction, Final String strType) {
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