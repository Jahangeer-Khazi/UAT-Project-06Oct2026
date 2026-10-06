import { LightningElement, api, track } from 'lwc';
import loadDeviceList from '@salesforce/apex/DeviceDetailsController.loadDeviceList';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class DeviceDetails extends LightningElement {

    // Input from Flow
    @api customerId;
    @api customerCIF;

    // Output to Flow
    @api deviceSummary;

    @track deviceData = [];
    //isLoaded = false;
    isLoading = true;
    columns = [
        {
            label: 'ID',
            fieldName: 'id',
            type: 'text'
        },
        {
            label: 'Status',
            fieldName: 'status',
            type: 'text'
        },
        {
            label: 'Manufacturer',
            fieldName: 'manufacturer',
            type: 'text'
        },
        {
            label: 'Model',
            fieldName: 'model',
            type: 'text'
        },
        {
            label: 'OS',
            fieldName: 'os',
            type: 'text'
        },
        {
            label: 'Device Last Login',
            fieldName: 'deviceLastLogin',
            type: 'text'
        }
    ];

    connectedCallback() {
        console.log('[DeviceDetails] Account Id:', this.customerId);
        this.fetchDevices();
    }

    fetchDevices() {
        this.isLoading = true;
        loadDeviceList({
            accID: this.customerId
        })
        .then(result => {

            console.log('[DeviceDetails] Raw API Result:',JSON.parse(JSON.stringify(result)));

            let devices = [];

            // Handle response as Object
            Object.keys(result).forEach(key => {

                let deviceObj = result[key];

                devices.push({
                    id : deviceObj.id,
                    status : deviceObj.status,
                    manufacturer : deviceObj.manufacturer,
                    model : deviceObj.model.name,
                    os : deviceObj.os.name,
                    deviceLastLogin : deviceObj.lastLogin.deviceLastLogin
                });

            });

            console.log('[DeviceDetails] Datatable Data:',JSON.stringify(devices));

            // Populate Datatable
            this.deviceData = devices;
            //this.isLoaded = true;

            // Generate Device Summary
            let firstKey = Object.keys(result)[0];

            if(firstKey){

                let firstDevice = result[firstKey];

                let summary =
                    'Manufacturer: ' +
                    firstDevice.manufacturer +
                    ', Model: ' +
                    (firstDevice.model
                        ? firstDevice.model.name
                        : '') +
                    ', OS: ' +
                    (firstDevice.os
                        ? firstDevice.os.name
                        : '');

                console.log('[DeviceDetails] Device Summary:',summary);

                // Set value locally
                this.deviceSummary = summary;

                // Send value back to Flow
                this.dispatchEvent(new FlowAttributeChangeEvent('deviceSummary', summary));

                console.log('[DeviceDetails] Device Summary sent to Flow:',summary);
            }

        })
        .catch(error => {

            console.error('[DeviceDetails] Error:',JSON.stringify(error));
            //this.isLoaded = true;
        })
        .finally(() => {
            this.isLoading = false;
        });
    }
    get hasDeviceData() {
        return this.deviceData && this.deviceData.length > 0;
    }
}