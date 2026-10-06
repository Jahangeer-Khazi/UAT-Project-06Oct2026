import { LightningElement,wire } from 'lwc';
import getWavierLimit from '@salesforce/apex/WavierLimitController.getWavierLimit';
import { refreshApex } from "@salesforce/apex";
import { updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
/*
{ label: 'Number', fieldName: 'caseRecordLink', type: 'url',initialWidth: 140, 
        typeAttributes: {
            label: { fieldName: 'caseNumber' },
            target: '_blank'
        } 
    },
*/

const COLUMNS = [
    
    { label: 'Name', fieldName: 'Name',initialWidth: 150 },
    { label: 'Role Name', fieldName: 'Role_Name__c',initialWidth: 200 },
    { label: 'Budget', fieldName: 'Budget__c',initialWidth: 100 },
    { label: 'Utilization', fieldName: 'Utilization__c',initialWidth: 150 },
    { label: 'Remaining Limit', fieldName: 'Remaining_Limit__c',initialWidth: 120 },
    { label: 'CRM Queue', fieldName: 'CRM_Queue__c',initialWidth: 300 },
    { label: 'Max Waiver Amount',fieldName:'Max_Waiver_Amount__c',initialWidth: 200 }
];


export default class WavierLimit extends LightningElement {

    numberOfRecords = 0;
    _wavierDataResult;
    data;
    showSpinner = true;
    columns = COLUMNS;
    draftValues = [];

    @wire(getWavierLimit)
        wavierLimit(result){
            this._wavierDataResult = result;
            this.showSpinner = false;
            console.log("wire response ",result.data);
            if(result.data != undefined && result.data.responseData){    
                this.data = result.data.responseData;
            }

            if(result.error){
                console.error("Error while fetching records",resulterror);
            }
        }


    async handleSave(event){
        const records = event.detail.draftValues.slice().map((draftValue) => {
        const fields = Object.assign({}, draftValue);
            return { fields };
        });
        console.log("records to edit ",records);
        console.log("records this.draftValues ",this.draftValues);
        // Clear all datatable draft values
        this.draftValues = [];

        //updating all the record(s)
        try{
            this.showSpinner = true;
            const recordUpdatePromises = records.map((record) => updateRecord(record));
            await Promise.all(recordUpdatePromises);

            // Report success with a toast
            this.dispatchEvent(
                new ShowToastEvent({
                title: "Success",
                message: "Wavier limit updated successfully.",
                variant: "success"
                })
            );

            await refreshApex(this._wavierDataResult);
            this.showSpinner = false;
        }
        catch(error){
            this.dispatchEvent(
                new ShowToastEvent({
                title: "Error updating or Wavier Limits",
                message: error.body.message,
                variant: "error"
                })
            );
        }
    }
}