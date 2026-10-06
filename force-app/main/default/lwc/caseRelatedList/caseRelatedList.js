import { LightningElement,api,wire } from 'lwc';
import getCaseRecords from '@salesforce/apex/CaseRelatedListController.getCaseRecords';


const CREDIT_CARD_COLUMNS = [
    { label: 'Case Number', fieldName: 'caseRecordLink', type: 'url',initialWidth: 140, 
        typeAttributes: {
            label: { fieldName: 'caseNumber' },
            target: '_blank'
        } 
    },
    { label: 'Application Open Date', fieldName: 'createdDate',initialWidth: 180 },
    { label: 'Approved Card Type', fieldName: 'approvedRequestedCardType',initialWidth: 180 },
    { label: 'Card Type', fieldName: 'cardType',initialWidth: 180 },
    { label: 'Status', fieldName: 'status',initialWidth: 120 },
    { label: 'Sub Status', fieldName: 'sub_Status__c',initialWidth: 120 },
    { label: 'Application Closed Date', fieldName: 'closedDate',initialWidth: 150 }
];

const LOAN_COLUMNS = [
    { label: 'Loan / Finance Application Number', fieldName: 'caseRecordLink', type: 'url',initialWidth: 140, 
        typeAttributes: {
            label: { fieldName: 'caseNumber' },
            target: '_blank'
        } 
    },
    { label: 'Loan / Finance Type', fieldName: 'loan_Finance_Type__c',initialWidth: 180 },
    { label: 'Application Open Date', fieldName: 'createdDate',initialWidth: 180 },
    { label: 'Product', fieldName: 'product__c',initialWidth: 100 },
    { label: 'Business Nature / Type', fieldName: 'business_Nature_Type__c',initialWidth: 150 },
    { label: 'Customer Unit', fieldName: 'case_Model__c',initialWidth: 120 },
    { label: 'Customer CIF', fieldName: 'customer_CIF__c',initialWidth: 120 },
    { label: 'Customer Name',fieldName:'contact_Name__c',initialWidth: 120 },
    { label: 'Status', fieldName: 'status',initialWidth: 120 },
    { label: 'Sub Status', fieldName: 'sub_Status__c',initialWidth: 120 },
    { label: 'Application Closed Date', fieldName: 'closedDate',initialWidth: 150 }
];

export default class CaseRelatedList extends LightningElement {

    @api recordId;

    @api relatedListTitle;
    @api caseRecordType;
    @api caseFields;
    @api caseFieldLabels;

    dataColumn;
    tableData;
    numberOfcases = "";
    showSpinner = true;

    connectedCallback() {
        //code
        console.log("caseRecordType ",this.caseRecordType);

        if(this.caseRecordType == "Loan_Application"){
            this.dataColumn = LOAN_COLUMNS;
        }
        else {
            this.dataColumn = CREDIT_CARD_COLUMNS;
        }
    }

    @wire(getCaseRecords,{recordId: '$recordId',caseRecordType:'$caseRecordType'})
        caseRecords({data,error}){
            this.showSpinner = false;
            console.log("wire response ",data);
            if(data != undefined && data.responseData){    
                this.numberOfcases = "(" + data.responseData.length + ")";
                if(this.caseRecordType == "Loan_Application"){
                    this.processLoanCases(data.responseData);
                }
                else if(this.caseRecordType == "Credit_Card"){
                    this.processCreditCardCases(data.responseData);
                }
            }

            if(error){
                console.error("Error while fetching records",error);
            }
    }

    processLoanCases(caseList){
        this.tableData = [];
        for(let i = 0; i < caseList.length; i++){
            const caseObj = caseList[i];
            var lonaFinanaceType = "";
            var product = "";
            var businessNatureType = "";

            if(caseObj.CaseAnnex__r != undefined && caseObj.CaseAnnex__r.cx_ln_Loan_Finance_Type__c){
                lonaFinanaceType = caseObj.CaseAnnex__r.cx_ln_Loan_Finance_Type__c;
            }

            if(caseObj.CaseAnnex__r != undefined && caseObj.CaseAnnex__r.cx_ln_Business_Nature_Type__c){
                businessNatureType = caseObj.CaseAnnex__r.cx_ln_Business_Nature_Type__c;
            }

            if(caseObj.CaseAnnex__r != undefined && caseObj.CaseAnnex__r.cx_ln_Product__c){
                product = caseObj.CaseAnnex__r.cx_ln_Product__c;
            }

            const dt = caseObj.CreatedDate;

            this.tableData.push({
                id:caseObj.Id,
                caseRecordLink: '/' + caseObj.Id,
                caseNumber : caseObj.CaseNumber,
                loan_Finance_Type__c : lonaFinanaceType,
                product__c : product,
                business_Nature_Type__c : businessNatureType,
                case_Model__c : caseObj.Case_Model__c,
                customer_CIF__c : caseObj.Customer_CIF__c,
                contact_Name__c : caseObj.Contact_Name__c,
                status : caseObj.Status,
                sub_Status__c : caseObj.Sub_Status__c,
                createdDate : this.getFormattedDate(caseObj.CreatedDate),
                closedDate : caseObj.ClosedDate == undefined ? "" : this.getFormattedDate(caseObj.ClosedDate)
            });
        }
    }

    processCreditCardCases(caseList){
        this.tableData = [];
        for(let i = 0; i < caseList.length; i++){
            const caseObj = caseList[i];
            this.tableData.push({
                id:caseObj.Id,
                caseRecordLink: '/' + caseObj.Id,
                caseNumber : caseObj.CaseNumber,
                approvedRequestedCardType : caseObj.cc_Approved_Requested_Card_Type__c,
                cardType:caseObj.cc_Requested_Card_Type__c,
                cardNumber:caseObj.cc_Credit_Card_PCI_Number__c,
                primaryMaskedCardNumber:caseObj.PrimaryMaskedCardNumber__c,
                status : caseObj.Status,
                sub_Status__c : caseObj.Sub_Status__c,
                createdDate : this.getFormattedDate(caseObj.CreatedDate),
                closedDate : caseObj.ClosedDate == undefined ? "" : this.getFormattedDate(caseObj.ClosedDate)
            });
        }
    }

    getFormattedDate(strDate){

        if(!strDate) return "";

        const dtArray = strDate.split("T");
        var strTime = "";
        const ddMMyyyy = dtArray[0].split("-");
        if(dtArray.length > 1){
            strTime = dtArray[1];
            strTime = strTime.replace(".000Z","");
            strTime = " " + strTime;
        }
        
        return ddMMyyyy[2] + "/" + ddMMyyyy[1] + "/" + ddMMyyyy[0] +  strTime;
    }
}