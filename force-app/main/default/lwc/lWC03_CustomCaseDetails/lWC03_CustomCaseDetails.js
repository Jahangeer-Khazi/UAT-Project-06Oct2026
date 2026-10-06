import { LightningElement, track, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getConfigJson from '@salesforce/apex/CaseAnnexController.getConfigJson';
import { refreshApex } from '@salesforce/apex';
import getCaseAnnexId from '@salesforce/apex/CaseAnnexController.getCaseAnnexId';
import getCaseTypeAndSubtype from '@salesforce/apex/CaseAnnexController.getCaseTypeAndSubtype';


export default class LWC03_CustomCaseDetails extends LightningElement {

    @track showSectionValeurs = true;
    @track flowError = false;
    @track validationError = false;
    errorFields = []
    @track show = true;
    @api recordId;
    @track fieldValue;
    disabled = false;
     @api columns;
    // @track recordAnnexId = 'a1tQI000004BsfVYAS';
    @track afficherFormulaire = false;
    @track caseAnnexString= '';
    @track validationError
    @track configJson = [];
    @track showValidationError = false
    @track showValidationErrorIcon = false
    // @track iconNameValeurs = 'utility:chevronright';
    @track dynamicObjectName
    @track dynamicRecordId
    @track loadingSpinner = false;
    @track configJson = [];  
    @track editSectionValeurs = false;
    validationErrorMessage
    value = 'field.fieldAPIName'
    errorNullRequiredField = false;
   
    isFirstUpdate = true;
    get cols() {
        console.log('Columns:', this.columns);
        return (typeof this.columns != "undefined" && this.columns != null) ? this.columns : 2;
    }

    get view() {
        console.log('View Mode:', this.viewMode);
        return (typeof this.viewMode != "undefined" && this.viewMode != null) ? this.viewMode : "readonly";
    }

    connectedCallback() {
         console.log('recordId==>', this.recordId);
        console.log('Component loaded!');
        // this.fetchRecordAnnexId();
        this.fetchCaseTypeAndSubtype();
       
    }

    async fetchCaseTypeAndSubtype() {
        try {
            const caseRecord = await getCaseTypeAndSubtype({ recordId: this.recordId });
            // console.log('caseRecord: >>> ', caseRecord);
            this.caseRecord = caseRecord; 
            const caseAnnexRecord  = await getCaseAnnexId({ recordId: this.recordId });
            this.recordAnnexId =  caseAnnexRecord.Id;
            this.caseAnnexString = caseAnnexRecord
            this.fetchConfigJson(caseRecord, caseAnnexRecord);
        } catch (error) {
            // this.loadingSpinner = false;
            console.error('Error fetching subtype:', error);
        }
    }

    // async fetchCaseSubtype() {
    //     try {
    //         const subtype = await getCaseSubtype({ recordId: this.recordId });
    //         console.log('type:', type);
    //         // this.fetchConfigJson(type);
            
    //     } catch (error) {
    //         // this.loadingSpinner = false;
    //         console.error('Error fetching subtype:', error);
    //     }
    // }
    // async fetchRecordAnnexId() {
    //     try {
    //         const caseAnnexRecord  = await getCaseAnnexId({ recordId: this.recordId });
    //         this.recordAnnexId =  caseAnnexRecord.Id;
    //         this.caseAnnexString = caseAnnexRecord
    //         console.log('CaseAnnex==>', JSON.stringify(this.caseAnnexString));
    //         console.log('RecordAnnexId==>', this.recordAnnexId);
           
    //         // this.fetchConfigJson();  
    //     } catch (error) {
    //         this.loadingSpinner = false
    //         console.error('Error fetching RecordAnnexId:', error);
    //     }
    // }

    async fetchConfigJson(caseRecord, caseAnnexRecord ) {
        try {
            // console.log('in fetch caseRecord :::  '+ JSON.stringify(caseRecord) + ' caseAnnex ::: ' + JSON.stringify(caseAnnexRecord));
            // console.log('in fetch caseRecord >> '+caseRecord.Type);
            // console.log('in fetch caseRecord2 >> '+caseRecord.Sub_Type__c);
            const result = await getConfigJson({ subtype: caseRecord.Sub_Type__c , type : caseRecord.Type});
            console.log('Json config ==>', result);
            const parsedResult = JSON.parse(result[0].JSON_Value__c);
            console.log('JsonObject after==>', JSON.stringify(parsedResult));
            this.configJson = this.processJsonConfig(parsedResult, caseRecord, caseAnnexRecord);
            // console.log('JsonObject after==>', this.configJson);
            // this.loadingSpinner = false
        } catch (error) {
            // this.loadingSpinner = false
            console.error('Error fetching configuration JSON:', error);
        }
    }
 
    
    processJsonConfig(jsonObject, caseRecord, caseAnnex) {
        // console.log('process !! :: ' + caseAnnex + 'JSON <<<>>> ' + JSON.stringify(caseAnnex));
        
        // First pass to set visibility and required status
        jsonObject.forEach(section => {
            if (section.fields) {
                section.fields.forEach(field => {
                    
                    if (field.objectName === 'Case') {
                        field.isCase = true;
                        field.isCaseAnnex = false;
                        field.rec = this.recordId;
                        this.dynamicObjectName = 'Case';
                        this.dynamicRecordId = this.recordId;
                        field.key = 'Case.' + field.fieldAPIName;
    
                    } else if (field.objectName === 'CaseAnnex__c') {
                        field.isCase = false;
                        field.rec = this.recordAnnexId;
                        field.isCaseAnnex = true;
                        this.dynamicObjectName = 'CaseAnnex__c';
                        this.dynamicRecordId = this.recordAnnexId;
                        field.key = 'CaseAnnex.' + field.fieldAPIName;
                    }
    
                    field.isRequired = field.required;
                    // console.log('field.isRequired >>>>> ' + field.isRequired);
                    // console.log('field Visible >>>>> ' + field.isVisible);
                    if (field.visibilityFilter !== undefined) {
                        field.isVisible = this.evaluateVisibility(field.visibilityFilter, caseRecord, caseAnnex);
                        // console.log('isVisible >>>>> ' + field.isVisible);
                        // console.log('field.visibilityFilter >>>>> ' + JSON.stringify(field.visibilityFilter));
                    }
                });
            }
            section.show = true;
            section.iconName = 'utility:chevrondown';
        });
    
        jsonObject.forEach(section => {
            if (section.fields) {
                let visibleFields = [];
                let nonVisibleFields = [];
        
                // Separate fields into visible and non-visible arrays
                section.fields.forEach(field => {
                    if (field.isVisible) {
                        visibleFields.push(field);
                    } else {
                        nonVisibleFields.push(field);
                    }
                });
        
                if (visibleFields.length === 0) {
                    // If visibleFields array is empty, filter nonVisibleFields to remove isVisible false and isRequired true
                    nonVisibleFields = nonVisibleFields.filter(field => !(field.isVisible === false && field.isRequired === true));
                } else {
                    // If visibleFields array is not empty, filter nonVisibleFields to remove fields with API names in visibleFields
                    let visibleFieldAPISet = new Set(visibleFields.map(field => field.fieldAPIName));
                    nonVisibleFields = nonVisibleFields.filter(field => !visibleFieldAPISet.has(field.fieldAPIName));
                }
        
           
                section.fields = [...visibleFields, ...nonVisibleFields];
                
                // console.log('Updated fields >>> ', JSON.stringify(section.fields));
            }
        });
        

    
        return jsonObject;
    }
    
    evaluateVisibility(condition, caseRecord, caseAnnexRecord) {
        // console.log('evaluateVisibility !! :: '+ JSON.stringify(caseRecord) + 'caseAnnexRecord <<<>>> '+ JSON.stringify(caseAnnexRecord))
        if (typeof condition === 'boolean') {
            return condition;
        } else if (typeof condition === 'object') {
            const { logicalOperator, expressions } = condition;
            // console.log('logic >>'+JSON.stringify(logicalOperator) + 'expressions >> '+JSON.stringify(expressions))
            switch (logicalOperator) {
                case 'and':
                    console.log('AND !!!')
                    return expressions.every(expression => this.evaluateExpression(expression, caseRecord, caseAnnexRecord));
                case 'or':
                    console.log('OR !!!')
                    return expressions.some(expression => this.evaluateExpression(expression, caseRecord, caseAnnexRecord));
                default:
                    console.log('Default !!!')
                    return false;
            }
        }
        return false;
    }

    evaluateExpression(expression, caseRecord, caseAnnexRecord) {
        // console.log('expression >> '+JSON.stringify(expression) + 'caseRecord' + JSON.stringify(caseRecord)+ 'caseAnnexRecord' + JSON.stringify(caseAnnexRecord))
        const { objectName, fieldAPIName, operator, value } = expression;
        // console.log('evaluateExpressionOperator  !!!' + operator)
        // console.log('evaluateExpressionObjectName  !!!' + objectName)
        console.log('evaluateExpressionvalue  !!!' + value)
        // console.log('evaluateExpressionvalue 2 !!!' + fieldAPIName)
        
        if (objectName === 'case') {
            console.log('inCASE!!!')
            this.fieldValue = caseRecord[fieldAPIName];
            console.log('fieldValue1 >> '+this.fieldValue)
        } else if (objectName === 'CaseAnnex__c') {
            console.log('inCASEANNEX!!!')
            this.fieldValue =  caseAnnexRecord[fieldAPIName];
            console.log('fieldValue2 >> '+ this.fieldValue)
        }

        switch (operator) {
            case '=':
                return  this.fieldValue == value;
            case '!=':
                return  this.fieldValue != value;
            case '<':
                return  this.fieldValue < value;
            case '>':
                return  this.fieldValue > value;
            case '<=':
                return  this.fieldValue <= value;
            case '>=':
                return  this.fieldValue >= value;
            default:
                return false;
        }
    }
 
    handleInputFocusOut(event) {
        try {
            console.log('handleInputFocusOut...');
            // console.log('caseRecord before update: ' + JSON.stringify(this.caseRecord));
            // console.log('caseAnnexString before update: ' + JSON.stringify(this.caseAnnexString));
            this.caseRecord = { ...this.caseRecord };
            this.caseAnnexString = { ...this.caseAnnexString };
    
            const fieldName = event.target.dataset.fieldName; 
            const value = event.target.value;
    
          
        
          
            if (fieldName in this.caseRecord) {
                console.log('in case...');
                this.caseRecord[fieldName] = value;
            } else if (fieldName in this.caseAnnexString) {
                console.log('in caseAnnex...');
                this.caseAnnexString[fieldName] = value;
                // this.caseAnnexString = { ...this.caseAnnexString };
                
            } else {
                console.warn(`Field ${fieldName} does not exist in either caseRecord or caseAnnexString.`);
            }
    
            // console.log('caseRecord after update:', this.caseRecord);
            // console.log('caseAnnexString after update:', this.caseAnnexString);
            // console.log(`Field Name: ${fieldName}, Value: ${value}`);
            // console.log('caseRecord after update: ' + JSON.stringify(this.caseRecord));
            // console.log('caseAnnexString after update: ' + JSON.stringify(this.caseAnnexString));
             this.fetchConfigJson(this.caseRecord, this.caseAnnexString )
            //   refreshApex(this.configJson);
        } catch (error) {
            console.error('Error in handleInputFocusOut:', error);
            // Optionally, show a user-friendly error message
        }
    }
    
    handleCloseError(){
        
        this.showValidationError = !this.showValidationError;
    }
    accordionClick() {
        console.log('Accordion Clicked');
        let accordion = this.template.querySelector('.accordion');
        let panel = this.template.querySelector('.panel');
        if (accordion.classList.contains('active') == false) {
            accordion.classList.add('active');
            panel.classList.add('activePanel');
        } else {
            accordion.classList.remove('active');
            panel.classList.remove('activePanel');
        }
    }
   
    handleChangeFormValeurs() {
        console.log('Form Values Changed');
        this.errorFields = [];
        this.caseRecord = { ...this.caseRecord };
        this.caseAnnexString = { ...this.caseAnnexString };
        this.showSectionValeurs = false;
        this.editSectionValeurs = true;
        refreshApex(this.configJson);
   
    }  
    
    handleCancel(){
        console.log('Cancellation Initiated');
        this.errorFields = [];
        this.errorNullRequiredField = false;
        this.showSectionValeurs = true;
        this.editSectionValeurs = false;
        this.showValidationError = false
        this.flowError = false;
        this.validationError = false;
        this.showValidationErrorIcon = false
        this.configJson.forEach(section => {
            section.fields.forEach(field => {
                 
                    field.errorMessage = '';
                    field.returnIcon = false
                    field.errorDesign = ''
                    field.inputErrorDesign = ''
            
            });
        });
    }

    handleToggleSection(event) {
        const sectionName = event.target.dataset.sectionName;
        const sections = this.configJson.map(section => {
            if (section.sectionName === sectionName) {
                section.show = !section.show;
                section.iconName = section.show ? 'utility:chevrondown' : 'utility:chevronright';  
            }
            return section;
        });
        this.configJson = [...sections];
    }
    
    handleReturnOriginalValues() {
        console.log('returning...');
    }

    async handleSave() {
            console.log('Save Button Clicked');
            this.errorNullRequiredField = false;
            // this.errorFields = [];
            try {
                 let records = {
                    Case: {Id : this.recordId},
                    CaseAnnex__c: {Id : this.recordAnnexId}
                };

                this.configJson.forEach((section) => {
                    section.fields
                    .filter(field => !field.readOnly)
                    .forEach((field) => {
                     
                        // console.log('field : ', JSON.stringify(field));
                        // console.log('required Value >> '+ JSON.stringify(field.required));
                         const recordEditField = this.template.querySelector(`[data-field-name="${field.fieldAPIName}"]`);
                     
                        if (recordEditField) {
                            records[field.objectName][field.fieldAPIName] = recordEditField.value;
                            console.log('recordEditField >> '+records[field.objectName][field.fieldAPIName] + '.. Obj >> '+recordEditField.value )
                            if (recordEditField.value == null && field.required == true ||  recordEditField.value == undefined && field.required == true || recordEditField.value == '' && field.required == true  ) {
                               
                                this.errorNullRequiredField = true;
                                this.errorFields.push(field.fieldAPIName)
                            }

                            // for (let objectName in records) {
                            //     if (records.hasOwnProperty(objectName)) {
                            //         const fields = records[objectName];
                            //         for (let fieldName in fields) {
                            //                 if (fields.hasOwnProperty(fieldName) && fields[fieldName] === null  ) {
                            //                     console.log(`Object: ${objectName}, Field: ${fieldName}, Value: ${fields[fieldName]}`);
                            //                     this.errorFields.push(fieldName)
                            //                     console.log('error array fields >> '+this.errorFields);

                            //                 }
                            //         }
                                
                            //     }   
                            // }
                            
                        }
                    });
                });
                console.log('records : ', records);
                if(this.errorNullRequiredField){
                    console.error('error... the null field is required to save the record');
                    this.validationErrorMessage = this.errorFields[0];
                    this.flowError = false;
                    this.validationError = true;
                 
                    this.showValidationError = true;
                    this.showValidationErrorIcon = true;
                    this.showSectionValeurs = false;
                    this.configJson.forEach(section => {
                        section.fields.forEach(field => {
                            if (field.fieldAPIName === this.errorFields[0]) {
                                // field.errorMessage = 'Complete this field.';
                                field.returnIcon = true;
                                field.errorDesign = 'errorBackground';
                                field.inputErrorDesign = 'slds-form-element slds-has-error';
                            }
                        });
                    });
                    this.errorFields = [];
                    this.caseRecord = { ...this.caseRecord };
                    this.caseAnnexString = { ...this.caseAnnexString };
                }
                else{
                    this.updateRecords(records.Case);
                    this.updateRecords(records.CaseAnnex__c);
                    this.showSectionValeurs = true;
                    this.editSectionValeurs = false;
                    this.showValidationError = false
                    this.flowError = false;
                    this.validationError = false;
                    this.showValidationErrorIcon = false
                    this.configJson.forEach(section => {
                        section.fields.forEach(field => {
                            
                                field.errorMessage = '';
                                field.returnIcon = false
                                field.errorDesign = ''
                                field.inputErrorDesign = ''
                        
                        });
                    });
                    this.fetchCaseTypeAndSubtype();
                  
                    this.errorFields = [];
                    this.caseRecord = { ...this.caseRecord };
                    this.caseAnnexString = { ...this.caseAnnexString };
                }
               
                await refreshApex(this.configJson);
            } catch (error) {
                console.error('Error:', error);
                this.showToast('Error updating records', error.body ? error.body.message : 'Unknown error', 'error');
            } finally {
                console.log('finished!!!')
                
            }
        }
 
    updateRecords(recordToInsert) {
        this.loadingSpinner = true;
        let isFirstUpdate = this.isFirstUpdate; 
        updateRecord({ 
            fields: recordToInsert
          })
        .then(() => {
           
   
            
           if (!this.isFirstUpdate) {
            // this.showToast('Success', 'Records updated successfully', 'success');
            this.showSectionValeurs = true;
            this.editSectionValeurs = false;
            
            setTimeout(() => {
                this.loadingSpinner = false;
            }, 2000);
           
        }
      
        this.isFirstUpdate = false;
        })
        .catch((error) => {
            console.log('Handling errors...');
            this.loadingSpinner = false;
        
            if (error.body.output.errors.length === 0) {
                console.log('Handling validation errors...');
                this.validationErrorMessage = '';
                this.flowError = false;
                this.validationError = true;
                const validationErrors = error.body.output.fieldErrors;
                console.log('Validation Errors: ' + JSON.stringify(validationErrors));
                this.showValidationError = true;
                this.showValidationErrorIcon = true;
                this.showSectionValeurs = false;
        
                for (const field in validationErrors) {
                    if (validationErrors.hasOwnProperty(field)) {
                        const errorObject = validationErrors[field][0];
                        const fieldName = errorObject.field;
                        const fieldLabel = errorObject.fieldLabel;
                        const errorMessage = errorObject.message;
                        console.log('Field Label: ', fieldLabel);
                        console.log('Field Name: ', fieldName);
                        console.log('Message: ', errorMessage);
                        this.validationErrorMessage = fieldLabel;
                        console.log(this.validationErrorMessage);
        
                        this.configJson.forEach(section => {
                            section.fields.forEach(field => {
                                if (field.fieldAPIName === fieldName) {
                                    field.errorMessage = errorMessage;
                                    field.returnIcon = true;
                                    field.errorDesign = 'errorBackground';
                                    field.inputErrorDesign = 'slds-form-element slds-has-error';
                                }
                            });
                        });
                    }
                }
            } else if (error.body.output.errors.length > 0) {
                console.log('Handling flow errors...');
                this.validationErrorMessage = '';
                this.flowError = true;
                this.validationError = false;
                const flowErrors = error.body.output.errors[0].message;
                console.log('Flow Errors: ' + JSON.stringify(flowErrors));
                this.showValidationError = true;
                this.showValidationErrorIcon = true;
                this.showSectionValeurs = false;
        
                this.validationErrorMessage = flowErrors;
            } else {
                this.showToast(`Error updating records`, error.body ? error.body.message : 'Unknown error', 'error');
            }
        
            console.error('Error: ' + error);
            console.error('Error Details: ' + JSON.stringify(error));
            this.editSectionValeurs = true;
            this.showSectionValeurs = false;
        });
        
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}