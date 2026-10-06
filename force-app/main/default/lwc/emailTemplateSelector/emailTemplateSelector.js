import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendEmailWithAttachment from '@salesforce/apex/EmailTemplateController.sendEmailWithAttachment';
import getCaseDetailsAndTemplates from '@salesforce/apex/EmailTemplateController.getCaseDetailsAndTemplates';
import checkFileSizeAndDelete from '@salesforce/apex/EmailTemplateController.checkFileSizeAndDelete';
import { CloseActionScreenEvent } from 'lightning/actions';

const TEMPLATE_MAPPING = {
    "Request": {
        "Official letter": {
            "Bank statement": {
                "Credit card": ["Official_Letter"],
                "Account": ["Official_Letter"]
            },
            "Outstanding letter": {
                "Credit card": ["Official_Letter"],
                "Loans": ["Official_Letter"]
            },
            "No Liability Letter": {
                "Credit card": ["Official_Letter"],
                "Loans": ["Official_Letter"]
            },
            "No objection letter": {
                "Customer Request": ["Official_Letter"]
            },
            "Debit Authority letter": {
                "Customer Request": ["Official_Letter"]
            },
            "Embassy referance letter": {
                "Customer Request": ["Official_Letter"]
            },
            "Gaurdianship form": {
                "Customer Request": ["Official_Letter"]
            },
            "Temporary credit declaration": {
                "Customer Request": ["Official_Letter"]
            },
            "Permenant Debit card limit": {
                "Customer Request": ["Official_Letter"]
            },
            "Referance Letter": {
                "Customer Request": ["Official_Letter"]
            },
            "University letter": {
                "Customer Request": ["Official_Letter"]
            },
            "Loan Outstanding Balance Certificate": {
                "Credit card": ["Official_Letter"],
                "Loans": ["Official_Letter"]
            }
        },
        "Account": {
            "Dormant": {
                "Reactivation": [
                    "Dormant_Account_Re_acivation_requirements",
                    "Account_Re_activation_confirmation"
                ]
            },
            "Profile Update": {
                "Address": [
                    "Proof_of_Address_Request_Email",
                    "Profile_Update_Confirmation_Email"
                ],
                "Email": ["Profile_update_confirmation"]
            },
            "Manual transfer": {
                "Internal (Between accounts)": [
                    "Manual_Transfer_Form_email",
                    "Manual_Transfer_Completion_Email"
                ],
                "External - SWIFT (international)": [
                    "Manual_Transfer_Form_email",
                    "Manual_Transfer_Completion_Email"
                ],
                "External - EFTS (local)": [
                    "Manual_Transfer_Form_email",
                    "Completion_Confirmation_SWIFT_Copy"
                ]
            }
        },
        "": {
            "": {
                "": ["No_Answer","No_Answer_Fraud","Business_Use_Prohibition_Awareness","Official_Letter"]
            }
        }
    },
    "Complaint": {
        "": {
            "": {
                "": ["No_Answer", "Unregistered_Email_Address", "No_Answer_Fraud","Business_Use_Prohibition_Awareness","Official_Letter"]
            }
        }
    },
    "Feedback": {
        "": {
            "": {
                "": ["No_Answer", "Unregistered_Email_Address", "No_Answer_Fraud","Business_Use_Prohibition_Awareness","Official_Letter"]
            }
        }
    },
    "Service_Request": {
        "": {
            "": {
                "": ["No_Answer", "Unregistered_Email_Address", "No_Answer_Fraud","Business_Use_Prohibition_Awareness","Official_Letter"]
            }
        }
    },
    "Case_Disputes_and_Frauds": {
        "": {
            "": {
                "": ["No_Answer", "No_Answer_Fraud","Business_Use_Prohibition_Awareness","Official_Letter"]
            }
        },
        "Benefit": {
            "ATM": {
                "Did not receive cash from ATM": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Partial Amount Dispensed": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Financial Impact Fraudulent / Unauthorized": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "No Financial Impact Fraudulent/Un authorized": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ]
            },
            "POS / E-Commerce": {
                "Transaction did not go through": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Duplicate payment": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Purchased goods not received": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Transaction amount differs": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Late posted transaction": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Refund not processed": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Service Not Provided": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Other (Specify in description)": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Financial Impact Fraudulent / Unauthorized": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "No Financial Impact Fraudulent/Un authorized": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ]
            }
        },
        "MasterCard": {
            "ATM": {
                "Did not receive cash from ATM": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Partial Amount Dispensed": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Financial Impact Fraudulent / Unauthorized": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "No Financial Impact Fraudulent/Un authorized": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ]
            },
            "POS / E-Commerce": {
                "Transaction did not go through": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Duplicate payment": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Purchased goods not received": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Transaction amount differs": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Late posted transaction": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Refund not processed": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Service Not Provided": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Other (Specify in description)": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "Financial Impact Fraudulent / Unauthorized": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ],
                "No Financial Impact Fraudulent/Un authorized": [
                    "Proof_Required",
                    "Dispute_Rejected",
                    "Dispute_Accepted_Refunded"
                ]
            }
        }
    },
    "Case_Faults_and_Incidents": {
        "": {
            "": {
                "": ["No_Answer", "No_Answer_Fraud","Business_Use_Prohibition_Awareness","Official_Letter"]
            }
        }
    },
    "Internal_Case": {
        "Customer Services": {
            "Overdraft": {
                "": [
                    "Amount_recovery_notification_about_debit",
                    "First_email_Notification_to_Cover_OD_amount",
                    "Final_notification_to_cover_the_OD"
                ]
            }
        },
        "": {
            "": {
                "": ["No_Answer_Fraud","Business_Use_Prohibition_Awareness","Official_Letter","No_Answer"]
            }
        }
    },
    "Block_Unblock_Account": {
        "": {
            "": {
                "": ["No_Answer_Fraud","Business_Use_Prohibition_Awareness","Official_Letter","No_Answer"]
            }
        }
    }
};

