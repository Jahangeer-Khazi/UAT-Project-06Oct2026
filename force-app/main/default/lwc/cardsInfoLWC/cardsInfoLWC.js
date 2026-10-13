/*      Organization : ABC Bank
 *      Description  : LWC version of the CardsInfo Aura component, used on the
 *                     Manual Authentication Flow screens. Shows the customer's
 *                     credit cards and debit cards.
 */
import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getCurrentCards from "@salesforce/apex/DeviceDetailsController.getCurrentCards";
import getCurrentDebitCards from "@salesforce/apex/DeviceDetailsController.getCurrentDebitCards";

export default class CardsInfoLWC extends LightningElement {
  // Input from Flow
  @api customerId;
  @api cifNumber;

  creditCards = [];
  debitCards = [];
  message = "";
  messageDebit = "";
  isLoadingCards = true;
  isLoadingDebitCards = true;

  columns = [
    {
      label: "Card Classification",
      fieldName: "cardClassification",
      type: "text"
    },
    { label: "Card Status", fieldName: "cardStatus", type: "text" },
    { label: "Card Type", fieldName: "cardType", type: "text" },
    { label: "Card Number", fieldName: "cardNumber", type: "text" }
  ];

  debitColumns = [
    { label: "Card Classification", fieldName: "productName", type: "text" },
    { label: "Card Status", fieldName: "status", type: "text" },
    { label: "Card Type", fieldName: "cardType", type: "text" },
    { label: "Card Number", fieldName: "cardNumber", type: "text" }
  ];

  connectedCallback() {
    this.fetchCreditCards();
    this.fetchDebitCards();
  }

  get hasCreditCards() {
    return this.creditCards.length > 0;
  }

  get hasDebitCards() {
    return this.debitCards.length > 0;
  }

  async fetchCreditCards() {
    this.isLoadingCards = true;
    try {
      this.creditCards =
        (await getCurrentCards({ accID: this.customerId })) || [];
      if (this.creditCards.length === 0) {
        this.message =
          "No Credit Cards Details found for customer : " + this.cifNumber;
      }
    } catch (error) {
      this.showError("Apex Class error in Credit Cards: ", error);
    } finally {
      this.isLoadingCards = false;
    }
  }

  async fetchDebitCards() {
    this.isLoadingDebitCards = true;
    try {
      const result =
        (await getCurrentDebitCards({ accID: this.customerId })) || [];
      // The Apex wrapper has no id field, so give each row a key for the datatable
      this.debitCards = result.map((row, index) => ({
        ...row,
        rowKey: String(index)
      }));
      if (this.debitCards.length === 0) {
        this.messageDebit =
          "No Debit Cards Details found for customer : " + this.cifNumber;
      }
    } catch (error) {
      this.showError("Apex Class error in Debit Cards: ", error);
    } finally {
      this.isLoadingDebitCards = false;
    }
  }

  showError(logPrefix, error) {
    console.error(logPrefix, JSON.stringify(error));
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Error",
        message:
          error && error.body && error.body.message ? error.body.message : "",
        variant: "error"
      })
    );
  }
}
