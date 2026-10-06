/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date:15-03-2023
* 		Change History: 
* 	 							  
*/
public class ConvertCustomerNameToCamelCase {
    public static String convert(String strToConvertIntoCamelCase) {
        strToConvertIntoCamelCase = strToConvertIntoCamelCase.toLowerCase();
        List<String> lstStringHoldingCamelCase = new List<String>();
        for(String s : strToConvertIntoCamelCase.split(' ')) {
            s = s.capitalize();
            lstStringHoldingCamelCase.add(s);
        }
        System.debug('List of String:'+lstStringHoldingCamelCase);
        return String.join(lstStringHoldingCamelCase, ' ');
    }
}