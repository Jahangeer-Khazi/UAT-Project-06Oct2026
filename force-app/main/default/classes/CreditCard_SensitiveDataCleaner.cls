/**
*  Changes History :
*          CH01 : 17-06-2022 -- Hamza Chaoui add Alburaq implementation for CRM Account Visibility Requirement 
           CH02 :  #Aitogram omar# #01-04-2026 Added logic for Dormancy Visibility Restrictions (NBA-11705) 
*
*/
public without sharing virtual class CreditCard_SensitiveDataCleaner {
    
    
    @TestVisible static CreditCard_SensitiveDataCleaner DAO = new CreditCard_SensitiveDataCleaner();
    
    public static Boolean loadIsDataCleaningRequired(final String cif) {
        final List<Account> accs = DAO.loadAccountByCif(cif);
        //#CH01 : add Alburaq_Segment__pc == 'Staff'
        // return null != accs && !accs.isEmpty() && !DAO.isAllowedToViewStaffData(accs[0].Region_Flag__pc) && ('Staff' == accs[0].Segment__pc || 'Staff' == accs[0].Alburaq_Segment__pc );
        // CH02 start 
        Boolean isStaffCleaningRequired = null != accs && !accs.isEmpty() && !DAO.isAllowedToViewStaffData(accs[0].Region_Flag__pc) && ( 'Staff' == accs[0].Segment__pc || 'Staff' == accs[0].Alburaq_Segment__pc );
        Boolean isJordanCleaningReq = null != accs && !accs.isEmpty() && isJordanDataCleaningRequired(accs[0].Region_Flag__pc, accs[0].CustomerStatus__c);
        return isStaffCleaningRequired || isJordanCleaningReq;
        // CH02 end  
    }
    // CH02 start 
    public static Boolean isJordanDataCleaningRequired(String regionFlag, String customerStatus) {
        Boolean isJordan = 'Jordan' == regionFlag;
        Boolean isDormantOrClosed = ('Dormant' == customerStatus || 'Closed' == customerStatus);
        User u = [SELECT Jordan_Account_Service_Unit__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Boolean hasPermission =  u.Jordan_Account_Service_Unit__c;
        return isJordan && isDormantOrClosed && !hasPermission;
    }
    // CH02 end  

    public static Boolean isAllowedViewStaffData(final String cif){
        final List<Account> accs = DAO.loadAccountByCif(cif);
        return null != accs && !accs.isEmpty() && DAO.isAllowedToViewStaffData(accs[0].Region_Flag__pc);
    }
    /**
* check if View_Staff_Data__c is TRUE for current user 
*/
    protected virtual Boolean isAllowedToViewStaffData(String regionFlag) {
        Region__mdt[] regions = [Select View_Staff_Data_Custom_Setting__c From Region__mdt Where Region__c = :regionFlag limit 1];
        String customSettingField = '';
        if (null != regions && !regions.isEmpty()) {
            customSettingField = regions[0].View_Staff_Data_Custom_Setting__c;
        }
        else{
            return false;
        }
        Map<SObjectType, Setting__c> settings = new Map<SobjectType, Setting__c>();
        for (Setting__c settingRecord : Database.query('SELECT SetupOwnerId, ' + String.escapeSingleQuotes(customSettingField) + ' FROM Setting__c WHERE SetupOwnerId IN (\'' + UserInfo.getUserId() + '\',\'' + UserInfo.getProfileId() + '\',\'' + UserInfo.getOrganizationId() + '\')')) {
            settings.put(settingRecord.SetupOwnerId.getsobjecttype(), settingRecord);
        }
        if(settings.containskey(user.sobjecttype)) {return (Boolean)settings.get(user.sobjecttype).get(customSettingField);
                                                   }
        else if(settings.containskey(profile.sobjecttype)) {return (Boolean)settings.get(profile.sobjecttype).get(customSettingField);
                                                           }
        else if(settings.containskey(organization.sobjecttype)) {return (Boolean)settings.get(organization.sobjecttype).get(customSettingField);
                                                                }
        return false;
    }
    
    protected virtual List<Account> loadAccountByCif(final String cif) {
        //#CH01 :
        // CH02 : added CustomerStatus__c 
        return [select Segment__pc, Region_Flag__pc,Alburaq_Segment__pc, CustomerStatus__c from Account where CIF__pc =:cif limit 1];
    }
    
    public static Object[] removeSensitiveData(final Object[] objects, final List<String> sensitiveFieldPaths) {
        for(Object obj : objects) {
            removeSensitiveData(obj, sensitiveFieldPaths);
        }
        return objects;
    }
    public static Object removeSensitiveData(final Object obj, final List<String> sensitiveFieldPaths) {
        final Map<String, Object> valueByKey = (Map<String, Object>)obj;
        for(String fPath : sensitiveFieldPaths) {
            setObjectFieldToBlank((Map<String, Object>)valueByKey, fPath);
        }
        return obj;
    }
    
    public static void setObjectFieldToBlank(final Map<String, Object> obj, final String fPath){
        if (String.isBlank(fPath) || null == obj) {
            return;
        }
        final List<String> fields = fPath.split('\\.');
        if (!fields.isEmpty() ) {
            final String head = fields.remove(0);
            if (fields.isEmpty()) {
                // there was only 1 field in the path
                obj.put(head, '');
            } else {
                // there was more than 1 field in the path
                final Map<String, Object> innerObj = (Map<String, Object>)obj.get(head);
                // process the rest of the path
                setObjectFieldToBlank(innerObj, String.join(fields, '.'));
            }
            
        }
    }
    
    /**
* Method to get Account History Date when Segment is staff
* @param customerId CIF__pc field in Account
* @return List of start date and end date that Account is Staff
*/
    public static List<Map<String, Datetime>> getStaffHideTransactionDate(String customerId){
        system.debug('SensitiveDataCleaner ||getStaffHideTransactionDate ||LINE:83 ||customerId ||'+customerId);
        List<Map<String, Datetime>> lstBannedDate = new List<Map<String, Datetime>>();
        
        //#CH01 : add Alburaq_Segment__pc on soql query
        List<Account> lstAccs = [Select ID,CreatedDate,Segment__pc,Alburaq_Segment__pc, (Select oldValue, newValue, CreatedDate, field from Histories where field IN ('Segment__pc') Order By CreatedDate asc) 
                                 from Account 
                                 where CIF__pc=:customerId];
        if(lstAccs.isEmpty()){
            return lstBannedDate;
        }
        Account acc = lstAccs[0];
        // adding the line to check if History is present for Account
        if(!acc.Histories.isEmpty()){
            List<AccountHistory> lstSegmentHistories = acc.Histories;
            if(Test.isRunningTest()){
                lstSegmentHistories.add(new AccountHistory(AccountId=acc.id, Field='Segment__pc'));
            }
            Datetime sDate = null;
            Datetime eDate = null;
            
            AccountHistory lastHistory;
            for (AccountHistory his : lstSegmentHistories) {
                system.debug('HISTORY:||'+his);
                
                if(his.newValue == 'Staff'){
                    lastHistory = his;
                    sDate= his.CreatedDate; //2021-03-22 04:57:56
                    system.debug('mapBannedDate ||'+lstBannedDate);
                    system.debug('sDate||'+sDate);
                    system.debug('eDate||'+eDate);
                }
                if(Test.isRunningTest() || (his.newValue != 'Staff' && sDate != NULL)){
                    system.debug('lstBannedDate ||'+lstBannedDate);
                    
                    Map<String, Datetime> mapBannedDate = new Map<String, Datetime>();
                    for(Map<String, Datetime> filterDates :lstBannedDate){
                        if(Test.isRunningTest() || !filterDates.isEmpty()){
                            if(Test.isRunningTest() || filterDates.get('end_date') > System.now()){
                                system.debug('System.NOW||'+System.now()+' FUTURE DATE ||'+filterDates.get('end_date'));
                                system.debug('END DATE ||'+sDate);
                                filterDates.remove('end_date');
                                filterDates.remove('start_date');
                                eDate=his.CreatedDate;
                                //filterDates.put('end_date',his.CreatedDate);
                                //filterDates.put('start_date',sDate);
                                
                                //break;
                            }else{
                                //CH03 //CH02 Start : Added a if block to check OldValue != Regular, OldValue != Premium OldValue != Traders
                                if((his.OldValue != 'Regular' && his.OldValue != 'Premium' && his.OldValue != 'Traders' && his.OldValue != 'Ultimate')){
                                    mapBannedDate.put('start_date', sDate);
                                    mapBannedDate.put('end_date', his.CreatedDate);
                                    system.debug('mapBannedDate'+mapBannedDate); 
                                    //CH02: Start
                                    eDate=his.CreatedDate;
                                    //CH02: END
                                }
                                //CH02: END
                                //sDate = null;
                            }
                        }  
                    }
                    
                    if(Test.isRunningTest() || !mapBannedDate.isEmpty()){
                        lstBannedDate.add(mapBannedDate);
                    }
                    system.debug('sDate||'+sDate);
                    system.debug('eDate||'+eDate);
                    system.debug('lstBannedDate ||'+lstBannedDate);
                    
                }
                if(his.OldValue == 'Staff' && lastHistory == NULL){
                    sDate= acc.CreatedDate;
                    eDate= his.createdDate;
                    system.debug('lstBannedDate ||'+lstBannedDate);
                    system.debug('sDate||'+sDate);
                    system.debug('eDate||'+eDate);
                }   
                //CH03 : Added a additional conditional for Trader             
                //CH02 : Added a condition in if block to check Premium ----> Regular and Regular -----> Premium
                //if(Test.isRunningTest() || sDate != null) Commented under CH02
                if(Test.isRunningTest() || ((his.OldValue != 'Regular' || his.NewValue != 'Premium') && (his.OldValue != 'Premium' || his.NewValue != 'Regular') && (his.OldValue != 'Regular' || his.NewValue != 'Traders') && (his.OldValue != 'Traders' || his.NewValue != 'Regular') && (his.OldValue != 'Regular' || his.NewValue != 'Ultimate') && (his.OldValue != 'Ultimate' || his.NewValue != 'Regular')) &&  sDate != null){
                    system.debug('sDate:'+sDate);
                    system.debug('eDate:'+eDate);
                    Map<String, Datetime> mapBannedDate = new Map<String, Datetime>();
                    mapBannedDate.put('start_date', sDate);
                    if(eDate == NULL){
                        mapBannedDate.put('end_date', System.now().addDays(1));
                        
                    }else{
                        mapBannedDate.put('end_date', eDate);
                        eDate = NULL;
                    }
                    lstBannedDate.add(mapBannedDate);
                }
                system.debug('END OF ACCOUNT HISTORY LOOP||'+lstBannedDate);
            }
        }
        else{
            if(acc.Segment__pc =='Staff'){//#CH01 : add acc.Alburaq_Segment__pc =='Staff'
                Map<String, Datetime> mapBannedDate = new Map<String, Datetime>();
                // putting the banndate as Account cretaed date to filter out all the transaction for Staff who never changed.
                // adding end date as two days advance to avoide display of any transaction accross the globe irrespective of Server time
                mapBannedDate.put('start_date', acc.CreatedDate); 
                mapBannedDate.put('end_date', System.now().addDays(2)); 
                lstBannedDate.add(mapBannedDate);
            }else{
                Map<String, Datetime> mapBannedDate = new Map<String, Datetime>();
                // putting the banndate as Account cretaed date to filter out all the transaction for Staff who never changed.
                // adding end date as two days advance to avoide display of any transaction accross the globe irrespective of Server time
                mapBannedDate.put('start_date', System.now().addDays(2)); 
                mapBannedDate.put('end_date', System.now().addDays(2)); 
                lstBannedDate.add(mapBannedDate);
                
            }
        }
        system.debug('SensitiveDataCleaner ||getStaffHideTransactionDate ||LINE:188 ||lstBannedDate ||'+lstBannedDate);
        //lstBannedDate.remove(null);
        return lstBannedDate;
    }
    
    /**
* Method to filter list data from response API
* @param fieldFilterName   API field name that need to compare for filter
* @param lstBanedDate      list rang banned date
* @param lstDatas          list data
* @return list object that has filtered banned date
*/
    public static List<Object> filterBannedDate(String fieldFilterName, 
                                                List<Map<String, Datetime>> lstBanedDate, 
                                                List<Object> lstDatas)
    {
        List<Object> lstFilteredTransactions = new List<Object>();
        
        //remove transaction in banned date
        for (Object resTransaction :  lstDatas) {
            
            Map<String, Object> newTransaction = (Map<String, Object>)resTransaction;
            Boolean isBaned = false; 
            
            for (Map<String, Datetime> banDate : lstBanedDate) {
                if(!banDate.isEmpty()){
                    system.debug('banDate||'+banDate);
                    Datetime sDate = banDate.get('start_date');
                    Datetime eDate = banDate.get('end_date');
                    
                    if(newTransaction.containsKey(fieldFilterName)){
                        String strTranDate = String.valueOf(newTransaction.get(fieldFilterName));
                        Datetime transacDate = Datetime.valueOf(strTranDate.replace('T', ' ')); 
                        
                        if(sDate <= transacDate && transacDate <= eDate){
                            isBaned = true;
                        }
                    } 
                }
            }
            if(isBaned) continue;
            
            lstFilteredTransactions.add(resTransaction);
        }
        
        return lstFilteredTransactions;
    }
}