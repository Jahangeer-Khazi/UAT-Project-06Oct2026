public class GenerateCSVFile {
    
    
    public static Id createFile(String versionData, String title) {
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; //denotes it resides on Salesforce
        cv.Title = title; //title of the file
        cv.PathOnClient = title; // full path within Salesforce this can just be the name of file to be in the library
        cv.VersionData = Blob.valueOf(versionData); //file data
        insert cv;
        return cv.Id;
    }
    
    /**
@description private method for looping through and creating the CSV string from a list of sOBjects
*/
    private static String createSObjectString(List<String> csvFieldAPINames, List<sObject> csvRowList, String concantenatedStr){
        Integer i = 0;
        Integer rowListSize = csvRowList.size();
        Integer headerSize = csvFieldAPINames.size();
        for(sObject row :csvRowList){
            //assuming the rowList is in the correct format and each string in the list is a new record
            Map<String,Object> objFieldMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(row));
            Integer j = 0;
            for(String objField :csvFieldAPINames){
                if(objField!='cc_Nationality__c' && objField!='Account.Passport_Number__pc'){
                    if(objField=='ID_Type__c'){
                        if(objFieldMap.get(objField)=='Bahraini ID'){
                            concantenatedStr += objFieldMap.get(objField) != null ? 'CPR' : '';
                        }else if(objFieldMap.get(objField)=='Passport'){
                            concantenatedStr += objFieldMap.get(objField) != null ? 'Passport -'+objFieldMap.get('cc_Nationality__c'): '';
                        }else if(objFieldMap.get(objField)=='GCC ID'){
                            concantenatedStr += objFieldMap.get(objField) != null ? 'GCC ID -'+objFieldMap.get('cc_Nationality__c') : '';
                        } 
                    }else if(objField=='ID_Number__c'){
                        if((objFieldMap.get('ID_Type__c')=='Bahraini ID')||(objFieldMap.get('ID_Type__c')=='GCC ID')){
                            concantenatedStr += objFieldMap.get('ID_Number__c') != null ? objFieldMap.get('ID_Number__c') : '';
                        }
                        else if(objFieldMap.get('ID_Type__c')=='Passport'){
                            concantenatedStr += objFieldMap.get('Account.Passport_Number__pc') != null ? objFieldMap.get('Account.Passport_Number__pc'): '';
                        }
                    }else{
                        concantenatedStr += objFieldMap.get(objField) != null ? String.valueOf(objFieldMap.get(objField)) : '';
                    }
                }
                j++;
                concantenatedStr += j != headerSize ? ',' : '';//add comma separator
            }
            i++;
            if(i != rowListSize) concantenatedStr += '\n';//add new line
        }
        return concantenatedStr;
    }
    
    /**
@description create a CSV from a list of sObjects in this method the CSV headers different than the api names of the fields to add
*/
    public static Id createCSV(List<String> csvHeaders, List<String> csvFieldAPINames, List<sObject> csvRowList, String title){
        String headerRow = String.join(csvHeaders,',') + '\n';
        String concantenatedStr = headerRow;
        concantenatedStr = createSObjectString(csvFieldAPINames, csvRowList, concantenatedStr);
        title += '.csv';
        return createFile(concantenatedStr, title);
    }
    /**  @description private method for looping through and creating the CSV string from a list of sOBjects
*/
    private static String createSObjectStringCustom(List<String> csvFieldAPINames, List<Object> csvRowList, String concantenatedStr){
        Integer i = 0;
        Integer rowListSize = csvRowList.size();
        Integer headerSize = csvFieldAPINames.size();
        for(Object row :csvRowList){
            //assuming the rowList is in the correct format and each string in the list is a new record
            Map<String,Object> objFieldMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(row));
            Integer j = 0;
            for(String objField :csvFieldAPINames){
               // concantenatedStr += objFieldMap.get(objField) != null ? String.valueOf(objFieldMap.get(objField)) : '';
                if(objField!='bs_Nationality' && objField!='bs_passportNumber'){
                    if(objField=='bs_IDType'){
                        if(objFieldMap.get(objField)=='Bahraini ID'){
                            concantenatedStr += objFieldMap.get(objField) != null ? 'CPR' : '';
                        }else if(objFieldMap.get(objField)=='Passport'){
                            concantenatedStr += objFieldMap.get(objField) != null ? 'Passport -'+objFieldMap.get('bs_Nationality'): '';
                        }else if(objFieldMap.get(objField)=='GCC ID'){
                            concantenatedStr += objFieldMap.get(objField) != null ? 'GCC ID -'+objFieldMap.get('bs_Nationality') : '';
                        } 
                    }else if(objField=='bs_IDNumber'){
                        if((objFieldMap.get('bs_IDType')=='Bahraini ID')||(objFieldMap.get('bs_IDType')=='GCC ID')){
                            concantenatedStr += objFieldMap.get('bs_IDNumber') != null ? objFieldMap.get('bs_IDNumber') : '';
                        }
                        else if(objFieldMap.get('bs_IDType')=='Passport'){
                            concantenatedStr += objFieldMap.get('bs_passportNumber') != null ? objFieldMap.get('bs_passportNumber'): '';
                        }
                    }else{
                        concantenatedStr += objFieldMap.get(objField) != null ? String.valueOf(objFieldMap.get(objField)) : '';
                    }
                }
                j++;
                concantenatedStr += j != headerSize ? ',' : '';//add comma separator
            }
            i++;
            if(i != rowListSize) concantenatedStr += '\n';//add new line
        }
        return concantenatedStr;
    }
    
    /**
@description create a CSV from a list of sObjects in this method the CSV headers different than the api names of the fields to add
*/
    public static Id createCSVCustom(List<String> csvHeaders, List<String> csvFieldAPINames, List<Object> csvRowList, String title){
        String headerRow = String.join(csvHeaders,',') + '\n';
        String concantenatedStr = headerRow;
        concantenatedStr = createSObjectStringCustom(csvFieldAPINames, csvRowList, concantenatedStr);
        title += '.csv';
        return createFile(concantenatedStr, title);
    }
}