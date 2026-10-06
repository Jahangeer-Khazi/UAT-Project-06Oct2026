/**
 *  @author: Imane Tsioucha
 *  @date: 2023-03-14  
 *  @description: Apex Class for VF VF02_CalculationSummaryReportPdf
 *      #CH01: By Imane Tsioucha ==> Date: 29/05/2023
 */
public with sharing class VF02_CalculationSummaryReportController {

    static Id id = ApexPages.currentPage().getParameters().get('id');
    public Case cs ;
    public Decimal current_DBR {  get;  set; }
    public Decimal ila_creditCard {  get;  set; }
    public Decimal NumberMultiples {  get; set; }
    public Integer age {get; set;}   
    public Integer Agee {get; set;}   
    private final Case caseRecord;
     
  


    public VF02_CalculationSummaryReportController(ApexPages.StandardController controller) {
        Set<Id> listIds=new Set<Id>();
        listIds.add(id);
        List<Case> cases = DM002_Case.getListByIds(listIds);
        for (Case cs : cases){

            Decimal calcul1=0;
            Decimal calcul2=0;
            Decimal calcul3=0;

            //CH01: Calculation of Age of Multiples on VF02_CalculationSummaryReportPdf
            if(cs.cc_Date_of_Birth__c!=null){
                Date expiryDate;
                System.debug('cc_Date_of_Birth__c --->'+cs.cc_Date_of_Birth__c);
                if (String.isNotBlank(cs.cc_Date_of_Birth__c)) {
                    List<String> parts = cs.cc_Date_of_Birth__c.split('/');
                    if (parts.size() == 3) {
                        expiryDate = Date.newInstance(Integer.valueOf(parts[2]), Integer.valueOf(parts[1]), Integer.valueOf(parts[0]));
                    } else {
                        expiryDate = Date.valueOf(cs.cc_Date_of_Birth__c);
                    }
                    System.debug('expiryDate --->'+expiryDate);
                    Date startDate = expiryDate;
                    Date dueDate = Date.today();
                    System.debug('dueDate --->'+dueDate);
                    Agee = startDate.monthsBetween(dueDate)/12;
                    System.debug('Agee --->'+Agee);
                    age=Agee;
                    System.debug('age --->'+age);
                } 
            }else{
                System.debug('else --->');
                Agee=0;
            }
           
           //Calculation for the Current DBR on VF02_CalculationSummaryReportPdf
            calcul1 = (cs.cc_Approved_Salary__c != null && cs.Total_Current_Obligations__c > 0) ? cs.Total_Current_Obligations__c / cs.cc_Approved_Salary__c * 100 : 0;
            current_DBR=calcul1.setScale(2);
            //Calculation for the ila Proposed Credit Card Deduction (5%) on VF02_CalculationSummaryReportPdf
            calcul2 = (cs.cc_Approved_Credit_Limit__c != null) ?  cs.cc_Approved_Credit_Limit__c * 0.05 : 0;
            ila_creditCard=calcul2.setScale(2);
            //Calculation for Number of Multiples on VF02_CalculationSummaryReportPdf
            calcul3 = (cs.cc_Approved_Salary__c != null && cs.cc_Approved_Salary__c >0 && cs.cc_Approved_Credit_Limit__c!=null ) ?  cs.cc_Approved_Credit_Limit__c / cs.cc_Approved_Salary__c : 0;
            NumberMultiples=calcul3.setScale(3);

            age =(cs.cc_Date_of_Birth__c!=null)? Agee :0;     

        }
    }
    //CH01:List of Content files linked on Case on VF02_CalculationSummaryReportPdf
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
    //CH01:List of files linked on Case on VF02_CalculationSummaryReportPdf
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