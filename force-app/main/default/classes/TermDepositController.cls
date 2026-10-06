/*     Organization : ABC Bank
 *     Created By: Jahangeer Mohammed
 *    Created Date:03-01-2022
 *     Change History: 
 *                       #CH01 : hamza chaoui 22/07/2022 -- add alburaq notification logic
 *       				 #CH03# #Jahangeer Mohammed #05-05-2024# Added logic for Audit History Enhancements(NBA-9027)
                         #CH04# #Jayanth Manickam #20-08-2024 PI-3509 Fix
						 #CH05# #Maksud Ali #07-01-2026 - FD Term Deposit, Button Added.
                         #CH06#: #Aitogram omar# #01-04-2026 Added logic for Dormancy Visibility Restrictions (NBA-11705)
 *        
*/
public class TermDepositController {
    private static ApiConnection con = new ApiConnection();
  private final static List<String> SENSITIVE_FIELDS_TERMDEPOSIT_DETAIL = new List<String>{
            'termDeposits.depositAmount',
            'termDeposits.currency',
            'termDeposits.interestRate',
            'termDeposits.earlyWithdraw.withdrawIntrestRate',
            'termDeposits.accroudInterest',
            'termDeposits.matruityAmount',
            'termDeposits.totalInterestEarned',
             'termDeposits.earlyWithdraw.withdrawFee'  
            //'termDeposits.earlyWithdraw.withdrawFee',
            //'termDeposits.earlyWithdraw.withdrawDate'
                
  };
    
  @AuraEnabled(cacheable=false)
     public static ApiConnection.Response termDepositList(final String customerId,String regionName){
        //String regionName = 'Bahrain';
        system.debug('Term Deposit Apex method:'+customerId);
          system.debug('regionName:'+regionName);
        final HttpRequest req = con.createRequest('GET', '/api/v1/term-deposit', customerId,regionName);
        system.debug('---> REQUEST --> '+req);
        		 //#CH02 : start

        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];

