({
    scriptsLoaded : function(component, event, helper) {
        $(document).ready(function(){ 
            helper.init(component);
            component.set("v.ready", true);
            var rows = component.get('v.rows');
            if (!$A.util.isEmpty(rows)) {
                helper.setTableRows(component, rows); 
            }
        });
    }, 
    onRowsChange : function(component, event, helper) {
        if (true === component.get("v.ready")) {
            var newRows = component.get('v.rows');
            helper.setTableRows(component, newRows); 
        }
    }, 
    onRowSelectionChange : function(component, event, helper) {
        helper.broadcastSelectedRows(component);
    }, 
    onRowDeSelectionChange : function(component, event, helper) {
        helper.broadcastDeSelectedRows(component);
    }, 
    handleJqDataTableEvent: function(component, event, helper) {
        helper.handleJqDataTableEvent(component, event);
    },
    
    selectShown: function(component, event, helper) {
        helper.selectRows(component, event, helper, "shown");
        helper.closeRowSelectionChoiceDialogue(component);
    },
    selectAll: function(component, event, helper) {
        helper.selectRows(component, event, helper, "all");
        helper.closeRowSelectionChoiceDialogue(component);
    },
    closeSelectionDialogue: function(component, event, helper) {
        helper.closeRowSelectionChoiceDialogue(component);
        
        // selection cancelled - return "Select All" checkbox value to previous state
        var tableDiv = helper.getTableElement(component);	
        if (!tableDiv) {
            return;
        }
        var selectAllControl = tableDiv.find('input:checkbox.selectAll');
        var isChecked = selectAllControl.is(':checked');
        selectAllControl.prop('checked', !isChecked);
        component.set('v.isSelectAllChecked', isChecked);
    },

});