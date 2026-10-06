/*     Organization  : ABC Bank
 *     Created By    : Jahangeer Mohammed
 *    Created Date  : 22/02/2022
 *    Description   : This Queuable is used to send Email to infosec user whenever any user is viewing/Extracting report.
 *      Test Class    : ExportLargeDataCondition_Test
 *     Change History: 
 *         
 */
global class EmailMessageQueuable implements Queueable {
  private ReportEvent repEvent;

    public EmailMessageQueuable(ReportEvent repEvent) {
        this.repEvent = repEvent;
    }

    public void execute(QueueableContext context) {
        String responseMessage = '';
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> emailList = System.Label.EVENT_MONITORING_USERS.split(',');

        mail.setToAddresses(emailList);
        mail.setSubject(System.Label.REPORT_SUBJECT);
        mail.setSaveAsActivity(false);
        //mail.setTargetObjectId(System.Label.InfosecUser);
        String reportUrl = sfdcBaseURL + '/' + repEvent.ReportId;
        String reportUrlWithAnchorTag = '<a href="'+ reportUrl +'"> Click here </a>';
        String body =  '<u>Following are the details of the report</u>:'+'<br><br>';
        body +='Report Id : '+repEvent.ReportId + '<br><br>';
        body +='Report Name : '+repEvent.Name + '<br><br>';
        body +='Total Number of Records : '+repEvent.RowsProcessed + '<br><br>';
        body +='UserId : '+repEvent.UserId+ '<br><br>';
        body +='User Name : '+repEvent.Username+ '<br><br>';
        body +='Report URL : '+reportUrlWithAnchorTag+ '<br><br>';
        body +='<br>';
        body +='System Generated Email';
        mail.setHtmlBody(body);
        mail.setOrgWideEmailAddressId(System.Label.ORG_Wide_Email_Address);
       
    try{
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
        }
        
    }
  
}