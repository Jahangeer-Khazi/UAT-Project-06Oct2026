// investmentQuestionnairePDFViewer.js
import { LightningElement, api } from 'lwc';

export default class InvestmentQuestionnairePDFViewer extends LightningElement {
    @api recordId;
    
    // This method is automatically called by the quick action
    @api 
    invoke() {
        console.log('invoke called with recordId:', this.recordId);
        // No action needed - component will display automatically
    }
    
    get pdfUrl() {
        return `/apex/InvestmentQuestionnairePDF?id=${this.recordId}`;
    }
}