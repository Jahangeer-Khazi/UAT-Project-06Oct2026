/**
 * @history Modifications : 
 *       #CH01 : 25/07/2022 Wissal add Account.Region_Flag__pc to soql query
 *       #CH02 : #Imane Tsioucha# #22-02-2024# add x-canary header cadd Account.x_canary__pc in soql query
 */
public class DM002_Case {

    private static String CLASS_NAME = DM002_Case.class.getName();

    public static List<Case> getListByIds(Set<Id> caseIds) {
        PAD.debugLogBegin(CLASS_NAME, 'getListByIds', '[caseIds] :' + caseIds);

        List<Case> caseList = new List<Case>();

        if (caseIds != null && caseIds.size() > 0) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,Account.x_canary__pc FROM Case WHERE Id IN :caseIds';
            caseList = new List<Case>((List<Case>)Database.query(soqlQuery));
        }

        PAD.debugLogEnd(CLASS_NAME, 'getListByIds', '[RESULTS] :' + caseList);

        return caseList;
    }
}