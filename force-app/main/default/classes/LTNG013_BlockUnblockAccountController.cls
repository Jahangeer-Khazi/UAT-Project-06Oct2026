/**
* @author Wissal benqezza
* @date Création 15/03/2022
* @date Modification
* @description :
*      Change History :
*         #CH01 : #D&A Team  Added alburaq logic.
*         #CH02 : #Imane Tsioucha# #15-01-2024# add x-canary header
*         #CH03 : #Imane Tsioucha# #18-03-2024# add Jordan Logic
*         #CH04 : #Jayanth Manickam# #13-01-2025# add Unblock checker Restriction

*/
public class LTNG013_BlockUnblockAccountController {
    private static String CLASS_NAME = LTNG013_BlockUnblockAccountController.class.getName();
    
    @AuraEnabled
    public static Id getAccRequestCaseRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Block_Unblock_Account').getRecordTypeId();
    }
    /* @AuraEnabled
public static Id getAccRequestCaseRecordType_Jordan() {
return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('JO_Block_Unblock_Account').getRecordTypeId();
}*/
    
    @AuraEnabled
    public static List<AccountToBlockUnblockDetails> getAccountToBlockUnblockViaApi(String accountId,String caseModel) {
        
        PAD.debugLogBegin(CLASS_NAME, 'getAccountToBlockUnblockViaApi', 'Parameters : [accountId] : '+accountId+' , '+caseModel );//CH01
        
        List<AccountToBlockUnblockDetails> accToBlockUnblock = new List<AccountToBlockUnblockDetails>();
        if(accountId != null && accountId != '' ){
            Account accObj = [SELECT Id, CIF__pc,PersonEmail,Region_Flag__c FROM Account WHERE Id=: accountId];
            
            //#CH01 Start
            String regionName = accObj.Region_Flag__c;//CH03
            if(caseModel == 'alburaq'){
                regionName += '_alburaq';
            }
            //#CH01 End
            ApiConnection con = new ApiConnection();
            HttpRequest request = con.createRequest('GET','/api/v1/accounts/all',regionName);//CH03
            
            //#CH02 : start
            List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE Id=: accountId];
            if(accs!= null && accs.size()>0){
                System.debug('x-canary added :'+accs.get(0).x_canary__pc);
                if(accs.get(0).x_canary__pc != null){
                    request.setHeader('x-canary', accs.get(0).x_canary__pc);
                }
            }
            //#CH02 : end
            
            System.debug('request==>'+Request.getEndpoint());
            //toDo : use api 
            HttpResponse response = SM001_ApiCalls.getAccountsListAllApi(request,accObj);         
            
            if (response.getStatusCode() != 200 ) {
                String errorMsg = 'The status code returned was not expected when we are calling Get Account List API : ' + response.getStatusCode();
                System.debug(errorMsg);
                throw new AuraHandledException(errorMsg);
            }else {
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                List<Object> accountList = (List<Object>)m1.get('accounts'); 
                for(Object accountDetails : accountList){
                    Map<String,Object> mapaccountConfig = (Map<String, Object>)accountDetails;
                    Map<String,Object> mapaccountDetails = (Map<String, Object>)mapaccountConfig.get('account');
                    String accCurrency = (String) ((Map<String, Object>)mapaccountDetails.get('currency')).get('code');
                    
                    accToBlockUnblock.add( new AccountToBlockUnblockDetails(
                        String.valueOf(mapaccountDetails.get('iban')) , 
                        accCurrency,
                        String.valueOf(mapaccountConfig.get('productName'))
                    ));
                }
            }
        }
        PAD.debugLogEnd(CLASS_NAME, 'getAccountToBlockUnblockViaApi', '[accToBlockUnblock] : ' + accToBlockUnblock );
        
        return accToBlockUnblock;
    }
    //CH04 -START
    @AuraEnabled
    public static String UpdateApproverProfile(String accountId,String caseModel, String UnblockAccount) {
        String blockProfile='ila Risk';
        System.debug('accountId'+accountId);
        System.debug('caseModel'+caseModel);
        System.debug('UnblockAccount'+UnblockAccount);
        List<String>UbAccount= UnblockAccount.split(','); 
        Map<String,List<String>>BlockedAccounts=New Map<String,List<String>>();
        for(Case BlockCase:[SELECT Id,cbb_UnblockStatusU__c,Type,CreatedDate,BUA_AccountsInformation__c,cbb_BlockStatusB__c FROM Case WHERE AccountId=:accountId and (Type='Block Account' OR (Type='Account' AND Sub_type__c IN ('Block for debit','Block for credit','Block for both'))) and Case_Model__c=:caseModel and cbb_BlockStatusB__c!='' Order by CreatedDate asc]){
            if(!BlockedAccounts.containsKey(BlockCase.cbb_BlockStatusB__c)){
                List<String> Bacc = String.valueOf(BlockCase.BUA_AccountsInformation__c).split(',');
                BlockedAccounts.put(BlockCase.cbb_BlockStatusB__c,Bacc);
            }else{
                List<String> Bacc =BlockedAccounts.get(BlockCase.cbb_BlockStatusB__c);
                Bacc.addAll( String.valueOf(BlockCase.BUA_AccountsInformation__c).split(','));
                BlockedAccounts.Put(BlockCase.cbb_BlockStatusB__c,Bacc);
            }
        }
        System.debug('BlockedAccounts'+BlockedAccounts);
        for(String bp:BlockedAccounts.keySet()){
            if(bp=='ila Risk' || bp=='ila Fraud' ){
                blockProfile=bp;
                break;
            }else{
                for(String bacc:BlockedAccounts.get(bp)){
                    System.debug('bacc'+bacc);
                    if(UbAccount.contains(bacc)){                     
                        blockProfile=bp;   
                    }
                }
            }
            //BlockedAccounts =String.valueOf(BlockCase.BUA_AccountsInformation__c).split(',');
        } 
        system.debug(blockProfile);
        return blockProfile;
    }
    //CH04 -END
    
    @InvocableMethod(label='Block/Unblock Account Api' description='The purpose of this service is to block accounts' callout=true )
    public static  List<String>  blockunblockAccountApiFromFlow(List<RequestBlockUnblockAcc> reqBlockUnblockAcc)
    {
        Set<Id> caseIds= new Set<Id>();
        String statusType = reqBlockUnblockAcc.get(0).statusType;
        for(RequestBlockUnblockAcc req : reqBlockUnblockAcc){
            caseIds.add(req.caseId);
        }
        
        blockUnblockAccountApi(caseIds,statusType);
        
        return null;
        
    }
    
    //CH04 -START
    @future(callout=true)
    public static void blockUnblockAccountApi(Set<Id> caseIds,String updatedStatus)
    {
        System.debug('unblockAccountApi*****************************');
        System.debug(caseIds);
        Id blockActionProfileId;
        Boolean UnBlockCompleted=False;
        Boolean Processrequest=False;
        User u= [Select Id, Profile.Name from User where Id=:UserInfo.getUserId()];
        List<String>AuthUnblock = New List<String>();
        List<String>UnAuthUnblock = New List<String>();
        List<Case> cases = DM002_Case.getListByIds(caseIds);
        Case caseOb = [SELECT Id,accountId,Status,Customer_CIF__c,case_Model__c,BUA_AccountsInformation__c FROM Case WHERE Id = :caseIds LIMIT 1];
        List<String>UnblockAccount=String.valueOf(caseOb.BUA_AccountsInformation__c).split(',');
        Map<String,List<String>>BlockedAccounts=New Map<String,List<String>>();
        List<Case> unblockcases = New List<Case>();
        System.debug('UnblockAccount##IS'+UnblockAccount);
        List<System_Action__c> lst = new List<System_Action__c>();
        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE id=:caseOb.accountId LIMIT 1];
        if((updatedStatus=='UNBLOCK') && (u.Profile.Name!='ila Risk' && u.Profile.Name!='ila Fraud' && u.Profile.Name!='System Administrator' && u.Profile.Name!='Restricted System Admin')){
            List<String> profileName=New List<String>();
            if(u.Profile.Name=='RMT'){
                System.debug('inside Profile.Name##'+u.Profile.Name);
                profileName=New List<String>{'RMT','Contact Centre','Compliance'};
                    }else{
                        System.debug('inside else##'+u.Profile.Name);
                        profileName.add(u.Profile.Name);  
                    }
            //List<String>BlockedAccounts=New List<String>();
            for(Case BlockCase:[SELECT Id,cbb_BlockStatusB__c,Type,CreatedDate,BUA_AccountsInformation__c FROM Case WHERE cbb_BlockStatusB__c IN:profileName and AccountId=:caseOb.accountId and (Type='Block Account' OR (Type='Account' AND Sub_type__c IN ('Block for debit','Block for credit','Block for both'))) and Case_Model__c=:caseOb.Case_Model__c Order by CreatedDate Desc]){
                if(!BlockedAccounts.containsKey(BlockCase.id)){
                    List<String> Bacc = String.valueOf(BlockCase.BUA_AccountsInformation__c).split(',');
                    BlockedAccounts.put(BlockCase.id,Bacc);
                }else{
                    List<String> Bacc =BlockedAccounts.get(BlockCase.id);
                    Bacc.addAll( String.valueOf(BlockCase.BUA_AccountsInformation__c).split(','));
                    BlockedAccounts.Put(BlockCase.id,Bacc);
                }
                //  BlockedAccounts =String.valueOf(BlockCase.BUA_AccountsInformation__c).split(',');
            } 
            System.debug('##BlockedAccounts##'+BlockedAccounts);
            
            for(String ub:unblockAccount){
                List<String>tempauth=New List<String>();
                List<String>tempunauth=New List<String>();
                for(String bcid:BlockedAccounts.keySet()){
                    if(BlockedAccounts.get(bcid).contains(ub)){
                        AuthUnblock.add(ub);
                        tempauth.add(ub);
                    }else{
                        tempunauth.add(ub);
                    }
                }
                if(tempauth.isEmpty()){
                    UnAuthUnblock.addAll(tempunauth);
                }
            }
            
            if(!BlockedAccounts.isEmpty()){
                System.debug('getProfileId###'+UserInfo.getProfileId());
                System.debug('AuthUnblock'+AuthUnblock);
                if(!UnAuthUnblock.isEmpty()){
                    Processrequest=false;
                    
                }else{
                    Processrequest=true;
                }
            }
        }else{
            Processrequest=true;
        }
        if(Processrequest){
            for(Case caseObj : cases){
                String regionName = caseObj.Account.Region_Flag__pc;//CH03
                if(caseObj.case_Model__c == 'alburaq'){
                    regionName += '_alburaq';
                }
                //toDo : use api uncomment this part
                ApiConnection con = new ApiConnection();
                HttpRequest request = con.createRequest('PUT','/api/v1/accounts/block-unblock',regionName);//CH03
                //#CH02 : start
                
                if(accs!= null && accs.size()>0){
                    System.debug('x-canary added :'+accs.get(0).x_canary__pc);
                    if(accs.get(0).x_canary__pc != null){
                        request.setHeader('x-canary', accs.get(0).x_canary__pc);
                    }
                }
                //#CH02 : end
                
                System.debug('Request'+request);
                HttpResponse response = SM001_ApiCalls.blockUnblockAccountApi(request,caseObj,updatedStatus);
                System.debug('response'+response);             
                System.debug('Body###'+response.getBody());
                Map<String, Object> deserialized = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                Map<String, Object>  validatecode = (Map<String, Object>) deserialized.get('meta');
                system.debug('deserialized'+deserialized);
                system.debug('m3'+validatecode.get('code'));
                if (response.getStatusCode() != 200 || (validatecode.get('code') !='ACCO-1011' && response.getStatusCode()== 200)) {
                    
                    System_Action__c actionRecord = SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                                                   request.getEndpoint() ,request.getMethod(),
                                                                                   caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                                                   'Block/Unblock Accounts API', updatedStatus
                                                                                  );
                    lst.add(actionRecord);
                }
                
                else{
                    System.debug(' == 200');
                    caseObj.Status = 'Closed';
                    caseObj.Sub_Status__c = 'Approved';//CH03
                    caseObj.BUA_UpdateStatusForAllAccounts__c =true;
                    if(updatedStatus == 'UNBLOCK'){
                        caseObj.cc_Checker_Result_Date_Time__c =DateTime.now();
                        UnBlockCompleted=True;
                    }else{
                        //caseObj.cbb_BlockStatusB__c=(u.Profile.Name=='Contact Centre')?'RMT':u.Profile.Name;
                        caseObj.cbb_BlockStatusB__c=u.Profile.Name;
                        caseObj.cc_Maker_Result_Date_Time__c =DateTime.now();
                    }
                }  
            }
        }else{
            System_Action__c actionRecord = SM001_ApiCalls.setSystemAction( 'Block/Unblock Accounts','Block/Unblock Accounts',
                                                                           'Unauthorized to unblock Account Only the Account blocker are allowed to unblock Account' ,'Unauthorized to unblock Account Only the Account blocker are allowed to unblock Account',
                                                                           caseOb.id,caseOb.Customer_CIF__c,caseOb.accountId,400, 
                                                                           'Block/Unblock Accounts API', updatedStatus
                                                                          );
            lst.add(actionRecord);
        }
        if(cases != null && cases.size()>0){
            update cases;
        }
        if(lst != null && lst.size()>0){
            insert lst;
        }
        if(UnBlockCompleted){
            for(Case Blc:[Select Id,cbb_BlockStatusB__c from case where Id in:BlockedAccounts.keySet()]){
                Blc.cbb_BlockStatusB__c=Blc.cbb_BlockStatusB__c+'Unblocked';
                unblockcases.add(Blc);
            }
        }
        if(unblockcases != null && unblockcases.size()>0){
            update unblockcases;
        }
    }
    //CH04 -END
    
    /* //#CH03 Start
@AuraEnabled

public static String getRecordTypeIdByregionName(String recordId) {
String recordTypeId;
Account accObj = [SELECT Id, CIF__pc,Region_Flag__c FROM Account WHERE Id=: recordId];
if(accObj.Region_Flag__c=='Bahrain'){
recordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Block_Unblock_Account').getRecordTypeId();

}else{
recordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('JO_Block_Unblock_Account').getRecordTypeId();

}
return recordTypeId;
}
//#CH03 END*/
    
    public class AccountToBlockUnblockDetails {
        @AuraEnabled 
        public String iban {get; set;}
        
        @AuraEnabled 
        public String ac_currency {get; set;}
        
        @AuraEnabled 
        public String ac_type {get; set;}
        
        @AuraEnabled 
        public String ac_label {get; set;}
        
        public AccountToBlockUnblockDetails(String iban,String ac_currency,String ac_type){
            this.iban = iban;
            this.ac_currency = ac_currency;
            this.ac_type = ac_type;
            this.ac_label = iban +' - '+ ac_currency+' - '+ ac_type;
        }
    }
    
    public class RequestBlockUnblockAcc {
        @InvocableVariable(label='Case Id' description='the Id of the Case' required=true)
        public Id caseId;
        
        @InvocableVariable(label='Status Type' description='Status Type' required=true)
        public String statusType;
    }
    
    @AuraEnabled
    public static Boolean isFraudTeamUser() {
        Set<Id> fraudProfiles = new Set<Id>{
            [SELECT Id FROM Profile WHERE Name IN ('ila Risk')].Id
                };
                    return fraudProfiles.contains(UserInfo.getProfileId());
    }
}