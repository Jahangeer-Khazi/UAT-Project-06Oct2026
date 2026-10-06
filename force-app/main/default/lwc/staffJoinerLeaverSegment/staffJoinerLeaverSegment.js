import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import loadSegmentOptionsCRM from '@salesforce/apex/SegmentAPIHandler.loadSegmentOptionsCRM';
import updateSegment from '@salesforce/apex/SegmentAPIHandler.updateSegment';
import updateAccountDetails from '@salesforce/apex/SegmentAPIHandler.updateAccountDetails';
import sendToSegmentChangeMaker from '@salesforce/apex/SegmentAPIHandler.sendToSegmentChangeMaker';

const CASE_FIELDS = [
    'Case.isSubmitted__c', 
    'Case.AccountId',
    'Case.Customer_CIF__c',
    'Case.cc_Staff_Number__c',
    'Case.Updated_Email__c',
    'Case.cc_Maker__c',
    'Case.cc_Request_Type__c',
    'Case.From_Date__c'
];
const ACCOUNT_FIELDS = ['Account.Staff_ID__pc', 'Account.Staff_Corporate_Email__pc', 'Account.Subscription_Model__pc', 'Account.Region_Flag__c'];

export default class SegmentComponent extends LightningElement {
    @api recordId; // This should be the caseId
    @api isAlburaqProduct = false;

    @track segmentCardOpts = [];
    @track segmentCurCards = [];
    @track segmentCurrent = {};
    @track segmentDisOpts = [];
    @track segmentOpts = [];
    @track segmenttransitionInProgress = false;
    @track showChangeSegment = false;
    @track curSegSelected = '';
    @track disSegSelected = '';
    @track segOptSelected = '';
    @track segmentEmbossName = '';
    @track isSubmited = false;
    @track staffId = '';
    @track staffCorporateEmail = '';
    @track exitDate = '';
    @track membershipDiscount;
    @track isLoading = false; // Added for spinner control

    customerId;
    accountId;
    caseRecord;
    accountRecord;
    hasCaseData = false;
    hasAccountData = false;
    wiredCaseResult;
    wiredAccountResult;

    // Get the cc_Maker__c field value to determine if we should show the submit button
    get ccMakerValue() {
        return getFieldValue(this.caseRecord, 'Case.cc_Maker__c');
    }

    get ccRequestType() {
        return getFieldValue(this.caseRecord, 'Case.cc_Request_Type__c');
    }

    get isDisabled() {
        return this.ccMakerValue === 'Send to Checker';
    }

    // Determine if we should show the submit button
    get showSubmitButton() {
        return !this.isSubmited;
    }

    @wire(getRecord, { recordId: '$recordId', fields: CASE_FIELDS })
    wiredCase(result) {
        this.wiredCaseResult = result;
        if (result.data) {
            this.caseRecord = result.data;
            this.isSubmited = this.caseRecord.fields.isSubmitted__c.value;
            this.customerId = this.caseRecord.fields.Customer_CIF__c.value;
            this.accountId = this.caseRecord.fields.AccountId.value;
            this.staffId = this.caseRecord?.fields?.cc_Staff_Number__c?.value || '';
            this.staffCorporateEmail = this.caseRecord?.fields?.Updated_Email__c?.value || '';
            this.exitDate = this.caseRecord?.fields?.From_Date__c?.value || '';
            this.hasCaseData = true;
            console.log('customerId -->', this.customerId);

            // Check if we can load segment options now
            this.checkAndLoadSegmentOptions();
        } else if (result.error) {
            console.error('Error loading case:', result.error);
            this.showToast('Error', 'Failed to load case data', 'error');
        }
    }

    @wire(getRecord, { recordId: '$accountId', fields: ACCOUNT_FIELDS })
    wiredAccount(result) {
        this.wiredAccountResult = result;
        if (result.data) {
            this.accountRecord = result.data;
            this.hasAccountData = true;
            console.log('Account data loaded:', this.accountRecord);

            // Check if we can load segment options now
            this.checkAndLoadSegmentOptions();
        } else if (result.error) {
            console.error('Error loading account:', result.error);
            this.showToast('Error', 'Failed to load account data', 'error');
        }
    }

