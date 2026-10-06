public with sharing class InvestmentQuestionnaireQuickAction {
    
    @AuraEnabled
    public static String generatePDFUrl(Id recordId) {
        try {
            // Create the PDF URL
            PageReference pdfPage = Page.InvestmentQuestionnairePDF;
            pdfPage.getParameters().put('id', recordId);
            
            // Return the URL
            return pdfPage.getUrl();
        } catch (Exception e) {
            throw new AuraHandledException('Error generating PDF: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Investment_Questionnaire__c getQuestionnaireDetails(Id recordId) {
        return [
            SELECT Id, Name, CIF__c, Product_Type__c, Customer__c,
                   Customer__r.Name, Customer__r.CIF__pc,
                   Investment_Questionnaire_JSON__c
            FROM Investment_Questionnaire__c
            WHERE Id = :recordId
            LIMIT 1
        ];
    }
}