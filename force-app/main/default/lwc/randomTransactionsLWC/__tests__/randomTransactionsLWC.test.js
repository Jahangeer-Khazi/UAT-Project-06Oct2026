import { createElement } from "lwc";
import RandomTransactionsLWC from "c/randomTransactionsLWC";
import loadAccountList from "@salesforce/apex/BankAccountController.loadAccountList";
import loadAccountTransactions from "@salesforce/apex/BankAccountController.loadAccountTransactions";

jest.mock(
  "@salesforce/apex/BankAccountController.loadAccountList",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/BankAccountController.loadAccountTransactions",
  () => ({ default: jest.fn() }),
  {
    virtual: true
  }
);

const ACCOUNTS = {
  isSuccess: true,
  responseData: {
    accounts: [
      { id: "ACC1", productName: "Current", account: { number: "123" } }
    ]
  }
};

function transaction(day) {
  return {
    id: "T" + day,
    transactionDate: `2026-09-${String(day).padStart(2, "0")}`,
    amount: day,
    transactionType: "Debit",
    transactionCurrency: { code: "BHD" },
    transactionDescription1: "Desc",
    transactionDescription2: String(day)
  };
}

// eslint-disable-next-line @lwc/lwc/no-async-operation
const flushPromises = () => new Promise((resolve) => setTimeout(resolve, 0));

function createComponent() {
  const element = createElement("c-random-transactions-lwc", {
    is: RandomTransactionsLWC
  });
  element.customerId = "CIF1";
  element.regionName = "BH";
  document.body.appendChild(element);
  return element;
}

describe("c-random-transactions-lwc", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("shows the latest 25 transactions of the first account, newest first", async () => {
    loadAccountList.mockResolvedValue(ACCOUNTS);
    const days = Array.from({ length: 30 }, (_, i) => i + 1);
    loadAccountTransactions.mockResolvedValue({
      isSuccess: true,
      responseData: days.map(transaction)
    });

    const element = createComponent();
    await flushPromises();
    await flushPromises();

    const params = JSON.parse(
      loadAccountTransactions.mock.calls[0][0].searchParametersJson
    );
    expect(params.id).toBe("ACC1");
    expect(params.pageSize).toBe(30);
    expect(params.fromDate).toMatch(/^\d{4}-\d{2}-\d{2}$/);

    const table = element.shadowRoot.querySelector("lightning-datatable");
    expect(table.data).toHaveLength(25);
    expect(table.data[0].id).toBe("T30");
    expect(table.data[0].accountNumber).toBe("123");
    expect(table.data[0].transactionCurrency).toBe("BHD");
    expect(table.data[0].transactionDescription).toBe("Desc 30");
  });

  it("shows the no data message when the customer has no accounts", async () => {
    loadAccountList.mockResolvedValue({
      isSuccess: true,
      responseData: { accounts: [] }
    });

    const element = createComponent();
    await flushPromises();
    await flushPromises();

    expect(loadAccountTransactions).not.toHaveBeenCalled();
    expect(element.shadowRoot.querySelector("lightning-datatable")).toBeNull();
    expect(element.shadowRoot.querySelector("div").textContent).toContain(
      "No Transaction Data found for customer: CIF1"
    );
  });
});
