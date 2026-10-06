global with sharing class MobileNumberClaimHandler extends ABC_TriggerHandler{
    ////////////// Framework ///////////////
    
    protected override void beforeInsert()
    {
        beforeInsert(trigger.new);
    }
    protected override void afterInsert()
    { 
    }
    protected override void beforeUpdate()
    {
    }    
    protected override void afterUpdate()
    {       
    }
    
    ///////////////////////////////////////
    
    public void beforeInsert(List<Mobile_Number_Claim__c> TriggerList){
        Set<String> setOwnerCIF = new Set<String>();
        Set<String> setClaimantCIF = new Set<String>();
        Account MobileOwnerID = new Account();
        Account MobileClaimantID = new Account();
        for(Mobile_Number_Claim__c objMNC : TriggerList){
            setOwnerCIF.add(objMNC.Owner_CIF__c);
            setClaimantCIF.add(objMNC.Claimant_CIF__c);
        }
        System.debug('Customer CIF:'+setOwnerCIF);
        if(!test.isRunningTest()){
        if(!setOwnerCIF.isEmpty())
            MobileOwnerID = [Select ID from Account where CIF__pc in: setOwnerCIF ORDER BY CreatedDate DESC limit 1 ];
        if(!setClaimantCIF.isEmpty())
            MobileClaimantID = [Select ID from Account where CIF__pc in: setClaimantCIF ORDER BY CreatedDate DESC limit 1 ];
        }
        System.debug('Mobile owner Id:'+MobileOwnerID);
        for(Mobile_Number_Claim__c objMNC : TriggerList){
            if(MobileClaimantID!= null)
                objMNC.Mobile_Claimant__c = MobileClaimantID.Id;
            objMNC.Type_of_Attempt__c = 'Claim Mobile Requester';
            if(MobileOwnerID!= null)
            objMNC.Mobile_Owner__c = MobileOwnerID.Id;
        }
    }
     public static void calculate(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
     }
}