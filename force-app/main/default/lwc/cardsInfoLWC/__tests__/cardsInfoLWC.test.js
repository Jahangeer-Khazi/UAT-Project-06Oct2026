import { createElement } from "lwc";
import Cmp from "c/cardsInfoLWC";
import getCurrentCards from "@salesforce/apex/DeviceDetailsController.getCurrentCards";
import getCurrentDebitCards from "@salesforce/apex/DeviceDetailsController.getCurrentDebitCards";
jest.mock(
  "@salesforce/apex/DeviceDetailsController.getCurrentCards",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/DeviceDetailsController.getCurrentDebitCards",
  () => ({ default: jest.fn() }),
  { virtual: true }
);

// eslint-disable-next-line @lwc/lwc/no-async-operation
const flushPromises = () => new Promise((resolve) => setTimeout(resolve, 0));

function createComponent() {
  const element = createElement("c-cards-info-l-w-c", { is: Cmp });
  element.customerId = "001ACC";
  element.cifNumber = "CIF1";
  document.body.appendChild(element);
  return element;
}

describe("c-cards-info-l-w-c", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("shows credit and debit cards in two tables", async () => {
    getCurrentCards.mockResolvedValue([
      { id: "C1", cardClassification: "Gold", cardNumber: "****1" }
    ]);
    getCurrentDebitCards.mockResolvedValue([
      { productName: "Debit", cardNumber: "****2" }
    ]);
    const element = createComponent();
    await flushPromises();

    const tables = element.shadowRoot.querySelectorAll("lightning-datatable");
    expect(tables).toHaveLength(2);
    expect(tables[0].data[0].id).toBe("C1");
    expect(tables[1].keyField).toBe("rowKey");
    expect(tables[1].data[0].rowKey).toBe("0");
  });

  it("shows both no data messages when the customer has no cards", async () => {
    getCurrentCards.mockResolvedValue([]);
    getCurrentDebitCards.mockResolvedValue([]);
    const element = createComponent();
    await flushPromises();

    const text = element.shadowRoot.textContent;
    expect(text).toContain("No Credit Cards Details found for customer : CIF1");
    expect(text).toContain("No Debit Cards Details found for customer : CIF1");
  });
});
