import { LightningElement,wire,api } from 'lwc';
import getWaiverApprovalHistory from '@salesforce/apex/WaiverRequestController.getWaiverApprovalHistory';
//contactId var is used to check if the approver is not a Email Service user's 
import contactId from '@salesforce/label/c.Email_Contact_ID_Waiver_Approval';

const COLUMNS = [
    { label: 'Date', fieldName: 'stepDate', type: 'date', initialWidth : 150,typeAttributes: {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            hour12: false
        } },
    { label: 'Status', fieldName: 'stepStatus', type: 'text', initialWidth : 120 },
    { label: 'Assigned To', fieldName: 'assignedTo', type: 'text', initialWidth : 150 },
    { label: 'Comments', fieldName: 'comments', type: 'text',initialWidth : 400, wrapText: true } 
];


export default class WaiverApprovalHistory extends LightningElement {

    @api recordId;
    columns = COLUMNS;
    isLoading = true;
    waiverAppovalHistories;

    connectedCallback() {
        console.log("connected waiver recordid ",this.recordId);
        //this.recordId = 'a2CQI000004uve12AA';
    }

    renderedCallback() {
        console.log("rendered waiver recordid ",this.recordId);
    }

    @wire(getWaiverApprovalHistory,{ recordId:'$recordId' })
    WaiverApprovalHistoryData({ error, data }) {
        if (data) {
            console.log("Wire Waiver Histories ",data);

            

            

            const tmpData = [];
            for(let i = 0; i < data.length; i++){
                //let stepDate = '';
                
                /*if(data[i].StepStatus == 'Started' || data[i].StepStatus == 'NoResponse'){
                    stepDate = data[i].ProcessInstance.CreatedDate
                }
                else {
                    
                }*/
                
                tmpData.push({
                    stepDate : data[i].dtTime,
                    stepStatus : data[i].status,
                    assignedTo : data[i].currentApprover,
                    comments:data[i].comments
                })
            }

            this.waiverAppovalHistories = tmpData;
        } else if (error) {
            console.error(error);
        }
        console.log("data ",data);
        console.log("error ",error);
        this.isLoading = false;
    }
}