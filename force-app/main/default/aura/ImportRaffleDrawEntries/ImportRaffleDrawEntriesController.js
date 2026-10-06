/**
 * Created by Himanshu on 13/01/2022.
 */

({
     init : function(cmp, event, helper) {
          helper.loadExcelFileName(cmp);
     },
    getAWSFile : function(cmp, event, helper){
          helper.loadExcelFileContent(cmp, event, helper);

    }/*,
     onTableImport: function (cmp, evt, helper) {
         helper.disableExcelInput(cmp);
         helper.importTableAndThrowEvent(cmp, evt, helper);
     }*/

});