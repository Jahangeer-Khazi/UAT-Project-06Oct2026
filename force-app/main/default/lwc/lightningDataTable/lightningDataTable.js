import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getRelatedList from '@salesforce/apex/CustomRelatedListController.getRelatedList';
import { IsConsoleNavigation, setTabLabel, getFocusedTabInfo, setTabIcon } from 'lightning/platformWorkspaceApi';
import updateContent from '@salesforce/apex/CustomRelatedListController.updateContentRecord';
export default class LightningDataTable extends LightningElement {
    columns = [
        {
            label: 'Content Ref',
            fieldName: 'ContentName',
            type: 'url',
            hideDefaultActions: true,
            typeAttributes: { label: { fieldName: 'Name' } }
        },
        { label: 'Case Number', fieldName: 'caseNumber', hideDefaultActions: true },
        { label: 'Document Model', fieldName: 'Document_Model__c', hideDefaultActions: true },
        { label: 'Document Type', fieldName: 'Document_Type__c', hideDefaultActions: true },
        { label: 'Document Number', fieldName: 'Document_Number__c', hideDefaultActions: true },
        { label: 'Scan Type', fieldName: 'Scan_Type__c', hideDefaultActions: true },
        { label: 'Attachment Name', fieldName: 'Attachment_Name__c', hideDefaultActions: true },
        { label: 'Attachment Type', fieldName: 'Attachment_Type__c', hideDefaultActions: true },
        {
            label: 'Created Date',
            fieldName: 'CreatedDate',
            type: 'date',
            typeAttributes: { day: 'numeric', month: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' },
            hideDefaultActions: true
        }
    ];

    recordList = [];
    recordId;
    caseId;
    showTable = false;

    @wire(IsConsoleNavigation)
    isConsoleNavigation;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state?.c__recordId;
            this.caseId = currentPageReference.state?.c__caseId;
            this.doSearch();
        }
    }

    handleClick(event) {
        const data = event.currentTarget.data;
        console.log(JSON.stringify(data));
    }

    doSearch() {
        getRelatedList({ accountId: this.recordId })
            .then(result => {
                console.log(JSON.stringify(result));
                this.recordList = result.map(record => ({
                    ...record,
                    ContentName: '/' + record.Id,
                    caseNumber: record.Case__r?.CaseNumber
                }));
                this.showTable = true;
            })
            .catch(error => {
                console.error('Error fetching related list:', error);
            });
    }

    async connectedCallback() {
        if (this.isConsoleNavigation) {
            try {
                const tabInfo = await getFocusedTabInfo();
                console.log(JSON.stringify(tabInfo));
                if (tabInfo.title === 'Loading...' && tabInfo.icon === 'standard:generic_loading' && tabInfo.isSubtab) {
                    setTabIcon(tabInfo.tabId, 'custom:custom18', { iconAlt: 'Content' });
                    setTabLabel(tabInfo.tabId, 'Content');
                }
				console.log('recordList'+JSON.stringify(this.recordList));
                this.recordList.forEach(record=>{
					console.log('LDTrecord.Id'+JSON.stringify(record.Id));
					console.log('LDTthis.caseId'+JSON.stringify(this.caseId));
                    this.updateContentRecord(record.Id, this.caseId);
                })
            } catch (error) {
                console.error('Error setting tab info:', error);
            }
        }
    }

    updateContentRecord(conId, casId) {
		console.log('conId'+JSON.stringify(conId));
		console.log('casId'+JSON.stringify(casId));
        updateContent({ contentId : conId, caseId : casId })
            .then(result => {
				console.log('result'+JSON.stringify(result));
                console.error(result);
            })
            .catch(error => {
                console.error('Error fetching related list:', error);
            });
    }
}