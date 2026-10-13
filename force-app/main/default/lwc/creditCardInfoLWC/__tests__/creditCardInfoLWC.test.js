import { createElement } from "lwc";
import Cmp from "c/creditCardInfoLWC";
import getCurrentCards from "@salesforce/apex/DeviceDetailsController.getCurrentCards";
import loadCardDetailsToFetchLimit from "@salesforce/apex/DeviceDetailsController.loadCardDetailsToFetchLimit";
jest.mock(
  "@salesforce/apex/DeviceDetailsController.getCurrentCards",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/DeviceDetailsController.loadCardDetailsToFetchLimit",
  () => ({ default: jest.fn() }),
  { virtual: true }
);

// eslint-disable-next-line @lwc/lwc/no-async-operation
const flushPromises = () => new Promise((resolve) => setTimeout(resolve, 0));

function createComponent() {
  const element = createElement("c-credit-card-info-l-w-c", { is: Cmp });
  element.customerId = "001ACC";
  element.cifNumber = "CIF1";
  document.body.appendChild(element);
  return element;
}

describe("c-credit-card-info-l-w-c", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("shows the credit limit of the selected card", async () => {
    getCurrentCards.mockResolvedValue([
      {
        id: "PCI1",
        cardClassification: "Platinum",
        cardNumber: "****1234",
        delinquentIcon: "utility:close"
      }
    ]);
    loadCardDetailsToFetchLimit.mockResolvedValue({ creditLimit: 5000 });
    const element = createComponent();
    await flushPromises();

    const table = element.shadowRoot.querySelector("lightning-datatable");
    table.dispatchEvent(
      new CustomEvent("rowselection", {
        detail: { selectedRows: [table.data[0]] }
      })
    );
    await flushPromises();

    expect(loadCardDetailsToFetchLimit).toHaveBeenCalledWith({
      accID: "001ACC",
      requestedPCINumber: "PCI1"
    });
    const card = element.shadowRoot.querySelector("lightning-card");
    expect(card.title).toBe("Card Number - ****1234");
    expect(card.textContent).toContain("Platinum Current Credit Limit :");
    expect(card.textContent).toContain("5000");
  });

  it("shows the no data message when the customer has no credit cards", async () => {
    getCurrentCards.mockResolvedValue([]);
    const element = createComponent();
    await flushPromises();

    expect(element.shadowRoot.querySelector("lightning-datatable")).toBeNull();
    expect(element.shadowRoot.querySelector("div").textContent).toBe(
      "No Credit Cards Details found for customer : CIF1"
    );
  });
});
