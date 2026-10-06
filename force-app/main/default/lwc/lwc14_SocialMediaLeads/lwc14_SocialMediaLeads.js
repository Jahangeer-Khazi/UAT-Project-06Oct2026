import { LightningElement, track } from 'lwc';
import analyzeSocialMediaLeads from '@salesforce/apex/lwc14_SocialMediaLeadsController.analyzeSocialMediaLeads';
import analyzeSocialMediaLeadsBatch from '@salesforce/apex/lwc14_SocialMediaLeadsController.analyzeSocialMediaLeadsBatch';
import commitSocialMediaLeads from '@salesforce/apex/lwc14_SocialMediaLeadsController.commitSocialMediaLeads';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import SHEETJS from '@salesforce/resourceUrl/sheetjs';


const COLUMNS = [
    { label: 'Name', fieldName: 'name', type: 'text', initialWidth: 160 },
    { label: 'Email', fieldName: 'email', type: 'email', initialWidth: 200 },
    { label: 'Phone Number', fieldName: 'phone', type: 'text', initialWidth: 140 },
    { label: 'Secondary Phone', fieldName: 'secondaryPhone', type: 'text', initialWidth: 150 },
    { label: 'WhatsApp', fieldName: 'whatsappNumber', type: 'text', initialWidth: 140 },
    { label: 'Source', fieldName: 'source', type: 'text', initialWidth: 130 },
    // { label: 'Channel', fieldName: 'channel', type: 'text', initialWidth: 130 },
    {
        label: 'CIF',
        fieldName: 'accountUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'cif' }, target: '_blank' },
        initialWidth: 120
    },



    {
        label: 'Is Customer',
        fieldName: 'isCustomer_str',
        type: 'text',
        initialWidth: 115,
        cellAttributes: { alignment: 'center', class: { fieldName: 'isCustomer_class' } }
    },
    {
        label: 'Blacklisted',
        fieldName: 'isBlacklisted_str',
        type: 'text',
        initialWidth: 110,
        cellAttributes: { alignment: 'center', class: { fieldName: 'isBlacklisted_class' } }
    },
    {
        label: 'Terminated Relationship',
        fieldName: 'terminatedRelationship_str',
        type: 'text',
        initialWidth: 175,
        cellAttributes: { alignment: 'center', class: { fieldName: 'terminatedRelationship_class' } }
    },
    {
        label: 'Active Credit Card',
        fieldName: 'hasActiveCreditCard_str',
        type: 'text',
        initialWidth: 145,
        cellAttributes: { alignment: 'center', class: { fieldName: 'hasActiveCreditCard_class' } }
    },
    {
        label: 'Pending Credit Card',
        fieldName: 'hasPendingCreditCard_str',
        type: 'text',
        initialWidth: 148,
        cellAttributes: { alignment: 'center', class: { fieldName: 'hasPendingCreditCard_class' } }
    },
    {
        label: 'Declined Credit Card',
        fieldName: 'hasDeclinedCreditCard_str',
        type: 'text',
        initialWidth: 152,
        cellAttributes: { alignment: 'center', class: { fieldName: 'hasDeclinedCreditCard_class' } }
    }
];

const YES_CLASS = 'slds-text-color_success slds-text-title_bold';
const NO_CLASS = 'slds-text-color_weak';
const WARN_CLASS = 'slds-text-color_error slds-text-title_bold';

export default class Lwc14_SocialMediaLeads extends LightningElement {
    @track isProcessing = false;
    @track message = '';
    @track messageType = 'info';
    @track previewData = [];
    @track allAnalysisData = [];
    @track isPreviewAvailable = false;
    @track progress = 0;
    @track totalRecords = 0;
    @track processedCount = 0;

    // Pagination State
    @track pageNumber = 1;
    @track rowsPerPage = 50;

    columns = COLUMNS;
    librariesLoaded = false;


    renderedCallback() {
        if (this.librariesLoaded) return;
        loadScript(this, SHEETJS)
            .then(() => { this.librariesLoaded = true; })
            .catch(error => { console.error('Error loading SheetJS', error); });
    }


    onFileSelection(event) {
        const file = event.target.files[0];
        if (!file) return;

        this.startProcessing();

        const reader = new FileReader();
        const extension = file.name.split('.').pop().toLowerCase();

        if (extension === 'xlsx' || extension === 'xls') {
            // this.handleExcelParsing(reader, file);
            this.notifyError('Upload Error', 'Only CSV files are allowed.');
            this.isProcessing = false;
        } else {
            this.handleCsvParsing(reader, file);
        }
    }

