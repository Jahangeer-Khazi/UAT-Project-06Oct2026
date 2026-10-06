import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import RECENT_UPDATE_FIELD from '@salesforce/schema/Case.Recent_Updates__c';
import CASE_ID_FIELD from '@salesforce/schema/Case.Id';
import USER_PROFILE from '@salesforce/schema/User.Profile.Name';
import { getRecord as getUserRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';

export default class CaseCommentsRead extends LightningElement {
    @api recordId;
    recentUpdates = true;
    userId = Id;
    userProfile;

    // Fetch Case record details including Recent_Updates__c field
    @wire(getRecord, { recordId: '$recordId', fields: [RECENT_UPDATE_FIELD] })
    wiredCaseRecord({ data, error }) {
        if (data) {
            this.recentUpdates = getFieldValue(data, RECENT_UPDATE_FIELD);
        } else if (error) {
            console.error(error);
        }
    }

    // Fetch the current user's profile
    @wire(getUserRecord, { recordId: '$userId', fields: [USER_PROFILE] })
    wiredUser({ data, error }) {
        if (data) {
            this.userProfile = getFieldValue(data, USER_PROFILE);

            // Check if the user has the 'RMT' profile and Recent_Updates__c is false
            if ((this.userProfile === 'Contact Centre' || this.userProfile === 'Restricted System Admin' || this.userProfile === 'RMT' || this.userProfile === 'System Administrator') && this.recentUpdates) {
                console.log('Reached');
                this.updateCommentsRead();
            }
        } else if (error) {
            console.error(error);
        }
    }

    // Update the Recent_Updates__c field to false if it's true
    updateCommentsRead() {
        const fields = {};
        fields[CASE_ID_FIELD.fieldApiName] = this.recordId;
        fields[RECENT_UPDATE_FIELD.fieldApiName] = false;

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                console.log('Recent_Updates__c updated to true');
            })
            .catch(error => {
                console.error('Error updating Recent_Updates__c:', error);
            });
    }
}