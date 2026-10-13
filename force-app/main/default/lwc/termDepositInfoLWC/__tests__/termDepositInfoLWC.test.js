import { createElement } from "lwc";
import Cmp from "c/termDepositInfoLWC";
import getFixedDeposits from "@salesforce/apex/DeviceDetailsController.getFixedDeposits";
jest.mock(
  "@salesforce/apex/DeviceDetailsController.getFixedDeposits",
  () => ({ default: jest.fn() }),
  { virtual: true }
);

// eslint-disable-next-line @lwc/lwc/no-async-operation
const flushPromises = () => new Promise((resolve) => setTimeout(resolve, 0));

function createComponent() {
  const element = createElement("c-term-deposit-info-l-w-c", { is: Cmp });
  element.customerId = "001ACC";
  element.cifNumber = "CIF1";
  document.body.appendChild(element);
  return element;
}

describe("c-term-deposit-info-l-w-c", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("shows the rows returned by Apex", async () => {
    getFixedDeposits.mockResolvedValue([
      {
        id: "FD1",
        name: "Deposit",
        currencyCode: "BHD",
        depositAmount: 100,
        maturityAmount: 105,
        status: "Active"
      }
    ]);
    const element = createComponent();
    await flushPromises();

    expect(getFixedDeposits).toHaveBeenCalledWith({ accID: "001ACC" });
    const table = element.shadowRoot.querySelector("lightning-datatable");
    expect(table.keyField).toBe("id");
    expect(table.data).toHaveLength(1);
  });

  it("shows the no data message when Apex returns nothing", async () => {
    getFixedDeposits.mockResolvedValue([]);
    const element = createComponent();
    await flushPromises();

    expect(element.shadowRoot.querySelector("lightning-datatable")).toBeNull();
    expect(element.shadowRoot.querySelector("div").textContent).toBe(
      "No Fixed Deposit found for customer : CIF1"
    );
  });
});
