// Change History: #CH01# #AITOGRAM OMAR# #22-04-2026# Added Cancel Fawri transfer logic (NBA-15906) 

import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from "lightning/uiRecordApi";
import CASE_OBJECT from '@salesforce/schema/Case';
import getPicklistDataByProfile from '@salesforce/apex/CaseFieldDependencyController.getPicklistDataByProfile';
import fetchCaseNatureAndRouting from '@salesforce/apex/CaseFieldDependencyController.fetchCaseNatureAndRouting';
import fetchCaseNatureAndRoutingUsingSubType from '@salesforce/apex/CaseFieldDependencyController.fetchCaseNatureAndRoutingUsingSubType';
import callResettingRecoveryCodeSMS from '@salesforce/apex/CaseFieldDependencyController.callResettingRecoveryCodeSMS';
import getAccountBondListViaApi from '@salesforce/apex/LTNG038_BOND_SUKUK_SellRequestController.getAccountBondListViaApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import Id from '@salesforce/user/Id';
import loadEPPList from '@salesforce/apex/LTNG043_CreditCardServiceReqController.loadEPPList';
import getAccountToBlockUnblockViaApi from '@salesforce/apex/LTNG013_BlockUnblockAccountController.getAccountToBlockUnblockViaApi';
import loadAccountList from '@salesforce/apex/BankAccountController.loadAccountList';
import getQueueNameToIdMap from '@salesforce/apex/CaseFieldDependencyController.getQueueNameToIdMap';
import isUserInMakerQueue from '@salesforce/apex/CaseFieldDependencyController.isUserInMakerQueue';
import loadDeviceList from '@salesforce/apex/LTNG029_InternalCaseRequestController.loadDeviceList';
import { CurrentPageReference } from 'lightning/navigation'; // NEW: for URL params
import getAccountIdByCIF from '@salesforce/apex/CaseFieldDependencyController.getAccountIdByCIF'; // NEW

import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import CASEMODEL_FIELD from '@salesforce/schema/Case.Case_Model__c';
import TYPE_FIELD from '@salesforce/schema/Case.Type';
import SUBTYPE_FIELD from '@salesforce/schema/Case.Sub_Type__c';
import REQUESTTYPE_FIELD from '@salesforce/schema/Case.cc_Request_Type__c';
import CASEORIGIN_FIELD from '@salesforce/schema/Case.Origin';
import CASENATURE_FIELD from '@salesforce/schema/Case.Case_Nature__c';

import SALES_OUTCOME_FIELD from '@salesforce/schema/Case.Sales_Out_Come__c';
import INSTRUMENT_ID_FIELD from '@salesforce/schema/Case.bs_Instrument_ID__c';

import RECORDTYPE_FIELD from '@salesforce/schema/Case.RecordTypeId';
import CUSTOMER_FIELD from '@salesforce/schema/Case.AccountId';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import SUBSTATUS_FIELD from '@salesforce/schema/Case.Sub_Status__c';
import OWNER_FIELD from '@salesforce/schema/Case.OwnerId';
import Customer_Email_Suppression_on_Creation_FIELD from '@salesforce/schema/Case.Customer_Email_Suppression_on_Creation__c';
import Customer_Email_Suppression_on_Closure_FIELD from '@salesforce/schema/Case.Customer_Email_Suppression_on_Closure__c';
import BUA_ACCOUNTS_INFORMATION_FIELD from '@salesforce/schema/Case.BUA_AccountsInformation__c';
import GENERATE_RANDOM_RECOVERY_CODE_FIELD from '@salesforce/schema/Case.Generate_Random_Recovery_Code__c';
import AC_IBAN_FIELD from '@salesforce/schema/Case.ac_Iban__c';
import CIF_FIELD from '@salesforce/schema/Account.Customer_CIF__c';
import REGION_FLAG_FIELD from '@salesforce/schema/Account.Region_Flag__c';
import CURRENCY_FIELD from '@salesforce/schema/Case.Currency__c';
import CREDIT_LIMIT_FIELD from '@salesforce/schema/Case.cc_Current_Credit_Limit__c';
import OVERDRAWN_ACCOUNT_FIELD from '@salesforce/schema/CaseAnnex__c.Overdrawn_Account_OD__c';
import MASKED_CARD_NUMBER_FIELD from '@salesforce/schema/Case.cc_Credit_Card_PCI_Number__c';
import PERIOD_FROM_FIELD from '@salesforce/schema/CaseAnnex__c.Period_From__c';
import PERIOD_TO_FIELD from '@salesforce/schema/CaseAnnex__c.Period_To__c';
import INVESTMENT_ID_FIELD from '@salesforce/schema/Case.bs_Investment_ID__c';
import ISIN_TYPE_FIELD from '@salesforce/schema/Case.bs_ISIN_Type__c';
import ISIN_CODE_FIELD from '@salesforce/schema/Case.bs_ISIN_Code__c';
import MATURITY_DATE_FIELD from '@salesforce/schema/Case.bs_Maturity_Date__c';
import TOTAL_BID_AMOUNT_FIELD from '@salesforce/schema/Case.bs_Total_Bid_Amount__c';
import CASEANNEX_OBJECT from '@salesforce/schema/CaseAnnex__c';
import CASE_FIELD from '@salesforce/schema/CaseAnnex__c.Case__c';
import PRIMARY_MASKED_CARD_NUMBER_FIELD from '@salesforce/schema/Case.PrimaryMaskedCardNumber__c';
import ACCOUNT_ALIAS_FIELD from '@salesforce/schema/Case.Alias_account__c';

import BENEFICIARY_NAME_FIELD from '@salesforce/schema/CaseAnnex__c.Beneficiary_Name__c';
import AMOUNT_FIELD from '@salesforce/schema/CaseAnnex__c.Amount__c';
import SEID_FIELD from '@salesforce/schema/Case.SEID__c';
import HOLD_ID_FIELD from '@salesforce/schema/Case.Hold_ID__c';
import CASE_ANNEX_RECTYPE_ID_FIELD from '@salesforce/schema/CaseAnnex__c.RecordTypeId';
import TENOR_FIELD from '@salesforce/schema/CaseAnnex__c.Tenor__c';

// CH01 start 
import TRANSACTION_AMOUNT_FIELD from '@salesforce/schema/Case.Transaction_Amount__c';
import TRANSACTION_DATE_FIELD from '@salesforce/schema/Case.Transaction_Date__c';
import TRANSACTION_CURRENCY_FIELD from '@salesforce/schema/Case.Transaction_Currency__c';
import TRANSACTION_REF_NO_FIELD from '@salesforce/schema/Case.cc_Transaction_Reference_Number__c';
import BATCHID_FIELD from '@salesforce/schema/Case.New_Mobile_Number__c';
import CCOL_HOLD_ACCOUNT_IBAN_FIELD from '@salesforce/schema/Case.ccol_Hold_Account_IBAN__c';
import getFawriTransferList from '@salesforce/apex/CaseFawriTransferController.getFawriTransferList';

import REQUESTED_BY_FIELD from '@salesforce/schema/Case.ac_RequestedBy__c';
import NAME_ON_THE_CARD_FIELD from '@salesforce/schema/Case.cc_Name_on_the_Card__c';
import TOTAL_FEES_FIELD from '@salesforce/schema/Case.Total_Fees__c';
import EXPIRY_DAYS_FIELD from '@salesforce/schema/Case.Expiry_Days__c';
import DISCOUNT_AMOUNT_FIELD from '@salesforce/schema/Case.Discount_Amount__c';

