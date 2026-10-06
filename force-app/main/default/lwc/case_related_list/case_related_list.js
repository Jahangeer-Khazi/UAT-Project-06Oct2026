import { LightningElement,api } from 'lwc';
export default class Case_related_list extends LightningElement {

    @api relatedListTitle;
    @api caseRecordType;
    @api caseFields;
}