    resetAnalysisView() {
        this.previewData = [];
        this.isPreviewAvailable = false;
        this.message = '';
        this.pageNumber = 1;
    }

    handleNextPage() {
        if (this.pageNumber < this.totalPages) {
            this.pageNumber += 1;
        }
    }

    handlePreviousPage() {
        if (this.pageNumber > 1) {
            this.pageNumber -= 1;
        }
    }

    get totalPages() {
        return Math.ceil(this.totalRecords / this.rowsPerPage) || 1;
    }

    get isFirstPage() {
        return this.pageNumber === 1;
    }

    get isLastPage() {
        return this.pageNumber >= this.totalPages;
    }

    async processLeadSubmission() {
        if (!this.previewData || this.previewData.length === 0) {
            this.notifyError('Submission Error', 'No data available to submit.');
            return;
        }

        this.startProcessing();
        this.totalRecords = this.previewData.length;
        this.processedCount = 0;
        this.progress = 0;

        const BATCH_SIZE = 1000;

        try {
            for (let i = 0; i < this.previewData.length; i += BATCH_SIZE) {
                const chunk = this.previewData.slice(i, i + BATCH_SIZE);
                const preparedChunk = this.prepareRecordsForDatabase(chunk);

                await commitSocialMediaLeads({ analysisList: preparedChunk });

                this.processedCount += chunk.length;
                this.progress = Math.round((this.processedCount / this.totalRecords) * 100);
                this.message = `Committing records... ${this.processedCount} of ${this.totalRecords}`;
            }
            this.notifySuccess('Success', `All ${this.totalRecords} leads committed successfully.`);
            this.resetAnalysisView();
        } catch (error) {
            this.notifyError('Submission Error', error);
        } finally {
            this.isProcessing = false;
        }
    }


    handleExcelParsing(reader, file) {
        reader.onload = (e) => {
            try {
                const data = e.target.result;
                const workbook = XLSX.read(data, { type: 'binary' });
                const firstSheetName = workbook.SheetNames[0];
                const worksheet = workbook.Sheets[firstSheetName];
                // Convert to JSON objects directly to preserve column structure
                const jsonData = XLSX.utils.sheet_to_json(worksheet);

                this.beginIterativeAnalysis(jsonData);
            } catch (error) {
                this.notifyError('Excel Parsing Error', error);
                this.isProcessing = false;
            }
        };
        reader.readAsBinaryString(file);
    }

    handleCsvParsing(reader, file) {
        reader.onload = (e) => {
            try {
                const data = e.target.result;
                const workbook = XLSX.read(data, { type: 'binary' });
                const jsonData = XLSX.utils.sheet_to_json(workbook.Sheets[workbook.SheetNames[0]]);
                this.beginIterativeAnalysis(jsonData);
            } catch (error) {
                this.notifyError('CSV Parsing Error', error);
                this.isProcessing = false;
            }
        };
        reader.readAsBinaryString(file);
    }

    async beginIterativeAnalysis(rawObjects) {
        if (!rawObjects || rawObjects.length === 0) {
            this.notifyError('Analysis Error', 'No data found in the file.');
            this.isProcessing = false;
            return;
        }

        this.totalRecords = rawObjects.length;
        this.processedCount = 0;
        this.progress = 0;
        this.previewData = [];

        // Map raw Excel field names to ouur expected wrap names
        const normalizedLeads = this.normalizeInputFields(rawObjects);
        const BATCH_SIZE = 1000;

        try {
            for (let i = 0; i < normalizedLeads.length; i += BATCH_SIZE) {
                const chunk = normalizedLeads.slice(i, i + BATCH_SIZE);
                const result = await analyzeSocialMediaLeadsBatch({ inputList: chunk });

                const formattedChunk = this.formatAnalysisResultsForTable(result);
                this.previewData = [...this.previewData, ...formattedChunk];

                this.processedCount += chunk.length;
                this.progress = Math.round((this.processedCount / this.totalRecords) * 100);
                this.message = `Analyzing records... ${this.processedCount} of ${this.totalRecords}`;

                if (this.processedCount > 0) {
                    this.isPreviewAvailable = true;
                }
            }

            this.message = `Analysis complete. Total: ${this.totalRecords} records.`;
            this.messageType = 'success';
        } catch (error) {
            this.notifyError('Analysis Error', error);
        } finally {
            this.isProcessing = false;
        }
    }

