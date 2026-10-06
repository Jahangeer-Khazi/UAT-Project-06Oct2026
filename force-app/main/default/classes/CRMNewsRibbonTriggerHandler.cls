/********************************************************************************************
* @name                 CRMNewsRibbonTriggerHandler
* @description          Handler class for CRMNewsRibbonTrigger
* @date                 15/05/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           15/05/2025     Initial Version
*********************************************************************************************
*/

public class CRMNewsRibbonTriggerHandler {

    public static void beforeUpsert(List<CRM_News_Ribbon__c> records,Map<Id,CRM_News_Ribbon__c> oldMap){
        for(CRM_News_Ribbon__c record: records){
            if(!String.isEmpty(record.Message__c)){
                Pattern specialCharPattern = Pattern.compile(Label.Special_Chars_For_News_Ribbon);
                Matcher patternMatcher = specialCharPattern.matcher(record.Message__c);
				Boolean hasSpecialChars = patternMatcher.find();
                
                if(record.Message__c.contains('&#')){ //&# this code is for emoji, all emoji start with &#
                   record.addError('Special Character / Emoji\'s not allowed.');
                }
                else if(!record.Message__c.contains('&amp;') && hasSpecialChars){
                   record.addError('Special Character / Emoji\'s not allowed.');
                }
                else if(record.Message__c.contains('<img src=') || record.Message__c.contains('</img>')) {
                    record.addError('Image cannot be added in Message.');
                }
                else if(hasSpecialChars){
                    record.addError('Special Character / Emoji\'s not allowed.');
                }
            }
        }
    }
}