import getCustomerNameByCIF from '@salesforce/apex/CaseDisputesController.getCustomerNameByCIF';

import { createRecord } from 'lightning/uiRecordApi';

export default class CaseFieldDependencySelector extends NavigationMixin(LightningElement) {
    // Record Type ID for "Request"
    requestRecordTypeId;
    recordTypeMap;
    recTypeName;
    recTypeId;

    // Data for picklist dependency
    allSubTypes = {};
    allRequestTypes = {};

    @api recordId;
    @track isAllowed = false;

    // Fields for Case
    @track subject = '';
    @track description = '';
    @track caseModel = 'ila';
    @track caseType = '';
    @track caseSubType = '';
    @track caseRequestType = '';
    @track caseOrigin = '';
    @track caseNature = '';
    @track customerEmailSuppressionOnCreation = false;
    @track customerEmailSuppressionOnClosure = false;
    @track generateRandomPassword = false;
    @track isShowEmailSuppressionSection = true;
    @track routing = '';
    @track error;
    @track caseCurrency = '';
    @track overdrawnAccount = '';
    @track creditLimit = '';
    @track maskedCardNumber = '';
    @track startDateTime;
    @track endDateTime;
    @track requestedAmount;
    @track staffId;
    @track staffCorporateEmail;
    @track exitDate;
    @track queueMap = {};
    @track userId = Id;
    @track isLoaded = false;
    @track selectedValues = [];
    @track selectedAccList = [];

    // Tracked reactive properties
    @track typeOptions = [];
    @track subTypeOptions = [];
    @track requestTypeOptions = [];
    @track caseModelOptions = [];
    @track caseNatureOptions = [];
    @track initialCaseNatureOptions = [];
    @track caseOriginOptions = [];
    @track currencyOptions = [];
    @track overdrawnAccounts = [];

    @track creditCardOptions = [];

    @track accDetails = [];
    @track accIbans = [];
    @track accToBlockUnblockList = [];
    @track accList = [];
    @track showCmp = false;

    isLoading = false;
    @track accountBondList;
    @track currentAcc = null;
    @track bondOptions = [];
    @track currentBond = {};
    @track investmentId = '';
    @track cc_cardPCINumber = [];
    @track selectedPCINumber = '';
    @track cif = '';
    @track regName = '';
    @track creditCardData = [];

    @track requestedBy = '';
    @track customerName = '';
    @track totalFees = '';
    @track discountAmount = '';
    @track expiryDays = '';
    @track isCustomer = false;
    @track isBank = false;
    @track cardNumber = '';
    @track accountAlias = '';
    @track subjectValue = '';
    @track descriptionValue = '';

    @track activeTermDeposits = []; // Stores active term deposits for selection
    @track allTermDeposits = []; // Stores all term deposits
    @track selectedDepositId = ''; // Stores selected deposits in the dual-listbox
    @track selectedIBANLetter = '';
    @track selectedDeposit = '';
    @track allCustomerAccounts = [];

    // CH01 start 
    @track caseFawriTransferList = [];
    caseFawriTransferOptions = [];
    @track isShowFawriTransaction = false;
    @track noTransactionsFound = false;
    @track fawriBatchId = '';
    @track selectedFawriAccount = '';
    @track fawriAccountOptions = [];
    @track fawriTransactionAmount = '';
    @track fawriTransactionDateTime = '';
    @track fawriBeneficiaryIban = '';
    @track caseFawriTransfer = '';

    // CH01 end 

    @track beneficiaryName = '';
    @track amount = '';
    @track tenor = '';
    @track devices = [];
    @track deviceOptions = [];
    @track selectedDeviceId = '';
    @track selectedDeviceName = '';
    @track showDeviceDropdown = false;

    // NEW: properties for URL mode
    @track accountIdFromCif = null;
    @track interactionId = null;
    @track isUrlMode = false;
    @track wrapupCode = null; // NEW

    @track caseCIF;
    @track caseCustomerName;

    // Options for the Requested By combobox
    requestedByOptions = [
        { label: 'Customer', value: 'Customer' },
        { label: 'Bank / CBB', value: 'Bank / CBB' }
    ];

    @wire(getRecord, { recordId: '$recordId', fields: [CIF_FIELD, REGION_FLAG_FIELD] })
    wiredRecord({ error, data }) {
        if (data) {
            this.cif = data.fields.Customer_CIF__c.value;
            this.regName = data.fields.Region_Flag__c.value;
        } else if (error) {
            this.cif = '';
            this.regName = '';
        }
    }

