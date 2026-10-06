import { LightningElement } from 'lwc';
import { subscribe, unsubscribe } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class WpsPayrollErrorToast extends LightningElement {
    subscription = {};
    channelName = '/event/WPS_Payroll_Error__e';
    
    connectedCallback() {
        this.subscribeToErrors();
    }
    
    disconnectedCallback() {
        this.unsubscribeFromErrors();
    }
    
    // Subscribe to Platform Event for errors
    subscribeToErrors() {
        const messageCallback = (response) => {
            console.log('Received error event:', response);
            this.handleErrorEvent(response.data.payload);
        };
        
        subscribe(this.channelName, -1, messageCallback)
            .then(response => {
                console.log('Successfully subscribed to error events');
                this.subscription = response;
            })
            .catch(error => {
                console.error('Error subscribing to error events:', error);
                // Show error about subscription failure
                this.showToast('Error', 'Failed to subscribe to error notifications', 'error');
            });
    }
    
    // Unsubscribe from Platform Event
    unsubscribeFromErrors() {
        if (this.subscription) {
            unsubscribe(this.subscription, response => {
                console.log('Unsubscribed from error events');
            }).catch(error => {
                console.error('Error unsubscribing:', error);
            });
        }
    }
    
    // Handle incoming error event
    handleErrorEvent(eventData) {
        const errorMessage = eventData.ErrorMessage__c || 'An unknown error occurred during payroll approval';
        
        // Show standard Lightning toast
        this.showToast('Payroll Approval Failed', errorMessage, 'error');
    }
    
    // Method to show standard toast
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'sticky' // Stays until user closes it
        });
        this.dispatchEvent(event);
    }
}