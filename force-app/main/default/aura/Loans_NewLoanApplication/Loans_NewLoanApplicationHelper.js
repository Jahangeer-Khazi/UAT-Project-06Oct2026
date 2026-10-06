({
    showSpinner: function (component, event, helper) {
        // var spinner = component.find("mySpinner");
        // $A.util.removeClass(spinner, "slds-hide");
        component.set("v.showSpinner",true);
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
        component.set("v.showSpinner",false);
    },
    fillRequestedLoansTypeOptions: function (component, event, helper) {
        var caseModel = component.get("v.caseModel");
        var customer = component.get("v.customer");
        console.log('=== customer=====> ', customer);
        var customerCIF = customer.CIF__pc;
        console.log('=== caseModel=====> ', caseModel);
        console.log('=== customerCIF=====> ', component.get("v.customer").CIF__pc);

        var loanOrFinance = (caseModel == 'alburaq') ? 'Finance' : 'Loan';
        component.find('apexService').request(component.get('c.callLoanOptionsAPI'), {
            customerId : customerCIF,
            caseModel : caseModel
            },
            function(response) {
                var result = response.getReturnValue();
                console.log('loansOptions API result: ', result);
                var loansOptions = result.responseData.loansOptions;
                console.log('result Loan Types loansOptions: ', loansOptions);
                    
                var fieldMap = [];
                for(var i in loansOptions){
                    var loansItems = loansOptions[i].loansItems;
                    for(var key in loansItems){
                        // fieldMap.push({key: loansOptions[i].type.replace(/^\w/, (c) => c.toUpperCase()) + ' ' + loanOrFinance + ' ' + loansItems[key].nature.replace(/^\w/, (c) => c.toUpperCase()) , value: loansItems[key].loanProductConfigurationId});
                        fieldMap.push({type: loansOptions[i].type.replace(/^\w/, (c) => c.toUpperCase()),nature: loansItems[key].nature.replace(/^\w/, (c) => c.toUpperCase()) , loanProductConfigurationId: loansItems[key].loanProductConfigurationId});
                        // if(!fieldMap.some(item => item.key === loansOptions[i].type.replace(/^\w/, (c) => c.toUpperCase()))){
                        //     fieldMap.push({key: loansOptions[i].type.replace(/^\w/, (c) => c.toUpperCase()) , value: loansItems[key].loanProductConfigurationId});
                        // }
                        
                    }
                }
                console.log('requestedLoanTypes => ', fieldMap);
                component.set("v.requestedLoanTypes",fieldMap);
                });
            
    },
    getUserApplicationInfoAPI: function (component, event, helper) {
        
        component.find('apexService').request(component.get('c.getUserApplicationInfoAPI'), {
            customerId : component.get("v.customer").CIF__pc,
            loanProductConfigurationId : component.get("v.loanProductConfigurationId"),
            caseModel : component.get("v.caseModel")
            },
            function(response) {
                var result = response.getReturnValue();
                console.log('getUserApplicationInfoAPI result: ', result);
                
                var dataArray = result.responseData;
                for(var key in dataArray){
                    var obj = dataArray[key];
                    // console.log('getUserApplicationInfoAPI result obj: ', obj);
                    //EMPLOYMENT_INFO Section
                    if(obj.sectionCode == 'EMPLOYMENT_INFO'){
                        for(var key in obj.fields){
                            var fieldObj = obj.fields[key];

                            if(fieldObj.code == 'EMPLOYMENT_STATUS'){
                                component.find("EmploymentStatus").set("v.value", fieldObj.value);

                                if (fieldObj.value =='Employed' ) {
                                    component.set("v.isEmployed", true);

                                }
                            }

                            if(fieldObj.code == 'ORGANIZATION_NAME'){
                                component.find("EmployerName").set("v.value", fieldObj.value);
                            }

                            if(fieldObj.code == 'MONTHLY_INCOME'){
                                component.find("cx_ln_Gross_Income").set("v.value", fieldObj.value);
                            }

                        }
                    }

                    //PERSONAL_INFO Section
                    if(obj.sectionCode == 'PERSONAL_INFO'){
                        for(var key in obj.fields){
                            var fieldObj = obj.fields[key];

                            if(fieldObj.code == 'RESIDENCE_STATUS'){
                                component.find("ResidenceOccupancyStatus").set("v.value", fieldObj.value);
                            }
                            if(fieldObj.code == 'CURRENT_RESIDENCE'){
                                // component.find("NumberYearsCurrentResidence").set("v.value", fieldObj.value);
                                var numberOfYears = Number(fieldObj.value);
                                if (numberOfYears < 1) {
                                    component.find("NumberYearsCurrentResidence").set("v.value", "Less than 1 year");

                                } else if (numberOfYears >= 1 && numberOfYears < 2) {
                                    component.find("NumberYearsCurrentResidence").set("v.value", "1 to 2 Years");

                                } else if (numberOfYears >= 2 && numberOfYears < 3) {
                                    component.find("NumberYearsCurrentResidence").set("v.value", "2 to 3 years");

                                } else if (numberOfYears >= 3 && numberOfYears < 5) {
                                    component.find("NumberYearsCurrentResidence").set("v.value", "3 to 5 years");

                                } else if (numberOfYears >= 5) {
                                    component.find("NumberYearsCurrentResidence").set("v.value", "5 years & above");
                                }
                                
                            }
                            else if(fieldObj.code == 'CURRENT_ADDRESS'){
                                // component.set("v.currentAddress", fieldObj.value);
                                component.find("currentAddress").set("v.value", fieldObj.value);
                            }
                            else if(fieldObj.code == 'MARITAL_STATUS'){
                                component.find("MaritalStatus").set("v.value", fieldObj.value);
                            }
                            else if(fieldObj.code == 'NUMBER_OF_DEPENDENTS'){
                                component.find("NumberOfDependents").set("v.value", fieldObj.value);
                            }
                            else if(fieldObj.code == 'ACADEMIC_QUALIFICATION'){
                                component.find("AcademicQualifications").set("v.value", fieldObj.value);
                            }
                            else if(fieldObj.code == 'PERSONS_CONTACT'){
                                component.find("FriendContactNumber").set("v.value", fieldObj.value);
                            }
                            else if(fieldObj.code == 'PERSONS_NAME'){
                                component.find("FriendName").set("v.value", fieldObj.value);
                            }

                        }
                    }

                }

                });
            
    },
    /*
    Comment this bloc because of UATNB-211338
    getExistingLiabilitiesAPI: function (component, event, helper) {
        
        component.find('apexService').request(component.get('c.getExistingLiabilitiesAPI'), {
            customerId : component.get("v.customer").CIF__pc,
            caseModel : component.get("v.caseModel")
            },
            function(response) {
                var result = response.getReturnValue();
                console.log('getExistingLiabilitiesAPI == ', result);

                var fieldMap = [];
                var counter = 0;
                for(var key in result.responseData){
                    fieldMap.push({selected: false, Id: counter , type: result.responseData[key].type, outstanding: result.responseData[key].outstanding , monthlyInstallment:  result.responseData[key].monthlyInstallment });
                    counter ++;
                    //   value: '{ "type": "'+result.responseData[key].type + '", "outstanding": '+result.responseData[key].outstanding+ ', "monthlyInstallment": '+ result.responseData[key].monthlyInstallment +'}'
                    // AllExistingLiabilitiesList.push(result.responseData[key]);
                }
                component.set("v.LiabilitiesOptions",fieldMap);
                component.find("cx_ln_Requested_Liabilities").set("v.value", JSON.stringify(fieldMap));
                helper.calculateLiabilityTotals(component, event, helper,fieldMap);
                // component.set("v.AllExistingLiabilities",AllExistingLiabilitiesList);
                
                //toDo : add logic to set the other 2 fields !!
                
        });
            
    },*/
    getHoldProductsAPI: function (component, event, helper) {
        var caseModel = component.get("v.caseModel");

        // var loanOrFinance = (caseModel == 'alburaq') ? 'Finance' : 'Loan';

        component.find('apexService').request(component.get('c.getCustomerProductsAPI'), {
            customerId : component.get("v.customer").CIF__pc,
            caseModel : caseModel
            },
            function(response) {
                var result = response.getReturnValue();
                var products = result.responseData.products;
                console.log('result Loan Types products: ', products);
                component.set("v.products", products);
                var fieldMap = [];
                for(var i in products){
                    var caseModel = component.get("v.caseModel");
                    var productType = products[i].productType == 'FIXED_DEPOSIT' && caseModel == 'alburaq' ? 'WAKALA' : products[i].productType;
                    fieldMap.push({productType: productType, id: products[i].id, name: products[i].name, availableBalance: products[i].availableBalance, accountId: (products[i].accountId ? products[i].accountId : products[i].id) });
                }
                
                component.set("v.DisabledCustomerProductsOptions",fieldMap);

                /* Commented because of UATNB-211338
                const calculationType = component.find("cx_ln_Loan_Calculation_Method").get("v.value"); // 'BY_MONTHLY_INSTALLMENT' or 'BY_LOAN_AMOUNT'
                const numberOfMonths = component.find("RequestedDuration").get("v.value");
                if (numberOfMonths && calculationType === 'By Loan/Finance Amount' ){
                    const loanAmount = component.find("Loans_Requested_Loan_Finance_Amount_Amount").get("v.value");
                    if(loanAmount){
                        //helper.calculateHoldAmount(component, event, helper);
                        helper.calculatorApiCall(component, event, helper); //toDo : uncomment
                        
                    }
                } else if (numberOfMonths && calculationType === 'By Monthly Installment' )  {
                    const monthlyInstallment = component.find("RequestedMonthlyInstalment_Installment").get("v.value");
                    if(monthlyInstallment){
                        //helper.calculateHoldAmount(component, event, helper);
                        helper.calculatorApiCall(component, event, helper); //toDo : uncomment
                    }
                } */
                // calculateHoldAmount(component);
                });
            
    },
    /*calculateHoldAmount: function(component, event, helper) {
        console.log('calculateHoldAmount');
        component.set("v.showLoanCalculatorSection", true);

        const calculationMatrixResp = component.get("v.calculationMatrixResponse");
        const matrixConfig = calculationMatrixResp.responseData.configurations[0];
        console.log('calculationMatrixResp.data.configurations :', matrixConfig);
        // const calculationType = component.find("loanAmountType").get("v.value"); // 'BY_MONTHLY_INSTALLMENT' or 'BY_LOAN_AMOUNT'
        const calculationType = component.find("cx_ln_Loan_Calculation_Method").get("v.value");//by_amount
        const numberOfMonths = component.find("RequestedDuration").get("v.value");//12

        const processingFee = matrixConfig.processingFee; // Assuming the values from the provided JSON //100
        const vatProcessingFee = matrixConfig.vatProcessingFee; //10
        const monthlyInterestRate = matrixConfig.interestRate / (100 * 12); // Interest rate as monthly decimal (example rate) // 4/1200 = 0,00333333
        component.find("cx_ln_Requested_Processing_Fees").set("v.value", matrixConfig.processingFee );
        component.find("cx_ln_Requested_Vat_Processing_Fees").set("v.value", matrixConfig.vatProcessingFee );
        component.find("cx_ln_Requested_Interest_Rate").set("v.value", matrixConfig.interestRate );
        component.find("cx_ln_Requested_Insurance_Amount").set("v.value", matrixConfig.insuranceFee );//EMPTY
        component.find("cx_ln_Requested_First_Payment_Date").set("v.value", matrixConfig.firstPaymentDate );

        const currentDate = new Date(matrixConfig.firstPaymentDate); // Initial date
        currentDate.setMonth(currentDate.getMonth() + parseInt(numberOfMonths, 10) - 1 ); // Add n-1 months // because of US UATNB-175258
        const formattedDate = currentDate.toISOString().split('T')[0];
        console.log("cx_ln_Requested_Maturity_Date --> "+formattedDate);
        component.find("cx_ln_Requested_Maturity_Date").set("v.value", formattedDate);

        // Existing Liabilities
        let existingLoans = 0;
        let LiabilitiesOptions = component.get("v.LiabilitiesOptions");
        for (var i = 0; i < LiabilitiesOptions.length; i++) {
            if (LiabilitiesOptions[i].selected) {
                existingLoans = existingLoans + LiabilitiesOptions[i].outstanding;
            }
        }

        let holdAmount;

        if (calculationType === 'By Loan/Finance Amount') {
            const loanAmount = component.find("Loans_Requested_Loan_Finance_Amount_Amount").get("v.value");
            // monthlyInstallment = "(MonthlyInterestRate * LoanAmount) / (1 − (1 + MonthlyInterestRate) ^ − NumberOfMonths)"
            //const monthlyInstallmentOld = (monthlyInterestRate * loanAmount) / (1 - Math.pow(1 + monthlyInterestRate, -numberOfMonths));
            const monthlyInstallment = (loanAmount * (monthlyInterestRate * Math.pow(1 + monthlyInterestRate, numberOfMonths)) / (Math.pow(1 + monthlyInterestRate, numberOfMonths) - 1)) + ((processingFee + vatProcessingFee) / numberOfMonths);
            console.log('monthlyInstallment New --> '+ monthlyInstallment);
            const totalRepayment = monthlyInstallment * numberOfMonths;
            holdAmount = totalRepayment + processingFee + vatProcessingFee;

            component.find("RequestedMonthlyInstalment_Amount").set("v.value", parseFloat(monthlyInstallment.toFixed(3)) );
            component.find("cx_ln_Requested_Cash_in_Hand").set("v.value", parseFloat((loanAmount - existingLoans).toFixed(3)) );

            component.find("RequestedMonthlyInstalment").set("v.value", parseFloat(monthlyInstallment.toFixed(3)) );
            console.log('Calculated monthlyInstallment :', monthlyInstallment );
            console.log('Calculated monthlyInstallment .003 :', parseFloat(monthlyInstallment.toFixed(3)));
            component.find("Loans_Requested_Loan_Finance_Amount").set("v.value", parseFloat(parseFloat(loanAmount).toFixed(3)) );

        } else if (calculationType === 'By Monthly Installment') {
            const monthlyInstallment = component.find("RequestedMonthlyInstalment_Installment").get("v.value");
            // LoanAmount = MonthlyInstallment *( (( (1+MonthlyInterestRate) ^ NumberOfMonths) -1)/(MonthlyInterestRate*((1+MonthlyInterestRate)^NumberOfMonths)))
            const loanAmount = monthlyInstallment * (((Math.pow(1 + monthlyInterestRate, numberOfMonths) - 1) / (monthlyInterestRate * Math.pow(1 + monthlyInterestRate, numberOfMonths))));
            const totalRepayment = monthlyInstallment * numberOfMonths;
            holdAmount = totalRepayment + processingFee + vatProcessingFee;

            component.find("Loans_Requested_Loan_Finance_Amount_Installment").set("v.value", parseFloat(loanAmount.toFixed(3)) );
            component.find("cx_ln_Requested_Cash_in_Hand").set("v.value", parseFloat((loanAmount - existingLoans).toFixed(3) ) );

            component.find("RequestedMonthlyInstalment").set("v.value", parseFloat(parseFloat(monthlyInstallment).toFixed(3)) );
            component.find("Loans_Requested_Loan_Finance_Amount").set("v.value", parseFloat(loanAmount).toFixed(3) );
            
            console.log('Calculated monthlyInstallment :', monthlyInstallment );
            console.log('Calculated monthlyInstallment .003 :', parseFloat(parseFloat(monthlyInstallment).toFixed(3)));
        }

        console.log('Calculated holdAmount :', holdAmount);
        console.log('Calculated holdAmount .003 :', parseFloat(holdAmount.toFixed(3)));
        component.set("v.holdAmount", parseFloat(holdAmount.toFixed(3)) );
        component.set("v.isLoanCalculated", true);
        component.set("v.isLoanCalculatedValidationMessage", "");

        var product = component.find("cx_ln_Product").get("v.value");
        if(product == 'Secured'){
            let products = component.get("v.products");
            component.set('v.selectedRows', []);
            component.set('v.FinalselectedRows', []);
            var fieldMap = [];
            var DisabledfieldMap = [];
            
            for(var i in products){
                var caseModel = component.get("v.caseModel");
                var productType = products[i].productType == 'FIXED_DEPOSIT' && caseModel == 'alburaq' ? 'WAKALA' : products[i].productType;
                if(products[i].availableBalance >= holdAmount){
                    fieldMap.push({productType: productType, id: products[i].id, name: products[i].name, availableBalance: products[i].availableBalance, accountId: (products[i].accountId ? products[i].accountId : products[i].id) });
                } else {
                    DisabledfieldMap.push({productType: productType, id: products[i].id, name: products[i].name, availableBalance: products[i].availableBalance, accountId: (products[i].accountId ? products[i].accountId : products[i].id) });
                }
            }
            component.set("v.CustomerProductsOptions",fieldMap);
            component.set("v.DisabledCustomerProductsOptions",DisabledfieldMap);
            component.find("ccol_Hold_Account").set("v.value", null );
            component.find("ccol_Hold_Account_IBAN").set("v.value", null );
            component.find("ccol_Hold_Account_Balance").set("v.value", null );
        }
        
    },*/
    getLoanCalculatorMatrixAPI: function (component, event, helper) {
        var caseModel = component.get("v.caseModel");
        console.log('call Loan Calculation matrix API ');
        component.find('apexService').request(component.get('c.getLoanCalculatorMatrixAPI'), {
            customerId : component.get("v.customer").CIF__pc,
            caseModel : caseModel
            },
            function(response) {
                var result = response.getReturnValue();
                console.log('result Loan Calculation matrix: ', result);
                
                component.set("v.calculationMatrixResponse",result);
                // this.calculateHoldAmount(component);
            });
            
    },
    // Call create loan api synchronously
    // callCreateLoanApplicationAPI: function (component, event, helper) {
    //     console.log('callCreateLoanApplicationAPI##');
    //     var payload = event.getParams().response;
    //     // var selectedHoldProduct = component.find("RequestedHoldProductAndAvailableBalance").get("v.value");
    //     // var showRequestedHoldProducts = component.get("v.showRequestedHoldProducts");
    //     // var selectedHoldProduct;
    //     // if(showRequestedHoldProducts === true){
    //     //     var selectedHoldProductId = component.find("RequestedHoldProductAndAvailableBalance").get("v.value");
    //     //     console.log('callCreateLoanApplicationAPI##selectedHoldProductId', selectedHoldProductId);
    //     //     var products = component.get("v.products");
            
    //     //     for (var i = 0; i < products.length; i++) {
    //     //         console.log('callCreateLoanApplicationAPI##for loop');
    //     //         if (products[i].id == selectedHoldProductId) {
    //     //             selectedHoldProduct = products[i];
                    
    //     //             break;
    //     //         }
    //     //     }
    //     // }
        
    //     component.find('apexService').request(component.get('c.callCreateLoanApplicationAPI'), {
    //         caseId : payload.id
    //         },
    //         function(response) {
    //             var result = response.getReturnValue();
    //             console.log('create loan application API response: ', result);
                    
    //             });
            
    // },
    resetLoanCalculatorValues: function (component, event, helper) {
        console.log('resetLoanCalculatorValues##');

        if(component.find("cx_ln_Requested_Processing_Fees")) component.find("cx_ln_Requested_Processing_Fees").set("v.value", null );
        if(component.find("cx_ln_Requested_Vat_Processing_Fees")) component.find("cx_ln_Requested_Vat_Processing_Fees").set("v.value", null );
        if(component.find("cx_ln_Requested_Interest_Rate")) component.find("cx_ln_Requested_Interest_Rate").set("v.value", null );
        if(component.find("cx_ln_Requested_Insurance_Amount")) component.find("cx_ln_Requested_Insurance_Amount").set("v.value", null );
        if(component.find("cx_ln_Requested_First_Payment_Date")) component.find("cx_ln_Requested_First_Payment_Date").set("v.value", null );

        if(component.find("cx_ln_Requested_Cash_in_Hand")) component.find("cx_ln_Requested_Cash_in_Hand").set("v.value", null );
        if(component.find("cx_ln_Requested_Maturity_Date")) component.find("cx_ln_Requested_Maturity_Date").set("v.value", null );
        if(component.find("Loans_Requested_Loan_Finance_Amount")) component.find("Loans_Requested_Loan_Finance_Amount").set("v.value", null );
        if(component.find("RequestedMonthlyInstalment")) component.find("RequestedMonthlyInstalment").set("v.value", null );
        
        const calculationType = component.find("cx_ln_Loan_Calculation_Method").get("v.value"); // 'BY_MONTHLY_INSTALLMENT' or 'BY_LOAN_AMOUNT'        
        if (calculationType === 'By Loan/Finance Amount' ){
            // component.find("Loans_Requested_Loan_Finance_Amount_Amount").set("v.value", null );
            if(component.find("RequestedMonthlyInstalment_Amount")) component.find("RequestedMonthlyInstalment_Amount").set("v.value", null );

        } else if (calculationType === 'By Monthly Installment' )  {
            if(component.find("Loans_Requested_Loan_Finance_Amount_Installment")) component.find("Loans_Requested_Loan_Finance_Amount_Installment").set("v.value", null );
            // component.find("RequestedMonthlyInstalment_Installment").set("v.value", null );
        } 

        component.set("v.showLoanCalculatorSection", false);
        component.set("v.isLoanCalculated", false);
        component.set("v.isLoanCalculatedValidationMessage", "");

    },
    checkCalculationButtonEnablement : function(component, event, helper) {
        console.log('handleAmountchange');
        const calculationType = component.find("cx_ln_Loan_Calculation_Method").get("v.value"); // 'BY_MONTHLY_INSTALLMENT' or 'BY_LOAN_AMOUNT'
        const numberOfMonths = component.find("RequestedDuration").get("v.value");
        
        if (numberOfMonths && calculationType === 'By Loan/Finance Amount' ){
            const loanAmount = component.find("Loans_Requested_Loan_Finance_Amount_Amount").get("v.value");
            if(loanAmount){
                component.set("v.disableLoanCalculationButton", false )
            } else{
                component.set("v.disableLoanCalculationButton", true )
            }
        } else if (numberOfMonths && calculationType === 'By Monthly Installment' )  {

            const monthlyInstallment = component.find("RequestedMonthlyInstalment_Installment").get("v.value");
            if(monthlyInstallment){
                component.set("v.disableLoanCalculationButton", false )
            } else{
                component.set("v.disableLoanCalculationButton", true )
            }
        } else{
            component.set("v.disableLoanCalculationButton", true )
        }

        //UATNB-211338 Start : make the "Calculate" Button disabled if cc_Business_Nature_Type is empty
        var BusinessNatureType = component.find('cc_Business_Nature_Type').get("v.value");
        if(!BusinessNatureType){ //toDo : check this while testing if it's good??
            component.set("v.disableLoanCalculationButton", true );
        }
        //UATNB-211338 End
    },

    //aniss Start 
    calculatorApiCall: function (component, event, helper) {
        component.set("v.showLoanCalculatorSection", true);
        var calculationType = component.find("cx_ln_Loan_Calculation_Method").get("v.value"); 
        var loanAmount;
        var monthlyInstallment;
        if(calculationType == 'By Monthly Installment'){
            monthlyInstallment = component.find("RequestedMonthlyInstalment_Installment").get("v.value");
        }
        else if(calculationType == 'By Loan/Finance Amount'){
            loanAmount = component.find("Loans_Requested_Loan_Finance_Amount_Amount").get("v.value");
        }
        var numberOfMonths = component.find("RequestedDuration").get("v.value");

        var calculatMethod;
        // change it to the values used on the method : 'BY_MONTHLY_INSTALLMENT' or 'BY_LOAN_AMOUNT'
        if(calculationType == 'By Monthly Installment'){
            calculatMethod = 'BY_MONTHLY_INSTALLMENT';
        }else if(calculationType == 'By Loan/Finance Amount'){
            calculatMethod = 'BY_LOAN_AMOUNT';
        }

        // Existing Liabilities
        let existingLoans = 0;
        let LiabilitiesOptions = component.get("v.LiabilitiesOptions");
        for (var i = 0; i < LiabilitiesOptions.length; i++) {
            if (LiabilitiesOptions[i].selected) {
                existingLoans = existingLoans + LiabilitiesOptions[i].outstanding;
            }
        }

        // Collect form data to pass to Apex
        var formData = {
            regionName: "Bahrain",//default value
            //segment: "Regular",//default value
          //  nationality: "BH",//default value // Fix for Interest issue (Jayanth)
            segment:component.get("v.customer").Segment__pc,
            nationality:component.get("v.customer").Nationality__pc,
            customerId: component.get("v.customer").CIF__pc,
            loanType: "personal",//default value
            subscription: component.get("v.caseModel"),
            calculationMethod: calculatMethod,
            LoanAmount: loanAmount,
            InstallmentAmount: monthlyInstallment,
            LoanDuration: numberOfMonths,
            ExistingLoans: existingLoans.toString()
        };

        // Call the Apex method with the form data as a map
        var action = component.get("c.calculatorApiCall");
        action.setParams({
            param: formData
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // Handle the response from Apex here (e.g., show the result to the user)
                console.log(result);
                console.log('api response calculation matrix :' +JSON.stringify(result.response));
                console.log('result.status calculate : ', result.status);
                if(result.status == 'Success'){
                    component.find("cx_ln_Requested_Processing_Fees").set("v.value", result.processingFee );
                    component.find("cx_ln_Requested_Vat_Processing_Fees").set("v.value", result.vatProcessingFee );
                    component.find("cx_ln_Requested_Interest_Rate").set("v.value", result.interestRate );
                    component.find("cx_ln_Requested_Insurance_Amount").set("v.value", result.insuranceFee );//toDo : EMPTY from the response
                    component.find("cx_ln_Requested_First_Payment_Date").set("v.value", result.firstPaymentDate );
                    
                    /*const currentDate = new Date(result.firstPaymentDate); // Initial date
                    currentDate.setMonth(currentDate.getMonth() + parseInt(numberOfMonths, 10) - 1 ); // Add n-1 months // because of US UATNB-175258
                    const formattedDate = currentDate.toISOString().split('T')[0];
                    console.log("cx_ln_Requested_Maturity_Date --> "+formattedDate);
                    component.find("cx_ln_Requested_Maturity_Date").set("v.value", formattedDate);*/
                    component.find("cx_ln_Requested_Maturity_Date").set("v.value", result.maturityDate );

                    if (calculationType === 'By Loan/Finance Amount') {
                        component.find("TotalRepaymentAmount").set("v.value", parseFloat(result.totalRepayment?result.totalRepayment.toFixed(3):result.totalRepayment) );
                        component.find("TotalInterest").set("v.value", parseFloat(result.totalInterest?result.totalInterest.toFixed(3):result.totalInterest) );

                        component.find("RequestedMonthlyInstalment_Amount").set("v.value", parseFloat(result.monthlyInstallment.toFixed(3)) );
                        component.find("cx_ln_Requested_Cash_in_Hand").set("v.value", parseFloat(result.totalCashInHand.toFixed(3)) );
                        
                        component.find("RequestedMonthlyInstalment").set("v.value", parseFloat(result.monthlyInstallment.toFixed(3)) );
                        console.log('Calculated monthlyInstallment :', result.monthlyInstallment );
                        console.log('Calculated monthlyInstallment .003 :', parseFloat(result.monthlyInstallment.toFixed(3)));
                        
                        //toDo : check with Mustapha
                        const loanAmount = component.find("Loans_Requested_Loan_Finance_Amount_Amount").get("v.value");
                        component.find("Loans_Requested_Loan_Finance_Amount").set("v.value", parseFloat(parseFloat(loanAmount).toFixed(3)) );
            
                    } else if (calculationType === 'By Monthly Installment') {
                        const monthlyInstallment = component.find("RequestedMonthlyInstalment_Installment").get("v.value");
                        
                        component.find("TotalRepaymentAmount").set("v.value", parseFloat(result.totalRepayment?result.totalRepayment.toFixed(3):result.totalRepayment) );
                        component.find("TotalInterest").set("v.value", parseFloat(result.totalInterest?result.totalInterest.toFixed(3):result.totalInterest) );

                        //toDo : check with Mustapha
                        component.find("Loans_Requested_Loan_Finance_Amount_Installment").set("v.value", parseFloat(result.loanAmount.toFixed(3)) );
                        component.find("cx_ln_Requested_Cash_in_Hand").set("v.value", parseFloat(result.totalCashInHand.toFixed(3) ) );
            
                        component.find("RequestedMonthlyInstalment").set("v.value", parseFloat(parseFloat(monthlyInstallment).toFixed(3)) );
                        component.find("Loans_Requested_Loan_Finance_Amount").set("v.value", parseFloat(result.loanAmount).toFixed(3) );
                        
                        console.log('Calculated monthlyInstallment :', monthlyInstallment );
                        console.log('Calculated monthlyInstallment .003 :', parseFloat(parseFloat(monthlyInstallment).toFixed(3)));
                    }
            
                    
                    
                    component.set("v.isLoanCalculated", true);
                    component.set("v.isLoanCalculatedValidationMessage", "");
                    console.log('isLoanCalculated after calculation: ', component.get("v.isLoanCalculated"));
            
                    var product = component.find("cx_ln_Product").get("v.value");
                    if(product == 'Secured'){
                        console.log('Calculated holdAmount :', result.holdAmount);
                        component.find("ccol_Hold_Amount").set("v.value", result.holdAmount );
                        console.log('Calculated holdAmount .003 :', parseFloat(result.holdAmount.toFixed(3)));
                        component.set("v.holdAmount", parseFloat(result.holdAmount.toFixed(3)) );

                        let products = component.get("v.products");
                        component.set('v.selectedRows', []);
                        component.set('v.FinalselectedRows', []);
                        var fieldMap = [];
                        var DisabledfieldMap = [];
                        
                        for(var i in products){
                            var caseModel = component.get("v.caseModel");
                            var productType = products[i].productType == 'FIXED_DEPOSIT' && caseModel == 'alburaq' ? 'WAKALA' : products[i].productType;
                            if(products[i].availableBalance >= result.holdAmount && (products[i].linkedAsCollateral == null || products[i].linkedAsCollateral == false) ){
                                fieldMap.push({productType: productType, id: products[i].id, name: products[i].name, availableBalance: products[i].availableBalance, accountId: (products[i].accountId ? products[i].accountId : products[i].id) });
                            } else {
                                DisabledfieldMap.push({productType: productType, id: products[i].id, name: products[i].name, availableBalance: products[i].availableBalance, accountId: (products[i].accountId ? products[i].accountId : products[i].id) });
                            }
                        }
                        component.set("v.CustomerProductsOptions",fieldMap);
                        component.set("v.DisabledCustomerProductsOptions",DisabledfieldMap);
                        component.find("ccol_Hold_Account").set("v.value", null );
                        component.find("ccol_Hold_Account_IBAN").set("v.value", null );
                        component.find("ccol_Hold_Account_Balance").set("v.value", null );
                        
                    }
    
                }else{
                    helper.handleErrors(result.message);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors.length > 0) {
                    var message = errors[0].message;
                    console.log("Error: " + message);
                    helper.handleErrors(message);
                }
            }
        });

        $A.enqueueAction(action); // Enqueue the Apex action
    },
    handleErrors: function (errors) {
        // Configure error toast
        let toastParams = {
            mode:"sticky",
            title: "Erreur",
            message: errors, // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },
    calculateLiabilityTotals: function (component, event, helper,liabilitiesOptions) {
        console.log('calculateLiabilityTotals check --> ');
        console.log(liabilitiesOptions);
        var selected = liabilitiesOptions.filter(function (row) { return !!row && !!row.selected; });

        var sumOutstanding = selected.reduce(function (sum, row) {
            var val = Number(row.outstanding);
            return sum + (isNaN(val) ? 0 : val);
        }, 0);

        var sumMonthly = selected.reduce(function (sum, row) {
            var val = Number(row.monthlyInstallment);
            return sum + (isNaN(val) ? 0 : val);
        }, 0);
        
        component.find("cx_ln_TotalLiabilitiesAmount").set("v.value", sumOutstanding);
        component.find("cx_ln_TotalLiabilityMonthlyInstallAmount").set("v.value", sumMonthly);
        console.log('sumMonthly --> '+ sumOutstanding);
        console.log('sumMonthly --> '+ sumMonthly);
    },
    //aniss End
    //UATNB-211338 : Start
    getExistingLiabilitiesAndCalculateAPI: function (component, event, helper) {
        var calculationType = component.find("cx_ln_Loan_Calculation_Method").get("v.value"); 
        var loanAmount;
        var monthlyInstallment;
        if(calculationType == 'By Monthly Installment'){
            monthlyInstallment = component.find("RequestedMonthlyInstalment_Installment").get("v.value");
        }
        else if(calculationType == 'By Loan/Finance Amount'){
            loanAmount = component.find("Loans_Requested_Loan_Finance_Amount_Amount").get("v.value");
        }
        var numberOfMonths = component.find("RequestedDuration").get("v.value");
        var calculatMethod;
        // change it to the values used on the method : 'BY_MONTHLY_INSTALLMENT' or 'BY_LOAN_AMOUNT'
        if(calculationType == 'By Monthly Installment'){
            calculatMethod = 'BY_MONTHLY_INSTALLMENT';
        }else if(calculationType == 'By Loan/Finance Amount'){
            calculatMethod = 'BY_LOAN_AMOUNT';
        }

        // default 0 at the first call
        let existingLoans = 0;
        // Collect form data to pass to Apex
        var formData = {
            regionName: "Bahrain",//default value
            segment: "Regular",//default value
            nationality: "BH",//default value
            customerId: component.get("v.customer").CIF__pc,
            loanType: "personal",//default value
            subscription: component.get("v.caseModel"),
            calculationMethod: calculatMethod,
            LoanAmount: loanAmount,
            InstallmentAmount: monthlyInstallment,
            LoanDuration: numberOfMonths,
            ExistingLoans: existingLoans.toString()
        };
        // Call the Apex method with the form data as a map
        var action = component.get("c.calculatorApiCall");
        action.setParams({
            param: formData
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // Handle the response from Apex here (e.g., show the result to the user)
                console.log(result);
                console.log('api response calculation matrix :' +JSON.stringify(result.response));
                console.log('result.status calculate : ', result.status);
                if(result.status == 'Success'){
                    if (calculationType === 'By Loan/Finance Amount') {
                        component.find("RequestedMonthlyInstalment_Amount").set("v.value", parseFloat(result.monthlyInstallment.toFixed(3)) );//calculated
            
                    } else if (calculationType === 'By Monthly Installment') {
                        component.find("Loans_Requested_Loan_Finance_Amount_Installment").set("v.value", parseFloat(result.loanAmount.toFixed(3)) );//calculated
                    }

                    //prepare data for the liabilities api "getExistingLiabilitiesAPI"
                    if(calculationType == 'By Monthly Installment'){
                        loanAmount = component.find("Loans_Requested_Loan_Finance_Amount_Installment").get("v.value");//calculated
                    }
                    else if(calculationType == 'By Loan/Finance Amount'){
                        monthlyInstallment = component.find("RequestedMonthlyInstalment_Amount").get("v.value");//calculated
                    }
                    component.find('apexService').request(component.get('c.getExistingLiabilitiesAPI'), {
                        customerId : component.get("v.customer").CIF__pc,
                        caseModel : component.get("v.caseModel"),
                        loanAmount : loanAmount,
                        loanDuration : numberOfMonths,
                        loanMonthlyInstalment : monthlyInstallment
                    },
                        function(response) {
                            var result = response.getReturnValue();
                            let LiabilitiesOptions = component.get("v.LiabilitiesOptions");
                            if(!LiabilitiesOptions || LiabilitiesOptions.length === 0){
                                console.log('getExistingLiabilitiesAPI == ', result);
                                var fieldMap = [];
                                var counter = 0;
                                for(var key in result.responseData){
                                    fieldMap.push({selected: false, Id: counter , type: result.responseData[key].type, outstanding: result.responseData[key].outstanding , monthlyInstallment:  result.responseData[key].monthlyInstallment });
                                    counter ++;
                                }
                                component.set("v.LiabilitiesOptions",fieldMap);
                                component.find("cx_ln_Requested_Liabilities").set("v.value", JSON.stringify(fieldMap));
                                helper.calculateLiabilityTotals(component, event, helper,fieldMap);
                            }
                            else{
                                console.log('already existing LiabilitiesOptions no need to call the api again ==> ', LiabilitiesOptions);
                                helper.calculateLiabilityTotals(component, event, helper,LiabilitiesOptions);
                            }
            
                            //call again calcuator api to use now the liabilities ..
                            helper.calculatorApiCall(component, event, helper);
                            
                    });
    
                }else{
                    helper.handleErrors(result.message);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors.length > 0) {
                    var message = errors[0].message;
                    console.log("Error: " + message);
                    helper.handleErrors(message);
                }
            }
        });

        $A.enqueueAction(action); // Enqueue the Apex action
    },
    //UATNB-211338 : End
})