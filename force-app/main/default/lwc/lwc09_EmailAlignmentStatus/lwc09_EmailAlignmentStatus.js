import { LightningElement, api, wire, track } from 'lwc';
import getEmailAlignmentDetails from '@salesforce/apex/LoginActivityDetailsService.getEmailAlignmentDetails';
import getMobileChangeHistory from '@salesforce/apex/LoginActivityDetailsService.getMobileChangeHistory';
import getEmailChangeHistory from '@salesforce/apex/LoginActivityDetailsService.getEmailChangeHistory';

export default class Lwc09_EmailAlignmentStatus extends LightningElement {
    @api recordId;
    @track emailDetails;
    @track error;
    @track isLoading = true;

    @wire(getEmailAlignmentDetails, { customerId: '$recordId' })
    wiredEmailDetails({ error, data }) {
        this.isLoading = true;
        if (data) {
            this.emailDetails = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.emailDetails = undefined;
        }
        this.isLoading = false;
    }

    get isAligned() {
        return this.emailDetails && this.emailDetails.isAligned;
    }

    get isNotAligned() {
        return this.emailDetails && !this.emailDetails.isAligned;
    }

    get statusClass() {
        return this.isAligned ? 'slds-text-color_success' : 'slds-text-color_error';
    }

    get iconName() {
        return this.isAligned ? 'utility:success' : 'utility:error';
    }

    get iconVariant() {
        return this.isAligned ? 'success' : 'error';
    }



    handleViewMobileChanges() {
        this.isLoading = true;
        getMobileChangeHistory({ customerId: this.recordId })
            .then(result => {
                const cif = this.emailDetails?.cif || '';
                this.downloadCsv(result, `MobileChange_History_${cif}.csv`);
            })
            .catch(error => {
                this.error = error;
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleViewEmailChanges() {
        this.isLoading = true;
        getEmailChangeHistory({ customerId: this.recordId })
            .then(result => {
                const cif = this.emailDetails?.cif || '';
                this.downloadCsv(result, `EmailChange_History_${cif}.csv`);
            })
            .catch(error => {
                this.error = error;
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    downloadCsv(data, filename) {
        if (!data || data.length === 0) return;

        let rowEnd = '\n';
        let csvString = '';

        // Headers (Dynamic based on map keys)
        let headers = Object.keys(data[0]);
        csvString += headers.join(',') + rowEnd;

        // Rows
        data.forEach(row => {
            let line = headers.map(header => {
                let cell = row[header] === null ? '' : row[header];
                return '"' + cell + '"';
            }).join(',');
            csvString += line + rowEnd;
        });

        // Download
        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        downloadElement.download = filename;
        document.body.appendChild(downloadElement);
        downloadElement.click();
        document.body.removeChild(downloadElement);
    }
}