const MAX_FILE_SIZE = 15 * 1024 * 1024; // 15 MB

export default class EmailTemplateSelector extends LightningElement {
    @api recordId;
    @track templates = [];
    @track filteredTemplates = [];
    @track selectedTemplateId;
    @track vfPageUrl;
    @track contentDocumentId;
    @track uploadedFileName;
    @track fileName;
    @track currentStep = 'templateSelection';
    @track isLoading = false;
    @track caseDetails = {};

    // Email details
    @track toAddress = 'ranjith.mathiyalagan@bank-abc.com';
    @track fromAddress = 'support@ilabank.com';
    @track emailSubject = 'Your Case Number 00458217';

    // Transform templates into table-compatible format
    get templateOptions() {
        return this.templates.map(template => ({
            label: template.Name,
            value: template.Id,
            description: template.Description || 'No description available',
            isSelected: this.selectedTemplateId === template.Id
        }));
    }

    // Calculate table height based on number of templates
    get templateTableHeight() {
        const rowHeight = 48; // Approximate height of each row in pixels
        const maxVisibleRows = 3;
        const headerHeight = 42; // Height of table header

        if (this.templates.length > maxVisibleRows) {
            const height = (maxVisibleRows * rowHeight) + headerHeight;
            return `max-height: ${height}px; overflow-y: auto;`;
        }
        return '';
    }

    // Getter for button disabled state
    get isNextButtonDisabled() {
        return !this.selectedTemplateId;
    }

    get isSendButtonDisabled() {
        return !this.contentDocumentId;
    }

    get showTemplateSelection() {
        return this.currentStep === 'templateSelection';
    }

    get showEmailPreview() {
        return this.currentStep === 'emailPreview';
    }

