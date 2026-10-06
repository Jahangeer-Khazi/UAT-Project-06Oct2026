public class LoanDocuSignDocumentListController {
    
    public String caseId { get; set; }
    public String caseNumber { get; set; }
    public List<DocuSignWrapper> documentList { get; set; }
    
    @AuraEnabled(cacheable=false)
    public static List<DocuSignWrapper> getDocumentList(Id caseId,Boolean fetchAllDocument){
        List<DocuSignWrapper> documentList = new List<DocuSignWrapper>();
        
        Map<Id,Content__c> docMap = new Map<Id,Content__c>();
        System.debug('case id = ' + caseId);
        
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        Case caseObj = [Select Id,CaseNumber,Account.CIF__pc FROM Case WHERE Id =:caseId];
        if(fetchAllDocument){
            for(Content__c cnt : [SELECT Id,Name,Case__c,Document_Model__c,CreatedBy.Name,CreatedDate,Person__r.Name,
                                 LastModifiedDate,Document_Type__c,Case__r.CaseNumber,Region_Flag__c
                                 FROM Content__c WHERE Case__c =: caseId]){
                docMap.put(cnt.Id,cnt);
            }
            
            if(!docMap.isEmpty()){
            	links = [SELECT Id,LinkedEntityId,ContentDocumentId,ContentDocument.Title,
                     ContentDocument.FileExtension,ContentDocument.ContentSize,ContentDocument.CreatedBy.Name 
                     FROM ContentDocumentLink 
                     WHERE LinkedEntityId IN :docMap.keyset()];    
            }
        }
        else {
            links = [SELECT Id,LinkedEntityId,ContentDocumentId,ContentDocument.Title,
                     ContentDocument.FileExtension,ContentDocument.ContentSize,
                     ContentDocument.LastModifiedDate,ContentDocument.CreatedDate,ContentDocument.CreatedBy.Name 
                     FROM ContentDocumentLink 
                     WHERE LinkedEntityId =:caseId];
        }
        
		        
        if(links.isEmpty()) return documentList;
        
        if(!links.isEmpty()){
            Integer sno = 1;
            for(ContentDocumentLink cdl :links){
           		documentList.add(new DocuSignWrapper(sno,docMap.get(cdl.LinkedEntityId),cdl,caseObj));
                sno++;
            }   
        }
        
        return documentList;
    }

    @AuraEnabled(cacheable=true)
    public static List<fileDataWrapper> getFileData(String caseId) {
        List<fileDataWrapper> fileData = new List<fileDataWrapper>();
        
        List<DocuSignWrapper> docList = new List<DocuSignWrapper>();
        for(DocuSignWrapper doc :  getDocumentList(caseId,true)){
            if(doc.documentType != 'DocuSign Document'){
                docList.add(doc);
            }
        }
        
        String summary = getCalculationSummaryPDF(caseId);
        fileData.add(new fileDataWrapper('CalculationSummary',summary));
        
        docList.addAll(getDocumentList(caseId,false));
        String loanSummary = getLoanPaymentSummary(caseId);
        
        
        if(docList.isEmpty()){
        	if(loanSummary != ''){
                fileData.add(new fileDataWrapper('LoanSummary',loanSummary));
            }
            return fileData;
        } 
        
        
        Set<Id> contentDocumentIds = new Set<Id>();
        for(DocuSignWrapper contentDoc :docList){
            contentDocumentIds.add(contentDoc.contentDocumentId);
        }
        
        for(ContentVersion cv : [SELECT Id, VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds ORDER BY CreatedDate DESC]){
            System.debug('cv ' + cv.FileExtension);
            if(cv.FileExtension == 'pdf'){
            	String base64Data = EncodingUtil.base64Encode(cv.VersionData);
                fileData.add(new fileDataWrapper('DocuSign',base64Data));
            }
        }
        
        if(loanSummary != ''){
            fileData.add(new fileDataWrapper('LoanSummary',loanSummary));
        } 
        
    	return fileData;
    }
    
    public static String getLoanPaymentSummary(String caseId){
        PageReference pdfPage = Page.loanPaymentScheduleVF;
        String encodedCaseId = EncodingUtil.base64Encode(Blob.valueOf(caseId));
        String encodedPageName = EncodingUtil.base64Encode(Blob.valueOf('case'));
        pdfPage.getParameters().put('caseId', encodedCaseId);
        pdfPage.getParameters().put('pageName',encodedPageName);
        Blob pdfBlob;
        
        try {
            pdfBlob = pdfPage.getContentAsPDF();
            String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
        	return base64Pdf;
        } catch (Exception e) {
            System.debug('Error -->'+e.getMessage());
            System.debug('Error Line -->'+e.getLineNumber());
            return '';
        }
        
        
    }
    
    public static String getCalculationSummaryPDF(String caseId){
        PageReference pdfPage = Page.LoanCalculationSummary;
        pdfPage.getParameters().put('id', caseId);
        Blob pdfBlob;
        
        try {
            pdfBlob = pdfPage.getContentAsPDF();
        } catch (Exception e) {
            System.debug('Error -->'+e.getMessage());
            System.debug('Error Line -->'+e.getLineNumber());
        }
        
        String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
        return base64Pdf;
    }
    
    public static String getDocuSignPDF(String caseId){
        PageReference pdfPage = Page.VF02_CalculationSummaryReportPdf;
        pdfPage.getParameters().put('id', caseId);
        Blob pdfBlob;
        
        try {
            pdfBlob = pdfPage.getContentAsPDF();
        } catch (Exception e) {
            System.debug('Error -->'+e.getMessage());
            System.debug('Error Line -->'+e.getLineNumber());
        }
        
        String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
        return base64Pdf;
    }
    
    public class fileDataWrapper {
        @AuraEnabled
        public String fileTitle { get; set; }
        
        @AuraEnabled
        public String fileData { get; set; }
        
        public fileDataWrapper(String title, String fData){
            this.fileTitle = title;
            this.fileData = fData;
        }
    }
    
    public class DocuSignWrapper {
        
        @AuraEnabled
        public Integer sno { get; set; }
        
        @AuraEnabled
        public String fileTitle { get; set; }
        
        @AuraEnabled
        public String fileExt { get; set; }
        
        @AuraEnabled
        public String caseNumber { get; set; }
        
        @AuraEnabled
        public String contentName { get; set; }
        
        @AuraEnabled
        public String regionFlag { get; set; }
        
        @AuraEnabled
        public String documentModel { get; set; }
        
        @AuraEnabled
        public String contentDocumentId { get; set; }
        
        @AuraEnabled
        public String contentDocumentLinkId { get; set; }
        
        @AuraEnabled
        public String ownerName { get; set; }
        
        @AuraEnabled
        public String fileSize { get; set; }
        
        @AuraEnabled
        public String documentType { get; set; }
        
        @AuraEnabled
        public Date lastModifiedDate { get; set; }
        
        @AuraEnabled
        public Date createdDate { get; set; }
        
        @AuraEnabled
        public String signerName { get; set; }
        
        @AuraEnabled
        public String fileName {
            get {
                return fileTitle;
            }
            private set;
        }
        
        @AuraEnabled
        public String documentURL {
            get {
                return  URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/ContentDocument/' + contentDocumentId + '/view#/';
            }
            private set;
        }

        public DocuSignWrapper(Integer sno,Content__c contentObj,ContentDocumentLink cdl,Case caseObj) {
            this.sno = sno;
            this.documentType = contentObj == null ? '' : contentObj.Document_Type__c;
            this.fileTitle = cdl.ContentDocument.Title;
            this.fileExt = cdl.ContentDocument.FileExtension;
            this.contentDocumentId = cdl.ContentDocumentId;
            this.contentDocumentLinkId = cdl.Id;
            this.caseNumber = caseObj.CaseNumber;
            this.contentName = contentObj == null ? 'Signed' : contentObj.Name;
            this.regionFlag = contentObj == null ? '' : contentObj.Region_Flag__c;
            this.documentModel = contentObj == null ? '' : contentObj.Document_Model__c;
            this.ownerName = contentObj == null ? cdl.ContentDocument.CreatedBy.Name : contentObj.CreatedBy.Name;
            this.fileSize = ((Decimal)cdl.ContentDocument.ContentSize / 1024 / 1024).setScale(2) + ' MB';
            this.lastModifiedDate = contentObj == null ? cdl.ContentDocument.LastModifiedDate.date() : contentObj.LastModifiedDate.date();
            this.createdDate = contentObj == null ? cdl.ContentDocument.CreatedDate.date() : contentObj.CreatedDate.date();
            this.signerName = caseObj.Account.CIF__pc;
            Map<String,String> partialFileNames = new Map<String,String>();
            partialFileNames.put('personalloanstermsandcondition','Personal Loans Terms and Condition');
            partialFileNames.put('taxinvoice','Tax Invoice');
            partialFileNames.put('ilamanagercheque','ila Manager Cheque');
            partialFileNames.put('certificateofcompletion','Certificate Of Completion');
            partialFileNames.put('promissorynote','Promissory Note - ila');
            partialFileNames.put('loandetailedrepaymentscheduleform','Loan Detailed Repayment Schedule Form');
            partialFileNames.put('personalloanagreemen','Personal Loan Agreemen');
            partialFileNames.put('loanapplicationform','Loan Application Form');
            
            for(String key :partialFileNames.keyset()){
                //System.debug('file Name FF before ' + cdl.ContentDocument.Title.toLowerCase());
                String fName = cdl.ContentDocument.Title.toLowerCase().trim();
                fName = fName.replaceAll('\\s','').replaceAll('\'s','').replace('_','');
                //System.debug('file Name FF after ' + fName + ' KEY = ' + key);
                if(fName.contains(key)){
                    System.debug('file Name FF after ' + fName);
                    if(contentObj == null){
                        this.contentName = partialFileNames.get(key);
                    }
                    break;
                }
            }
        }
    }
    
}