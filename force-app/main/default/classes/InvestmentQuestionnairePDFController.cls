public with sharing class InvestmentQuestionnairePDFController {
    
    public Investment_Questionnaire__c questionnaire {get;set;}
    public List<QuestionWrapper> questions {get;set;}
    public String formattedTodayDate {get;set;}
    public String customerName {get;set;}
    public String customerCIF {get;set;}
    public Map<String, List<QuestionWrapper>> questionsByCategory {get;set;}
    public String errorMessage {get;set;}
    
    public class QuestionWrapper {
        public Integer questionId {get;set;}
        public String questionText {get;set;}
        public String category {get;set;}
        public String type {get;set;}
        public String selectedAnswer {get;set;}
        public String formattedOptions {get;set;}
    }
    
    public InvestmentQuestionnairePDFController(ApexPages.StandardController controller) {
        try {
            Id recordId = controller.getId();
            if (String.isNotBlank(recordId)) {
                loadData(recordId);
            }
        } catch (Exception e) {
            errorMessage = 'Error: ' + e.getMessage();
        }
    }
    
    private void loadData(Id recordId) {
        questionnaire = [
            SELECT Id, Name, CIF__c, Product_Type__c, Customer__c, 
                   Customer__r.Name, Investment_Questionnaire_JSON__c,
                   CreatedDate, CreatedBy.Name
            FROM Investment_Questionnaire__c 
            WHERE Id = :recordId LIMIT 1
        ];
        
        formattedTodayDate = DateTime.now().format('dd/MM/yyyy');
        customerCIF = questionnaire.CIF__c;
        customerName = questionnaire.Customer__r?.Name ?? 'N/A';
        questionsByCategory = new Map<String, List<QuestionWrapper>>();
        
        if (String.isNotBlank(questionnaire.Investment_Questionnaire_JSON__c)) {
            parseJSON();
        }
    }
    
    private void parseJSON() {
        Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(
            questionnaire.Investment_Questionnaire_JSON__c
        );
        
        List<Object> questionList = (List<Object>) jsonData.get('questions');
        questions = new List<QuestionWrapper>();
        
        for (Object qObj : questionList) {
            Map<String, Object> qMap = (Map<String, Object>) qObj;
            
            QuestionWrapper q = new QuestionWrapper();
            q.questionId = Integer.valueOf(qMap.get('questionId'));
            q.questionText = (String) qMap.get('questionText');
            q.category = (String) qMap.get('category');
            q.type = (String) qMap.get('type');
            
            // Get selected answer
            if (qMap.containsKey('selectedAnswer')) {
                q.selectedAnswer = (String) qMap.get('selectedAnswer');
            } else if (qMap.containsKey('selectedAnswers')) {
                List<Object> selected = (List<Object>) qMap.get('selectedAnswers');
                q.selectedAnswer = String.join(selected, '; ');
            }
            
            // Format options
            List<Object> options = (List<Object>) qMap.get('options');
            if (options != null) {
                String formatted = '';
                for (Integer i = 0; i < options.size(); i++) {
                    formatted += (i + 1) + '. ' + options.get(i) + '<br/>';
                }
                q.formattedOptions = formatted;
            }
            
            questions.add(q);
            
            // Group by category
            if (!questionsByCategory.containsKey(q.category)) {
                questionsByCategory.put(q.category, new List<QuestionWrapper>());
            }
            questionsByCategory.get(q.category).add(q);
        }
    }
    
    public List<String> getCategories() {
        if (questionsByCategory == null) return new List<String>();
        List<String> categories = new List<String>(questionsByCategory.keySet());
        categories.sort();
        return categories;
    }
}