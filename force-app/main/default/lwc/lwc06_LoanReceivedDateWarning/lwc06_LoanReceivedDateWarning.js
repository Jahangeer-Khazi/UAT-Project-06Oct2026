import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import TIME_ZONE from '@salesforce/i18n/timeZone';

import OWNER_ID_FIELD from '@salesforce/schema/Case.OwnerId';
import OWNER_CHANGE_DATE_FIELD from '@salesforce/schema/Case.Owner_Change_Date__c';
import GROUP_DEVELOPER_NAME_FIELD from '@salesforce/schema/Group.DeveloperName';

const CASE_FIELDS = [
    OWNER_ID_FIELD,
    OWNER_CHANGE_DATE_FIELD
];

const EXPECTED_QUEUE_DEVELOPER_NAME =
    'Loan_Finance_Operations_Processing_Queue';

export default class Lwc06_LoanReceivedDateWarning extends LightningElement {
    @api recordId;

    ownerId;
    ownerChangeDate;
    queueDeveloperName;

    caseError;
    queueError;

    /**
     * Retrieves the Case owner and Owner Change Date.
     */
    @wire(getRecord, {
        recordId: '$recordId',
        fields: CASE_FIELDS
    })
    wiredCase({ data, error }) {
        if (data) {
            this.ownerId = getFieldValue(data, OWNER_ID_FIELD);
            this.ownerChangeDate = getFieldValue(
                data,
                OWNER_CHANGE_DATE_FIELD
            );

            this.queueDeveloperName = undefined;
            this.caseError = undefined;
        } else if (error) {
            this.ownerId = undefined;
            this.ownerChangeDate = undefined;
            this.queueDeveloperName = undefined;
            this.caseError = error;

            // eslint-disable-next-line no-console
            console.error(
                'Lwc06_LoanReceivedDateWarning: Error retrieving Case',
                error
            );
        }
    }

    /**
     * Salesforce Group and Queue record IDs start with 00G.
     *
     * Returning undefined prevents the Group wire adapter from running
     * when the Case owner is a User.
     */
    get queueRecordId() {
        return this.ownerId?.startsWith('00G')
            ? this.ownerId
            : undefined;
    }

    /**
     * Retrieves the queue Developer Name.
     */
    @wire(getRecord, {
        recordId: '$queueRecordId',
        fields: [GROUP_DEVELOPER_NAME_FIELD]
    })
    wiredQueue({ data, error }) {
        if (data) {
            this.queueDeveloperName = getFieldValue(
                data,
                GROUP_DEVELOPER_NAME_FIELD
            );

            this.queueError = undefined;
        } else if (error) {
            this.queueDeveloperName = undefined;
            this.queueError = error;

            // eslint-disable-next-line no-console
            console.error(
                'Lwc06_LoanReceivedDateWarning: Error retrieving queue',
                error
            );
        }
    }

    /**
     * Displays the warning only when:
     *
     * 1. The Case owner is the expected queue.
     * 2. Owner_Change_Date__c has a value.
     * 3. Its date is earlier than today.
     */
    get showWarning() {
        return (
            !this.caseError &&
            !this.queueError &&
            this.isExpectedQueue &&
            this.isOwnerChangeDateBeforeToday
        );
    }

    get isExpectedQueue() {
        return (
            this.queueDeveloperName ===
            EXPECTED_QUEUE_DEVELOPER_NAME
        );
    }

    /**
     * Compares only YYYY-MM-DD values.
     *
     * The time component is ignored for DateTime fields.
     */
    get isOwnerChangeDateBeforeToday() {
        if (!this.ownerChangeDate) {
            return false;
        }

        const ownerChangeDateOnly = this.getDateOnly(
            this.ownerChangeDate
        );

        const todayDateOnly = this.getDateOnly(new Date());

        if (!ownerChangeDateOnly || !todayDateOnly) {
            return false;
        }

        /*
         * YYYY-MM-DD strings can be compared lexicographically.
         *
         * Same day: false
         * Previous day: true
         * Future day: false
         */
        return ownerChangeDateOnly < todayDateOnly;
    }

    /**
     * Converts a Salesforce Date or DateTime into YYYY-MM-DD.
     *
     * Salesforce Date:
     * 2026-07-25
     *
     * Salesforce DateTime:
     * 2026-07-25T15:30:00.000Z
     */
    getDateOnly(value) {
        if (!value) {
            return undefined;
        }

        /*
         * A Salesforce Date field is already returned as YYYY-MM-DD.
         */
        if (
            typeof value === 'string' &&
            /^\d{4}-\d{2}-\d{2}$/.test(value)
        ) {
            return value;
        }

        const dateValue =
            value instanceof Date
                ? value
                : new Date(value);

        if (Number.isNaN(dateValue.getTime())) {
            return undefined;
        }

        const dateParts = new Intl.DateTimeFormat('en-GB', {
            timeZone: TIME_ZONE,
            year: 'numeric',
            month: '2-digit',
            day: '2-digit'
        }).formatToParts(dateValue);

        const year = dateParts.find(
            (part) => part.type === 'year'
        )?.value;

        const month = dateParts.find(
            (part) => part.type === 'month'
        )?.value;

        const day = dateParts.find(
            (part) => part.type === 'day'
        )?.value;

        if (!year || !month || !day) {
            return undefined;
        }

        return `${year}-${month}-${day}`;
    }

    get formattedReceivedDate() {
        if (!this.ownerChangeDate) {
            return '';
        }

        /*
         * Prevents timezone shifts when the Salesforce field is a Date.
         */
        if (
            typeof this.ownerChangeDate === 'string' &&
            /^\d{4}-\d{2}-\d{2}$/.test(this.ownerChangeDate)
        ) {
            const [year, month, day] = this.ownerChangeDate
                .split('-')
                .map(Number);

            return new Intl.DateTimeFormat('en-GB', {
                day: '2-digit',
                month: 'long',
                year: 'numeric'
            }).format(new Date(year, month - 1, day));
        }

        const dateValue = new Date(this.ownerChangeDate);

        if (Number.isNaN(dateValue.getTime())) {
            return this.ownerChangeDate;
        }

        return new Intl.DateTimeFormat('en-GB', {
            timeZone: TIME_ZONE,
            day: '2-digit',
            month: 'long',
            year: 'numeric'
        }).format(dateValue);
    }
}