/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 07-11-2022
*       Change History: 
						#CH01: #Jahangeer Mohammed# #29-04-2025# Added Logic for Sending separate Branch Name for SMS (NBA-13736)
*/
public class walkInCustomerSendingSMSReminders {
    @future(callout=true)
    public static void sendSMSRemindersOnCaseCreation(Set<Id> caseIds){
        ApiConnection con = new ApiConnection();
        List<Case> caseToUpdate = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        //CH01: Added Type in the SOQL
        for(Case caseObj : [SELECT Id,Type,Status,Sub_Status__c,Token_Counter__c,Account.CIF__pc,Customer_CIF__c,cc_Email_Address__c,Account.PersonEmail,Web_Phone_Country_Code__c,SuppliedPhone,cc_Mobile_Number__c,Case_Model__c,Region_Flag__c, 
                            WalkIn_Update_SMS_Sent__c,WalkIn_Creation_SMS_Sent__c,Total_Walkin_Cases__c FROM Case WHERE Id In:caseIds]){
            Http http = new Http();
            HttpRequest request1 = new HttpRequest();      
            request1 = con.createRequest('POST','/api/v1/notifications?',caseObj.Region_Flag__c);
           
            String sms = 'sms';
            String walkinCreation = 'WALKIN_CREATION';
            String tokenCounterNumber = String.valueOf(caseObj.Token_Counter__c);
            String totalWalkinCaseCount = String.valueOf(caseObj.Total_Walkin_Cases__c);
            String body = '';
            if(caseObj.cc_Mobile_Number__c != '' && caseObj.cc_Mobile_Number__c != null){
                System.debug('Mobile Number in Future Class in If condition:'+caseObj.cc_Mobile_Number__c);
                System.debug('Supplied Number in Future Class in If condition:'+caseObj.SuppliedPhone);
            	//CH01: Start
                if(caseObj.Type == 'Walkin Customer'){
                    body =                    
                       '{"phoneNumber": "'+caseObj.cc_Mobile_Number__c + 
                        '","type": "'+sms +
                        '","subject": "'+null +
                        '","templateCode": "'+walkinCreation +
                        '","placeholderReplacements": [ '+
                        	' 	{ '+
                        	'	  "fieldName":"tokenCounter", '+
                        	'	  "fieldText":"'+tokenCounterNumber+'" '+
                        	' 	}, '+
                            '	{ '+
                        	'	  "fieldName":"branchName", '+
                        	'	  "fieldText":"ila Bank Service Centre" '+
                        	' 	}, '+
                            '	{ '+
							'	  "fieldName":"caseCount", '+
							'     "fieldText":"'+totalWalkinCaseCount+'" '+
							'   } '+
                            ' ] '+
                        ' }'; 
                }
                else if(caseObj.Type == 'Walkin Customer Pop Up'){
                    body =                    
                       '{"phoneNumber": "'+caseObj.cc_Mobile_Number__c + 
                        '","type": "'+sms +
                        '","subject": "'+null +
                        '","templateCode": "'+walkinCreation +
                        '","placeholderReplacements": [ '+
                        	' 	{ '+
                        	'	  "fieldName":"tokenCounter", '+
                        	'	  "fieldText":"'+tokenCounterNumber+'" '+
                        	' 	}, '+
                            '	{ '+
                        	'	  "fieldName":"branchName", '+
                        	'	  "fieldText":"ila Popup Branch" '+
                        	' 	}, '+
                            '	{ '+
							'	  "fieldName":"caseCount", '+
							'     "fieldText":"'+totalWalkinCaseCount+'" '+
							'   } '+
                            ' ] '+
                        ' }'; 
                }
                //CH01: END
                
                system.debug('---> BODY --> '+body);          
            	request1.setBody(body);
            	request1.setHeader('userId', caseObj.Account.PersonEmail);
            	request1.setHeader('customerId', caseObj.Account.CIF__pc);
                System.debug('Get Header User Information:'+request1.getHeader('userId'));
            	System.debug('Get Header CIF Information:'+request1.getHeader('customerId'));
            	system.debug('---> request1 --> '+request1.getBody());
            	
            }
            else if(caseObj.cc_Mobile_Number__c == '' || caseObj.cc_Mobile_Number__c == null){
                String internationalCode = caseObj.Web_Phone_Country_Code__c;
                String suppPhone = caseObj.SuppliedPhone;
                String mobileNumber = internationalCode + suppPhone;
                System.debug('Mobile Number in Future Class in Else condition:'+caseObj.cc_Mobile_Number__c);
                System.debug('Supplied Number in Future Class in Else condition:'+caseObj.SuppliedPhone);
                //CH01: Start
                if(caseObj.Type == 'Walkin Customer'){
                   body =                    
                       '{"phoneNumber": "'+mobileNumber  + 
                        '","type": "'+sms +
                        '","subject": "'+null +
                        '","templateCode": "'+walkinCreation +
                        '","placeholderReplacements": [ '+
                        	' 	{ '+
                        	'	  "fieldName":"tokenCounter", '+
                        	'	  "fieldText":"'+tokenCounterNumber+'" '+
                        	' 	}, '+
                            '	{ '+
                        	'	  "fieldName":"branchName", '+
                        	'	  "fieldText":"ila Bank Service Centre" '+
                        	' 	}, '+
                    		'	{ '+
							'	  "fieldName":"caseCount", '+
							'     "fieldText":"'+totalWalkinCaseCount+'" '+
							'   } '+
                            ' ] '+
                        ' }';  
                }
                else if(caseObj.Type == 'Walkin Customer Pop Up'){
                    body =                    
                       '{"phoneNumber": "'+mobileNumber  + 
                        '","type": "'+sms +
                        '","subject": "'+null +
                        '","templateCode": "'+walkinCreation +
                        '","placeholderReplacements": [ '+
                        	' 	{ '+
                        	'	  "fieldName":"tokenCounter", '+
                        	'	  "fieldText":"'+tokenCounterNumber+'" '+
                        	' 	}, '+
                            '	{ '+
                        	'	  "fieldName":"branchName", '+
                        	'	  "fieldText":"ila Popup Branch" '+
                        	' 	}, '+
                    		'	{ '+
							'	  "fieldName":"caseCount", '+
							'     "fieldText":"'+totalWalkinCaseCount+'" '+
							'   } '+
                            ' ] '+
                        ' }'; 
                }
                //CH01: END
                   system.debug('---> BODY --> '+body);          
                   request1.setBody(body);
                   system.debug('---> request1 --> '+request1.getBody());
            }
            HttpResponse response1 = http.send(request1);
            if(response1.getStatusCode() != 200){
                System.debug('Invalid Status Code from API');
                lstSA = createSystemAction(request1.getBody(),response1.getBody(),'callout:NeoBank_Endpoint/api/v1/notifications?language=en&unit=neo','POST',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response1.getStatusCode(), 'Walkin Customer', 'SMS Reminder');

            }
            else{
                System.debug('Getting Success Status Code from API:'+response1.getBody());
                caseObj.WalkIn_Creation_SMS_Sent__c = true;
                caseToUpdate.add(caseObj);
			}
        }
        if(caseToUpdate.size()>0){
            update caseToUpdate;
        }
         if(lstSA.size()>0)
            insert lstSA;
    }
    @future(callout=true)
    public static void sendSMSRemindersOnChangingOwnership(Set<Id> caseIds){
        ApiConnection con = new ApiConnection();
        List<Case> caseToUpdate = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
       
        for(Case caseObj : [SELECT Id,Owner.Name,Status,Sub_Status__c,Token_Counter__c,Counter_Number__c,Account.CIF__pc,Customer_CIF__c,cc_Email_Address__c,Account.PersonEmail,Web_Phone_Country_Code__c,SuppliedPhone,cc_Mobile_Number__c,Case_Model__c,Region_Flag__c FROM Case WHERE Id In:caseIds]){
            Http http = new Http();
            HttpRequest request1 = new HttpRequest();      
            request1 = con.createRequest('POST','/api/v1/notifications?',caseObj.Region_Flag__c);
           
            String sms = 'sms';
            String walkinUpdate = 'WALKIN_UPDATE';
            String counterNum = String.valueOf(caseObj.Counter_Number__c);
            String ownerName = String.valueOf(caseObj.Owner.Name);
            System.debug('Counter Number:'+counterNum);
            System.debug('Case Owner Name:'+ownerName);
            String body = '';
            if(caseObj.cc_Mobile_Number__c != '' && caseObj.cc_Mobile_Number__c != null){
            	body = 
               		'{"phoneNumber": "'+caseObj.cc_Mobile_Number__c + 
                	'","type": "'+sms +
                	'","subject": "'+null +
                	'","templateCode": "'+walkinUpdate +
                	'","placeholderReplacements": [ '+
                    	' 	{ '+
                    	'	  "fieldName":"counterNumber", '+
                    	'	  "fieldText":"'+counterNum+'" '+
                    	' 	}, '+
                		'	{ '+
                    	'	  "fieldName":"owner", '+
                    	'     "fieldText":"'+ownerName+'" '+
	                    '   } '+
                    	' ] '+
                		' }';
            	system.debug('---> BODY --> '+body);          
            	request1.setBody(body);
            	request1.setHeader('userId', caseObj.Account.PersonEmail);
            	request1.setHeader('customerId', caseObj.Account.CIF__pc);
            	System.debug('Get Header User Information:'+request1.getHeader('userId'));
            	System.debug('Get Header CIF Information:'+request1.getHeader('customerId'));
            	system.debug('---> request1 --> '+request1.getBody());
            }
            else if(caseObj.cc_Mobile_Number__c == '' || caseObj.cc_Mobile_Number__c == null){
                String internationalCode = caseObj.Web_Phone_Country_Code__c;
                String suppPhone = caseObj.SuppliedPhone;
                String mobileNumber = internationalCode + suppPhone;
                body = 
               		'{"phoneNumber": "'+mobileNumber + 
                	'","type": "'+sms +
                	'","subject": "'+null +
                	'","templateCode": "'+walkinUpdate +
                	'","placeholderReplacements": [ '+
                    	' 	{ '+
                    	'	  "fieldName":"counterNumber", '+
                    	'	  "fieldText":"'+counterNum+'" '+
                    	' 	}, '+
                		'	{ '+
                    	'	  "fieldName":"owner", '+
                    	'     "fieldText":"'+ownerName+'" '+
	                    '   } '+
                    	' ] '+
                		' }';
                
					system.debug('---> BODY --> '+body);          
            		request1.setBody(body); 
                    system.debug('---> request1 --> '+request1.getBody());
            }
            HttpResponse response1 = http.send(request1);
            if(response1.getStatusCode() != 200){
                System.debug('Invalid Status Code from API');
                lstSA = createSystemAction(request1.getBody(),response1.getBody(),'callout:NeoBank_Endpoint/api/v1/notifications?language=en&unit=neo','POST',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response1.getStatusCode(), 'Walkin Customer', 'SMS Reminder');

            }
            else{
                System.debug('Getting Success Status Code from API:'+response1.getBody());
                caseObj.WalkIn_Update_SMS_Sent__c = true;
                caseToUpdate.add(caseObj);
			}
            //reDirectToDisplayPage(caseObj);
        }
        if(caseToUpdate.size()>0){
            update caseToUpdate;
        }
         if(lstSA.size()>0)
            insert lstSA;
    }
    
    /*public static PageReference reDirectToDisplayPage(Case cse)
    {
        System.debug('Case Record in Page Reference:'+cse);
        System.debug('Case Record ID in Page Reference:'+cse.id);
        PageReference pr;
        pr = new PageReference('/apex/walkinCustomerRegistration_Display?id='+cse.id);
        System.debug('Page Reference is:'+pr);
        pr.setRedirect(true);
        return pr;
    }*/
     public static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Final Integer statCode, Final String strAction, Final String strType) {
        List<System_Action__c> lstSA = new List<System_Action__c>();
        System_Action__c action = new System_Action__c();
        action.Account_Number__c = custId;
        action.Action__c = strAction;
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