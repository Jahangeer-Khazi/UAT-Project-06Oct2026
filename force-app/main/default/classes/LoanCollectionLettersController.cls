public class LoanCollectionLettersController {

    private static ApiConnection con = new ApiConnection();
     @AuraEnabled
    public static Id getCollectionLetterCaseRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
    }
    
      @AuraEnabled
    public static Id getCollectionLetterCaseQueue() {
        Id queueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Loan_Finance_Collection_Maker_Queue'].Id;
        return queueId;
    }

      @AuraEnabled(cacheable=false)
    public static String sendEmailWithPdf(ID caseId){
       
        Case cs = [SELECT Id,Status,AccountId,Letter_Type__c,ContactEmail,Sub_Status__c,cc_Contact_Centre_Result__c,cc_Contact_Centre_Date_Time__c,cc_Business_Approval_Result__c,cc_Business_Approval_Result_Date_Time__c,Case_Model__c FROM Case Where ID =:caseId];
        contact cd = [SELECT Id,Name,Email FROM contact WHERE AccountId =:cs.AccountId];
        System.debug('cs > '+ cs+ ' cd > '+cd);
        String responseMessage;
        string fileName;
        PageReference pdf;
        If(cs.Letter_Type__c=='Outstanding Balance')
        {
            pdf=Page.LoanNoLiabilityPDF;
            fileName='Outstanding Balance.pdf';
        }
       If(cs.Letter_Type__c=='No Liability')
        {
            pdf=Page.LoanLiabilityCancellationLetter;
            fileName='No Liability.pdf';
        }
        pdf.getParameters().put('accId', cs.AccountId);
        pdf.getParameters().put('csId', cs.Id);
        
        Blob b;
        if (Test.IsRunningTest()){
            b=Blob.valueOf('UNIT.TEST');
             
        }
        else{
           
            b = pdf.getContent();
        }

         EmailTemplate et;
        if(cs.Case_Model__c == 'alburaq'){
            et = [SELECT Id,Name FROM EmailTemplate WHERE DeveloperName ='No_liability_Letters_Alburaq'];
        }else{
            et = [SELECT Id,Name FROM EmailTemplate WHERE DeveloperName ='No_liability_Letters'];
        }
 
        OrgWideEmailAddress owe = [select Id from OrgWideEmailAddress where Address = 'support@ilabank.com'];
        system.debug('et--->'+et);
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(fileName);
        efa.setBody(b);
                        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setWhatId(cs.Id);
        email.setTemplateId(et.Id);
        email.setTargetObjectId(cd.Id);
        email.setOrgWideEmailAddressId(owe.Id);
        email.setToAddresses( new List<String>{cd.Email} );
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        try{
            Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            System.debug('result'+result);
            if(result[0].isSuccess()){
                responseMessage='Success';
                cs.Is_Hand_Off__c = true;
                update cs;
            }else{
                responseMessage='Email Not sent successfully';
            }
            
        }
        catch(System.Exception e){
            responseMessage='Error:'+e.getMessage();
            System.debug('result'+responseMessage);
        }
        return responseMessage; 
    }
   
    
    
     @AuraEnabled(cacheable=false)
    public static string downloadcasePdf(ID caseId){
        system.debug('reached');
        Case cs = [SELECT Id,Status,AccountId,Account.CIF__pc,Letter_Type__c,ContactEmail,Sub_Status__c,cc_Contact_Centre_Result__c,cc_Contact_Centre_Date_Time__c,cc_Business_Approval_Result__c,cc_Business_Approval_Result_Date_Time__c FROM Case Where ID =:caseId];
        contact cd = [SELECT Id,Name,Email,Account.CIF__pc FROM contact WHERE AccountId =:cs.AccountId];
        //getCardOptions(cs.AccountId);
        PageReference pdf;
        If(cs.Letter_Type__c=='Outstanding Balance')
            pdf=Page.LoanNoLiabilityPDF;
      If(cs.Letter_Type__c=='No Liability')
        {
            pdf=Page.LoanLiabilityCancellationLetter;
        } 
        pdf.getParameters().put('accId', cs.AccountId);
        pdf.getParameters().put('csId', cs.Id);
        
        Blob b;
     string newblobMessage;
        if (Test.IsRunningTest()){
            b=Blob.valueOf('UNIT.TEST');
        }
        else{
            system.debug('CaseId||'+CaseId);
            b = pdf.getContent();
            newblobMessage = EncodingUtil.base64Encode(b);
        }

 
      
        cs.Is_Hand_Off__c = true;
        update cs;
     
     
        return newblobMessage; 
    }
}