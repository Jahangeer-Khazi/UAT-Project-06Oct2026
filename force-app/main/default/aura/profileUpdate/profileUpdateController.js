/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History:
 *  			CH01 : #Jahangeer Mohammed# #10-03-2026# Added Logic for Credit Card Guarantor CIF (NBA-16525)
 * 				CH02 : #Jahangeer Mohammed# #30-08-2026# Added Logic for Restricting Mobile Country Codes for Jordan (NBA-17747)
 *
 * 
*/
({
    doInit: function (component, event, helper) {
        helper.init(component);
        // helper.checkMakerResultOnCase(component);
    },
    onEditClick: function (component, event, helper) {
        component.set('v.mode', 'edit');
    },
    onCancelClick: function (component, event, helper) {
        component.set('v.mode', 'view');
    },
    onSaveClickAddInfor: function (component, event, helper) {
        console.log('Inside onSaveClickAddInfor');
        var account = component.get("v.account");
        var customerId = component.get('v.customerId');
        var caseId = component.get('v.caseId');
        var caseSubType = component.get("v.caseSubType");
        console.log('Case Sub Type Value:', caseSubType);
        if (caseSubType == "Expired ID Update" || caseSubType == "ID Expiry Update" || caseSubType == "ID Type Update") {
            if (account.ID_Type_Update__pc != null && account.ID_Expiry_Date_Update__pc != null) {
                console.log('ID Type field update:' + account.ID_Type_Update__pc);
                var dateValue = account.ID_Expiry_Date_Update__pc;
                var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                if (dateValue <= today && dateValue != null) {
                    helper.handleErrors(component, 'ID Expiry Date must be greater then today');
                }
                else {
                    helper.saveAddInfor(component, account, customerId, caseId);
                }
            }
            else {
                helper.handleErrors(component, 'Please fill all the fields related to ID details !');
            }
        }
        else if (caseSubType == 'Email update') {
            if (account.Email_Update__pc != null) {
                console.log('Email field update:' + account.Email_Update__pc);
                helper.saveAddInfor(component, account, customerId, caseId);
            }
            else {
                helper.handleErrors(component, 'Please fill the updated email field of a Customer !');
            }
        }
        else if (caseSubType == 'Mobile update') {
            console.log('Mobile Country Code Update:', account.Mobile_Country_Code_Update__pc);
            console.log('Mobile field update:' + account.Mobile_Update__pc);
            if (account.Mobile_Country_Code_Update__pc != null && account.Mobile_Update__pc != null) {
                //console.log('Mobile Country Code Update:',account.Mobile_Country_Code_Update__pc);
                console.log('Mobile field update:'+account.Region_Flag__pc);
                //CH02: Start
				let invalidCountryCodes;
                if(account.Region_Flag__pc === 'Bahrain'){
                    invalidCountryCodes = $A.get("$Label.c.INVALID_COUNTRY_CODE").split(',');
                }
                else if(account.Region_Flag__pc === 'Jordan'){
                    invalidCountryCodes = $A.get("$Label.c.INVALID_COUNTRY_CODE_JO").split(',');
                }
                //CH02: END
                let userCode = account.Mobile_Country_Code_Update__pc ? account.Mobile_Country_Code_Update__pc.replace(/\s+/g, '').trim() : '';

                if (invalidCountryCodes.includes(userCode)) {
                    helper.handleErrors(component, 'Restricted country code for mobile number. Please use different country code');
                    helper.sendEmail(component, account, customerId, caseId);
                }
                else {
                    //account.PersonMobilePhone=account.Mobile_Update__pc;
                    helper.saveAddInfor(component, account, customerId, caseId);
                }

            }
            else {
                helper.handleErrors(component, 'Please fill all the fields related to Mobile details !');
            }
        }
        else if (caseSubType == 'Name Fix / Update' || caseSubType == "Name Update") {
            if (account.FirstName_Update__pc != null && account.MiddleName_Update__pc != null && account.LastName_Update__pc != null) {
                console.log('First Name field update:' + account.FirstName_Update__pc);
                helper.saveAddInfor(component, account, customerId, caseId);
            }
            else {
                console.log('Middle Name field update:' + account.MiddleName_Update__pc);
                helper.handleErrors(component, 'Please fill all the fields related to Personnel Information !');
            }
        }
        else if (caseSubType == 'Address update') {
            if (account.Proof_of_Address_Id_Update__pc != null && account.Proof_of_Address_ID_Type_Update__pc != null && account.Address_ID_Expiry_Date_Update__pc ||
                account.Mailing_Street_Update__pc != null && account.Mailing_City_Update__pc != null && account.Postcode_Block_Update__pc != null && account.Mailing_Country_Update__pc != null) {
                console.log('Address Id Expiry Update:' + account.Address_ID_Expiry_Date_Update__pc);
                var dateValue = account.Address_ID_Expiry_Date_Update__pc;
                var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                if (dateValue <= today && dateValue != null) {
                    helper.handleErrors(component, 'Address ID Expiry Date must be greater then today');
                }
                else {
                    helper.saveAddInfor(component, account, customerId, caseId);
                }
            }
            else {
                helper.handleErrors(component, 'Please fill all the fields related to Address Information !');
            }
        }
        else if (caseSubType == 'Additional Information') {
            if (account.Residency_Permit_Number_Update__pc != null || account.Residency_Permit_Expiry_Update__pc != null || account.Employer_Name_Update__pc != null ||
                account.Business_Name_Update__pc != null || account.Business_Address_Update__pc != null || account.Expected_Monthly_deposits_Update__pc || account.Passport_Number_Update__pc != null ||
                account.Passport_Expiry_Date_Update__pc != null || account.Nationality_Update__pc != null || account.Place_of_birth_government_Update__pc) {
                var dateValuePassport = account.Passport_Expiry_Date_Update__pc;
                var dateValueResident = account.Residency_Permit_Expiry_Update__pc;
                var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                if (dateValuePassport == null && dateValueResident <= today && dateValueResident != null) {
                    helper.handleErrors(component, 'Resident Expiry Date must be greater then today');
                }
                else if (dateValuePassport != null && dateValuePassport <= today && dateValueResident == null) {
                    helper.handleErrors(component, 'Passport Expiry Date must be greater then today');
                }
                else if (dateValuePassport > today && dateValuePassport != null && dateValueResident <= today && dateValueResident != null) {
                    helper.handleErrors(component, 'Resident Expiry Date must be greater then today');
                }
                else if (dateValuePassport <= today && dateValuePassport != null && dateValueResident > today && dateValueResident != null) {
                    helper.handleErrors(component, 'Passport Expiry Date must be greater then today');
                }
                else if (dateValuePassport <= today && dateValuePassport != null && dateValueResident <= today && dateValueResident != null) {
                    helper.handleErrors(component, 'Passport & Resident Expiry Date must be greater then today');
                }
                else {
                    console.log('All the conditions are Satisfying');
                    helper.saveAddInfor(component, account, customerId, caseId);
                }

            }
            else {
                helper.handleErrors(component, 'Please fill atleast one of the fields related to Additional Information !');
            }

        }
        else if (caseSubType == 'Guardian Info') {
            console.log('Gaurdian Information');
            console.log('Minor value:', account.Minor_Update__pc);
            console.log('Guardain CIF Update:', account.Guardian_CIF_Update__pc);
            var accGuardian = account.Guardian_CIF_Update__pc;
            const checkNumber = /^\d+$/;
            if (account.Minor_Update__pc != null && account.Minor_Update__pc == true && account.Guardian_CIF_Update__pc == null) {
                helper.handleErrors(component, 'Please fill the Guardian CIF field !');
            }
            else if (account.Minor_Update__pc != null && account.Minor_Update__pc == true && account.Guardian_CIF_Update__pc != null && !checkNumber.test(account.Guardian_CIF_Update__pc)) {
                console.log('2 Else if');
                helper.handleErrors(component, 'Guardian CIF field Must be a Number !');
            }
            else if (account.Minor_Update__pc == undefined && account.Guardian_CIF_Update__pc != null && !checkNumber.test(account.Guardian_CIF_Update__pc)) {
                console.log('3 Else if');
                helper.handleErrors(component, 'Guardian CIF field Must be a Number !');
            }
            else if (account.Minor_Update__pc == false && account.Guardian_CIF_Update__pc != null) {
                helper.handleErrors(component, 'Please keep the Guardian CIF field as blank');
            } else {
                console.log('Account Minor Value:' + account.Minor_Update__pc);
                helper.saveAddInfor(component, account, customerId, caseId);
            }
        }
        else if (caseSubType == 'Geo-Location Check') {
            console.log('account.Bypass_Geo_Location_End_Date_Update__pc' + account.Bypass_Geo_Location_End_Date_Update__pc);
            console.log('account.Bypass_Geo_Location_Country_Update__pc' + account.Bypass_Geo_Location_Country_Update__pc);
            if (account.Bypass_Geo_Location_Check_Update__pc == true && (account.Bypass_Geo_Location_End_Date_Update__pc == null || account.Bypass_Geo_Location_Country_Update__pc == null)) {
                helper.handleErrors(component, 'Please select the end date for Bypass Geo-location request!');
            } else {
                console.log('Geo-Location Check:' + account.Bypass_Geo_Location_Check_Update__pc);
                helper.saveAddInfor(component, account, customerId, caseId);
                //
            }

        }
        //CH01: Start
        else if (caseSubType == 'Credit Card Guarantor CIF') {
            const checkNumber = /^\d+$/;
            if (account.Credit_Card_Guarantor_CIF_Update__pc != null && !checkNumber.test(account.Credit_Card_Guarantor_CIF_Update__pc)) {
                helper.handleErrors(component, 'Guarantor CIF field Must be a Number !');
            }
            else if (account.Credit_Card_Guarantor_CIF_Update__pc == null) {
                helper.handleErrors(component, 'Please fill the Guarantor CIF field !');
            }
            else if (account.Credit_Card_Guarantor_CIF_Update__pc != null && checkNumber.test(account.Credit_Card_Guarantor_CIF_Update__pc)) {
                var action = component.get("c.checkCIFNumber");
                action.setParams({
                    cifNumber: account.Credit_Card_Guarantor_CIF_Update__pc
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        console.log('Getting response CIF Number:', response.getReturnValue());
                        var cifFound = response.getReturnValue();
                        console.log('Response Value:', cifFound);
                        if (cifFound === true) {
                            helper.saveAddInfor(component, account, customerId, caseId);
                        }
                        else if (cifFound === false) {
                            helper.handleErrors(component, 'Entered CIF is not Valid !');
                        }
                    }
                    else if (state === 'ERROR') {
                        console.log('Error from the Server')
                    }
                });
                $A.enqueueAction(action);
            }
            //CH01: END

        }
    }
})