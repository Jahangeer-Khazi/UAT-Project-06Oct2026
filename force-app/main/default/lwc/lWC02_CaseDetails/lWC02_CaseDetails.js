//#CH01# AITOGRAM Omar 07-14-2026 – Synchronous Fawri cancellation error handling added for updateRecordsWithRollback  [NBA-15906].
import { LightningElement, track, api, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getConfigJson from '@salesforce/apex/CaseAnnexController.getConfigJson';
import { refreshApex } from '@salesforce/apex';
import getCaseAnnexFields from '@salesforce/apex/CaseAnnexController.getCaseAnnexFields';
import getCaseFields from '@salesforce/apex/CaseAnnexController.getCaseFields';
import updateRecordsWithRollback from '@salesforce/apex/CaseAnnexController.updateRecordsWithRollback';
import { IsConsoleNavigation, getFocusedTabInfo, refreshTab } from 'lightning/platformWorkspaceApi';
import getOwnerDeveloperName from '@salesforce/apex/CaseAnnexController.getOwnerDeveloperName';
import syncForm from '@salesforce/apex/HandOffProcessController.syncForm';
import loadLoansList from '@salesforce/apex/Loans_LoansListController.loadLoansList';

export default class LWC02_CaseDetails extends LightningElement {
    @wire(IsConsoleNavigation) isConsoleNavigation;

    objectLwcIdMap = new Map();
    objectIsVisibledMap = new Map();

    expressionFields = [];
    onFocusOutVisible;
    caseRecordType;
    @track showSectionValeurs = true;
    @track showSyncButton = false;
    @track showBuyOutMsg = false;//NBA-17570
    @track flowError = false;
    @track validationError = false;
    errorFields = []
    @track show = true;
    @api recordId;
    @track fieldValue;
    disabled = false;
    @track parsedJsonResult;
    @api columns;
    @track afficherFormulaire = false;
    @track caseAnnexMap = '';
    @track validationError
    @track configJson = [];
    @track showValidationError = false
    @track showValidationErrorIcon = false
    @track dynamicObjectName
    @track dynamicRecordId
    @track loadingSpinner = false;
    dataLoaded = false;
    @track editSectionValeurs = false;
    @track caseRecord;

    @track caseRecordOrigin;
    @track caseAnnexMapOrigin;
    validationErrorMessage
    value = 'field.fieldAPIName'
    errorNullRequiredField = false;

    isFirstUpdate = true;

    @api size;
    isConfigJsonFetched = false;
    @track specialFields = ['Subject', 'Description', 'Comments', 'Case_Outcome__c'];

    retryCount = 0;
    maxRetries = 10;
    ownerDeveloperName;

    connectedCallback() {
        console.log('=== connectedCallback STARTED ===');
        console.log('recordId:', this.recordId);
        this.loadingSpinner = true;
        console.log('loadingSpinner set to:', this.loadingSpinner);
        console.log('=== connectedCallback COMPLETED ===');
    }

    // @wire(getCaseFields, { recordId: '$recordId' })
    // wiredGetCaseFields(result) {
    //     console.log('=== wiredGetCaseFields TRIGGERED ===');
    //     console.log('Case result status:', result.data ? 'DATA' : result.error ? 'ERROR' : 'LOADING');
    //     console.log('Case result data:', result.data);
    //     console.log('Case result error:', result.error);

    //     if (result.data) {
    //         var resultJson = JSON.parse(result.data);
    //         console.log('Parsed case resultJson:', resultJson);
    //         this.wiredCaseFields = resultJson;
    //         const caseRecord = resultJson;
    //         this.caseTypeValue = caseRecord.type;
    //         this.caseSubTypeValue = caseRecord.sub_type__c;
    //         this.caseRecordType = caseRecord.recordtype_developername__c;
    //         this.caseRecord = caseRecord;

    //         this.caseRecordOrigin = caseRecord;
    //         this.isConfigJsonFetched = false;

    //         console.log('Case type:', this.caseTypeValue);
    //         console.log('Case subtype:', this.caseSubTypeValue);
    //         console.log('Case record type:', this.caseRecordType);

    //         if(this.wiredCaseFields){
    //             console.log('Case owner:', this.wiredCaseFields.ownerid);
    //             var ownerid = this.wiredCaseFields.ownerid;
    //             getOwnerDeveloperName({ ownerid: ownerid })
    //                 .then(result => {
    //                     console.log('Queue Developer Name fetched:', result);
    //                     this.ownerDeveloperName = result;
    //                     console.log('ownerDeveloperName set to:', this.ownerDeveloperName);
    //                 })
    //                 .catch(error => {
    //                     console.error('Error fetching owner developer name:', error);
    //                 });
    //         }

    //         console.log('Calling callFetchConfigJson from wiredGetCaseFields');
    //         this.callFetchConfigJson();
    //     } else if (result.error) {
    //         console.error('Error fetching case fields:', result.error);
    //     }
    //     console.log('=== wiredGetCaseFields COMPLETED ===');
    // }
    fetchCaseFields() {
        console.log('=== fetchCaseFields CALLED (manual call after Case Annex loaded) ===');
        getCaseFields({ recordId: this.recordId })
            .then(result => {
                console.log('Case fields fetched manually:', result);
                if (result) {
                    var resultJson = JSON.parse(result);
                    this.wiredCaseFields = resultJson;
                    const caseRecord = resultJson;
                    this.caseTypeValue = caseRecord.type;
                    this.caseStatusValue = caseRecord.status;
                    this.caseSubTypeValue = caseRecord.sub_type__c;
                    this.caseRecordType = caseRecord.recordtype_developername__c;
                    this.caseRecord = caseRecord;
                    this.caseRecordOrigin = caseRecord;
                    this.isConfigJsonFetched = false;

                    if (this.wiredCaseFields) {
                        //console.log('Case owner:', this.wiredCaseFields.ownerid);
                        let loanOwnerid = this.wiredCaseFields.ownerid;
                        let lastAssignedQueueId = this.wiredCaseFields.alias_account__c;
                        var ownerid;
                        if(lastAssignedQueueId != null && lastAssignedQueueId.startsWith('00G') ){
                            ownerid = lastAssignedQueueId;
                            console.log('Loan -> lastAssignedQueueId using "Accout Alias" Field --> ', ownerid);
                        }
                        else{
                            ownerid = loanOwnerid;
                            console.log('Loan -> loanOwnerid using OwnerId Field --> ', ownerid);
                        }
                        getOwnerDeveloperName({ ownerid: ownerid })
                            .then(result => {
                                console.log('Queue Developer Name:', result);
                                this.ownerDeveloperName = result;
                                this.callFetchConfigJson();
                            })
                            .catch(error => {
                                console.error('Error:', error);
                            });
                    }
                    //this.callFetchConfigJson();
                }
            })
            .catch(error => {
                console.error('Error fetching case fields:', error);
            });
    }
    @wire(getCaseAnnexFields, {
        recordId: '$recordId',
        retryCount: '$retryCount'
    })
    wiredGetCaseAnnexFields(result) {
        console.log('=== wiredGetCaseAnnexFields TRIGGERED ===');
        console.log('Retry count:', this.retryCount);
        console.log('Case Annex result status:', result.data ? 'DATA' : result.error ? 'ERROR' : 'LOADING');

        this.wiredCaseAnnexFields = result;
        console.log('Case Annex Result:', result);

        if (result.data) {
            console.log('Case Annex data length:', result.data.length);
            if (result.data.length > 0) {
                this.retryCount = 0;
                var resultJson = JSON.parse(result.data[0])
                console.log('Parsed case annex resultJson:', resultJson);
                this.recordAnnexId = resultJson.id;
                this.caseAnnexMap = resultJson;
                this.caseAnnexMapOrigin = resultJson;

                console.log('recordAnnexId set to:', this.recordAnnexId);
                console.log('caseAnnexMap set to:', this.caseAnnexMap);
                this.fetchCaseFields();
            } else {
                console.log('No data found in case annex fields.');
                if (this.retryCount < this.maxRetries) {
                    console.log(`Retrying... (Attempt ${this.retryCount + 1}/${this.maxRetries})`);
                    setTimeout(() => {
                        this.retryCount++;
                        console.log('retryCount incremented to:', this.retryCount);
                    }, 1500);
                } else {
                    this.caseAnnexMap = 'EMpty';
                    this.isConfigJsonFetched = false;
                    console.log('Max retries reached. caseAnnexMap set to Empty');
                    this.fetchCaseFields();
                    this.callFetchConfigJson();
                    console.error('Max retries reached. Stopping.');
                }
            }
        } else if (result.error) {
            console.error('Error fetching case annex fields:', result.error);
            this.fetchCaseFields();
        }
        console.log('=== wiredGetCaseAnnexFields COMPLETED ===');
    }
    // omar start

    async handleRefreshApi() {
        console.log('=== handleRefreshApi TRIGGERED ===');
        this.loadingSpinner = true;

        try {
            const customerId = this.caseRecord.customer_cif__c;
            const caseModel = this.caseRecord.case_model__c;
            const LoanId = this.caseRecord.cc_pci_id__c;

            console.log('Fetching loan list for refresh. CIF:', customerId, 'Model:', caseModel, 'Target LoanId:', LoanId);

            const response = await loadLoansList({ customerId: customerId, caseModel: caseModel });

            console.log('loadLoansList response:', response);
            // console.log('loadLoansList response stringified:', JSON.stringify(response));

            let loanObj = null;
            if (response && response.responseData && response.responseData.currentLoans) {
                const currentLoans = response.responseData.currentLoans;
                for (let i = 0; i < currentLoans.length; i++) {
                    if (currentLoans[i].arrangementId == LoanId) {
                        loanObj = currentLoans[i];
                        break;
                    }
                }
            }

            console.log('Found loanObj:', loanObj);

            if (!loanObj) {
                throw new Error('Could not find matching loan details for ID: ' + LoanId);
            }

            await syncForm({
                caseId: this.recordId,
                LoanId: LoanId,
                loanObj: loanObj
            });

            console.log('submitForm for refresh successful');
            this.showToast('Success', 'API data refreshed successfully', 'success');
            await this.refreshTab();
        } catch (error) {
            console.error('Error refreshing API data:', error);
            this.showToast('Error refreshing API data', error.message || (error.body ? error.body.message : 'Unknown error'), 'error');
        } finally {
            this.loadingSpinner = false;
        }
    }
    // omar end
    callFetchConfigJson() {
        console.log('=== callFetchConfigJson CALLED ===');
        console.log('Seq: Case Annex -> Case -----> Config JSON');

        if (!this.isConfigJsonFetched && this.caseRecord && this.caseAnnexMap) {
            this.isConfigJsonFetched = true;
            console.log('Conditions met, calling fetchConfigJson');
            this.fetchConfigJson();
        } else {
            console.log('Conditions NOT met for fetchConfigJson');
        }
        console.log('=== callFetchConfigJson COMPLETED ===');
    }

    async refreshTab() {
        console.log('=== refreshTab CALLED ===');
        console.log('isConsoleNavigation:', this.isConsoleNavigation);

        if (!this.isConsoleNavigation) {
            console.log("Not in console navigation—refresh skipped.");
            return;
        }
        try {
            const { tabId } = await getFocusedTabInfo();
            console.log('Tab ID to refresh:', tabId);
            await refreshTab(tabId, { includeAllSubtabs: true });
            console.log("Tab refreshed successfully!");
        } catch (error) {
            console.error("Error refreshing tab:", error);
        }
        console.log('=== refreshTab COMPLETED ===');
    }

    async fetchConfigJson() {
        console.log('=== fetchConfigJson STARTED ===');
        console.log('caseRecordType:', this.caseRecordType);
        console.log('caseSubTypeValue:', this.caseSubTypeValue);
        console.log('caseTypeValue:', this.caseTypeValue);

        try {
            const result = await getConfigJson({ subtype: this.caseSubTypeValue, type: this.caseTypeValue, recTypeDveloperName: this.caseRecordType });
            console.log('getConfigJson result:', result);

            const parsedResult = JSON.parse(result[0].JSON_Value__c);
            this.parsedJsonResult = parsedResult;
            console.log('Parsed JSON result:', parsedResult);

            this.configJson = this.processJsonConfig(parsedResult, this.caseRecord, this.caseAnnexMap);
            console.log('Processed configJson:', this.configJson);

            if (this.configJson && this.caseRecord && this.caseAnnexMap) {
                this.dataLoaded = true;
                this.loadingSpinner = false;
                console.log('Data loaded successfully, loadingSpinner set to false');
            } else {
                console.log('Data not fully loaded yet');
            }
        } catch (error) {
            console.error('Error fetching configuration JSON:', error);
        }
        console.log('=== fetchConfigJson COMPLETED ===');
    }

    processJsonConfig(jsonObject, caseRecord, caseAnnex) {
        console.log('=== processJsonConfig STARTED ===');
        console.log('Input jsonObject:', jsonObject);
        console.log('Input caseRecord:', caseRecord);
        console.log('Input caseAnnex:', caseAnnex);

        let i = 0;
        jsonObject.forEach(section => {
            console.log('Processing section:', section.sectionName);
            // omar start
            console.log('test caseStatusValue >>> ' + this.caseStatusValue)
            if (this.caseSubTypeValue === 'Instalment Deferment / Postponement' && this.caseStatusValue.toLowerCase() !== 'closed') {
                this.showSyncButton = true;
            }
            if (section.sectionName === 'Case Details' && this.caseStatusValue.toLowerCase() !== 'closed' && this.caseSubTypeValue !== 'Instalment Deferment / Postponement') {
                section.showSyncButton = true;
                console.log('Sync button flag set for section: Case Details');
            }
            // omar end 
            
            //NBA-17570 :start
            if (section.sectionName === 'to be provided by Document Verifier OBL' && this.caseStatusValue.toLowerCase() !== 'closed' && this.caseSubTypeValue === 'New Loan / Finance Application Request' && this.ownerDeveloperName == 'Loan_Document_Verifier_OBL') {
                section.showBuyOutMsg = true;
                console.log('showBuyOutMsg true for section: to be provided by Document Verifier OBL');
            }
            //NBA-17570 :end

            if (!section.fields) {
                console.log('No fields in section, skipping');
                return;
            }

            section.fields.forEach(field => {
                i += 1;
                console.log(`Processing field ${i}:`, field.fieldAPIName);

                const baseConfig = this.createBaseConfig(field, i);
                console.log('Base config created:', baseConfig);

                if (field.hidden !== undefined && field.hidden == true) {
                    baseConfig.responsiveClass += ' slds-hide';
                    baseConfig.dynamicClass += ' slds-hide';
                    console.log('Field marked as hidden');
                }

                Object.assign(field, baseConfig);
                console.log('Field after assignment:', field);

                this.dynamicObjectName = field.objectName;
                this.dynamicRecordId = baseConfig.rec;
                console.log('dynamicObjectName set to:', this.dynamicObjectName);
                console.log('dynamicRecordId set to:', this.dynamicRecordId);

                if (field.visibilityFilter !== undefined) {
                    console.log('Field has visibility filter:', field.visibilityFilter);
                    this.updateVisibilityConfig(field);
                    field.isVisible = this.evaluateVisibility(field.visibilityFilter, caseRecord, caseAnnex);
                    console.log('Field visibility evaluated to:', field.isVisible);
                }

                if (field.Label !== undefined) {
                    field.overideLabel = true;
                    console.log('Field label overridden');
                }
            });

            if (section.visibilityFilter !== undefined) {
                section.isVisible = this.evaluateVisibility(section.visibilityFilter, caseRecord, caseAnnex);
                console.log('Section visibility evaluated to:', section.isVisible);
            } else {
                section.isVisible = true;
                console.log('Section has no visibility filter, defaulting to visible');
            }

            section.show = true;
            section.iconName = 'utility:chevrondown';
            console.log('Section finalized:', section);
        });

        console.log('Final processed jsonObject:', jsonObject);
        console.log('=== processJsonConfig COMPLETED ===');
        return jsonObject;
    }

    createBaseConfig(field, index) {
        console.log('=== createBaseConfig CALLED ===');
        console.log('Field:', field.fieldAPIName);
        console.log('Index:', index);

        const baseConfig = {
            isCase: field.objectName === 'Case',
            isCaseAnnex: field.objectName === 'CaseAnnex__c',
            rec: field.objectName === 'Case' ? this.recordId : this.recordAnnexId,
            key: `${field.objectName}.${field.fieldAPIName}`,
            lwcId: `${field.objectName}-${field.fieldAPIName}-${index}`,
            isRequired: field.required,
            isVisible: true,
            dynamicClass: this.specialFields.includes(field.fieldAPIName)
                ? 'slds-size_1-of-1'
                : `slds-size_1-of-${this.size}`,
            responsiveClass: this.specialFields.includes(field.fieldAPIName)
                ? 'slds-col slds-size_1-of-1 slds-p-around_xxx-small'
                : `slds-col slds-size_1-of-${this.size} slds-p-around_xxx-small`
        };

        console.log('Base config created:', baseConfig);
        console.log('=== createBaseConfig COMPLETED ===');
        return baseConfig;
    }

    updateVisibilityConfig(field) {
        console.log('=== updateVisibilityConfig CALLED ===');
        console.log('Field for visibility config:', field);

        const { key, lwcId, visibilityFilter } = field;
        this.objectLwcIdMap.set(key, lwcId);
        console.log('objectLwcIdMap updated with key:', key, 'value:', lwcId);

        if (typeof visibilityFilter !== 'boolean') {
            this.expressionFields = visibilityFilter.expressions.map(expr => expr.fieldAPIName);
            this.objectIsVisibledMap.set(field, [...this.expressionFields]);
            console.log('expressionFields set to:', this.expressionFields);
            console.log('objectIsVisibledMap updated with field:', field, 'expressions:', this.expressionFields);
        }
        console.log('=== updateVisibilityConfig COMPLETED ===');
    }

    evaluateVisibility(condition, caseRecord, caseAnnexRecord) {
        console.log('=== evaluateVisibility CALLED ===');
        console.log('Condition:', condition);
        console.log('caseRecord:', caseRecord);
        console.log('caseAnnexRecord:', caseAnnexRecord);

        if (typeof condition === 'boolean') {
            console.log('Condition is boolean, returning:', condition);
            return condition;
        } else if (typeof condition === 'object') {
            const { logicalOperator, expressions } = condition;
            console.log('Logical operator:', logicalOperator);
            console.log('Expressions:', expressions);

            const evaluate = expr => this.evaluateExpression(expr, caseRecord, caseAnnexRecord);

            let result;
            switch (logicalOperator) {
                case 'and':
                    result = expressions.every(evaluate);
                    console.log('AND operation result:', result);
                    break;
                case 'or':
                    result = expressions.some(evaluate);
                    console.log('OR operation result:', result);
                    break;
                default:
                    result = false;
                    console.log('Unknown operator, returning false');
            }
            console.log('=== evaluateVisibility COMPLETED with result:', result);
            return result;
        }
        console.log('Condition type not recognized, returning false');
        return false;
    }

    evaluateExpression(expression, caseRecord, caseAnnexRecord) {
        console.log('=== evaluateExpression CALLED ===');
        console.log('Expression:', expression);

        const { objectName, fieldAPIName, operator, value } = expression;
        const lowerFieldName = fieldAPIName.toLowerCase();
        const lowerobjectName = objectName.toLowerCase();

        console.log('Field details - object:', objectName, 'field:', fieldAPIName, 'operator:', operator, 'value:', value);

        var fieldValue;
        if (lowerobjectName === 'queue') {
            //#CH02 : start
            if (this.ownerDeveloperName == null) {
                //console.log('this.caseRecord.ownerId :', this.caseRecord.ownerid);
                let loanOwnerid = this.wiredCaseFields.ownerid;
                let lastAssignedQueueId = this.wiredCaseFields.alias_account__c;
                var ownerid;
                if(lastAssignedQueueId != null && lastAssignedQueueId.startsWith('00G') ){
                    ownerid = lastAssignedQueueId;
                    console.log('Loan -> lastAssignedQueueId using "Accout Alias" Field --> ', ownerid);
                }
                else{
                    ownerid = loanOwnerid;
                    console.log('Loan -> loanOwnerid using OwnerId Field --> ', ownerid);
                }
                getOwnerDeveloperName({ ownerid: ownerid })
                    .then(result => {
                        console.log('--> Queue Developer Name:', result);
                        this.ownerDeveloperName = result;
                        fieldValue = this.ownerDeveloperName;
                        console.log('getOwnerDeveloperName >> Queue Dev evaluation - objectName:', lowerobjectName, 'fieldValue:', fieldValue, 'comparisonValue:', value);
                    })
                    .catch(error => {
                        console.error('Error:', error);
                    });
            }
            else{
                fieldValue = this.ownerDeveloperName;
                console.log('Queue Dev evaluation - objectName:', lowerobjectName, 'fieldValue:', fieldValue, 'comparisonValue:', value);
            }
            //#CH02 : End
        } else {
            fieldValue = lowerobjectName === 'case' ? caseRecord[lowerFieldName] : caseAnnexRecord[lowerFieldName];
            console.log('Field value retrieved:', fieldValue, 'from object:', lowerobjectName);
        }

        let result;
        switch (operator) {
            case '=':
                result = fieldValue == value;
                break;
            case '!=':
                result = fieldValue != value;
                break;
            case '<':
                result = fieldValue < value;
                break;
            case '>':
                result = fieldValue > value;
                break;
            case '<=':
                result = fieldValue <= value;
                break;
            case '>=':
                result = fieldValue >= value;
                break;
            default:
                result = false;
        }

        console.log('Expression evaluation result:', result, `(${fieldValue} ${operator} ${value})`);
        console.log('=== evaluateExpression COMPLETED ===');
        return result;
    }

    handleInputFocusOut(event) {
        console.log('=== handleInputFocusOut TRIGGERED ===');
        console.log('Event details:', event);
        console.log('Event target:', event.target);

        try {
            const fieldName = event.target.dataset.fieldName;
            const fieldObjName = event.target.dataset.objectName;
            const value = event.target.value;
            const lowerFieldName = fieldName.toLowerCase();
            const lowerfieldObjName = fieldObjName.toLowerCase();

            console.log('Field changed - Name:', fieldName, 'Object:', fieldObjName, 'Value:', value);
            console.log('Normalized - lowerFieldName:', lowerFieldName, 'lowerfieldObjName:', lowerfieldObjName);

            let fieldVisibilityFilter = [];
            let fieldFound = false;

            console.log('objectIsVisibledMap contents:', this.objectIsVisibledMap);

            this.objectIsVisibledMap.forEach((expressionFieldsArray, filter) => {
                console.log('Checking filter:', filter, 'with fields:', expressionFieldsArray);
                if (expressionFieldsArray.includes(fieldName)) {
                    fieldFound = true;
                    fieldVisibilityFilter.push(filter);
                    console.log('Field found in filter:', filter);
                }
            });

            console.log('Field found in filters:', fieldFound);
            console.log('Field visibility filters:', fieldVisibilityFilter);

            if ((lowerFieldName in this.caseRecord) && lowerfieldObjName == 'case') {
                console.log('Updating caseRecord field:', lowerFieldName, 'from', this.caseRecord[lowerFieldName], 'to', value);
                this.caseRecord[lowerFieldName] = value;
            } else if ((lowerFieldName in this.caseAnnexMap) && lowerfieldObjName == 'caseannex__c') {
                console.log('Updating caseAnnexMap field:', lowerFieldName, 'from', this.caseAnnexMap[lowerFieldName], 'to', value);

                //#CH02 : Start NBA-17410 : calculate field cx_ln_approved_deferment_fee_amount__c based on changing of cx_ln_deferment_with_applicable_fees__c(yes or no)
                // NOTE: template.querySelector / this.template.content.querySelector always return null in LWC 
                // because the framework scopes/mangles all IDs and shadow DOM. 
                // The correct LWC pattern is: mutate the field object inside configJson directly, 
                // then spread configJson to trigger a re-render. The HTML template branches on 
                // field.calculatedValue to show a disabled lightning-input-field with the live value.
                if ( (lowerFieldName == 'cx_ln_deferment_with_applicable_fees__c' || lowerFieldName == 'cx_ln_approved_number_of_months__c') &&
                    this.caseSubTypeValue === 'Instalment Deferment / Postponement' &&
                    this.caseAnnexMap[lowerFieldName] != value
                ) {
                    console.log('#CH02 '+lowerFieldName + ' changed from', this.caseAnnexMap[lowerFieldName], 'to', value);
                    let calculatedFeeAmount;

                    //senario1 if cx_ln_deferment_with_applicable_fees__c is the one changed
                    if( lowerFieldName == 'cx_ln_deferment_with_applicable_fees__c' ){
                        if ( value == 'No' ) {
                            console.log('#CH02 No senario1: setting approved deferment fee amount to 0');
                            calculatedFeeAmount = 0;
                        } else if ( value == 'Yes' ) {
                            let numberOfMonths = Number(this.caseAnnexMap['cx_ln_approved_number_of_months__c']) || 0;
                            calculatedFeeAmount = numberOfMonths * 10;
                            console.log('#CH02 Yes senario1: numberOfMonths =', numberOfMonths, '→ calculatedFeeAmount =', calculatedFeeAmount);
                        }
                    }

                    //senario2 if cx_ln_approved_number_of_months__c is the one changed
                    if ( lowerFieldName == 'cx_ln_approved_number_of_months__c' && this.caseAnnexMap['cx_ln_deferment_with_applicable_fees__c'] == 'Yes' ) {
                        let numberOfMonths = Number(value) || 0;
                        calculatedFeeAmount = numberOfMonths * 10;
                        console.log('#CH02 Yes senario2: numberOfMonths =', numberOfMonths, '→ calculatedFeeAmount =', calculatedFeeAmount);
                    }

                    if (calculatedFeeAmount !== undefined) {
                        // Write the calculated value back into caseAnnexMap so handleSave picks it up
                        this.caseAnnexMap['cx_ln_approved_deferment_fee_amount__c'] = calculatedFeeAmount;

                        // Update field.calculatedValue on the matching configJson field object(s)
                        // so the HTML template can render a reactive disabled input-field instead of the
                        // static output-field (which is bound directly to the server record and 
                        // cannot be updated from JS at all).
                        this.configJson.forEach(section => {
                            if (section.fields) {
                                section.fields.forEach(f => {
                                    if (f.fieldAPIName.toLowerCase() === 'cx_ln_approved_deferment_fee_amount__c' &&
                                        f.objectName.toLowerCase() === 'caseannex__c') {
                                        f.calculatedValue = calculatedFeeAmount;
                                        f.isNeededCalculation = true;
                                        console.log('#CH02 Set calculatedValue =', calculatedFeeAmount, 'on field object', f.fieldAPIName, '(lwcId:', f.lwcId, ')');
                                    }
                                });
                            }
                        });
                        // Spread configJson to notify LWC's reactive system and trigger re-render
                        this.configJson = [...this.configJson];
                        console.log('#CH02 configJson spread triggered for reactive re-render');
                    }
                }
                //#CH02 : End

                this.caseAnnexMap[lowerFieldName] = value;
            } else {
                console.warn(`Field ${lowerFieldName} does not exist in either caseRecord or caseAnnexMap.`);
                return;
            }

            this.caseRecord = { ...this.caseRecord };
            this.caseAnnexMap = { ...this.caseAnnexMap };
            console.log('Records updated with spread operator');

            this.configJson.forEach(section => {
                if (section.visibilityFilter !== undefined) {
                    const oldVisibility = section.isVisible;
                    section.isVisible = this.evaluateVisibility(section.visibilityFilter, this.caseRecord, this.caseAnnexMap);
                    console.log('Section visibility -', section.sectionName, 'changed from', oldVisibility, 'to', section.isVisible);
                }
            });

            if (!fieldFound) {
                console.warn(`Field ${fieldName} not found in any filter.`);
                return;
            }

            fieldVisibilityFilter.forEach(filter => {
                const isVisible = this.evaluateVisibility(filter.visibilityFilter, this.caseRecord, this.caseAnnexMap);
                console.log('Visibility for filter', filter, 'evaluated to:', isVisible);

                this.configJson.forEach(section => {
                    if (section.fields) {
                        section.fields.forEach(field => {
                            if (field.lwcId === filter.lwcId) {
                                const oldVisibility = field.isVisible;
                                field.isVisible = isVisible;
                                console.log('Field visibility updated -', field.fieldAPIName, 'changed from', oldVisibility, 'to', isVisible);
                            }
                        });
                    }
                });
            });

            this.caseRecord = { ...this.caseRecord };
            this.caseAnnexMap = { ...this.caseAnnexMap };

        } catch (error) {
            console.error('Error in handleInputFocusOut:', error);
        }
        console.log('=== handleInputFocusOut COMPLETED ===');
    }

    handleCloseError() {
        console.log('=== handleCloseError CALLED ===');
        console.log('showValidationError before:', this.showValidationError);
        this.showValidationError = !this.showValidationError;
        console.log('showValidationError after:', this.showValidationError);
        console.log('=== handleCloseError COMPLETED ===');
    }

    accordionClick() {
        console.log('=== accordionClick CALLED ===');
        let accordion = this.template.querySelector('.accordion');
        let panel = this.template.querySelector('.panel');
        console.log('Accordion element:', accordion);
        console.log('Panel element:', panel);

        if (accordion.classList.contains('active') == false) {
            accordion.classList.add('active');
            panel.classList.add('activePanel');
            console.log('Accordion expanded');
        } else {
            accordion.classList.remove('active');
            panel.classList.remove('activePanel');
            console.log('Accordion collapsed');
        }
        console.log('=== accordionClick COMPLETED ===');
    }

    handleChangeFormValeurs() {
        console.log('=== handleChangeFormValeurs CALLED ===');
        console.log('Current errorFields:', this.errorFields);
        this.errorFields = [];
        this.caseRecord = { ...this.caseRecord };
        this.caseAnnexMap = { ...this.caseAnnexMap };
        this.showSectionValeurs = false;
        this.editSectionValeurs = true;

        console.log('Form values changed, edit mode activated');
        console.log('=== handleChangeFormValeurs COMPLETED ===');
    }

    handleCancel() {
        console.log('=== handleCancel CALLED ===');
        console.log('Resetting all error states and validation');

        this.errorFields = [];
        this.errorNullRequiredField = false;
        this.showSectionValeurs = true;
        this.editSectionValeurs = false;
        this.showValidationError = false
        this.flowError = false;
        this.validationError = false;
        this.showValidationErrorIcon = false

        console.log('Resetting field errors in configJson');
        this.configJson.forEach(section => {
            section.fields.forEach(field => {
                field.errorMessage = '';
                field.returnIcon = false
                field.errorDesign = ''
                field.inputErrorDesign = ''
            });
        });

        console.log('Cancel operation completed');
        console.log('=== handleCancel COMPLETED ===');
    }

    handleToggleSection(event) {
        console.log('=== handleToggleSection CALLED ===');
        const sectionName = event.target.dataset.sectionName;
        console.log('Toggling section:', sectionName);

        const sections = this.configJson.map(section => {
            if (section.sectionName === sectionName) {
                const oldState = section.show;
                section.show = !section.show;
                section.iconName = section.show ? 'utility:chevrondown' : 'utility:chevronright';
                section.ClassName = section.show ? '' : 'slds-hide';
                console.log('Section toggled from', oldState, 'to', section.show);
            }
            return section;
        });
        this.configJson = [...sections];
        console.log('=== handleToggleSection COMPLETED ===');
    }

    handleReturnOriginalValues() {
        console.log('=== handleReturnOriginalValues CALLED ===');
        console.log('Returning to original values...');
        console.log('=== handleReturnOriginalValues COMPLETED ===');
    }

    handleSave() {
        console.log('=== handleSave CALLED ===');
        console.log('Save operation initiated');
        this.loadingSpinner = true;
        console.log('loadingSpinner set to:', this.loadingSpinner);

        this.errorNullRequiredField = false;
        console.log('errorNullRequiredField reset to:', this.errorNullRequiredField);

        try {
            let records = {
                Case: { Id: this.recordId },
                CaseAnnex__c: { Id: this.recordAnnexId }
            };

            console.log('Initial records object:', records);

            this.configJson.forEach(section => {
                console.log('Processing section for save:', section.sectionName, 'visible:', section.isVisible);

                if (section.isVisible) {
                    section.fields
                        .filter(field => (!field.readOnly || field.isNeededCalculation) && field.isVisible) //#CH02 : add field.isNeededCalculation
                        .forEach(field => {
                            console.log('Processing field for save:', field.fieldAPIName);

                            let fieldValue;
                            if (field.objectName.toLowerCase() === 'case') {
                                fieldValue = this.caseRecord[field.fieldAPIName.toLowerCase()];
                                console.log('Case field value:', fieldValue);
                            }
                            else if (field.objectName.toLowerCase() === 'caseannex__c') {
                                fieldValue = this.caseAnnexMap[field.fieldAPIName.toLowerCase()];
                                console.log('CaseAnnex field value:', fieldValue);
                            }

                            console.log('Field required:', field.required);
                            if (this.isFieldValueInvalid(fieldValue, field.required)) {
                                this.errorNullRequiredField = true;
                                this.errorFields.push(field.fieldAPIName);
                                console.log('Field validation failed - required field empty:', field.fieldAPIName);
                            }

                            if (field.objectName.toLowerCase() === 'case' && this.caseRecord[field.fieldAPIName.toLowerCase()] != this.caseRecordOrigin[field.fieldAPIName.toLowerCase()]) {
                                fieldValue = this.caseRecord[field.fieldAPIName.toLowerCase()];
                                records[field.objectName][field.fieldAPIName] = fieldValue;
                                console.log('Case field added to update:', field.fieldAPIName, 'value:', fieldValue);
                            }
                            else if (field.objectName.toLowerCase() === 'caseannex__c' && this.caseAnnexMap[field.fieldAPIName.toLowerCase()] != this.caseAnnexMapOrigin[field.fieldAPIName.toLowerCase()]) {
                                fieldValue = this.caseAnnexMap[field.fieldAPIName.toLowerCase()];
                                records[field.objectName][field.fieldAPIName] = fieldValue;
                                console.log('CaseAnnex field added to update:', field.fieldAPIName, 'value:', fieldValue);
                            }
                        });
                }
            });

            console.log('Final records to update:', records);
            console.log('errorNullRequiredField after validation:', this.errorNullRequiredField);
            console.log('errorFields:', this.errorFields);

            if (this.errorNullRequiredField) {
                console.log('Validation errors found, calling handleValidationError');
                this.handleValidationError();
                this.loadingSpinner = false;
                console.log('loadingSpinner set to:', this.loadingSpinner);
            } else {
                console.log('No validation errors, proceeding with saveRecords');
                this.saveRecords(records);
            }

        } catch (error) {
            console.error('Error in handleSave:', error);
            this.showToast('Error updating records', error.body ? error.body.message : 'Unknown error', 'error');
        } finally {
            console.log('handleSave operation completed');
        }
        console.log('=== handleSave COMPLETED ===');
    }

    isFieldValueInvalid(value, required) {
        console.log('=== isFieldValueInvalid CHECK ===');
        console.log('Value:', value, 'Required:', required);
        const result = required && (value === null || value === undefined || value === '');
        console.log('Field value invalid:', result);
        console.log('=== isFieldValueInvalid COMPLETED ===');
        return result;
    }

    handleValidationError() {
        console.log('=== handleValidationError CALLED ===');
        console.log('Validation error fields:', this.errorFields);

        this.validationErrorMessage = this.errorFields[0];
        this.flowError = false;
        this.validationError = true;
        this.showValidationError = true;
        this.showValidationErrorIcon = true;
        this.showSectionValeurs = false;

        console.log('Validation error message set to:', this.validationErrorMessage);
        console.log('Error states - flowError:', this.flowError, 'validationError:', this.validationError);
        console.log('UI states - showValidationError:', this.showValidationError, 'showValidationErrorIcon:', this.showValidationErrorIcon);

        this.configJson.forEach(section => {
            section.fields.forEach(field => {
                if (field.fieldAPIName === this.errorFields[0]) {
                    field.returnIcon = true;
                    field.errorDesign = 'errorBackground';
                    field.inputErrorDesign = 'slds-form-element slds-has-error';
                    console.log('Field error styling applied to:', field.fieldAPIName);
                }
            });
        });

        this.errorFields = [];
        console.log('=== handleValidationError COMPLETED ===');
    }

    async saveRecords(records) {
        console.log('=== saveRecords CALLED ===');
        console.log('Records to save:', records);

        try {
            await updateRecordsWithRollback({
                cas: records.Case,
                caseAnnexe: records.CaseAnnex__c
            })
                .then(() => {
                    console.log('updateRecordsWithRollback successful');
                    this.showSectionValeurs = true;
                    this.editSectionValeurs = false;
                    this.loadingSpinner = false;

                    console.log('UI states after successful save:');
                    console.log('showSectionValeurs:', this.showSectionValeurs);
                    console.log('editSectionValeurs:', this.editSectionValeurs);
                    console.log('loadingSpinner:', this.loadingSpinner);

                    this.resetValidationErrors();
                    this.refreshTab();
                    console.log('Save operation completed successfully');
                })
                .catch((error) => {
                    console.log('updateRecordsWithRollback error:', JSON.stringify(error));
                    this.handleUpdateError(error);
                });

        } catch (error) {
            console.error('Error in saveRecords:', error);
        }
        console.log('=== saveRecords COMPLETED ===');
    }

    resetValidationErrors() {
        console.log('=== resetValidationErrors CALLED ===');

        this.showSectionValeurs = true;
        this.editSectionValeurs = false;
        this.showValidationError = false;
        this.flowError = false;
        this.validationError = false;
        this.showValidationErrorIcon = false;

        console.log('All error states reset to false');

        this.configJson.forEach(section => {
            section.fields.forEach(field => {
                field.errorMessage = '';
                field.returnIcon = false;
                field.errorDesign = '';
                field.inputErrorDesign = '';
            });
        });

        this.errorFields = [];
        console.log('Field error states cleared');
        console.log('=== resetValidationErrors COMPLETED ===');
    }

    updateRecords(recordToInsert) {
        console.log('=== updateRecords CALLED ===');
        console.log('Record to update:', JSON.stringify(recordToInsert));
        this.loadingSpinner = true;
        console.log('loadingSpinner set to:', this.loadingSpinner);

        return updateRecord({
            fields: recordToInsert
        })
            .then(() => {
                console.log('updateRecord successful');
                if (!this.isFirstUpdate) {
                    this.showSectionValeurs = true;
                    this.editSectionValeurs = false;
                    this.loadingSpinner = false;
                    console.log('UI states updated after first update');
                }

                this.isFirstUpdate = false;
                console.log('isFirstUpdate set to:', this.isFirstUpdate);
            })
            .catch((error) => {
                console.log('updateRecord error, calling handleUpdateError');
                this.handleUpdateError(error);
            });
    }

    // handleUpdateError(error) {
    //     console.log('=== handleUpdateError CALLED ===');
    //     console.log('Error details:', error);
    //     this.loadingSpinner = false;
    //     console.log('loadingSpinner set to:', this.loadingSpinner);

    //     if (error.body.fieldErrors != null && Object.keys(error.body.fieldErrors).length != 0) {
    //         console.log('Field errors detected, calling handleValidationErrors');
    //         this.handleValidationErrors(error.body.fieldErrors);
    //     } else if (error.body.pageErrors.length > 0) {
    //         console.log('Page errors detected, calling handleFlowErrors');
    //         this.handleFlowErrors(error.body.pageErrors[0].message);
    //     } else {
    //         console.log('Generic error, showing toast');
    //         this.showToast('Error updating records', error.body ? error.body.message : 'Unknown error', 'error');
    //     }

    //     console.error('Error details:', error);
    //     console.error('Error JSON:', JSON.stringify(error));
    //     this.editSectionValeurs = true;
    //     this.showSectionValeurs = false;
    //     console.log('Error handling completed');
    //     console.log('=== handleUpdateError COMPLETED ===');
    // }

    // #CH01# – Start: Fawri cancellation
    handleUpdateError(error) {
        console.log('=== handleUpdateError CALLED ===');
        console.log('Error detailss:', JSON.stringify(error));
        this.loadingSpinner = false;

        const body = error && error.body ? error.body : null;

        if (body && body.fieldErrors && Object.keys(body.fieldErrors).length > 0) {
            console.log('Field errors detected, calling handleValidationErrors');
            this.handleValidationErrors(body.fieldErrors);

        } else if (body && body.pageErrors && body.pageErrors.length > 0) {
            console.log('Page errors detected, calling handleFlowErrors');
            this.handleFlowErrors(body.pageErrors[0].message);



        } else if (body && body.message) {
            console.log('AuraHandledException message detected:', body.message);

            if (body.message.startsWith('PERMISSION_ERROR:')) {
                this.showToast(
                    'Permission Error',
                    body.message.replace('PERMISSION_ERROR:', ''),
                    'error'
                );
            } else {
                this.handleFlowErrors(body.message);
            }
        }
        else {
            const fallback = (body && body.message) ? body.message : 'An unexpected error occurred. Please try again.';
            console.warn('Unknown error shape, showing toast. Error:', JSON.stringify(error));
            this.showToast('Error updating records', fallback, 'error');
            this.editSectionValeurs = true;
            this.showSectionValeurs = false;
        }

        console.error('Error details s:', error);
        this.editSectionValeurs = true;
        this.showSectionValeurs = false;
        console.log('=== handleUpdateError COMPLETED ===');
    }
    // #CH01# – End: Fawri cancellation

    handleValidationErrors(validationErrors) {
        console.log('=== handleValidationErrors CALLED ===');
        console.log('Validation errors:', JSON.stringify(validationErrors));

        this.validationErrorMessage = '';
        this.flowError = false;
        this.validationError = true;
        this.showValidationError = true;
        this.showValidationErrorIcon = true;
        this.showSectionValeurs = false;

        console.log('Error states set for validation errors');

        for (const field in validationErrors) {
            if (validationErrors.hasOwnProperty(field)) {
                const errorObject = validationErrors[field][0];
                const fieldName = field;
                const errorMessage = errorObject.message;

                console.log('Processing field error - Field:', fieldName, 'Message:', errorMessage);

                this.validationErrorMessage = fieldName;
                console.log('validationErrorMessage set to:', this.validationErrorMessage);

                this.configJson.forEach(section => {
                    section.fields.forEach(field => {
                        if (field.fieldAPIName === fieldName || field.VRfieldAPIName === fieldName) {
                            field.errorMessage = errorMessage;
                            field.returnIcon = true;
                            field.errorDesign = 'errorBackground';
                            field.inputErrorDesign = 'slds-form-element slds-has-error';
                            console.log('Field error applied to:', field.fieldAPIName);
                        }
                    });
                });
            }
        }
        console.log('=== handleValidationErrors COMPLETED ===');
    }

    handleFlowErrors(flowErrors) {
        console.log('=== handleFlowErrors CALLED ===');
        console.log('Flow errors:', JSON.stringify(flowErrors));

        this.validationErrorMessage = '';
        this.flowError = true;
        this.validationError = false;
        this.showValidationError = true;
        this.showValidationErrorIcon = true;
        this.showSectionValeurs = false;

        this.validationErrorMessage = flowErrors;
        console.log('Flow error message set to:', this.validationErrorMessage);
        console.log('=== handleFlowErrors COMPLETED ===');
    }

    showToast(title, message, variant) {
        console.log('=== showToast CALLED ===');
        console.log('Toast - Title:', title, 'Message:', message, 'Variant:', variant);

        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
        console.log('Toast event dispatched');
        console.log('=== showToast COMPLETED ===');
    }

    get dynamicClass() {
        const result = `slds-size_1-of-${this.size}`;
        console.log('dynamicClass computed:', result);
        return result;
    }

    get responsiveClass() {
        const result = `slds-col slds-size_1-of-${this.size} slds-p-around_xxx-small`;
        console.log('responsiveClass computed:', result);
        return result;
    }

    get layoutClass() {
        const result = `slds-col slds-size_1-of-${this.size} slds-p-small`;
        console.log('layoutClass computed:', result);
        return result;
    }
}