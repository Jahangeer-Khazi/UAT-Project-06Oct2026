/**
 * Created by Himanshu on 13/01/2022.
 */


 ({

            parseFileAndInsertContent: function (cmp, evt, helper) {

                /*var file = cmp.get("v.file");
                  console.log('File Name ' +file.name);*/
                var drawId = cmp.get("v.recordId");

                var fileaction = cmp.get("c.parseFile");
                //console.log('parseFile fired >> '+cmp.get("v.filedata"));
                console.log('parseFile fired >> ');
                fileaction.setParams({
                     csvDataString: cmp.get("v.filedata"),
                     drawId: drawId
                });

                fileaction.setCallback(this, function (response) {
                  var state =  response.getState()
                 if (state == "SUCCESS") {
                       //cmp.set("v.showResponseText",true);
                       //cmp.set("v.responseText", JSON.stringify(response.getReturnValue()));
                       if(response.getReturnValue()){  //call is successful but not all the records are loaded. Failed records were attached to the csv
                            this.fireToast('Error', 'Some of the records are no uploaded. Please refresh the page and check attached error file on the draw entries', 50000 , 'Error', 'dismissible' );
                       }else{
                       console.log(' parseFileAndInsertContent Success >> ' );
                       this.fireToast('Success', 'Draw entries are uploaded successfully', '' , 'Success', 'sticky' );
                       }

                 }else if(state == "ERROR"){
                            console.error('parseFileAndInsertContent Error happened');
                            this.handleErrors(cmp, response.getError());
                    }
                   cmp.set('v.loaded',false);
                });
                $A.enqueueAction(fileaction);
            },

      loadExcelFileName : function(cmp) {
            try {
                cmp.set('v.loaded',true);
                var action = cmp.get("c.getAWSService");
                 action.setCallback(this, function (response) {

                 var state = response.getState();

                  if (state == "SUCCESS") {

                      if(!$A.util.isEmpty(response.getReturnValue())){
                       console.log('>>>>>>> res ' +JSON.stringify(response.getReturnValue()));
                       cmp.set('v.showFileLink',true);
                       cmp.set("v.fileNamedata", response.getReturnValue());

                      }else{
                             console.error('No data found');
                             this.fireToast('Error', 'No file found', '' ,'Error', 'sticky');
                        }

                  }else if(state == "ERROR"){
                       this.handleErrors(cmp, response.getError());
                  }
                  cmp.set('v.loaded',false);

                });
                $A.enqueueAction(action);
            } catch (exceptionMessage) {
            console.error('Catch exception :' +exceptionMessage);
            //helper.throwExceptionEvent(cmp, exceptionMessage);

        }
     	},
     	  loadExcelFileContent : function(cmp, event, helper) {
                 cmp.set('v.loaded',true);
     	         var selectedFileName = cmp.find("AWSfiles").get("v.value");
                 console.log(' \t Selected file >>' +selectedFileName);
                 var action = cmp.get("c.getAWSFileContent");
                 action.setParams({
                     fileName : selectedFileName
                     });

                 action.setCallback(this, function (response) {
                 var state = response.getState();
                  if (state == "SUCCESS" && !$A.util.isEmpty(response.getReturnValue())) {
                       var res =  response.getReturnValue();
                       //console.log('res >>>>>>>  ' +JSON.stringify(res));
                        cmp.set('v.showFileLink',true);
                        //var blobData = "data:" + res.ContentType + ";base64," + res.Content;
                        cmp.set("v.filedata", res.Content);
                        //insert the content :
                        console.log(' The loadExcelFileContent CALL SUCCESS');
                        helper.parseFileAndInsertContent(cmp, event, helper);
                      }else if(state == "ERROR"){
                       console.error(' The loadExcelFileContent CALL ERROR');
                       this.handleErrors(cmp, response.getError());
                  }

                });
                $A.enqueueAction(action);
     	},
     	fireToast : function(title, message, duration, type, mode ){

     	    $A.get("e.force:showToast").setParams({
                                title : title,
                                message: message,
                                duration: duration,
                                key: 'info_alt',
                                type: type,
                                mode: mode,
                                allowHTML : true
            }).fire();

       },
       handleErrors: function (cmp, errors) {
                 if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                        this.fireToast('Error', errors[0].message ,  '' , 'Error', 'sticky' );

                    }
                }

            }
       });