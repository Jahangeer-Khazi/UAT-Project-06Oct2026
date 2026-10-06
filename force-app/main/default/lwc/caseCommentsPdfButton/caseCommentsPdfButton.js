import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const VF_PAGE_NAME = 'CaseCommentsPDF';

export default class CaseCommentsPdfButton extends NavigationMixin(LightningElement) {
    @api recordId;

    @track isModalOpen = false;
    @track isLoading = false;
    @track pdfUrl = '';

    get vfPageUrl() {
        return `/apex/${VF_PAGE_NAME}?id=${this.recordId}`;
    }

    handleOpenPdf() {
        if (!this.recordId) {
            console.error('CaseCommentsPdfButton: recordId is not set.');
            return;
        }
        this.pdfUrl = this.vfPageUrl;
        this.isLoading = true;
        this.isModalOpen = true;
    }

    handleIframeLoad() {
        this.isLoading = false;
    }

    handleCloseModal() {
        this.isModalOpen = false;
        this.isLoading = false;
        this.pdfUrl = '';
    }

    handleOpenNewTab() {
        window.open(this.vfPageUrl, '_blank');
    }

    handleWord() {
        const childLwc = this.template.querySelector('c-case-comments-pdf-preview');
        if (childLwc) {
            try {
                childLwc.generateWord();
            } catch (e) {
                this.dispatchEvent(new ShowToastEvent({ title: 'Error generating Word', message: e.message || 'Unknown error', variant: 'error' }));
            }
        } else {
            this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: 'Data component not found or still loading.', variant: 'error' }));
        }
    }

    handleWordSuccess() {
        this.dispatchEvent(new ShowToastEvent({ title: 'Success', message: 'Word document downloaded successfully!', variant: 'success' }));
    }

    handleWordError(event) {
        this.dispatchEvent(new ShowToastEvent({ title: 'Error generating Word', message: event.detail, variant: 'error' }));
    }

}