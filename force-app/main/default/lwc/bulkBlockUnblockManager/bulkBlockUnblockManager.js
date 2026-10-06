import { LightningElement, track } from 'lwc';
import readExcelFile from '@salesforce/apex/CSVFileReadLWCCntrl.readExcelFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import templateFile from '@salesforce/resourceUrl/BulkBlockUnblockTemplate';
import saveBulkOperation from '@salesforce/apex/CSVFileReadLWCCntrl.saveBulkOperation';

export default class BulkBlockUnblock extends NavigationMixin(LightningElement) {
    @track data = [];
    @track columns = [];
    @track draftValues = [];
    @track parsedData = [];
    @track contentDocId;

    isLoading = false;

    modelOptions = [
        { label: 'ila', value: 'ila' },
        { label: 'alburaq', value: 'alburaq' }
    ];

    @track subTypeOptions = [];

    caseNatureOptions = [];

    caseOriginOptions = [
        { label: 'CRM', value: 'CRM' }
    ];

    @track selectedType = 'Block Account'; // Default selected type
    @track typeOptions = [
        { label: 'Block Account', value: 'Block Account' },
        { label: 'Unblock Account', value: 'Unblock Account' }
    ];

    handleFileUpload(event) {
        this.isLoading = true;
        const uploadedFiles = event.detail.files;

        if (uploadedFiles.length === 0) {
            this.isLoading = false;
            return;
        }

        const fileName = uploadedFiles[0].name;
        if (!fileName.endsWith('.csv')) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please upload a valid Excel or CSV file.',
                    variant: 'error',
                })
            );
            this.isLoading = false;
            return;
        }

        this.contentDocId = uploadedFiles[0].documentId;
        if (uploadedFiles.length > 0) {
            readExcelFile({ contentDocumentId: uploadedFiles[0].documentId })
                .then(result => {
                    if (result && result.length > 0) {
                        console.log('result -->', JSON.stringify(result));
                        this.data = result;
                        this.parseResponse(result);
                    }
                })
                .catch(error => {
                    console.log('Error --->', JSON.stringify(error));
                    this.isLoading = false;

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: this.parseError(error),
                            variant: 'error',
                        })
                    );
                });
        }
    }

    // Parse the JSON response and format data into an array of objects
    parseResponse(response) {
        let processedData = [];
        let typeSet = new Set();

        response.forEach((obj) => {
            let dataString = Object.values(obj)[0];
            let dataArray = dataString.split(',');

            // Check if CIF (dataArray[0]) is empty or null
            if (!dataArray[0] || dataArray[0].trim() === '') {
                this.isLoading = false;
                throw new Error('CIF number cannot be empty in the uploaded file.');
            }

            if (!dataArray[3] || dataArray[3].trim() === '') {
                this.isLoading = false;
                throw new Error('Type cannot be empty in the uploaded file.');
            }

            if (!dataArray[4] || dataArray[4].trim() === '') {
                this.isLoading = false;
                throw new Error('Sub Type cannot be empty in the uploaded file.');
            }

            let record = {
                CIF: dataArray[0],
                Subject: 'Bulk Block/Unblock Requests',
                Model: dataArray[2],
                Type: dataArray[3],
                SubType: dataArray[4],
                CaseNature: dataArray[5],
                Reason: dataArray[6],
                Origin: 'CRM',
                IBAN: dataArray[8],
                AllAccounts: this.isYes(dataArray[9]),
                BlockAppAccess: this.isYes(dataArray[10]),
                Blacklist: this.isYes(dataArray[11]),
                isFraud: this.isYes(dataArray[12])
            };
            typeSet.add(record.Type);
            processedData.push(record);
        });

        // Check if both "Block Account" and "Unblock Account" exist
        if (typeSet.has('Block Account') && typeSet.has('Unblock Account')) {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please provide the Bulk Blocking or Unblocking of the Accounts in a Seperate File, the sheet can contain only Block Accounts or Unblock Accounts, not both.',
                    variant: 'error'
                })
            );
            return; // Stop further execution
        }

        if (typeSet.has('Block Account')) {
            this.subTypeOptions = [
                { label: 'Block for debit', value: 'Block for debit' },
                { label: 'Block for credit', value: 'Block for credit' },
                { label: 'Block for both', value: 'Block for both' }
            ];
            this.caseNatureOptions = [
                { label: 'Block', value: 'Block' }
            ];
        } else if (typeSet.has('Unblock Account')) {
            this.subTypeOptions = [
                { label: 'Unblock for debit', value: 'Unblock for debit' },
                { label: 'Unblock for credit', value: 'Unblock for credit' },
                { label: 'Unblock for both', value: 'Unblock for both' }
            ];
            this.caseNatureOptions = [
                { label: 'Unblock', value: 'Unblock' }
            ];
        }

        this.parsedData = processedData;

        console.log('parsedData --->', JSON.stringify(this.parsedData));
        this.isLoading = false;
    }

    // Handle input changes
    handleInputChange(event) {
        let index = event.target.dataset.id;
        let field = event.target.dataset.field;
        let value = event.target.value;

        this.parsedData = this.parsedData.map((record, idx) => {
            if (idx == index) {
                return { ...record, [field]: value };
            }
            return record;
        });
    }

    handleSave() {
        this.isLoading = true;
        console.log('parsedData --->', JSON.stringify(this.parsedData));
        // Prepare the data to be sent to Apex
        const recordsToSave = this.parsedData.map(record => ({
            CIF: record.CIF,
            Subject: record.Subject,
            Model: record.Model,
            Type: record.Type,
            SubType: record.SubType,
            CaseNature: record.CaseNature,
            Reason: record.Reason,
            Origin: record.Origin,
            IBAN: record.IBAN,
            AllAccounts: record.AllAccounts === true, // Convert string to Boolean
            BlockAppAccess: record.BlockAppAccess === true, // Convert string to Boolean
            Blacklist: record.Blacklist === true, // Convert string to Boolean
            isFraud: record.isFraud === true // Convert string to Boolean
        }));

        // Call the Apex method to save the data
        saveBulkOperation({ records: recordsToSave, operationType: this.parsedData[0].Type, contentDocumentId: this.contentDocId })
            .then((record) => {
                console.log('record --->', JSON.stringify(record));
                this.navigateToRecord(record);

                // Optionally, reset the data after saving
                this.parsedData = [];
                this.data = [];
            })
            .catch(error => {
                console.log('error --->', JSON.stringify(error));
                this.isLoading = false;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: this.parseError(error),
                        variant: 'error',
                    })
                );

            });
    }

    handleCancel() {
        this.data = [];
        this.parsedData = [];
        this.contentDocId = null;
    }

    handleDownload() {
        // Open the static resource file in a new tab for download
        window.open(templateFile, '_blank');
    }

    handleChange(event) {
        let recordId = event.target.dataset.id;
        let field = event.target.dataset.field;
        let value = event.target.value;

        this.parsedData = this.parsedData.map(record => {
            if (record.CIF === recordId) {
                return { ...record, [field]: value };
            }
            return record;
        });

        console.log("Updated Data: ", this.parsedData);
    }

    navigateToRecord(operationRecord) {
        if (!operationRecord || !operationRecord.Id) {
            console.error('Error: operationRecord is undefined or does not have an Id');
            return;
        }

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: operationRecord.Id,
                actionName: 'view',
            },
        });

        // Execute these actions immediately after navigation
        this.isLoading = false;
        this.showSuccessToast('Success!', 'Bulk Operation created successfully!');
        this.closeQuickAction();
    }


    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    // Toast Notifications
    showSuccessToast(title, message) {
        this.isLoading = false;
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant: 'success',
        }));
    }

    showErrorToast(title, message) {
        this.isLoading = false;
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant: 'error',
        }));
    }

    isYes(value) {
        return String(value).trim().toLowerCase() === 'yes';
    }

    parseError(error) {
        if (error?.body?.message) return error.body.message;
        if (error?.message) return error.message;
        return 'An unexpected error occurred.';
    }

    handleCheckboxChange(event) {
        const index = event.target.dataset.id;
        const field = event.target.dataset.field;
        const isChecked = event.target.checked;

        this.parsedData = this.parsedData.map((record, idx) => {
            if (idx == index) {
                return { ...record, [field]: isChecked };
            }
            return record;
        });

        console.log('Updated Checkbox Field:', field, 'Value:', isChecked);
    }
}