    checkAndLoadSegmentOptions() {
        // Only load segment options when both case and account data are available
        if (this.hasCaseData && this.hasAccountData && this.customerId && this.recordId && this.regionFlag) {
            console.log('All data available, loading segment options');
            this.getSegmentOptionsCRM();
        }
    }

    get subscriptionModel() {
        return this.accountRecord?.fields?.Subscription_Model__pc?.value || '';
    }

    get regionFlag() {
        return this.accountRecord?.fields?.Region_Flag__c?.value || '';
    }

    get isPremiumSelected() {
        return this.segOptSelected === 'Premium' && this.subscriptionModel === 'alburaq';
    }

    get showStaffFields() {
        return this.showChangeSegment && this.segOptSelected === 'Staff';
    }

    get isPremiumSegment() {
        return this.segOptSelected === 'Premium' || this.segOptSelected === 'Regular';
    }

    get showExitField() {
        return this.ccRequestType === 'Staff Leaver';
    }

    get hideExitField() {
        return this.ccRequestType !== 'Staff Leaver';
    }

    getSegmentOptionsCRM() {
        this.isLoading = true; // Show spinner
        
        let regionName = this.regionFlag;
        if (this.isAlburaqProduct) {
            regionName += '_alburaq';
        }

        console.log('Loading segment options with:', {
            customerId: this.customerId,
            caseId: this.recordId,
            regionName: regionName
        });

        loadSegmentOptionsCRM({
            customerId: this.customerId,
            caseId: this.recordId,
            regionName: regionName
        })
            .then(result => {
                if (result.isSuccess && result.responseData) {
                    const segmentOpts = result.responseData.segmentOptions?.map(segOpt => ({
                        label: segOpt.segmentName,
                        value: segOpt.segmentCrmId
                    })) || [];

                    const cardOpts = result.responseData.cardOptions?.map(cardOpt => ({
                        label: cardOpt.cardDisplayName,
                        value: cardOpt.cardAfsId
                    })) || [];

                    const disOpts = result.responseData.discountOptions?.map(disOpt => ({
                        label: disOpt.displayName,
                        value: disOpt.name
                    })) || [];

                    this.segmentCardOpts = cardOpts;
                    this.segmentCurCards = result.responseData.currentCards || [];
                    this.segmentCurrent = result.responseData.currentSegment || {};
                    this.segmentDisOpts = disOpts;
                    this.segmentOpts = segmentOpts;
                    this.segmenttransitionInProgress = result.responseData.transitionInProgress || false;

                    console.log('Segment options loaded successfully');
                } else {
                    console.error('Failed to load segment options:', result);
                    this.showToast('Error', 'Failed to load segment options', 'error');
                }
            })
            .catch(error => {
                console.error('Error loading segment options:', error);
                this.showToast('Error', 'Failed to load segment options', 'error');
            })
            .finally(() => {
                this.isLoading = false; // Hide spinner
            });
    }

    handleSegmentChange(event) {
        this.segOptSelected = event.detail.value;
        console.log('this.segOptSelected --->',this.segOptSelected);
        this.showChangeSegment = this.segOptSelected === 'Staff';
    }

    handleStaffIdChange(event) {
        this.staffId = event.target.value;
    }

    handleStaffEmailChange(event) {
        this.staffCorporateEmail = event.target.value;
    }

    handleExitDateChange(event) {
        this.exitDate = event.target.value;
    }

    handleMembershipDiscountChange(event) {
        this.membershipDiscount = event.target.value;
    }

