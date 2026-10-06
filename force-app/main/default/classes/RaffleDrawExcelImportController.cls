/**
 * Created by Himanshu on 14/01/2022.
 */
public without sharing class RaffleDrawExcelImportController {
    private final static String AWS_CALLOUT = 'callout:AWS_S3';  //callout:AWS_S3_Test  callout:AWS_S3
    public virtual class RaffleDrawException extends Exception {
    }
    @AuraEnabled(cacheable=false)
    public static FileData getAWSFileContent(String fileName) {
        try {
            System.debug('File content callout');
            HttpRequest req = new HttpRequest();
            req.setEndpoint(AWS_CALLOUT + '/' + fileName);  //AWS_S3 : https://abcbank-454462831927.s3-accesspoint.eu-west-2.amazonaws.com/
            req.setMethod('GET');
            req.setHeader('Content-type', 'application/vnd.ms-excel');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                System.debug('File content callout SUCCESS');
                FileData data = new FileData();
                data.Content = res.getBody();
                return data;
            }
        } catch (RaffleDrawException e) {
            throw new AuraHandledException('Aura Handle Exception' + e.getMessage());
        }
        return null;
    }
    @AuraEnabled(cacheable=false)
    public static List<String> getAWSService() {
        System.debug('File Metadata callout');
        List<string> fileNames = new List<string>();
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(AWS_CALLOUT);
            req.setMethod('GET');
            req.setHeader('Content-type', 'application/vnd.ms-excel');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('File Metadta Body >> \n ');  //For CSV it is simple
            if ((res.getStatusCode() == 200 || res.getStatusCode() == 201) && String.isNotEmpty(res.getBody())) {
                DOM.Document doc = res.getBodyDocument();
                for (Dom.XmlNode node : doc.getRootElement().getChildElements()) {
                    //System.debug('Node --->' + node.getName());
                    for (Dom.XmlNode contentChildNode : node.getChildElements()) {
                        if (contentChildNode.getName() == 'Key' && contentChildNode.getText().startsWithIgnoreCase('Draw/') && contentChildNode.getText().endsWithIgnoreCase('csv')) {
                            String fnames = contentChildNode.getText();
                            fileNames.add(fnames);
                        }
                    }
                }
                System.debug('filenames--->' + fileNames);
                return fileNames;
            } else {
                System.debug(LoggingLevel.Error, 'No file found');
                return fileNames;
            }
        } catch (RaffleDrawException e) {
            throw new AuraHandledException('Aura Handle Exception' + e.getMessage());
        }
    }
    @AuraEnabled(cacheable=false)
    //public static String parseFile(String base64Data, String drawId) {  //for excel
    public static Boolean parseFile(String csvDataString, String drawId) {
        System.debug('In ParseFile length : ' +csvDataString.length());
        try {
            //Blob blobData = Blob.valueOf(base64Data);
            Draw__c draw = [SELECT Id, Status__c FROM Draw__c WHERE Id = :drawId];
            if (draw.Status__c == 'New') {
                //createDrawEntriesRecords(blobData, drawId);
                return createDrawEntriesFromCSVData(csvDataString, drawId);
            } else {
                System.debug('In order to upload the draw entries, draw status must be New');
                throw new RaffleDrawException('Error: In order to upload the draw entries, draw status must be New.');
            }
        } catch (Exception e) {
            System.debug('RaffleDrawException::::' + e.getMessage());
            throw new RaffleDrawException(e.getMessage());
        }
    }
    public static Boolean createDrawEntriesFromCSVData(String data, String drawId) {
       // List<String> filelines = data.split('\n');  //Split will not work with more than around 3000 records.. "Regex is too complex" error. This is exceeding the hap size
       List<String> filelines = new List<String>();
       filelines = GetFileLines(data);
        System.debug('filelines >> ' +filelines.size());
        //System.debug( 'Before Parsing : Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
        List<Draw_Entry__c> drawEntryList = new List<Draw_Entry__c>();
        List<Account> notEligibleCifs = new List<Account>();
        Set<String> cifs = new Set<String>();
        for (Integer i = 1; i < filelines.size(); i++) {
            if(String.isNotBlank(filelines[i])) {
                List<String> columnValues = new List<String>();
                columnValues = filelines[i].split(',', -1);
                cifs.add(columnValues[1]);  //Cif Number
            }
        }
        //System.debug( 'ON account Parsing : Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
        List<Account> accs = [SELECT Id, CIF__pc, PLA_Eligibility__pc FROM Account WHERE CIF__pc = :cifs  ];
        Map<String, Account> accsWithCif = new Map<String, Account>();
        for (Account acc : accs) {  //AND PLA_Eligibility__pc = 'Yes'
            accsWithCif.put(acc.CIF__pc, acc);
        }
        System.debug('List of Cifs ' + cifs.size() + ' and Accounts ' + accsWithCif.size());
        System.debug( 'After Parsing : Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
        System.debug(LoggingLevel.Error, 'After Parsing : Get limits >> ' +Limits.getLimitCpuTime() + ' CPU Time already spent ' +Limits.getCPUTime());
        for (Integer i = 1; i < filelines.size(); i++) {
            if (String.isNotBlank(filelines[i])) {
                List<String> columnValues = new List<String>();
                columnValues = filelines[i].split(',', -1);
                //As per requirement : https://bank-abc.atlassian.net/browse/NBA-4683
                //columns default order  :
                // 0 -> Draw Reference Id
                // 1 -> CIF, 2 -> total balance , 3 -> Kanz ticket balance
                // 4 -> Total Number of Tickets (No of changes) , 5 -> Issue date , 6 > Last Deposite Date , 7 ->Last Withdraw date
                // 8 -> Status , 9 ->  From Date , 10 -> To Date
                Draw_Entry__c drawEntryRecord = new Draw_Entry__c();
                Account acc = new Account();
                If (!accsWithCif.isEmpty()) {
                    if (accsWithCif.containsKey(columnValues[1])) {
                        acc = accsWithCif.get(columnValues[1]);
                    }
                    //if (acc.PLA_Eligibility__pc == 'Yes') {
                    // drawEntryRecord.Name = columnValues[1];   //Customer_CIF__c is not used anymore
                    // drawEntryRecord.Customer__c = acc.Id != null ? acc.Id : null ;
                     
                    drawEntryRecord.CIF_ID__c = decimal.valueOf(columnValues[1]);
                    drawEntryRecord.Customer__c = acc.Id;
                    drawEntryRecord.Draw__c = drawId;
                    //String data = '2019-01-03T00:26:01.711-02:00';
                    //Datetime dt = (DateTime)JSON.deserialize('"' + data + '"', DateTime.class);
                    drawEntryRecord.Balance__c = String.isNotBlank(columnValues[2]) ? Integer.valueof(columnValues[2].trim()) : null;  //Kanz total balance (or total balance)
                    drawEntryRecord.Kanz_Ticket_Balance__c = String.isNotBlank(columnValues[3]) ? Integer.valueof(columnValues[3].trim()) : null;  //Kanz total balance (or total balance)
                    drawEntryRecord.No_of_Chances__c = String.isNotBlank(columnValues[4]) ? Integer.valueOf(columnValues[4]) : null;  //total number of tickets
                    drawEntryRecord.Issue_Date__c = String.isNotBlank(columnValues[5]) ? Date.parse(columnValues[5].trim().replace('-', '/')) : null;
                    drawEntryRecord.Last_deposit_date__c = String.isNotBlank(columnValues[6]) ? Date.parse(columnValues[6].trim().replace('-', '/')) : null;
                    drawEntryRecord.Last_withdraw_date__c = String.isNotBlank(columnValues[7]) ? Date.parse(columnValues[7].trim().replace('-', '/')) : null;
                    drawEntryRecord.Status__c = String.isNotBlank(columnValues[8]) ? columnValues[8] : null;
                    drawEntryRecord.From_Date__c = String.isNotBlank(columnValues[9]) ? Date.parse(columnValues[9].trim().replace('-', '/')) : null;
                    drawEntryRecord.To_Date__c = String.isNotBlank(columnValues[10]) ? Date.parse(columnValues[10].trim().replace('-', '/')) : null;
                    drawEntryList.add(drawEntryRecord);

                } else {
                    throw new RaffleDrawException('CIFs do not exist. Please make sure all accounts are uploaded with the CIFs');
                    // throw new RaffleDrawException('The CIF ' + columnValues[1] + ' doesn\'t have customer');
                }
            }
        }
        try {
            if (drawEntryList.size() > 0) {
                System.debug('drawEntryList Insert: Get limits >> ' +Limits.getLimitCpuTime() + ' CPU Time already spent ' +Limits.getCPUTime());
                Map<String, SObject> IdToSObjectMap = new Map<String, SObject>();
                Integer index = 0;
                Integer successIndex = 0;
                Database.SaveResult[] srList = Database.insert(drawEntryList, false);
                System.debug('Sr List ' + srList.size());
                Map<String, String> errorMap = new Map<String, String>();
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        //Operation was successful, so get the ID of the record that was processed
                        //System.debug('Successfully inserted Draw Entries ' + sr.getId());
                        successIndex++;
                    } else {
                        // Operation failed, so get all errors and object to insert to a temporary file
                        for (Database.Error err : sr.getErrors()) {
                            //System.debug('Error' + err.getStatusCode() + ' : ' + err.getMessage() + ' >> Fields that affected this error: ' + err.getFields());
                            errorMap.put('record ' + index, err.getMessage());
                            IdToSObjectMap.put('record ' + index, drawEntryList[index]);
                        }
                    }
                    index++;
                }
                //Create a final csv with failed data
                System.debug('Error map : ' + errorMap.size()+ ' Successfully inserted records ' +successIndex);
                Boolean isError = false;
                if (!errorMap.isEmpty()) {
                    return CreateErrorFile(IdToSObjectMap, errorMap, drawId);
                    //throw new RaffleDrawException('Error Please check the csv file'); //Throw will rollback the transaction
                }
            }
        } catch (RaffleDrawException e) {
            System.debug('Exception :: ' + e.getMessage());
            throw new RaffleDrawException(e.getMessage());
        }
        return false; //If all files are uploaded there is no error.
    }
     private static List<String> GetFileLines(String data) {
        Integer lastEnd = 0;
        Integer regexFindLimit = 1000;
        Integer regexFindCount = 0;
        List<String> fileRecords =  new List<String>();
        Matcher m = Pattern.compile('\r\n').matcher(data);
        //Matcher m = Pattern.compile('\n').matcher(data);
        while (!m.hitEnd()) {
            while (regexFindCount < regexFindLimit && !m.hitEnd()) {
                if (m.find()) {
                    //System.debug('m found >> ' + filelines.substring(lastEnd, m.start()) + '\n');
                    fileRecords.add(data.substring(lastEnd, m.start()));
                    lastEnd = m.end();
                } else {
                    fileRecords.add(data.substring(lastEnd));
                    lastEnd = data.length();
                }
                regexFindCount++;
            }
            m.reset(data);
            m.region(lastEnd, m.regionEnd());
            regexFindCount = 0;
        }
        return fileRecords;
    }
    public static Boolean CreateErrorFile(Map<String, SObject> IdToSObjectMap, Map<String, String> errorMap, String drawId) {
        String header = 'CIF , ErrorMessage' + '\n';
        string finalstr = header ;
        for (String recordId : IdToSObjectMap.keySet()) {
            if (IdToSObjectMap.get(recordId) instanceof Draw_Entry__c) {
                Draw_Entry__c drawEntry = (Draw_Entry__c) IdToSObjectMap.get(recordId);
                String error = errorMap.get(recordId);
                string recordString = drawEntry.Name + ',' + error + '. Also please make sure all the accounts PLA_Eligibility__pc set to true \n';
                finalstr += recordString;
            }
        }
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Draw Entries Upload Error List ' + Datetime.now();
        cv.PathOnClient = 'Errors' + Datetime.now() + '.csv';
        cv.VersionData = Blob.valueOf(finalstr);
        Insert cv;
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        //Create ContentDocumentLink
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = drawId;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        insert cdl;
        return true;
    }
    public class FileData {
        @AuraEnabled
        public string Content { get; set; }
        @AuraEnabled
        public blob ContentBlob { get; set; }
        @AuraEnabled
        public string ContentType { get; set; }
    }
}