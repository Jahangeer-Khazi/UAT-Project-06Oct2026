import { LightningElement,api,wire,track } from 'lwc';
import setOwnerAsQueue from '@salesforce/apex/LeadTriggerHandler.setOwnerAsQueue';

export default class AssignToQueueLWC extends LightningElement {
      @api recordidd;
      connectedCallback() {
        var recordid;
        recordid = this.recordidd;
        setOwnerAsQueue({ recordid })
        .then(projectName => {
            eval("$A.get('e.force:refreshView').fire();");
        })
        .catch(error => {
            console.log('Unexpected error occured');
        });
    }
}