/*      Organization : ABC Bank
 *      Description  : LWC version of the creditCardInfo Aura component, used on the
 *                     Manual Authentication Flow screens. Lists the customer's credit
 *                     cards and shows the current credit limit of the selected card.
 */
import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getCurrentCards from "@salesforce/apex/DeviceDetailsController.getCurrentCards";
import loadCardDetailsToFetchLimit from "@salesforce/apex/DeviceDetailsController.loadCardDetailsToFetchLimit";

export default class CreditCardInfoLWC extends LightningElement {
  // Input from Flow
  @api customerId;
  @api cifNumber;

  currentCards = [];
  message = "";
  isLoadingCards = true;
  isLoadingLimit = false;

  pciNumber;
  selectedCardName;
  cardNumber;
  currentCreditLimit;

  columns = [
    {
      label: "Card Classification",
      fieldName: "cardClassification",
      type: "text"
    },
    { label: "Card Status", fieldName: "cardStatus", type: "text" },
    { label: "Card Type", fieldName: "cardType", type: "text" },
    { label: "Card Number", fieldName: "cardNumber", type: "text" },
    {
      label: "Is Delinquent",
      type: "button-icon",
      cellAttributes: { alignment: "left" },
      typeAttributes: {
        iconName: { fieldName: "delinquentIcon" },
        disabled: false,
        variant: "bare"
      }
    }
  ];

  connectedCallback() {
    this.fetchCurrentCards();
  }

  get hasCards() {
    return this.currentCards.length > 0;
  }

  get hasCreditLimit() {
    return (
      this.currentCreditLimit !== undefined &&
      this.currentCreditLimit !== null &&
      this.currentCreditLimit !== ""
    );
  }

  get cardTitle() {
    return "Card Number - " + this.cardNumber;
  }

  async fetchCurrentCards() {
    this.isLoadingCards = true;
    try {
      this.currentCards =
        (await getCurrentCards({ accID: this.customerId })) || [];
      if (this.currentCards.length === 0) {
        this.message =
          "No Credit Cards Details found for customer : " + this.cifNumber;
      }
    } catch (error) {
      this.showError(error);
    } finally {
      this.isLoadingCards = false;
    }
  }

  handleRowSelection(event) {
    const selectedRows = event.detail.selectedRows;
    if (!selectedRows || selectedRows.length === 0) {
      return;
    }
    const selectedRow = selectedRows[0];
    this.pciNumber = selectedRow.id;
    this.selectedCardName = selectedRow.cardClassification;
    this.cardNumber = selectedRow.cardNumber;
    // Clear previous limit
    this.currentCreditLimit = null;
    this.fetchCurrentLimit(selectedRow.id);
  }

  async fetchCurrentLimit(cardId) {
    this.isLoadingLimit = true;
    try {
      const result = await loadCardDetailsToFetchLimit({
        accID: this.customerId,
        requestedPCINumber: cardId
      });
      // Ignore a late response for a card that is no longer selected
      if (cardId === this.pciNumber) {
        this.currentCreditLimit = result ? result.creditLimit : null;
      }
    } catch (error) {
      this.showError(error);
    } finally {
      if (cardId === this.pciNumber) {
        this.isLoadingLimit = false;
      }
    }
  }

  showError(error) {
    console.error("Apex Class error: ", JSON.stringify(error));
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
