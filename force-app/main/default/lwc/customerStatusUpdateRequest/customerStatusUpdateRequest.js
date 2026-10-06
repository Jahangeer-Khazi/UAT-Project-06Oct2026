import { LightningElement,wire,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';

import { getObjectInfo,getPicklistValues } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';

import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import getAccountDetails from '@salesforce/apex/CustomerProfileUpdateController.getAccountDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

const FIELDS = [
    //NAME_FIELD,
    //IS_BUSINESS_LIGHT_CUSTOMER_FIELD,
    //IS_ABCI_FIELD//,
    //REGION_FLAG_FIELD
];
export default class CustomerStatusUpdateRequest extends LightningElement {

    _recordId;

    @api
    set recordId(value) {
        this._recordId = value;
        if (value) {
            //this.handleRecordIdAvailable();
            console.log("Record Id Populated. ",value);
            this.fetchAccountDetails();
        }

    }

    get recordId() {
        return this._recordId;
    }

    //@api recordId;
    wiredRecordId;
    recordTypeId;
    accountDetails;
    customerStatusUpdate = '';
    isFormReady = false;
    isLoading = false;

    selectedSubTypeValue = 'Add Flag';
    selectedType = '';

    subTypeOptions = [];

    showSubType = false;
    showDelinquencyReason = false;
    showDelinquencyOtherReason = false;
    isBusinessLightWarning = false;
    isCustomerStatusUpdate = true;

    caseSubject = 'Customer Status Update';
    caseDescription = 'Customer Status Update';

    connectedCallback() {
        console.log('recordId', this.recordId);
    }

    renderedCallback() {
        console.log('Rendered Callback RecordId', this.recordId);
        if(this.recordId && this.accountDetails == undefined){
            
        }
    }

    get showCustomerStatusUpdate() {
        return this.isFormReady && this.isCustomerStatusUpdate;
    }


    fetchAccountDetails(){
        console.log('Rendered Callback RecordId2', this.recordId);
        getAccountDetails({recordId : this.recordId})
        .then((response) => {
            console.log("response account ",response);
            this.isFormReady = true;
            this.accountDetails = response;
            this.customerStatusUpdate = response.CustomerStatus__c;
        })
        .catch((error) => {
            console.error('Error:', error);
        });
    }
    
    get customerRegion() {
        return getFieldValue(this.account.data, REGION_FLAG_FIELD);
    }

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    objectInfo({ data, error }) {
        if (data) {
            const rtis = data.recordTypeInfos;
            console.log("record type id is ",data.recordTypeInfos);
            // Example: get record type by name
            this.recordTypeId = Object.keys(rtis).find(
                rtId => rtis[rtId].name === 'Customer Profile Update'
            );

            console.log("record type id is ",this.recordTypeId);
        }
        if (error) {
            console.error(error);
        }
    }


    handleSuccess(event) {
        console.log('Case Created Id: ' + event.detail.id);
        this.isLoading = false;
        const recordId = event.detail.id;

        this.closeAction();
        // Navigate to record view page
        setTimeout(() => {
            window.location.href = `/lightning/r/Case/${recordId}/view`;
        },500);
        
    }

    handleCancel(){
        this.closeAction();
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleTypeChange(event){
        debugger;
        this.selectedType = event.detail.value;
        this.showSubType = false;
        this.showDelinquencyReason = false;
        this.showDelinquencyOtherReason = false;
        this.isBusinessLightWarning = false;
        this.isCustomerStatusUpdate = false;
        if(this.selectedType == 'Update ABCI Flag' || this.selectedType == 'Update Business Light Flag' || this.selectedType == 'Update Delinquency Reason'){
            
            if(this.accountDetails && this.accountDetails.Region_Flag__pc == 'Bahrain'){
                this.isBusinessLightWarning = true;
                this.showToast('Warning',`"${this.selectedType}" type is not available for Bahrain Region`,'error');
                return;
            }
            else {
                this.showSubType = true;
            }

            let optionName = "";
            if(this.selectedType == 'Update ABCI Flag'){
                //checking current flag status and adding the option for sub type
                optionName = this.accountDetails.Is_ABCI__c ? "Remove Flag" : "Add Flag";
                this.caseSubject = 'Update ABCI Flag';
                this.caseDescription = 'Update ABCI Flag';
            }

            if(this.selectedType == 'Update Business Light Flag'){
                //checking current flag status and adding the option for sub type
                optionName = this.accountDetails.Is_Business_Light_Customer__c ? "Remove Flag" : "Add Flag";
                this.caseSubject = 'Update Business Light Flag';
                this.caseDescription = 'Update Business Light Flag';
            }

            this.selectedSubTypeValue = optionName;
            this.subTypeOptions = [
                { label: optionName, value: optionName }
            ];
        }

        
        if(this.selectedType == 'Update Delinquency Reason'){
            this.showDelinquencyReason = true;
            this.showSubType = false;
            this.caseSubject = 'Update Delinquency Reason';
            this.caseDescription = 'Update Delinquency Reason';
        }

        if(this.selectedType == 'Customer Status Update'){
            this.caseSubject = 'Customer Status Update';
            this.caseDescription = 'Customer Status Update';
            this.isCustomerStatusUpdate = true;
        }

        if(this.selectedType == 'Personal Info Update'){
            this.caseSubject = 'Personal Info Update';
            this.caseDescription = 'Personal Info Update';
        }
    }

    showToast(title,message,variant) {
        const event = new ShowToastEvent({
            title: title, 
            message: message, 
            variant: variant, 
            mode: 'dismissable' 
        });
        this.dispatchEvent(event);
    }

    handleDelinqReasonChange(event){
        const selectedReason = event.detail.value;
        this.showDelinquencyOtherReason = false;
        if(selectedReason && selectedReason == 'Other'){
            this.showDelinquencyOtherReason = true;
        }
    }

    handleSubmit(event){
        event.preventDefault();
        
        if(this.selectedType == 'Update ABCI Flag' || this.selectedType == 'Update Business Light Flag' || this.selectedType == 'Update Delinquency Reason'){
            if(this.accountDetails && this.accountDetails.Region_Flag__pc == 'Bahrain'){
                this.isBusinessLightWarning = true;
                this.showToast('Warning',`"${this.selectedType}" type is not available for Bahrain Region`,'error');
                return;
            }
        }
       

        this.isLoading = true;

        const fields = event.detail.fields;
        console.log("form submit value ",fields);

        //Setting fields by default values.
        fields.Status = 'New';
        if(this.showSubType){
            fields.Sub_Type__c = this.selectedSubTypeValue;
        }
        fields.Sub_Status__c = 'In-Progress';

        fields.AccountId = this.recordId;

        if(this.accountDetails.PersonContactId){
            fields.ContactId = this.accountDetails.PersonContactId;
        }
        
        if(this.accountDetails.Subscription_Model__pc){
            fields.Case_Model__c = this.accountDetails.Subscription_Model__pc;
        }

        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSubTypeChange(event){
        this.selectedSubTypeValue = event.detail.value;
    }

    handleError(event) {
        debugger;
        console.error('Error saving record:', event.detail);
        console.error('Error saving record:', JSON.stringify(event.detail));
        this.isLoading = false;
    }
}