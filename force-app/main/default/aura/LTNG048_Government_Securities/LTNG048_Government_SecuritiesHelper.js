({
    loadGovernmenSecurities: function(component, helper, event) {
        var helper = this;
        if(!$A.util.isEmpty(component.get('v.selectedLookUpRecord'))){
            component.set('v.customerId',component.get('v.selectedLookUpRecord.CIF__pc'));
        }
        var customerId = component.get('v.customerId');
        var unit = component.get('v.unit');
        component.find("apexService").request(
            component.get("c.loadGovSecurities"),
            {      
                regionName:unit,
                customerId:customerId// #CH04#
            },
            
            function(response) {
                var result = response.getReturnValue();
                console.log("result", result);
                var data = [];
                var results;
                var instrumentsBatch = [];
                var recordLength = 0;
                if (true === result.isSuccess) {
                    recordLength = parseInt(result.recordLength);
                    console.log("Record Length from Server:" + recordLength);
                }
                if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) { 
                    results=result.responseData;
                    instrumentsBatch = results.instruments;
                    console.log('#instrumentsBatch#'+JSON.stringify(instrumentsBatch));
                    console.log('length##'+instrumentsBatch.length);
                    for (var i = 0; i < instrumentsBatch.length; i++) {
                        //CH03: Start
                        console.log('instrumentsBatch'+JSON.stringify(instrumentsBatch[i]));
                        var instrument = instrumentsBatch[i];
                        console.log('###instrumentObj##'+JSON.stringify(instrument));
                        data.push(helper.formatData(component,instrument));
                        console.log('###instrumentdata##'+JSON.stringify(data));
                        //CH03: END
                    } 
                    component.set('v.gridDataRows',data);
                }
            }
        );
    },
    formatData: function(component,instrument){
        //CH01: Start
        //
        //alert(new Date(instrument.invitationDateCBB).toUTCString());
        var helper = this;
        var result = {};
        result.id =instrument.id;
        result.isInCodeCBB =instrument.isInCodeCBB;
        result.isInTypeCBB =instrument.isInTypeCBB;
        result.invitationDateCBB =(this.addHours(this.parseDate(instrument.invitationDateCBB),3)).toLocaleString();
        result.bidDueDate=(this.addHours(this.parseDate(instrument.bidDueDate),3)).toLocaleString();
        result.status=instrument.status;
        result.securityType=instrument.securityType;
        result.instrumentData=instrument;
        console.log('####result###'+result);
        return result;
    },
    parseDate:function (dateTimeString){
        // Split the date and time parts
        const [datePart, timePart] = dateTimeString.split(' ');
        // Split the date into day, month, and year
        const [day, month, year] = datePart.split('-').map(Number);
        // Split the time into hours, minutes, and seconds
        const [hours, minutes, seconds] = timePart.split(':').map(Number);
        return new Date(year, month - 1, day, hours, minutes, seconds);
    },
    addHours:function(date, hours) {
        const hoursToAdd = hours * 60 * 60 * 1000;
        date.setTime(date.getTime() + hoursToAdd);
        return date;
    },
    handleJqDataTableEvent: function(component, event) {
        console.log("bankAccountTransaction.handleJqDataTableEvent=" + JSON.stringify(event));
        var message = event.getParam("message");
        var action = message.action;
        var thisHelper = this;
        if ("getSelectedRowsResponse" === action) {
        } else if ("broadcastSelectedRows" === action) {
            var selectedIds = message.rowIds;
            console.log("selectedIds=" + JSON.stringify(selectedIds));
            var gridDataRows = component.get("v.gridDataRows");
            var selectedRows = [];
            if (!$A.util.isEmpty(gridDataRows)) {
                for (var i = 0; i < selectedIds.length; i++) {
                    var id = selectedIds[i];
                    var foundRow = gridDataRows.find(function(row) {
                        return row.id === id;
                    });
                    if (foundRow) {
                        selectedRows.push(foundRow);
                    }
                }
            }
            thisHelper.getRatesDetails(component, selectedRows);
        } else if ("broadcastDeSelectedRows" === action) {
            var selectedIds = message.rowIds;
            thisHelper.onDeSelectRow(component, selectedIds);
        }
    },
    getRatesDetails:function(component,selectedRows){
        var thisHelper = this;
        var unit = component.get('v.unit');
        var rowsWithChildData = [];
        var historyData=[];
        console.log('subType'+JSON.stringify(selectedRows));
        for (var i = 0; i < selectedRows.length; i++) {
            var Row = selectedRows[i];
            component.find("apexService").request(
                component.get("c.getHistoryDetails"),
                {      
                    regionName:unit,
                    subType:Row.instrumentData.subType// #CH04#
                },
                
                function(response) {
                    var result = response.getReturnValue();
                    console.log('resulthistoryData'+JSON.stringify(result.responseData.instruments));  
                    console.log('resultselectedRows'+JSON.stringify(selectedRows)); 
                    historyData = result.responseData.instruments;
                    if(historyData){
                        thisHelper.onSelectRow(component,selectedRows,historyData); 
                    }   
                }
            );
            // console.log('historyData'+JSON.stringify(historyData));   
            
        }
    },
    // notify other components about row selection
    onSelectRow: function(component,selectedRows,historyData) {
        if ($A.util.isEmpty(selectedRows)) {
            return;
        }
        var thisHelper = this;
        console.log('historyData'+historyData);
        console.log('historyData.length'+historyData.length);
        var rowsWithChildData = [];
        for (var i = 0; i < selectedRows.length; i++) {
            var row = selectedRows[i];
            console.log('row'+JSON.stringify(row));
            // for(var j=0; j<historyData.length; j++){
            rowsWithChildData.push({
                id: row.id,
                childData: thisHelper.formatChildData(row,historyData)   
            });
            //  }
        }
        // request child row data display
        var appEvent = $A.get("e.c:jqDataTableEvent");
        var message = {
            action: "displayChild",
            rowsWithChildData: rowsWithChildData
        };
        appEvent.setParams({
            message: message
        });
        appEvent.fire();
    },
    onDeSelectRow: function(component, rowIds) {
        if ($A.util.isEmpty(rowIds)) {
            return;
        }
        var appEvent = $A.get("e.c:jqDataTableEvent");
        var message = {
            action: "hideChild",
            rowIds: rowIds
        };
        appEvent.setParams({
            message: message
        });
        appEvent.fire();
    },
    
    formatChildData: function(row,historyData) {
        console.log('row'+JSON.stringify(row.instrumentData));
        var d = row.instrumentData;
        // var e = historyData;
        var numberFormatter = new Intl.NumberFormat('en-GB', { style: 'decimal', maximumFractionDigits: 3});
        // `row` is the original data object for the row
        var historyTable='';
        for(var j=0; j<historyData.length; j++){
            var trend = historyData[j].trend=='UP'?'<span style="color:green;">&#x25B2;</span>':(historyData[j].trend=='DOWN'?'<span style="color:red;">&#x25BC;</span>':'<span style="color:black;">&#x229C;</span>');
            historyTable= historyTable+"<tr><td>"+historyData[j].isinCode +"</td><td>"+historyData[j].issueDate +"</td><td>"+trend+"</td><td>"+Number(historyData[j].rate).toFixed(2) +"</td></tr>";
        }
        return (
            '<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">' +
            "<tr>" +
            "<td><b>Group</b></td>" +
            "<td>"+
            d.group +
            "</td>" +
            "<td><b>Maturity Date:</b></td>" +
            "<td>" +
            d.maturityDateCBB +
            "</td>" +
            "</tr>" +
            "<tr>" +
            "<td><b>Maximum Order Amount:</b></td>" +
            "<td>" +
            numberFormatter.format(d.maximumOrderAmount) +
            "</td>" +
            "<td><b>Minimum Order Amount:</b></td>" +
            "<td>" +
            numberFormatter.format(d.minimumOrderAmount) +
            "</td>" +
            "</tr>" +
            "<tr>" +
            "<td><b>Processing Fees - Percentage:</b></td>" +
            "<td>" +
            (typeof d.processingFeesPercentage !='undefined'?d.processingFeesPercentage:'') +
            "</td>" +
            "<td><b>Processing Fees - Min. Amount:</b></td>" +
            "<td>" +
            (typeof d.processingFeesMinimumAmount !='undefined'?numberFormatter.format(d.processingFeesMinimumAmount):'') +
            "</td>" +
            "</tr>" +
            "<tr>" +
            "<td><b>Processing Fees - VAT %:</b></td>" +
            "<td>" +
            (typeof d.processingFeesVAT !='undefined'?numberFormatter.format(d.processingFeesVAT)+' %':'') +
            "</td>" +
            "<td><b>IssueNo:</b></td>" +
            "<td>" +
            d.issueNoCBB +
            "</td>" +
            "</tr>" +
            "<tr>" +
            "<td><b>Issue Price:</b></td>" + //RM edit, was "Original Amount"
            "<td>" +
            (typeof d.issuePrice !='undefined'?d.issuePrice:'')  +
            "</td>" + //RM edit, was originalAmount
            "<td><b>Issue Amount:</b></td>" + //RM edit, was "Original Amount"
            "<td>" +
            numberFormatter.format(d.issueAmountCBB) +
            "</td>" + //RM edit, was originalAmount
            "</tr>" +
            "<tr>" +
            "<td><b>Issue Date:</b></td>" + //RM edit, was "Original Amount"
            "<td>" +
            d.issueDateCBB +
            "</td>" + //RM edit, was originalAmount
            "<td><b>Period:</b></td>" +
            "<td>" +
            Math.round(d.period.tenure) +' '+ d.period.tenure_type+'(s)'+
            "</td>" +
            "</tr>" +
            "<tr>" +
            "<td><b>Tender Date:</td>" +
            "<td>" +
            d.tenderDateCBB +
            "</td>" +
            "<td><b>Rate:</td>" +
            "<td>" +
            Number(d.rateCBB).toFixed(2) +
            "</td>" +
            "</tr>" +
            "<tr>" +
            "<td><b>Category:</td>" +
            "<td>" +
            d.categoryName +
            "</td>" +
            "<td><b>Coupon Distribution:</td>" +
            "<td>" +
            d.couponDistributionFlag +
            "</td>" +
            "</tr>" +
            "<tr>" +
            "<td><b>Coupon Distribution Frequency:</td>" +
            "<td>" +
            (typeof d.couponDistributionFrequency !='undefined'?d.couponDistributionFrequency+' Months':'') +
            "</td>" +
            "<td><b>Currency:</td>" +
            "<td>" +
            d.currency +
            "</td>" +
            "</tr>" +
            "<tr>"+
            "<td><b><u>HISTORICAL RATES</u></b></td><td></td>"+
            "</tr>"+
            '<table cellpadding="2" cellspacing="0" border="0" style="padding-left:20px;">' +
            "<tr>" +
            "<th><b>ISIN Code:</b></th>" +
            "<th><b>Issue Date:</b></th>" +
            "<th><b>Trend:</b></th>" +
            "<th><b>Rate:</b></th>" +
            "</tr>" +
            historyTable+
            "</table>"+
            "</table>"
        );
    },
    /*  formatHistoryData: function(row) {
        var d = row;
        console.log('formatHistoryData'+JSON.stringify(row));
        console.log('isinCode##3'+row.isinCode);
        var numberFormatter = new Intl.NumberFormat('en-GB', { style: 'decimal', maximumFractionDigits: 3});
        // `row` is the original data object for the row
        return (
            '<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">' +
            "<tr>" +
            "<td><b>ISIN Code:</b></td>" +
            "<td>"+
            d.isinCode +
            "</td>" +
            "<td><b>Issue Date:</b></td>" +
            "<td>" +
            d.issueDate +
            "</td>" +
            "</tr>" +
            "<tr>" +
            "<td><b>Trend:</b></td>" +
            "<td>" +
            d.trend +
            "</td>" +
            "<td><b>Rate:</b></td>" +
            "<td>" +
            d.rate +
            "</td>" +
            "</tr>" +
            "</table>"
        );
    },*/
    //CH01: END
    getDataColumns: function(component) {
        return [
            {title: 'id', data: 'id', "orderable": false, "visible": false, "searchable": false},
            {title: 'ISIN Code', data: 'isInCodeCBB'},
            {title: 'ISIN Type', data: 'isInTypeCBB'},
            {title: 'Security Type', data: 'securityType'},
            {title: 'Status', data: 'status'},
            {title: 'Invitation Date', data: 'invitationDateCBB'},//, className: 'dt-body-right' //RM edit, was {title: 'Amount', data: 'amount'} // Ashish -  {title: 'Amount', data: 'originalAmount'}
            {title: 'Bid DueDate', data: 'bidDueDate'},
        ];
            },
            
            getColumnDefs: function(component) {
            var columnDefs = [
            
            {
            targets: '_all',
            "defaultContent": ""
            }, 
            { targets: 1, width: '10%'},
            { targets: 2, width: '10%'},
            { targets: 3, width: '10%'},
            { targets: 4, width: '10%' },
            { targets: 5, width: '10%',type : 'date' },
            { targets: 6, width: '10%',type : 'date'}
        ];
        return columnDefs;
        
    },
    
    customerDetails:function(component,event,helper){
        var helper = this;
        var customerId =component.get('v.customerId');
        component.find("apexService").request(
            component.get("c.getCustomerDetails"),
            {      
                regionName:'Bahrain',
                customerId:customerId// #CH04#
            },
            
            function(response) {
                var result = response.getReturnValue();
                console.log("result- Customer", JSON.stringify(result));
                var data = [];
                var results;
                if (true === result.isSuccess) {
                    recordLength = parseInt(result.recordLength);
                    console.log("Record Length from Server:" + recordLength);
                }
                if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) { 
                    results=result.responseData;
                }
            }
        );
    }
});