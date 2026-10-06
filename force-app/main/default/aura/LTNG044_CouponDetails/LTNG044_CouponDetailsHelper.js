({
    formatData: function(component, transactionObj){
        var result = {};
        result.creationDate = transactionObj.creationDate;
        result.amount = transactionObj.amount;
        result.CouponCreditedTo = transactionObj.proceedsCreditedTo;
        result.CouponCreditedOn = transactionObj.proceedsCreditedOn;
        return result;
        
    },
    loadCouponDetails:function(component,helper){
        var Investmentdata= component.get('v.InvestmentData');
        component.find('apexService').request(component.get('c.loadCouponDetails'), {
            "investment_id": Investmentdata.id,
            "regionName" : component.get('v.regionName'),
            "customerId" :component.get('v.customerId')
        },
                                              function(response) {
                                                  
                                                  var result = response.getReturnValue();
                                                  console.log("result",JSON.stringify(result));
                                                  var data = [];
                                                  var transactionsBatch = [];
                                                  var recordLength = 0;
                                                  if (true === result.isSuccess && !$A.util.isEmpty(result.responseData.distributeDetails)) {
                                                      transactionsBatch = result.responseData.distributeDetails;
                                                      console.log('inside bacth'+JSON.stringify(transactionsBatch));
                                                      for (var i = 0; i < transactionsBatch.length; i++) {
                                                          //CH03: Start
                                                          var transactionObj = transactionsBatch[i]; 
                                                          console.log('##transactionObj#'+JSON.stringify(transactionObj));
                                                          data.push(helper.formatData(component, transactionObj));
                                                          //CH03: END
                                                      }
                                                      component.set('v.viewCouponDetails','true');
                                                      component.set('v.data',data);
                                                  }else if(true === result.isSuccess && $A.util.isEmpty(result.responseData.distributeDetails)){
                                                      component.set('v.viewNoCouponDetailsMsg',true);
                                                  }
                                                  
                                              });
    }
    
})