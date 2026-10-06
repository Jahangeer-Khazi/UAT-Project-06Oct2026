import { LightningElement,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import callRLOSInquiry from '@salesforce/apex/JordanLoanController.callRLOSInquiry';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';

export default class JordanLoanRLOSInquiry extends LightningElement {

    showSpinner = true;
    isSuccess = false;
    msg = "";
    //@api recordId;
    _recordId;

    @api set recordId(value) {
        this._recordId = value;
        this.callJordanRLOSInquiry();
    }

    get recordId() {
        return this._recordId;
    }

    callJordanRLOSInquiry(){
        
        callRLOSInquiry({recordId : this.recordId})
            .then((response) => {
                console.log('response - ', response);
                if(response.isSuccess){
                    this.isSuccess = true;
                    let responseStatus = '';
                    let approvedAmount = 0;
                    if(Array.isArray(response.responseData)){
                        if(response.responseData.length > 0){
                            const data = response.responseData[0];
                            responseStatus = data.applicationStatus;
                            this.msg = `LOS Inquiry status is - ${data.applicationStatus}. Loan case status is being updated.`;
                        }
                        else {
                            this.msg = "RLOS has already processed. Loan case status is being updated.";
                            responseStatus = data.applicationStatus; 
                        }
                    }
                    else {
                        this.msg = "RLOS Status retrieved successfully. Loan case status is being updated.";
                        responseStatus = data.applicationStatus;
                    }

                    let strStatus = '';
                    let shouldUpdateRecord = false;
                    if(responseStatus && responseStatus.toLowerCase() == 'completed'){
                        //update jordan status
                        strStatus = 'LOS Approved';
                        shouldUpdateRecord = true;
                        approvedAmount = response.responseData[0].approvedAmount;
                    }
                    else if(responseStatus && responseStatus.toLowerCase() == 'decline' || 
                            responseStatus && responseStatus.toLowerCase() == 'rejected'){
                        strStatus = 'LOS Rejected';
                        shouldUpdateRecord = true;
                    }
                    else {
                        // considering the status inprocess.
                    }

                    if(shouldUpdateRecord){
                        const fields = {
                            Id : this.recordId,
                            Status__c : strStatus,
                            Approved_Amount__c : approvedAmount
                        };

                        const recordInput = { fields };
                        updateRecord(recordInput)
                        .then(() => {
                            console.log('Record updated');
                            this.closePopup();
                        })
                        .catch(error => {
                            console.error(error);
                        });
                    }
                    else {
                        this.closePopup();
                    }
                }
                else {
                    this.isSuccess = false;
                    //this.showSnackbar('Error',response,'error');
                    if(response.errorData){
                        this.msg = JSON.stringify(response.errorData);
                    }
                    else {
                        this.msg = JSON.stringify(response);
                    }
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                console.error('Error:', error);
                this.closePopup();
                //this.showSnackbar('Error',error,'error');
                this.showSpinner = false;
                this.isSuccess = false;
                if(error.message){
                    this.msg = error.message;
                }
                else {
                    this.msg = error;
                }
            })
    }

    showSnackbar(title,message,variant) {
        const event = new ShowToastEvent({
            title: title, 
            message: message, 
            variant: variant, 
            mode: 'dismissable' 
        });
        this.dispatchEvent(event);
    }

    closePopup(){
        //Popup would be closed after 5 seconds.
        setTimeout(()=>{
            this.dispatchEvent(new CloseActionScreenEvent());
        },5000);
    }
}