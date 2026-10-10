/*      Organization : ABC Bank
 *      Description  : LWC version of the randomTransactions Aura component, used on the
 *                     Manual Authentication Flow screens. Shows the latest 25 transactions
 *                     of the customer's first account for the last 12 months.
 */
import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import loadAccountList from "@salesforce/apex/BankAccountController.loadAccountList";
import loadAccountTransactions from "@salesforce/apex/BankAccountController.loadAccountTransactions";

const BATCH_SIZE = 30;
const RECORD_SIZE = 25;
const MONTHS_BACK = 12;

export default class RandomTransactionsLWC extends LightningElement {
  // Input from Flow
  @api customerId;
  @api regionName;

  gridDataRows = [];
  isLoading = true;
  sortedBy;
  sortedDirection = "desc";

  columns = [
    {
      label: "Account Number",
      fieldName: "accountNumber",
      type: "text",
      sortable: true
    },
    {
      label: "Product Name",
      fieldName: "productName",
      type: "text",
      sortable: true
    },
    {
      label: "Transaction Date",
      fieldName: "transactionDate",
      type: "date",
      sortable: true
    },
    {
      label: "Transaction Amount",
      fieldName: "amount",
      type: "number",
      sortable: true
    },
    {
      label: "Transaction Currency",
      fieldName: "transactionCurrency",
      type: "text",
      sortable: true
    },
    {
      label: "Transaction Type",
      fieldName: "transactionType",
      type: "text",
      sortable: true
    },
    {
      label: "Transaction Description",
      fieldName: "transactionDescription",
      type: "text",
      sortable: false
    }
  ];

  connectedCallback() {
    this.loadData();
  }

  get hasTransactionData() {
    return this.gridDataRows && this.gridDataRows.length > 0;
  }

  async loadData() {
    this.isLoading = true;
    try {
      const accountResult = await loadAccountList({
        customerId: this.customerId,
        regionName: this.regionName
      });
      if (this.isApiError(accountResult)) {
        return;
      }
      const accounts = accountResult?.responseData?.accounts || [];
      // Only the first account is used, same as the Aura component
      if (accounts.length === 0) {
        return;
      }
      await this.loadTransactions(accounts[0]);
    } catch (error) {
      this.showError(this.reduceError(error));
    } finally {
      this.isLoading = false;
    }
  }

  async loadTransactions(account) {
    const today = new Date();
    const toDate = new Date(
      today.getFullYear(),
      today.getMonth(),
      today.getDate() + 1
    );
    const fromDate = new Date(
      today.getFullYear(),
      today.getMonth() - MONTHS_BACK,
      today.getDate()
    );

    const searchParametersJson = {
      id: account.id,
      offSet: 0,
      pageSize: BATCH_SIZE,
      fromDate: this.formatDate(fromDate),
      toDate: this.formatDate(toDate),
      debitCreditIndicator: "ALL"
    };

    const result = await loadAccountTransactions({
      customerId: this.customerId,
      searchParametersJson: JSON.stringify(searchParametersJson),
      regionName: this.regionName
    });
    if (this.isApiError(result)) {
      return;
    }

    const transactions = Array.isArray(result?.responseData)
      ? [...result.responseData]
      : [];
    transactions.sort(
      (a, b) =>
        new Date(b.transactionDate).getTime() -
        new Date(a.transactionDate).getTime()
    );

    this.gridDataRows = transactions
      .slice(0, RECORD_SIZE)
      .map((transaction) => this.formatData(transaction, account));
  }

  formatData(transaction, account) {
    return {
      id: transaction.id,
      accountNumber: account.account ? account.account.number : "",
      productName: account.productName,
      transactionDate: new Date(transaction.transactionDate).getTime(),
      transactionType: transaction.transactionType,
      transactionCurrency: transaction.transactionCurrency
        ? transaction.transactionCurrency.code
        : "",
      transactionDescription: [
        transaction.transactionDescription1,
        transaction.transactionDescription2
      ].join(" "),
      amount: transaction.amount
    };
  }

  // yyyy-mm-dd in local time, as expected by the transactions API
  formatDate(date) {
    const mm = String(date.getMonth() + 1).padStart(2, "0");
    const dd = String(date.getDate()).padStart(2, "0");
    return `${date.getFullYear()}-${mm}-${dd}`;
  }

  handleSort(event) {
    const { fieldName, sortDirection } = event.detail;
    const modifier = sortDirection === "asc" ? 1 : -1;
    const rows = [...this.gridDataRows];
    rows.sort((a, b) => {
      const x = a[fieldName] ?? "";
      const y = b[fieldName] ?? "";
      if (x > y) {
        return modifier;
      }
      return x < y ? -modifier : 0;
    });
    this.gridDataRows = rows;
    this.sortedBy = fieldName;
    this.sortedDirection = sortDirection;
  }

  // Matches apexService: an API response with isSuccess = false shows an error toast
  isApiError(result) {
    if (result && result.isSuccess === false) {
      const msg = result.errorData
        ? JSON.stringify(result.errorData)
        : "An unexpected error has occurred.";
      this.showError(msg);
      return true;
    }
    return false;
  }

  reduceError(error) {
    if (error && error.body && error.body.message) {
      return error.body.message;
    }
    return error && error.message
      ? error.message
      : "An unexpected error has occurred.";
  }

  showError(message) {
    // Curly brackets make the toast show an empty message
    const clean = String(message).replace(/[{}]/g, "");
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Error!",
        message: clean,
        variant: "error",
        mode: "sticky"
      })
    );
  }
}
