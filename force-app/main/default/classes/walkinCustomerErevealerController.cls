public without sharing class walkinCustomerErevealerController {
    public Case caseRec {get;set;}
    public Content__c contentDoc {get;set;}
    public String cntID {get;set;}
    public String caseID {get;set;}
    public transient Blob pdfFileBody{get;set;}
    public String fileName{get;set;}
    public String emailAddress{get;set;}
    public string pdfAsString{get;set;}
    public Attachment contentAttachment { get; set; }
    public String attachmentId {get;set;}
    public String cattachmentId {get;set;}
    public String battachmentId {get;set;}
    public String ImgattachmentId {get;set;}
    public String cprattachmentId {get;set;}
    public List<Account>accRec{get;set;}
    public string Norerun{get;set;}
    public Date Today { get { return Date.today(); }}
    public List<Map<String, String>> pdfFilesWithIds {get;set;}
    public walkinCustomerErevealerController() {
        Norerun = ApexPages.currentPage().getParameters().get('Norerun');
    }
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}
    public String reqCase { get; set; }
    public String reqSign { get; set; }
    public void saveRequest() {
        List<Case> caselist=[Select Id,AccountId,Account.Name,Account.CIF__pc,case_model__c From Case where CaseNumber=:reqCase and Type='Walkin Customer' and Status!='Closed'];
        if(caselist.size() > 0){
            caseRec=caselist[0];
            accRec=[Select Id, Name, CIF__pc,PersonMobilePhone,subscription_Model__pc From Account where Id=:caseRec.AccountId];
        }
        System.debug('caseLis##'+accRec);
        
    }
    public PageReference processRequest() {
        Content__c con= New Content__c ();
        con.Person__c=caseRec.AccountId;
        con.Case__c=caseRec.Id;
        con.Document_Model__c=accRec[0].subscription_Model__pc=='alburaq'?'alburaq':'ila';
        con.Attachment_Type__c='html';
        con.Document_Type__c='CPR Extract';
        con.Region_Flag__c='Bahrain';
        con.Upload_Type__c='Manual';
        con.Scan_Type__c='POI';
        con.Service_Center_Extract__c=True;
        insert con;
        contentDoc=con;
        cntID=caseRec.Id;
        Attachment myAttach = new Attachment();   
        myAttach.name = 'CPR_Extract_'+accRec[0].CIF__pc+'.html';
        myAttach.ParentId =con.Id;
        myAttach.body =pdfFileBody;       
        try{
            insert myAttach;
        }catch (DMLException e)
        {
            System.debug('error'+e.getMessage());
        }
        string url = '/apex/walkinCustomer_CustomerSignature?attachmentId='+myAttach.Id+'&pageNo=1';
        PageReference page = new PageReference(url);
        page.setRedirect(true);
        return page;
        
    }
    public void customerSignature()
    {
        cprattachmentId = Apexpages.currentPage().getParameters().get('attachmentId');
        pdfAsString = [SELECT Id, body FROM Attachment WHERE Id=:cprattachmentId].body.tostring();
        Attachment CvInfo =[Select Id,ParentId from Attachment Where Id=:cprattachmentId];
        Content__c cn=[Select Id,Case__c from content__c where ID=:CvInfo.ParentId];
        cntID=CvInfo.Id;
        caseID=cn.Case__c;
        
    }
    
    public PageReference GeneratePdf() {
        if(Norerun == 'No'){
            return null;
        }
        Id caseRecId=Apexpages.currentPage().getParameters().get('caseId');
        cattachmentId =Apexpages.currentPage().getParameters().get('cresult');
        battachmentId =Apexpages.currentPage().getParameters().get('bresult');
        ImgattachmentId =  Apexpages.currentPage().getParameters().get('imgresult');
        emailAddress = Apexpages.currentPage().getParameters().get('emailAddress');
        Case caselist=[Select Id,AccountId,Account.Name,Account.CIF__pc,Account.subscription_Model__pc From Case where Id=:caseRecId];
        Content__c con= New Content__c ();
        con.Person__c=caselist.AccountId;
        con.Case__c=caselist.Id;
        con.Document_Model__c=caselist.Account.subscription_Model__pc=='alburaq'?'alburaq':'ila';
        con.Attachment_Type__c='PDF';
        con.Document_Type__c='CPR Extract';
        con.Region_Flag__c='Bahrain';
        con.Upload_Type__c='Manual';
        con.Scan_Type__c='POI';
        con.Service_Center_Extract__c=True;
        insert con;
        PageReference reportPage = Page.walkinCustomerErevealerPDFVFPage;
        reportPage.getParameters().put('cresult',cattachmentId);
        reportPage.getParameters().put('bresult',battachmentId);
        reportPage.getParameters().put('caseId',caseRecId);
        reportPage.getParameters().put('imgresult',ImgattachmentId);
        reportPage.getParameters().put('emailAddress',emailAddress);
        reportPage.getParameters().put('Norerun','No');
        String Norerun=reportPage.getParameters().get('Norerun');
        Blob reportPdf;
        String pdfFile;
        ContentVersion cv = New ContentVersion();
        //Attachment a = new Attachment();   
        try {
            reportPdf = reportPage.getContentAsPDF();
            cv.VersionData=reportPDF;
            cv.title='Valid_CPRExtract_'+caselist.Account.CIF__pc;
            cv.PathOnClient='Attested_SCAN_COPY.PDF';
            cv.FirstPublishLocationId=con.Id;
            insert cv;
        }
        catch (Exception e) {
            reportPdf = Blob.valueOf(e.getMessage());
            System.debug(e.getMessage());
            pdfFile=EncodingUtil.convertToHex(Blob.valueOf(e.getMessage()));
        }
        
        return null; 
        
    }
    @RemoteAction
    public static string GenerateImage(string dataurl,string OffdataUrl,Id caseRecId,String imgData){
        Case caselist=[Select Id,AccountId,Account.Name,Account.CIF__pc,Account.subscription_Model__pc From Case where Id=:caseRecId];
        Content__c con= New Content__c ();
        con.Person__c=caselist.AccountId;
        con.Case__c=caselist.Id;
        con.Document_Model__c=caselist.Account.subscription_Model__pc=='alburaq'?'alburaq':'ila';
        con.Attachment_Type__c='PNG';
        con.Document_Type__c='CPR Extract';
        con.Region_Flag__c='Bahrain';
        con.Upload_Type__c='Manual';
        con.Scan_Type__c='POI';
        con.Service_Center_Extract__c=True;
        insert con;
        String pdfFile = EncodingUtil.convertToHex(((Blob) EncodingUtil.base64Decode(dataurl.split(',')[1])));
        Attachment cusAttach = new Attachment();   
        cusAttach.name = 'ApplicantSignature.png';
        cusAttach.ParentId =con.Id;
        cusAttach.body =(Blob)EncodingUtil.base64Decode(dataurl.replaceFirst('data:image/png;base64,',''));
        insert cusAttach;
        String pdfFile2 = EncodingUtil.convertToHex(((Blob) EncodingUtil.base64Decode(OffdataUrl.split(',')[1])));
        Attachment BankAttach = new Attachment();   
        BankAttach.name = 'BankAuthority.png';
        BankAttach.ParentId =con.Id;
        BankAttach.body =(Blob)EncodingUtil.base64Decode(OffdataUrl.replaceFirst('data:image/png;base64,',''));
        insert BankAttach; 
        Attachment myAttach2 = new Attachment();   
        myAttach2.name = 'CPRExtract_'+caselist.Account.CIF__pc+'.png';
        myAttach2.ParentId =con.Id;  //Add ID of the parent object for the attachment (Account,Contact,etc..)
        myAttach2.body =(Blob)EncodingUtil.base64Decode(imgData.replaceFirst('data:image/png;base64,',''));
        insert myAttach2;
        return cusAttach.Id+';'+BankAttach.Id+';'+myAttach2.Id;
        
    }
}