import { LightningElement, api, track } from 'lwc';
import getPdfData from '@salesforce/apex/CasePDFCommentController.getPdfData';

const WORD_TABLE_WIDTH_PT = 774;
const WORD_COL_WIDTHS_5 = [5, 10, 20, 20, 45];
const WORD_COL_WIDTHS_6 = [5, 10, 15, 15, 15, 40];

export default class CaseCommentsPdfPreview extends LightningElement {
    @api recordId;
    @track data;
    @track isLoading = true;
    @track error;

    @track accountName = '';
    @track ownerName = '';

    connectedCallback() {
        if (this.recordId) {
            this.loadData();
        }
    }

    loadData() {
        this.isLoading = true;
        getPdfData({ caseId: this.recordId })
            .then(result => {
                this.data = this.processResult(result);
                this.isLoading = false;
            })
            .catch(error => {
                console.error(error);
                this.error = error;
                this.isLoading = false;
            });
    }

    assignAttachmentKeys(attachments) {
        if (!attachments) {
            return;
        }
        attachments.forEach((att, i) => {
            att.key = (att.attachmentName || 'att') + '-' + i;
        });
    }

    // Adds the row number, reply flag and attachment keys the templates rely on
    decorateRows(rows) {
        if (!rows) {
            return;
        }
        rows.forEach((row, i) => {
            row.index = i + 1;
            row.hasReplies = !!(row.replies && row.replies.length);
            this.assignAttachmentKeys(row.attachments);
            if (row.replies) {
                row.replies.forEach(reply => this.assignAttachmentKeys(reply.attachments));
            }
        });
    }

    processResult(res) {
        // Create a deep clone to mutate
        const processed = JSON.parse(JSON.stringify(res));

        this.decorateRows(processed.threads);
        this.decorateRows(processed.callLogs);
        this.decorateRows(processed.emails);

        if (processed.caseRecord) {
            this.accountName = processed.caseRecord.Account ? processed.caseRecord.Account.Name : '';
            this.ownerName = processed.caseRecord.Owner ? processed.caseRecord.Owner.Name : '';
        }

        return processed;
    }


    formatDate(ds) {
        if (!ds) return '';
        const d = new Date(ds);
        return d.toLocaleDateString('en-GB') + ' ' + d.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
    }

    toPoints(percent) {
        return Math.round(WORD_TABLE_WIDTH_PT * (percent / 100));
    }

    toPointsList(percentages) {
        const widthsPt = percentages.map(p => this.toPoints(p));
        const totalWidthPt = widthsPt.reduce((sum, widthPt) => sum + widthPt, 0);
        if (totalWidthPt !== WORD_TABLE_WIDTH_PT) {
            widthsPt[widthsPt.length - 1] += WORD_TABLE_WIDTH_PT - totalWidthPt;
        }
        return widthsPt;
    }

    buildColGroupPt(widthsPt) {
        return `<colgroup>${widthsPt.map(widthPt => {
            const twips = widthPt * 20;
            return `<col width="${widthPt}" style="width:${widthPt}pt;mso-width-source:userset;mso-width-alt:${twips};" />`;
        }).join('')}</colgroup>`;
    }

    buildHeaderRow(columns, widthsPt) {
        return `<tr>${columns.map((label, index) => {
            const widthPt = widthsPt[index];
            return `<th width="${widthPt}" style="width:${widthPt}pt;mso-width-source:userset;">${label}</th>`;
        }).join('')}</tr>`;
    }

    buildDataTable(colPercents, headerColumns, buildRows) {
        const widthsPt = this.toPointsList(colPercents);
        const totalWidthPt = widthsPt.reduce((sum, widthPt) => sum + widthPt, 0);
        let tableHtml = `<table class="data-table" border="1" cellspacing="0" cellpadding="0" width="${totalWidthPt}" style="width:${totalWidthPt}pt;border-collapse:collapse;mso-table-layout-alt:fixed;table-layout:fixed;">`;
        tableHtml += this.buildColGroupPt(widthsPt);
        tableHtml += `<thead>${this.buildHeaderRow(headerColumns, widthsPt)}</thead><tbody>`;
        tableHtml += buildRows(widthsPt);
        tableHtml += `</tbody></table>`;
        return tableHtml;
    }

