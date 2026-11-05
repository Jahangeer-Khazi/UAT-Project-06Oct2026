import { createElement } from "lwc";
import DeviceDetailLWC from "c/deviceDetailLWC";
import loadDeviceList from "@salesforce/apex/DeviceDetailsController.loadDeviceList";

jest.mock(
  "@salesforce/apex/DeviceDetailsController.loadDeviceList",
  () => ({ default: jest.fn() }),
  { virtual: true }
);

// eslint-disable-next-line @lwc/lwc/no-async-operation
const flushPromises = () => new Promise((resolve) => setTimeout(resolve, 0));

describe("c-device-detail-lwc", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("reads Device Last Login as UTC and shows it as a date-time column", async () => {
    loadDeviceList.mockResolvedValue({
      d1: {
        id: "d1",
        status: "ACTIVE",
        manufacturer: "samsung",
        model: { name: "SM-A525F" },
        os: { name: "ANDROID" },
        lastLogin: { deviceLastLogin: "2026-11-05T13:10:25.926" }
      }
    });

    const element = createElement("c-device-detail-lwc", {
      is: DeviceDetailLWC
    });
    element.customerId = "001";
    document.body.appendChild(element);
    await flushPromises();
    await flushPromises();

    const table = element.shadowRoot.querySelector("lightning-datatable");
    expect(table.data[0].deviceLastLogin).toBe(
      Date.UTC(2026, 10, 5, 13, 10, 25, 926)
    );
    const column = table.columns.find((c) => c.fieldName === "deviceLastLogin");
    expect(column.type).toBe("date");
    expect(column.typeAttributes.month).toBe("short");
  });
});
