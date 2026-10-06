/*     
 *     Change History: 
 *          #CH01 : hamza chaoui 22/07/2022 -- add alburaq notification logic
 *        
*/
public class EmailAlertonAccount {

    @InvocableMethod(label='Get Account' description='Send an email' category='Account')
  public static void sendEmailToCustomer(lIST<iD> customerId)
  {
      string responseMessage;
    //#CH01 Start
    List<Contact> acc = [select Id,Email,Subscription_Model__c from Contact where AccountId IN:customerId Limit 1]; 
    OrgWideEmailAddress owe = [select Id from OrgWideEmailAddress where Address = 'support@ilabank.com'];
    EmailTemplate et;
    if(acc != null && acc.size()>0 && acc.get(0).Subscription_Model__c == 'alburaq' ){
        et = [SELECT Id,Name FROM EmailTemplate WHERE Name ='PLA Flag Enabled - REMINDER Alburaq'];
      }else{
          et = [SELECT Id,Name FROM EmailTemplate WHERE Name ='PLA Flag Enabled - REMINDER'];
      }
    
    //#CH01 End

      
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(et.Id);
        email.setTargetObjectId(acc[0].Id);
        email.setOrgWideEmailAddressId(owe.Id);
        email.setToAddresses( new List<String>{acc[0].Email} );
        Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        System.debug('result||'+result);
        if(result[0].isSuccess()){
            responseMessage='Success';
        }else{
            responseMessage='Email Not sent successfully';
        }
  }
   
}