    async handleSubmit() {
        console.log('--- handleSubmit START ---');
        console.log('Initial Values:', {
            subscriptionModel: this.subscriptionModel,
            isAlburaqProduct: this.isAlburaqProduct,
            showChangeSegment: this.showChangeSegment,
            segOptSelected: this.segOptSelected,
            staffId: this.staffId,
            exitDate: this.exitDate,
            staffCorporateEmail: this.staffCorporateEmail
        });

        this.isLoading = true; // Show spinner

        try {
            // Check for Alburaq model
            if (this.subscriptionModel === 'alburaq' && this.isAlburaqProduct) {
                console.log('Condition matched: subscriptionModel === alburaq AND isAlburaqProduct === true');
                console.log('Calling sendToSegmentChangeMaker()...');
                await this.sendToSegmentChangeMaker();
                console.log('Completed sendToSegmentChangeMaker()');
            } else {
                console.log('Condition NOT alburaq or isAlburaqProduct is false');
                let canProceed = true;
                console.log('canProceed initialized ->', canProceed);
                
                // Segment check
                if (this.showChangeSegment && this.segOptSelected === 'Staff') {
                    console.log('Condition matched: showChangeSegment === true AND segOptSelected === Staff');

                    // Staff ID & Email check
                    if ((!this.staffId || !this.staffCorporateEmail) && this.ccRequestType == 'Staff Joiner') {
                        console.log('Validation FAILED: Missing staffId or staffCorporateEmail');
                        this.showToast('Error', 'Please complete the mandatory fields', 'error');
                        canProceed = false;
                        console.log('canProceed updated ->', canProceed);
                    } else {
                        console.log('Validation PASSED: staffId and staffCorporateEmail are present');
                        console.log('Calling updateAccDetails()...');
                        await this.updateAccDetails();
                        console.log('Completed updateAccDetails()');
                    }
                } else {
                    console.log('Condition NOT met: showChangeSegment or segOptSelected');
                    await this.updateAccDetails();
                }
            }
            
            // Refresh the UI with updated data
            await refreshApex(this.wiredCaseResult);
            await refreshApex(this.wiredAccountResult);
            await this.getSegmentOptionsCRM(); // Reload segment options to reflect changes
            
        } catch (error) {
            console.error('Error in handleSubmit:', error);
            this.disableEditOptions = false;
            this.showToast('Error', 'An error occurred during submission', 'error');
        } finally {
            this.isLoading = false; // Hide spinner
            console.log('--- handleSubmit END ---');
        }
    }

    async updateSegment(regionName) {
        this.isLoading = true; // Show spinner
        
        try {
            const result = await updateSegment({
                customerId: this.customerId,
                newSegmentCRMId: this.segOptSelected,
                caseId: this.recordId,
                regionName: regionName
            });

            if (result.isSuccess) {
                this.showToast('Success', 'Segment updated successfully', 'success');
            } else {
                this.showToast('Error', 'Failed to update segment', 'error');
            }
        } catch (error) {
            console.error('Error updating segment:', error);
            this.showToast('Error', 'Failed to update segment', 'error');
        } finally {
            this.isLoading = false; // Hide spinner
        }
    }

    async updateAccDetails() {
        this.isLoading = true; // Show spinner
        
        try {
            const result = await updateAccountDetails({
                accountId: this.accountId,
                staffId: this.staffId,
                exitDate: this.exitDate,
                staffCorporateEmail: this.staffCorporateEmail,
                caseId: this.recordId,
                currentSegment: this.segOptSelected
            });

            if (result.isSuccess) {
                console.log('Case updated successfully and assigned to Segment Checker Queue.');
                this.showToast('Success', 'Case updated successfully and assigned to Segment Checker Queue.', 'success');
            } else {
                console.error('Failed to update account details:', result.message);
                this.showToast('Error', result.message, 'error');
            }
        } catch (error) {
            console.error('Error updating account:', error);
            this.showToast('Error', 'Failed to update account details', 'error');
        } finally {
            this.isLoading = false; // Hide spinner
        }
    }

    async sendToSegmentChangeMaker() {
        this.isLoading = true; // Show spinner
        
        try {
            const discountName = this.isPremiumSelected ? this.membershipDiscount : null;

            await sendToSegmentChangeMaker({
                caseId: this.recordId,
                currentSegment: this.segmentCurrent.segmentName,
                newSegment: this.segOptSelected,
                discountName: discountName
            });

            this.showToast('Success', 'Sent to Segment Change Maker', 'success');
        } catch (error) {
            console.error('Error sending to segment change maker:', error);
            this.showToast('Error', 'Failed to send to Segment Change Maker', 'error');
        } finally {
            this.isLoading = false; // Hide spinner
        }
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: variant === 'error' ? 'sticky' : 'dismissible'
        });
        this.dispatchEvent(toastEvent);
    }
}