    @wire(getPicklistDataByProfile)
    wiredData({ error, data }) {
        if (data) {
            const { allowedTypes, subTypeMap, requestTypeMap } = data;
            this.typeOptions = allowedTypes.map(type => ({ label: type, value: type }));
            this.allSubTypes = subTypeMap;
            console.log('allSubTypes --->', JSON.stringify(this.allSubTypes));
            this.allRequestTypes = requestTypeMap;
            this.subTypeOptions = [];
            this.requestTypeOptions = [];
        } else if (error) {
            console.error('Error fetching picklist data:', error);
        }
    }

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseObjectInfoHandler({ error, data }) {
        if (data) {
            this.recordTypeMap = new Map(Object.values(data.recordTypeInfos).map(item => [item.name, item.recordTypeId]));
            Object.values(data.recordTypeInfos).forEach(recordTypeInfo => {
                if (recordTypeInfo.name === 'Request') {
                    this.requestRecordTypeId = recordTypeInfo.recordTypeId;
                }
            });
        } else if (error) {
            console.error('Error fetching record type info:', error);
        }
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: CASE_OBJECT, recordTypeId: '$requestRecordTypeId' })
    casePicklistValuesHandler({ error, data }) {
        if (data) {
            this.populatePicklistOptions(data, {
                Case_Model__c: 'caseModelOptions',
                Origin: 'caseOriginOptions',
                Case_Nature__c: 'caseNatureOptions',
                Currency__c: 'currencyOptions'
            });
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: CASEANNEX_OBJECT, recordTypeId: '012000000000000AAA' })
    caseAnnexPicklistValuesHandler({ error, data }) {
        if (data) {
            this.populatePicklistOptions(data, {
                Overdrawn_Account_OD__c: 'overdrawnAccounts'
            });
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }

    @wire(getQueueNameToIdMap)
    wiredQueueMap({ error, data }) {
        if (data) {
            this.queueMap = data; // Stores the map in JS object
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.queueMap = {};
        }
    }

    connectedCallback() {
        isUserInMakerQueue()
            .then(result => {
                this.isAllowed = result;
            })
            .catch(error => {
                this.showError('Error checking permissions');
            });
    }

    renderedCallback() {
        // Ensure the style is added only once
        if (this.isLoaded) return;

        // Create a <style> element
        const STYLE = document.createElement("style");
        STYLE.innerText = `
        .uiModal--horizontalForm .modal-container {
            width: 40% !important;
            max-width: 40% !important;
            height: 100%;
        }
    `;

        // Append the style element to the component
        const lightningCard = this.template.querySelector('lightning-card');
        if (lightningCard) {
            lightningCard.appendChild(STYLE);
            this.isLoaded = true; // Mark as loaded
        }
    }

    // NEW: wire to read URL parameters
    @wire(CurrentPageReference)
    getPageReference(pageRef) {
        if (pageRef && pageRef.state) {
            const cif = pageRef.state.c__cif;
            this.caseCIF = cif;
            this.interactionId = pageRef.state.c__interactionId || null;
            this.wrapupCode = pageRef.state.c__wrapupcode || null; // NEW
            if (cif) {
                this.loadAccountByCIF(cif);
            }
        }
    }

    // NEW: fetch Account ID from CIF and set recordId
    async loadAccountByCIF(cif) {
        if (!cif) return;
        this.isLoading = true;
        this.isUrlMode = true; // mark as URL mode
        try {
            const accountId = await getAccountIdByCIF({ cif });
            if (accountId) {
                this.recordId = accountId; // set recordId to trigger all wired methods
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'No Account found for the provided CIF.',
                        variant: 'error'
                    })
                );
            }

            this.caseCustomerName = await getCustomerNameByCIF({ cif });
            if (!this.caseCustomerName) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'No Account found for the provided CIF.',
                        variant: 'error'
                    })
                );
            }
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to fetch Account for CIF.',
                    variant: 'error'
                })
            );
            console.error(error);
        } finally {
            this.isLoading = false;
        }
    }

    // NEW: container style for URL mode
    get containerStyle() {
        if (this.isUrlMode) {
            return 'max-width: 40%; margin: 0 auto; padding: 1rem;';
        }
        return '';
    }

    // NEW: transform raw wrapup code to user-friendly label
    get wrapupLabel() {
        const map = {
            'FCR': 'FCR',
            'customerAbandoned': 'Customer abandoned',
            'EscalatedComplaint': 'Escalated- complaint',
            'handoffFault': 'Handed off- fault',
            'handoffRequest': 'Handed off- request',
            'disputeFraud': 'Dispute - Fraud'
        };
        return map[this.wrapupCode] || this.wrapupCode;
    }

    handleTypeChange(event) {
        this.caseType = event.target.value;
        this.caseSubType = null;
        this.caseRequestType = null;
        // CH01 start 
        this.isShowFawriTransaction = false;
        this.caseFawriTransfer = null;
        // CH01 end 
        this.subTypeOptions = this.allSubTypes[this.caseType]?.map(subType => ({
            label: subType,
            value: subType
        })) || [];
        this.requestTypeOptions = [];


        if (this.caseType == 'Sukuk/bonds/Government security') {
            getAccountBondListViaApi({ accountId: this.recordId, caseModel: this.caseModel })
                .then(data => {
                    this.currentAcc = null;
                    this.accountBondList = data;

                    // Transform the data into label-value pairs
                    this.bondOptions = data.map(item => {
                        return {
                            label: item.referenceNo, // Customize the label as needed
                            value: item.referenceNo // Use referenceNo or any unique identifier as the value
                        };
                    });
                })
                .catch(error => {
                    console.error('Error:', error);
                });
        }
    }

    async handleSubTypeChange(event) {
        this.caseSubType = event.target.value;
        this.caseRequestType = null;
        this.isShowFawriTransaction = false; //CH01
        this.requestTypeOptions = this.allRequestTypes[this.caseSubType]?.map(requestType => ({
            label: requestType,
            value: requestType
        })) || [];

        if (this.caseType == 'Official letter' && this.caseSubType == 'IBAN letter') {
            console.log('caseModel' + this.caseModel);
            const regionName = this.caseModel == 'ila' ? 'Bahrain' : 'Bahrain_alburaq';
            loadAccountList({ customerId: this.cif, regionName: regionName })
                .then((data) => {
                    console.log('Data received:', JSON.stringify(data));

                    if (data.isSuccess && data.responseData?.accounts?.length) {
                        this.allCustomerAccounts = data.responseData.accounts.map(accountObj => ({
                            label: `${accountObj.account.iban} - ${accountObj.account.currency.code}`, // Display alias + IBAN
                            value: accountObj.account.iban // Set IBAN as value
                        }));
                        console.log('this.allCustomerAccounts --->', JSON.stringify(this.allCustomerAccounts));
                        this.error = undefined;
                    } else {
                        this.allCustomerAccounts = [];
                    }
                })
                .catch((error) => {
                    console.error('Error loading accounts:', error);
                    this.error = error;
                    this.allCustomerAccounts = [];
                });
        }

        if (this.caseType == 'Funds Transfer' && this.caseSubType == 'Fawri Cancellation Request') {
            console.log("Case Fawri Criteria.");
            //loadAccountList
            //BankAccountController
            const regionName = this.caseModel == 'ila' ? 'Bahrain' : 'Bahrain_alburaq';
            loadAccountList({ customerId: this.cif, regionName: regionName })
                .then((data) => {
                    console.log('498 Data received:', data);

                    if (data.isSuccess && data.responseData?.accounts?.length) {
                        const bhdAccounts = data.responseData.accounts.filter(f => f.account.currency.code == 'BHD');
                        let listOfBHD_Accounts = [];
                        bhdAccounts.forEach(accountObj => {
                            listOfBHD_Accounts.push({
                                iban: accountObj.account.iban,
                                number: accountObj.account.number,
                                customerId: accountObj.customerId
                            })
                        });
                        console.log("tmpAccount ", listOfBHD_Accounts);
                        this.fetchFawriTransferList(listOfBHD_Accounts, regionName);
                        this.error = undefined;
                    } else {
                        //this.allCustomerAccounts = [];
                    }
                })
                .catch((error) => {
                    console.error('Error loading accounts:', error);
                    this.error = error;
                });


        }
        //end cancel fawri new change 
        if (this.requestTypeOptions?.length === 0) {
            const result = await fetchCaseNatureAndRouting({
                type: this.caseType,
                subType: this.caseSubType,
                requestType: ''
            });
            this.caseNature = result.CaseNature;
            this.routing = result.Routing;
            this.recTypeName = result.RecordTypeName;
            this.recTypeId = this.recordTypeMap.get(result.RecordTypeName);
        }
    }

    handleBondChange(event) {
        const selectedValue = event.detail.value;
        this.investmentId = selectedValue;

        if (!selectedValue) {
            this.currentBond = null;
            return;
        }

        // Find the selected bond from the accountBondList
        const selectedBond = this.accountBondList.find(item => item.referenceNo === selectedValue);

        if (selectedBond) {
            this.currentBond = selectedBond; // Set the selected bond
        } else {
            this.currentBond = null; // Clear if no matching bond is found
            console.error('No matching bond found for referenceNo:', selectedValue);
        }
    }

    handleStartDateTimeChange(event) {
        this.startDateTime = event.target.value;
    }

    handleEndDateTimeChange(event) {
        this.endDateTime = event.target.value;
    }

    async handleRequestTypeChange(event) {
        this.isLoading = true;
        // CH01 start 
        //this.isShowFawriTransaction = false;
        this.caseFawriTransferList = [];
        this.caseFawriTransferOptions = [];

        this.caseRequestType = event.target.value;

        // CH01 end  
        if (!this.initialCaseNatureOptions || this.initialCaseNatureOptions.length === 0) {
            this.initialCaseNatureOptions = [...this.caseNatureOptions];
        }

        this.caseNatureOptions = [...this.initialCaseNatureOptions];

        if ((this.caseType === 'Cards' && this.caseSubType === 'Card Transactions' && this.caseRequestType === 'Hold Release Request') ||
            (this.caseType === 'Cards' && this.caseSubType === 'Dispatch' && (this.caseRequestType === 'Returned Cards Re-delivery Request' || this.caseRequestType === 'International Delivery Request' || this.caseRequestType === 'Pick Up Request'))) {
            this.caseNatureOptions = [
                { "label": "Credit Card", "value": "Credit Card" },
                { "label": "Debit Card", "value": "Debit Card" }
            ];
            console.log('caseNatureOptions -->', JSON.stringify(this.caseNatureOptions));
        }

        console.log('outer loop -->', JSON.stringify(this.caseNatureOptions));
        //this.caseRequestType = event.target.value;
        try {
            const result = await fetchCaseNatureAndRouting({
                type: this.caseType,
                subType: this.caseSubType,
                requestType: this.caseRequestType
            });
            this.caseNature = result.CaseNature;
            this.routing = result.Routing;
            this.recTypeName = result.RecordTypeName;
            this.recTypeId = this.recordTypeMap.get(result.RecordTypeName);

            if (this.caseRequestType === 'Staff Joiner' || this.caseRequestType === 'Staff Leaver') {
                this.isShowEmailSuppressionSection = false;
                this.customerEmailSuppressionOnCreation = true;
                this.customerEmailSuppressionOnClosure = true;
                this.subjectValue = 'Segment Change';
                this.descriptionValue = 'Segment Change';
                this.subject = 'Segment Change';
                this.description = 'Segment Change';
            }

            if (
                (this.caseType == 'Official letter' && this.caseSubType == 'Outstanding letter' && this.caseRequestType == 'Credit Card') ||
                (this.caseType == 'Official letter' && this.caseSubType == 'Outstanding letter' && this.caseRequestType == 'Loans') ||
                (this.caseType == 'Official letter' && this.caseSubType == 'Account Statements' && this.caseRequestType == 'Credit Card')
            ) {
                loadEPPList({ accountId: this.recordId })
                    .then((data) => {
                        this.creditCardOptions = data.map(item => {
                            return { label: item, value: item };
                        });
                        this.isLoading = false;
                    })
                    .catch((error) => {
                        this.isLoading = false;
                        console.error('Error >> ', error);
                        // Handle error here
                    });
            }

            if (
                (this.caseType === 'Official letter' && this.caseSubType === 'Account Statements' && this.caseRequestType === 'Account') 
            ) {
                getAccountToBlockUnblockViaApi({
                    accountId: this.recordId,
                    caseModel: this.caseModel
                })
                    .then((data) => {
                        this.showCmp = true;
                        if (data) {
                            this.accDetails = null;
                            this.accToBlockUnblockList = data;

                            this.accList = data.map((item) => ({
                                label: item.ac_label,
                                value: item.iban
                            }));
                        }
                        this.isLoading = false;
                    })
                    .catch((error) => {
                        this.isLoading = false;
                        console.error('Error:', error);
                    });
            }

            if (this.caseType == 'Official letter' && this.caseSubType == 'IBAN letter') {
                console.log('caseModel' + this.caseModel);
                const regionName = this.caseModel == 'ila' ? 'Bahrain' : 'Bahrain_alburaq';
                loadAccountList({ customerId: this.cif, regionName: regionName })
                    .then((data) => {
                        console.log('Data received:', JSON.stringify(data));

                        if (data.isSuccess && data.responseData?.accounts?.length) {
                            this.allCustomerAccounts = data.responseData.accounts.map(accountObj => ({
                                label: `${accountObj.account.iban} - ${accountObj.account.currency.code}`, // Display alias + IBAN
                                value: accountObj.account.iban // Set IBAN as value
                            }));
                            console.log('this.allCustomerAccounts --->', JSON.stringify(this.allCustomerAccounts));
                            this.error = undefined;
                        } else {
                            this.allCustomerAccounts = [];
                        }
                    })
                    .catch((error) => {
                        console.error('Error loading accounts:', error);
                        this.error = error;
                        this.allCustomerAccounts = [];
                    });
            }

            if (this.shouldShowDeviceDropdown) {
                this.deviceOptions = [];
                this.selectedDeviceId = '';
                this.selectedDeviceName = '';
                this.showDeviceDropdown = false;

                this.loadDeviceList();
            }

            if (this.caseType == 'Funds Transfer' && this.caseSubType == 'Fawri Cancellation Request') {
                console.log("Case Fawri Criteria.");
                //loadAccountList
                //BankAccountController
                const regionName = this.caseModel == 'ila' ? 'Bahrain' : 'Bahrain_alburaq';
                loadAccountList({ customerId: this.cif, regionName: regionName })
                    .then((data) => {
                        console.log('498 Data received:', data);

                        if (data.isSuccess && data.responseData?.accounts?.length) {
                            const bhdAccounts = data.responseData.accounts.filter(f => f.account.currency.code == 'BHD');
                            let listOfBHD_Accounts = [];
                            bhdAccounts.forEach(accountObj => {
                                listOfBHD_Accounts.push({
                                    iban: accountObj.account.iban,
                                    number: accountObj.account.number,
                                    customerId: accountObj.customerId
                                })
                            });
                            console.log("tmpAccount ", listOfBHD_Accounts);
                            this.fetchFawriTransferList(listOfBHD_Accounts, regionName);
                            this.error = undefined;
                        } else {
                            //this.allCustomerAccounts = [];
                        }
                    })
                    .catch((error) => {
                        console.error('Error loading accounts:', error);
                        this.error = error;
                    });


            }

            if (this.isShowPremiumRetentionFields) {
                this.subjectValue = 'Premium Invitation Application';
                this.descriptionValue = 'Premium Invitation Application';
            }

            this.isLoading = false;
            this.error = undefined; // Clear any previous errors
        } catch (error) {
            this.isLoading = false;
            this.error = error.body ? error.body.message : error.message;
            this.caseNature = '';

            if (this.initialCaseNatureOptions && this.initialCaseNatureOptions.length > 0) {
                this.caseNatureOptions = [...this.initialCaseNatureOptions];
            }
        }
    }

    loadDeviceList() {
        if (!this.recordId) {
            console.warn('No recordId provided for device list');
            return;
        }

        loadDeviceList({
            accID: this.recordId,
            caseModel: this.caseModel || 'ila'
        })
            .then(result => {
                console.log('Device list result:', JSON.stringify(result));

                const options = [];
                const devicesMap = [];

                for (let key in result) {
                    let deviceObj = result[key];
                    let labelParts = [];

                    if (deviceObj.manufacturer) {
                        labelParts.push(deviceObj.manufacturer);
                    }

                    if (deviceObj.model && deviceObj.model.marketingName) {
                        labelParts.push(deviceObj.model.marketingName);
                    }

                    if (deviceObj.os) {
                        if (deviceObj.os.name) {
                            labelParts.push(deviceObj.os.name);
                        }
                        if (deviceObj.os.version) {
                            labelParts.push(deviceObj.os.version);
                        }
                    }

                    if (deviceObj.lastLogin && deviceObj.lastLogin.deviceLastLogin) {
                        let dateForm = new Date(deviceObj.lastLogin.deviceLastLogin);
                        const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                        let hours = dateForm.getHours();
                        let minutes = dateForm.getMinutes();
                        let formattedDate = `${dateForm.getDate()} ${months[dateForm.getMonth()]}, ${dateForm.getFullYear()} ${hours}:${minutes.toString().padStart(2, '0')}`;
                        labelParts.push(formattedDate);
                    }

                    options.push({
                        label: labelParts.join(' - '),
                        value: key
                    });

                    devicesMap.push({
                        deviceId: key,
                        label: labelParts.join(' - ')
                    });
                }

                this.deviceOptions = options;
                this.devices = devicesMap;
                this.showDeviceDropdown = this.deviceOptions.length > 0;

            })
            .catch(error => {
                console.error('Error loading devices:', error);
                this.showToast('Error', 'Failed to load device list', 'error');
            });
    }

    handleDeviceChange(event) {
        this.selectedDeviceId = event.detail.value;

        // Find the selected device name
        const selectedDevice = this.devices.find(device => device.deviceId === this.selectedDeviceId);
        this.selectedDeviceName = selectedDevice ? selectedDevice.label : '';

        console.log('Selected Device ID:', this.selectedDeviceId);
        console.log('Selected Device Name:', this.selectedDeviceName);
    }

    // CH01 start
    fetchFawriTransferList(accountList, regionName) {
        if (!accountList || accountList.length === 0) {
            this.noTransactionsFound = true;
            return;
        }

        this.isLoading = true;
        this.fawriAccountOptions = accountList.map(acc => ({
            label: acc.number,
            value: acc.iban
        }));
        this.fawriAccountList = [];
        this.caseFawriTransferList = [];
        this.noTransactionsFound = false;

        const promises = accountList.map(account =>
            getFawriTransferList({ customerId: account.customerId, regionName: regionName })
                .then((data) => {
                    console.log('Fawri Data received for account:', account.iban, data);
                    if (data.isSuccess && data.responseData) {
                        const accountTransactions = [];
                        for (let fawriIndex = 0; fawriIndex < data.responseData.length; fawriIndex++) {
                            const fawriObj = data.responseData[fawriIndex];
                            fawriObj["accountInfo"] = account;

                            console.log('fawriObj --->', fawriObj);

                            if ((fawriObj.reconciliationStatus == 'ACCEPTED' || fawriObj.reconciliationStatus == 'CREATED') && fawriObj.batchId) {
                                const debtorIban = fawriObj.debtor && fawriObj.debtor.account ? (fawriObj.debtor.account.iban || fawriObj.debtor.account.IBAN) : '';
                                const debtorLast10 = (typeof debtorIban === 'string') ? debtorIban.slice(-10) : '';
                                const accountIbanLast10 = (account.iban && typeof account.iban === 'string') ? account.iban.slice(-10) : '';
                                const accountNumberLast10 = (account.number && typeof account.number === 'string') ? account.number.slice(-10) : (account.number ? String(account.number).slice(-10) : '');

                                console.log('debtorIban --->', debtorIban);
                                console.log('debtorLast10 --->', debtorLast10);
                                console.log('accountIbanLast10 --->', accountIbanLast10);
                                console.log('accountNumberLast10 --->', accountNumberLast10);

                                if (debtorLast10 && (debtorLast10 === accountIbanLast10 || debtorLast10 === accountNumberLast10)) {
                                    const uniqueKey = fawriObj.paymentIdentification.endToEndId;
                                    fawriObj.uniqueKey = uniqueKey;
                                    fawriObj.parentIban = account.iban;

                                    accountTransactions.push(fawriObj);
                                    this.caseFawriTransferList = [...this.caseFawriTransferList, fawriObj];
                                }
                            }
                        }

                        if (accountTransactions.length > 0) {
                            this.fawriAccountList.push({
                                iban: account.iban,
                                transactions: accountTransactions
                            });
                            this.isShowFawriTransaction = true;
                        }
                    }
                })
                .catch((error) => {
                    console.error('Error loading Fawri for account ' + account.iban, error);
                })
        );

        Promise.allSettled(promises).then(() => {
            this.isLoading = false;
            if (this.caseFawriTransferList.length === 0) {
                this.noTransactionsFound = true;
                this.isShowFawriTransaction = false;
            } else {
                this.noTransactionsFound = false;
            }
        });
    }

    handleFawriAccountChange(event) {
        this.selectedFawriAccount = event.detail.value;
        this.caseFawriTransfer = '';
        this.fawriTransactionAmount = '';
        this.fawriTransactionDateTime = '';
        this.fawriBeneficiaryIban = '';
        this.fawriBatchId = '';
    }

    get selectedAccountTransactions() {
        if (!this.selectedFawriAccount) return [];
        const account = this.fawriAccountList.find(acc => acc.iban === this.selectedFawriAccount);
        return account ? account.transactions.map(t => ({
            label: t.paymentIdentification.endToEndId,
            value: t.uniqueKey
        })) : [];
    }

    get isTransactionRequired() {
        return this.selectedAccountTransactions && this.selectedAccountTransactions.length > 0;
    }

    get showTransactionDetails() {
        return !!this.caseFawriTransfer;
    }

    get shouldShowDeviceDropdown() {
        return this.caseType === 'App Login' &&
            this.caseSubType === 'Password Reset' &&
            this.caseRequestType === 'Generate Random Password / Revoke Device';
    }

    handleCaseFawriChange(event) {
        const selectedValue = event.detail.value;
        this.caseFawriTransfer = selectedValue;

        const trans = this.caseFawriTransferList.find(f => f.uniqueKey === selectedValue);
        if (trans) {

            // console.log('transactions >> ' ,trans)
            this.fawriTransactionAmount = trans.instructedAmount ? `${trans.instructedAmount.value} ${trans.instructedAmount.currency}` : '';
            this.fawriBatchId = trans.batchId ? trans.batchId : '';


            let rawDate = trans.creationDate || trans.valueDate || '';
            if (rawDate && rawDate.includes('T')) {
                try {
                    // Format: 2026-04-22T17:40:36.955+0300 -> 2026-04-22 17:40:36
                    this.fawriTransactionDateTime = rawDate.replace('T', ' ').split('.')[0];
                } catch (e) {
                    this.fawriTransactionDateTime = rawDate;
                }
            } else {
                this.fawriTransactionDateTime = rawDate;
            }

            this.fawriBeneficiaryIban = trans.creditor && trans.creditor.account ? trans.creditor.account.IBAN : '';
        } else {
            this.fawriTransactionAmount = '';
            this.fawriTransactionDateTime = '';
            this.fawriBeneficiaryIban = '';
        }

        console.log("Fawri transaction updated:", selectedValue);
    }


    // CH01 end
    handleSelectionChange(event) {
        const selectedValue = event.detail.value;
        const fieldName = event.target.name; // Get picklist name

        if (!selectedValue) {
            this.selectionError = 'Please select a value.';
        } else {
            this.selectionError = '';
        }

        // Dynamically set the selected value based on the picklist name
        if (fieldName === 'termDeposits') {
            this.selectedDepositId = selectedValue;
        } else if (fieldName === 'ibanLetters') {
            this.selectedIBANLetter = selectedValue;
        }
    }

    transformDepositData(deposit) {
        return {
            label: `${deposit.urbisContractId} - ${deposit.currency.code} - ${deposit.name}`,
            value: `${deposit.urbisContractId} - ${deposit.currency.code} - ${deposit.name}`,
            status: deposit.progressCode === 'PREPAID' ? 'Early Withdrawn' : deposit.progressCode
        };
    }

    handlePCINumberChange(event) {
        this.selectedPCINumber = event.detail.value;
    }
    // CH01 start 
    get isFawriCancellation() {
        return ((this.caseType == 'Funds Transfer' && this.caseSubType == 'Fawri Cancellation Request') || (this.caseType == 'Funds Transfer' && this.caseSubType == 'Fawri Cancellation'));
        // return this.caseType == 'Funds Transfer' && this.caseSubType == 'Fawri Cancellation';
    }
    // CH01 end

    get isShowBeneficiaryName() {
        return this.caseType == 'Manager Cheque' && this.caseSubType == 'Manager Cheque Issuance';
    }

    get isSubTypeDisabled() {
        return !this.caseType;
    }

    get isRequestTypeDisabled() {
        return !this.caseSubType;
    }

    get selected() {
        return this.accDetails;
    }

    get todaysDate() {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = mm + '/' + dd + '/' + yyyy;
        return today;
    }

    handleChange(event) {
        this[event.target.name] = event.target.value;
        const { name, value } = event.target;

        if (name === 'customerEmailSuppressionOnClosure') {
            this.customerEmailSuppressionOnClosure = event.target.checked;
        }

        if (name === 'customerEmailSuppressionOnCreation') {
            this.customerEmailSuppressionOnCreation = event.target.checked;
        }

        if (name === 'generateRandomPassword') {
            this.generateRandomPassword = event.target.checked;
        }
        if (name === 'caseModel' && this.caseRequestType != '' && this.caseRequestType != undefined && this.caseRequestType != null) {
            this.handleRequestTypeChange(event);
        }
        if (name === 'subject') {
            this.subjectValue = event.target.value;
        }
        if (name === 'description') {
            this.descriptionValue = event.target.value;
        }

        if (name === 'caseNature') {
            if (this.caseType === 'Cards' && this.caseSubType === 'Card Transactions' && this.caseRequestType === 'Hold Release Request') {
                if (this.caseNature == 'Credit Card') {
                    this.routing = 'Credit Card Operations';
                } else if (this.caseNature == 'Debit Card') {
                    this.routing = 'Operations Team';
                }
            }
        }
    }

    // Handle change in Requested By field
    handleRequestedByChange(event) {
        this.requestedBy = event.detail.value;
        this.isCustomer = this.requestedBy === 'Customer';
        this.isBank = this.requestedBy === 'Bank / CBB';
    }

    handleListBoxChange(event) {
        //this.selectedValues = event.detail.value;
        const selectedValues = event.detail.value;
        this.selectedAccList = selectedValues;
        const myValues = this.accToBlockUnblockList;

        const accLst = [];
        selectedValues.forEach(iban => {
            myValues.forEach(element => {
                if (element.iban === iban) {
                    console.error('*********************', element);
                    accLst.push(element);
                }
            });
        });

        if (accLst.length > 0) {
            let str = '';
            let strIban = '';
            accLst.forEach((account, index) => {
                if (index === 0) {
                    str = account.ac_label + ',';
                    strIban = account.iban + '';
                } else {
                    str += '\n' + account.ac_label;
                    strIban += ',' + account.iban;
                }
            });

            this.accDetails = str;
            this.accIbans = strIban;
        } else {
            // Clear the values if no matching accounts
            this.accDetails = null;
            this.accIbans = null;
        }
    }

    async handleSave() {
        // Get all input fields (combobox, input, textarea, etc.)
        let allFieldsValid = [...this.template.querySelectorAll(
            'lightning-combobox, lightning-input, lightning-textarea'
        )].reduce((validSoFar, inputField) => {
            inputField.reportValidity(); // Show error if invalid
            return validSoFar && inputField.checkValidity(); // Check validity
        }, true);

        if (allFieldsValid) {
            if (!this.caseRequestType) {
                const result = await fetchCaseNatureAndRoutingUsingSubType({
                    type: this.caseType,
                    subType: this.caseSubType
                });
                this.caseNature = result.CaseNature;
                this.routing = result.Routing;
                this.recTypeName = result.RecordTypeName;
                this.recTypeId = this.recordTypeMap.get(result.RecordTypeName);
            }

            this.isLoading = true;
            const fields = {
                [SUBJECT_FIELD.fieldApiName]: this.subject,
                [DESCRIPTION_FIELD.fieldApiName]: this.description,
                [CASEMODEL_FIELD.fieldApiName]: this.caseModel,
                [TYPE_FIELD.fieldApiName]: this.caseType,
                [SUBTYPE_FIELD.fieldApiName]: this.caseSubType,
                [REQUESTTYPE_FIELD.fieldApiName]: this.caseRequestType || '',
                [CASEORIGIN_FIELD.fieldApiName]: this.caseOrigin,
                [CASENATURE_FIELD.fieldApiName]: this.caseNature,
                [RECORDTYPE_FIELD.fieldApiName]: this.recTypeId,
                [CUSTOMER_FIELD.fieldApiName]: this.recordId, // uses resolved recordId (set from URL or Quick Action)
                [Customer_Email_Suppression_on_Creation_FIELD.fieldApiName]: this.customerEmailSuppressionOnCreation,
                [Customer_Email_Suppression_on_Closure_FIELD.fieldApiName]: this.customerEmailSuppressionOnClosure
            };

            if (this.routing == 'FCR') {
                fields[STATUS_FIELD.fieldApiName] = 'Closed';
                fields[SUBSTATUS_FIELD.fieldApiName] = 'Closed';
                fields[OWNER_FIELD.fieldApiName] = this.userId;
            } else if (this.routing == '') {
                fields[OWNER_FIELD.fieldApiName] = this.userId;
            } else {
                fields[OWNER_FIELD.fieldApiName] = this.queueMap[this.routing];
            }

            if (this.isShowCurrencies) {
                fields[CURRENCY_FIELD.fieldApiName] = this.caseCurrency;
            }

            if (this.isShowMaskedNumber) {
                fields[CREDIT_LIMIT_FIELD.fieldApiName] = this.creditLimit;
                fields[MASKED_CARD_NUMBER_FIELD.fieldApiName] = this.selectedPCINumber;
            }

            if (this.isShowAccounts) {
                fields[BUA_ACCOUNTS_INFORMATION_FIELD.fieldApiName] = Array.isArray(this.accDetails) ? this.accDetails.join(', ') : this.accDetails;
                fields[AC_IBAN_FIELD.fieldApiName] = Array.isArray(this.accIbans) ? this.accIbans.join(',') : this.accIbans;
            }

            if (this.interactionId) {
                fields[INSTRUMENT_ID_FIELD.fieldApiName] = this.interactionId;
            }
            if (this.wrapupCode) {
                fields[SALES_OUTCOME_FIELD.fieldApiName] = this.wrapupCode;
            }

            if (this.isShowIBANLetters) {
                fields[BUA_ACCOUNTS_INFORMATION_FIELD.fieldApiName] = this.selectedIBANLetter;
                fields[AC_IBAN_FIELD.fieldApiName] = this.selectedIBANLetter;
            }

            if (this.isShowGenerateRandomPassword) {
                fields[GENERATE_RANDOM_RECOVERY_CODE_FIELD.fieldApiName] = this.generateRandomPassword;
            }

            if (this.recTypeName == 'Request' && this.routing != 'FCR') {
                fields[SUBSTATUS_FIELD.fieldApiName] = 'In-Progress';
            }

            if (this.caseType == 'Profile Update' || (this.caseType == 'Account' && this.caseSubType == 'Dormant Account Reactivation')
                || (this.caseType == 'Account' && this.caseSubType == 'Manual Account Creation')
                || (this.caseType == 'Card Service' && this.caseSubType == 'Link/ Delink Card')
                || (this.caseType == 'Cards' && this.caseSubType == 'Debit Card')
                || (this.caseType == 'Cards' && this.caseSubType == 'Card Control')
                || (this.caseType == 'Sukuk/bonds/Government security')
                || (this.caseType == 'Account' && this.caseSubType == 'Segment')
                || (this.caseType === 'App Login' && this.caseSubType === 'Password Reset' && this.caseRequestType === 'Generate Random Password / Revoke Device')) {
                fields[SUBSTATUS_FIELD.fieldApiName] = 'In-Progress';
            }

            // CH01 start 
            if (this.isShowFawriTransaction) {
                const fawriIndex = this.caseFawriTransferList.findIndex(f => f.uniqueKey == this.caseFawriTransfer);
                if (fawriIndex > -1) {
                    fields[AC_IBAN_FIELD.fieldApiName] = this.caseFawriTransferList[fawriIndex].accountInfo.iban;
                    fields[TRANSACTION_AMOUNT_FIELD.fieldApiName] = this.caseFawriTransferList[fawriIndex].instructedAmount.value;
                    fields[TRANSACTION_CURRENCY_FIELD.fieldApiName] = this.caseFawriTransferList[fawriIndex].instructedAmount.currency;
                    fields[TRANSACTION_DATE_FIELD.fieldApiName] = this.caseFawriTransferList[fawriIndex].valueDate;
                    fields[TRANSACTION_REF_NO_FIELD.fieldApiName] = this.caseFawriTransfer;
                    fields[BATCHID_FIELD.fieldApiName] = this.caseFawriTransferList[fawriIndex].batchId;
                    fields[CCOL_HOLD_ACCOUNT_IBAN_FIELD.fieldApiName] = this.caseFawriTransferList[fawriIndex].debtorAgent.bic;
                    // fields[CC_MAKER_FIELD.fieldApiName] = 'Send to Checker';
                    // fields[CC_MAKER_RESULT_DATE_TIME_FIELD.fieldApiName] = new Date().toISOString();
                    console.log("Fawri fields save ", fields);
                } else if (this.selectedFawriAccount) {
                    fields[AC_IBAN_FIELD.fieldApiName] = this.selectedFawriAccount;
                }
            }
            // CH01 end 

            if (this.isShowBondSukukOptions) {
                fields[INVESTMENT_ID_FIELD.fieldApiName] = this.investmentId;
                fields[ISIN_TYPE_FIELD.fieldApiName] = this.currentBond.bs_ISIN_Type;
                fields[ISIN_CODE_FIELD.fieldApiName] = this.currentBond.bs_ISIN_Code;
                fields[MATURITY_DATE_FIELD.fieldApiName] = this.currentBond.bs_Maturity_Date;
                fields[TOTAL_BID_AMOUNT_FIELD.fieldApiName] = this.currentBond.bs_bidAllocationAmount;
            }

            if (this.isShowPremiumRetentionFields) {
                //fields[INVESTMENT_ID_FIELD.fieldApiName] = this.investmentId;
                fields[REQUESTED_BY_FIELD.fieldApiName] = this.requestedBy;
                fields[SUBSTATUS_FIELD.fieldApiName] = 'Pending Customer';

                if (this.isCustomer) {
                    if (this.customerName && this.customerName.length > 26) {
                        this.showErrorToast('Error', 'Customer Name cannot exceed 26 characters.', 'error');
                        return;
                    }
                    fields[NAME_ON_THE_CARD_FIELD.fieldApiName] = this.customerName;
                    fields[TOTAL_FEES_FIELD.fieldApiName] = this.totalFees;
                    fields[EXPIRY_DAYS_FIELD.fieldApiName] = 365;
                }

                if (this.isBank) {
                    fields[DISCOUNT_AMOUNT_FIELD.fieldApiName] = this.discountAmount;
                    fields[EXPIRY_DAYS_FIELD.fieldApiName] = this.expiryDays;
                }
            }

            if (this.isShowCardNumbers) {
                fields[PRIMARY_MASKED_CARD_NUMBER_FIELD.fieldApiName] = this.cardNumber;
            }

            if (this.isShowAccountAliasAndCurrencies) {
                fields[CURRENCY_FIELD.fieldApiName] = this.caseCurrency;
                fields[ACCOUNT_ALIAS_FIELD.fieldApiName] = this.accountAlias;
            }

            if (this.isShowBondSukukOptions && (!this.investmentId || this.investmentId.trim() === '')) {
                this.showErrorToast('Error', 'Investment ID is required to create a record.', 'error');
                return;
            }

            if (this.isShowMaskedNumber && (!this.selectedPCINumber || this.selectedPCINumber.trim() === '') && (!this.creditLimit || this.creditLimit.trim() === '')) {
                this.showErrorToast('Error', 'Masked Card Number and Credit Limit are required to create a record.', 'error');
                return;
            }

            /* if (this.shouldShowDeviceDropdown && !this.selectedDeviceId) {
                this.showToast('Error', 'Please select a device', 'error');
                return;
            } */

            if (this.shouldShowDeviceDropdown) {
                fields[SEID_FIELD.fieldApiName] = this.selectedDeviceName;
                fields[HOLD_ID_FIELD.fieldApiName] = this.selectedDeviceId;
            }

            console.log('fields --->', JSON.stringify(fields));
            createRecord({ apiName: CASE_OBJECT.objectApiName, fields }).then((record) => {
                console.log('record --->', JSON.stringify(record));

                // if (this.caseType === 'Onboarding' && this.caseSubType === 'Manual' && this.caseRequestType === 'Trigger OB') {
                //                     this.closeCase(record);
                //                     this.navigateToRecord(record);
                //                 } else 

                if (this.recTypeName == 'Request') {
                    this.createCaseAnnex(record);
                } else if (this.generateRandomPassword == true) {
                    callResettingRecoveryCodeSMS({ CaseId: record.id })
                        .then(() => {
                            this.isLoading = false;
                            console.log('Apex method called successfully');
                            this.navigateToRecord(record);
                        })
                        .catch(error => {
                            this.isLoading = false;
                            console.error('Error calling Apex method:', error);
                        })
                        .finally(() => {
                            this.isLoading = false;
                        });
                } else {
                    this.navigateToRecord(record);
                    this.isLoading = false;
                }
            }).catch(error => {
                this.isLoading = false;
                console.log('Error --->', JSON.stringify(error));
                this.showErrorToast(
                    'Error creating Case',
                    error?.body?.output?.errors?.[0]?.message || 'Unknown error occurred'
                );
            });
        } else {
            this.isLoading = false;
            // Prevent save operation
            console.error("Please fill all required fields before saving.");
            this.showErrorToast('Error creating Case', 'Please fill all required fields before saving.');
        }
    }

    createCaseAnnex(caseRecord) {
        console.log('===== createCaseAnnex START =====');

        console.log('caseRecord --->', JSON.stringify(caseRecord));

        const fields = {
            [CASE_FIELD.fieldApiName]: caseRecord.id,
        };

        console.log('Initial fields --->', JSON.stringify(fields));

        // Check Overdrawn Account
        console.log('isShowOverdrawnAccount --->', this.isShowOverdrawnAccount);
        if (this.isShowOverdrawnAccount) {
            console.log('Adding Overdrawn Account field --->', this.overdrawnAccount);

            fields[OVERDRAWN_ACCOUNT_FIELD.fieldApiName] = this.overdrawnAccount;

            console.log(
                'Overdrawn Account field added --->',
                JSON.stringify(fields)
            );
        }

        // Check Dates
        console.log('isShowDates --->', this.isShowDates);
        if (this.isShowDates) {
            console.log('startDateTime --->', this.startDateTime);
            console.log('endDateTime --->', this.endDateTime);

            fields[PERIOD_FROM_FIELD.fieldApiName] = this.startDateTime;
            fields[PERIOD_TO_FIELD.fieldApiName] = this.endDateTime;

            console.log(
                'Date fields added --->',
                JSON.stringify(fields)
            );
        }

        // Check Beneficiary Name
        console.log('isShowBeneficiaryName --->', this.isShowBeneficiaryName);
        if (this.isShowBeneficiaryName) {
            console.log('beneficiaryName --->', this.beneficiaryName);
            console.log('amount --->', this.amount);

            fields[BENEFICIARY_NAME_FIELD.fieldApiName] = this.beneficiaryName;
            fields[AMOUNT_FIELD.fieldApiName] = this.amount;

            console.log(
                'Beneficiary Name and Amount fields added --->',
                JSON.stringify(fields)
            );
        }

        // Check Tenor
        console.log('isShowTenor --->', this.isShowTenor);
        if (this.isShowTenor) {
            console.log('tenor --->', this.tenor);

            fields[TENOR_FIELD.fieldApiName] = this.tenor;

            console.log(
                'Tenor field added --->',
                JSON.stringify(fields)
            );
        }

        // Case Annex Record Type
        console.log(
            'CASE_ANNEX_RECTYPE_ID_FIELD --->',
            CASE_ANNEX_RECTYPE_ID_FIELD.fieldApiName
        );

        fields[CASE_ANNEX_RECTYPE_ID_FIELD.fieldApiName] = '012Pw00000ApHtDIAV';

        console.log(
            'Final fields before createRecord --->',
            JSON.stringify(fields)
        );

        console.log('Calling createRecord --->');
        console.log('Object API Name --->', CASEANNEX_OBJECT.objectApiName);

        createRecord({
            apiName: CASEANNEX_OBJECT.objectApiName,
            fields
        })
            .then(result => {
                console.log('createRecord SUCCESS --->');
                console.log('Created Case Annex result --->', JSON.stringify(result));

                console.log('Calling navigateToRecord --->');
                this.navigateToRecord(caseRecord);
            })
            .catch(error => {
                console.log('createRecord ERROR --->', JSON.stringify(error));
                console.log('Error body --->', JSON.stringify(error?.body));
                console.log('Error message --->', error?.body?.message);

                this.isLoading = false;

                console.log('isLoading set to false due to error --->', this.isLoading);

                this.showErrorToast(
                    'Error creating Case Annex',
                    error.body.message
                );
            })
            .finally(() => {
                console.log('createRecord FINALLY --->');

                this.isLoading = false;

                console.log('isLoading set to false in finally --->', this.isLoading);
                console.log('===== createCaseAnnex END =====');
            });
    }

    populatePicklistOptions(data, fieldMapping) {
        for (const fieldName in fieldMapping) {
            const options = data.picklistFieldValues[fieldName]?.values || [];
            this[fieldMapping[fieldName]] = options.map(item => ({
                label: item.label,
                value: item.value
            }));
        }
    }

    navigateToRecord(caseRecord) {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseRecord.id,
                actionName: 'view',
            },
        }).then(url => {
            this.isLoading = false;
            this.showSuccessToast('Case created successfully!', url, caseRecord.fields.CaseNumber.value);
            this.closeQuickAction();
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseRecord.id,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
    }

    // Toast Notifications
    showSuccessToast(title, url, caseNumber) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message: `Case {0} was created!`,
            messageData: [{ url, label: caseNumber }],
            variant: 'success',
        }));
    }

    showErrorToast(title, message) {
        this.isLoading = false;
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant: 'error',
        }));
    }

    // Handle Cancel
    handleCancel() {
        this.closeQuickAction();
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    get isShowCreditCardOptions() {
        return (
            (this.caseType === 'Official letter' && this.caseSubType === 'Account Statements' && this.caseRequestType === 'Credit Card')
        );
    }

    get isShowBondSukukOptions() {
        return (
            (this.caseType === 'Sukuk/bonds/Government security')
        );
    }

    get isShowIBANLetters() {
        return (
            this.caseType == 'Official letter' && this.caseSubType == 'IBAN letter'
        );
    }

    get isShowPremiumInvitation() {
        return (
            this.caseType == 'Account' && this.caseSubType == 'Segment' && this.caseRequestType == 'Invitation'
        );
    }

    get isShowTenor() {
        return (
            this.caseType == 'Cards' && this.caseSubType == 'Credit Card' && this.caseRequestType == 'Manual EPP Creation'
        );
    }

    get isShowAccounts() {
        return (
            (this.caseType === 'Official letter' && this.caseSubType === 'Account Statements' && this.caseRequestType === 'Account')
        );
    }

    get isShowDates() {
        return (
            (this.caseType === 'Official letter' && this.caseSubType === 'Account Statements' && this.caseRequestType === 'Account')
        );
    }

    get isShowCurrencies() {
        return (
            (this.caseType === 'Relationship Termination' && this.caseSubType === 'Relationship Termination - By Customer' && this.caseRequestType === 'FX accounts') ||
            (this.caseType === 'Account' && this.caseSubType === 'Manual Account Closure' && this.caseRequestType === 'FX accounts') ||
            (this.caseType === 'Account' && this.caseSubType === 'Manual Account Creation' && this.caseRequestType === 'FX accounts')
        );
    }

    get isShowOverdrawnAccount() {
        return (
            this.caseType === 'Account' && this.caseSubType === 'Status' && this.caseRequestType === 'Overdrawn'
        );
    }

    get isShowPremiumRetentionFields() {
        return (
            this.caseType == 'Account' && this.caseSubType == 'Segment' && this.caseRequestType == 'Invitation'
            //this.caseType === 'Premium' && (this.caseSubType === 'Retention' || this.caseSubType === 'Invitation')
        );
    }

    get isShowAccountAliasAndCurrencies() {
        return (
            this.caseType === 'Account' && this.caseSubType === 'Create Account'
        );
    }

    get isShowGenerateRandomPassword() {
        const isVisible = (this.caseType === 'App Login' && this.caseSubType === 'Password Reset' && this.caseRequestType === 'Generate Random Password / Revoke Device');
        console.log('isVisible --->', isVisible);
        return isVisible;
    }

    get isShowMaskedNumber() {
        const conditions = [
            { caseType: 'Credit Card', caseSubType: 'ila Switch', caseRequestType: 'Decrease credit limit' },
            { caseType: 'Credit Card', caseSubType: 'ila Blue', caseRequestType: 'Decrease credit limit' },
            { caseType: 'Credit Card', caseSubType: 'Cash Collateral', caseRequestType: 'From Salary to Kanz' },
            { caseType: 'Credit Card', caseSubType: 'Cash Collateral', caseRequestType: 'From Kanz to Salary' }
        ];

        return conditions.some(condition =>
            condition.caseType === this.caseType &&
            condition.caseSubType === this.caseSubType &&
            condition.caseRequestType === this.caseRequestType
        );
    }

    get hasData() {
        return this.currentBond && Object.keys(this.currentBond).length > 0;
    }

    get isShowCardNumbers() {
        return (
            this.caseType === 'Fraud'
        );
    }
}