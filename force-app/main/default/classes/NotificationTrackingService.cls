public without sharing class NotificationTrackingService {

    public static NotificationsTracking__c setNotifTracking(
        String triggeredFrom, Id caseId, String channel, String description, String path, String failureReason, 
        Integer statCode,String method, String notificationType, String product , String reqBody, String resBody, 
        Datetime sentOnDate, String statusStr, String subStatusStr, String templateCode
    ) {
        NotificationsTracking__c action = new NotificationsTracking__c();
        action.TriggeredFrom__c = triggeredFrom;
        action.Case__c = caseId;
        action.Channel__c = channel;
        action.Description__c = description;
        action.Endpoint__c = path;
        action.Failure_Reason__c = failureReason;
        action.HTTP_Response_Code__c = statCode;
        action.Method__c = method;
        action.NotificationType__c = notificationType;
        action.Product__c = product;
        action.Request_Body__c = reqBody;
        action.Response_Body__c = resBody;
        action.SentOn__c = sentOnDate;
        action.Status__c = statusStr;
        action.Sub_Status__c = subStatusStr;
        action.TemplateCode__c = templateCode;
        return action; 
    }
}