    @wire(getCaseDetailsAndTemplates, { recordId: '$recordId' })
    wiredCaseDetails({ error, data }) {
        if (data) {
            this.caseDetails = data.caseDetails;
            const allTemplates = data.allTemplates;

            this.toAddress = this.caseDetails.toAddress;
            this.emailSubject = 'Your Case Number ' + this.caseDetails.caseNumber;

            // Filter templates based on case details and mapping
            this.filteredTemplates = this.filterTemplatesBasedOnCase(
                allTemplates,
                this.caseDetails.recordType,
                this.caseDetails.type,
                this.caseDetails.subType,
                this.caseDetails.requestType
            );

            // If no templates found, show all as fallback
            this.templates = this.filteredTemplates.length > 0 ? this.filteredTemplates : allTemplates;
        } else if (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    filterTemplatesBasedOnCase(allTemplates, recordType, type, subType, requestType) {
        try {
            console.log('Starting template filtering with parameters:', {
                recordType,
                type,
                subType,
                requestType
            });

            // Clean inputs (handle null/undefined)
            recordType = recordType || '';
            type = type || '';
            subType = subType || '';
            requestType = requestType || '';

            console.log('Cleaned parameters:', {
                recordType,
                type,
                subType,
                requestType
            });

            // Initialize array to collect matching template names
            let templateDevNames = [];
            let matchedPaths = [];

            // Get all type paths for this recordType
            const recordTypePaths = TEMPLATE_MAPPING[recordType] || {};

            console.log(`Found ${Object.keys(recordTypePaths).length} paths for recordType ${recordType}`);

            // Check all possible type paths under this recordType
            for (const typePath in recordTypePaths) {
                // Only process the specific type or the generic path
                if (typePath !== type && typePath !== '') continue;

                const typeObj = recordTypePaths[typePath];
                console.log(`Checking type path: ${typePath}`);

                // Get all subType paths for this type
                for (const subTypePath in typeObj) {
                    // Only process the specific subType or the generic path
                    if (subTypePath !== subType && subTypePath !== '') continue;

                    const subTypeObj = typeObj[subTypePath];
                    console.log(`Checking subType path: ${subTypePath}`);

                    // Get all requestType paths for this subType
                    for (const requestTypePath in subTypeObj) {
                        // Only process the specific requestType or the generic path
                        if (requestTypePath !== requestType && requestTypePath !== '') continue;

                        const templates = subTypeObj[requestTypePath];
                        console.log(`Found matching path: ${recordType} > ${typePath} > ${subTypePath} > ${requestTypePath}`);
                        console.log(`Templates found: ${templates.join(', ')}`);

                        templateDevNames = templateDevNames.concat(templates);
                        matchedPaths.push(`${recordType} > ${typePath} > ${subTypePath} > ${requestTypePath}`);
                    }
                }
            }

            console.log('All matched paths:', matchedPaths);
            console.log('All matched template names before deduplication:', templateDevNames);

            // Remove duplicates
            templateDevNames = [...new Set(templateDevNames)];
            console.log('Unique matched template names:', templateDevNames);

            // Filter templates based on matched developer names
            const filteredTemplates = allTemplates.filter(template =>
                templateDevNames.includes(template.DeveloperName)
            );

            console.log('Final filtered templates:', filteredTemplates.map(t => t.DeveloperName));

            // If specific matches are found, return them; otherwise, fall back to all templates
            return filteredTemplates.length > 0 ? filteredTemplates : allTemplates;
        } catch (e) {
            console.error('Error filtering templates:', e);
            console.log('Error occurred, returning all templates as fallback');
            return allTemplates;
        }
    }

    // Handle template selection via checkbox
    handleTemplateSelection(event) {
        const templateId = event.target.dataset.id;
        this.selectedTemplateId = templateId;
        this.vfPageUrl = `/apex/EmailTemplatePreview?id=${this.selectedTemplateId}&caseId=${this.recordId}`;
        // Trigger re-render to update checkbox states
        this.templates = [...this.templates];
    }

    // Handle file upload
    handleUploadFinished(event) {
        //this.showToast('Success', 'File uploaded successfully', 'success');
        const uploadedFiles = event.detail.files;
        console.log('uploadedFiles -->', JSON.stringify(uploadedFiles));
        if (uploadedFiles.length > 0) {
            this.isLoading = true;
            this.contentDocumentId = uploadedFiles[0].documentId;
            this.uploadedFileName = uploadedFiles[0].name;

            checkFileSizeAndDelete({
                contentDocumentId: this.contentDocumentId,
                maxSize: MAX_FILE_SIZE
            })
                .then(result => {
                    if (result.isValid) {
                        this.showToast('Success', 'File uploaded successfully', 'success');

                        // Set file name based on case type
                        if (this.caseDetails.type == 'Account' &&
                            this.caseDetails.subType == 'Dormant' &&
                            this.caseDetails.requestType == 'Reactivation') {
                            this.fileName = this.uploadedFileName + ', KYC_Profile_Form.pdf';
                        } else {
                            this.fileName = this.uploadedFileName;
                        }
                    } else {
                        // File was too large and deleted
                        this.showToast('Error', 'File exceeds 15MB limit and was deleted', 'error');
                        this.contentDocumentId = null;
                        this.uploadedFileName = null;
                    }
                })
                .catch(error => {
                    this.showToast('Error', error.body?.message || 'Error processing file', 'error');
                    this.contentDocumentId = null;
                    this.uploadedFileName = null;
                })
                .finally(() => {
                    this.isLoading = false;
                });
        }
    }

    // Handle next button click
    handleNext() {
        this.currentStep = 'emailPreview';
    }

    // Handle back button click
    handleBack() {
        this.currentStep = 'templateSelection';
    }

    // Handle send email
    handleSendEmail() {
        this.isLoading = true;
        sendEmailWithAttachment({
            templateId: this.selectedTemplateId,
            recordId: this.recordId,
            contentDocumentId: this.contentDocumentId,
            toAddress: this.toAddress,
            fromAddress: this.fromAddress,
            subject: this.emailSubject
        })
            .then(() => {
                this.showToast('Success', 'Email sent successfully', 'success');
                // Reset form
                this.currentStep = 'templateSelection';
                this.selectedTemplateId = null;
                this.contentDocumentId = null;
                this.uploadedFileName = null;
                this.fileName = null;
                this.isLoading = false;
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
                this.isLoading = false;
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}