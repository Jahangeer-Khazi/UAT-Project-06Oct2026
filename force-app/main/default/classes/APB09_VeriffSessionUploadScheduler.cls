Global class APB09_VeriffSessionUploadScheduler Implements Schedulable {
    global void execute(SchedulableContext sc) {
    APB09_VeriffSessionUpload c = new APB09_VeriffSessionUpload();
    Database.executeBatch(c,1);
    }

 Public static void SchedulerMethod() {   
    Datetime sysTime = System.now().addMinutes(1);
    String cronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
    system.schedule('My Jobs scheduled name', cronExpression, new APB09_VeriffSessionUploadScheduler());

   }
}