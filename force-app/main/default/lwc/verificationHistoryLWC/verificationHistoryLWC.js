import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
//import CustomerID from "@salesforce/schema/Account.CIF__pc";
import getVerificationHistory from '@salesforce/apex/IDVVerificationService.getVerificationHistory';
//const FIELDS = [CustomerID];
export default class VerificationHistoryLWC extends LightningElement {
    dataIsRetrieved = false;
    showTable = true;
    @api recordId;
    @track dataToDisplay;
	@track sortBy='createdDate';
    @track sortDirection='desc';
  //  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
   // account;
     @wire(getVerificationHistory, { recordId: "$recordId" })
     wiredRecords({ err, data }) {
        if (err) {
            console.log('error: ',err);
        } else if (data) {
            this.dataIsRetrieved = true;
            console.log('getRecords results: ',data);
             this.dataToDisplay=data;
			 this.sortData(this.sortBy, this.sortDirection);
           /* data.forEach(record => {
               this.dataToDisplay.push({
                id: record.vfid,
                status: record.status,
                numberOfRetries: record.numberOfRetries,
                crmCaseId: record.crmCaseId,
                activity: record.activity,
                createdDate: record.createdDate,
                lastUpdatedDate: record.lastUpdatedDate
                });
            });*/
        }}
    columns = [
        { label: 'Unit', fieldName: 'vfid', hideDefaultActions: true },
        { label: 'Status', fieldName: 'status', hideDefaultActions: true },
        { label: 'Retries', fieldName: 'numberOfRetries', hideDefaultActions: true },
        { label: 'CRM Case Number', fieldName: 'crmCaseId', hideDefaultActions: true },
        { label: 'Date Time Stamp', fieldName: 'createdDate', hideDefaultActions: true, type: 'date', typeAttributes:{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:false}},
        { label: 'Activity', fieldName: 'activity', hideDefaultActions: true },
        { label: 'lastUpdatedDate', fieldName: 'lastUpdatedDate', hideDefaultActions: true ,type: 'date', typeAttributes:{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:false}},
		{ label: 'Authentication Method', fieldName: 'authMethod', hideDefaultActions: true }
    ];
	
	  doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.dataToDisplay));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.dataToDisplay = parseData;
    }    
	
    //dataToDisplay = JSON.parse('[{"Unit":"Bahrain","Status":"Block","Retries":"2","CRMCaseNumber":"12345","DateTimeStamp":"23/10/2024, 10:12","Activity":"New","AuthenticationMethod":"Email"}]');
}