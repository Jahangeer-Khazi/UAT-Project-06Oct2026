/*      Organization : ABC Bank
 *      Description  : LWC version of the ForeignBankAcctsInfo Aura component, used on the
 *                     Manual Authentication Flow screens.
 */
import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getForeignAccounts from "@salesforce/apex/DeviceDetailsController.getForeignAccounts";

export default class ForeignBankAcctsInfoLWC extends LightningElement {
  // Input from Flow
  @api customerId;
  @api cifNumber;

  rows = [];
  message = "";
  isLoading = true;

  columns = [
    { label: "Account Number", fieldName: "accNumber", type: "text" },
    { label: "Alias Name", fieldName: "aliasName", type: "text" },
    { label: "Currency", fieldName: "currencyCode", type: "text" },
    {
      label: "Available Balance",
      fieldName: "availableBalance",
      type: "number",
      cellAttributes: { alignment: "left" },
      typeAttributes: { minimumFractionDigits: 0, maximumFractionDigits: 3 }
    }
  ];

  connectedCallback() {
    this.loadRows();
  }

  get hasRows() {
    return this.rows.length > 0;
  }

  async loadRows() {
    this.isLoading = true;
    try {
      const result = await getForeignAccounts({ accID: this.customerId });
      // The Apex wrapper has no id field, so give each row a key for the datatable
      this.rows = (result || []).map((row, index) => ({
        ...row,
        rowKey: String(index)
      }));
      if (this.rows.length === 0) {
        this.message =
          "No Foreign Accounts found for customer : " + this.cifNumber;
      }
    } catch (error) {
      console.error("Apex Class error: ", JSON.stringify(error));
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message:
            error && error.body && error.body.message ? error.body.message : "",
          variant: "error"
        })
      );
    } finally {
      this.isLoading = false;
    }
  }
}
