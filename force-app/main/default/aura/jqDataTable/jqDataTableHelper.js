({
    getTableElementId: function(component) {
        var id = component.get('v.id');
        return id;
    },
    getTableElement: function(component) {
        var id = this.getTableElementId(component);
        return $('#' + id);
    },
	init: function(component) {
        /*
           var dataSet = [
           [ "Tiger Nixon", "System Architect", "Edinburgh", "5421", "2011/04/25", "$320,800" ],
           [ "Garrett Winters", "Accountant", "Tokyo", "8422", "2011/07/25", "$170,750" ]
           ];
           $('#dataTable').DataTable( {
                data: dataSet,
                columns: [
                { title: "Name" },
                { title: "Position" },
                { title: "Office" },
                { title: "Extn." },
                { title: "Start date" },
                { title: "Salary" }
                ]
                } );	
         */
        var thisHelper = this;
        var columns = component.get('v.columns');
        var showCheckboxColumn =  component.get('v.showCheckboxColumn');
        var firstVisibleColumnIndex = true === showCheckboxColumn ? 1 : 0;
        var columnDefs = component.get('v.columnDefs');
        var orderBy = component.get('v.orderBy');
        var dataTable = thisHelper.getTableElement(component).DataTable( {
            "rowId": component.get('v.keyField'), 
            "scrollX": true,
            // JT 10-06-19 Change to prevent error DataTables warning: table id=bankTransactionsTable - 
            // Cannot reinitialise DataTable. For more information about this error, please see http://datatables.net/tn/3
            // "destroy" : "true",
            
            "columns": columns,
            "columnDefs": columnDefs,
            
            "select": {
                style:    component.get("v.selectStyle"),//'multi+shift',
                //selector: 'td:first-child'
            },
            /* https://stackoverflow.com/questions/17569632/customize-th-rendering-in-datatables */
            "headerCallback": function headerCallback(thead, data, start, end, display) {
                if (showCheckboxColumn) {
                    var isSelectAllChecked = component.get('v.isSelectAllChecked');
                    var checkedVal = '';//isSelectAllChecked ? ' checked ' : '';
                    $(thead)
                    .find('th')
                    .first()
                    .html('<input type="checkbox" class="selectAll" title="Select/Deselect All" '+checkedVal+'></input>');
                    
                    thisHelper._initHeader(component, dataTable);
                }
            },
            "order": [[firstVisibleColumnIndex + 1, orderBy]],
            "lengthMenu": [ 10, 25, 50, 75, 100, 250, 500 ],
            "destroy": true
            //"deferRender": true, // this line makes no difference, hence disabled
        } );	
	},
    
    setTableRows: function(component, newRows) {
        var thisHelper = this;
        var dataTable = thisHelper.getTableElement(component).DataTable();	
        console.log('redraw table with new rows: ' + newRows.length);
        dataTable.clear().draw();
        dataTable.rows.add(newRows);
        dataTable.draw();

        //this._initHeader(component, dataTable);
        this._initRows(component, dataTable);
       
    },
    
    _initRows: function(component, dataTable) {
        var thisHelper = this;
        dataTable.on( 'select deselect', function ( e, dt, type, indexes ) {
            if ("deselect" === e.type) {
                var deSelectedRows = dataTable.rows(indexes);
                component.set('v.deSelectedRows', deSelectedRows[0]);
            }
            var selectedRows = dataTable.rows( { selected: true } );
            component.set('v.selectedRows', selectedRows[0]);
        } );
    },
    
    _initHeader: function(component, dataTable) {
        var thisHelper = this;
        thisHelper.getTableElement(component).find('input:checkbox.selectAll').change(function(e){
            //thisHelper.selectAll(component, dataTable);
            thisHelper.openRowSelectionChoiceDialogue(component, dataTable);
        });
    },
    
    openRowSelectionChoiceDialogue: function(component, dataTable) {
        var isChecked = this.getTableElement(component).find('input:checkbox.selectAll').is(':checked');
        component.set('v.isSelectAllChecked', isChecked);
        if (!dataTable) {
            return;
        }
        
        // display appropriate prompt text and button labels
        var dialogue = document.getElementById('rowSelectionChoiceDialogue');
        if (dialogue) {
            component.find('btnSelectShown').set('v.label', isChecked ? 'Select Shown' : 'Deselect Shown');
            component.find('btnSelectAll').set('v.label', isChecked ? 'Select All' : 'Deselect All');
            var span = document.getElementById('rowSelectionChoiceDialogueText');
            if (span) {
                span.querySelector(isChecked ? '.onSelect' : '.onDeSelect').style.display = 'block';
                span.querySelector(isChecked ? '.onDeSelect' : '.onSelect').style.display = 'none';
            }

            dialogue.style.display = "block";
        }
        
    },
    closeRowSelectionChoiceDialogue: function(component) {
        var dataTable = this.getTableElement(component).DataTable();	
        if (!dataTable) {
            return;
        }
        var dialogue = document.getElementById('rowSelectionChoiceDialogue');
        if (dialogue) {
            dialogue.style.display = "none";
        }
        
    },
    
    selectRows: function(component, event, thisHelper, selectionType) {
        var dataTable = thisHelper.getTableElement(component).DataTable();	
        if (!dataTable) {
            return;
        }
        var isChecked = thisHelper.getTableElement(component).find('input:checkbox.selectAll').is(':checked');

        var isAll = "all" === selectionType;
        var rowsModifier = isAll? {} : { page: 'current' };
        
        //var cells = dataTable.cells( ).nodes();
        //$( cells ).find('input:checkbox.rowSelector').prop('checked', isChecked);
        if (isChecked) {
             dataTable.rows(rowsModifier).select();
        } else {
             dataTable.rows(rowsModifier).deselect();
        }
        // Looks like we do not need to broadcast this event
        //var selectedRows = dataTable.rows( { selected: true } );
        //component.set('v.selectedRows', selectedRows);
    },
     
    broadcastDeSelectedRows: function(component) {
        var thisHelper = this;
        var dataTable = thisHelper.getTableElement(component).DataTable();	
        var selectedRows = component.get('v.deSelectedRows');
        var rows = dataTable.rows(selectedRows).data();
        var selectedKeys = [];

        var keyField = component.get('v.keyField');
        if (keyField) {
            for( var i = 0; i < rows.length; i++) {
                var row = rows[i];
                var rowId = row[keyField];
                selectedKeys.push(rowId);
            }
        }
        if (!$A.util.isEmpty(selectedKeys)) {
            var appEvent = $A.get("e.c:jqDataTableEvent");
            var message = {
                "action": "broadcastDeSelectedRows",
                "rowIds": selectedKeys,
                //"selectedRowDataByKey": selectedRowDataByKey
            };
            appEvent.setParams(
                { 
                    "message": message
                }
            );
            appEvent.fire();
        }
    },
    /**
     * broadcast Ids of rows selected in jqDataTable selected
     */
    broadcastSelectedRows: function(component) {
        var thisHelper = this;
        var dataTable = thisHelper.getTableElement(component).DataTable();	
        var selectedRows = component.get('v.selectedRows');
        var rows = dataTable.rows(selectedRows).data();
        var selectedKeys = [];

        var keyField = component.get('v.keyField');
        if (keyField) {
            for( var i = 0; i < rows.length; i++) {
                var row = rows[i];
                var rowId = row[keyField];
                selectedKeys.push(rowId);
            }
        }
        
        var appEvent = $A.get("e.c:jqDataTableEvent");
        var message = {
            "action": "broadcastSelectedRows",
            "rowIds": selectedKeys,
        };
        appEvent.setParams(
            { 
                "message": message
            }
        );
        appEvent.fire();
    },
    
    handleJqDataTableEvent: function(component, event) {
        console.log("jqDataTable.handleJqDataTableEvent=" + JSON.stringify(event));
        var thisHelper = this;
        var message = event.getParam("message");
        var action = message.action;
        
        if ( "displayChild" === action) {
            var rows = message.rowsWithChildData;
            var dataTable = thisHelper.getTableElement(component).DataTable();	
            
            for (var i = 0; i < rows.length; i++) {
                var row = rows[i];
                var rowId = row.id;
                var tableRow = dataTable.row('#' + rowId);
                if (false === tableRow.child.isShown()) {
                    //show child
                    var childData = row.childData;
                    tableRow.child( childData ).show();
                    //tableRow.child( thisHelper.format(childData) ).show();
                    /*
                    dataTable.row( ':eq(0)' ).child( [
                        'First child row',
                        'Second child row',
                        'Third child row'
                    ] )
                    .show();
                    */
                   /*
                    tableRow.child( [
                        'First child row',
                        'Second child row',
                        'Third child row'
                    ] )
                    .show();
                    */
                }
            }
        } else if ("hideChild" === action) {
            var rowIds = message.rowIds;
            var dataTable = thisHelper.getTableElement(component).DataTable();	
            
            for (var i = 0; i < rowIds.length; i++) {
                var rowId = rowIds[i];
                var tableRow = dataTable.row('#' + rowId);
                if (true === tableRow.child.isShown()) {
                    tableRow.child.hide();
                }
                
            }
        }
        
    },
    format: function ( d ) {
        // `d` is the original data object for the row
        return '<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
            '<tr>'+
            '<td>Full name:</td>'+
            '<td>'+'NAME GOES HERE'+'</td>'+
            '</tr>'+
            '<tr>'+
            '<td>Extension number:</td>'+
            '<td>'+'EXTENSION GOES HERE'+'</td>'+
            '</tr>'+
            '<tr>'+
            '<td>Extra info:</td>'+
            '<td>And any further details here (images etc)...</td>'+
            '</tr>'+
            '</table>';
    }

});