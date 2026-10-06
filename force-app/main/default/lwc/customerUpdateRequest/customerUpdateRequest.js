import { LightningElement,wire,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';
import { getObjectInfo,getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';

//import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import getAccountDetails from '@salesforce/apex/CustomerProfileUpdateController.getAccountDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CustomerUpdateRequest extends LightningElement {
    headerTitle = "Customer Status Update Request"; 
    recordTypeId;
    caseSubject = 'Customer Status Update';
    caseDescription = 'Customer Status Update';
    isLoading = false;
    accountDetails;
    customerStatusUpdate = '';
    isCustomerStatusUpdateAction = false;
    showSubType = true;
    showDelinquencyOtherReason = false;
    selectedReason = "";
    selectedSubType = "";
    selectedType = "";
    selectedCustomerUpdateStatus = "";
    isJordanCustomerUpdate = false;
    isCustomerUpdateStatus = false;
    customTypePicklist = [];

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

    // Get Picklist Metadata
    @wire(getPicklistValuesByRecordType, {objectApiName:'Case',recordTypeId:'0121t000000MKbJAAW'})
    wiredPicklists({ data, error }) {
        if(data){
            console.log('Type ',data.picklistFieldValues.Type.values);
            console.log('Sub_Type__c ',data.picklistFieldValues.Sub_Type__c.values);
        }
        else {
            console.log('err ',error);
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(pageRef) {
        console.log("Page Ref  ",pageRef);
        if (pageRef && pageRef.type === 'standard__quickAction') {
            // This returns the API Name (e.g., "Account.TypeA_MyAction")

            this.customTypePicklist.push({label : 'Customer Status Update', value : 'Customer Status Update'});
            this.customTypePicklist.push({label : 'Personal Info Update', value : 'Personal Info Update'});
            /*if(pageRef.attributes.apiName.includes('Customer_Status_Update')){
                this.isCustomerStatusUpdateAction = true;
                this.selectedType = "Personal Info Update";
            }*/
            if(pageRef.attributes.apiName.includes('Jordan_Update_Customer_Profile')){
                //this.isCustomerStatusUpdateAction = true;
                this.headerTitle = "Jordan Customer Profile Update";
                this.isJordanCustomerUpdate = true;
                this.selectedType = "Update Business Light Flag";
                this.customTypePicklist = [];
                this.customTypePicklist.push({label : 'Customer Business Light Flag Update', value : 'Update Business Light Flag'});
                this.customTypePicklist.push({label : 'Customer ABCI Flag Update', value : 'Update ABCI Flag'});
                this.customTypePicklist.push({label : 'Customer Delinquency Reason Update', value : 'Update Delinquency Reason'});
                this.customTypePicklist.push({label : 'Update Preferential FD Rate Flag', value : 'Update Preferential FD Rate Flag'});
            }
            else {
                this.headerTitle = "Customer Profile Update";
                this.selectedType = "Customer Status Update";
                this.isCustomerUpdateStatus = true;
                this.selectedCustomerUpdateStatus = 'Active';
            }
        }
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

    fetchAccountDetails(){
        console.log('Rendered Callback RecordId2', this.recordId);
        getAccountDetails({recordId : this.recordId})
        .then((response) => {
            console.log("response account ",response);
            this.accountDetails = response;
            this.customerStatusUpdate = response.CustomerStatus__c;
            if(this.isJordanCustomerUpdate){
                this.selectedSubType = this.accountDetails.Is_Business_Light_Customer__c ? "Remove Flag" : "Add Flag";
            }
        })
        .catch((error) => {
            console.error('Error:', error);
        });
    }


    //picklist change events
    handleCustomerStatusUpdateChange(event){
        this.selectedCustomerUpdateStatus = event.detail.value;
    }

    handleTypeChange(event){ 

        this.selectedType = event.detail.value;

        this.isCustomerUpdateStatus = false;
        if(this.selectedType == 'Customer Status Update'){
            this.isCustomerUpdateStatus = true;
        }


        if(this.isCustomerStatusUpdateAction){
            if(this.selectedType == 'Update ABCI Flag' || this.selectedType == 'Update Business Light Flag' || this.selectedType == 'Update Delinquency Reason'){
                //type is not available for Bahrain Region
                this.showToast('Warning',`"${this.selectedType}" type is not available for Status Update case`,'error');
                return;
            }
        }
        else {
            if(this.selectedType == 'Update ABCI Flag' || this.selectedType == 'Update Business Light Flag' || this.selectedType == 'Update Delinquency Reason'){
                if(this.accountDetails && this.accountDetails.Region_Flag__pc == 'Bahrain'){
                    this.isBusinessLightWarning = true;
                    this.showToast('Warning',`"${this.selectedType}" type is not available for Bahrain Region`,'error');
                    return;
                }

                this.showSubType = true;
                if(this.selectedType == 'Update ABCI Flag'){
                    this.selectedSubType = this.accountDetails.Is_ABCI__c ? "Remove Flag" : "Add Flag";
                }

                if(this.selectedType == 'Update Business Light Flag'){
                    this.selectedSubType = this.accountDetails.Is_Business_Light_Customer__c ? "Remove Flag" : "Add Flag";
                }

                if(this.selectedType == 'Update Delinquency Reason'){
                    this.showSubType = false;
                }
            }
            
        }
    }
    handleSubTypeChange(event){
        this.selectedSubType = event.detail.value;
        console.log('Selected Sub Type => ',this.selectedSubType);
    }

    handleDelinqReasonChange(event){
        this.selectedReason = event.detail.value;
        this.showDelinquencyOtherReason = false;
        if(this.selectedReason && this.selectedReason == 'Other (Specify)' || this.selectedReason == 'Other'){
            this.showDelinquencyOtherReason = true;
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


    //button events
    handleCancel(){
        this.closeAction();
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    //Form events
    handleSubmit(event){
        event.preventDefault();
        console.log('Handle Submit Button');
        console.log('Type:',this.selectedType);
        console.log('Sub Type:',this.selectedSubType);
        console.log('Customer Status Update:',this.isCustomerStatusUpdateAction);
        if(this.isCustomerStatusUpdateAction){
            if(this.selectedType == 'Update ABCI Flag' || this.selectedType == 'Update Business Light Flag' || this.selectedType == 'Update Delinquency Reason' || this.selectedType == 'Update Preferential FD Rate Flag'){
                //type is not available for Bahrain Region
                this.showToast('Warning',`"${this.selectedType}" type is not available for Status Update case`,'error');
                return;
            }
        }
        else {
            if(this.selectedType == 'Update ABCI Flag' || this.selectedType == 'Update Business Light Flag' || this.selectedType == 'Update Delinquency Reason' || this.selectedType == 'Update Preferential FD Rate Flag'){
                if(this.accountDetails && this.accountDetails.Region_Flag__pc == 'Bahrain'){
                    this.isBusinessLightWarning = true;
                    this.showToast('Warning',`"${this.selectedType}" type is not available for Bahrain Region`,'error');
                    return;
                }
            }
            if(this.selectedType == 'Personal Info Update' && this.selectedSubType == 'Credit Card Guarantor CIF'){
                if(this.accountDetails && this.accountDetails.Region_Flag__pc == 'Jordan'){
                    this.showToast('Error', 'Credit Card Guarantor CIF is not applicable for Jordan customers', 'error');
                    return; // Stop form submission
                }
            }
        }

        this.isLoading = true;
        const fields = event.detail.fields;
        fields.Status = 'New';
        fields.Sub_Status__c = 'In-Progress';
        fields.AccountId = this.recordId;

        if(this.selectedType = 'Customer Status Update'){
            fields.CustomerStatusUpdate__c = this.selectedCustomerUpdateStatus;
        }
        else {
            fields.CustomerStatusUpdate__c = '';
        }

        if(this.accountDetails.PersonContactId){
            fields.ContactId = this.accountDetails.PersonContactId;
        }
        
        if(this.accountDetails.Subscription_Model__pc){
            //fields.Case_Model__c = this.accountDetails.Subscription_Model__pc;
        }

        console.log("fields value ",JSON.stringify(fields));
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(event) {
        console.log('Case Created Id: ' + event.detail.id);
        this.isLoading = false;
        const recordId = event.detail.id;

        this.closeAction();
        // Navigate to record view page
        setTimeout(() => {
            window.location.href = `/lightning/r/Case/${recordId}/view`;
        },200);
    }

    handleError(event) {
        debugger;
        console.error('Error saving record:', event.detail);
        console.error('Error saving record:', JSON.stringify(event.detail));
        this.isLoading = false;
    }
}