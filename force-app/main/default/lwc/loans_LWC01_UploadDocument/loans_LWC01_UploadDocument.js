// Loans_LWC01_UploadDocument.js
import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadDocument from '@salesforce/apex/Loans_UploadDocumentController.uploadDocument';
import confirmAllDocumentUploaded from '@salesforce/apex/Loans_UploadDocumentController.confirmAllDocumentUploaded';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Case.Status',
    'Case.Sub_Status__c',
    'Case.cc_CC_Application_Source__c'
];
export default class Loans_LWC01_UploadDocument extends LightningElement {
    @api recordId;
    @track selectedFiles = [];
    @track selectedDocumentType = ''
    @track file;
    @track spinnerClass = 'slds-hide';
    @track disableButtons = false;
    @track showConfirmButton = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
     wiredRecord({ error, data }) {
        if (data) {

            const status = data.fields.Status.value;
            const subStatus = data.fields.Sub_Status__c.value;
            const source = data.fields.cc_CC_Application_Source__c.value;
            console.log('showConfirmButton >>  '+ status +' ... ' + subStatus + ' ... ' + source)
           if(status === 'Pending' && subStatus === 'Pending' &&  source === 'Manual'){
               this.showConfirmButton = true;
           }
           else{
                this.showConfirmButton = false;
           }
            
        } else if (error) {
           
            console.error('Error retrieving record:', error);
        }
    }

    documentTypeOptions = [
        { label: 'Bahraini ID', value: 'Bahraini ID' },
        { label: 'Passport', value: 'Passport' },
        { label: 'GCC ID', value: 'GCC ID' },
        { label: 'CPR Extract', value: 'CPR Extract' },
        { label: 'Bahraini Drivers Licence', value: 'Bahraini Drivers Licence' },
        { label: 'Utility Bill', value: 'Utility Bill' },
        { label: 'Bank Statement', value: 'Bank Statement' },
        { label: 'Tenancy Agreement', value: 'Tenancy Agreement' },
        { label: 'Signature', value: 'Signature' },
        { label: 'Personal Photo', value: 'Personal Photo' },
        { label: 'Residency Permit', value: 'Residency Permit' },
        { label: 'Other', value: 'Other' },
        { label: 'Salary Certificate', value: 'Salary Certificate' },
        { label: 'Commercial Registration', value: 'Commercial Registration' },
        { label: 'Electricity bill', value: 'Electricity bill' },
        { label: 'Telephone bill', value: 'Telephone bill' },
        { label: 'Employer\'s letters', value: 'Employer\'s letters' },
        { label: 'Record of any home visit by bank official', value: 'Record of any home visit by bank official' },
        { label: 'Benefit Report (CRB)', value: 'Benefit Report (CRB)' },
        { label: 'Credit Card Application', value: 'Credit Card Application' },
        { label: 'Promissory Note & Authorization Letter', value: 'Promissory Note & Authorization Letter' },
        { label: 'Credit Card Approval Sheet', value: 'Credit Card Approval Sheet' },
        { label: 'Loan Approval Sheet', value: 'Loan Approval Sheet' },
        { label: 'Salary Slip', value: 'Salary Slip' },
        { label: 'Underwriting Bundle', value: 'Underwriting Bundle' },
        { label: 'Professional Practice Certificate', value: 'Professional Practice Certificate' },
        { label: 'Business Bank Statement', value: 'Business Bank Statement' },
        { label: 'Credit Card Statement', value: 'Credit Card Statement' },
        { label: 'SIO Certificate (GOSI / Pension)', value: 'SIO Certificate (GOSI / Pension)' },
        { label: 'Other Source of Income', value: 'Other Source of Income' },
        { label: 'Salary Transfer Letter (STL)', value: 'Salary Transfer Letter (STL)' },
        { label: 'Irrevocable Standing Order', value: 'Irrevocable Standing Order' },
        { label: 'Video Verification', value: 'Video Verification' },
        { label: 'DocuSign Document', value: 'DocuSign Document' },
        { label: 'Conditional Salary Certificate', value: 'Conditional Salary Certificate' },
        { label: 'Outstanding Letter', value: 'Outstanding Letter' }
        
    ];

