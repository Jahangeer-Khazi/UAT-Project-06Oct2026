import { LightningElement, api , track} from 'lwc';
import sendEnvelope from '@salesforce/apex/EmbeddedSigningController.sendEnvelope';
import getEmbeddedSigningUrl from '@salesforce/apex/EmbeddedSigningController.getEmbeddedSigningUrl';
 
export default class LWC04_TestDocuSignEmbeddedSigning extends LightningElement {
 

   channel = 'In-App';
   @api recordId;   

    @track loadingSpinner = false;
    @track envelopeId;
    @track processingTime;
    startTime;

   handleClick() {
        this.loadingSpinner = true;
        this.envelopeId = null;
        this.processingTime = null;
        this.startTime = performance.now(); // Record start time

       sendEnvelope({recordId: this.recordId, channel: this.channel})
           .then((envelopeId) => {
                this.envelopeId = envelopeId;
                return getEmbeddedSigningUrl({
                    envId: envelopeId,
                    url: window.location.href
                });
            })
            .then((signingUrl) => {
                // Calculate total time taken
                const endTime = performance.now();
                this.processingTime = ((endTime - this.startTime) / 1000).toFixed(2);
                
                this.loadingSpinner = false;
                window.open(signingUrl, '_blank').focus();
            })
            .catch((error) => {
                this.loadingSpinner = false;
                console.log('Error:');
                console.log(error);
            });
   }
}