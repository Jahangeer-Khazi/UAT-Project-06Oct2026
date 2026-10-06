@IsTest
private class CasePDFCommentControllerTest {

    @TestSetup
    static void setupTestData() {
        Account acc = (Account) TestDataFactory.createSObject(
            new Account(CIF__pc = '1293779'),
            'TestFactoryDefaults.AccountDefaults',
            true
        );
        Id issueRtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        Case cse = (Case) TestDataFactory.createSObject(
            new Case(
                RecordTypeId = issueRtId,
                ContactId = acc.PersonContactId,
                AccountId = acc.Id,
                Case_Model__c = 'ila',
                Subject = 'PDF comments test',
                Status = 'New',
                Origin = 'Email'
            ),
            'TestFactoryDefaults.CaseDefaults',
            true
        );

        ContentVersion cv = new ContentVersion(
            Title = 'Invoice',
            PathOnClient = 'docs/Invoice.PDF',
            VersionData = Blob.valueOf('invoice-bytes')
        );
        insert cv;
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        Attachment classicAtt = new Attachment(
            ParentId = cse.Id,
            Name = 'classic-note.txt',
            Body = Blob.valueOf('classic')
        );
        insert classicAtt;

        insert new CaseComment(
            ParentId = cse.Id,
            CommentBody = 'Plain comment without files',
            IsPublished = true
        );
        insert new CaseComment(
            ParentId = cse.Id,
            CommentBody =
                '<p>Has files</p>'
                + '<img alt="photo.PNG" src="https://example.com/' + cv.Id + '">'
                + '<img alt="photo.png" src="https://example.com/dup">'
                + '<img title="scan.TIFF" src="https://cdn.example.com/path/scan.tiff?x=1">'
                + '<img src="https://cdn.example.com/folder/chart.jpeg">'
                + '<img>'
                + ' also classic ' + classicAtt.Id,
            IsPublished = false
        );

        List<CaseFeed> commentFeeds = [
            SELECT Id FROM CaseFeed
            WHERE ParentId = :cse.Id AND Type = 'CaseCommentPost'
            LIMIT 1
        ];
        if (!commentFeeds.isEmpty()) {
            insert new FeedComment(
                FeedItemId = commentFeeds[0].Id,
                CommentBody = 'Reply with file <img alt="reply-doc.docx" src="x">'
            );
        }

        EmailMessage inbound = new EmailMessage(
            ParentId = cse.Id,
            Subject = 'Inbound mail',
            FromName = 'Customer',
            FromAddress = 'from@example.com',
            ToAddress = 'to@example.com',
            CcAddress = 'cc@example.com',
            Incoming = true,
            Status = '0',
            MessageDate = Datetime.now().addHours(-2)
        );
        EmailMessage outbound = new EmailMessage(
            ParentId = cse.Id,
            Subject = null,
            FromAddress = 'bank@example.com',
            ToAddress = 'cust@example.com',
            Incoming = false,
            Status = '3',
            MessageDate = Datetime.now().addHours(-1)
        );
        insert new List<EmailMessage>{ inbound, outbound };

        ContentVersion emailFile = new ContentVersion(
            Title = 'EmailAtt',
            PathOnClient = 'EmailAtt.pdf',
            VersionData = Blob.valueOf('email-att')
        );
        insert emailFile;
        emailFile = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :emailFile.Id];
        insert new ContentDocumentLink(
            LinkedEntityId = inbound.Id,
            ContentDocumentId = emailFile.ContentDocumentId,
            ShareType = 'V'
        );