    timelineTypeBadge(thread) {
        if (thread.isHistory) {
            return `<span style="color:#0B5CAB;">History</span>`;
        }
        if (thread.isContent) {
            return `<span style="color:#5A2CA0;">Content</span>`;
        }
        if (thread.isPublic) {
            return `<span style="color:#04844B;">Public</span>`;
        }
        return `<span style="color:#8A6D3B;">Internal</span>`;
    }

    formatAttachmentLabels(attachments) {
        if (!attachments || attachments.length === 0) {
            return '';
        }
        return attachments
            .filter(att => att && att.attachmentName)
            .map(att => ` <span style="color:#C62828; font-weight:bold;">[${att.attachmentName}]</span>`)
            .join('');
    }

    buildReplyBlocks(replies) {
        if (!replies || replies.length === 0) {
            return '';
        }
        let blocks = '<div class="replies-container">';
        replies.forEach(reply => {
            const attachment = this.formatAttachmentLabels(reply.attachments);
            blocks += `<div class="reply-block">
                <div class="reply-meta"><span style="color: green; font-weight: bold;">RE: </span><strong>${reply.createdBy}</strong>${attachment} &mdash; ${this.formatDate(reply.createdDate)}</div>
                <div class="reply-body">${reply.body || ''}</div>
            </div>`;
        });
        blocks += '</div>';
        return blocks;
    }

