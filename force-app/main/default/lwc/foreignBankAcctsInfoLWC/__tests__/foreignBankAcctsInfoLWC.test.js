import { createElement } from "lwc";
import Cmp from "c/foreignBankAcctsInfoLWC";
import getForeignAccounts from "@salesforce/apex/DeviceDetailsController.getForeignAccounts";
jest.mock(
  "@salesforce/apex/DeviceDetailsController.getForeignAccounts",
  () => ({ default: jest.fn() }),
  { virtual: true }
);

// eslint-disable-next-line @lwc/lwc/no-async-operation
const flushPromises = () => new Promise((resolve) => setTimeout(resolve, 0));

function createComponent() {
  const element = createElement("c-foreign-bank-accts-info-l-w-c", { is: Cmp });
  element.customerId = "001ACC";
  element.cifNumber = "CIF1";
  document.body.appendChild(element);
  return element;
}

describe("c-foreign-bank-accts-info-l-w-c", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("shows the rows returned by Apex", async () => {
    getForeignAccounts.mockResolvedValue([
      {
        accNumber: "111",
        aliasName: "USD",
        currencyCode: "USD",
        availableBalance: 5
      },
      {
        accNumber: "222",
        aliasName: "EUR",
        currencyCode: "EUR",
        availableBalance: 6
      }
    ]);
    const element = createComponent();
    await flushPromises();

    expect(getForeignAccounts).toHaveBeenCalledWith({ accID: "001ACC" });
    const table = element.shadowRoot.querySelector("lightning-datatable");
    expect(table.keyField).toBe("rowKey");
    expect(table.data).toHaveLength(2);
  });

  it("shows the no data message when Apex returns nothing", async () => {
    getForeignAccounts.mockResolvedValue([]);
    const element = createComponent();
    await flushPromises();

    expect(element.shadowRoot.querySelector("lightning-datatable")).toBeNull();
    expect(element.shadowRoot.querySelector("div").textContent).toBe(
      "No Foreign Accounts found for customer : CIF1"
    );
  });
});