    handleFileChange(event) {
        const inputFiles = event.target.files;
        if (inputFiles.length === 0) {
            // No file selected, handle accordingly
            return;
        }
        const file = inputFiles[0];
        const reader = new FileReader();

        reader.onload = () => {
            // Successfully read the file, now convert to base64
            const fileContent = this.arrayBufferToBase64(reader.result);
            // console.log(fileContent);
            // Add selected files to the selectedFiles list
            this.selectedFiles = [
                {
                    index: 1, // You may assign a unique identifier if needed
                    fileName: file.name,
                    fileContent: fileContent,
                },
            ];
        };

        reader.onerror = (error) => {
            // Handle file reading error
            console.error('Error reading file:', error);
        };

        // Read the file as ArrayBuffer
        reader.readAsArrayBuffer(file);
    }

    arrayBufferToBase64(buffer) {
        // Convert ArrayBuffer to base64
        var binary = '';
        var bytes = new Uint8Array( buffer );
        var len = bytes.byteLength;
        for (var i = 0; i < len; i++) {
            binary += String.fromCharCode( bytes[ i ] );
        }
        return window.btoa( binary );
    }

    handleDocumentTypeChange(event) {
        this.selectedDocumentType = event.detail.value;
        console.log(this.selectedDocumentType);
    }

    handleUpload() {
        // console.log('handleUpload =>');
        console.log('recordId =>', this.recordId);
        // Check if a document is selected
        if (this.selectedFiles.length === 0) {
            console.error('No files selected for upload.');
            return;
        }

        const fileData = this.selectedFiles[0]; // Assuming only one file is selected
        
        // Call the Apex method to handle the HTTP request
        this.spinnerClass = ''; // Remove 'slds-hide' to show the spinner
        this.disableButtons = true;
        const result = uploadDocument({ caseId: this.recordId, documentType: this.selectedDocumentType, fileName: fileData.fileName, fileContent: fileData.fileContent })
            .then(response => {
                this.spinnerClass = 'slds-hide'; // Add 'slds-hide' to hide the spinner
                this.disableButtons = false;
                console.log(response);
                if(response.isSuccess == true){
                    const toastEvent = new ShowToastEvent({
                        title:'File was uploaded successfully!',
                        message:'Your file was uploaded successfully to DMS.',
                        variant:'success'
                       });
                    this.dispatchEvent(toastEvent);
                    this.selectedFiles = [];
                    this.selectedDocumentType = '';
                } else{
                    const toastEvent = new ShowToastEvent({
                        title:'Error',
                        message:'An error occurred while uploading the file to DMS.',
                        variant:'error'
                       });
                    this.dispatchEvent(toastEvent);
                }
                
            })
            .catch(error => {

                const toastEvent = new ShowToastEvent({
                    title:'Error',
                    message: error,
                    variant:'error'
                   });
                this.dispatchEvent(toastEvent);
            });
    
    }


    handleConfirmAllDocsUploaded() {
        console.log('handleConfirmAllDocsUploaded recordId =>', this.recordId);
        // Check if a document is selected
        

     
        
        // Call the Apex method to handle the HTTP request
        this.spinnerClass = ''; // Remove 'slds-hide' to show the spinner
        this.disableButtons = true;
        const result = confirmAllDocumentUploaded({ caseId: this.recordId})
            .then(response => {
                this.spinnerClass = 'slds-hide'; // Add 'slds-hide' to hide the spinner
                this.disableButtons = false;
                console.log(response);
                if(response.isSuccess == true){
                    const toastEvent = new ShowToastEvent({
                        title:'Uploaded documents are confirmed with success!',
                        message:'Your documents uploading to infinity DMS is confirmed.',
                        variant:'success'
                       });
                    this.dispatchEvent(toastEvent);
                    this.selectedFiles = [];
                    this.selectedDocumentType = '';
                } else{
                    const toastEvent = new ShowToastEvent({
                        title:'Error',
                        message:'An error occurred while confirming documents uploading.',
                        variant:'error'
                       });
                    this.dispatchEvent(toastEvent);
                }
                
            })
            .catch(error => {

                const toastEvent = new ShowToastEvent({
                    title:'Error',
                    message: error,
                    variant:'error'
                   });
                this.dispatchEvent(toastEvent);
            });
    
    }

}