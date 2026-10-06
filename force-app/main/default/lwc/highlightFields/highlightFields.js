import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import No_of_Arrears_Current_and_Historical_FIELD from "@salesforce/schema/Case.No_of_Arrears_Current_and_Historical__c";
import cc_Total_Obligations_FIELD from "@salesforce/schema/Case.cc_Total_Obligations__c";
import cc_Control_Type_FIELD from "@salesforce/schema/Case.cc_Control_Type__c";
import asc_Current_Segment_FIELD from "@salesforce/schema/Case.asc_Current_Segment__c";

export default class HighlightFields extends LightningElement {
    @api recordId;
    @track caseRecord;

    @wire(getRecord, { recordId: '$recordId', fields: [No_of_Arrears_Current_and_Historical_FIELD, cc_Total_Obligations_FIELD, cc_Control_Type_FIELD, asc_Current_Segment_FIELD] })
    wiredCase({ error, data }) {
        if (data) {
            console.log('---->',JSON.stringify(data));
            this.caseRecord = {
                No_of_Arrears_Current_and_Historical__c: data.fields.No_of_Arrears_Current_and_Historical__c.value,
                cc_Total_Obligations__c: data.fields.cc_Total_Obligations__c.value,
                cc_Control_Type__c: data.fields.cc_Control_Type__c.value,
                asc_Current_Segment__c: data.fields.asc_Current_Segment__c.value
            };
        } else if (error) {
            console.error('Error fetching case record', error);
        }
    }

    get noOfArrearsClass() {
        return this.caseRecord && this.caseRecord.No_of_Arrears_Current_and_Historical__c > 0 
            ? 'slds-text-color_error inline-label' 
            : 'slds-text-color_default inline-label';
    }

    get noOfArrears() {
        return this.caseRecord && this.caseRecord.No_of_Arrears_Current_and_Historical__c > 0 
            ? 'slds-text-color_error value-alignment' 
            : 'slds-text-color_default value-alignment';
    }

    get totalObligationsClass() {
        return this.caseRecord && this.caseRecord.cc_Total_Obligations__c > 0 
            ? 'slds-text-color_error inline-label' 
            : 'slds-text-color_default inline-label';
    }

    get totalObligations() {
        return this.caseRecord && this.caseRecord.cc_Total_Obligations__c > 0 
            ? 'slds-text-color_error value-alignment' 
            : 'slds-text-color_default value-alignment';
    }

    get currentSegmentClass() {
        return this.caseRecord && this.caseRecord.asc_Current_Segment__c !== 'Normal' 
            ? 'slds-text-color_error inline-label' 
            : 'slds-text-color_default inline-label';
    }

    get currentSegment() {
        return this.caseRecord && this.caseRecord.asc_Current_Segment__c !== 'Normal' 
            ? 'slds-text-color_error value-alignment' 
            : 'slds-text-color_default value-alignment';
    }
}