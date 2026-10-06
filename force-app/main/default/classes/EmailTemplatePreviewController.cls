public with sharing class EmailTemplatePreviewController {
    public String templateBody { get; set; }
    public String caseId { get; set; }
    
    public EmailTemplatePreviewController() {
        String templateId = ApexPages.currentPage().getParameters().get('id');
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        
        if (String.isNotBlank(templateId)) {
            EmailTemplate template = [SELECT Id, HtmlValue, Body 
                                      FROM EmailTemplate 
                                      WHERE Id = :templateId 
                                      LIMIT 1];
            
            // Use HtmlValue if available, otherwise use Body
            String templateContent = String.isNotBlank(template.HtmlValue) 
                ? template.HtmlValue 
                : template.Body;
            
            // Replace merge fields with sample values
            this.templateBody = processMergeFields(templateContent);
        }
    }
    
    public String processMergeFields(String html) {
        String processedHtml = html.replace('{!', '').replace('}', '');
        
        if (String.isNotBlank(caseId)) {
            try {
                Case caseRecord = [SELECT Id, Case_Model__c, Current_First_Name__c FROM Case WHERE Id = :caseId LIMIT 1];
                
                String logoHtml = '';
                if (caseRecord.Case_Model__c == 'ila') {
                    logoHtml = getLogoHtml(
                        'https://images.ctfassets.net/2c8e80nprabl/5cgeqYcj46Yo7Vj76b4Pph/77905df16179591bb8a8a8b3e7d44bca/ilaemails_logo.png',
                        '80',
                        'ILA Logo'
                    );
                } else if (caseRecord.Case_Model__c == 'alburaq') {
                    logoHtml = getLogoHtml(
                        'https://images.ctfassets.net/2c8e80nprabl/1Us2L0VnElhpE6VHi5AakS/f24736241fd9ef3ad5ccda277c26f424/AlBuraq_x_ila__logo___2_.png',
                        '200',
                        'Al Buraq Logo'
                    );
                }
                
                if (String.isNotBlank(logoHtml)) {
                    processedHtml = processedHtml
                        .replace('@{!Case.cc_Case_Create_Date_Time__c}', logoHtml)
                        .replace('@Case.cc_Case_Create_Date_Time__c', logoHtml);
                }
                
                if (String.isNotBlank(caseRecord.Current_First_Name__c)) {
                    processedHtml = processedHtml
                        .replace('@Case.Current_First_Name__c', caseRecord.Current_First_Name__c)
                        .replace('@{!Case.Current_First_Name__c}', caseRecord.Current_First_Name__c);
                }
                
            } catch (Exception e) {
                System.debug('Error processing case record: ' + e.getMessage());
            }
        }
        return processedHtml;
    }
    
    @TestVisible
    private String getLogoHtml(String url, String width, String altText) {
        return '<img src="' + url + '" ' +
            'width="' + width + '" ' +
            'height="auto" ' +
            'alt="' + altText + '" ' +
            'title="' + altText + '" ' +
            'style="display:block; border:0; outline:none; text-decoration:none; -ms-interpolation-mode:bicubic;">';
    }
}