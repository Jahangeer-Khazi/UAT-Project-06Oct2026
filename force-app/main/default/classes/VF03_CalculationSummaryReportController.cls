/**
 *  @author: Imane Tsioucha
 *  @date: 2023-03-14  
 *  @description: Apex Class for VF VF03_CalculationSummaryReportPdfSecured
 *         #CH01: By Imane Tsioucha ==> Date: 29/05/2023
 */
public with sharing class VF03_CalculationSummaryReportController {

    static Id id = ApexPages.currentPage().getParameters().get('id');
    public Case cs ;
    public Decimal ratio { get;  set; }
    public Integer age {get; set;}   
    public Integer Agee {get; set;}   
    private final Case caseRecord;

    public VF03_CalculationSummaryReportController(ApexPages.StandardController controller) {
        Decimal calcul=0;
        Set<Id> listIds=new Set<Id>();
        listIds.add(id);
        List<Case> cases = DM002_Case.getListByIds(listIds);
        
        for (Case cs : cases){
            //CH01: Calculation of Age of Multiples on VF03_CalculationSummaryReportPdf
            if(cs.cc_Date_of_Birth__c!=null){
                Date expiryDate;
                if (String.isNotBlank(cs.cc_Date_of_Birth__c)) {
                    List<String> parts = cs.cc_Date_of_Birth__c.split('/');
                    if (parts.size() == 3) {
                        expiryDate = Date.newInstance(Integer.valueOf(parts[2]), Integer.valueOf(parts[1]), Integer.valueOf(parts[0]));
                    } else {
                        expiryDate = Date.valueOf(cs.cc_Date_of_Birth__c);
                    }
                    Date startDate = expiryDate;
                    Date dueDate = Date.today();
                    Agee = startDate.monthsBetween(dueDate)/12;
                    age=Agee;
                }
            }else{
                Agee=0;
            }
            
            calcul = (cs.ccol_Approved_Hold_Amount__c != null &&  cs.cc_Approved_Credit_Limit__c!=null && cs.cc_Approved_Credit_Limit__c> 0 ) ? cs.ccol_Approved_Hold_Amount__c / cs.cc_Approved_Credit_Limit__c * 100 : 0;
            ratio=calcul.setScale(3);
            age =(cs.cc_Date_of_Birth__c!=null)? Agee :0; 
           

        }
        
    }
     //CH01:List of Content files linked on Case on VF03_CalculationSummaryReportPdf
     public static List<Content__c> getCaseDocuments() {
        List<Content__c> documents= new List<Content__c>();
        Set<Id> listCaseId=new Set<Id>();
        Set<Id> listIds=new Set<Id>();
        listIds.add(id);
        List<Case> cases = DM002_Case.getListByIds(listIds);
       for (Case cs : cases){
        listCaseId.add(cs.Id);
          
        }
        documents = [SELECT Id, Name,Document_Type__c, CreatedDate FROM Content__c WHERE Case__c IN :listCaseId];
        return documents;

    }
     //CH01:List of files linked on Case on VF03_CalculationSummaryReportPdf
     public static List<ContentDocumentLink> getCaseFiles() {
        List<ContentDocumentLink> files = new List<ContentDocumentLink>();
        Set<Id> listIds = new Set<Id>();
        Set<Id> listCaseId=new Set<Id>();
        listIds.add(id);
        List<Case> cases = DM002_Case.getListByIds(listIds);
        
        for (Case cs : cases) {
            listCaseId.add(cs.Id);
        }
        //GET USER iD OF SYSTEM
        Id userId=[SELECT Id FROM User WHERE Name='System' ].Id;
        
        files = [
            SELECT ContentDocument.Id, ContentDocument.Title, ContentDocument.LastModifiedDate
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :listCaseId AND ContentDocument.OwnerId != :userId
        ];
        
        return files;
    }
}