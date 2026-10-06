import { LightningElement,api,wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import PDFLib from '@salesforce/resourceUrl/pdfMergeLibrary';
import getFileData from '@salesforce/apex/LoanDocuSignDocumentListController.getFileData';
import { getRecord } from 'lightning/uiRecordApi';

// Define the fields you need
import CONTACT_NAME from '@salesforce/schema/Case.Contact_Name__c';
import ID_CPR_NUMBER from '@salesforce/schema/Case.cc_ID_Number__c';
import DOB from '@salesforce/schema/Case.cc_Date_of_Birth__c';
import CUSTOMER_CIF from '@salesforce/schema/Case.Customer_CIF__c';
import MOBILE_NUMBER from '@salesforce/schema/Case.cc_Mobile_Number__c';
import CREATED_DATE from '@salesforce/schema/Case.CreatedDate';
import EMAIL from '@salesforce/schema/Case.cc_Email_Address__c';

export default class FullLoanApplicationReview extends LightningElement {

    _recordId;

    @api
    set recordId(value) {
        this._recordId = value;
        console.log('recordId:', value);

        if (!this.pdfLibJs) {
            loadScript(this, PDFLib)
                .then(() => {
                    this.pdfLibJs = window.PDFLib;
                    console.log('PDFLib script loaded successfully.');
                })
                .catch((error) => {
                    console.error('Error loading PDFLib: ', error);
                    this.isLoading = false;
                });
        }
    }

    get recordId() {
        return this._recordId;
    }

    docData = [];
    error;
    pdfLibJs;
    previewUrl;
    isLoading = false;
    isRendered = false;
    noDocumentToShow = false;
    isLoaded = false;
    blobValue;
    caseRecord;
    hasCaseData = false; // Track if case data is loaded
    hasDocData = false; // Track if document data is loaded

    // Fetch Case data
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [CONTACT_NAME, ID_CPR_NUMBER, DOB, CUSTOMER_CIF, MOBILE_NUMBER, CREATED_DATE, EMAIL]
    })
    wiredCase({ error, data }) {
        console.log("case data ",data);
        if (data) {
            this.caseRecord = {
                contactName: data.fields.Contact_Name__c?.value || '',
                idCprNumber: data.fields.cc_ID_Number__c?.value || '',
                dob: data.fields.cc_Date_of_Birth__c?.value || '',
                customerCif: data.fields.Customer_CIF__c?.value || '',
                mobileNumber: data.fields.cc_Mobile_Number__c?.value || '',
                age: data.fields.cc_Date_of_Birth__c ? this.calculateAge(data.fields.cc_Date_of_Birth__c) : '',
                createdDate: data.fields.CreatedDate?.value || '',
                email: data.fields.cc_Email_Address__c?.value || ''
            };
            console.log('this.caseRecord -->', JSON.stringify(this.caseRecord));
            this.hasCaseData = true;
            this.error = undefined;
            this.fetchData();
            
            // Check if we can create PDF now
            this.tryCreatePdf();
        } else if (error) {
            this.error = error;
            this.caseRecord = undefined;
            this.hasCaseData = false;
        }
    }


    get modifiedPreviewUrl() {
        return this.previewUrl ? `${this.previewUrl}#toolbar=0` : '';
    }

    renderedCallback(){
        //code
        console.log("rendered callback = ",this.recordId);
    }

    connectedCallback() {
        console.log("connected callback = ",this.recordId);
        //this.fetchData();
    }

    fetchData(){
        this.isLoading = true;
        if (this.recordId) {
            getFileData({ caseId: this.recordId })
                .then((result) => {
                    this.docData = JSON.parse(JSON.stringify(result));
                    console.log("result from file data ",this.docData);
                    if(this.docData.length == 0){
                        this.noDocumentToShow = true;
                    }
                    else {
                        this.noDocumentToShow = false;
                    }
                    // Check if we can create PDF now
                    this.tryCreatePdf();
                })
                .catch((error) => {
                    console.error('Error fetching data: ', error);
                    this.error = error;
                    this.isLoading = false;
                });
        }
    }

    // Try to create PDF only when all required data is available
    tryCreatePdf() {
        // Check if all prerequisites are met
        if (!this.pdfLibJs) {
            console.log('PDFLib not loaded yet');
            return;
        }

        // Now we have all data, proceed with PDF creation
        if (this.docData.length > 0) {
            
            try {
                this.createPdf();
            } catch (error) {
                console.error('Error creating PDF:', error);
                this.isLoading = false;
            } finally {
                this.isLoading = false;
            }
        }
        else {
            this.isLoading = false;
        }
    }

    async createPdf() {

        const pdfDoc = await this.pdfLibJs.PDFDocument.create();

        // Create a new page for the summary section
        const summaryPage = pdfDoc.addPage([600, 400]);
        const { height, width } = summaryPage.getSize();
        const font = await pdfDoc.embedFont(this.pdfLibJs.StandardFonts.HelveticaBold);

        // **1. Add "Credit Card Summary" Header**
        summaryPage.drawText('Loan/Finance Summary Review', {
            x: width / 2 - 100,
            y: height - 50,
            size: 20,
            font,
            color: this.pdfLibJs.rgb(0, 0, 0),
        });

        // **4. Customer Information**
            summaryPage.drawText(`Customer Name: ${this.caseRecord.contactName}`, { x: 50, y: height - 100, size: 12, font });
            summaryPage.drawText(`ID/CPR Number: ${this.caseRecord.idCprNumber}`, { x: 300, y: height - 100, size: 12, font });
            summaryPage.drawText(`DOB: ${this.caseRecord.dob}`, { x: 50, y: height - 120, size: 12, font });
            summaryPage.drawText(`CIF: ${this.caseRecord.customerCif}`, { x: 300, y: height - 120, size: 12, font });
            summaryPage.drawText(`Mobile Number: ${this.caseRecord.mobileNumber}`, { x: 50, y: height - 140, size: 12, font });
            summaryPage.drawText(`Email: ${this.caseRecord.email}`, { x: 300, y: height - 140, size: 12, font });

        // **2. Add a black separator line**
        summaryPage.drawLine({
            start: { x: 50, y: height - 70 },
            end: { x: width - 50, y: height - 70 },
            thickness: 2,
            color: this.pdfLibJs.rgb(0, 0, 0),
        });

        // **5. Draw a Line Before "Documents" Section**
        summaryPage.drawLine({
            start: { x: 50, y: height - 155 },
            end: { x: 550, y: height - 155 },
            thickness: 1,
        });

        // **6. Add Text Before the Numbered List**
        summaryPage.drawText('This summary includes the following documents:', {
            x: 50,
            y: height - 180,
            size: 14,
            font,
            fontWeight: 'bold'
        });

        // **7. Numbered List of Documents**
        const docList = [
            '1. Loan Calculation Summary',
            '2. Docusign Documents List',
            '3. DocuSign Consolidate List',
            '4. Loan Repayment Schedule'
        ];

        let docY = height - 210;

        docList.forEach(doc => {
            summaryPage.drawText(doc, {
                x: 70,
                y: docY,
                size: 12,
                font
            });
            docY -= 20;
        });

        // Process all document data
        for (let i = 0; i < this.docData.length; i++) {
            const fileObj = this.docData[i];

            try {
                const tempBytes = Uint8Array.from(atob(fileObj.fileData), (c) => c.charCodeAt(0));
                const fileHeader = tempBytes.slice(0, 4).join(',');
                if (fileHeader === '37,80,68,70') {
                    const loadedPdf = await this.pdfLibJs.PDFDocument.load(tempBytes);
                    const pages = loadedPdf.getPages();
                    console.log("Total Pages ",pages);
                    if (pages.length > 0) {
                        for (const page of pages) {
                            const embeddedPage = await pdfDoc.embedPage(page);

                            //If pdf is Calculation Summary or LoanSummary, it should have landscape orientation.
                            if(fileObj.fileTitle == 'CalculationSummary' || fileObj.fileTitle == 'LoanSummary'){ 
                                const newPage = pdfDoc.addPage([842,595]);
                                newPage.drawPage(embeddedPage);
                            }
                            else {
                                const newPage = pdfDoc.addPage();
                                newPage.drawPage(embeddedPage);
                            }
                            
                            
                            

                            /*newPage.drawText('This', {
                                x: 50,
                                y: height - 180,
                                size: 14,
                                font,
                                fontWeight: 'bold'
                            });*/
                        }
                    } else {
                        console.error(`No pages found in PDF at index ${i}`);
                    }
                } else if (fileHeader.startsWith('255,216') || fileHeader.startsWith('137,80,78,71')) {
                    const newPage = pdfDoc.addPage();

                    let embeddedImage;
                    if (fileHeader.startsWith('255,216')) {
                        embeddedImage = await pdfDoc.embedJpg(tempBytes);
                    } else if (fileHeader.startsWith('137,80,78,71')) {
                        embeddedImage = await pdfLib.embedPng(tempBytes);
                    }

                    const { width: imgWidth, height: imgHeight } = embeddedImage;
                    const pageWidth = newPage.getWidth();
                    const pageHeight = newPage.getHeight();
                    const widthScale = pageWidth / imgWidth;
                    const heightScale = pageHeight / imgHeight;
                    const scale = Math.min(widthScale, heightScale);
                    const scaledWidth = imgWidth * scale;
                    const scaledHeight = imgHeight * scale;
                    const xOffset = (pageWidth - scaledWidth) / 2;
                    const yOffset = (pageHeight - scaledHeight) / 2;

                    newPage.drawImage(embeddedImage, {
                        x: xOffset,
                        y: yOffset,
                        width: scaledWidth,
                        height: scaledHeight,
                    });
                } else {
                    console.error(`Unknown file type at index ${i}`);
                    continue;
                }
            } catch (error) {
                console.error(`Error processing file at index ${i}:`, error);
                continue;
            }
        }

        const pdfBytes = await pdfDoc.save();
        console.log('Final PDF generated with byte length:', pdfBytes.length);
        this.setPreviewUrl(pdfBytes);
        this.isLoading = false;
    }

    // Set the preview URL for the iframe
    setPreviewUrl(byte) {
        const blob = new Blob([byte], { type: 'application/pdf' });
        this.previewUrl = URL.createObjectURL(blob);
        console.log('Preview URL set:', this.previewUrl);
        this.blobValue = blob;
    }

    // Trigger download with the desired filename
    triggerDownload() {
        if (!this.blobValue) {
            console.error('No PDF available for download');
            return;
        }
        
        console.log("creating pdf...");
        const url = URL.createObjectURL(this.blobValue);
        const a = document.createElement('a');
        a.href = url;
        // Use safe case record for filename
        //const caseRecord = this.safeCaseRecord;
        a.download = 'LoanApplicationSummary_' + this.caseRecord.customerCif + '_v1.pdf';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    }

    calculateAge(dob) {
        const birthDate = new Date(dob);
        const today = new Date();
        const monthsBetween = (today.getFullYear() - birthDate.getFullYear()) * 12 + (today.getMonth() - birthDate.getMonth());
        return Math.floor(monthsBetween / 12);
    }

}