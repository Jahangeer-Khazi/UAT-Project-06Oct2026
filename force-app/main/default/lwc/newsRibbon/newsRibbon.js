import { LightningElement,wire,api } from 'lwc';
import getActiveNewsRibbon from '@salesforce/apex/NewsRibbonController.getActiveNewsRibbon';

export default class NewsRibbon extends LightningElement {

    @api recordId;
    newsRibbonRecord;
    isNewsRibbonMsg = false; //This variable would use to show the new ribbon msg if found else nothing would appears.


    @wire(getActiveNewsRibbon,{recordId: '$recordId'})
        newsRibbon({data,error}){

            console.log("wire response ",data);
            if(data != undefined && data.responseData){    
                this.newsRibbonRecord = data.responseData[0];
                this.isNewsRibbonMsg = true;
            }
    }
}