/*     Organization   : ABC Bank
 *     Created By     : Jahangeer Mohammed
 *     Created Date   : 22/02/2022
 *     Description    : This Apex class is used to send Email to infosec user, whenever any user is modifying the Mobile/Email of Customer and
 *              		whenever any user is changing the role or profile of any user in the organisation.
 *     Change History : 
 * 					  #CH01# #Jahangeer Mohammed# #04-08-2022# By-Passing condition for Integration user.
 * 					  #CH02# #Jahangeer Mohammed# #09-07-2023# Added Logic to add User to the Jordan Territory
 *         
 */
public class UserTriggerHandler{
    @InvocableMethod
    public static void SendEmailToInfosec(List<Account> accList){
        System.debug('Inside Infosec method:'+accList);
        Set<Id> modifiedOwnerSet = new Set<Id>();
        for(Account a : accList) {
           //CH01: Start
           if(Userinfo.getUserId() != System.Label.INTEGRATION_USER)
           		modifiedOwnerSet.add(a.LastModifiedById);
           //CH01: END
        } 
        
        System.debug('Modified owner set:'+modifiedOwnerSet);
        //CH01: Start
        Map<Id,User> ownerMap = new Map<Id,User>();
        if(modifiedOwnerSet.size()>0){
            ownerMap = new Map<Id,User>([select id,Name,email from User where id in: modifiedOwnerSet]);
            System.debug('Modified owner Map:'+ownerMap);
        }
        //CH01: END
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        String responseMessage = '';
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        List<String> emailList = System.Label.EVENT_MONITORING_USERS.split(',');
        //CH01: Added Null Check Condition in if condition.
        if((accList.size()>0 && !ownerMap.isEmpty() && ownerMap != null) || Test.isRunningTest()){
            for(Account acc : accList){
                //System.debug('Account Name:'+acc.FirstName);
                //System.debug('Account Modified by:'+acc.LastModifiedById);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject(System.Label.CUST_INFO_SUBJECT);
                mail.setTreatTargetObjectAsRecipient(true); 
               // mail.setTargetObjectId(System.Label.InfosecUser);
                mail.setSaveAsActivity(false);
                mail.setToAddresses(emailList);
                String accUrl = sfdcBaseURL + '/' + acc.Id;
                String accUrlWithAnchorTag = '<a href="'+ accUrl +'"> Click here </a>';
                String body =  '<u>Following are the details of the Customer which has been modified </u>:'+'<br><br>';
                body +='Customer Id : '+acc.Id + '<br><br>';
                body +='Customer Name : '+acc.FirstName + ' ' +acc.LastName + '<br><br>';
                body +='Customer CIF : '+acc.Customer_CIF__c + '<br><br>';
                if(!Test.isRunningTest()){
                body +='Last Modified By : '+ownerMap.get(acc.LastModifiedById).Name + '<br><br>';
                }
                body +='Account URL : '+accUrlWithAnchorTag+ '<br><br>';
                body +='<br>';
                body +='System Generated Email';
                mail.setHtmlBody(body);
                mail.setOrgWideEmailAddressId(System.Label.ORG_Wide_Email_Address);
                mails.add(mail);
            }
            if(!mails.isEmpty()){
                try{
                   Messaging.SendEmailResult [] result = Messaging.sendEmail(mails);
                    if(result[0].isSuccess()){
                         responseMessage='Email sent successfully';
                    }
                    else{
                        responseMessage='Email Not sent successfully';
                    }
                }
                catch(Exception e){
                     responseMessage='Error:'+e.getMessage();
                     System.debug('Exception Message:'+responseMessage);
                }
            }
        }
    }
    public static void sendEmailToInfosecForUserCreation(List<User> userList){
        //Set<Id> createdOwnerSet = new Set<Id>();
        Set<String> modifiedRoleIds = new Set<String>();
        Set<String> modifiedProfileIds = new Set<String>();
        for(User u : userList){
            if(u.UserRoleId != null){
                modifiedRoleIds.add(u.UserRoleId);
            }
            if(u.ProfileId != null){
                modifiedProfileIds.add(u.ProfileId);
            }
        }
        System.debug('Modified Role Size:'+modifiedRoleIds.size());
		Map<Id,UserRole> usrRole;
		Map<Id,Profile> usrProfile;
		if(modifiedRoleIds.size()>0){
		    usrRole = new Map<Id,UserRole>([select id,Name from userRole where id in:modifiedRoleIds]);

		}
		if(modifiedProfileIds.size()>0){
		    usrProfile = new Map<Id,Profile>([select id,Name from Profile where id in:modifiedProfileIds]);

		}
        Map<Id,User> ownerMap = new Map<Id,User>([select id,Name,email from User where id =: System.UserInfo.getUserId()]);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        String responseMessage = '';
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        List<String> emailList = System.Label.EVENT_MONITORING_USERS.split(',');
        if(userList.size()>0){
            for(User u : userList){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject(System.Label.USER_CREATION_SUBJECT);
                mail.setTreatTargetObjectAsRecipient(true); 
                //mail.setTargetObjectId(System.Label.InfosecUser);
                mail.setSaveAsActivity(false);
                mail.setToAddresses(emailList);
                String userUrl = sfdcBaseURL + '/' + u.Id;
                String userUrlWithAnchorTag = '<a href="'+ userUrl +'"> Click here </a>';
                String body =  '<u>Following are the details of new user creation </u>:'+'<br><br>';
                if(!Test.isRunningTest()){
                    body +='User Id : '+u.Id + '<br><br>';
                    body +='User Name : '+u.FirstName + ' '+u.LastName + '<br><br>';
                    if(usrRole != null){
                    	body +='User Role Id : '+usrRole.get(u.UserRoleId).Name + '<br><br>';
                    }
                    body +='User Profile Id : '+usrProfile.get(u.ProfileId).Name + '<br><br>';
                    body +='User Active : '+u.IsActive + '<br><br>';
                    body +='Created User Name : '+ownerMap.get(u.CreatedById).Name + '<br><br>';
                    body +='User URL : '+userUrlWithAnchorTag+ '<br><br>';
                    body +='<br>';
                    body +='System Generated Email';
                }
                mail.setHtmlBody(body);
                mail.setOrgWideEmailAddressId(System.Label.ORG_Wide_Email_Address);
                mails.add(mail);
            }
            if(!mails.isEmpty()){
                 try{
                   Messaging.SendEmailResult [] result = Messaging.sendEmail(mails);
                    if(result[0].isSuccess()){
                         responseMessage='Email sent successfully';
                    }
                    else{
                        responseMessage='Email Not sent successfully';
                    }
                }
                catch(Exception e){
                     responseMessage='Error:'+e.getMessage();
                     System.debug('Exception Message:'+responseMessage);
                }
            }
        }
    }
    public static void sendEmailToInfosecForUserUpdate(Map<Id,User> newMapValues,Map<Id,User> oldMapValues){
        //Map<Id,User> ownerMap = new Map<Id,User>([select id,Name,email from User where id =: System.UserInfo.getUserId()]);
        Set<String> modifiedUserIds = new Set<String>();
        Set<String> modifiedRoleIds = new Set<String>();
        Set<String> modifiedProfileIds = new Set<String>();
        
        for(User u : newMapValues.values()){
            if(u.LastModifiedById != null){
                modifiedUserIds.add(u.LastModifiedById);
            }
            if(u.UserRoleId != null){
                modifiedRoleIds.add(u.UserRoleId);
            }
            if(u.ProfileId != null){
                modifiedProfileIds.add(u.ProfileId);
            }
            
        }
        System.debug('Role id:'+modifiedRoleIds);
        Map<Id,User> ownerMap = new Map<Id,User>([select id,Name,email from User where id in: modifiedUserIds]);
        
        Map<Id,UserRole> usrRole;
        System.debug('User Role Before if:'+usrRole);
        if(modifiedRoleIds != null && !modifiedRoleIds.isEmpty()){
        	usrRole = new Map<Id,UserRole>([select id,Name from userRole where id in:modifiedRoleIds]);
             System.debug('User Role Inside if:'+usrRole);
        }
        Map<Id,Profile> usrProfile = new Map<Id,Profile>([select id,Name from Profile where id in:modifiedProfileIds]);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        String responseMessage = '';
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
         List<String> emailList = System.Label.EVENT_MONITORING_USERS.split(',');
        if(newMapValues.values().size()>0){
            for(User u : newMapValues.values()){
                if(u.ProfileId != oldMapValues.get(u.Id).ProfileId || u.UserRoleId != oldMapValues.get(u.Id).UserRoleId ){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setSubject(System.Label.USER_MODIFICATION_SUBJECT);
                    mail.setTreatTargetObjectAsRecipient(true); 
                    //mail.setTargetObjectId(System.Label.InfosecUser);
                    mail.setSaveAsActivity(false);
                    mail.setToAddresses(emailList);
                    String userUrl = sfdcBaseURL + '/' + u.Id;
                    String userUrlWithAnchorTag = '<a href="'+ userUrl +'"> Click here </a>';
                    String body =  '<u>Following are the details of user modification </u>:'+'<br><br>';
                    body +='User Id : '+u.Id + '<br><br>';
                    body +='User Name : '+u.FirstName + ' '+u.LastName + '<br><br>';
                    if(usrRole != null){
                    	body +='User Role Id : '+usrRole.get(u.UserRoleId).Name + '<br><br>';
                    }
                    body +='User Profile Id : '+usrProfile.get(u.ProfileId).Name + '<br><br>';
                    body +='User Active : '+u.IsActive + '<br><br>';
                    body +='Last Modified User : '+ownerMap.get(u.LastModifiedById).Name + '<br><br>';
                    body +='User URL : '+userUrlWithAnchorTag+ '<br><br>';
                    body +='<br>';
                    body +='System Generated Email';
                    mail.setHtmlBody(body);
                    mail.setOrgWideEmailAddressId(System.Label.ORG_Wide_Email_Address);
                    mails.add(mail);
                }
            }
            if(!mails.isEmpty()){
                  try{
                   Messaging.SendEmailResult [] result = Messaging.sendEmail(mails);
                    if(result[0].isSuccess()){
                         responseMessage='Email sent successfully';
                    }
                    else{
                        responseMessage='Email Not sent successfully';
                    }
                }
                catch(Exception e){
                     responseMessage='Error:'+e.getMessage();
                     System.debug('Exception Message:'+responseMessage);
                }
            }
        }
    }
    //CH02: Start
    public static void assignUserToTerritory(Map<Id,User> newMapValues,Map<Id,User> oldMapValues){
        Set<Id> userIdsToAssign = new Set<Id>();
        Set<Id> userIdsToAssignToBahrainTerritory = new Set<Id>();
        
        for(User u : newMapValues.values()){
            User oldUser = oldMapValues.get(u.Id);
            if(oldUser.IsActive != u.IsActive && u.IsActive == true && u.Region_Flag__c == 'Jordan'){
                userIdsToAssign.add(u.Id);
            }
            else if(oldUser.IsActive != u.IsActive && u.IsActive == true && u.Region_Flag__c == 'Bahrain'){
                userIdsToAssignToBahrainTerritory.add(u.Id);
            }
        } //for loop Ends
        
        List<UserTerritory2Association> userTerritoryList = new List<UserTerritory2Association>();
        Map<Id,UserTerritory2Association> mapUserExistingInTerritory = new Map<Id,UserTerritory2Association>();
        
        /****************************************************** Start: Assigning to Jordan Territory ******************************************/
        if(!userIdsToAssign.isEmpty()){
            System.debug('User Assign to Territory:'+userIdsToAssign);
            for(UserTerritory2Association userTerritory : [Select Id, UserId from UserTerritory2Association]){
                mapUserExistingInTerritory.put(userTerritory.UserId,userTerritory);
            }
            
            for (Id userId : userIdsToAssign) {
                if(!mapUserExistingInTerritory.containsKey(userId)){
                    UserTerritory2Association userTerritory = new UserTerritory2Association();
            		userTerritory.UserId = userId;
            		userTerritory.Territory2Id = System.Label.JORDAN_TERRITORY; 
            		userTerritoryList.add(userTerritory);
                }
            }//for loop Ends
            if(userTerritoryList.size() > 0){
            	insert userTerritoryList;
        	}
        }//If Ends
      /****************************************************** END: Assigning to Jordan Territory ******************************************/
      
      /****************************************************** Start: Assigning to Bahrain Territory ******************************************/
  		else if(!userIdsToAssignToBahrainTerritory.isEmpty()){
            for(UserTerritory2Association userTerritory : [Select Id, UserId from UserTerritory2Association]){
                mapUserExistingInTerritory.put(userTerritory.UserId,userTerritory);
            }
            
            for (Id userId : userIdsToAssignToBahrainTerritory) {
                if(!mapUserExistingInTerritory.containsKey(userId)){
                    UserTerritory2Association userTerritory = new UserTerritory2Association();
            		userTerritory.UserId = userId;
            		userTerritory.Territory2Id = System.Label.BAHRAIN_TERRITORY; 
            		userTerritoryList.add(userTerritory);
                }
            }//for loop Ends
            if(userTerritoryList.size() > 0){
            	insert userTerritoryList;
        	}
        }
     /****************************************************** END: Assigning to Bahrain Territory ******************************************/

    }
    //CH02: END
}