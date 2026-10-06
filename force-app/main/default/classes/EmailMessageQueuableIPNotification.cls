/*     Organization  : ABC Bank
 *     Created By    : Jahangeer Mohammed
 *     Created Date  : 07/03/2022
 *     Description   : This Queuable is used to send Email to infosec user whenever any user is logged in with different IP Notification.
 *     Test Class    : 
 *     Change History: 
 *         
 */
global class EmailMessageQueuableIPNotification implements Queueable {
    private LoginEvent logEvent;

    public EmailMessageQueuableIPNotification(LoginEvent logEvent) {
        this.logEvent = logEvent;
    }

    public void execute(QueueableContext context) {
        String responseMessage = '';
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('Inside Queuable Context Method');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> emailList = System.Label.EVENT_MONITORING_USERS.split(',');

        mail.setToAddresses(emailList);
        mail.setSubject(System.Label.LOGGED_IN_IP_SUBJECT);
        mail.setSaveAsActivity(false);
        //mail.setTargetObjectId(System.Label.InfosecUser);
        System.debug('User Id:'+logEvent.UserId);
        try{
            String loggedInUserIdUrl = sfdcBaseURL + '/' + logEvent.UserId;
            String loggedInUserIdUrlWithAnchorTag = '<a href="'+ loggedInUserIdUrl +'"> Click here </a>';
            String body =  '<u>Following are the details of the user logged in from different IP</u>:'+'<br><br>';
            body +='User Name : '+logEvent.Username + '<br><br>';
            body +='Source IP : '+logEvent.SourceIp + '<br><br>';
            body +='Browser Name : '+logEvent.Browser + '<br><br>';
            body +='Platform : '+logEvent.Platform+ '<br><br>';
            body +='Country : '+logEvent.Country+ '<br><br>';
            body +='City : '+logEvent.City+ '<br><br>';
            body +='UserId URL : '+loggedInUserIdUrlWithAnchorTag+ '<br><br>';
            body +='<br>';
            body +='System Generated Email';
            mail.setHtmlBody(body);
            mail.setOrgWideEmailAddressId(System.Label.ORG_Wide_Email_Address);
            Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            System.debug('result'+result);
            if(result[0].isSuccess()){
                responseMessage='Email sent successfully';
            }else{
                responseMessage='Email Not sent successfully';
            }
            
        }
        catch(System.Exception e){
            responseMessage='Error:'+e.getMessage();
            System.debug('Exception Message:'+responseMessage);
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        
    }
  

}