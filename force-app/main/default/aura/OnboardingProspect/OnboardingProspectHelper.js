/* 		Organization : ABC Bank
 * 		Created By: ABC Support
 *		Created Date: 07-10-2019
 * 		Change History: 
 *			   
 *             #CH02 : #Jahangeer Mohammed# #13-04-2025# Added Logic to check duplicate Id number (PI-3973)
 *
 */
({
    init: function (component) {
        component.find('apexService').request(component.get('c.getCaseAccount'), {
            caseId: component.get("v.recordId")
        },
                                              function (response) {
                                                  var result = response.getReturnValue();
                                                  console.log("result>>>", result);
                                                  component.set("v.case", result);
                                                  component.set("v.account", result.Account);
                                                  component.set("v.accountOld", JSON.parse(JSON.stringify(result.Account)));
                                                  console.log("result Account>>>", JSON.parse(JSON.stringify(result.Account)));
                                                  
                                                  component.set("v.isUpdateSuccessful", false);
                                                  component.set("v.isFetchIGASuccessful", false);
                                                  component.set("v.isLoading", false);
                                              });
        
        this.loadProfileVisibility(component);
    },
    
    
    save: function (component, account, customerId, caseId) {
        //delete read only field
        delete account.Name;
        
        component.find('apexService').request(component.get('c.updateProfile'), {
            acc: account,
            customerId: customerId,
            caseId: caseId,
            personEmail: account.PersonEmail,
            regionName: account.Region_Flag__c
        },
                                              function (response) {
                                                  //this.init(component);
                                                  var result = response.getReturnValue();
                                                  if (true === result.isSuccess) {
                                                      component.set('v.accountOld', JSON.parse(JSON.stringify(account)));
                                                      component.find('apexService').showSuccessMessage("Request successful");
                                                      
                                                      component.set("v.mode", "view");
                                                      
                                                      // refresh the standard page view
                                                      $A.get('e.force:refreshView').fire();
                                                  }
                                              });
    },
    
    saveFieldUpdate: function (cmp) {
        
        var account = cmp.get("v.account");
        var guardianCIF = cmp.get("v.guardianCIFFromChild");
        account.Guardian_CIF__pc = guardianCIF;
        
        cmp.find('apexService').request(cmp.get('c.doSaveFieldUpdate'), {
            acc: account
        },
                                        function (response) {
                                            //this.init(component);
                                            console.log("res", response);
                                            var result = response.getReturnValue();
                                            if (true === result.isSuccess) {
                                                cmp.set("v.isSavedOnBoarding", true);
                                                if (cmp.get("v.case.Origin") != 'eKey') {
                                                    cmp.find('apexService').showSuccessMessage("Record has saved! Please click Continue On Boarding button.");
                                                }
                                            }
                                        });
    },
    
    continueOnboarding: function (component, account, caseId, customerId, email, actionName, requestBody) {
        var self = this;
        console.log(">>>>>>sending onboarding");
        //delete read only field
        console.log('requeeeeeeeeestBody'+JSON.stringify(requestBody));
        delete account.Name;
        component.find('apexService').request(component.get('c.sendOnboardingContinue'), {
            acc: account,
            caseId: caseId,
            customerId: customerId,
            actionName: actionName,
            requestBody: JSON.stringify(requestBody),
            email: email,
            regionName: account.Region_Flag__c
        },
                                              function (response) {
                                                  
                                                  console.log(">>>>>>response onboarding", response);
                                                  //this.init(component);
                                                  var result = response.getReturnValue();
                                                  if (true === result.isSuccess) {
                                                      component.find('apexService').showSuccessMessage("Onboarding Request successful!");
                                                      component.set("v.mode", "view");
                                                      
                                                  }
                                              });
    },
    
    continueManualOnboarding: function (component, account, caseId, customerId, email, actionName, reqBody) {
        console.log('---->In Manual Onboarding Helper Class ');
        var action = component.get("c.sendManualOnboardingRequest");
        action.setParams({
            caseId: caseId,
            customerId: customerId,
            actionName: actionName,
            requestBody: JSON.stringify(reqBody),
            email: email,
            regionName: account.Region_Flag__c
        });
        console.log('----> REQUEST Body --> ');
        console.log(reqBody);
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('---> SUCCESS Response-->');
                console.log(response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                console.log('---> INCOMPLETE --> ');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
        
    },
    
    loadProfileVisibility: function (component) {
        component.find('apexService').request(component.get('c.loadCusProVisibility'), {},
                                              function (response) {
                                                  var result = response.getReturnValue();
                                                  if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                                                      var proVisibility = result.responseData;
                                                      if (proVisibility.Field_Read_Only__c) {
                                                          var strFields = proVisibility.Field_Read_Only__c;
                                                          strFields = strFields.toLowerCase();
                                                          var lstFields = (strFields.indexOf(",") > -1 ? strFields.split(",") : [strFields]);
                                                          var mapField = {};
                                                          lstFields.forEach(function (field) {
                                                              mapField[field] = 1;//put number 1 just to set value for mapping
                                                          });
                                                          component.set("v.readOnlyFields", mapField);
                                                      }
                                                  }
                                              });
    },
    
    isValidAccount: function (cmp) {
        var acc = cmp.get("v.account");
        var caseObject = cmp.get("v.case");
        var caseSubject = (caseObject.Subject ? caseObject.Subject : "");
        var hasErr = true;
        var lstErrs = [];
        
        console.log(">>>>", acc.FirstName);
        
        // Basic required fields (always checked)
        if (!acc.FirstName) lstErrs.push('FirstName');
        if (!acc.LastName) lstErrs.push('LastName');
        if (!acc.Nationality__pc) lstErrs.push('Nationality');
        if (!acc.PersonBirthdate) lstErrs.push('Birthdate');
        if (!acc.ID_Number__pc) lstErrs.push('ID Number');
        if (!acc.PersonMailingCountry) lstErrs.push('Mailing Country');
        if (!acc.PersonMailingCity) lstErrs.push('Mailing City');
        if (!acc.Place_of_birth_government__pc) lstErrs.push('Place of birth government');
        if (!acc.PersonMailingStreet) lstErrs.push('Mailing Street');
        if (!acc.Arabic_Name__pc) lstErrs.push('Arabic Name');
        
        // Region-specific validations
        var regionFlag = acc.Region_Flag__c;
        var nationality = acc.Nationality__pc;
        
        if (regionFlag == 'Jordan') {
            // Jordan-specific validations
            if (!acc.MiddleName && nationality == 'JO') lstErrs.push('MiddleName');
            if (!acc.Arabic_Name__pc && nationality == 'JO') lstErrs.push('Arabic Name');
            
            if (!acc.Gender__pc) lstErrs.push('Gender');
            if ((!acc.Mailing_Area__c)||(acc.Mailing_Area__c==' ')) lstErrs.push('Mailing Area');
            if ((!acc.Mailing_Building_Number__c)||(acc.Mailing_Building_Number__c==' '))lstErrs.push('Mailing Building Number');
            if ((!acc.Mailing_Apartment_Number__c)||(acc.Mailing_Apartment_Number__c==' '))lstErrs.push('Mailing Apartment Number');
            if (!acc.Residency__pc) lstErrs.push('Residency');
            if (!acc.ID_Type__pc) lstErrs.push('ID Type');
            if (!acc.ID_Nationality__pc) lstErrs.push('Document Country');
            if (!acc.ID_Expiry_Date__pc) lstErrs.push('ID Expiry Date');
            if (!acc.Proof_of_Address_ID_Type__pc) lstErrs.push('Proof of Address ID Type');
            
            if (!acc.Gross_Monthly_Income__pc && caseSubject == 'Onboarding Verification Required') {
                lstErrs.push('Gross Monthly Income');
            }
            
            // Residency permit validations
            if (nationality == 'JO' && acc.Residency__pc != 'JO' ||
                nationality != 'JO' && acc.Residency__pc == 'JO') {
                if (!acc.Residency_Permit_Number__pc || !acc.Residency_Permit_Expiry__pc) {
                    lstErrs.push('Residency Permit');
                }
            }
            
            // ID Type specific validations
            if (acc.ID_Type__pc == 'Passport' && !acc.Passport_Number__pc) {
                lstErrs.push('Passport/Document Number');
            }
            
            if (acc.ID_Type__pc == 'Passport' && !acc.Passport_Expiry_Date__pc) {
                lstErrs.push('Passport/Document Expiry Date');
            }
            
            // Resident permit number/expiry for non-exempt ID types
            var exemptIDTypes = ['Jordanian ID', 'Military ID', "Sons of Jordanian Women's ID", 'Gaza ID'];
            if (!exemptIDTypes.includes(acc.ID_Type__pc)) {
                if (!acc.Residency_Permit_Number__pc) lstErrs.push('Resident Permit Number');
                if (!acc.Residency_Permit_Expiry__pc) lstErrs.push('Resident Permit Expiry');
            }
            
            // Place of birth validation
            if (!acc.Place_of_Birth__pc) lstErrs.push('Place of birth');
        }
        
        if (regionFlag == 'Bahrain') {
            // Bahrain-specific validations
            if (!acc.PersonMailingPostalCode) lstErrs.push('Postcode');
            if (!acc.Proof_of_Address_Id__pc) lstErrs.push('Proof of Address');
            if (!acc.Sources_of_Funds__pc) lstErrs.push('Sources of Funds');
        }
        
        // ID Number 2 validation (only for Jordan nationals)
        if (regionFlag == 'Jordan' && nationality == 'JO' && !acc.ID_Number_2__pc) {
            lstErrs.push('Jordan ID Number');
        }
        
        // Remove falsy values and check if any errors exist
        if (lstErrs.length) {
            hasErr = false;
            this.showErr("Fields required: " + lstErrs.join(', '));
        }
        
        return hasErr;
    },
    //CH02: Start
    checkDuplicateIdNumber: function (cmp, helper) {
        //cmp.set("v.isLoading", true);
        var helper = this;
        console.log('Checking Duplicate ID Number');
        var idNumber = cmp.find('idInformation').find("idNumber").get("v.value");
        var acct = cmp.get("v.account");
        var regionName = acct.Region_Flag__c;
        console.log('Region Name:', regionName);
        console.log('Id Number:', idNumber);
        console.log('Account:', acct);
        var action = cmp.get("c.isDuplicateId");
        action.setParams({
            idNumber: idNumber,
            acc: acct,
            regionName: regionName
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isDuplicate = response.getReturnValue();
                if (isDuplicate) {
                    cmp.find('idValNotice').showNotice({
                        "variant": "error",
                        "header": "Duplicate ID Number Found!",
                        "message": "Customer already exists with the same ID Number. Please verify.",
                        closeCallback: function () { }
                    });
                } else {
                    console.log('No duplicates, proceeding to save');
                    this.saveFieldUpdate(cmp);
                    
                    // For eKey cases, set update success flag
                    if (cmp.get("v.case.Origin") == 'eKey') {
                        cmp.set("v.isUpdateSuccessful", true);
                        // Show success message
                        cmp.find('apexService').showSuccessMessage("Record updated successfully!");
                    }
                    
                    console.log('After helper.saveFieldUpdateee to update Case Field on IGA Data Tab');
                    cmp.find("eKYCDataOnOnboardingCase").find('caseViewForm').submit();
                    
                }
            } else {
                console.error("Error in duplicate check:", response.getError());
            }
        }.bind(this));
        $A.enqueueAction(action);
    },
    //CH02: END
    getProspectSource: function (cmp, event, helper) {
        var action = cmp.get("c.prospectSource");  // calling method from the apex class
        console.log('---Case ID --> ' + cmp.get("v.recordId"));
        
        action.setParams({ CaseID: cmp.get("v.recordId") });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('---->' + response.getReturnValue());
                cmp.set("v.leadConverted", response.getReturnValue());
            }
            
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    showErr: function (msg) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                "title": "Error!",
                "message": msg,
                "type": "error"
            });
            toastEvent.fire();
        } else {
            alert(message);
        }
    },
    eKYCHelper: function (component) {
        //to display the eKyc tab
        //component.set("v.isSuccess_eKYC",true);
        component.find('apexService').request(component.get('c.eKYCsignOffCase'), {
            caseId: component.get("v.recordId")
        },
                                              function (response) {
                                                  var result = response.getReturnValue();
                                                  console.log("RESPONSE RESULT", result);
                                                  if (result == true) {
                                                      component.set("v.isSuccess_eKYC", true);
                                                  } else {
                                                      var toastEvent = $A.get("e.force:showToast");
                                                      toastEvent.setParams({
                                                          "type": "error",
                                                          "title": "Error in API",
                                                          "message": "Api call is not successfull Please re-try"
                                                      });
                                                      toastEvent.fire();
                                                  }
                                                  
                                              });
        
    },
    WathiqConsentFormValidation: function (component) {
        component.find('apexService').request(component.get('c.isWatiqueUpload'), {
            caseId: component.get("v.recordId")
        },
                                              function (response) {
                                                  var result = response.getReturnValue();
                                                  console.log("WathiqConsentFormValidation result>>>", result);
                                                  component.set("v.isWathiqConsent", result);
                                              });
    },
    
    // New helper method with promise support for checkDuplication
    checkDuplicationWithPromise: function (component, caseId, email, mobile, customerId, resolve, reject) {
        console.log('Helper.checkDuplicationWithPromise: Called with params - caseId:', caseId, 'email:', email, 'mobile:', mobile, 'customerId:', customerId);
        
        if (!caseId) {
            console.error('Helper.checkDuplicationWithPromise: Missing caseId parameter');
            component.set("v.isLoading", false);
            reject('Missing caseId parameter');
            return;
        }
        
        var action = component.get("c.checkForDuplicates");
        console.log('Helper.checkDuplicationWithPromise: Apex action created');
        
        action.setParams({
            caseId: caseId,
            email: email || '',
            mobile: mobile || '',
            customerId: customerId || ''
        });
        
        action.setCallback(this, function (response) {
            console.log('Helper.checkDuplicationWithPromise: Callback triggered, state =', response.getState());
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Helper.checkDuplicationWithPromise: Server returned:', result);
                
                if (result !== 'SUCCESS') {
                    console.warn('Helper.checkDuplicationWithPromise: Duplicate found:', result);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Duplicate Found",
                        "message": result
                    });
                    toastEvent.fire();
                    // Resolve anyway to continue the flow (or reject if you want to stop)
                    resolve(result);
                } else {
                    console.log('Helper.checkDuplicationWithPromise: No duplicates found');
                    resolve(result);
                }
                
            } else if (state === "ERROR") {
                console.error('Helper.checkDuplicationWithPromise: Error in server call');
                var errors = response.getError();
                var errorMessage = "An unknown error occurred while checking for duplicates";
                
                if (errors && errors[0] && errors[0].message) {
                    errorMessage = errors[0].message;
                    console.error('Helper.checkDuplicationWithPromise: Error details:', JSON.stringify(errors));
                }
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error",
                    "message": errorMessage
                });
                toastEvent.fire();
                reject(errorMessage);
            } else {
                var stateMessage = 'Request ' + state.toLowerCase();
                console.error('Helper.checkDuplicationWithPromise:', stateMessage);
                reject(stateMessage);
            }
        });
        
        console.log('Helper.checkDuplicationWithPromise: Enqueuing action...');
        $A.enqueueAction(action);
    },
    
    // New helper method with promise support for checkOnboardingStatus
    checkOnboardingStatusWithPromise: function (component, caseId, nationality, resolve, reject) {
        console.log('Helper.checkOnboardingStatusWithPromise: Called with params - caseId:', caseId, 'nationality:', nationality);
        
        if (!caseId) {
            console.error('Helper.checkOnboardingStatusWithPromise: Missing caseId parameter');
            reject('Missing caseId parameter');
            return;
        }
        
        var action = component.get("c.continueOnboarding");
        console.log('Helper.checkOnboardingStatusWithPromise: Apex action created');
        
        action.setParams({
            caseId: caseId,
            nationality: nationality || ''
        });
        
        action.setCallback(this, function (response) {
            console.log('Helper.checkOnboardingStatusWithPromise: Callback triggered, state =', response.getState());
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var canContinue = response.getReturnValue();
                console.log('Helper.checkOnboardingStatusWithPromise: Server returned canContinue =', canContinue);
                
                if (!canContinue) {
                    console.warn('Helper.checkOnboardingStatusWithPromise: Cannot continue onboarding - missing documents');
                    
                    var errorToast = $A.get("e.force:showToast");
                    errorToast.setParams({
                        "type": "error",
                        "title": "Missing Documents",
                        "message": "Required documents are missing. Cannot continue onboarding."
                    });
                    errorToast.fire();
                    
                    // Trigger failure event if needed
                    var appEvent = $A.get("e.c:OnboardingCheckFailed");
                    if (appEvent) {
                        console.log('Helper.checkOnboardingStatusWithPromise: Firing OnboardingCheckFailed event');
                        appEvent.setParams({
                            "caseId": caseId,
                            "canContinue": false
                        });
                        appEvent.fire();
                    }
                }
                
                // Resolve with the result (true if can continue, false if not)
                resolve(canContinue);
                
            } else if (state === "ERROR") {
                console.error('Helper.checkOnboardingStatusWithPromise: Error in server call');
                var errors = response.getError();
                var errorMessage = "An unknown error occurred while checking onboarding status";
                
                if (errors && errors[0] && errors[0].message) {
                    errorMessage = errors[0].message;
                    console.error('Helper.checkOnboardingStatusWithPromise: Error details:', JSON.stringify(errors));
                }
                
                var errorToast = $A.get("e.force:showToast");
                errorToast.setParams({
                    "type": "error",
                    "title": "Error",
                    "message": errorMessage
                });
                errorToast.fire();
                reject(errorMessage);
            } else {
                var stateMessage = 'Request ' + state.toLowerCase();
                console.error('Helper.checkOnboardingStatusWithPromise:', stateMessage);
                reject(stateMessage);
            }
        });
        
        console.log('Helper.checkOnboardingStatusWithPromise: Enqueuing action...');
        $A.enqueueAction(action);
    },
    
    checkDuplicationWithPromise: function (component, caseId, personEmail, personMobileNumber, customerId, resolve, reject) {
        var action = component.get("c.checkForDuplicates");
        action.setParams({
            "caseId": caseId,
            "email": personEmail,
            "mobile": personMobileNumber,
            "customerId": customerId
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Helper: Duplication check result:', result);
                resolve(result);
            } else if (state === "ERROR") {
                var errors = response.getError();
                var errorMessage = errors && errors[0] && errors[0].message ? errors[0].message : "Unknown error";
                console.error('Helper: Error in duplication check:', errorMessage);
                reject(new Error(errorMessage));
            }
        });
        
        $A.enqueueAction(action);
    },
    
    checkOnboardingStatusWithPromise: function (component, caseId, nationality, resolve, reject) {
        var action = component.get("c.continueOnboarding");
        action.setParams({
            "caseId": caseId,
            "nationality": nationality
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Helper: Onboarding status check result:', result);
                resolve(result);
            } else if (state === "ERROR") {
                var errors = response.getError();
                var errorMessage = errors && errors[0] && errors[0].message ? errors[0].message : "Unknown error";
                console.error('Helper: Error in onboarding status check:', errorMessage);
                reject(new Error(errorMessage));
            }
        });
        
        $A.enqueueAction(action);
    },
    
    continueOnboardingForEkey: function (component, account, caseId, customerId, email, actionName, requestBody) {
        return new Promise(function (resolve, reject) {
            console.log(">>>>>>sending onboarding");
            //delete read only field
            delete account.Name;
            component.find('apexService').request(component.get('c.sendManualOnboardingRequestForEkey'), {
                acc: account,
                caseId: caseId,
                customerId: customerId,
                actionName: actionName,
                requestBody: JSON.stringify(requestBody),
                email: email,
                regionName: account.Region_Flag__c
            },
                                                  function (response) {
                                                      console.log(">>>>>>response onboarding", response);
                                                      var result = response.getReturnValue();
                                                      if (result && result.isSuccess === true) {
                                                          component.find('apexService').showSuccessMessage("Onboarding Request successful!");
                                                          component.set("v.mode", "view");
                                                          resolve(result);
                                                      } else {
                                                          var errorMsg = result && result.message ? result.message : "Onboarding failed";
                                                          reject(new Error(errorMsg));
                                                      }
                                                  });
        });
    },
    
    convertToISODate: function (dateString) {
        if (!dateString) return null;
        
        if (dateString instanceof Date) {
            return dateString.toISOString().split('T')[0];
        }
        
        if (typeof dateString === 'string' && dateString.match(/^\d{4}-\d{2}-\d{2}/)) {
            return dateString.split('T')[0];
        }
        
        if (typeof dateString === 'string' && dateString.includes('/')) {
            var parts = dateString.split('/');
            if (parts.length === 3) {
                if (parseInt(parts[0]) > 12) {
                    return parts[2] + '-' + parts[1] + '-' + parts[0];
                } else {
                    return parts[2] + '-' + parts[1] + '-' + parts[0];
                }
            }
        }
        
        console.warn('Unable to parse date:', dateString);
        return dateString;
    }
})