        Task callTask = new Task(
            WhatId = cse.Id,
            Subject = 'Customer call',
            Description = '<p>Call notes</p><img alt="call.png">',
            Status = 'Completed',
            Priority = 'Normal',
            Type = 'Call',
            TaskSubtype = 'Call',
            CallType = 'Inbound',
            CallDurationInSeconds = 65,
            ActivityDate = Date.today()
        );
        insert callTask;
    }

    @IsTest
    static void testVfConstructorLoadsCase() {
        Case cse = [SELECT Id FROM Case LIMIT 1];
        Test.setCurrentPage(Page.CaseCommentsPDF);
        ApexPages.currentPage().getParameters().put('id', cse.Id);

        Test.startTest();
        CasePDFCommentController ctrl = new CasePDFCommentController();
        Test.stopTest();

        System.assertEquals(cse.Id, ctrl.caseId);
        System.assertNotEquals(null, ctrl.caseRecord);
        System.assertEquals(true, ctrl.hasData);
        System.assertEquals(2, ctrl.threads.size());
        System.assertEquals(true, ctrl.hasEmails);
        System.assertEquals(2, ctrl.emails.size());
        System.assertNotEquals(null, ctrl.generatedOn);
        System.assertEquals(null, ctrl.errorMessage);
    }

    @IsTest
    static void testVfConstructorWithoutId() {
        Test.setCurrentPage(Page.CaseCommentsPDF);

        Test.startTest();
        CasePDFCommentController ctrl = new CasePDFCommentController();
        Test.stopTest();

        System.assertEquals(null, ctrl.caseId);
        System.assertEquals(false, ctrl.hasData);
        System.assertEquals(false, ctrl.hasEmails);
        System.assertEquals(false, ctrl.hasCallLogs);
        System.assertEquals(0, ctrl.threads.size());
    }

    @IsTest
    static void testGetPdfDataWithCommentsEmailsAndCalls() {
        Case cse = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        CasePDFCommentController data = CasePDFCommentController.getPdfData(cse.Id);
        Test.stopTest();

        System.assertEquals(cse.Id, data.caseId);
        System.assertNotEquals(null, data.caseRecord);
        System.assertEquals(true, data.hasData);
        System.assertEquals(2, data.threads.size());

        CasePDFCommentController.CommentThread attachedThread;
        CasePDFCommentController.CommentThread plainThread;
        for (CasePDFCommentController.CommentThread t : data.threads) {
            if (t.hasAttachment) {
                attachedThread = t;
            } else {
                plainThread = t;
            }
        }
        System.assertNotEquals(null, attachedThread, 'Expected a comment with attachments');
        System.assertNotEquals(null, plainThread, 'Expected a plain comment');
        System.assertEquals(false, attachedThread.commentBody.contains('<img'));
        System.assert(attachedThread.attachments.size() >= 2, 'Expected multiple distinct attachment labels');

        Set<String> labels = new Set<String>();
        for (CasePDFCommentController.AttachmentInfo info : attachedThread.attachments) {
            labels.add(info.attachmentName.toLowerCase());
        }
        System.assertEquals(labels.size(), attachedThread.attachments.size(), 'Attachment labels should be distinct');

        System.assertEquals(true, data.hasEmails);
        Boolean foundInbound = false;
        Boolean foundOutboundNoSubject = false;
        for (CasePDFCommentController.EmailEntry em : data.emails) {
            if (em.isIncoming) {
                foundInbound = true;
                System.assertEquals('Inbound', em.directionLabel);
                System.assertEquals('Inbound mail', em.subject);
            } else {
                foundOutboundNoSubject = true;
                System.assertEquals('Outbound', em.directionLabel);
                System.assertEquals('(No Subject)', em.subject);
            }
        }
        System.assertEquals(true, foundInbound);
        System.assertEquals(true, foundOutboundNoSubject);

        for (CasePDFCommentController.EmailEntry em : data.emails) {
            System.assertEquals(
                0,
                em.replies.size(),
                'Case comment replies must not leak into the email section'
            );
        }

        if (data.hasCallLogs) {
            System.assert(!data.callLogs.isEmpty());
            System.assertEquals('01:05', data.callLogs[0].callDurationDisplay);
        }
    }

    private static Id findEmailPostId(Id caseId) {
        for (FeedItem fi : [SELECT Id, Type FROM FeedItem WHERE ParentId = :caseId]) {
            if (fi.Type != null && fi.Type.containsIgnoreCase('Email')) {
                return fi.Id;
            }
        }
        return null;
    }

    private static Integer countEmailReplies(CasePDFCommentController data) {
        Integer total = 0;
        for (CasePDFCommentController.EmailEntry em : data.emails) {
            total += em.replies.size();
        }
        return total;
    }

    @IsTest
    static void testCaseFeedEmailPostRepliesAttachToEmail() {
        Case cse = [SELECT Id FROM Case LIMIT 1];

        Id emailPostId = findEmailPostId(cse.Id);
        if (emailPostId != null) {
            insert new FeedComment(
                FeedItemId = emailPostId,
                CommentBody = 'Case feed reply <img alt="email-reply.PDF" src="x">'
            );
        }

        Test.startTest();
        CasePDFCommentController data = CasePDFCommentController.getPdfData(cse.Id);
        Test.stopTest();

        if (emailPostId == null) {
            System.assertEquals(
                0,
                countEmailReplies(data),
                'Without an email post in the case feed no reply can be attributed'
            );
            return;
        }

        System.assertEquals(1, countEmailReplies(data), 'The case feed reply should reach its email');

        CasePDFCommentController.ReplyThread attached;
        for (CasePDFCommentController.EmailEntry em : data.emails) {
            if (!em.replies.isEmpty()) {
                attached = em.replies[0];
            }
        }
        System.assertEquals(false, attached.body.containsIgnoreCase('<img'));
        System.assertEquals(true, attached.hasAttachment);
        System.assertEquals('email-reply.pdf', attached.attachments[0].attachmentName);
    }

    @IsTest
    static void testEmailPostReplyMatchesEmailWithClosestMessageDate() {
        Case cse = [SELECT Id FROM Case LIMIT 1];

        EmailMessage dated = new EmailMessage(
            ParentId = cse.Id,
            Subject = 'Dated',
            FromAddress = 'dated@example.com',
            Incoming = true,
            Status = '0',
            MessageDate = Datetime.now()
        );
        EmailMessage undated = new EmailMessage(
            ParentId = cse.Id,
            Subject = 'Undated',
            FromAddress = 'undated@example.com',
            Incoming = false,
            Status = '3'
        );
        insert new List<EmailMessage>{ dated, undated };

        Id emailPostId = findEmailPostId(cse.Id);
        if (emailPostId != null) {
            insert new FeedComment(FeedItemId = emailPostId, CommentBody = 'closest match reply');
        }

        Test.startTest();
        CasePDFCommentController data = CasePDFCommentController.getPdfData(cse.Id);
        Test.stopTest();

        System.assert(data.emails.size() >= 2, 'The extra emails should load with the setup case');

        if (emailPostId == null) {
            System.assertEquals(
                0,
                countEmailReplies(data),
                'Without an email post nothing can attach'
            );
            return;
        }

        System.assertEquals(1, countEmailReplies(data), 'The reply should reach exactly one email');

        FeedItem post = [SELECT Id, RelatedRecordId FROM FeedItem WHERE Id = :emailPostId];
        if (post.RelatedRecordId == null) {
            return;
        }
        EmailMessage matched = [SELECT Subject FROM EmailMessage WHERE Id = :post.RelatedRecordId];
        String expectedSubject = String.isBlank(matched.Subject) ? '(No Subject)' : matched.Subject;
        for (CasePDFCommentController.EmailEntry em : data.emails) {
            System.assertEquals(
                em.subject == expectedSubject ? 1 : 0,
                em.replies.size(),
                'Reply belonged on the ' + expectedSubject + ' email, not ' + em.subject
            );
        }
    }

    @IsTest
    static void testPlainCaseFeedRepliesStayOutOfEmailSection() {
        Case cse = [SELECT Id FROM Case LIMIT 1];

        FeedItem chatterPost = new FeedItem(ParentId = cse.Id, Body = 'Plain chatter post');
        insert chatterPost;
        insert new FeedComment(
            FeedItemId = chatterPost.Id,
            CommentBody = 'Reply to a plain chatter post'
        );

        Test.startTest();
        CasePDFCommentController data = CasePDFCommentController.getPdfData(cse.Id);
        Test.stopTest();

        System.assertEquals(true, data.hasEmails);
        for (CasePDFCommentController.EmailEntry em : data.emails) {
            System.assertEquals(
                0,
                em.replies.size(),
                'A reply on a non-email post must not attach to an email'
            );
        }
    }

    @IsTest
    static void testGetPdfDataNullAndUnknownCase() {
        Test.startTest();
        CasePDFCommentController emptyCtrl = CasePDFCommentController.getPdfData(null);
        CasePDFCommentController missingCtrl = CasePDFCommentController.getPdfData(
            '500000000000000AAA'
        );
        Test.stopTest();

        System.assertEquals(false, emptyCtrl.hasData);
        System.assertEquals(null, missingCtrl.caseRecord);
        System.assertEquals(false, missingCtrl.hasData);
    }

    @IsTest
    static void testCommentThreadParsesAttachmentsAndCleansBody() {
        Map<String, String> namesById = new Map<String, String>{
            '069XXXXXXXXXXXX' => 'looked-up.png'
        };
        CaseComment cc = new CaseComment(
            CommentBody =
                '<p></p><img src="https://x/069XXXXXXXXXXXX">'
                + '<img alt="looked-up.PNG">'
                + '<img alt="other.jpg">'
                + '<img>'
        );

        Test.startTest();
        CasePDFCommentController.CommentThread thread =
            new CasePDFCommentController.CommentThread(cc, namesById);
        Test.stopTest();

        System.assertEquals(true, thread.hasAttachment);
        System.assertEquals('Unknown', thread.createdByName);
        System.assertEquals(false, thread.commentBody.containsIgnoreCase('<img'));
        System.assertEquals(2, thread.attachments.size());
        System.assertEquals('looked-up.png', thread.attachmentName);
        System.assertEquals(0, thread.replies.size());
        System.assertEquals(true, thread.isInternal);
        System.assertEquals(false, thread.isHistory);
        System.assertEquals(false, thread.isContent);
    }

    private static FeedItem buildPost(String payload) {
        return (FeedItem) JSON.deserialize(payload, FeedItem.class);
    }

    @IsTest
    static void testHistoryAndContentThreadConstructors() {
        FeedItem historyFeed = buildPost(
            '{"Type":"TrackedChange","CreatedDate":"2026-01-01T10:00:00.000+0000"}'
        );
        FeedItem contentFeed = buildPost(
            '{"Type":"ContentPost","Title":"Invoice.PDF","Body":"<p>uploaded</p>","CreatedDate":"2026-01-02T10:00:00.000+0000"}'
        );

        Test.startTest();
        CasePDFCommentController.CommentThread historyThread =
            new CasePDFCommentController.CommentThread(historyFeed, new Map<String, String>());
        CasePDFCommentController.CommentThread contentThread =
            new CasePDFCommentController.CommentThread(
                contentFeed,
                new Map<String, String>{ '068XXXXXXXXXXXX' => 'looked-up.pdf' }
            );
        Test.stopTest();

        System.assertEquals(true, historyThread.isHistory);
        System.assertEquals('History', historyThread.typeLabel);
        System.assertEquals('History tracking updated', historyThread.commentBody);
        System.assertEquals(false, historyThread.isPublic);

        System.assertEquals(true, contentThread.isContent);
        System.assertEquals('Content', contentThread.typeLabel);
        System.assertEquals('<p>uploaded</p>', contentThread.commentBody);
        System.assertEquals(true, contentThread.hasAttachment);
        System.assertEquals('Invoice.PDF', contentThread.attachmentName);

        String historyId = History_Tracking__c.SObjectType.getDescribe().getKeyPrefix() + '000000000001';
        FeedItem createdFeed = buildPost(
            '{"Type":"CreateRecordEvent","ParentId":"' + historyId + '",'
            + '"Body":"History Tracking created","CreatedDate":"2026-01-03T10:00:00.000+0000"}'
        );
        CasePDFCommentController.CommentThread createdThread =
            new CasePDFCommentController.CommentThread(
                createdFeed,
                new Map<String, String>(),
                'History Tracking created: HT-02689483'
            );
        System.assertEquals(true, createdThread.isHistory, 'A History Tracking record post is a History row');
        System.assertEquals('History', createdThread.typeLabel);
        System.assertEquals('History Tracking created: HT-02689483', createdThread.commentBody);

        FeedItem plainPost = buildPost(
            '{"Type":"CreateRecordEvent","Body":"Some record created","CreatedDate":"2026-01-04T10:00:00.000+0000"}'
        );
        CasePDFCommentController.CommentThread plainThread =
            new CasePDFCommentController.CommentThread(plainPost, new Map<String, String>());
        System.assertEquals(true, plainThread.isCreated);
        System.assertEquals('Created', plainThread.typeLabel);
        System.assertEquals('Some record created', plainThread.commentBody);

        List<CasePDFCommentController.CommentThread> ordered =
            new List<CasePDFCommentController.CommentThread>{ historyThread, contentThread };
        ordered.sort();
        System.assertEquals(true, ordered[0].isContent, 'Newer content post should sort first');
        System.assertEquals(true, ordered[1].isHistory);
    }

    private static Id feedPostOn(Id recordId, String body) {
        List<FeedItem> posts = [SELECT Id FROM FeedItem WHERE ParentId = :recordId LIMIT 1];
        if (!posts.isEmpty()) {
            return posts[0].Id;
        }
        try {
            FeedItem post = new FeedItem(ParentId = recordId, Body = body);
            insert post;
            return post.Id;
        } catch (DmlException e) {
            return null;
        }
    }

    private static History_Tracking__c insertHistoryTracking(Id caseId) {
        History_Tracking__c ht = new History_Tracking__c(
            Case__c = caseId,
            Field_Name__c = 'Status',
            Prior_Value__c = 'New',
            Current_Value__c = 'Closed'
        );
        insert ht;
        return ht;
    }

    private static Content__c insertContent(Id caseId, String documentType) {
        Content__c doc = new Content__c(Case__c = caseId, Document_Type__c = documentType);
        insert doc;
        return doc;
    }

    @IsTest
    static void testChildRecordPostsWithRepliesJoinTimeline() {
        Case cse = [SELECT Id FROM Case LIMIT 1];

        History_Tracking__c ht = insertHistoryTracking(cse.Id);
        Content__c doc = insertContent(cse.Id, 'Bahraini ID');

        Id historyPostId = feedPostOn(ht.Id, 'History Tracking created');
        Id contentPostId = feedPostOn(doc.Id, 'Content created');
        List<FeedComment> replies = new List<FeedComment>();
        if (historyPostId != null) {
            replies.add(new FeedComment(FeedItemId = historyPostId, CommentBody = 'test history created'));
        }
        if (contentPostId != null) {
            replies.add(new FeedComment(FeedItemId = contentPostId, CommentBody = 'content test 2'));
        }
        if (!replies.isEmpty()) {
            insert replies;
        }

        Test.startTest();
        CasePDFCommentController data = CasePDFCommentController.getPdfData(cse.Id);
        Test.stopTest();

        CasePDFCommentController.CommentThread historyRow;
        CasePDFCommentController.CommentThread contentRow;
        for (CasePDFCommentController.CommentThread t : data.threads) {
            if (t.isHistory) {
                historyRow = t;
            } else if (t.isContent) {
                contentRow = t;
            }
        }

        if (historyPostId != null) {
            System.assertNotEquals(null, historyRow, 'The History Tracking post should join the timeline');
            System.assertEquals(1, historyRow.replies.size());
            System.assertEquals('test history created', historyRow.replies[0].body);
            System.assertEquals(true, historyRow.commentBody.contains('History Tracking created'));
        } else {
            System.assertEquals(null, historyRow, 'No history row without a feed post');
        }

        if (contentPostId != null) {
            System.assertNotEquals(null, contentRow, 'The Content__c post should join the timeline');
            System.assertEquals('Content', contentRow.typeLabel);
            System.assertEquals(1, contentRow.replies.size());
            System.assertEquals('content test 2', contentRow.replies[0].body);
            System.assertEquals('Content created: Bahraini ID', contentRow.commentBody);
        } else {
            System.assertEquals(null, contentRow, 'No content row without a feed post');
        }

        System.assertEquals(true, data.hasData);
    }

    @IsTest
    static void testChildRecordPostsWithoutRepliesStayOut() {
        Case cse = [SELECT Id FROM Case LIMIT 1];
        insertHistoryTracking(cse.Id);
        insertContent(cse.Id, 'Passport');

        Test.startTest();
        CasePDFCommentController data = CasePDFCommentController.getPdfData(cse.Id);
        Test.stopTest();

        for (CasePDFCommentController.CommentThread t : data.threads) {
            System.assertEquals(false, t.isHistory, 'History without subcomments must stay omitted');
            System.assertEquals(false, t.isContent, 'Content without subcomments must stay omitted');
        }
        System.assertEquals(2, data.threads.size(), 'Only the setup case comments should remain');
    }

    @IsTest
    static void testHistoryAndContentPostsWithRepliesAppearInTimeline() {
        Case cse = [SELECT Id FROM Case LIMIT 1];

        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE Title = 'Invoice' LIMIT 1];
        Id contentPostId;
        try {
            FeedItem contentPost = new FeedItem(
                ParentId = cse.Id,
                RelatedRecordId = cv.Id,
                Body = 'File posted'
            );
            insert contentPost;
            contentPostId = contentPost.Id;
            insert new FeedComment(
                FeedItemId = contentPostId,
                CommentBody = 'Reply on content created'
            );
        } catch (DmlException e) {
            contentPostId = null;
        }

        List<CaseFeed> historyFeeds = [
            SELECT Id FROM CaseFeed
            WHERE ParentId = :cse.Id AND Type = 'TrackedChange'
            LIMIT 1
        ];
        if (!historyFeeds.isEmpty()) {
            insert new FeedComment(
                FeedItemId = historyFeeds[0].Id,
                CommentBody = 'Reply on history tracking'
            );
        }

        Test.startTest();
        CasePDFCommentController data = CasePDFCommentController.getPdfData(cse.Id);
        Test.stopTest();

        Integer historyCount = 0;
        Integer contentCount = 0;
        for (CasePDFCommentController.CommentThread t : data.threads) {
            if (t.isHistory) {
                historyCount++;
                System.assertEquals(false, t.replies.isEmpty(), 'History rows require subcomments');
            }
            if (t.isContent) {
                contentCount++;
                System.assertEquals(false, t.replies.isEmpty(), 'Content rows require subcomments');
            }
        }

        if (!historyFeeds.isEmpty()) {
            System.assertEquals(1, historyCount, 'History tracking with a reply should appear in the timeline');
        } else {
            System.assertEquals(0, historyCount, 'History without a feed post must stay omitted');
        }
        if (contentPostId != null) {
            System.assert(contentCount >= 1, 'Content created with a reply should appear in the timeline');
        }
        System.assertEquals(true, data.hasData);
    }

    @IsTest
    static void testReplyThreadImageFallbacks() {
        FeedComment fc = new FeedComment(
            CommentBody = '<img title="notes" src="https://files.example.com/dir/notes.PDF?token=abc">'
        );

        Test.startTest();
        CasePDFCommentController.ReplyThread reply =
            new CasePDFCommentController.ReplyThread(fc, new Map<String, String>());
        Test.stopTest();

        System.assertEquals(true, reply.hasAttachment);
        System.assertEquals('notes.pdf', reply.attachmentName);
        System.assertEquals('pdf', reply.attachmentExtension);
        System.assertEquals('Unknown', reply.createdBy);
    }

    @IsTest
    static void testEmailEntryAndCallLogEntry() {
        EmailMessage withFiles = (EmailMessage) JSON.deserialize(
            '{"Subject":"","Incoming":false,"HasAttachment":true,"Status":"3"}',
            EmailMessage.class
        );
        EmailMessage noFiles = (EmailMessage) JSON.deserialize(
            '{"Subject":"Hello","FromName":"Agent","FromAddress":"a@b.com","Incoming":true,"HasAttachment":false,"Status":"0"}',
            EmailMessage.class
        );
        Task callTask = new Task(
            Subject = '',
            Description = '<img alt="ignored.png"> kept',
            CallType = 'Outbound',
            CallDurationInSeconds = 5,
            Status = 'Completed',
            ActivityDate = Date.today()
        );
        Task zeroDuration = new Task(Subject = 'Missed', CallDurationInSeconds = 0);

        Test.startTest();
        CasePDFCommentController.EmailEntry fallbackEmail =
            new CasePDFCommentController.EmailEntry(withFiles, null);
        CasePDFCommentController.EmailEntry labeledEmail =
            new CasePDFCommentController.EmailEntry(
                withFiles,
                new List<CasePDFCommentController.AttachmentInfo>{
                    new CasePDFCommentController.AttachmentInfo('stmt.pdf')
                }
            );
        CasePDFCommentController.EmailEntry inbound =
            new CasePDFCommentController.EmailEntry(noFiles, new List<CasePDFCommentController.AttachmentInfo>());
        CasePDFCommentController.CallLogEntry callEntry =
            new CasePDFCommentController.CallLogEntry(callTask);
        CasePDFCommentController.CallLogEntry zeroEntry =
            new CasePDFCommentController.CallLogEntry(zeroDuration);
        CasePDFCommentController.AttachmentInfo emptyInfo =
            new CasePDFCommentController.AttachmentInfo();
        Test.stopTest();

        System.assertEquals('(No Subject)', fallbackEmail.subject);
        System.assertEquals('Outbound', fallbackEmail.directionLabel);
        System.assertEquals('Image', fallbackEmail.attachmentName);
        System.assertEquals('stmt.pdf', labeledEmail.attachmentName);
        System.assertEquals('pdf', labeledEmail.attachmentExtension);
        System.assertEquals('Inbound', inbound.directionLabel);
        System.assertEquals(null, inbound.attachmentName);
        System.assertEquals('(No Subject)', callEntry.subject);
        System.assertEquals('00:05', callEntry.callDurationDisplay);
        System.assertEquals(false, callEntry.description.contains('<img'));
        System.assertNotEquals(null, callEntry.activityDateTime);
        System.assertEquals('00:00', zeroEntry.callDurationDisplay);
        System.assertEquals(false, emptyInfo.hasAttachment);
    }
}