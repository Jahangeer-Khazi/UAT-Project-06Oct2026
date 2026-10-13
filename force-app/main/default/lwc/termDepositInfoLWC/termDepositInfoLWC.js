/*      Organization : ABC Bank
 *      Description  : LWC version of the TermDepositInfo Aura component, used on the
 *                     Manual Authentication Flow screens.
 */
import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getFixedDeposits from "@salesforce/apex/DeviceDetailsController.getFixedDeposits";

export default class TermDepositInfoLWC extends LightningElement {
  // Input from Flow
  @api customerId;
  @api cifNumber;

  rows = [];
  message = "";
  isLoading = true;

  columns = [
    { label: "Id", fieldName: "id", type: "text" },
    { label: "Name", fieldName: "name", type: "text" },
    { label: "Currency", fieldName: "currencyCode", type: "text" },
    {
      label: "Deposit Amount",
      fieldName: "depositAmount",
      type: "number",
      cellAttributes: { alignment: "left" },
      typeAttributes: { minimumFractionDigits: 0, maximumFractionDigits: 3 }
    },
    {
      label: "Maturity Amount",
      fieldName: "maturityAmount",
      type: "number",
      cellAttributes: { alignment: "left" },
      typeAttributes: { minimumFractionDigits: 0, maximumFractionDigits: 3 }
    },
    { label: "Status", fieldName: "status", type: "text" }
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
      const result = await getFixedDeposits({ accID: this.customerId });
      this.rows = result || [];
      if (this.rows.length === 0) {
        this.message =
          "No Fixed Deposit found for customer : " + this.cifNumber;
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