    normalizeInputFields(data) {
        return data.map(item => {
            const findKey = (search) => Object.keys(item).find(k => k.toLowerCase() === search.toLowerCase());

            return {
                name: item[findKey('name')] || item[findKey('full name')] || '',
                email: item[findKey('email')] || item[findKey('email address')] || '',
                phone: item[findKey('phone')] || item[findKey('phone number')] || item[findKey('mobile')] || '',
                secondaryPhone: item[findKey('secondary phone')] || item[findKey('secondary phone number')] || '',
                whatsappNumber: item[findKey('whatsapp number')] || item[findKey('whatsapp')] || '',
                source: item[findKey('source')] || '',
                channel: item[findKey('channel')] || '',
                cif: item[findKey('cif')] || item[findKey('cif number')] || '',
                isCustomer: false,
                isBlacklisted: false,
                terminatedRelationship: false,
                hasActiveCreditCard: false,
                hasPendingCreditCard: false,
                hasDeclinedCreditCard: false
            };
        });
    }


    requestLeadAnalysis(base64Data, fileName) {
        analyzeSocialMediaLeads({ base64Data, fileName })
            .then(result => {
                this.previewData = this.formatAnalysisResultsForTable(result);
                this.isPreviewAvailable = true;
                this.message = 'Analysis complete. Please review results and click Submit.';
                this.messageType = 'success';
            })
            .catch(error => {
                this.notifyError('Analysis Error', error);
            })
            .finally(() => { this.isProcessing = false; });
    }

    get renderedPreviewData() {
        if (!this.previewData || this.previewData.length === 0) return [];
        const start = (this.pageNumber - 1) * this.rowsPerPage;
        const end = start + this.rowsPerPage;
        return this.previewData.slice(start, end);
    }


    formatAnalysisResultsForTable(data) {
        return data.map(record => {
            const row = { ...record };

            row.isCustomer_str = record.isCustomer ? 'Active Customer' : 'False';
            row.isBlacklisted_str = record.isBlacklisted ? 'True' : 'False';
            row.terminatedRelationship_str = record.terminatedRelationship ? 'True' : 'False';
            row.hasActiveCreditCard_str = record.hasActiveCreditCard ? 'True' : 'False';
            row.hasPendingCreditCard_str = record.hasPendingCreditCard ? 'True' : 'False';
            row.hasDeclinedCreditCard_str = record.hasDeclinedCreditCard ? 'True' : 'False';

            row.isCustomer_class = record.isCustomer ? YES_CLASS : NO_CLASS;
            row.isBlacklisted_class = record.isBlacklisted ? WARN_CLASS : NO_CLASS;
            row.terminatedRelationship_class = record.terminatedRelationship ? WARN_CLASS : NO_CLASS;
            row.hasActiveCreditCard_class = record.hasActiveCreditCard ? YES_CLASS : NO_CLASS;
            row.hasPendingCreditCard_class = record.hasPendingCreditCard ? YES_CLASS : NO_CLASS;
            row.hasDeclinedCreditCard_class = record.hasDeclinedCreditCard ? WARN_CLASS : NO_CLASS;

            row.accountUrl = record.accountId ? `/lightning/r/Account/${record.accountId}/view` : '';

            return row;
        });
    }

    prepareRecordsForDatabase(data) {
        return data.map(record => ({
            name: record.name,
            email: record.email,
            phone: record.phone,
            secondaryPhone: record.secondaryPhone,
            whatsappNumber: record.whatsappNumber,
            source: record.source,
            channel: record.channel,
            cif: record.cif,
            isCustomer: record.isCustomer === true,
            isBlacklisted: record.isBlacklisted === true,
            terminatedRelationship: record.terminatedRelationship === true,
            hasActiveCreditCard: record.hasActiveCreditCard === true,
            hasPendingCreditCard: record.hasPendingCreditCard === true,
            hasDeclinedCreditCard: record.hasDeclinedCreditCard === true
        }));
    }


    startProcessing() {
        this.isProcessing = true;
        this.message = '';
        this.isPreviewAvailable = false;
    }

    notifySuccess(title, msg) {
        this.showToast(title, msg, 'success');
        this.message = msg;
        this.messageType = 'success';
    }

    notifyError(title, error) {
        const errorMsg = error.body?.message || error.message || error;
        this.showToast(title, errorMsg, 'error');
        this.message = 'Error: ' + errorMsg;
        this.messageType = 'error';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    get messageContainerClass() {
        const base = 'slds-notify slds-notify_alert ';
        if (this.messageType === 'success') return base + 'slds-alert_success';
        if (this.messageType === 'error') return base + 'slds-alert_error';
        return base + 'slds-alert_offline';
    }
}