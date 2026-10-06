public with sharing class FantasyLeague_VFPageController 
{
    public Fantasy_League_Entry__c objFan{get;set;}
    public FantasyLeague_VFPageController(ApexPages.StandardController controller) {
        objFan = new Fantasy_League_Entry__c();
    }

    public PageReference saveRequest()
    {
        PageReference pr;
        system.debug('---> Email__c --> ' +objFan.Email__c);
        if(objFan.Email__c != '' || objFan.Email__c != ''){
            List<Account> lstAcc = [Select id from Account where (PersonEmail =: objFan.Email__c OR PersonMobilePhone =: objFan.Mobile_Number__c) AND Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED' AND Archived__pc = false];
            if(lstAcc.size()>0){
                objFan.is_Active_ila_Customer__c = True;
            }
            insert objFan;
        }
        pr = new PageReference('/apex/FantasyLeague_ThankyouPage');
        pr.setRedirect(true);
        return pr;
    }
}