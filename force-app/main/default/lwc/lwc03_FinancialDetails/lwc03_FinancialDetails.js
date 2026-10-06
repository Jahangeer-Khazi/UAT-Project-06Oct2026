import { LightningElement, track, api, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getCaseAnnexFieldsMap from '@salesforce/apex/Lwc03_FinancialDetailsController.getCaseAnnexFieldsMap';
import getCaseFieldsMap from '@salesforce/apex/Lwc03_FinancialDetailsController.getCaseFieldsMap';
import fetchBcrbDetails from '@salesforce/apex/Lwc03_FinancialDetailsController.fetchBcrbDetails';
import reviewBcrbDetails from '@salesforce/apex/Lwc03_FinancialDetailsController.reviewBcrbDetails';
import generateRepaymentSchedule from '@salesforce/apex/Lwc03_FinancialDetailsController.generateRepaymentSchedule';
import getSimulationPaymentList from '@salesforce/apex/Lwc03_FinancialDetailsController.getSimulationPaymentList';
import { publish, MessageContext } from 'lightning/messageService';
import TRIGGER_CHANNEL from '@salesforce/messageChannel/TriggerChannel__c';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import CREDIT_RETAIL_TEAM_MEMBER_FIELD from '@salesforce/schema/User.Credit_retail_team_member__c';

const USER_FIELDS = [CREDIT_RETAIL_TEAM_MEMBER_FIELD];

export default class Lwc03_FinancialDetails extends LightningElement {
    objectLwcIdMap = new Map();
    objectIsVisibledMap = new Map();
  // user fields omar start
    userId = USER_ID;
    creditRetailTeamMember;
    @track isCreditRetailMember = false
    // omar end 
    expressionFields = [];
    onFocusOutVisible;
    @track showSectionValeurs = true;
    @track flowError = false;
    @track validationError = false;
    errorFields = []
    @track show = true;
    @api recordId;
    @track fieldValue;
    disabled = false;
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
    @track isBCRBResponseExist = false;
    @track responseBCRB;
    @track wiredCaseAnnexFields; // Store the wired data

    @track caseRecordOrigin;
    @track caseAnnexMapOrigin;
    validationErrorMessage
    value = 'field.fieldAPIName'
    errorNullRequiredField = false;

    isFirstUpdate = true;

    @api size;
    @track isConfigJsonFetched = false;

    @track configReviewBCRBJson = [];
    @track cx_ln_Product;//values -> "Secured" ; "Unsecured"
    @track cc_Business_Nature_Type;//values -> "New Loan/Finance"; "Buyout Loan/Finance"
    @track cx_ln_credit_approval_result;//#CH01
    @track cx_DBR_Sheet_ReadOnlyChecK;//#CH02

    @track cx_ln_Total_no_of_Loans;
    @track cx_ln_No_of_Arrears_with_gov_loans;
    @track cx_ln_No_of_Arrears_without_gov_loans;
    @track requestedLiabilitiesSelectedRows = []; // Store the selected rows
    @track requestedLiabilitiesvalidationMessage = ''; // Store validation message
    @track disableGenerateScheduleButton = true;
    @track isButtonScheduleClicked = false;
    @track buttonGenerateScheduleLabel;
    getScheduleRetries = 1;
    

    // Wire up the LMS context so we can publish
    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.loadingSpinner = true;
    }
    
    // omar start 
     @wire(getRecord, { recordId: USER_ID, fields: USER_FIELDS })
        wiredUser({ error, data }) {
            if (data) {
                this.creditRetailTeamMember = data.fields.Credit_retail_team_member__c.value;
                if(this.creditRetailTeamMember){
                  this.isCreditRetailMember = true;
                }
            } else if (error) {
                console.error('Error fetching user fields:', error);
            }
        }
    // omar end 
    
    @wire(getCaseFieldsMap, { recordId: '$recordId' })
    wiredGetCaseFields(result) {
        this.wiredCaseFields = result;
        if (result.data) {
            const caseRecord = result.data;
            //this.recordId = caseRecord.id;
            this.caseRecord = caseRecord;
            this.caseRecordOrigin = caseRecord;
            this.callFetchConfigJson();
        } else if (result.error) {
            console.error('Error fetching case fields:', result.error);
        }
    }

    @wire(getCaseAnnexFieldsMap, { recordId: '$recordId' })
    wiredGetCaseAnnexFields(result) {
        this.wiredCaseAnnexFields = result;
        if (result.data) {
            if(result.data[0].cx_ln_bcrb_api_response__c != null ){
              this.isBCRBResponseExist = true;
              console.log("wiredCaseAnnexFields --> this.isBCRBResponseExist --> "+this.isBCRBResponseExist);
              this.responseBCRB = result.data[0].cx_ln_bcrb_api_response__c;
            }

            this.cx_ln_credit_approval_result = result.data[0].cx_ln_credit_approval_result__c;//#CH01

            if(result.data[0].cx_ln_isschedulegenerated__c == false && this.cx_ln_credit_approval_result != 'Approve'){//#CH01
              this.disableGenerateScheduleButton = false;
            }
            this.recordAnnexId = result.data[0].id;
            this.caseAnnexMap = result.data[0];
            this.caseAnnexMapOrigin = result.data[0];
            this.cx_ln_Product = result.data[0].cx_ln_product__c;
            this.cx_DBR_Sheet_ReadOnlyCheck = result.data[0].cx_dbr_sheet_readonlycheck__c;//#CH02
            this.cx_ln_Total_no_of_Loans = result.data[0].cx_ln_total_no_of_loans__c;
            this.cx_ln_No_of_Arrears_with_gov_loans = result.data[0].cx_ln_no_of_arrears_with_gov_loans__c;
            this.cx_ln_No_of_Arrears_without_gov_loans = result.data[0].cx_ln_no_of_arrears_without_gov_loans__c;
            this.cc_Business_Nature_Type = result.data[0].cx_ln_business_nature_type__c;
            this.callFetchConfigJson();
            //this.fetchConfigJson();
        } else if (result.error) {
            console.error('Error fetching case annex fields:', result.error);
        }
    }

    callFetchConfigJson() {
        if (!this.isConfigJsonFetched && this.caseRecord && this.caseAnnexMap) {
            this.isConfigJsonFetched = true;
            this.fetchConfigJson();
        }
    }

    // Fetch configuration JSON from metadata
    async fetchConfigJson() {
      try {
        if(this.cx_ln_Product == 'Secured'){
          this.buttonGenerateScheduleLabel = "Schedule Generation/Regeneration";
        }else{
          this.buttonGenerateScheduleLabel = "DBR Schedule Generation/Regeneration";
        }

        if(this.cx_ln_Product == 'Secured' && this.cc_Business_Nature_Type == 'New Loan/Finance'){
          console.log('Senario >>> Secured and "New Loan/Finance" ')
        }
        else if(this.cx_ln_Product == 'Secured' && this.cc_Business_Nature_Type == 'Buyout Loan/Finance'){
          console.log('Senario >>> Secured and "Buyout Loan/Finance" ')
        }
        else if(this.cx_ln_Product == 'Unsecured' && this.cc_Business_Nature_Type == 'New Loan/Finance'){
          console.log('Senario >>> Unsecured and "New Loan/Finance" ')
        }
        else if(this.cx_ln_Product == 'Unsecured' && this.cc_Business_Nature_Type == 'Buyout Loan/Finance'){
          console.log('Senario >>> Unsecured and "Buyout Loan/Finance" ')
        }

        let jsonData = [];
        //commun section : "Requested Application Details"
        jsonData.push(
          {
            "sectionName": "Requested Application Details",
            "fields": [
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Requested_Loan_Finance_Amount__c",
                "readOnly": true,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Monthly_Instalment__c",
                "readOnly": true,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Requested_Duration_Months__c",
                "readOnly": true,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Requested_Interest_Rate__c",
                "readOnly": true,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Requested_Insurance_Amount__c",
                "readOnly": true,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Requested_Processing_Fees__c",
                "readOnly": true,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Requested_Vat_Processing_Fees__c",
                "readOnly": true,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Requested_First_Payment_Date__c",
                "readOnly": true,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Requested_Maturity_Date__c",
                "readOnly": true,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Requested_Cash_in_Hand__c",
                "readOnly": true,
                "required": false,
                "visibilityFilter": true
              }
            ]
          }
        );

        //display "Income Details"&&"Income Deductions" sections only in unsecured senarios
        if(this.cx_ln_Product == 'Unsecured'){
          jsonData.push(
            {
              "sectionName": "Income Details",
              "fields": [
                {
                  "objectName": "CaseAnnex__c",
                  "fieldAPIName": "cx_ln_Basic_Salary__c",
                  "readOnly": false,
                  "required": true,
                  "visibilityFilter": true
                },
                {
                  "objectName": "CaseAnnex__c",
                  "fieldAPIName": "cx_ln_Fixed_Allowances__c",
                  "readOnly": false,
                  "required": true,
                  "visibilityFilter": true
                },
                {
                  "objectName": "CaseAnnex__c",
                  "fieldAPIName": "cx_ln_Variable_Allowances__c",
                  "readOnly": false,
                  "required": true,
                  "visibilityFilter": true
                },
                {
                  "objectName": "CaseAnnex__c",
                  "fieldAPIName": "cx_ln_Business_Income__c",
                  "readOnly": false,
                  "required": true,
                  "visibilityFilter": true
                },
                {
                  "objectName": "CaseAnnex__c",
                  "fieldAPIName": "cx_ln_Total_Approved_Income__c",//Basic Salary + Fixed Allowances
                  "readOnly": true,
                  "isCalculated": true,
                  "required": true,
                  "visibilityFilter": true
                },
                {
                  "objectName": "CaseAnnex__c",
                  "fieldAPIName": "cx_ln_Gross_Income__c",//Total Approved Income + Variable Allowances
                  "readOnly": true,
                  "isCalculated": true,
                  "required": true,
                  "visibilityFilter": true
                }/*,
                {
                  "objectName": "CaseAnnex__c",
                  "fieldAPIName": "cx_ln_Net_Income__c",//Gross Income - Total Deductions
                  "readOnly": true,
                  "isCalculated": true,
                  "required": true,
                  "visibilityFilter": true
                }*/
              ],
              "hasParentTitle": true,
              "titleSection": "Financial Information :",
              "subSectionClass" : "subSectionClass"
            },
            {
              "sectionName": "Income Deductions",
              "fields": [
                {
                  "objectName": "CaseAnnex__c",
                  "fieldAPIName": "cx_ln_InternalDeductions__c",
                  "readOnly": false,
                  "required": false,
                  "visibilityFilter": true
                }
              ],
              "subSectionClass" : "subSectionClass"
            }
          );
        }

        //commun sections : "BCRB Details" && "Current Loans Statistics" && "Main CRB Details"
        jsonData.push(
          {
            "sectionName": "BCRB Details",
            "fields": [
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_TotalConsumerLoansInstallments__c",//new field added
                "readOnly": false,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_TotalMortgageLoansInstallments__c",//new field added
                "readOnly": false,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_TotalCreditCardsInstallments__c",//new field added 
                "readOnly": true,
                "required": false,
                "isCalculated": true,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Total_CCs_Installments_without_ila__c",//new field added
                "readOnly": false,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Total_IlaCreditCardsInstallments__c",
                "readOnly": false,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_TotalGovernmentLoansInstallments__c",//new field added
                "readOnly": false,
                "required": false,
                "visibilityFilter": true
              },
              {
                  "objectName": "CaseAnnex__c",
                  "fieldAPIName": "cx_ln_TotalOverdraftInstallments__c",//new field added
                  "readOnly": false,
                  "required": false,
                  "visibilityFilter": true
              },
              {
                  "objectName": "CaseAnnex__c",
                  "fieldAPIName": "cx_ln_TotalLeverageLoanInstallments__c",//new field added
                  "readOnly": false,
                  "required": false,
                  "visibilityFilter": true
              },
              {
                  "objectName": "CaseAnnex__c",
                  "fieldAPIName": "cx_ln_TotalBuyNowPayLaterInstallments__c",//new field added
                  "readOnly": false,
                  "required": false,
                  "visibilityFilter": true
              },
              {
                  "objectName": "CaseAnnex__c",
                  "fieldAPIName": "cx_ln_CurrentLoansLimit__c",//new field added
                  "readOnly": false,
                  "required": false,
                  "visibilityFilter": true
              },
              {
                  "objectName": "CaseAnnex__c",
                  "fieldAPIName": "cx_ln_TotalCurrentObligations__c",
                  "readOnly": true,
                  "required": false,
                  "isCalculated": true,
                  "visibilityFilter": true
              },
              {
                  "objectName": "CaseAnnex__c",
                  "fieldAPIName": "cx_ln_Total_Obligations__c",
                  "readOnly": true,
                  "required": false,
                  "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Other_Deductions__c",
                "readOnly": false,
                "required": false,
                "visibilityFilter": (this.cx_ln_Product == 'Unsecured') ?true:false
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Total_Deductions__c",
                "readOnly": true,
                "isCalculated": true,
                "required": false,
                "visibilityFilter": (this.cx_ln_Product == 'Unsecured') ?true:false
              }
              
            ]
          },
          {
            "sectionName": "Current Loans Statistics",
            "fields": [ //all new field added
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_No_of_Corporate_Accounts__c",
                "readOnly": false,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_No_of_Non_Owner_Accounts__c",
                "readOnly": false,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_No_of_non_normal_accounts__c",
                "readOnly": false,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_No_of_Credit_Cards_without_Ila__c",
                "readOnly": false,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_No_of_Ila_Credit_Cards__c",
                "readOnly": false,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_NoPenaltiesContraventions_accounts__c",
                "readOnly": false,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_No_of_Billing_Accounts__c",
                "readOnly": false,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Total_no_of_Loans__c",
                "readOnly": false,
                "required": false,
                //"isHighlighted":(this.cx_ln_Total_no_of_Loans>0)?true:false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_No_of_Arrears_with_gov_loans__c",
                "isHighlighted":(this.cx_ln_No_of_Arrears_with_gov_loans>0)?true:false,
                "readOnly": false,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_No_of_Arrears_without_gov_loans__c",
                "isHighlighted":(this.cx_ln_No_of_Arrears_without_gov_loans>0)?true:false,
                "readOnly": false,
                "required": false,
                "visibilityFilter": true
              },
            ]
          },
          {
            "sectionName": "Main CRB Details",
            "fields": [
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Current_Customer_Status__c",
                "readOnly": false,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Current_DBR__c",
                "readOnly": true,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Total_Credit_Exposure__c",
                "readOnly": false,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Credit_Bureau_Score__c",
                "readOnly": false,
                "required": false,
                "visibilityFilter": true
              },
              {
                  "objectName": "CaseAnnex__c",
                  "fieldAPIName": "cx_ln_Credit_Bureau_Risk_Rating__c",
                  "readOnly": false,
                  "required": false,
                  "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Current_PSI_Transaction_No__c",
                "readOnly": true,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Current_PSI_Expiry_Date__c",
                "readOnly": true,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Auto_Decisioning_Result__c",
                "readOnly": true,
                "required": false,
                "visibilityFilter": true
              }
            ]
          }
          
        );

        //display "Liabilities Details" Section in case of new Buyout 
        if(this.cc_Business_Nature_Type == 'Buyout Loan/Finance'){
          /*jsonData.push(
            {

            }
          );*/
        }

        //commun section : "DBR Sheet"
        jsonData.push(
          {
            "sectionName": "DBR Sheet",
            "isDbSheet": true,
            "fields": [
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Approved_Loan_Amount__c",
                "readOnly": (this.cx_DBR_Sheet_ReadOnlyCheck == true)? true : false,//#CH02
                "required": (this.cx_DBR_Sheet_ReadOnlyCheck == true)? false : true,//#CH02
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Approved_Duration_Months__c",
                "readOnly": (this.cx_DBR_Sheet_ReadOnlyCheck == true)? true : false,//#CH02
                "required": (this.cx_DBR_Sheet_ReadOnlyCheck == true)? false : true,//#CH02
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_ApprovedInterestProfitRateReducing__c",
                "readOnly": (this.cx_DBR_Sheet_ReadOnlyCheck == true)? true : false,//#CH02
                "required": (this.cx_DBR_Sheet_ReadOnlyCheck == true)? false : true,//#CH02
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Approved_Installment_Amount__c",
                "readOnly": true,
                "isCalculated": true,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Approved_Maturity_Date__c",
                //"isCalculated": true,//will updated after calling get list payment schedule api
                "readOnly": true,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Approved_Insurance_Premium__c",
                "readOnly": (this.cx_DBR_Sheet_ReadOnlyCheck == true)? true : false,//#CH02
                "required": (this.cx_DBR_Sheet_ReadOnlyCheck == true)? false : true,//#CH02
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Approved_Insurance_Rate__c",
                "readOnly": true,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Approved_Insurance_Amount__c",
                //"isCalculated": true,//will updated after calling get list payment schedule api
                "readOnly": true,
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Approved_insurance__c",
                "readOnly": (this.cx_DBR_Sheet_ReadOnlyCheck == true)? true : false,//#CH02
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Approved_PreInsuranceStatus__c",
                "readOnly": (this.cx_DBR_Sheet_ReadOnlyCheck == true)? true : false,//#CH02
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Approved_First_installment_date__c",
                "readOnly": (this.cx_DBR_Sheet_ReadOnlyCheck == true)? true : false,//#CH02
                "required": (this.cx_DBR_Sheet_ReadOnlyCheck == true)? false : true,//#CH02
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_ApprovedProcessing_Fee_Type__c",
                "readOnly": true,
                "required": false,
                "visibilityFilter": true
              },
              {
                  "objectName": "CaseAnnex__c",
                  "fieldAPIName": "cx_ln_Approved_Cash_in_Hand__c",
                  "readOnly": true,
                  "required": false,
                  "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Final_DBR__c",
                "readOnly": true,
                "required": false,
                "visibilityFilter": (this.cx_ln_Product == 'Secured')? false : true
              },
              {
                  "objectName": "CaseAnnex__c",
                  "fieldAPIName": "cx_ln_APR__c",
                  //"isCalculated": true,//will updated after calling get list payment schedule api
                  "readOnly": true,
                  "required": false,
                  "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_core_product_name__c",
                "readOnly": true,
                "required": true,
                "visibilityFilter": true
              }
              ,
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Approved_Credit_Limit__c",
                "readOnly": (this.cx_DBR_Sheet_ReadOnlyCheck == true)? true : false,//#CH02
                "required": false,
                "visibilityFilter": true
              },
              {
                "objectName": "CaseAnnex__c",
                "fieldAPIName": "cx_ln_Approved_Requested_Card_Type__c",
                "readOnly": (this.cx_DBR_Sheet_ReadOnlyCheck == true)? true : false,//#CH02
                "required": false,
                "visibilityFilter": true
              }
            ]
          }
        )
        
        
        this.configJson = this.processJsonConfig(jsonData, this.caseRecord, this.caseAnnexMap);
        
        //display Review section for all 4 scenarios
        if(this.responseBCRB != null){
          this.configReviewBCRBJson = this.displayReviewSection(this.responseBCRB);
        }
        if (this.configJson && this.caseRecord && this.caseAnnexMap) {
            console.log('caseAnnexMap22 >>> ' + this.caseAnnexMap)
            this.dataLoaded = true;
            this.loadingSpinner = false;
        }
      } catch (error) {
        console.error('Error fetching configuration JSON:', error);
      }

    }

    // Process JSON configuration data
    processJsonConfig(jsonObject, caseRecord, caseAnnex) {
        let i = 0;
        jsonObject.forEach(section => {
            if (!section.fields) return;

            section.fields.forEach(field => {
                i += 1;
                const baseConfig = this.createBaseConfig(field, i);
                Object.assign(field, baseConfig);

                this.dynamicObjectName = field.objectName;
                this.dynamicRecordId = baseConfig.rec;

                if (field.visibilityFilter !== undefined) {
                    this.updateVisibilityConfig(field);
                    field.isVisible = this.evaluateVisibility(field.visibilityFilter, caseRecord, caseAnnex);

                }
            });
            // Start CH01
            // if (section.visibilityFilter !== undefined) {
            //     section.isVisible = this.evaluateVisibility(section.visibilityFilter, caseRecord, caseAnnex);

            // }else{
            //     section.isVisible = true;
            // }
            // End CH01
            section.show = true;
            section.iconName = 'utility:chevrondown';
        });

        return jsonObject;
    }

    // Create base configuration for each field
    createBaseConfig(field, index) {
        return {
            isCase: field.objectName === 'Case',
            isCaseAnnex: field.objectName === 'CaseAnnex__c',
            rec: field.objectName === 'Case' ? this.recordId : this.recordAnnexId,
            key: `${field.objectName}.${field.fieldAPIName}`,
            lwcId: `${field.objectName}-${field.fieldAPIName}-${index}`,
            isRequired: field.required,
            isVisible: true
        };
    }
    // Update visibility configuration for a field
    updateVisibilityConfig(field) {
        const { key, lwcId, visibilityFilter } = field;
        this.objectLwcIdMap.set(key, lwcId);
        if (typeof visibilityFilter !== 'boolean') {
            this.expressionFields = visibilityFilter.expressions.map(expr => expr.fieldAPIName);
            this.objectIsVisibledMap.set(field, [...this.expressionFields]);

        }
    }
    // Evaluate visibility of a field based on conditions
    evaluateVisibility(condition, caseRecord, caseAnnexRecord) {
        if (typeof condition === 'boolean') {
            return condition;
        } else if (typeof condition === 'object') {
            const { logicalOperator, expressions } = condition;
            const evaluate = expr => this.evaluateExpression(expr, caseRecord, caseAnnexRecord);

            switch (logicalOperator) {
                case 'and':
                    return expressions.every(evaluate);
                case 'or':
                    return expressions.some(evaluate);
                default:
                    return false;
            }
        }
        return false;
    }
    // Evaluate a single expression to determine visibility
    evaluateExpression(expression, caseRecord, caseAnnexRecord) {
        const { objectName, fieldAPIName, operator, value } = expression;
        const lowerFieldName = fieldAPIName.toLowerCase();
        const fieldValue = objectName === 'case' ? caseRecord[lowerFieldName] : caseAnnexRecord[lowerFieldName];

        switch (operator) {
            case '=':
                return fieldValue == value;
            case '!=':
                return fieldValue != value;
            case '<':
                return fieldValue < value;
            case '>':
                return fieldValue > value;
            case '<=':
                return fieldValue <= value;
            case '>=':
                return fieldValue >= value;
            default:
                return false;
        }
    }
    // Handle focus out event for input fields
    handleInputFocusOut(event) {
        try {
            console.log('handleInputFocusOut event triggeredTest');

            const fieldName = event.target.dataset.fieldName;
            const fieldObjName = event.target.dataset.objectName;
            const value = event.target.value;
            const lowerFieldName = fieldName.toLowerCase();
            const lowerfieldObjName = fieldObjName.toLowerCase();
            let fieldVisibilityFilter = [];
            let fieldFound = false;

            //Logique handling of the "Income Details" section:
            if ((fieldName == 'cx_ln_Basic_Salary__c' || fieldName == 'cx_ln_Fixed_Allowances__c' || fieldName == 'cx_ln_Variable_Allowances__c' || fieldName == 'cx_ln_InternalDeductions__c' || fieldName == 'cx_ln_Other_Deductions__c'  || fieldName == 'cx_ln_Business_Income__c' ) && fieldObjName == 'CaseAnnex__c') {
                
                const cx_ln_Basic_Salary = this.template.querySelector(`[data-field-name="cx_ln_Basic_Salary__c"][data-object-name="CaseAnnex__c"]`);
                const cx_ln_Business_Income = this.template.querySelector(`[data-field-name="cx_ln_Business_Income__c"][data-object-name="CaseAnnex__c"]`);
                const cx_ln_Fixed_Allowances = this.template.querySelector(`[data-field-name="cx_ln_Fixed_Allowances__c"][data-object-name="CaseAnnex__c"]`);
                const cx_ln_Variable_Allowances = this.template.querySelector(`[data-field-name="cx_ln_Variable_Allowances__c"][data-object-name="CaseAnnex__c"]`);
                const cx_ln_InternalDeductions = this.template.querySelector(`[data-field-name="cx_ln_InternalDeductions__c"][data-object-name="CaseAnnex__c"]`);
                const cx_ln_Other_Deductions = this.template.querySelector(`[data-field-name="cx_ln_Other_Deductions__c"][data-object-name="CaseAnnex__c"]`);

                
                // Safely get the value and ensure it's a number
                let basicSalaryValue = parseFloat(cx_ln_Basic_Salary?.value) || 0; // Default to 0 if the value is invalid
                let cx_ln_Business_IncomeValue = parseFloat(cx_ln_Business_Income?.value) || 0; // Default to 0 if the value is invalid
                let fixedAllowancesValue = parseFloat(cx_ln_Fixed_Allowances?.value) || 0; // Default to 0 if the value is invalid
                let cx_ln_Variable_AllowancesValue = parseFloat(cx_ln_Variable_Allowances?.value) || 0; // Default to 0 if the value is invalid
                let cx_ln_InternalDeductionsValue = parseFloat(cx_ln_InternalDeductions?.value) || 0; // Default to 0 if the value is invalid
                let cx_ln_Other_DeductionsValue = parseFloat(cx_ln_Other_Deductions?.value) || 0; // Default to 0 if the value is invalid
                
                console.log('cx_ln_Basic_Salary__c --->', basicSalaryValue);
                console.log('cx_ln_Business_Income__c --->', cx_ln_Business_IncomeValue);
                console.log('cx_ln_Fixed_Allowances__c --->', fixedAllowancesValue);
                console.log('cx_ln_Variable_Allowances__c --->', cx_ln_Variable_AllowancesValue);
                console.log('cx_ln_InternalDeductions__c --->', cx_ln_InternalDeductionsValue);
                console.log('cx_ln_Other_Deductions__c --->', cx_ln_Other_DeductionsValue);
                
                // Calculate the total, making sure the values are numeric
                let ttl = basicSalaryValue + fixedAllowancesValue + cx_ln_Variable_AllowancesValue + cx_ln_Business_IncomeValue;
                
                const cx_ln_Total_Approved_Income = this.template.querySelector(`[data-field-name="cx_ln_Total_Approved_Income__c"][data-object-name="CaseAnnex__c"]`);
                if (cx_ln_Total_Approved_Income) {
                    // Set the value of "Total Approved Income"
                    cx_ln_Total_Approved_Income.value = ttl;
                }

                const cx_ln_Gross_Income = this.template.querySelector(`[data-field-name="cx_ln_Gross_Income__c"][data-object-name="CaseAnnex__c"]`);
                if (cx_ln_Gross_Income) {
                    // Set the value of "Gross Income"
                    cx_ln_Gross_Income.value = ttl;
                }
                
                const cx_ln_Total_Deductions = this.template.querySelector(`[data-field-name="cx_ln_Total_Deductions__c"][data-object-name="CaseAnnex__c"]`);
                if (cx_ln_Total_Deductions) {
                  // Set the value of "cx_ln_Total_Deductions"
                  cx_ln_Total_Deductions.value = cx_ln_InternalDeductionsValue + cx_ln_Other_DeductionsValue;
                }

                let cx_ln_Total_DeductionsValue = parseFloat(cx_ln_Total_Deductions?.value) || 0; // Default to 0 if the value is invalid
                /*const cx_ln_Net_Income = this.template.querySelector(`[data-field-name="cx_ln_Net_Income__c"][data-object-name="CaseAnnex__c"]`);
                if (cx_ln_Net_Income) {
                    // Set the value of "Net Income"
                    cx_ln_Net_Income.value = ttl;
                }*/
            }
            
            //#CH01
            if(this.cx_ln_credit_approval_result != 'Approve'){
              //DBR Sheet Dynamic Behavior
              if(fieldName == 'cx_ln_Approved_Loan_Amount__c' || fieldName == 'cx_ln_Approved_Duration_Months__c' || fieldName == 'cx_ln_ApprovedInterestProfitRateReducing__c' ||
                 fieldName == 'cx_ln_Approved_Insurance_Premium__c' || fieldName == 'cx_ln_Approved_First_installment_date__c' || fieldName == 'cx_ln_ApprovedProcessing_Fee_Type__c'){
                //const cx_ln_Approved_Loan_Amount = this.template.querySelector(`[data-field-name="cx_ln_Approved_Loan_Amount__c"][data-object-name="CaseAnnex__c"]`);
                //let cx_ln_Approved_Loan_AmountValue = parseFloat(cx_ln_Approved_Loan_Amount?.value) || 0; // Default to 0 if the value is invalid
                this.disableGenerateScheduleButton = false;
                // set some values to blank
                const cx_ln_Approved_Installment_Amount = this.template.querySelector(`[data-field-name="cx_ln_Approved_Installment_Amount__c"][data-object-name="CaseAnnex__c"]`);
                if (cx_ln_Approved_Installment_Amount) {
                  // Set the value of "Approved Installment Amount"
                  cx_ln_Approved_Installment_Amount.value = null;
                }
                
                //set blank "cx_ln_Final_DBR__c"
                const cx_ln_Final_DBR = this.template.querySelector(`[data-field-name="cx_ln_Final_DBR__c"][data-object-name="CaseAnnex__c"]`);
                if (cx_ln_Final_DBR) {
                  // Set the value of "Approved Installment Amount"
                  cx_ln_Final_DBR.value = null;
                }
                
                if(fieldName == 'cx_ln_Approved_Duration_Months__c'){
                  //set blank "cx_ln_Approved_Maturity_Date__c"  
                  const cx_ln_Approved_Maturity_Date = this.template.querySelector(`[data-field-name="cx_ln_Approved_Maturity_Date__c"][data-object-name="CaseAnnex__c"]`);
                  if (cx_ln_Approved_Maturity_Date) {
                    cx_ln_Approved_Maturity_Date.value = null;
                  }
                }
                  
              }
            }

            //logic handling bcrb Details section
            if ((fieldName == 'cx_ln_TotalConsumerLoansInstallments__c' || fieldName == 'cx_ln_TotalMortgageLoansInstallments__c' || fieldName == 'cx_ln_Total_CCs_Installments_without_ila__c' || fieldName == 'cx_ln_Total_IlaCreditCardsInstallments__c' || 
                fieldName == 'cx_ln_TotalGovernmentLoansInstallments__c' || fieldName == 'cx_ln_TotalOverdraftInstallments__c' || fieldName == 'cx_ln_TotalLeverageLoanInstallments__c' || fieldName == 'cx_ln_TotalBuyNowPayLaterInstallments__c' ) 
                && fieldObjName == 'CaseAnnex__c'
            ){
              
              const cx_ln_TotalConsumerLoansInstallments = this.template.querySelector(`[data-field-name="cx_ln_TotalConsumerLoansInstallments__c"][data-object-name="CaseAnnex__c"]`);
              const cx_ln_TotalMortgageLoansInstallments = this.template.querySelector(`[data-field-name="cx_ln_TotalMortgageLoansInstallments__c"][data-object-name="CaseAnnex__c"]`);
              const cx_ln_Total_CCs_Installments_without_ila = this.template.querySelector(`[data-field-name="cx_ln_Total_CCs_Installments_without_ila__c"][data-object-name="CaseAnnex__c"]`);
              const cx_ln_Total_IlaCreditCardsInstallments = this.template.querySelector(`[data-field-name="cx_ln_Total_IlaCreditCardsInstallments__c"][data-object-name="CaseAnnex__c"]`);
              const cx_ln_TotalGovernmentLoansInstallments = this.template.querySelector(`[data-field-name="cx_ln_TotalGovernmentLoansInstallments__c"][data-object-name="CaseAnnex__c"]`);
              const cx_ln_TotalOverdraftInstallments = this.template.querySelector(`[data-field-name="cx_ln_TotalOverdraftInstallments__c"][data-object-name="CaseAnnex__c"]`);
              const cx_ln_TotalLeverageLoanInstallments = this.template.querySelector(`[data-field-name="cx_ln_TotalLeverageLoanInstallments__c"][data-object-name="CaseAnnex__c"]`);
              const cx_ln_TotalBuyNowPayLaterInstallments = this.template.querySelector(`[data-field-name="cx_ln_TotalBuyNowPayLaterInstallments__c"][data-object-name="CaseAnnex__c"]`);

              
              // Safely get the value and ensure it's a number
              let cx_ln_TotalConsumerLoansInstallmentsValue = parseFloat(cx_ln_TotalConsumerLoansInstallments?.value) || 0; // Default to 0 if the value is invalid
              let cx_ln_TotalMortgageLoansInstallmentsValue = parseFloat(cx_ln_TotalMortgageLoansInstallments?.value) || 0; // Default to 0 if the value is invalid
              let cx_ln_Total_CCs_Installments_without_ilaValue = parseFloat(cx_ln_Total_CCs_Installments_without_ila?.value) || 0; // Default to 0 if the value is invalid
              let cx_ln_Total_IlaCreditCardsInstallmentsValue = parseFloat(cx_ln_Total_IlaCreditCardsInstallments?.value) || 0; // Default to 0 if the value is invalid
              let cx_ln_TotalGovernmentLoansInstallmentsValue = parseFloat(cx_ln_TotalGovernmentLoansInstallments?.value) || 0; // Default to 0 if the value is invalid
              let cx_ln_TotalOverdraftInstallmentsValue = parseFloat(cx_ln_TotalOverdraftInstallments?.value) || 0; // Default to 0 if the value is invalid
              let cx_ln_TotalLeverageLoanInstallmentsValue = parseFloat(cx_ln_TotalLeverageLoanInstallments?.value) || 0; // Default to 0 if the value is invalid
              let cx_ln_TotalBuyNowPayLaterInstallmentsValue = parseFloat(cx_ln_TotalBuyNowPayLaterInstallments?.value) || 0; // Default to 0 if the value is invalid
              
              console.log('cx_ln_TotalConsumerLoansInstallments__c --->', cx_ln_TotalConsumerLoansInstallmentsValue);
              console.log('cx_ln_TotalMortgageLoansInstallments__c --->', cx_ln_TotalMortgageLoansInstallmentsValue);
              console.log('cx_ln_Total_CCs_Installments_without_ila__c --->', cx_ln_Total_CCs_Installments_without_ilaValue);
              console.log('cx_ln_Total_IlaCreditCardsInstallments__c --->', cx_ln_Total_IlaCreditCardsInstallmentsValue);
              console.log('cx_ln_TotalGovernmentLoansInstallments__c --->', cx_ln_TotalGovernmentLoansInstallmentsValue);
              console.log('cx_ln_TotalOverdraftInstallments__c --->', cx_ln_TotalOverdraftInstallmentsValue);
              console.log('cx_ln_TotalLeverageLoanInstallments__c --->', cx_ln_TotalLeverageLoanInstallmentsValue);
              console.log('cx_ln_TotalBuyNowPayLaterInstallments__c --->', cx_ln_TotalBuyNowPayLaterInstallmentsValue);
              
              // Calculate the total, making sure the values are numeric
              let ttlBcrb = cx_ln_TotalConsumerLoansInstallmentsValue + cx_ln_TotalMortgageLoansInstallmentsValue + cx_ln_Total_CCs_Installments_without_ilaValue+cx_ln_Total_IlaCreditCardsInstallmentsValue+cx_ln_TotalGovernmentLoansInstallmentsValue
                        +cx_ln_TotalOverdraftInstallmentsValue+cx_ln_TotalLeverageLoanInstallmentsValue+cx_ln_TotalBuyNowPayLaterInstallmentsValue; 
              
              const cx_ln_TotalCurrentObligations = this.template.querySelector(`[data-field-name="cx_ln_TotalCurrentObligations__c"][data-object-name="CaseAnnex__c"]`);
              if (cx_ln_TotalCurrentObligations) {
                // Set the value of "Total Approved Income"
                cx_ln_TotalCurrentObligations.value = ttlBcrb;
              }
              const cx_ln_TotalCreditCardsInstallments = this.template.querySelector(`[data-field-name="cx_ln_TotalCreditCardsInstallments__c"][data-object-name="CaseAnnex__c"]`);
              if (cx_ln_TotalCurrentObligations) {
                // Set the value of "Total Approved Income"
                cx_ln_TotalCreditCardsInstallments.value = cx_ln_Total_CCs_Installments_without_ilaValue + cx_ln_Total_IlaCreditCardsInstallmentsValue;
              }
            }

            // console.log('Initial objectIsVisibledMap:', this.objectIsVisibledMap);

            // Find the filters that contain the fieldName
            this.objectIsVisibledMap.forEach((expressionFieldsArray, filter) => {
                if (expressionFieldsArray.includes(fieldName)) {
                    fieldFound = true;
                    fieldVisibilityFilter.push(filter);
                    // console.log('Field found in filter:', filter);
                }
            });

            if (!fieldFound) {
                console.warn(`Field ${fieldName} not found in any filter.`);
                return;
            }

            // console.log(`Field ${fieldName} is in one of the expressionFields arrays in objectIsVisibledMap.`);

            // Update the appropriate object based on lowerFieldName
            if ((lowerFieldName in this.caseAnnexMap) && lowerfieldObjName == 'caseannex__c') {
                this.caseAnnexMap[lowerFieldName] = value;
            } else {
                console.warn(`Field ${lowerFieldName} does not exist in either caseRecord or caseAnnexMap.`);
                return;
            }

            this.caseAnnexMap = { ...this.caseAnnexMap };

            // Evaluate visibility for each filter
            fieldVisibilityFilter.forEach(filter => {
                const isVisible = this.evaluateVisibility(filter.visibilityFilter, this.caseRecord, this.caseAnnexMap);
                // console.log('Visibility for filter', filter, ':', isVisible);

                // Update visibility in configJson
                this.configJson.forEach(section => {
                    
                    if (section.fields) {
                        section.fields.forEach(field => {
                            if (field.lwcId === filter.lwcId) {
                                field.isVisible = isVisible;
                            }
                        });
                    }
                });
            });


            this.caseAnnexMap = { ...this.caseAnnexMap };

        } catch (error) {
            console.error('Error in handleInputFocusOut:', error);
        }
    }

    handleCloseError() {

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
        console.log('Form Values Changed'  );
        refreshApex(this.wiredCaseAnnexFields);
        this.errorFields = [];
        this.caseAnnexMap = { ...this.caseAnnexMap };
        this.showSectionValeurs = false;
        this.editSectionValeurs = true;
                
    }

    handleCancel() {
        console.log('Cancellation Initiated');
        this.errorFields = [];
        this.errorNullRequiredField = false;
        this.showSectionValeurs = true;
        this.editSectionValeurs = false;
        this.showValidationError = false
        this.flowError = false;
        this.validationError = false;
        this.showValidationErrorIcon = false
        this.isButtonScheduleClicked = false;
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
        // omar  start
        event.preventDefault();
        event.stopPropagation();
        // omar end
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

    
    handleToggleSection1(event) {
        // omar  start
        event.preventDefault();
        event.stopPropagation();
        // omar end
        const sectionName = event.target.dataset.sectionName;
        const sections = this.configReviewBCRBJson.map(section => {
            if (section.sectionName === sectionName) {
                section.show = !section.show;
                section.iconName = section.show ? 'utility:chevrondown' : 'utility:chevronright';
            }
            return section;
        });
        this.configReviewBCRBJson = [...sections];
    }

    handleReturnOriginalValues() {
        console.log('returning...');
    }

    handleSave() {
        console.log('Save Button Clicked');
        this.loadingSpinner = true;

        this.errorNullRequiredField = false;

        try {
            let records = {
                //Case: { Id: this.recordId },
                CaseAnnex__c: { Id: this.recordAnnexId }
            };

            this.configJson.forEach(section => {
                // Start CH01 add condition on section visibility
                // if(section.isVisible){
                // End CH01 add condition on section visibility
                    section.fields
                    .filter(field => (!field.readOnly || field.isCalculated) && field.isVisible)
                    .forEach(field => {
                        this.processField(field, records);
                    });
                // }
                
            });

            // console.log('records:', records);

            if (this.errorNullRequiredField) {
                this.handleValidationError();
                this.loadingSpinner = false;
            } else {
              //check dbr sheet section
              const cx_ln_Approved_Installment_Amount = this.template.querySelector(`[data-field-name="cx_ln_Approved_Installment_Amount__c"][data-object-name="CaseAnnex__c"]`);
              if (cx_ln_Approved_Installment_Amount && this.isFieldValueInvalid(cx_ln_Approved_Installment_Amount.value, true) && this.isButtonScheduleClicked == false) {
                this.validationErrorMessage = "Can't proceed with task approval, schedule must be regenerated as the approved values have been changed";
                this.flowError = false;
                this.validationError = true;
                this.showValidationError = true;
                this.showValidationErrorIcon = true;
                this.loadingSpinner = false;
              }else{
                /*if(this.isScheduleGenerated == true ){
                  records["CaseAnnex__c"]["cx_ln_isScheduleGenerated__c"] = true;
                }*/
                this.saveRecords(records);
              }
            }

            refreshApex(this.configJson);
            
        } catch (error) {
            console.error('Error:', error);
            this.showToast('Error updating records', error.body ? error.body.message : 'Unknown error', 'error');
        } finally {
            console.log('finished!!!');
        }
    }

    processField(field, records) {
        console.log('1 --->',field.fieldAPIName,field.objectName);
        const recordEditField = this.template.querySelector(`[data-field-name="${field.fieldAPIName}"][data-object-name="${field.objectName}"]`);
        console.log('1 --->',recordEditField.value);
        console.log('2 --->',this.caseRecordOrigin[field.fieldAPIName.toLowerCase()]);
        if (recordEditField) {
            if (field.objectName === 'CaseAnnex__c' && recordEditField.value != this.caseAnnexMapOrigin[field.fieldAPIName.toLowerCase()]) {
                console.log('"' + field.objectName + '" Field to Edit ApiName --> ' + field.fieldAPIName + ' old Value --> ' + this.caseAnnexMapOrigin[field.fieldAPIName.toLowerCase()] + ';; new Value --> ' + recordEditField.value);
                records[field.objectName][field.fieldAPIName] = recordEditField.value;
            }

            if (this.isFieldValueInvalid(recordEditField.value, field.required)) {
                this.errorNullRequiredField = true;
                this.errorFields.push(field.fieldAPIName);
            }
        }
    }

    isFieldValueInvalid(value, required) {
        return required && (value === null || value === undefined || value === '');
    }

    handleValidationError() {
        console.error('error... the null field is required to save the record', this.errorFields[0]);
        this.validationErrorMessage = this.errorFields[0];
        this.flowError = false;
        this.validationError = true;
        this.showValidationError = true;
        this.showValidationErrorIcon = true;
        this.showSectionValeurs = false;

        this.configJson.forEach(section => {
            section.fields.forEach(field => {
                if (field.fieldAPIName === this.errorFields[0]) {
                    field.returnIcon = true;
                    field.errorDesign = 'errorBackground';
                    field.inputErrorDesign = 'slds-form-element slds-has-error';
                }
            });
        });

        this.errorFields = [];
    }

    /*checkCaseFieldsIfChanged(fieldAPIName) {
      console.log('checkCaseFieldsIfChanged --> ');
      console.log('1 --->',fieldAPIName);
      console.log('2 --->',this.caseRecordOrigin[fieldAPIName.toLowerCase()]);
      
      let objectName = 'Case';
      const recordEditField = this.template.querySelector(`[data-id="${fieldAPIName}"]`);
      console.log('3 --->',recordEditField?.value);
      if (recordEditField) {
        if (recordEditField.value != this.caseRecordOrigin[fieldAPIName.toLowerCase()]) {
            console.log('"' + objectName + '" Field changed ApiName --> ' + fieldAPIName + ' old Value --> ' + this.caseRecordOrigin[fieldAPIName.toLowerCase()] + ';; new Value --> ' + recordEditField.value);
            return true;
        }
      }
      return false;
    }

    processCaseField(fieldAPIName, csrecords) {
      let objectName = 'Case';
      const recordEditField = this.template.querySelector(`[data-field-name="${fieldAPIName}"][data-object-name="${objectName}"]`);
      if (recordEditField) {
        csrecords[objectName][fieldAPIName] = recordEditField.value;
      }
    }*/

    async saveRecords(records) {
      try {

        //update caseAnnex record
        await this.updateRecords(records.CaseAnnex__c);
        
        if(this.showValidationError == false){
          //refreshApex(this.wiredCaseFields),
          refreshApex(this.wiredCaseAnnexFields)

          this.isConfigJsonFetched = false; // Reset to allow re-fetching
          this.callFetchConfigJson();
          console.log('saveRecords(records) finished');

          if(this.isButtonScheduleClicked == true){
            this.generateRepaymentScheduleFunc();
          }
        }
        
      } catch (error) {
          console.error('Error saving records:', error);
      }
    }

    resetValidationErrors() {
        this.showSectionValeurs = true;
        this.editSectionValeurs = false;
        this.showValidationError = false;
        this.flowError = false;
        this.validationError = false;
        this.showValidationErrorIcon = false;

        this.configJson.forEach(section => {
            section.fields.forEach(field => {
                field.errorMessage = '';
                field.returnIcon = false;
                field.errorDesign = '';
                field.inputErrorDesign = '';
            });
        });

        this.errorFields = [];
    }

    updateRecords(recordToInsert) {
        console.log('updateRecord details :', JSON.stringify(recordToInsert));
        this.loadingSpinner = true;

        return updateRecord({
            fields: recordToInsert
        })
            .then(() => {
                if (!this.isFirstUpdate) {
                    this.showSectionValeurs = true;
                    this.editSectionValeurs = false;
                    this.loadingSpinner = false;
                }

                this.isFirstUpdate = false;
                this.resetValidationErrors();
            })
            .catch((error) => {
                this.handleUpdateError(error);
            });
    }

    handleUpdateError(error) {
        console.log('Handling errors...');
        this.loadingSpinner = false;

        if (error.body.output.errors.length === 0) {
            this.handleValidationErrors(error.body.output.fieldErrors);
        } else if (error.body.output.errors.length > 0) {
            this.handleFlowErrors(error.body.output.errors[0].message);
        } else {
            this.showToast('Error updating records', error.body ? error.body.message : 'Unknown error', 'error');
        }

        console.error('Error:', error);
        console.error('Error Details:', JSON.stringify(error));
        this.editSectionValeurs = true;
        this.showSectionValeurs = false;
    }

    handleValidationErrors(validationErrors) {
        this.validationErrorMessage = '';
        this.flowError = false;
        this.validationError = true;
        console.log('Validation Errors:', JSON.stringify(validationErrors));
        this.showValidationError = true;
        this.showValidationErrorIcon = true;
        this.showSectionValeurs = false;

        for (const field in validationErrors) {
            if (validationErrors.hasOwnProperty(field)) {
                const errorObject = validationErrors[field][0];
                const fieldName = errorObject.field;
                const fieldLabel = errorObject.fieldLabel;
                const errorMessage = errorObject.message;

                console.log('Field Label:', fieldLabel);
                console.log('Field Name:', fieldName);
                console.log('Message:', errorMessage);

                this.validationErrorMessage = fieldLabel;
                console.log(this.validationErrorMessage);
                console.log("field.fieldAPIName --> check ");

                this.configJson.forEach(section => {
                    section.fields.forEach(field => {
                        if (field.fieldAPIName === fieldName) {
                            console.log("field.fieldAPIName --> "+field.fieldAPIName);
                            field.errorMessage = errorMessage;
                            field.returnIcon = true;
                            field.errorDesign = 'errorBackground';
                            field.inputErrorDesign = 'slds-form-element slds-has-error';
                        }
                    });
                });
            }
        }
    }

    handleFlowErrors(flowErrors) {
        this.validationErrorMessage = '';
        this.flowError = true;
        this.validationError = false;
        console.log('Flow Errors:', JSON.stringify(flowErrors));
        this.showValidationError = true;
        this.showValidationErrorIcon = true;
        this.showSectionValeurs = false;

        this.validationErrorMessage = flowErrors;
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

    get dynamicClass() {
        return `slds-size_1-of-${this.size}`;
    }

    get responsiveClass() {
        return `slds-col slds-size_1-of-${this.size} slds-p-around_xxx-small`;
    }

    get layoutClass() {
        return `slds-col slds-size_1-of-${this.size} slds-p-small`;
    }

    /*
    callEsalaryApi() {
        console.log('callEsalaryApi() Button Clicked');
        this.loadingSpinner = true;
        this.handleChangeFormValeurs();
        getEsalaryApiResponse({ caseId: this.recordId })
        .then(result => {
            if(result.status == 'Success'){
                let dataResponse = JSON.parse(result.response);
                console.log('>>>>> LWC03 : getEsalaryApiResponse result = ' + JSON.stringify(result.response));

                const cx_ln_Basic_Salary = this.template.querySelector(`[data-field-name="cx_ln_Basic_Salary__c"][data-object-name="CaseAnnex__c"]`);
                const cx_ln_Fixed_Allowances = this.template.querySelector(`[data-field-name="cx_ln_Fixed_Allowances__c"][data-object-name="CaseAnnex__c"]`);
                const cx_ln_Variable_Allowances = this.template.querySelector(`[data-field-name="cx_ln_Variable_Allowances__c"][data-object-name="CaseAnnex__c"]`);
                const cx_ln_Business_Income = this.template.querySelector(`[data-field-name="cx_ln_Business_Income__c"][data-object-name="CaseAnnex__c"]`);
                const cx_ln_Total_Approved_Income = this.template.querySelector(`[data-field-name="cx_ln_Total_Approved_Income__c"][data-object-name="CaseAnnex__c"]`);
                const cx_ln_Gross_Income = this.template.querySelector(`[data-field-name="cx_ln_Gross_Income__c"][data-object-name="CaseAnnex__c"]`);
                const cx_ln_Net_Income = this.template.querySelector(`[data-field-name="cx_ln_Net_Income__c"][data-object-name="CaseAnnex__c"]`);
                const cx_ln_Other_Deductions = this.template.querySelector(`[data-field-name="cx_ln_Other_Deductions__c"][data-object-name="CaseAnnex__c"]`);
                const cx_ln_Total_Deductions = this.template.querySelector(`[data-field-name="cx_ln_Total_Deductions__c"][data-object-name="CaseAnnex__c"]`);
                
                if (cx_ln_Basic_Salary) {
                    cx_ln_Basic_Salary.value = dataResponse.data[0].basicSalary;
                }
                if (cx_ln_Fixed_Allowances) {
                    cx_ln_Fixed_Allowances.value = dataResponse.data[0].fixedAllowances;
                }
                if (cx_ln_Variable_Allowances) {
                    cx_ln_Variable_Allowances.value = dataResponse.data[0].variableAllowances;
                }
                if (cx_ln_Business_Income) {
                    cx_ln_Business_Income.value = dataResponse.data[0].businessIncome;
                }
                if (cx_ln_Total_Approved_Income) {
                    cx_ln_Total_Approved_Income.value = dataResponse.data[0].totalApprovedIncome;
                }
                if (cx_ln_Gross_Income) {
                    cx_ln_Gross_Income.value = dataResponse.data[0].grossIncome;
                }
                if (cx_ln_Net_Income) {
                    cx_ln_Net_Income.value = dataResponse.data[0].netIncome;
                }
                if (cx_ln_Other_Deductions) {
                    cx_ln_Other_Deductions.value = dataResponse.data[0].otherDeductions;
                }
                if (cx_ln_Total_Deductions) {
                    cx_ln_Total_Deductions.value = dataResponse.data[0].totalDeductions;
                }
    

                this.loadingSpinner = false;
            }else{
              this.showToast('Error Api',result.message, 'error');
            }
        })
        .catch(error => {
            //handle error show an error message !!
            this.showToast('Error Api', error.body ? error.body.message : 'Unknown error', 'error');
            console.log('lwc03 >>> Error in callEsalaryApi() : ' + JSON.stringify(error));
        });
                    
    }

    callBCRBApi() {
        console.log('callBCRBApi() Button Clicked');
        this.loadingSpinner = true;
        this.handleChangeFormValeurs();
        getBCRBapiResponse({ caseId: this.recordId })
        .then(result => {
            if(result.status == 'Success'){
                let dataResponse = JSON.parse(result.response);
                console.log('>>>>> LWC03 : callBCRBApi result = ' + JSON.stringify(result.response));


                this.loadingSpinner = false;
            }else{
              this.showToast('Error',result.message, 'error');
            }
        })
        .catch(error => {
            //handle error show an error message !!
            this.showToast('Error Api', error.body ? error.body.message : 'Unknown error', 'error');
            console.log('lwc03 >>> Error in callEsalaryApi() : ' + JSON.stringify(error));
        });
                    
    }
  */

    fetchBcrbDetailsButton() {
      console.log('fetchBcrbDetails() Button Clicked--> this.recordId : '+this.recordId + '==>this.recordAnnexId :'+this.recordAnnexId);
      this.loadingSpinner = true;
      fetchBcrbDetails({ caseId: this.recordId, caseAnnexId: this.recordAnnexId })
      .then(result => {
          if(result.status == 'Success'){
            this.showToast('Success','Results Fetched Successfully!', 'success');
            let records = {
              CaseAnnex__c: { Id: this.recordAnnexId }
            };
            this.saveRecords(records);
            refreshApex(this.wiredCaseAnnexFields);
          }else{
              this.showToast('Error Api',result.message, 'error');
          }
      })
      .catch(error => {
          //handle error show an error message !!
          this.showToast('Error Api', error.body ? error.body.message : 'Unknown error', 'error');
          console.log('lwc03 >>> Error in fetchBcrbDetailsButton() : ' + JSON.stringify(error));
      });
                  
    }

    reviewBcrbDetailsButton() {
      console.log('reviewBcrbDetailsButton() Button Clicked');
      this.loadingSpinner = true;
      reviewBcrbDetails({ caseId: this.recordId, caseAnnexId: this.recordAnnexId })
      .then(result => {
          if(result.status == 'Success'){
            this.showToast('Success','Review Details fetched Successfully!', 'success');
            let records = {
              CaseAnnex__c: { Id: this.recordAnnexId }
            };
            this.saveRecords(records);
            refreshApex(this.wiredCaseAnnexFields);
          }else{
              this.showToast('Error Api',result.message, 'error');
          }
      })
      .catch(error => {
          //handle error show an error message !!
          this.showToast('Error Api', error.body ? error.body.message : 'Unknown error', 'error');
          console.log('lwc03 >>> Error in reviewBcrbDetailsButton() : ' + JSON.stringify(error));
      });
                  
    }

  displayReviewSection(result) {
    console.log('displayReviewSection--->'+result);
    let dataResponse = JSON.parse(result);
    let bcrbData = dataResponse.data;
    let calculateTotalCurrentObligation =
        (bcrbData.totalConsumerLoans ?? 0) +
        (bcrbData.totalMortgageLoans ?? 0) +
        (bcrbData.totalCreditCards ?? 0) +
        (bcrbData.totalIlaCreditCardInstallments ?? 0) +
        (bcrbData.totalGovernmentLoans ?? 0) +
        (bcrbData.totalOverdraftInstallments ?? 0) +
        (bcrbData.totalLeverageLoanInstallments ?? 0) +
        (bcrbData.totalBuyNowPayLaterInstallments ?? 0);
    console.log('calculateTotalCurrentObligation --> ' +calculateTotalCurrentObligation);
    return [
      {
        "sectionName": "BCRB Details",
        "show":true,
        "iconName" : 'utility:chevrondown',
        "fields": [
          {
            "fieldAPIName": "cx_ln_TotalConsumerLoansInstallments__c",//new field added
            "fieldValue": bcrbData.totalConsumerLoans
          },
          {
            "fieldAPIName": "cx_ln_TotalMortgageLoansInstallments__c",//new field added
            "fieldValue": bcrbData.totalMortgageLoans
          },
          {
            "fieldAPIName": "cx_ln_TotalCreditCardsInstallments__c",//new field added
            "fieldValue": bcrbData.totalCreditCardInstallments
          },
          {
            "fieldAPIName": "cx_ln_Total_IlaCreditCardsInstallments__c",//new field added
            "fieldValue": (bcrbData.totalIlaCreditCardInstallments)?bcrbData.totalIlaCreditCardInstallments:0
          },
          {
            "fieldAPIName": "cx_ln_Total_CCs_Installments_without_ila__c",
            "fieldValue": (bcrbData.totalIlaCreditCardInstallmentsWithoutIla)?bcrbData.totalIlaCreditCardInstallmentsWithoutIla:0
          },
          {
            "fieldAPIName": "cx_ln_TotalGovernmentLoansInstallments__c",//new field added
            "fieldValue": bcrbData.totalGovernmentLoans
          },
          {
              "fieldAPIName": "cx_ln_TotalOverdraftInstallments__c",//new field added
              "fieldValue": bcrbData.totalOverdraftInstallments
          },
          {
              "fieldAPIName": "cx_ln_TotalLeverageLoanInstallments__c",//new field added
              "fieldValue": bcrbData.totalLeverageLoanInstallments
          },
          {
              "fieldAPIName": "cx_ln_TotalBuyNowPayLaterInstallments__c",//new field added
              "fieldValue": bcrbData.totalBuyNowPayLaterInstallments
          },
          {
              "fieldAPIName": "cx_ln_CurrentLoansLimit__c",//new field added
              "fieldValue": bcrbData.currentLoansLimit
          },
          {
              "fieldAPIName": "cx_ln_TotalCurrentObligations__c",
              "fieldValue": bcrbData.totalCurrentObligations//calculateTotalCurrentObligation
          },
          {
              "fieldAPIName": "cx_ln_Total_Obligations__c",
              "fieldValue": bcrbData.totalIObligations
          }
        ]
      },
      {
        "sectionName": "Current Loans Statistics",
        "show":true,
        "iconName" : 'utility:chevrondown',
        "fields": [ //all new field added
          {
            "fieldAPIName": "cx_ln_No_of_Corporate_Accounts__c",
            "fieldValue": bcrbData.numberOfCorporateAccounts
          },
          {
            "fieldAPIName": "cx_ln_No_of_Non_Owner_Accounts__c",
            "fieldValue": bcrbData.numberOfNonOwnerAccounts
          },
          {
            "fieldAPIName": "cx_ln_No_of_non_normal_accounts__c",
            "fieldValue": bcrbData.numberOfNonNormalAccounts
          },
          {
            "fieldAPIName": "cx_ln_No_of_Credit_Cards_without_Ila__c",
            "fieldValue": (bcrbData.numberOfCreditCardsWithoutIla)?bcrbData.numberOfCreditCardsWithoutIla:0
          },
          {
            "fieldAPIName": "cx_ln_No_of_Ila_Credit_Cards__c",
            "fieldValue": (bcrbData.numberOfIlaCreditCards)?bcrbData.numberOfIlaCreditCards:0
          },
          {
            "fieldAPIName": "cx_ln_NoPenaltiesContraventions_accounts__c",
            "fieldValue": (bcrbData.totalOfPenaltiesAndContraventionAccounts)?bcrbData.totalOfPenaltiesAndContraventionAccounts:0
          },
          {
            "fieldAPIName": "cx_ln_No_of_Billing_Accounts__c",
            "fieldValue": (bcrbData.numberOfBillingAccounts)?bcrbData.numberOfBillingAccounts:0
          },
          {
            "fieldAPIName": "cx_ln_Total_no_of_Loans__c",
            //"isHighlighted":( ((bcrbData.totalNumberOfLoans)?bcrbData.totalNumberOfLoans:0) > 0 )?true:false,
            "fieldValue": (bcrbData.totalNumberOfLoans)?bcrbData.totalNumberOfLoans:0
          },
          {
            "fieldAPIName": "cx_ln_No_of_Arrears_with_gov_loans__c",
            "isHighlighted":( ((bcrbData.numberOfArrearsWithGovLoans)?bcrbData.numberOfArrearsWithGovLoans:0) > 0 )?true:false,
            "fieldValue": (bcrbData.numberOfArrearsWithGovLoans)?bcrbData.numberOfArrearsWithGovLoans:0
          },
          {
            "fieldAPIName": "cx_ln_No_of_Arrears_without_gov_loans__c",
            "isHighlighted":( ((bcrbData.numberOfArrearsWithoutGovLoans)?bcrbData.numberOfArrearsWithoutGovLoans:0) > 0 )?true:false,
            "fieldValue": (bcrbData.numberOfArrearsWithoutGovLoans)?bcrbData.numberOfArrearsWithoutGovLoans:0
          },
        ]
      },
      {
        "sectionName": "Main CRB Details",
        "show":true,
        "iconName" : 'utility:chevrondown',
        "fields": [
          {
            "fieldAPIName": "cx_ln_Current_Customer_Status__c",
            "fieldValue": bcrbData.currentCustomerStatus
          },
          {
            "fieldAPIName": "cx_ln_Current_DBR__c",
            "fieldValue": this.caseAnnexMap['cx_ln_current_dbr__c']
          },
          {
            "fieldAPIName": "cx_ln_Total_Credit_Exposure__c",
            "fieldValue": bcrbData.totalCreditExposure
          },
          {
            "fieldAPIName": "cx_ln_Credit_Bureau_Score__c",
            "fieldValue": bcrbData.creditBureauScore
          },
          {
              "fieldAPIName": "cx_ln_Credit_Bureau_Risk_Rating__c",
              "fieldValue": bcrbData.creditBureauRiskRating //toDo : check this if it's populated
          },
          {
            "fieldAPIName": "cx_ln_Current_PSI_Transaction_No__c",
            "fieldValue": (bcrbData.transactionNo)?bcrbData.transactionNo:0
          },
          {
            "fieldAPIName": "cx_ln_Current_PSI_Expiry_Date__c",
            "fieldValue": bcrbData.currentPSIExpiryDate
          },
          {
            "fieldAPIName": "cx_ln_LoanApplicationDecision__c",
            "fieldValue": bcrbData.loanApplicationDecision
          }
        ]
      }
    ];
  }

  generateRepaymentScheduleButton() {
    console.log('generateRepaymentScheduleButton() Clicked test ');
    this.isButtonScheduleClicked = true;
    this.handleSave();
  }

  generateRepaymentScheduleFunc(){
    this.isButtonScheduleClicked = false;
    this.loadingSpinner = true;
    console.log('enter generateRepaymentScheduleFunc');
    generateRepaymentSchedule({ caseId: this.recordId, caseAnnexId: this.recordAnnexId })
        .then(result => {
            if(result.status == 'Success'){
              this.handleCancel();
              this.showToast('Success','Generate Repayment schedule simulation Successfully!', 'success');
              this.getScheduleRetries = 1;
              setTimeout(() => {
                this.getSimulationPaymentListFunc();
              }, 3000);
              
            }else{
                this.showToast('Error Api',result.message, 'error');
                this.loadingSpinner = false;
            }
        })
        .catch(error => {
            //handle error show an error message !!
            this.showToast('Error Api', error.body ? error.body.message : 'Unknown error', 'error');
            this.loadingSpinner = false;
            console.log('lwc03 >>> Error in generateRepaymentScheduleButton() : ' + JSON.stringify(error));
        });
  }

  getSimulationPaymentListFunc(){
    console.log('enter getSimulationPaymentListFunc => ' + this.getScheduleRetries);
    this.getScheduleRetries = this.getScheduleRetries + 1;
    getSimulationPaymentList({ caseId: this.recordId ,caseAnnexId: this.recordAnnexId})
        .then(result => {
            console.log('getSimulationPaymentList Result --> ');
            console.log(JSON.stringify(result));
            if(result.isSuccess == true){
              if(result.headerData != null){
                this.showToast('Success','Call simulation Successfully!', 'success');
                let records = {
                  CaseAnnex__c: { Id: this.recordAnnexId }
                };
                this.saveRecords(records);
                refreshApex(this.wiredCaseAnnexFields);
                /*const cx_ln_Approved_Installment_Amount = this.template.querySelector(`[data-field-name="cx_ln_Approved_Installment_Amount__c"][data-object-name="CaseAnnex__c"]`);
                if (cx_ln_Approved_Installment_Amount) {
                  cx_ln_Approved_Installment_Amount.value = result.headerData.monthlyInstallment;
                }
                const cx_ln_Approved_Maturity_Date = this.template.querySelector(`[data-field-name="cx_ln_Approved_Maturity_Date__c"][data-object-name="CaseAnnex__c"]`);
                if (cx_ln_Approved_Maturity_Date) {
                  //cx_ln_Approved_Maturity_Date.value = '2025-01-21';
                }
                const cx_ln_Approved_Insurance_Amount = this.template.querySelector(`[data-field-name="cx_ln_Approved_Insurance_Amount__c"][data-object-name="CaseAnnex__c"]`);
                if (cx_ln_Approved_Insurance_Amount) {
                  cx_ln_Approved_Insurance_Amount.value = result.headerData.insuranceAmount;
                }
                const cx_ln_APR = this.template.querySelector(`[data-field-name="cx_ln_APR__c"][data-object-name="CaseAnnex__c"]`);
                if (cx_ln_APR) {
                  cx_ln_APR.value = result.headerData.apr;
                }*/

                //refresh the payment schedule aura comopent on the other Tab -- START
                // Create a simple message payload (can be any JSON)
                const payload = { notify: true, timestamp: Date.now() };
                // Publish it on TriggerChannel
                publish(this.messageContext, TRIGGER_CHANNEL, payload);
                // refresh -- END

                this.disableGenerateScheduleButton = true;
                this.loadingSpinner = false;
              }else{
                  this.showToast('call Get Schedule List API response is empty','"data":[]', 'error');
                  this.loadingSpinner = false;
              }
            }else{
                if (this.getScheduleRetries <= 1) {
                  setTimeout(() => {
                    this.getSimulationPaymentListFunc();
                  }, 3000);
                } else  {
                  this.showToast('Error Api',result.message, 'error');
                  this.loadingSpinner = false;
                }
                
            }
        })
        .catch(error => {
            //handle error show an error message !!
            this.showToast('Error Api', error.body ? error.body.message : 'Unknown error', 'error');
            this.loadingSpinner = false;
            console.log('lwc03 >>> Error in getSimulationPaymentListFunc() : ' + JSON.stringify(error));
        });
  }
}