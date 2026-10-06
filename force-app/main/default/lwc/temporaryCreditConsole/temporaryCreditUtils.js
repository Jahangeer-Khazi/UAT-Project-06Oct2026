const recordTypeConfig = [
    {
        type: 'Credit Card',
        subType: 'Temporary Credit',
        requestType: 'Temporary Credit Case',
        recordType: 'Request'
    },
    {
        type: 'Debit Card',
        subType: 'Temporary Credit',
        requestType: 'Temporary Credit Case',
        recordType: 'Request'
    },
    {
        type: 'EFTs',
        subType: 'Temporary Credit',
        requestType: 'Temporary Credit Case',
        recordType: 'Request'
    },
    {
        type: 'Swift Transfer',
        subType: 'Temporary Credit',
        requestType: 'Temporary Credit Case',
        recordType: 'Request'
    }
];

export function getRecordTypeId(type, subType, requestType) {
    const recordTypeEntry = recordTypeConfig.find(
        (item) =>
            item.type === type &&
            item.subType === subType &&
            item.requestType === requestType
    );

    return recordTypeEntry ? recordTypeEntry.recordType : null;
}