public with sharing class CasePDFCommentController {

    private static final String EMAIL_POST_TYPE_TOKEN = 'Email';
    private static final String FEED_TYPE_COMMENT = 'CaseCommentPost';
    private static final String FEED_TYPE_HISTORY = 'TrackedChange';
    private static final String FEED_TYPE_CONTENT = 'ContentPost';
    private static final String FEED_TYPE_CREATED = 'CreateRecordEvent';
    private static final String FEED_TYPE_CALL = 'CallLogPost';

    private static final String LABEL_HISTORY_CREATED = 'History Tracking created';
    private static final String LABEL_HISTORY_UPDATED = 'History tracking updated';
    private static final String LABEL_CONTENT_CREATED = 'Content created';
    private static final String LABEL_RECORD_CREATED = 'Record created';
    private static final String LABEL_UNKNOWN_USER = 'Unknown';
    private static final String LABEL_EMPTY_VALUE = '(empty)';
    private static final String DEFAULT_ATTACHMENT_NAME = 'Image';

    public Id caseId { get; set; }

    @AuraEnabled public Case caseRecord { get; private set; }

    @AuraEnabled public String errorMessage { get; private set; }

    private static String cleanBody(String val) {
        if (String.isBlank(val)) return '';
        // Remove image tags completely
        val = val.replaceAll('(?i)<img[^>]*>', '');
        // Clean up leftover empty paragraphs if any
        val = val.replaceAll('(?i)<p>\\s*</p>', '');
        return val.trim();
    }

    // Helper to format call duration as mm:ss
    private static String formatDuration(Integer secs) {
        if (secs == null || secs == 0) return '00:00';
        Integer m = secs / 60;
        Integer s = Math.mod(secs, 60);
        return (m < 10 ? '0' + m : String.valueOf(m)) + ':' + (s < 10 ? '0' + s : String.valueOf(s));
    }

    private static Boolean hasImgAttachment(String rawBody) {
        return String.isNotBlank(rawBody) && rawBody.containsIgnoreCase('<img');
    }

    private static String getImgAttr(String attrs, String attrName) {
        Matcher matcher = Pattern.compile('(?i)' + attrName + '="([^"]*)"').matcher(attrs);
        return matcher.find() ? matcher.group(1) : null;
    }

    private static Boolean isValidExtension(String extension) {
        return String.isNotBlank(extension)
            && extension.length() <= 10
            && !extension.contains(' ')
            && Pattern.matches('[a-zA-Z0-9]+', extension);
    }

    private static String extensionFromFileName(String fileName) {
        if (String.isBlank(fileName) || !fileName.contains('.')) {
            return null;
        }
        String extension = fileName.substring(fileName.lastIndexOf('.') + 1);
        return isValidExtension(extension) ? extension.toLowerCase() : null;
    }

    private static String extensionFromUrl(String url) {
        if (String.isBlank(url)) {
            return null;
        }
        String path = url.contains('?') ? url.substring(0, url.indexOf('?')) : url;
        if (path.contains('/')) {
            path = path.substring(path.lastIndexOf('/') + 1);
        }
        return extensionFromFileName(path);
    }

    public class AttachmentInfo {
        @AuraEnabled public Boolean hasAttachment { get; set; }
        @AuraEnabled public String attachmentName { get; set; }
        @AuraEnabled public String attachmentExtension { get; set; }

        public AttachmentInfo() {
            this.hasAttachment = false;
        }

        public AttachmentInfo(String fileName) {
            this.hasAttachment = true;
            this.attachmentName = fileName;
            this.attachmentExtension = extensionFromFileName(fileName);
        }
    }

    private static Set<String> extractFileIds(String rawBody) {
        Set<String> ids = new Set<String>();
        if (String.isBlank(rawBody)) {
            return ids;
        }
        // ContentVersion (068), ContentDocument (069), classic Attachment (00P)
        Matcher m = Pattern.compile('(?i)(068|069|00P)[a-zA-Z0-9]{12,15}').matcher(rawBody);
        while (m.find()) {
            ids.add(m.group(0));
        }
        return ids;
    }

    // Id → "Title.ext" (or PathOnClient / Attachment.Name)
    private static Map<String, String> buildFileNameMap(List<String> rawBodies) {
        Map<String, String> fileNamesById = new Map<String, String>();
        Set<String> fileIds = new Set<String>();
        for (String rawBody : rawBodies) {
            fileIds.addAll(extractFileIds(rawBody));
        }
        if (fileIds.isEmpty()) {
            return fileNamesById;
        }

        if (Schema.sObjectType.ContentVersion.isAccessible()) {
            for (ContentVersion cv : [
                SELECT Id, ContentDocumentId, Title, PathOnClient, FileExtension
                FROM ContentVersion
                WHERE Id IN :fileIds OR ContentDocumentId IN :fileIds
                WITH SECURITY_ENFORCED
            ]) {
                String label = resolveContentVersionLabel(cv);
                if (String.isNotBlank(label)) {
                    fileNamesById.put(String.valueOf(cv.Id), label);
                    fileNamesById.put(String.valueOf(cv.ContentDocumentId), label);
                }
            }
        }

        if (Schema.sObjectType.Attachment.isAccessible()) {
            for (Attachment att : [
                SELECT Id, Name
                FROM Attachment
                WHERE Id IN :fileIds
                WITH SECURITY_ENFORCED
            ]) {
                if (String.isNotBlank(att.Name)) {
                    fileNamesById.put(String.valueOf(att.Id), att.Name);
                }
            }
        }
        return fileNamesById;
    }

    private static String resolveContentVersionLabel(ContentVersion cv) {
        if (String.isNotBlank(cv.PathOnClient)) {
            return cv.PathOnClient.contains('/')
                ? cv.PathOnClient.substring(cv.PathOnClient.lastIndexOf('/') + 1)
                : cv.PathOnClient;
        }
        String title = String.isNotBlank(cv.Title) ? cv.Title : DEFAULT_ATTACHMENT_NAME;
        if (String.isNotBlank(cv.FileExtension) && !title.toLowerCase().endsWith('.' + cv.FileExtension.toLowerCase())) {
            return title + '.' + cv.FileExtension.toLowerCase();
        }
        return title;
    }

    private static Map<Id, List<AttachmentInfo>> buildEmailAttachments(List<EmailMessage> emailList) {
        Map<Id, List<AttachmentInfo>> attachmentsByEmailId = new Map<Id, List<AttachmentInfo>>();
        if (emailList == null || emailList.isEmpty()) {
            return attachmentsByEmailId;
        }

        Set<Id> emailIds = new Set<Id>();
        for (EmailMessage em : emailList) {
            if (em.HasAttachment) {
                emailIds.add(em.Id);
            }
        }
        if (emailIds.isEmpty() || !Schema.sObjectType.ContentDocumentLink.isAccessible()) {
            return attachmentsByEmailId;
        }

        Map<Id, List<Id>> docsByEmailId = new Map<Id, List<Id>>();
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink cdl : [
            SELECT LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :emailIds
            WITH SECURITY_ENFORCED
        ]) {
            if (!docsByEmailId.containsKey(cdl.LinkedEntityId)) {
                docsByEmailId.put(cdl.LinkedEntityId, new List<Id>());
            }
            docsByEmailId.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
            contentDocumentIds.add(cdl.ContentDocumentId);
        }

        Map<Id, String> labelByDocId = new Map<Id, String>();
        if (!contentDocumentIds.isEmpty() && Schema.sObjectType.ContentVersion.isAccessible()) {
            for (ContentVersion cv : [
                SELECT ContentDocumentId, Title, PathOnClient, FileExtension
                FROM ContentVersion
                WHERE ContentDocumentId IN :contentDocumentIds
                AND IsLatest = true
                WITH SECURITY_ENFORCED
            ]) {
                labelByDocId.put(cv.ContentDocumentId, resolveContentVersionLabel(cv));
            }
        }

        for (Id emailId : docsByEmailId.keySet()) {
            List<AttachmentInfo> infos = new List<AttachmentInfo>();
            Set<String> seenNames = new Set<String>();
            for (Id docId : docsByEmailId.get(emailId)) {
                String label = labelByDocId.get(docId);
                addUniqueAttachment(infos, seenNames, String.isNotBlank(label) ? new AttachmentInfo(label) : new AttachmentInfo(DEFAULT_ATTACHMENT_NAME));
            }
            attachmentsByEmailId.put(emailId, infos);
        }
        return attachmentsByEmailId;
    }

    private static String fileNameFromLookup(String source, Map<String, String> fileNamesById) {
        if (String.isBlank(source) || fileNamesById == null || fileNamesById.isEmpty()) {
            return null;
        }
        for (String fileId : extractFileIds(source)) {
            if (fileNamesById.containsKey(fileId)) {
                return fileNamesById.get(fileId);
            }
        }
        return null;
    }

    private static void addUniqueAttachment(List<AttachmentInfo> results, Set<String> seenNames, AttachmentInfo info) {
        if (info == null || String.isBlank(info.attachmentName)) {
            return;
        }
        String key = info.attachmentName.toLowerCase();
        if (seenNames.contains(key)) {
            return;
        }
        seenNames.add(key);
        results.add(info);
    }

    // Resolves a single <img> tag's attributes into an AttachmentInfo.
    private static AttachmentInfo parseSingleImage(String attrs, Map<String, String> fileNamesById) {
        AttachmentInfo info = new AttachmentInfo();
        info.hasAttachment = true;

        String lookedUp = fileNameFromLookup(attrs, fileNamesById);
        if (String.isNotBlank(lookedUp)) {
            info.attachmentName = lookedUp;
            info.attachmentExtension = extensionFromFileName(lookedUp);
            return info;
        }

        String alt = getImgAttr(attrs, 'alt');
        String src = getImgAttr(attrs, 'src');
        String title = getImgAttr(attrs, 'title');
        String fileName = String.isNotBlank(alt) ? alt : (String.isNotBlank(title) ? title : null);
        String extension = extensionFromFileName(fileName);
        if (String.isBlank(extension)) {
            extension = extensionFromUrl(src);
        }

        if (String.isNotBlank(fileName) && fileName.contains('.')) {
            Integer dotIndex = fileName.lastIndexOf('.');
            String tail = fileName.substring(dotIndex + 1);
            if (isValidExtension(tail)) {
                info.attachmentName = fileName.substring(0, dotIndex) + '.' + tail.toLowerCase();
                info.attachmentExtension = tail.toLowerCase();
                return info;
            }
        }

        String name = String.isNotBlank(fileName) ? fileName : DEFAULT_ATTACHMENT_NAME;
        info.attachmentName = String.isNotBlank(extension) ? name + '.' + extension.toLowerCase() : name;
        info.attachmentExtension = String.isNotBlank(extension) ? extension.toLowerCase() : null;
        return info;
    }

    // Parses every <img> tag and every file Id in the body (not just the first).
    private static List<AttachmentInfo> parseAttachments(String rawBody, Map<String, String> fileNamesById) {
        List<AttachmentInfo> results = new List<AttachmentInfo>();
        Set<String> seenNames = new Set<String>();

        if (hasImgAttachment(rawBody)) {
            Matcher imgMatcher = Pattern.compile('(?i)<img\\s+([^>]+)>').matcher(rawBody);
            Boolean foundTag = false;
            while (imgMatcher.find()) {
                foundTag = true;
                addUniqueAttachment(results, seenNames, parseSingleImage(imgMatcher.group(1), fileNamesById));
            }
            if (!foundTag) {
                addUniqueAttachment(results, seenNames, new AttachmentInfo(DEFAULT_ATTACHMENT_NAME));
            }
        }

        for (String fileId : extractFileIds(rawBody)) {
            String label = (fileNamesById == null) ? null : fileNamesById.get(fileId);
            if (String.isNotBlank(label)) {
                addUniqueAttachment(results, seenNames, new AttachmentInfo(label));
            }
        }
        return results;
    }

    // The first parsed attachment doubles as the single-attachment view the PDF renders
    private static AttachmentInfo primaryAttachment(List<AttachmentInfo> infos) {
        return (infos == null || infos.isEmpty()) ? new AttachmentInfo() : infos[0];
    }

    private static Set<String> attachmentNameKeys(List<AttachmentInfo> infos) {
        Set<String> keys = new Set<String>();
        if (infos == null) {
            return keys;
        }
        for (AttachmentInfo info : infos) {
            if (info != null && String.isNotBlank(info.attachmentName)) {
                keys.add(info.attachmentName.toLowerCase());
            }
        }
        return keys;
    }

    
    private static List<FeedTrackedChange> safeTrackedChanges(FeedItem fi) {
        try {
            return fi.FeedTrackedChanges;
        } catch (SObjectException e) {
            return null;
        }
    }

    private static String formatTrackedChanges(List<FeedTrackedChange> changes) {
        if (changes == null || changes.isEmpty()) {
            return LABEL_HISTORY_UPDATED;
        }
        List<String> parts = new List<String>();
        for (FeedTrackedChange change : changes) {
            String field = change.FieldName;
            if (String.isBlank(field)) {
                continue;
            }
            if (field.contains('.')) {
                field = field.substringAfter('.');
            }
            if (field.equalsIgnoreCase('created')) {
                parts.add(LABEL_RECORD_CREATED);
                continue;
            }
            String oldVal = change.OldValue == null ? LABEL_EMPTY_VALUE : String.valueOf(change.OldValue);
            String newVal = change.NewValue == null ? LABEL_EMPTY_VALUE : String.valueOf(change.NewValue);
            parts.add(field + ' changed from ' + oldVal + ' to ' + newVal);
        }
        return parts.isEmpty() ? LABEL_HISTORY_UPDATED : String.join(parts, '<br/>');
    }

    private static Boolean isHistoryTrackingRecord(Id recordId) {
        return recordId != null && recordId.getSObjectType() == History_Tracking__c.SObjectType;
    }

    private static Boolean isContentRecord(Id recordId) {
        if (recordId == null) {
            return false;
        }
        Schema.SObjectType sobjectType = recordId.getSObjectType();
        return sobjectType == Content__c.SObjectType
            || sobjectType == ContentVersion.SObjectType
            || sobjectType == ContentDocument.SObjectType;
    }

    // Describes each History Tracking record so its feed post reads as a real entry
    private Map<Id, String> loadHistoryTrackingLabels() {
        Map<Id, String> labels = new Map<Id, String>();
        if (!Schema.sObjectType.History_Tracking__c.isAccessible()) {
            return labels;
        }
        for (History_Tracking__c ht : [
            SELECT Id, Name, Field_Name__c, Prior_Value__c, Current_Value__c
            FROM   History_Tracking__c
            WHERE  Case__c = :caseId
            WITH SECURITY_ENFORCED
        ]) {
            String label = LABEL_HISTORY_CREATED;
            if (String.isNotBlank(ht.Name)) {
                label += ': ' + ht.Name;
            }
            if (String.isNotBlank(ht.Field_Name__c)) {
                String priorVal = String.isBlank(ht.Prior_Value__c) ? LABEL_EMPTY_VALUE : ht.Prior_Value__c;
                String currentVal = String.isBlank(ht.Current_Value__c) ? LABEL_EMPTY_VALUE : ht.Current_Value__c;
                label += '<br/>' + ht.Field_Name__c + ' changed from ' + priorVal + ' to ' + currentVal;
            }
            labels.put(ht.Id, label);
        }
        return labels;
    }

    // Content__c is the custom document record, distinct from a Salesforce file
    private Map<Id, String> loadContentLabels() {
        Map<Id, String> labels = new Map<Id, String>();
        if (!Schema.sObjectType.Content__c.isAccessible()) {
            return labels;
        }
        for (Content__c doc : [
            SELECT Id, Name, Document_Type__c
            FROM   Content__c
            WHERE  Case__c = :caseId
            WITH SECURITY_ENFORCED
        ]) {
            String label = LABEL_CONTENT_CREATED;
            if (String.isNotBlank(doc.Document_Type__c)) {
                label += ': ' + doc.Document_Type__c;
            } else if (String.isNotBlank(doc.Name)) {
                label += ': ' + doc.Name;
            }
            labels.put(doc.Id, label);
        }
        return labels;
    }

    public class CommentThread implements Comparable {
        @AuraEnabled public CaseComment comment       { get; set; }
        @AuraEnabled public String      threadKey     { get; set; }
        @AuraEnabled public String      typeLabel     { get; set; }
        @AuraEnabled public Boolean     isPublic      { get; set; }
        @AuraEnabled public Boolean     isInternal    { get; set; }
        @AuraEnabled public Boolean     isHistory     { get; set; }
        @AuraEnabled public Boolean     isContent     { get; set; }
        @AuraEnabled public Boolean     isCreated     { get; set; }
        @AuraEnabled public String      commentBody   { get; set; }
        @AuraEnabled public String      createdByName { get; set; }
        @AuraEnabled public Datetime    createdDate   { get; set; }
        @AuraEnabled public List<ReplyThread> replies { get; set; }
        @AuraEnabled public Boolean  hasAttachment { get; set; }
        @AuraEnabled public String   attachmentName { get; set; }
        @AuraEnabled public String   attachmentExtension { get; set; }
        @AuraEnabled public List<AttachmentInfo> attachments { get; set; }

        public CommentThread(CaseComment cc, Map<String, String> fileNamesById) {
            this.comment       = cc;
            this.threadKey     = cc.Id != null ? String.valueOf(cc.Id) : 'comment';
            this.isPublic      = cc.IsPublished;
            this.isInternal    = !cc.IsPublished;
            this.isHistory     = false;
            this.isContent     = false;
            this.isCreated     = false;
            this.typeLabel     = this.isPublic ? 'Public' : 'Internal';
            String rawBody     = cc.CommentBody != null ? cc.CommentBody : '';
            this.attachments   = parseAttachments(rawBody, fileNamesById);
            this.hasAttachment = !this.attachments.isEmpty();
            AttachmentInfo primary = primaryAttachment(this.attachments);
            this.attachmentName = primary.attachmentName;
            this.attachmentExtension = primary.attachmentExtension;

            this.commentBody   = cleanBody(rawBody);
            this.createdByName = cc.CreatedBy != null ? cc.CreatedBy.Name : LABEL_UNKNOWN_USER;
            this.createdDate   = cc.CreatedDate;
            this.replies       = new List<ReplyThread>();
        }

        public CommentThread(FeedItem fi, Map<String, String> fileNamesById) {
            this(fi, fileNamesById, null);
        }

        // A post is classified by the record it belongs to or points at, because the
        // feed Type alone does not distinguish a History Tracking record from a file
        public CommentThread(FeedItem fi, Map<String, String> fileNamesById, String relatedLabel) {
            this.comment       = null;
            this.threadKey     = fi.Id != null ? String.valueOf(fi.Id) : fi.Type;
            this.isPublic      = false;
            this.isInternal    = false;
            this.isHistory     = FEED_TYPE_HISTORY.equals(fi.Type)
                || isHistoryTrackingRecord(fi.ParentId)
                || isHistoryTrackingRecord(fi.RelatedRecordId);
            this.isContent     = !this.isHistory
                && (FEED_TYPE_CONTENT.equals(fi.Type)
                    || isContentRecord(fi.ParentId)
                    || isContentRecord(fi.RelatedRecordId));
            this.isCreated     = !this.isHistory && !this.isContent;
            this.typeLabel     = this.isHistory
                ? 'History'
                : (this.isContent
                    ? 'Content'
                    : (FEED_TYPE_CREATED.equals(fi.Type) ? 'Created' : 'Post'));
            this.createdByName = fi.CreatedBy != null ? fi.CreatedBy.Name : LABEL_UNKNOWN_USER;
            this.createdDate   = fi.CreatedDate;
            this.replies       = new List<ReplyThread>();
            this.attachments   = new List<AttachmentInfo>();

            if (FEED_TYPE_HISTORY.equals(fi.Type)) {
                this.commentBody = formatTrackedChanges(safeTrackedChanges(fi));
            } else {
                String rawBody = fi.Body != null ? fi.Body : '';
                this.attachments = parseAttachments(rawBody, fileNamesById);
                Set<String> seenNames = attachmentNameKeys(this.attachments);
                if (fi.RelatedRecordId != null) {
                    String lookedUp = fileNameFromLookup(String.valueOf(fi.RelatedRecordId), fileNamesById);
                    if (String.isNotBlank(lookedUp)) {
                        addUniqueAttachment(this.attachments, seenNames, new AttachmentInfo(lookedUp));
                    }
                }
                if (this.isContent && String.isNotBlank(fi.Title)) {
                    addUniqueAttachment(this.attachments, seenNames, new AttachmentInfo(fi.Title));
                }
                this.commentBody = resolveFeedBody(fi, relatedLabel);
            }

            this.hasAttachment = !this.attachments.isEmpty();
            AttachmentInfo primary = primaryAttachment(this.attachments);
            this.attachmentName = primary.attachmentName;
            this.attachmentExtension = primary.attachmentExtension;
        }

        // The related record's own description beats the feed body, which is boilerplate
        // on created-record posts
        private String resolveFeedBody(FeedItem fi, String relatedLabel) {
            if (String.isNotBlank(relatedLabel)) {
                return relatedLabel;
            }
            String cleaned = cleanBody(fi.Body);
            if (String.isNotBlank(cleaned)) {
                return cleaned;
            }
            if (String.isNotBlank(fi.Title)) {
                return this.isContent ? LABEL_CONTENT_CREATED + ': ' + fi.Title : fi.Title;
            }
            if (this.isHistory) {
                return LABEL_HISTORY_CREATED;
            }
            return this.isContent ? LABEL_CONTENT_CREATED : LABEL_RECORD_CREATED;
        }

        public Integer compareTo(Object other) {
            CommentThread that = (CommentThread) other;
            Long thisTime = this.createdDate == null ? 0 : this.createdDate.getTime();
            Long thatTime = that.createdDate == null ? 0 : that.createdDate.getTime();
            if (thisTime == thatTime) {
                return 0;
            }
            return thisTime > thatTime ? -1 : 1;
        }
    }

    public class ReplyThread {
        @AuraEnabled public String  body          { get; set; }
        @AuraEnabled public String  createdBy     { get; set; }
        @AuraEnabled public Datetime createdDate   { get; set; }
        @AuraEnabled public Boolean  hasAttachment { get; set; }
        @AuraEnabled public String   attachmentName { get; set; }
        @AuraEnabled public String   attachmentExtension { get; set; }
        @AuraEnabled public List<AttachmentInfo> attachments { get; set; }

        public ReplyThread(FeedComment fc, Map<String, String> fileNamesById) {
            String rawBody     = fc.CommentBody != null ? fc.CommentBody : '';
            this.attachments   = parseAttachments(rawBody, fileNamesById);
            this.hasAttachment = !this.attachments.isEmpty();
            AttachmentInfo primary = primaryAttachment(this.attachments);
            this.attachmentName = primary.attachmentName;
            this.attachmentExtension = primary.attachmentExtension;

            this.body          = cleanBody(rawBody);
            this.createdBy     = fc.CreatedBy != null ? fc.CreatedBy.Name : LABEL_UNKNOWN_USER;
            this.createdDate   = fc.CreatedDate;
        }
    }

    // ── Email data model
    public class EmailEntry {
        @AuraEnabled public String  subject      { get; set; }
        @AuraEnabled public String  fromName     { get; set; }
        @AuraEnabled public String  fromAddress  { get; set; }
        @AuraEnabled public String  toAddress    { get; set; }
        @AuraEnabled public String  ccAddress    { get; set; }
        @AuraEnabled public Boolean isIncoming   { get; set; }   // true = received, false = sent
        @AuraEnabled public String  directionLabel { get; set; } // 'Inbound' | 'Outbound'
        @AuraEnabled public String  status       { get; set; }
        @AuraEnabled public Datetime messageDate { get; set; }
        @AuraEnabled public Boolean hasAttachment { get; set; }
        @AuraEnabled public String  attachmentName { get; set; }
        @AuraEnabled public String  attachmentExtension { get; set; }

        @AuraEnabled public List<AttachmentInfo> attachments { get; set; }
        @AuraEnabled public List<ReplyThread> replies { get; set; }

        public EmailEntry(EmailMessage em, List<AttachmentInfo> resolvedAttachments) {
            this.subject       = String.isNotBlank(em.Subject)     ? em.Subject     : '(No Subject)';
            this.fromName      = String.isNotBlank(em.FromName)    ? em.FromName    : '';
            this.fromAddress   = String.isNotBlank(em.FromAddress) ? em.FromAddress : '';
            this.toAddress     = String.isNotBlank(em.ToAddress)   ? em.ToAddress   : '';
            this.ccAddress     = String.isNotBlank(em.CcAddress)   ? em.CcAddress   : '';
            this.isIncoming    = em.Incoming;
            this.directionLabel = em.Incoming ? 'Inbound' : 'Outbound';
            this.status        = em.Status;
            this.messageDate   = em.MessageDate;
            this.hasAttachment = em.HasAttachment;
            this.attachments   = resolvedAttachments != null ? resolvedAttachments : new List<AttachmentInfo>();
            this.replies       = new List<ReplyThread>();
            if (em.HasAttachment) {
                if (this.attachments.isEmpty()) {
                    this.attachments.add(new AttachmentInfo(DEFAULT_ATTACHMENT_NAME));
                }
                AttachmentInfo primary = primaryAttachment(this.attachments);
                this.attachmentName = primary.attachmentName;
                this.attachmentExtension = primary.attachmentExtension;
            } else {
                this.attachmentName = null;
                this.attachmentExtension = null;
            }
        }
    }

    // ── Call log data model
    public class CallLogEntry {
        @AuraEnabled public Id       id                { get; set; }
        @AuraEnabled public String   subject           { get; set; }
        @AuraEnabled public String   description       { get; set; }
        @AuraEnabled public String   callType          { get; set; }   // Inbound / Outbound / Internal
        @AuraEnabled public String   callDisposition   { get; set; }
        @AuraEnabled public Integer  callDurationSecs  { get; set; }
        @AuraEnabled public String   callDurationDisplay { get; set; } // formatted mm:ss
        @AuraEnabled public String   status            { get; set; }
        @AuraEnabled public String   createdByName     { get; set; }
        @AuraEnabled public Datetime createdDate       { get; set; }
        @AuraEnabled public Datetime activityDateTime  { get; set; }
        @AuraEnabled public List<ReplyThread> replies  { get; set; }

        public CallLogEntry(Task t) {
            this.id                = t.Id;
            this.subject          = String.isNotBlank(t.Subject) ? t.Subject : '(No Subject)';
            this.description      = String.isNotBlank(t.Description) ? cleanBody(t.Description) : '';
            this.callType          = t.CallType;
            this.callDisposition   = t.CallDisposition;
            this.callDurationSecs  = t.CallDurationInSeconds != null ? Integer.valueOf(t.CallDurationInSeconds) : 0;
            this.callDurationDisplay = CasePDFCommentController.formatDuration(this.callDurationSecs);
            this.status            = t.Status;
            this.createdByName     = t.CreatedBy != null ? t.CreatedBy.Name : LABEL_UNKNOWN_USER;
            this.createdDate       = t.CreatedDate;
            this.activityDateTime  = t.ActivityDate != null ? Datetime.newInstance(t.ActivityDate, Time.newInstance(0,0,0,0)) : null;
            this.replies           = new List<ReplyThread>();
        }
    }

    @AuraEnabled public List<CommentThread> threads { get; private set; }
    @AuraEnabled public Boolean             hasData { get; private set; }
    @AuraEnabled public String              generatedOn { get; private set; }

    // ── Emails exposure
    @AuraEnabled public List<EmailEntry>   emails      { get; private set; }
    @AuraEnabled public Boolean            hasEmails   { get; private set; }

    // ── Call log exposure
    @AuraEnabled public List<CallLogEntry> callLogs    { get; private set; }
    @AuraEnabled public Boolean            hasCallLogs { get; private set; }

    // ── Constructor (called by VF page)
    public CasePDFCommentController() {
        caseId = ApexPages.currentPage() != null
            ? ApexPages.currentPage().getParameters().get('id')
            : null;
        initCollections();
        try {
            loadData();
        } catch (Exception e) {
            errorMessage = 'Unable to load case data: ' + e.getMessage();
        }
    }

    // LWC entry point for Word/PDF export
    @AuraEnabled(cacheable=false)
    public static CasePDFCommentController getPdfData(Id caseId) {
        try {
            return new CasePDFCommentController(caseId);
        } catch (Exception e) {
            throw new AuraHandledException('Unable to load case data: ' + e.getMessage());
        }
    }

    // Private constructor used by getPdfData
    private CasePDFCommentController(Id cId) {
        this.caseId = cId;
        initCollections();
        loadData();
    }

    private void initCollections() {
        threads     = new List<CommentThread>();
        emails      = new List<EmailEntry>();
        callLogs    = new List<CallLogEntry>();
        hasData     = false;
        hasEmails   = false;
        hasCallLogs = false;
        generatedOn = Datetime.now().format('dd/MM/yyyy HH:mm:ss');
    }

    // Shared data loading logic
    private void loadData() {
        if (caseId == null) {
            return;
        }
        if (!Schema.sObjectType.Case.isAccessible()) {
            errorMessage = 'Insufficient access to view this case.';
            return;
        }
        if (!loadCaseRecord()) {
            return;
        }
        loadComments();
        loadEmails();
        loadCallLogs();
    }

    // Returns false when the case is missing or not visible to the running user
    private Boolean loadCaseRecord() {
        List<Case> cases = [
            SELECT Id, CaseNumber, Subject, Status, Priority,
                   Account.Name, Owner.Name, CreatedDate
            FROM   Case
            WHERE  Id = :caseId
            WITH SECURITY_ENFORCED
            LIMIT  1
        ];
        if (cases.isEmpty()) {
            return false;
        }
        caseRecord = cases[0];
        return true;
    }

    private void loadComments() {
        List<CaseComment> comments = queryCaseComments();

        // The case feed plus the feeds of the records that hang off the case. A
        // "History Tracking created" or "Content created" post is parented to that
        // child record, not to the case, so a case-feed-only query never sees it.
        Map<Id, String> relatedLabels = loadHistoryTrackingLabels();
        relatedLabels.putAll(loadContentLabels());

        Set<Id> feedParentIds = new Set<Id>{ caseId };
        feedParentIds.addAll(relatedLabels.keySet());

        List<FeedItem> feedPosts = queryCommentedFeedPosts(feedParentIds);
        Map<String, String> fileNamesById = buildFileNameMap(attachmentSources(comments, feedPosts));

        Map<Id, CommentThread> threadByCommentId = new Map<Id, CommentThread>();
        for (CaseComment cc : comments) {
            CommentThread thread = new CommentThread(cc, fileNamesById);
            threadByCommentId.put(cc.Id, thread);
            threads.add(thread);
        }

        for (FeedItem fi : feedPosts) {
            // The semi-join already excludes uncommented posts, but sharing can still
            // hide every subcomment from the running user
            if (fi.FeedComments == null || fi.FeedComments.isEmpty()) {
                continue;
            }
            if (FEED_TYPE_COMMENT.equals(fi.Type)) {
                attachRepliesToCaseComment(fi, comments, threadByCommentId, fileNamesById);
            } else if (isEmailPost(fi.Type) || FEED_TYPE_CALL.equals(fi.Type)) {
                continue; // Those belong to the email and call log sections
            } else {
                threads.add(buildRelatedRecordThread(fi, relatedLabels, fileNamesById));
            }
        }

        threads.sort();
        hasData = !threads.isEmpty();
    }

    private List<CaseComment> queryCaseComments() {
        if (!Schema.sObjectType.CaseComment.isAccessible()) {
            return new List<CaseComment>();
        }
        return [
            SELECT Id, CommentBody, CreatedDate, CreatedBy.Name, IsPublished
            FROM   CaseComment
            WHERE  ParentId = :caseId
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
        ];
    }

    private List<FeedItem> queryCommentedFeedPosts(Set<Id> feedParentIds) {
        return new FeedAccess().queryTimelinePosts(feedParentIds);
    }

    // Every string that might hold a file Id, resolved in one pass to keep the
    // file name lookup to a single pair of queries
    private static List<String> attachmentSources(List<CaseComment> comments, List<FeedItem> feedPosts) {
        List<String> sources = new List<String>();
        for (CaseComment cc : comments) {
            if (cc.CommentBody != null) {
                sources.add(cc.CommentBody);
            }
        }
        for (FeedItem fi : feedPosts) {
            collectBodies(fi.FeedComments, sources);
            if (fi.Body != null) {
                sources.add(fi.Body);
            }
            if (fi.RelatedRecordId != null) {
                sources.add(String.valueOf(fi.RelatedRecordId));
            }
        }
        return sources;
    }

    private static void attachRepliesToCaseComment(
        FeedItem fi,
        List<CaseComment> comments,
        Map<Id, CommentThread> threadByCommentId,
        Map<String, String> fileNamesById
    ) {
        Id commentId = (fi.RelatedRecordId != null && threadByCommentId.containsKey(fi.RelatedRecordId))
            ? fi.RelatedRecordId
            : latestCommentIdBefore(comments, fi.CreatedDate);
        if (commentId == null) {
            return;
        }
        List<ReplyThread> replies = threadByCommentId.get(commentId).replies;
        for (FeedComment fc : fi.FeedComments) {
            replies.add(new ReplyThread(fc, fileNamesById));
        }
    }

    private static CommentThread buildRelatedRecordThread(
        FeedItem fi,
        Map<Id, String> relatedLabels,
        Map<String, String> fileNamesById
    ) {
        String label = relatedLabels.get(fi.ParentId);
        if (label == null && fi.RelatedRecordId != null) {
            label = relatedLabels.get(fi.RelatedRecordId);
        }
        CommentThread thread = new CommentThread(fi, fileNamesById, label);
        for (FeedComment fc : fi.FeedComments) {
            thread.replies.add(new ReplyThread(fc, fileNamesById));
        }
        return thread;
    }

    private void loadEmails() {
        if (!Schema.sObjectType.EmailMessage.isAccessible()) {
            return;
        }

        List<EmailMessage> emailList = [
            SELECT Id, Subject, FromName, FromAddress, ToAddress, CcAddress,
                   Incoming, Status, MessageDate, HasAttachment
            FROM   EmailMessage
            WHERE  ParentId = :caseId
            WITH SECURITY_ENFORCED
            ORDER BY MessageDate ASC
        ];
        if (emailList.isEmpty()) {
            return;
        }
        hasEmails = true;

        Map<Id, List<AttachmentInfo>> attachmentsByEmailId = buildEmailAttachments(emailList);
        Map<Id, EmailEntry> entryByEmailId = new Map<Id, EmailEntry>();
        for (EmailMessage em : emailList) {
            EmailEntry entry = new EmailEntry(em, attachmentsByEmailId.get(em.Id));
            entryByEmailId.put(em.Id, entry);
            emails.add(entry);
        }
        loadEmailReplies(entryByEmailId);
    }

    private void loadCallLogs() {
        if (!Schema.sObjectType.Task.isAccessible()) {
            return;
        }

        List<Task> callTasks = [
            SELECT Id, Subject, Description, CallType, CallDisposition,
                   CallDurationInSeconds, Status, CreatedDate, ActivityDate,
                   CreatedBy.Name
            FROM   Task
            WHERE  WhatId = :caseId
            AND    TaskSubtype   = 'Call'
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
        ];
        if (callTasks.isEmpty()) {
            return;
        }
        hasCallLogs = true;

        Map<Id, CallLogEntry> entryByTaskId = new Map<Id, CallLogEntry>();
        for (Task t : callTasks) {
            CallLogEntry entry = new CallLogEntry(t);
            entryByTaskId.put(t.Id, entry);
            callLogs.add(entry);
        }

        Set<Id> callTaskIds = entryByTaskId.keySet();
        List<FeedItem> feeds = new FeedAccess().queryReplyPosts(callTaskIds);
        if (feeds.isEmpty()) {
            return;
        }

        List<String> replyBodies = new List<String>();
        for (FeedItem fi : feeds) {
            collectBodies(fi.FeedComments, replyBodies);
        }
        Map<String, String> fileNamesById = buildFileNameMap(replyBodies);

        for (FeedItem fi : feeds) {
            CallLogEntry entry = entryByTaskId.get(fi.ParentId);
            if (entry == null || fi.FeedComments == null) {
                continue;
            }
            for (FeedComment fc : fi.FeedComments) {
                entry.replies.add(new ReplyThread(fc, fileNamesById));
            }
        }
    }

    private static void collectBodies(List<FeedComment> feedComments, List<String> bodies) {
        if (feedComments == null) {
            return;
        }
        for (FeedComment fc : feedComments) {
            if (fc.CommentBody != null) {
                bodies.add(fc.CommentBody);
            }
        }
    }

    // Newest comment created at or before a feed post, used when the post
    // carries no reference back to its CaseComment
    private static Id latestCommentIdBefore(List<CaseComment> comments, Datetime postDate) {
        Id bestId;
        Datetime bestDate;
        for (CaseComment cc : comments) {
            if (cc.CreatedDate > postDate) {
                continue;
            }
            if (bestDate == null || cc.CreatedDate > bestDate) {
                bestDate = cc.CreatedDate;
                bestId = cc.Id;
            }
        }
        return bestId;
    }

    // Email posts in the case feed carry an email-flavoured Type ('EmailMessageEvent'),
    // which keeps case comment posts and plain Chatter posts out of the email section.
    private static Boolean isEmailPost(String feedItemType) {
        return feedItemType != null && feedItemType.containsIgnoreCase(EMAIL_POST_TYPE_TOKEN);
    }

    // Picks the email closest in time to a feed post, used when the post itself
    // carries no reference back to the EmailMessage.
    private static Id closestEmailIdByDate(Datetime postDate, Map<Id, EmailEntry> entryByEmailId) {
        if (postDate == null) {
            if (entryByEmailId.size() != 1) {
                return null;
            }
            List<Id> onlyEmailId = new List<Id>(entryByEmailId.keySet());
            return onlyEmailId[0];
        }

        Id bestId;
        Long bestGap;
        for (Id emailId : entryByEmailId.keySet()) {
            Datetime emailDate = entryByEmailId.get(emailId).messageDate;
            if (emailDate == null) {
                continue;
            }
            Long gap = Math.abs(emailDate.getTime() - postDate.getTime());
            if (bestGap == null || gap < bestGap) {
                bestGap = gap;
                bestId = emailId;
            }
        }
        return bestId;
    }

    // Chatter replies on an email live either on the EmailMessage feed itself
    // (FeedComment.ParentId = email Id) or on the case feed's email post
    // (FeedComment.ParentId = case Id). The latter usually leaves
    // FeedItem.RelatedRecordId empty, so the post's Type and date resolve the email.
    private void loadEmailReplies(Map<Id, EmailEntry> entryByEmailId) {
        if (entryByEmailId.isEmpty() || !Schema.sObjectType.FeedItem.isAccessible()) {
            return;
        }

        Set<Id> emailIds = entryByEmailId.keySet();
        Set<Id> feedParentIds = new Set<Id>(emailIds);
        feedParentIds.add(caseId);

        List<FeedItem> feedPosts = new FeedAccess().queryReplyPosts(feedParentIds);
        List<FeedComment> feedComments = flattenFeedComments(feedPosts);
        if (feedComments.isEmpty()) {
            return;
        }

        Map<Id, Id> emailIdByFeedItemId = resolveEmailPosts(feedPosts, entryByEmailId);

        Map<Id, List<FeedComment>> repliesByEmailId = new Map<Id, List<FeedComment>>();
        List<String> replyBodies = new List<String>();
        for (FeedComment fc : feedComments) {
            // Comments on the email's own feed name it directly; case-feed comments
            // have to go through their resolved email post
            Id emailId = emailIds.contains(fc.ParentId)
                ? fc.ParentId
                : emailIdByFeedItemId.get(fc.FeedItemId);
            if (emailId == null) {
                continue;
            }
            if (!repliesByEmailId.containsKey(emailId)) {
                repliesByEmailId.put(emailId, new List<FeedComment>());
            }
            repliesByEmailId.get(emailId).add(fc);
            if (fc.CommentBody != null) {
                replyBodies.add(fc.CommentBody);
            }
        }
        if (repliesByEmailId.isEmpty()) {
            return;
        }

        Map<String, String> fileNamesById = buildFileNameMap(replyBodies);
        for (Id emailId : repliesByEmailId.keySet()) {
            List<ReplyThread> replies = entryByEmailId.get(emailId).replies;
            for (FeedComment fc : repliesByEmailId.get(emailId)) {
                replies.add(new ReplyThread(fc, fileNamesById));
            }
        }
    }

    private static List<FeedComment> flattenFeedComments(List<FeedItem> feedPosts) {
        List<FeedComment> comments = new List<FeedComment>();
        for (FeedItem fi : feedPosts) {
            if (fi.FeedComments != null) {
                comments.addAll(fi.FeedComments);
            }
        }
        return comments;
    }

    // Maps each case-feed post that represents an email onto that email's Id.
    private static Map<Id, Id> resolveEmailPosts(
        List<FeedItem> feedPosts,
        Map<Id, EmailEntry> entryByEmailId
    ) {
        Map<Id, Id> emailIdByFeedItemId = new Map<Id, Id>();
        Set<Id> emailIds = entryByEmailId.keySet();

        for (FeedItem fi : feedPosts) {
            if (emailIds.contains(fi.ParentId)
                || fi.FeedComments == null
                || fi.FeedComments.isEmpty()) {
                continue;
            }
            if (fi.RelatedRecordId != null && emailIds.contains(fi.RelatedRecordId)) {
                emailIdByFeedItemId.put(fi.Id, fi.RelatedRecordId);
            } else if (isEmailPost(fi.Type)) {
                // Case-feed email posts leave RelatedRecordId empty, so fall back to
                // the email whose timestamp sits closest to the post
                Id emailId = closestEmailIdByDate(fi.CreatedDate, entryByEmailId);
                if (emailId != null) {
                    emailIdByFeedItemId.put(fi.Id, emailId);
                }
            }
        }
        return emailIdByFeedItemId;
    }

    // FeedItem cannot be queried by ParentId under with sharing for most users. the issue that makes us change the approach is :
    //System.QueryException: Implementation restriction: directly querying FeedComment is only supported for admin users in version 23.0 and higher.
    //its a salesforce restriction so we had to change it wit  the subquery  15/sep/26
    // Isolated here so the rest of the controller keeps normal sharing rules
    private without sharing class FeedAccess {
        private List<FeedItem> queryTimelinePosts(Set<Id> parentIds) {
            if (parentIds == null || parentIds.isEmpty() || !Schema.sObjectType.FeedItem.isAccessible()) {
                return new List<FeedItem>();
            }
            List<FeedItem> posts = [
                SELECT Id, Type, ParentId, Body, Title, RelatedRecordId, CreatedDate, CreatedBy.Name,
                       (SELECT Id, CommentBody, CreatedDate, CreatedBy.Name
                        FROM   FeedComments
                        ORDER BY CreatedDate DESC),
                       (SELECT FieldName, OldValue, NewValue
                        FROM   FeedTrackedChanges)
                FROM   FeedItem
                WHERE  ParentId IN :parentIds
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC
            ];
            List<FeedItem> commented = new List<FeedItem>();
            for (FeedItem fi : posts) {
                if (fi.FeedComments != null && !fi.FeedComments.isEmpty()) {
                    commented.add(fi);
                }
            }
            return commented;
        }

        private List<FeedItem> queryReplyPosts(Set<Id> parentIds) {
            if (parentIds == null || parentIds.isEmpty() || !Schema.sObjectType.FeedItem.isAccessible()) {
                return new List<FeedItem>();
            }
            return [
                SELECT Id, Type, ParentId, RelatedRecordId, CreatedDate,
                       (SELECT Id, ParentId, FeedItemId, CommentBody, CreatedDate, CreatedBy.Name
                        FROM   FeedComments
                        ORDER BY CreatedDate ASC)
                FROM   FeedItem
                WHERE  ParentId IN :parentIds
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate ASC
            ];
        }
    }
}