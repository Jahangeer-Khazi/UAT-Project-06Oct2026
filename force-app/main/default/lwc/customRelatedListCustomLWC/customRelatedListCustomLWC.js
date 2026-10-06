import { LightningElement, wire, api } from 'lwc';
import { IsConsoleNavigation, openSubtab, EnclosingTabId, getFocusedTabInfo } from 'lightning/platformWorkspaceApi';
import getRelatedList from '@salesforce/apex/CustomRelatedListController.getRelatedList';
import { NavigationMixin } from 'lightning/navigation';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import ACCOUNT_ID from '@salesforce/schema/Case.AccountId';
import ID_FIELD from "@salesforce/schema/Case.Id";
import updateContent from '@salesforce/apex/CustomRelatedListController.updateContentRecord';
export default class CustomRelatedListCustomLWC extends NavigationMixin(LightningElement) {
    @api recordId;

    data;
    visibleData;
    caseNumber;
    title;
    showMessage = false;
    message;
    accId;
    
    @wire(IsConsoleNavigation) 
    isConsoleNavigation;

    @wire(EnclosingTabId) 
    parentTabId;

    tabNewId;

    @wire(getRecord, { recordId: "$recordId", fields:[ID_FIELD, ACCOUNT_ID] } )
    caseRecord({ error, data }) {
        if (data) {
            this.accId = getFieldValue(data, ACCOUNT_ID);
            this.doSearch();
        } else if (error) {
            console.error('Error fetching related list:', error);
        }
    } 

    doSearch() {
        getRelatedList({ accountId: this.accId, caseId: this.recordId })
            .then(result => {
                this.processRelatedListData(result);
            })
            .catch(error => {
                console.error('Error fetching related list:', error);
            });
    }

    updateContentRecord(conId, casId) {
        updateContent({ contentId : conId, caseId : casId })
            .then(result => {
                console.error(result);
            })
            .catch(error => {
                console.error('Error fetching related list:', error);
            });
    }

    processRelatedListData(data) {
        if (data == undefined || data.length == 0) {
            this.showMessage = true;
            this.message = 'No Previous Approved Credit Card Cases';
            this.title = `Previous Credit Card Docs (0)`;
            return;
        }

        this.showMessage = false;
        this.data = data;
        this.visibleData = this.data.slice(0, 3);
        this.caseNumber = this.visibleData[0]?.Case__r.CaseNumber;

        this.title = `Previous Credit Card Docs (${this.data.length > 3 ? '3+' : this.data.length})`;
    }

     async connectedCallback() {
        if (this.isConsoleNavigation) {
            try {
                const tabInfo = await getFocusedTabInfo();
                console.log('tab '+JSON.stringify(tabInfo));
                this.tabNewId = tabInfo.isSubtab ? tabInfo.parentTabId : tabInfo.tabId;
            } catch (error) {
                console.error('Error setting tab info:', error);
            }
        }
    }

    openSubTab(event) {
        event.preventDefault();
        const index = event.currentTarget.dataset.index;
        const record = this.data[index];
		console.log('recordId',JSON.stringify(record));
		console.log('this.recordId',JSON.stringify(this.recordId));
        this.updateContentRecord(record.Id, this.recordId);
        if (this.isConsoleNavigation) {
            openSubtab(this.tabNewId, {
                recordId: record.Id,
                label: record.Name,
                highlighted: true,
                iconAlt:this.record,
                url:this.recordId
            }).catch(error => {
                console.error('Error opening subtab:', error);
            });
        }
    }
    
    

    navigateToCustomTab() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Content_List'
            },
            state: {
                c__recordId: this.accId,
                c__caseId: this.recordId
            }
        });
    }
}