    @api
    generateWord() {
        if (!this.data) return;

        let html = `
        <html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:w='urn:schemas-microsoft-com:office:word' xmlns='http://www.w3.org/TR/REC-html40'>
        <head>
            <meta charset="utf-8">
            <title>Case Comments Report</title>
            <!--[if gte mso 9]>
            <xml>
                <w:WordDocument>
                    <w:View>Print</w:View>
                </w:WordDocument>
            </xml>
            <![endif]-->
            <style>
                @page { size: A4 landscape; margin: 12mm; }
                body {
                    font-family: 'Arial', sans-serif;
                    font-size: 10pt;
                    color: #333;
                    line-height: 1.4;
                    margin: 0;
                    padding: 0;
                    direction: ltr;
                }
                .report-header { border-bottom: 2px solid #0070D2; padding-bottom: 8px; margin-bottom: 15px; }
                .report-header h1 { font-size: 14pt; color: #0070D2; margin: 0; font-weight: bold; }
                .report-header .meta { font-size: 8pt; color: #666; margin-top: 4px; }
                table { width: 100%; border-collapse: collapse; margin-bottom: 15px; font-size: 9pt; }
                .data-table { width: 100%; table-layout: fixed; mso-table-layout-alt: fixed; }
                td, th { border: 1px solid #D4D4D4; padding: 6px 8px; vertical-align: top; word-wrap: break-word; }
                th { background-color: #F3F3F3; text-align: left; font-weight: bold; color: #16325C; }
                .section-title { background-color: #F3F3F3; border: 1px solid #D4D4D4; border-left: 4px solid #0070D2; padding: 6px 10px; font-size: 11pt; font-weight: bold; color: #16325C; margin: 15px 0 10px 0; }
                .reply-meta { font-size: 8pt; color: #666; margin-bottom: 2px; }
                .replies-container { width: 100%; margin-top: 10px; }
                .reply-block { width: 100%; border-left: 3px solid #0070D2; padding: 4px 6px; background-color: #FAFAFA; margin-bottom: 6px; }
                .reply-body { width: 100%; }
            </style>
        </head>
        <body dir="ltr">
            <div class="report-header">
                <h1>Case Comments & Replies Report</h1>
                <div class="meta">Generated: ${this.data.generatedOn} | Case: ${this.data.caseRecord.CaseNumber}</div>
            </div>
            
            <div class="section-title">Case Information</div>
            <table width="100%">
                <tr>
                    <td><strong>Case Number:</strong> ${this.data.caseRecord.CaseNumber}</td>
                    <td><strong>Status:</strong> ${this.data.caseRecord.Status || ''}</td>
                </tr>
                <tr>
                    <td><strong>Subject:</strong> ${this.data.caseRecord.Subject || ''}</td>
                    <td><strong>Priority:</strong> ${this.data.caseRecord.Priority || ''}</td>
                </tr>
                <tr>
                    <td><strong>Customer Name:</strong> ${this.accountName}</td>
                    <td><strong>Owner:</strong> ${this.ownerName}</td>
                </tr>
                <tr>
                    <td><strong>Created Date:</strong> ${this.formatDate(this.data.caseRecord.CreatedDate)}</td>
                    <td><strong>Total Comments:</strong> ${this.data.threads ? this.data.threads.length : 0}</td>
                </tr>
            </table>

            <div class="section-title">Comments & Replies Timeline</div>
        `;

        if (!this.data.hasData) {
            html += `<div style="text-align:center; padding: 15px;">No comments found for this case.</div>`;
        } else {
            html += this.buildDataTable(
                WORD_COL_WIDTHS_5,
                ['#', 'Type', 'Author', 'Date', 'Comment / Replies'],
                () => {
                    let rows = '';
                    this.data.threads.forEach(thread => {
                        const badge = this.timelineTypeBadge(thread);
                        const attachment = this.formatAttachmentLabels(thread.attachments);
                        rows += `<tr>
                            <td>${thread.index}</td>
                            <td>${badge}</td>
                            <td>${thread.createdByName}${attachment}</td>
                            <td>${this.formatDate(thread.createdDate)}</td>
                            <td>
                                <div>${thread.commentBody || ''}</div>
                                ${thread.hasReplies ? this.buildReplyBlocks(thread.replies) : ''}
                            </td>
                        </tr>`;
                    });
                    return rows;
                }
            );
        }

        // Add Call Logs
        html += `<div class="section-title">Call Log</div>`;
        if (!this.data.hasCallLogs) {
            html += `<div style="text-align:center; padding: 15px;">No call logs found for this case.</div>`;
        } else {
            html += this.buildDataTable(
                WORD_COL_WIDTHS_6,
                ['#', 'Type', 'By', 'Date', 'Duration', 'Subject / Notes'],
                () => {
                    let rows = '';
                    this.data.callLogs.forEach(call => {
                        rows += `<tr>
                            <td>${call.index}</td>
                            <td>${call.callType || ''}</td>
                            <td>${call.createdByName || ''}</td>
                            <td>${this.formatDate(call.createdDate)}</td>
                            <td>${call.callDurationDisplay || ''}</td>
                            <td>
                                <strong>${call.subject || ''}</strong><br/>
                                ${call.callDisposition ? `<div class="reply-meta">Disposition: ${call.callDisposition}</div>` : ''}
                                <div>${call.description || ''}</div>
                                ${call.hasReplies ? this.buildReplyBlocks(call.replies) : ''}
                            </td>
                        </tr>`;
                    });
                    return rows;
                }
            );
        }

        // Add Emails
        html += `<div class="section-title">Emails Triggered</div>`;
        if (!this.data.hasEmails) {
            html += `<div style="text-align:center; padding: 15px;">No emails found for this case.</div>`;
        } else {
            html += this.buildDataTable(
                WORD_COL_WIDTHS_5,
                ['#', 'Dir.', 'From', 'Date', 'Subject / Recipients'],
                () => {
                    let rows = '';
                    this.data.emails.forEach(email => {
                        const badge = email.isIncoming
                            ? `<span style="color:#04844B;">Inbound</span>`
                            : `<span style="color:#8A6D3B;">Outbound</span>`;
                        const attachment = this.formatAttachmentLabels(email.attachments);
                        rows += `<tr>
                            <td>${email.index}</td>
                            <td>${badge}</td>
                            <td>${email.fromName || ''}<br/><span class="reply-meta">${email.fromAddress || ''}</span>${attachment}</td>
                            <td>${this.formatDate(email.messageDate)}</td>
                            <td>
                                <strong>${email.subject || ''}</strong><br/>
                                ${email.toAddress ? `<div class="reply-meta">To: ${email.toAddress}</div>` : ''}
                                ${email.ccAddress ? `<div class="reply-meta">Cc: ${email.ccAddress}</div>` : ''}
                                ${email.hasReplies ? this.buildReplyBlocks(email.replies) : ''}
                            </td>
                        </tr>`;
                    });
                    return rows;
                }
            );
        }

        html += `</body></html>`;

        try {
            const dataUrl = 'data:text/html;charset=utf-8,' + encodeURIComponent(html);
            const a = document.createElement('a');
            a.href = dataUrl;
            a.download = this.data.caseRecord.CaseNumber + '_CaseCommentsPDF_IlaRCD' + '.doc';
            a.target = '_blank';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);

            this.dispatchEvent(new CustomEvent('wordsuccess'));
        } catch (e) {
            console.error('Word generation error:', e);
            this.dispatchEvent(new CustomEvent('worderror', { detail: e.message }));
        }
    }

}