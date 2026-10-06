/**
 *  @author: Andrey Gavrikov (westbrook)
 *  @date: 2019-02-05
 *  @description:
 *      generate unique, non conflicting CIF numbers
 *
 *  Version History :
 *  2019-02-05 - CRM-35 - AG
 *  initial version
 *
 */
public without sharing virtual class CifGenerator {
    public static Integer CLEANUP_THRESHOLD = 100;

    @TestVisible
    private static CifGenerator DAO = new CifGenerator();

    @InvocableMethod(label='createNewCifIds' description='generate new CIF numbers')
    public static List<String> createNewCifIds(List<Account> accounts) {
        final List<SObject> CIFRecords = new List<SObject>();
        Map<String, Schema.SObjectType> mapRegionCifType = new Map<String, Schema.SObjectType>();
        for (Account acc : accounts) {
             // 17/11/02021 made a check Region_Flag__pc != null becuase some of the test classes were failing.
            if (mapRegionCifType.get(acc.Region_Flag__pc) == null && acc.Region_Flag__pc != null) {
                //System.debug(' get ObjectName Region__mdt >> ' +Region__mdt);
                String objectName = Region__mdt.getInstance(acc.Region_Flag__pc).CIF_Generation_Type__c;
                System.debug('ObjectName >> ' +objectName);
                mapRegionCifType.put(acc.Region_Flag__pc, Schema.getGlobalDescribe().get(objectName));
            }
        }
        for (Account acc : accounts) {
            CIFRecords.add(mapRegionCifType.get(acc.Region_Flag__pc).newSobject());
        }
        final List<String> cifs = new List<String>();
        for(SObject rec : DAO.queryRecords(DAO.insertRecords(CIFRecords))) {
            String num = DAO.getCifNumber(rec);
            cifs.add(num);
            cleanupIfRequired(num);
        }
        return cifs;
    }

    /**
     * delete used records created yesterday or earlier
     */
    @future
    public static void cleanUp() {
        final Integer maxRecs = CLEANUP_THRESHOLD + 50;// always delete more than threshold to make
                                                       // sure that list of old records is not growing overtime
        Database.delete([select Id from CIF__c where CreatedDate < TODAY limit :maxRecs]);
    }

    protected virtual String getCifNumber(final SObject rec) {
        return string.valueOf(rec.get('Name'));// Name is "Auto Number"
    }
    protected virtual List<Id> insertRecords(final List<SObject> recs) {
        final List<Id> ids = new List<Id>();
        for(Database.SaveResult res : Database.insert(recs, /*all_or_none=*/true)) {
            ids.add(res.getId()); // there is no need to check for isSuccess because exception would be thrown in the line above
        }
        return ids;
    }
    protected virtual List<SObject> queryRecords(final List<Id> recIds) {
        Map<Schema.SObjectType, List<Id>> mapCifIds = new Map<Schema.SObjectType, List<Id>>();
        List<Id> tempIdList = new List<Id>();
        for (Id idValue: recIds) {
            tempIdList = mapCifIds.get(idValue.getsobjecttype());
            if (tempIdList != null) {
                tempIdList.add(idValue);
                mapCifIds.put(idValue.getsobjecttype(), tempIdList);
            }
            else {
                mapCifIds.put(idValue.getsobjecttype(), new List<Id>{idValue});
            }
        }
        List<SObject> foundRecs = new List<SObject>();
        List<SObject> currentRecs;
        String constructedQuery = '';
        for (Schema.SObjectType CifType : mapCifIds.keySet()) {
            currentRecs = new List<SObject>();
            tempIdList = mapCifIds.get(CifType);
            constructedQuery = 'SELECT Name FROM ' + String.escapeSingleQuotes(String.valueOf(CifType)) + ' WHERE Id in :tempIdList';
            currentRecs = Database.query(constructedQuery);
            if(currentRecs.size() > 0) {
                foundRecs.addall(currentRecs);
            }
        }
        return foundRecs;
    }

    @TestVisible
    private static void cleanupIfRequired(final String value) {
        try {
            final Long num = Long.valueOf(value);
            if (0 == Math.mod(num, CLEANUP_THRESHOLD)) {
                // run cleanUp logic once every NNN records
                cleanUp();
            }
        } catch (Exception e) {
            // clean-up is not very important
            // failure to convert to number must not interfere with the rest of the logic
            System.debug('CifGenerator: failed to cleanup after value: ' + value);
            System.debug(e);

        }
    }

    public static String generateRandomString() {
        final String chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
        final String charInteger = '23456789';
        String randStr1 = '';
        String randStr2 = '';
        String randStr3 = '';
        String finalrandStr = '';
        while (randStr1.length() < 2) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), 31);
            randStr1 += chars.substring(idx, idx+1);
        }
        while (randStr2.length() < 2) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), 8);
            randStr2 += charInteger.substring(idx, idx+1);
        }
        while (randStr3.length() < 1) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), 31);
            randStr3 += chars.substring(idx, idx+1);
        }
        finalrandStr=randStr1+randStr2+randStr3;
        system.debug('######CODE####' +  finalrandStr);
        return finalrandStr;
    }

}