        if(accs!= null && accs.size()>0){

        System.debug('x-canary added :'+accs.get(0).x_canary__pc);

         if(accs.get(0).x_canary__pc != null){
             req.setHeader('x-canary', accs.get(0).x_canary__pc);
         }
        }
        //#CH02 : end
        req.setTimeout(120000);
        ApiConnection.Response response = new ApiConnection.Response();
        response = con.makeCallout(req);
        System.debug('Response in Apex class:' +JSON.serializePretty(response));
        return response; 
    }
     @AuraEnabled(cacheable=false)
     public static ApiConnection.Response termDepositMatrix(final String customerId,String regionName){
        //String regionName = 'Bahrain';
        system.debug('Tem Deposit Matrix Apex method:'+customerId);
        final HttpRequest req = con.createRequest('GET', '/api/v1/term-deposit/term-deposit-matrix', customerId, regionName);
        system.debug('---> REQUEST --> '+req);
        //req.setHeader('customerId', customerId);
		 //#CH02 : start

        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];

        if(accs!= null && accs.size()>0){
        System.debug('x-canary added :'+accs.get(0).x_canary__pc);

         if(accs.get(0).x_canary__pc != null){

             req.setHeader('x-canary', accs.get(0).x_canary__pc);
         }
        }

        //#CH02 : end
        req.setTimeout(120000);
        ApiConnection.Response response = new ApiConnection.Response();
        response = con.makeCallout(req);
        System.debug('Response in Apex class:' +JSON.serializePretty(response));
        return response; 
    }
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response termDepositDetails(final String customerId, final String urbisContractId, String regionName) {
        //String regionName = 'Bahrain';
        //final HttpRequest req = con.createRequest('GET', '/api/v1/term-deposit/'+urbisContractId+'/details', customerId);
        final HttpRequest req = con.createRequest('GET', '/api/v1/term-deposit/'+urbisContractId, customerId,regionName);

        req.setTimeout(120000);  
		 //#CH02 : start

         system.debug('---> REQUEST IN CIF__pc --> '+customerId);

        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];

        if(accs!= null && accs.size()>0){
        System.debug('x-canary added :'+accs.get(0).x_canary__pc);
         if(accs.get(0).x_canary__pc != null){

             req.setHeader('x-canary', accs.get(0).x_canary__pc);
         }
       }

        //#CH02 : end 
        system.debug('---> REQUEST IN TERM DEPOSIT DETAIL --> '+req);
        final ApiConnection.Response response = con.makeCallout(req);
        system.debug('---> RESPONSE IN TERM DEPOSIT DETAIL --> '+JSON.serializePretty(response)); 
         if(response.isSuccess && null != response.responseData){
            final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
             System.debug('Before Sensitive Data Cleaner');
             if(CreditCard_SensitiveDataCleaner.loadIsDataCleaningRequired(customerId)){
                system.debug('SENSITIVE_FIELDS_TERM_DEPOSIT||'+SENSITIVE_FIELDS_TERMDEPOSIT_DETAIL);
                CreditCard_SensitiveDataCleaner.removeSensitiveData(responseData, SENSITIVE_FIELDS_TERMDEPOSIT_DETAIL); 
            }
        }
        return response;
    }
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response downloadTermDeposit(final String customerId, final String urbisContractId,String regionName){
        //String regionName = 'Bahrain';
        final HttpRequest req = con.createRequest('POST', '/api/v1/term-deposit/download', customerId,regionName);
         //#CH02 : start
         system.debug('---> REQUEST IN CIF__pc --> '+customerId);
         List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
            if(accs!= null && accs.size()>0){
            System.debug('x-canary added :'+accs.get(0).x_canary__pc);
             if(accs.get(0).x_canary__pc != null){
    
                 req.setHeader('x-canary', accs.get(0).x_canary__pc);
             }
           }
        //#CH02 : end 
        req.setBody('{"urbisContractId": "'+urbisContractId+'","fileOutputType":"file"}');
        req.setTimeout(120000); 
        system.debug('---> REQUEST IN TERM DEPOSIT DOWNLOAD  --> '+req.getBody());
        final ApiConnection.Response response = con.makeCallout(req);
        system.debug('---> RESPONSE IN TERM DEPOSIT DOWNLOAD --> '+response);
        return response;
    }
    @auraEnabled
    public static String sendEmailWithTermDepositPdf(String conEmail, String file ){
        String responseMessage;
        System.debug('Encoding Base64 String Value from API :'+file);
        Blob b;
        b = Blob.valueOf(file);
        System.debug('Blob Size:'+b.size());
        Blob myBlob = EncodingUtil.base64Decode(file);
        System.debug('Blob Size:'+myBlob.size());
        
       /* String decodedString = myBlob.toString();
        System.debug('Decoded String :'+decodedString);*/
        System.debug('Email:'+conEmail);
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('Term Deposit.pdf');
        efa.setContentType('application/pdf');
        efa.setBody(myBlob);
        OrgWideEmailAddress owe;
       
       // OrgWideEmailAddress owe = [select Id from OrgWideEmailAddress where Address = 'support@ilabank.com'];
         //#CH01 : Start
		 //#CH04 : Start
         EmailTemplate et;
         contact cd = [SELECT Id,Name,Email,Subscription_Model__c,Region_Flag__c FROM contact WHERE Email =:conEmail LIMIT 1];
	    if(cd !=null && cd.Region_Flag__c =='Bahrain'){
		    owe = [select Id from OrgWideEmailAddress where Address = 'support@ilabank.com' LIMIT 1];
			 if( cd != null && cd.Subscription_Model__c == 'alburaq' ){
				 et = [SELECT Id,Name FROM EmailTemplate WHERE Name ='TermDepositReceiptDetailsAlburaq' LIMIT 1];
			 }else{
				 et = [SELECT Id,Name FROM EmailTemplate WHERE Name ='TermDepositReceiptDetails' LIMIT 1];
			 }
		}else if(cd != null && cd.Region_Flag__c =='Jordan' ){
		     owe = [select Id from OrgWideEmailAddress where Address = 'support@ilajordan.com' LIMIT 1];
             et = [SELECT Id,Name FROM EmailTemplate WHERE Name ='TermDepositReceiptDetailsJo' LIMIT 1];
        }
		 //#CH04 : END
         //#CH01 End
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(et.Id);
        email.setTargetObjectId(cd.Id);
        email.setOrgWideEmailAddressId(owe.Id);
        email.setToAddresses( new List<String>{conEmail} );
        //email.setPlainTextBody('Test Message');
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

        try{
            Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            System.debug('result'+result);
            if(result[0].isSuccess()){
                 responseMessage='Success';
            }else{
                 responseMessage='Email Not sent successfully';
            }

        }
        catch(System.Exception e){
            responseMessage='Error:'+e.getMessage();
        }
        return responseMessage;
         //return null;
    }
    @auraEnabled
    public static string updateCaseStatus(String recId, String file){
        String response;
        System.debug('Encoding Base64 String Value from API in updateCaseStatus method :'+file);
        Blob b;
        b = Blob.valueOf(file);
        System.debug('Blob Size in updateCaseStatus method:'+b.size());
        Blob myBlob = EncodingUtil.base64Decode(file);
        System.debug('Blob Size updateCaseStatus method:'+myBlob.size());
        try
        {
            case cs=[Select id,Status from case where Id=:recId];
            Attachment attachPDF = new Attachment();
            attachPDF.body = myBlob;
            attachPDF.Name = 'Term Deposit.pdf';
            attachPDF.ParentId = cs.id;
            insert attachPDF;
            cs.Case_Nature__c='Account Maintenance';
            cs.Status='Closed';
            update cs;
            
            response='Success';
        }
        catch(system.Exception e){
            response='Error:' +e.getMessage();
        }
        return response;
    }
     @auraEnabled
    public static string fetchCaseStatus(String recId){
        String caseStatus;
        try
        {
            case cs=[Select id,Status from case where Id=:recId];
            caseStatus=cs.Status;
            
        }
        catch(system.Exception e){
            caseStatus='Error:' +e.getMessage();
        }
        return caseStatus;
    }
    //CH03: Start
    @AuraEnabled
    public static String createAuditRecordForTermDepositDetails(String accCIF, String termDepositId, Boolean isAlburaqProduct){
        
        System.debug('Account CIF:'+accCIF);
        System.debug('Term Deposit Id:'+termDepositId);
        
        Customer_Pages_Audit_Trail__c cusAudit = new Customer_Pages_Audit_Trail__c();
        cusAudit.Customer_CIF__c = accCIF;
        cusAudit.User_Action__c = 'Viewed';
        cusAudit.User__c = userInfo.getUserId();
        
        if(isAlburaqProduct == false){
            cusAudit.Page_Name__c = 'Fixed Deposit Detail';
        }
        else if(isAlburaqProduct == true){
            cusAudit.Page_Name__c = 'Wakala Detail';
        }
        cusAudit.Contract_Number__c = termDepositId;
        insert cusAudit;
        
        return cusAudit.id;
    }
    //CH03: END
    //UATNB-133425 Fix
    
      @auraEnabled
    Public static string closedCaseStatus(String recId){
        String response;
        try
        {
            case cs=[Select id,Status from case where Id=:recId];
            cs.Status='Closed';
            update cs;
            response='Success';
        }
        catch(system.Exception e){
            response='Error:' +e.getMessage();
        }
        return response;
    }
    
    //CH05 - START
    @AuraEnabled(cacheable=false)
    public static Boolean canUserViewFDButton(String regionFlag,String segment){
        User loggedInUser = [Select Id, Can_View_FD_Term_Deposit__c FROM User WHERE ID =: UserInfo.getUserId()];
        
        if(!loggedInUser.Can_View_FD_Term_Deposit__c){
            return false;
        }
        
        //if customer is not staff then following logic would bypass
        if(!segment.equalsIgnoreCase('staff')){
            return true;
        }
        
        List<String> ownerIds = new List<String>();
        ownerIds.add(UserInfo.getUserId());
        ownerIds.add(UserInfo.getProfileId());
        ownerIds.add(UserInfo.getOrganizationId());
        List<Setting__c> settings = [Select SetupOwnerId,View_Staff_Data__c,View_Staff_Data_Jordan__c 
                                     FROM Setting__c 
                                     WHERE SetupOwnerId IN :ownerIds];
        
        System.debug('308 settings ' + settings);
        
        Boolean canViewStaffData = false;
        for(Setting__c setting : settings){
            
            System.debug('308 regionFlag ' + regionFlag);
            canViewStaffData = regionFlag.equalsIgnoreCase('bahrain') ? setting.View_Staff_Data__c : setting.View_Staff_Data_Jordan__c;
            System.debug('308 canViewStaffData ' + canViewStaffData);
            //if canViewStaffData is true, that means user can access staff data.
            if(canViewStaffData){
                break;
            }
        }
        
        return canViewStaffData;
    }
    //CH05 - END

    // CH06 start     
    @AuraEnabled
    public static Boolean getJordanVisibility(String customerId) {
        return CreditCard_SensitiveDataCleaner.loadIsDataCleaningRequired(customerId);
    }
    // CH06 end  
}