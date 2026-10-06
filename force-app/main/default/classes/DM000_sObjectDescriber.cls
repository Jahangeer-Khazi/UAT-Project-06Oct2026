/**
* @author ANISS MBARKI
* @date Création 14/12/2021
* @date Modification 
* @description Datas Manager 000 - Management of queries on all objects (sObjects)
*/
global class DM000_sObjectDescriber {

    global static final Map <String, Schema.SObjectType> schemaMap;
    static {
        schemaMap = Schema.getGlobalDescribe();
    }


    global static String constructFieldListForQueryFrom(String sObjectName) {
        List<String> fieldsList = getFieldsListFor(sObjectName);
        String fieldsQuery = '';
        system.debug('## fieldsList : ' + fieldsList);
        for (String field : fieldsList) {
            fieldsQuery = fieldsQuery + '' + field + ',';
        }
        
        return fieldsQuery.replace(fieldsQuery, fieldsQuery.substring(0, fieldsQuery.length() - 1));
    }

    /**
     * @author ANISS MBARKI
     * @date Création 14/12/2021
     * @date Modification 
     * @description Method used to return a list of fields for a given object
     * @param sObjectName String Name of sObject
     * @return List<String> list of sObject fields as parameter
     */
    global static List<String> getFieldsListFor(String sObjectName) {
        system.debug('## sObject : ' + sObjectName);
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectName).getDescribe().fields.getMap();
        List<String> fieldsList = new List<String>();
        for (Schema.SObjectField sfield : fieldMap.Values()) {
            schema.describefieldresult dfield = sfield.getDescribe();
            fieldsList .add(dfield.getname());
        }
        return fieldsList;
    }

    
    /**
     * @author ANISS MBARKI
     * @date Création 10/01/2022
     * @date Modification 
     * @description Method used to Get recordTypeId by Object Name & Record Type Developer Name
     */
    public static Id recordTypeIdByDevName(string objAPIName, string recTypeDevName){
        Id recTypeId;
        if(String.isNotBlank(objAPIName) && String.isNotBlank(recTypeDevName)){
            recTypeId= Schema.getGlobalDescribe().get(objAPIName).getDescribe().getRecordTypeInfosByDeveloperName().get(recTypeDevName).getRecordTypeId();
        }  
        return recTypeId;  
    }
}