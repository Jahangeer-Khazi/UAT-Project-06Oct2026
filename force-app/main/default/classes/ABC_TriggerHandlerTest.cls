@isTest(seeAllData = true)
private class ABC_TriggerHandlerTest 
{
    static testMethod void ABC_TriggerHandlertest()
    {
        User thisUser = [Select id from User where id =: UserInfo.getUserId()];
        system.runAs(thisUser)
        {
            ABC_TriggerHandler cls = new ABC_TriggerHandler ();
            ABC_TriggerHandler.bypass('Class');
            ABC_TriggerHandler.clearBypass('Class');
            ABC_TriggerHandler.isBypassed('Class');
            ABC_TriggerHandler.clearAllBypasses();
            
            cls.beforeInsert();
            cls.beforeUpdate();
            cls.beforeDelete();
            cls.afterInsert();
            cls.afterUpdate();
            cls.afterDelete(); 
            cls.afterUndelete();
            
            
        }
    }
    
    static testMethod void ADS_TriggerHandlertest1()
    {
        User thisUser = [Select id from User where id =: UserInfo.getUserId()];
        system.runAs(thisUser)
        {
            ABC_TriggerHandler.LoopCount cls1 = new ABC_TriggerHandler.LoopCount();
            ABC_TriggerHandler.LoopCount cls2 = new ABC_TriggerHandler.LoopCount(2);
            ABC_TriggerHandler cls3 = new ABC_TriggerHandler();
            cls3.setMaxLoopCount(2);
            cls3.clearMaxLoopCount();
            
            cls2.increment();
            cls2.exceeded();
            cls2.getMax();
            cls2.getcount();
            cls2.setMax(2);
        }
    } 
    
    static testMethod void ADS_TriggerHandlertest2()
    {
        User thisUser = [Select id from User where id =: UserInfo.getUserId()];
        system.runAs(thisUser)
        {
            List<Lead> leadList = new List<Lead> ();
            Lead ld = new Lead();
            ld.LastName = 'Lead Lastname11';
            ld.Email = 'lead11@test.com';
            ld.Company = 'ABC';
            ld.Birthdate__c = Date.parse('12/12/2000');
            leadList.add(ld);
            
            Lead ld1 = new Lead();
            ld1.LastName = 'Lead Lastname';
            ld1.Email = 'lead@test.com';
            ld1.Company = 'ABC';
            ld1.Birthdate__c = Date.parse('12/12/2000');
            leadList.add(ld1);
            
            try
            {
                insert leadList;

                ld.email = 'leadtest1@test.com';
                update ld;
            
                delete ld;
            }
            catch(DMLException ex)
            {
                
            }   
           // test.stoptest();
        }   
    }
}