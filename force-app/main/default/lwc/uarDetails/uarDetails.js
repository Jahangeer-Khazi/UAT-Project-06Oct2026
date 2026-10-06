import { LightningElement, api } from 'lwc';

export default class UarDetails extends LightningElement {
    vfPageUrl;
    _recordId;
    showDownloadButton = false;
    isLoading = true; // Start with loading true
    hasRendered = false; // Flag to prevent multiple executions

    @api
    get recordId() {
        return this._recordId;
    }

    set recordId(value) {
        if (value) {
            this._recordId = value;
            console.log('Record Id received:', value);
            this.vfPageUrl = `/apex/UARDetailsPDF?id=${this._recordId}`;
        }
    }

    renderedCallback() {
        if (!this.hasRendered) {  // Ensure this runs only once
            this.hasRendered = true;
            console.log('Setting isLoading to true...');
            this.isLoading = true;

            setTimeout(() => {
                this.handleIframeLoad();
            }, 5000);
        }
    }

    handleIframeLoad() {
        console.log('Iframe loaded, hiding loader...');
        this.isLoading = false;
        this.showDownloadButton = true;

        // Force re-render if UI is not updating
        this.forceRender();
    }

    triggerDownload() {
        this.isLoading = true;
        console.log('Download triggered, showing loader...');

        const downloadUrl = `/apex/UARDetailsPDF?id=${this._recordId}&download=true`;

        let link = document.createElement('a');
        link.href = downloadUrl;
        link.target = '_blank';
        link.download = 'UAR_Details.pdf';

        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);

        setTimeout(() => {
            console.log('Download complete, hiding loader...');
            this.isLoading = false;
            //this.forceRender();
        }, 3000);
    }

    // Force re-render if the UI does not update
    forceRender() {
        this.showDownloadButton = !this.showDownloadButton;
        setTimeout(() => {
            this.showDownloadButton = !this.showDownloadButton;
        }, 50);
    }
}