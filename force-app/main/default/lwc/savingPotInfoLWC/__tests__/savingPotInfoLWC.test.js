import { createElement } from "lwc";
import Cmp from "c/savingPotInfoLWC";
import getSavingPots from "@salesforce/apex/DeviceDetailsController.getSavingPots";
jest.mock(
  "@salesforce/apex/DeviceDetailsController.getSavingPots",
  () => ({ default: jest.fn() }),
  { virtual: true }
);

// eslint-disable-next-line @lwc/lwc/no-async-operation
const flushPromises = () => new Promise((resolve) => setTimeout(resolve, 0));

function createComponent() {
  const element = createElement("c-saving-pot-info-l-w-c", { is: Cmp });
  element.customerId = "001ACC";
  element.cifNumber = "CIF1";
  document.body.appendChild(element);
  return element;
}

describe("c-saving-pot-info-l-w-c", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("shows the rows returned by Apex", async () => {
    getSavingPots.mockResolvedValue([
      { id: "P1", name: "Pot", currencyCode: "BHD", availableBalance: 10 }
    ]);
    const element = createComponent();
    await flushPromises();

    expect(getSavingPots).toHaveBeenCalledWith({ accID: "001ACC" });
    const table = element.shadowRoot.querySelector("lightning-datatable");
    expect(table.keyField).toBe("id");
    expect(table.data).toHaveLength(1);
  });

  it("shows the no data message when Apex returns nothing", async () => {
    getSavingPots.mockResolvedValue([]);
    const element = createComponent();
    await flushPromises();

    expect(element.shadowRoot.querySelector("lightning-datatable")).toBeNull();
    expect(element.shadowRoot.querySelector("div").textContent).toBe(
      "No Saving Pots found for customer : CIF1"
    );
  });
});
