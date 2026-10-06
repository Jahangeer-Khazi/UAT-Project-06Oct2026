import { LightningElement,api,wire } from 'lwc';
import sendEmail from '@salesforce/apex/CustomEmailComposerController.sendEmail';
import getJordanCase from '@salesforce/apex/CustomEmailComposerController.getJordanCase';
import getHtmlTemplate from '@salesforce/apex/CustomEmailComposerController.getHtmlTemplate';
import { RefreshEvent } from 'lightning/refresh';

export default class CustomEmailComposer extends LightningElement {

    @api recordId;

    toolbarConfig = [
        ['bold', 'italic', 'underline', 'strike'],
        ['link', 'blockquote', 'code-block'],
        [{ list: 'ordered' }, { list: 'bullet' }],
        ['clean']
    ];

    matchingInfo = {
        primaryField: { fieldPath: 'PersonEmail' }
    };

    displayInfo = {
        primaryField: 'Name'
    };
    
    htmlTemplate = '';
    toAddress = '';
    ccAddress = '';
    subject = '';
    body = '';
    jordanCaseNumber = '';
    customerName = '';

    showEmailComposer = false;
    isCustomerAssociatedWithRecord = true; // assuming that each jordan loan record would be associated with customer.
    isCustomerFound = false;
    errorMessage = '';
    successMessage = '';

    connectedCallback() {
        this.ccAddress = '';
    }

    @wire(getJordanCase,{recordId: '$recordId'})
        jordanCaseData({data,error}){
            console.log("data template ",data);
            if(data != undefined){
                this.jordanCaseNumber = data.jordanCase.Name;
                this.subject = `Loan Request - [${this.jordanCaseNumber}]`;
                if(data.jordanCase.Customer__r != null){
                    this.toAddress = data.jordanCase.Customer__r.PersonEmail;
                    this.isCustomerFound = true;
                    this.customerName = data.jordanCase.Customer__r.Name;
                }

                if(data.htmlTemplate != undefined && data.htmlTemplate != null){
                    let jordanTemplate = data.htmlTemplate;
                    jordanTemplate = jordanTemplate.replace("{!Case.Contact_First_Name__c}",this.customerName);
                    this.htmlTemplate = jordanTemplate;
                }
                
                console.log("Jordan Case ",this.jordanCaseNumber);
            }
        }

    handleChange(event) {
        console.log("event handle change. ",event);
        console.log("event.target.name ",event.target.name);
        const field = event.target.name;
        this[field] = event.target.value;
    }

    validateEmail(email) {
        // Simple regex for email validation
        const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(email);
    }


    handleRecordPickerChange(event) {
        console.log("Record Picker ",event);
        const record = event.detail.record;
        if (record && record.fields.Email) {
            this.toAddress = record.fields.Email.value;
        } else {
            this.toAddress = '';
        }
    }

    handleSend() {

        console.log("event handle To. ",this.toAddress);
        console.log("event handle Subject. ",this.subject);
        console.log("event handle Body. ",this.body);

        const container = this.template.querySelector('.htmlTemplateContainer');
        console.log("container 97 ",container);
        console.log("container innerHTML ",container.innerHTML);
        
        
        this.errorMessage = '';
        this.successMessage = '';

        if (!this.toAddress) {
            this.errorMessage = 'To Address is required.';
            return;
        }
        if (!this.subject) {
            this.errorMessage = 'Subject is required.';
            return;
        }

        if (!this.validateEmail(this.toAddress)) {
            this.errorMessage = 'Please enter a valid To email address.';
            return;
        }

        if(this.ccAddress && this.validateEmail(this.ccAddress)){
            this.errorMessage = 'Please enter a valid Cc email address.';
            return;
        }

        if(container.innerHTML == "" || container.innerHTML == "<br>"){
            this.errorMessage = 'Enter email message.';
            return;
        }

        if(this.subject.indexOf(`[${this.jordanCaseNumber}]`) < 0){
            this.subject = this.subject + ` [${this.jordanCaseNumber}]`;
        }

        
        sendEmail({ toAddress:this.toAddress,ccAddress:this.ccAddress, subject:this.subject, body:container.innerHTML, recordId:this.recordId})
            .then(() => {
                this.successMessage = 'Email sent successfully!';
                //this.subject = '';
                this.ccAddress = '';
                //this.body = '';
                console.log("refreshing the cmps");
                this.dispatchEvent(new RefreshEvent());
                console.log("refreshed the cmps");
            })
            .catch(error => {
                this.errorMessage = 'Error sending email: ' + error.body.message;
            });
    }

    handleResetTemplateClick(){
        const container = this.template.querySelector('.htmlTemplateContainer');
        console.log("container 147 ",container);
        container.innerHTML = this.htmlTemplate;
    }

    handleEmailButtonClicked(){
        console.log("this.htmlTemplate ",this.htmlTemplate);
        if(this.isCustomerFound){
            this.showEmailComposer = true;
        }
        else {
            this.isCustomerAssociatedWithRecord = false;
        }

        setTimeout(()=>{
            const container = this.template.querySelector('.htmlTemplateContainer');
            console.log("container 147 ",container);
            container.innerHTML = this.htmlTemplate;
        },1000);
    }
}