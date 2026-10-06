/* 		Organization : ABC Bank
 * 		Created By: ABC Support
 *		Created Date: 07-10-2019
 * 		Change History: 
 *			   
 *             #CH02 : #Jahangeer Mohammed# #13-04-2025# Added Logic to check duplicate Id number (PI-3973)
 *  		   #CH03 : #Jahangeer Mohammed# #13-05-2025# Added Logic for Onboarding Document Number Enhancements(NBA-13626)
 * 		       #CH04 : #Jahangeer Mohammed# #06-10-2025# Added Logic for restricting mobile country codes(NBA-15878)
			   #CH05 : #Jahangeer Mohammed# #27-08-2026# Added Logic for restricting mobile country codes Jordan(NBA-17747)
 */
({
    doInit: function (component, event, helper) {
        helper.init(component);
        helper.WathiqConsentFormValidation(component);

        component.set("v.isUpdateSuccessful", false);
        component.set("v.isFetchIGASuccessful", false);
        component.set("v.isLoading", false);
    },
    onEditClick: function (component, event, helper) {
        component.set('v.mode', 'edit');
        component.set("v.isSavedOnBoarding", false);

        component.set("v.isUpdateSuccessful", false);
        component.set("v.isFetchIGASuccessful", false);
    },

    fetchIGAData: function (component, event, helper) {
        console.log('========== fetchIGAData STARTED ==========');
        console.log('Method: fetchIGAData() called');
        component.set("v.isLoading", true);
        try {
            // Get child components
            console.log('Getting child components...');
            var childIdInformation = component.find('idInformation');
            var childPersonInformation = component.find('personalDetail');
            var childContactInformation = component.find('contactInformation');

            console.log('Child components retrieved:');
            console.log('- idInformation: ', childIdInformation ? 'Found' : 'NOT FOUND');
            console.log('- personalDetail: ', childPersonInformation ? 'Found' : 'NOT FOUND');
            console.log('- contactInformation: ', childContactInformation ? 'Found' : 'NOT FOUND');

            // Validation
            if (!childContactInformation) {

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: "error",
                    title: "Contact Information Missing",
                    message: "Please validate the Contact Information section before fetching IGA data."
                });
                toastEvent.fire();
                component.set("v.isLoading", false);
                return; // Stop further execution
            }

            // Get values from contact information
            console.log('Getting contact information values...');
            var personEmail = childContactInformation.find("personEmail").get("v.value");
            var countryISOCode = childContactInformation.find("countryISOCode").get("v.value");
            var personMobileNumber = childContactInformation.find("personMobileNumber").get("v.value");

            console.log('Contact Information Values:');
            console.log('- personEmail: ', personEmail);
            console.log('- countryISOCode: ', countryISOCode);
            console.log('- personMobileNumber: ', personMobileNumber);

            // Get values from ID information
            console.log('Getting ID information values...');
            var idNumber = childIdInformation.find("idNumber").get("v.value");
            var idNationality = childIdInformation.find("idNationality").get("v.value");
            var idExpiryDate = childIdInformation.find("idExpiryDate").get("v.value");

            console.log('ID Information Values:');
            console.log('- idNumber: ', idNumber);
            console.log('- idNationality: ', idNationality);
            console.log('- idExpiryDate: ', idExpiryDate);

            // Get values from person information
            console.log('Getting personal information values...');
            var birthdate = childPersonInformation.find("birthdate").get("v.value");
            var gender = childPersonInformation.find("gender").get("v.value");
            var nationality = childPersonInformation.find("nationality").get("v.value");

            console.log('Personal Information Values:');
            console.log('- birthdate: ', birthdate);
            console.log('- gender: ', gender);
            console.log('- nationality: ', nationality);

            // Individual field validations
            console.log('Starting field validations...');

            // Consolidated validation
            console.log('========== Starting Validation ==========');

            let validationErrors = [];

            // Check each field and collect error messages
            if (!personEmail || personEmail.trim() === '') {
                console.error('VALIDATION FAILED: Person Email is empty');
                validationErrors.push('Person Email cannot be empty.');
            } else {
                console.log('✓ Person Email validation passed');
            }

            if (!countryISOCode || countryISOCode.trim() === '') {
                console.error('VALIDATION FAILED: Country ISO Code is empty');
                validationErrors.push('Country ISO Code cannot be empty.');
            } else {
                console.log('✓ Country ISO Code validation passed');
            }

            if (!personMobileNumber || personMobileNumber.trim() === '') {
                console.error('VALIDATION FAILED: Person Mobile Number is empty');
                validationErrors.push('Person Mobile Number cannot be empty.');
            } else {
                console.log('✓ Person Mobile Number validation passed');
            }

            if (!idNumber || idNumber.trim() === '') {
                console.error('VALIDATION FAILED: ID Number is empty');
                validationErrors.push('ID Number cannot be empty.');
            } else {
                console.log('✓ ID Number validation passed');
            }

            if (!idNationality || idNationality.trim() === '') {
                console.error('VALIDATION FAILED: ID Nationality is empty');
                validationErrors.push('ID Nationality cannot be empty.');
            } else {
                console.log('✓ ID Nationality validation passed');
            }

            if (!idExpiryDate || idExpiryDate.trim() === '') {
                console.error('VALIDATION FAILED: ID Expiry Date is empty');
                validationErrors.push('ID Expiry Date cannot be empty.');
            } else {
                console.log('✓ ID Expiry Date validation passed');
            }

            if (!birthdate || birthdate.trim() === '') {
                console.error('VALIDATION FAILED: Birthdate is empty');
                validationErrors.push('Birthdate cannot be empty.');
            } else {
                console.log('✓ Birthdate validation passed');

                // ADDITIONAL VALIDATION: Check if person is under 18
                console.log('Checking if person is under 18 years old...');
                var birthDateObj = new Date(birthdate);
                var today = new Date();
                var age = today.getFullYear() - birthDateObj.getFullYear();
                var monthDiff = today.getMonth() - birthDateObj.getMonth();

                // Adjust age if birthday hasn't occurred this year
                if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDateObj.getDate())) {
                    age--;
                }

                console.log('Calculated age: ', age, 'years');

                var guardianCIFFromChild = component.get('v.guardianCIFFromChild');
                console.log('guardianCIFFromChild: ', guardianCIFFromChild);

                if (age < 18 && (!guardianCIFFromChild || guardianCIFFromChild.trim() === '')) {
                    console.error('VALIDATION FAILED: Person is under 18 years old (Age: ' + age + ')');
                    validationErrors.push('Guardian is required. Person must be at least 18 years old.');
                } else {
                    console.log('✓ Age validation passed (Age: ' + age + ' years)');
                }
            }

            if (!gender || gender.trim() === '') {
                console.error('VALIDATION FAILED: Gender is empty');
                validationErrors.push('Gender cannot be empty.');
            } else {
                console.log('✓ Gender validation passed');
            }

            if (!nationality || nationality.trim() === '') {
                console.error('VALIDATION FAILED: Nationality is empty');
                validationErrors.push('Nationality cannot be empty.');
            } else {
                console.log('✓ Nationality validation passed');
            }

            // If there are validation errors, show a single consolidated notice
            if (validationErrors.length > 0) {
                console.log(`Showing error notice with ${validationErrors.length} validation error(s)`);

                // Create a formatted message with all errors
                let errorMessage = 'Please fix the following errors:\n\n';
                validationErrors.forEach((error, index) => {
                    errorMessage += `• ${error}\n`;
                });

                component.find('idValNotice').showNotice({
                    "variant": "error",
                    "header": `Validation Error${validationErrors.length > 1 ? 's' : ''}!`,
                    "message": errorMessage,
                    closeCallback: function () {
                        console.log('Error notice closed');
                    }
                });

                component.set("v.isLoading", false);
                console.log('========== fetchIGAData ENDED (Validation Failed) ==========');
                return;
            }

            console.log('✓ All validations passed');
            console.log('========== Validation Complete ==========');

            console.log('✅ ALL VALIDATIONS PASSED');
            console.log('All validations passed, proceeding with fetchIGAData...');

            var caseId = component.get("v.recordId");
            console.log('Case ID from component attribute: ', caseId);

            // Call the Apex method directly
            console.log('Preparing to call Apex method: validateeKeyDocumentsSimple');
            var action1 = component.get("c.validateeKeyDocumentsSimple");
            action1.setParams({
                "caseId": caseId,
                "nationality": nationality
            });

            console.log('Parameters set for validateeKeyDocumentsSimple:');
            console.log('- caseId: ', caseId);
            console.log('- nationality: ', nationality);

            action1.setCallback(this, function (response) {
                console.log('Callback received for validateeKeyDocumentsSimple');
                console.log('Response state: ', response.getState());

                if (response.getState() === "SUCCESS") {
                    console.log('✅ Apex call validateeKeyDocumentsSimple SUCCESS');
                    var result = response.getReturnValue();
                    console.log('Return value from validateeKeyDocumentsSimple: ', result);

                    if (result === 'SUCCESS') {
                        console.log('✅ Document validation SUCCESS - proceeding to verifyEKeyPerson');

                        var account = component.get("v.account");
                        console.log('Account from component attribute: ', account);

                        var regionName = account.Region_Flag__c;
                        console.log('Region Name from account: ', regionName);

                        // Get parameters for the second call
                        var customerId = component.get("v.customerId");
                        // Note: idNumber is already declared above, reusing it
                        var idCountry = idNationality;
                        var expiryDate = idExpiryDate;
                        var dateOfBirth = birthdate;
                        // Note: gender is already declared above
                        // Note: nationality is already declared above
                        var guardianCIF = '1157411';
                        // Note: regionName is already set above

                        console.log('Parameters for verifyEKeyPerson:');
                        console.log('- customerId: ', customerId);
                        console.log('- idNumber: ', idNumber);
                        console.log('- idCountry: ', idCountry);
                        console.log('- expiryDate: ', expiryDate);
                        console.log('- dateOfBirth: ', dateOfBirth);
                        console.log('- gender: ', gender);
                        console.log('- nationality: ', nationality);
                        console.log('- guardianCIF: ', guardianCIF);
                        console.log('- regionName: ', regionName);

                        var account = component.get("v.account");
                        var custId = account.CIF__pc;
                        var guardCIF = component.get("v.guardianCIFFromChild");

                        // Second: Call verifyEKeyPerson
                        console.log('Preparing to call Apex method: verifyEKeyPerson');
                        var action2 = component.get("c.verifyEKeyPerson");
                        action2.setParams({
                            "customerId": custId,
                            "idNumber": idNumber,
                            "idCountry": idCountry,
                            "expiryDate": expiryDate,
                            "dateOfBirth": dateOfBirth,
                            "gender": gender,
                            "nationality": nationality,
                            "guardianCIF": guardCIF,
                            "regionName": regionName
                        });

                        action2.setCallback(this, function (response2) {
                            console.log('Callback received for verifyEKeyPerson');
                            console.log('Response state: ', response2.getState());
                            component.set("v.isLoading", false);

                            if (response2.getState() === "SUCCESS") {
                                console.log('✅ Apex call verifyEKeyPerson SUCCESS');
                                var result2 = response2.getReturnValue();
                                console.log('Return value from verifyEKeyPerson: ', JSON.stringify(result2));

                                if (result2.success) {
                                    console.log('✅ E-Key verification SUCCESS');
                                    console.log('Success message: ', result2.message);

                                    // Show green toast for E-Key verification success
                                    console.log('Showing success toast notification');
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "type": "success",
                                        "title": "Success",
                                        "message": "Consent registered and IGA data retrieved successfully"
                                    });
                                    toastEvent.fire();

                                    // For eKey cases, set the success flag to show next stage buttons
                                    if (component.get("v.case.Origin") == 'eKey') {
                                        component.set("v.isFetchIGASuccessful", true);
                                        // Keep in edit mode but update button state
                                        component.set("v.mode", "edit");
                                        console.log('final data --->', result2.data);

                                        if (result2 && result2.data && result2.data.data && result2.data.data.igaData) {
                                            try {
                                                var finalData = result2.data.data.igaData;  // Notice the extra .data
                                                var accountDetail = component.get("v.account");

                                                if (!accountDetail) {
                                                    console.error('accountDetail is undefined');
                                                    return;
                                                }

                                                console.log('Original account:', JSON.stringify(accountDetail));
                                                console.log('IGA Data received:', finalData);

                                                // DIRECTLY UPDATE THE EXISTING OBJECT - DON'T CREATE A NEW ONE
                                                accountDetail.FirstName = finalData.enFirstName;

                                                accountDetail.MiddleName = [finalData.enMiddleName1, finalData.enMiddleName2, finalData.enMiddleName3, finalData.enMiddleName4]
                                                    .filter(name => name && name.trim() !== '')
                                                    .join(' ');

                                                console.log('MiddleName', accountDetail.MiddleName);

                                                accountDetail.LastName = finalData.enLastName;

                                                accountDetail.Arabic_Name__pc = [
                                                    finalData.arFirstName,
                                                    finalData.arMiddleName1,
                                                    finalData.arMiddleName2,
                                                    finalData.arMiddleName3,
                                                    finalData.arMiddleName4,
                                                    finalData.arLastName
                                                ]
                                                    .filter(name => name && name.trim() !== '')
                                                    .join(' ');

                                                console.log('Arabic Name', accountDetail.Arabic_Name__pc);

                                                // More compact approach without optional chaining
                                                let streetParts = [];

                                                if (finalData.customerAddress) {
                                                    if (finalData.customerAddress.flatNumber) {
                                                        streetParts.push('Flat ' + finalData.customerAddress.flatNumber);
                                                    }

                                                    if (finalData.customerAddress.buildingNumber || finalData.customerAddress.buildingAlpha) {
                                                        let buildingPart = 'Bldg ';
                                                        if (finalData.customerAddress.buildingNumber) buildingPart += finalData.customerAddress.buildingNumber;
                                                        if (finalData.customerAddress.buildingAlpha) buildingPart += finalData.customerAddress.buildingAlpha;
                                                        streetParts.push(buildingPart);
                                                    }

                                                    if (finalData.customerAddress.roadNumber) {
                                                        streetParts.push('Road ' + finalData.customerAddress.roadNumber);
                                                    }
                                                }

                                                accountDetail.PersonMailingStreet = streetParts.join(' ');

                                                console.log('Mailing Street', accountDetail.PersonMailingStreet);

                                                accountDetail.PersonMailingPostalCode = finalData.customerAddress.blockNumber;
                                                accountDetail.PersonMailingCountry = finalData.cardCountry2Digits;
                                                accountDetail.Residency__pc = 'BH';
                                                accountDetail.Proof_of_Address_ID_Type__pc = 'IGA';
                                                accountDetail.Passport_Number__pc = finalData.passportNumber;

                                                // CALL WITH helper.convertToISODate
                                                if (finalData.passportExpiryDate) {
                                                    accountDetail.Passport_Expiry_Date__pc = helper.convertToISODate(finalData.passportExpiryDate);
                                                }

                                                accountDetail.Residency_Permit_Number__pc = finalData.residentPermitNo;

                                                if (finalData.residentPermitExpiry) {
                                                    accountDetail.Residency_Permit_Expiry__pc = helper.convertToISODate(finalData.residentPermitExpiry);
                                                }

                                                accountDetail.employer_name__pc = finalData.employmentInfo.employerName;
                                                accountDetail.Business_Address__pc = 'Flat ' + finalData.employmentInfo.employerAddress.flatNumber + ' Bldg ' + finalData.employmentInfo.employerAddress.buildingNumber + '' + finalData.employmentInfo.employerAddress.buildingAlpha + ' Road ' + finalData.employmentInfo.employerAddress.roadNumber;
                                                accountDetail.Marital_Status__pc = finalData.maritalStatus;
                                                accountDetail.Gender__pc = finalData.gender;
                                                accountDetail.Nationality__pc = finalData.customerNationalityTwoChars;
                                                accountDetail.ID_Number__pc = finalData.idNumber;
                                                accountDetail.Proof_of_Address_Id__pc = finalData.idNumber;
                                                accountDetail.Place_of_birth_government__pc = finalData.placeOfBirth;
                                                accountDetail.PersonMailingCity = finalData.mailingCity;

                                                console.log('Updated account:', accountDetail);

                                                if (guardCIF) {
                                                    var guardIdNumber = component.get("v.guardianIdNumberFromChild");
                                                    accountDetail.Guardian_CIF__c = guardCIF;
                                                    accountDetail.Minor__pc = true;
                                                    accountDetail.Guardian_CPR__pc = guardIdNumber;
                                                }

                                                // SET THE SAME OBJECT BACK
                                                component.set("v.account", accountDetail);

                                                // Force a refresh
                                                component.set("v.account", component.get("v.account"));

                                                console.log('Account final', JSON.stringify(accountDetail));

                                            } catch (e) {
                                                console.error('Error updating account:', e);
                                                console.error('Error details:', e.message);
                                                console.error('Stack trace:', e.stack);
                                            }
                                        } else {
                                            console.error('Invalid response structure:', result2);
                                            if (result2 && result2.data) {
                                                console.log('result2.data keys:', Object.keys(result2.data));
                                                if (result2.data.data) {
                                                    console.log('result2.data.data keys:', Object.keys(result2.data.data));
                                                }
                                            }
                                        }
                                    }

                                    console.log('✅ Process completed successfully');

                                } else {
                                    console.error('❌ E-Key verification FAILED');
                                    console.error('Failure message: ', result2.message);

                                    // Show red toast for E-Key verification failure
                                    console.log('Showing error toast notification');
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "type": "error",
                                        "title": "E-Key Verification Failed",
                                        "message": result2.message || "E-Key verification failed. Please try again."
                                    });
                                    toastEvent.fire();
                                    console.log('⚠️ Process stopped - E-Key verification failed');
                                }

                            } else if (response2.getState() === "ERROR") {
                                console.error('❌ Apex call verifyEKeyPerson ERROR');
                                // Handle Apex errors for second call
                                var errors = response2.getError();
                                console.error('Apex errors: ', JSON.stringify(errors));

                                var errorMessage = "An error occurred during E-Key verification.";

                                if (errors && errors[0] && errors[0].message) {
                                    errorMessage = errors[0].message;
                                    console.error('Primary error message: ', errorMessage);
                                }

                                console.log('Showing error toast notification');
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": "error",
                                    "title": "Error",
                                    "message": errorMessage
                                });
                                toastEvent.fire();
                            } else if (response2.getState() === "INCOMPLETE") {
                                console.error('❌ Apex call verifyEKeyPerson INCOMPLETE');
                                console.error('Response incomplete');
                            } else if (response2.getState() === "ABORTED") {
                                console.error('❌ Apex call verifyEKeyPerson ABORTED');
                                console.error('Response aborted');
                            }

                            console.log('========== verifyEKeyPerson Callback ENDED ==========');
                        });

                        console.log('Enqueuing verifyEKeyPerson action...');
                        $A.enqueueAction(action2);
                        console.log('verifyEKeyPerson action enqueued');

                    } else {
                        console.error('❌ Document validation FAILED');
                        console.error('Validation result: ', result);

                        // Show red toast and stop
                        console.log('Showing error toast notification');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "error",
                            "title": "Document Validation Failed",
                            "message": result
                        });
                        toastEvent.fire();
                        console.log('⚠️ Process stopped - document validation failed');

                        // ✅ Turn OFF loader here
                        component.set("v.isLoading", false);
                    }
                }
                else if (response.getState() === "ERROR") {
                    console.error('❌ Apex call validateeKeyDocumentsSimple ERROR');
                    // Handle Apex errors for first call
                    var errors = response.getError();
                    console.error('Apex errors: ', JSON.stringify(errors));

                    var errorMessage = "An error occurred during document validation.";

                    if (errors && errors[0] && errors[0].message) {
                        errorMessage = errors[0].message;
                        console.error('Primary error message: ', errorMessage);
                    }

                    console.log('Showing error toast notification');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error",
                        "message": errorMessage
                    });
                    toastEvent.fire();

                    // ✅ Turn OFF loader here
                    component.set("v.isLoading", false);
                } else if (response.getState() === "INCOMPLETE") {
                    console.error('❌ Apex call validateeKeyDocumentsSimple INCOMPLETE');
                    console.error('Response incomplete');

                    // ✅ Turn OFF loader here
                    component.set("v.isLoading", false);
                } else if (response.getState() === "ABORTED") {
                    console.error('❌ Apex call validateeKeyDocumentsSimple ABORTED');
                    console.error('Response aborted');

                    // ✅ Turn OFF loader here
                    component.set("v.isLoading", false);
                }
                console.log('========== validateeKeyDocumentsSimple Callback ENDED ==========');
            });

            console.log('Enqueuing validateeKeyDocumentsSimple action...');
            $A.enqueueAction(action1);
            console.log('validateeKeyDocumentsSimple action enqueued');

        } catch (error) {
            console.error('❌ UNEXPECTED ERROR in fetchIGAData method');
            console.error('Error name: ', error.name);
            console.error('Error message: ', error.message);
            console.error('Error stack: ', error.stack);

            // Show error toast for unexpected errors
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Unexpected Error",
                "message": "An unexpected error occurred. Please try again."
            });
            toastEvent.fire();

            // ✅ Turn OFF loader here
            component.set("v.isLoading", false);
        }

        console.log('========== fetchIGAData ENDED ==========');
        // Note: The final component.set("v.isLoading", false); has been removed
        // Loader will be turned off in the callbacks
    },

    onCancelClick: function (component, event, helper) {

        component.set('v.account', JSON.parse(JSON.stringify(component.get('v.accountOld'))));
        component.set('v.mode', 'view');

        component.set("v.isUpdateSuccessful", false);
        component.set("v.isFetchIGASuccessful", false);
        component.set("v.isLoading", false);
    },

    onSaveClick: function (component, event, helper) {
        var account = component.get("v.account");
        var customerId = account.CIF__pc;
        var caseId = component.get('v.recordId');
        helper.save(component, account, customerId, caseId);
    },

    onSaveFieldUpdate: function (component, event, helper) {
        var englishRegex = /^[A-Za-z0-9 ]+$/;
        var arabicRegex = /^[\u0600-\u06FF\s]+$/;
        //var tab = event.getSource();
        //helper.getProspectSource(component, event, helper);

        //Sopha Pum: 17-11-2020: To avoid error script when cannot find idInformation
        try {
            var childPersonInformation = component.find('personalDetail');
            var childIdInformation = component.find('idInformation');
            console.log("childIdInformation:", childIdInformation);
			console.log("Is Array:", Array.isArray(childIdInformation));
            var additionalInformation = component.find('additionalInformation');
            //var isValidationSuccess = childIdInformation.doValidityCheckMethod;
            var idType = childIdInformation.find("idType").get("v.value");
            var poaIdType = childIdInformation.find("poaIdType").get("v.value");
            var idNumber = childIdInformation.find("idNumber").get("v.value");
            var poaIdNumber = childIdInformation.find("poaIdNumber").get("v.value");
            var passportNumber = childIdInformation.find("passportNumber").get("v.value");
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            //CH03: Start
            var passportDate = childIdInformation.find("passExpiry").get("v.value");
            console.log('Passport Date:', passportDate);
            var dateResultPassPort = new Date();
            var ppValidation = $A.localizationService.formatDate(dateResultPassPort, "YYYY-MM-DD");
            console.log('Passport Validation Date:', ppValidation);
            //CH03: END
            var rpdate = childIdInformation.find("rpExpiryDate").get("v.value");
            var nationality = childPersonInformation.find("nationality").get("v.value");

            var account = component.get("v.account");
            var regionName = account.Region_Flag__c;

            var caseObject = component.get("v.case");
            var caseSubject = (caseObject.Subject ? caseObject.Subject : "");

            if (regionName == 'Jordan') {
                var mailingArea = childPersonInformation.find("mailingArea").get("v.value");
                var mailingStreet = childPersonInformation.find("mailingStreet").get("v.value");
                var mailingBuildingNumber = childPersonInformation.find("mailingBuildingNumber").get("v.value");
                var mailingApartmentNumber = childPersonInformation.find("mailingApartmentNumber").get("v.value");
                var arabicName = childPersonInformation.find("arabicName").get("v.value");

                var expectedMonthlyDeposit = additionalInformation.find("expectedMonthlyDeposit").get("v.value");
                var employerAddress = additionalInformation.find("employerAddress").get("v.value");
                var employerCity = additionalInformation.find("employerCity").get("v.value");
                var occupation = additionalInformation.find("occupation").get("v.value");

                var depositRegex = /^\d{1,16}(\.\d{1,2})?$/;

                console.log('caseSubject ===>', caseSubject);
                console.log('expectedMonthlyDeposit ===>', !expectedMonthlyDeposit);
                console.log('final ===>', (!expectedMonthlyDeposit && caseSubject == 'Onboarding Verification Required'));

                if (!expectedMonthlyDeposit && caseSubject == 'Onboarding Verification Required') {
                    component.find('idValNotice').showNotice({
                        "variant": "error",
                        "header": "Expected Monthly Deposit is Required!",
                        "message": "Expected Monthly Deposit is a required field and cannot be empty.",
                        closeCallback: function () { }
                    });
                    return;
                }

                if (expectedMonthlyDeposit && !depositRegex.test(expectedMonthlyDeposit)) {
                    component.find('idValNotice').showNotice({
                        "variant": "error",
                        "header": "Invalid Expected Monthly Deposit!",
                        "message": "Expected Monthly Deposit must be up to 16 digits with an optional decimal and a maximum of 2 decimal places.",
                        closeCallback: function () { }
                    });
                    return;
                }

                if (employerAddress && employerAddress.length > 255) {
                    component.find('idValNotice').showNotice({
                        "variant": "error",
                        "header": "Invalid Employer Address!",
                        "message": "Employer Address cannot exceed 255 characters.",
                        closeCallback: function () { }
                    });
                    return;
                }

                if (employerCity && employerCity.length > 200) {
                    component.find('idValNotice').showNotice({
                        "variant": "error",
                        "header": "Invalid Employer City!",
                        "message": "Employer City cannot exceed 200 characters.",
                        closeCallback: function () { }
                    });
                    return;
                }

                if (occupation && occupation.length > 255) {
                    component.find('idValNotice').showNotice({
                        "variant": "error",
                        "header": "Invalid Occupation!",
                        "message": "Occupation cannot exceed 255 characters.",
                        closeCallback: function () { }
                    });
                    return;
                }

                if (passportNumber && passportNumber.length > 20) {
                    component.find('idValNotice').showNotice({
                        "variant": "error",
                        "header": "Invalid Passport Document Number!",
                        "message": "Passport Document Number cannot exceed 20 characters.",
                        closeCallback: function () { }
                    });
                    return;
                }

                if (mailingArea && mailingArea.length > 100) {
                    component.find('idValNotice').showNotice({
                        "variant": "error",
                        "header": "Invalid Mailing Area!",
                        "message": "Mailing Area cannot exceed 100 characters.",
                        closeCallback: function () { }
                    });
                    return;
                }

                if (mailingBuildingNumber && mailingBuildingNumber.length > 50) {
                    component.find('idValNotice').showNotice({
                        "variant": "error",
                        "header": "Invalid Mailing Building Number!",
                        "message": "Mailing Building Number cannot exceed 50 characters.",
                        closeCallback: function () { }
                    });
                    return;
                }

                console.log('mailingApartmentNumber --->', mailingApartmentNumber);
                console.log('mailingApartmentNumber length--->', mailingApartmentNumber.length);
                console.log('final --->', (mailingApartmentNumber && mailingApartmentNumber.length > 50));

                if (mailingApartmentNumber) {

                    // Check if only numbers
                    const isNumeric = /^\d+$/.test(mailingApartmentNumber);

                    if (!isNumeric) {
                        component.find('idValNotice').showNotice({
                            variant: "error",
                            header: "Invalid Mailing Apartment Number!",
                            message: "Mailing Apartment Number should contain only numbers.",
                            closeCallback: function () { }
                        });
                        return;
                    }

                    // Check length
                    if (mailingApartmentNumber.length > 50) {
                        component.find('idValNotice').showNotice({
                            variant: "error",
                            header: "Invalid Mailing Apartment Number!",
                            message: "Mailing Apartment Number cannot exceed 50 characters.",
                            closeCallback: function () { }
                        });
                        return;
                    }
                }

                if (mailingStreet && mailingStreet.length > 50) {
                    component.find('idValNotice').showNotice({
                        "variant": "error",
                        "header": "Invalid Mailing Street!",
                        "message": "Mailing Street cannot exceed 50 characters.",
                        closeCallback: function () { }
                    });
                    return;
                }

                if ((mailingArea && !englishRegex.test(mailingArea)) ||
                    (mailingStreet && !englishRegex.test(mailingStreet)) ||
                    (mailingBuildingNumber && !englishRegex.test(mailingBuildingNumber)) ||
                    (mailingApartmentNumber && !englishRegex.test(mailingApartmentNumber))) {

                    component.find('idValNotice').showNotice({
                        "variant": "error",
                        "header": "Invalid Mailing Address Details",
                        "message": "The address fields should be in English only. No special characters or Arabic letters allowed.",
                        closeCallback: function () { }
                    });

                    return;
                }

                if (arabicName) {
                    // Check if any character is NOT Arabic or space
                    var nonArabicChars = arabicName.match(/[^\u0600-\u06FF\s]/g);

                    console.log('nonArabicChars -->', nonArabicChars);

                    if (nonArabicChars && nonArabicChars.length > 0) {
                        component.find('idValNotice').showNotice({
                            "variant": "error",
                            "header": "Invalid Arabic Name",
                            "message": "The Arabic name field should contain only Arabic characters. Found non-Arabic characters: " + nonArabicChars.join(', '),
                            closeCallback: function () { }
                        });

                        return;
                    }
                }
                
                var finalMailingAddress = '';
                
                finalMailingAddress = mailingArea;
                if (mailingStreet) finalMailingAddress += ', ' + mailingStreet;
                if (mailingBuildingNumber) finalMailingAddress += ', ' + mailingBuildingNumber;
                if (mailingApartmentNumber) finalMailingAddress += ', ' + mailingApartmentNumber;
                
                childPersonInformation.find("mailingStreet").set("v.value", finalMailingAddress);
                
                
            }

            // In your controller where you call the methods
            var caseObject = component.get("v.case");
            var caseOrigin = (caseObject.Origin ? caseObject.Origin : "");
            console.log('Controller: caseOrigin =', caseOrigin, 'caseId =', caseObject.Id);

            var dateResultRp = new Date();
            //dateResultRp.setDate(dateResultRp.getDate() + 30);
            var rpValidation = $A.localizationService.formatDate(dateResultRp, "YYYY-MM-DD");
            //CH03: Start
            if (passportDate < ppValidation) {
                //error condition
                component.find('idValNotice').showNotice({
                    "variant": "error",
                    "header": "Please check the Passport Expiry Date!",
                    "message": "Passport Expiry Date should be greater than or equal current date.",
                    closeCallback: function () { }
                });
                return;
            }
            //CH03: END
            //CH04: Start
            //CH05: Start
            let invalidCountryCodes = [];
            if(regionName == 'Bahrain') {
            	invalidCountryCodes = $A.get("$Label.c.INVALID_COUNTRY_CODE").split(',');
            }else if(regionName == 'Jordan'){
                invalidCountryCodes = $A.get("$Label.c.INVALID_COUNTRY_CODE_JO").split(',');
            }
            //CH05: END
            var childcontactInformation = component.find('contactInformation');
            var mobileCountryCode = childcontactInformation.find("countryISOCode").get("v.value");

            let userCode = mobileCountryCode ? mobileCountryCode.replace(/\s+/g, '').trim() : '';

            if (invalidCountryCodes.includes(userCode)) {
                //error condition
                component.find('idValNotice').showNotice({
                    "variant": "error",
                    "header": "Please check the Mobile Country Code!",
                    "message": "Restricted country code for mobile number. Please use different country code",
                    closeCallback: function () { }
                });
                return;

            }
            //CH04: END
            if (rpdate < rpValidation && nationality != 'BH') {
                //error condition
                component.find('idValNotice').showNotice({
                    "variant": "error",
                    "header": "Please check the Resident Permit Expiry Date!",
                    "message": "RP Expiry Date Must be greater than or equal current date for Non Bahrain Nationality.",
                    closeCallback: function () { }
                });
                return;
            }
            //IF “Account.ID_Type__pc” = “Passport” or “Bahraini ID” AND “Account. Proof_of_Address_ID_Type__c” = “Bahraini Drivers Licence” THEN “Account.ID_Number__c” and “Account.Proof_of_Address_Id__c” must be equal. If not equal, display alert.
            if ((idType == "Passport" || idType == "Bahraini ID") && (poaIdType == "Bahraini Drivers Licence") && (idNumber != poaIdNumber)) {
                console.log('Validation is NOT');
                component.find('idValNotice').showNotice({
                    "variant": "error",
                    "header": "Please check the ID numbers!",
                    "message": "If the ID Type is 'Passport' or 'Bahraini ID', and the Proof of Address ID Type is 'Bahraini Drivers Licence', then the ID Number and Proof of Address Id must match",
                    closeCallback: function () { }
                });
                return;
            } else {
                console.log('Validation is successfull');
            }
        } catch (error) {
            console.log('Error id ', error);
        }

        //check validation
        if (!helper.isValidAccount(component)) {
            // alert('Validation Failed');
            return;
        }
        //CH02: Start

        helper.checkDuplicateIdNumber(component, helper);
        //helper.saveFieldUpdate(component);
        //CH01 : CRM22-10 : CRM - eKYC Case Description Modification
        //console.log('After helper.saveFieldUpdate to update Case Field on IGA Data Tab');
        //component.find("eKYCDataOnOnboardingCase").find('caseViewForm').submit();
        //CH01 : END
        //CH02: END
    },

    doContinuOnboarding: function (component, event, helper) {

        var account = component.get("v.account");
        var caseId = component.get("v.recordId");
        var caseObject = component.get("v.case");
        var customerId = account.CIF__pc;
        var email = account.PersonEmail;
        var caseType = (caseObject.Type ? caseObject.Type : "");
        caseType = caseType.toLowerCase();
        var caseOrigin = (caseObject.Origin ? caseObject.Origin : "");
        caseOrigin = caseOrigin.toLowerCase();

        var childPersonInformation = component.find('personalDetail');
        var childIdInformation = component.find('idInformation');
        var childcontactInformation = component.find('contactInformation');

        var requestBody = {};

        // Build request body for non-wathiq cases
        if (caseOrigin != 'wathiq') {
            requestBody = {
                "caseId": caseId,
                "caseStatus": (caseType == 'identification' ? 'All Documents Uploaded' : (caseType == 'name screening' ? 'Verified' : caseObject.Status)),
                "caseType": (caseObject.Type ? caseObject.Type : ""),
                "caseOutcome": (caseObject.Child_Case_Closure_Recommendation__c ? caseObject.Child_Case_Closure_Recommendation__c : ""),
               // "email": account.PersonEmail
                "email":(caseObject.Contact && caseObject.Contact.Email ? caseObject.Contact.Email : "")
            };
        }

        // Build request body for wathiq cases
        if (caseOrigin == 'wathiq') {
            requestBody = {
                "caseId": caseId,
                "caseStatus": 'Approved',
                "caseType": "Wathiq",
                "email": (caseObject.Contact && caseObject.Contact.Email ? caseObject.Contact.Email : "")
            };
        }

        console.log('caseOrigin --->', caseOrigin);

        if (caseOrigin == 'ekey') {
            // ID_MANUAL_ENTRY
            /*   requestBody = {
                   "manualStopReason": "ekey_issue",
                   "email": (caseObject.Contact && caseObject.Contact.Email ? caseObject.Contact.Email : ""),
                   "state": "ID_MANUAL_ENTRY",
                   "manualStopReasonId": "",
                   "manualStopDescription": "I have an issue with ekey"
               };*/
            requestBody = {
                "email": (caseObject.Contact && caseObject.Contact.Email ? caseObject.Contact.Email : ""),
                "caseStatus": (caseType == 'identification' ? 'All Documents Uploaded' : (caseType == 'name screening' ? 'Verified' : caseObject.Status)),
                "caseType": (caseObject.Type ? caseObject.Type : "")
            };

            console.log('Controller: eKey case detected, checking duplication and onboarding');

            // Get values from components
            var personEmail = childcontactInformation.find("personEmail").get("v.value");
            var personMobileNumber = childcontactInformation.find("personMobileNumber").get("v.value");
            var idNumber = childIdInformation.find("idNumber").get("v.value");

            console.log('personEmail :', personEmail);
            console.log('personMobileNumber :', personMobileNumber);
            console.log('idNumber :', idNumber);

            // Get nationality - assuming this field exists in personalDetail component
            var nationality = '';
            if (childPersonInformation && childPersonInformation.find("nationality")) {
                nationality = childPersonInformation.find("nationality").get("v.value");
            }

            console.log('Controller: Collected values - Email:', personEmail, 'Mobile:', personMobileNumber, 'ID:', idNumber, 'Nationality:', nationality);

            // Set loading state
            // component.set("v.isLoading", true);

            // Create a promise for the duplication check
            var duplicationPromise = new Promise(function (resolve, reject) {
                helper.checkDuplicationWithPromise(component, caseObject.Id, personEmail, personMobileNumber, customerId, resolve, reject);
            });

            // Chain the promises properly
            duplicationPromise
                .then($A.getCallback(function (duplicationResult) {
                    console.log('Controller: Duplication check completed with result:', duplicationResult);

                    if (duplicationResult !== 'SUCCESS') {
                        // Throw an error to break the promise chain and go to catch block
                        throw new Error(duplicationResult);
                    }

                    // Only proceed to onboarding check if no duplicates found
                    return new Promise(function (resolve, reject) {
                        helper.checkOnboardingStatusWithPromise(component, caseObject.Id, nationality, resolve, reject);
                    });
                }))
                .then($A.getCallback(function (onboardingResult) {
                    console.log('Controller: Onboarding status check completed with result:', onboardingResult);

                    if (onboardingResult !== true) {
                        // Throw an error if onboarding cannot continue
                        throw new Error('Cannot continue onboarding due to missing documents or other issues');
                    }

                    // Only continue onboarding if both previous checks passed
                    console.log('Controller: Both checks passed, calling continueOnboarding');
                    return helper.continueOnboardingForEkey(component, account, caseId, customerId, email, "Continue On boarding", requestBody);
                }))
                .then($A.getCallback(function (finalResult) {
                    console.log('Controller: All eKey onboarding steps completed successfully');
                    //component.set("v.isLoading", false);
                }))
                .catch($A.getCallback(function (error) {
                    console.error('Controller: Error in eKey onboarding flow:', error);
                    //component.set("v.isLoading", false);

                    // Extract just the error message without the framework wrapper
                    var errorMessage = error.message || error.toString();

                    // Check if it contains the Aura framework wrapper
                    if (errorMessage.includes('Error in $A.getCallback() [')) {
                        // Extract just the message between the brackets
                        var startIndex = errorMessage.indexOf('[') + 1;
                        var endIndex = errorMessage.lastIndexOf(']');
                        if (startIndex > 0 && endIndex > startIndex) {
                            errorMessage = errorMessage.substring(startIndex, endIndex);
                        }
                    }

                    // Also check for common Aura error patterns
                    if (errorMessage.includes('AuraHandledException: ')) {
                        errorMessage = errorMessage.replace('AuraHandledException: ', '');
                    }

                    console.log('Extracted error message:', errorMessage);

                    // Show error toast
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Onboarding Error",
                        "message": errorMessage
                    });
                    toastEvent.fire();
                }));

        } else {
            helper.continueOnboarding(component, account, caseId, customerId, email, "Continue On boarding", requestBody);
        }
    },

    doManualContinueOnboarding: function (component, event, helper) {
        console.log('---->In Manual Onboarding Controller Class ');
        var account = component.get("v.account");
        var caseId = component.get("v.recordId");
        var caseObject = component.get("v.case");
        var customerId = account.CIF__pc;
        var email = account.PersonEmail;
        var caseType = (caseObject.Type ? caseObject.Type : "");
        var reqBody = {
            "caseId": caseId,
            "caseStatus": (caseType == 'identification' ? 'All Documents Uploaded' : (caseType == 'name screening' ? 'Verified' : caseObject.Status)),
            "caseType": (caseObject.Type ? caseObject.Type : ""),
            "email": (caseObject.Contact && caseObject.Contact.Email ? caseObject.Contact.Email : "")

        };

        //Sopha Pum - 13-11-2020: update change request
        // If the case origin = Wathiq then send the following through the API:
        // {
        //     "email":"{{userId}}",
        //     "caseType":"Wathiq",
        //     "caseStatus":"Approved"
        // }
        if (caseType == 'wathiq') {
            requestBody = {
                "caseId": caseId,
                //if Case.Type == ‘Identification’. If the user clicks on the 'Continue Onboarding' button,
                //we will send a message to the Continue Onboarding API and pass "casestatus" : "All Documents Uploaded".
                "caseStatus": 'Approved',
                "caseType": "Wathiq",
                "email": (caseObject.Contact && caseObject.Contact.Email ? caseObject.Contact.Email : "")
            };
        }

        helper.continueManualOnboarding(component, account, caseId, customerId, email, "Continue Manual On-boarding", reqBody);
    },
    geteKYCdetails: function (component, event, helper) {
        helper.eKYCHelper(component);
    },

    handleGuardianCIFUpdate: function (component, event, helper) {
        var guardianCIF = event.getParam("guardianCIF");
        var guardianIdNumber = event.getParam("guardianIdNumber");
        component.set("v.guardianCIFFromChild", guardianCIF);
        component.set("v.guardianIdNumberFromChild", guardianIdNumber);
        console.log("Received from child - CIF: " + guardianCIF + ", ID Number: " + guardianIdNumber);
    }
})