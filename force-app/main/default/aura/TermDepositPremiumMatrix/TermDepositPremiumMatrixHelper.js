/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:03-01-2022
 * 		Change History: 
 *			  
*/
({
	loadTermDepositMatrix : function(component,customerId,helper) {
		var helper = this;
       // var customerId = '1294463';
        component.find('apexService').request(component.get('c.termDepositMatrix'), {
		    customerId: customerId,
            regionName:component.get('v.regionName')
        },
        function(response) {
		    var result = response.getReturnValue();
            var data = {};
            var lstCurrency = [];
            var termDepositMatrixData = [];
            var termDepositMatrixData1month = [];
            var termDepositMatrixData3month = [];
            var termDepositMatrixData6month = [];
            var termDepositMatrixData9month = [];
            var termDepositMatrixData1year = [];
            var termDepositMatrixData2year = [];
            
            var termDepositMatrixDataUSA = [];
            var termDepositMatrixData1monthUSA = [];
            var termDepositMatrixData3monthUSA = [];
            var termDepositMatrixData6monthUSA = [];
            var termDepositMatrixData9monthUSA = [];
            var termDepositMatrixData1yearUSA = [];
            var termDepositMatrixData2yearUSA = [];
            
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData))
            {
                data = result.responseData;
            }
			for(var i = 0; i < data.termDepositMatrixs.length; i++){
				lstCurrency.push(data.termDepositMatrixs[i].currency.code);
			}
			var uniqCurrency = [...new Set(lstCurrency)];
			console.log('Unique Currency 0:'+uniqCurrency[0]);
            console.log('Unique Currency 1:'+uniqCurrency[1]);
            console.log('Unique Currency Length:'+uniqCurrency.length);
			for(var h = 0; h < uniqCurrency.length; h++){
				/*if(uniqCurrency[h] == 'BHD'){
                    component.set('v.BHDTable',uniqCurrency[h]);
                }
                if(uniqCurrency[h] == 'USD'){
                    component.set('v.USDTable',uniqCurrency[h]);
                }*/
				
				for(var i = 0; i < data.termDepositMatrixs.length; i++){
				   
				   if(data.termDepositMatrixs[i].segmentId === 'Premium' && data.termDepositMatrixs[i].currency.code === 'BHD' && uniqCurrency[h] === 'BHD'){
						var fromAmount = data.termDepositMatrixs[i].fromAmount;
						var toAmount = data.termDepositMatrixs[i].toAmount;
						var amtRange;
						
						if(fromAmount != toAmount){
							 amtRange = fromAmount +'-' +toAmount;
						}
						if(fromAmount == toAmount){
							 amtRange = fromAmount  +'>' ;
						}
						termDepositMatrixData.push(amtRange);
					   
						for(var j = 0; j < data.termDepositMatrixs[i].tiers.length; j++){
						   if(data.termDepositMatrixs[i].tiers[j].tenorValue == 1 && data.termDepositMatrixs[i].tiers[j].tenorUnit === 'month'){
							 
							   termDepositMatrixData1month.push(data.termDepositMatrixs[i].tiers[j].interestRate);
						   }
						   if(data.termDepositMatrixs[i].tiers[j].tenorValue == 3 && data.termDepositMatrixs[i].tiers[j].tenorUnit === 'month'){
							  
							   termDepositMatrixData3month.push(data.termDepositMatrixs[i].tiers[j].interestRate);
						   }
						   if(data.termDepositMatrixs[i].tiers[j].tenorValue == 6 && data.termDepositMatrixs[i].tiers[j].tenorUnit === 'month'){
							 
							   termDepositMatrixData6month.push(data.termDepositMatrixs[i].tiers[j].interestRate);
						   }
						   if(data.termDepositMatrixs[i].tiers[j].tenorValue == 9 && data.termDepositMatrixs[i].tiers[j].tenorUnit === 'month'){
							   
							   termDepositMatrixData9month.push(data.termDepositMatrixs[i].tiers[j].interestRate);
						   }
						   if(data.termDepositMatrixs[i].tiers[j].tenorValue == 1 && data.termDepositMatrixs[i].tiers[j].tenorUnit === 'year'){
							  
							   termDepositMatrixData1year.push(data.termDepositMatrixs[i].tiers[j].interestRate);
						   } 
						   if(data.termDepositMatrixs[i].tiers[j].tenorValue == 2 && data.termDepositMatrixs[i].tiers[j].tenorUnit === 'year'){
							 
							   termDepositMatrixData2year.push(data.termDepositMatrixs[i].tiers[j].interestRate);
						   } 
						   
					   }
					 
					}
					else if(data.termDepositMatrixs[i].segmentId === 'Premium' && data.termDepositMatrixs[i].currency.code === 'USD' && uniqCurrency[h] === 'USD'){
						var fromAmount = data.termDepositMatrixs[i].fromAmount;
						var toAmount = data.termDepositMatrixs[i].toAmount;
						var amtRange;
						if(fromAmount != toAmount){
							 amtRange = fromAmount +'-' +toAmount;
						}
						if(fromAmount == toAmount){
							 amtRange = fromAmount  +'>' ;
						}
						termDepositMatrixDataUSA.push(amtRange);
					   
						for(var j = 0; j < data.termDepositMatrixs[i].tiers.length; j++){
						   if(data.termDepositMatrixs[i].tiers[j].tenorValue == 1 && data.termDepositMatrixs[i].tiers[j].tenorUnit === 'month'){
							 
							   termDepositMatrixData1monthUSA.push(data.termDepositMatrixs[i].tiers[j].interestRate);
						   }
						   if(data.termDepositMatrixs[i].tiers[j].tenorValue == 3 && data.termDepositMatrixs[i].tiers[j].tenorUnit === 'month'){
							  
							   termDepositMatrixData3monthUSA.push(data.termDepositMatrixs[i].tiers[j].interestRate);
						   }
						   if(data.termDepositMatrixs[i].tiers[j].tenorValue == 6 && data.termDepositMatrixs[i].tiers[j].tenorUnit === 'month'){
							 
							   termDepositMatrixData6monthUSA.push(data.termDepositMatrixs[i].tiers[j].interestRate);
						   }
						   if(data.termDepositMatrixs[i].tiers[j].tenorValue == 9 && data.termDepositMatrixs[i].tiers[j].tenorUnit === 'month'){
							   
							   termDepositMatrixData9monthUSA.push(data.termDepositMatrixs[i].tiers[j].interestRate);
						   }
						   if(data.termDepositMatrixs[i].tiers[j].tenorValue == 1 && data.termDepositMatrixs[i].tiers[j].tenorUnit === 'year'){
							  
							   termDepositMatrixData1yearUSA.push(data.termDepositMatrixs[i].tiers[j].interestRate);
						   } 
						   if(data.termDepositMatrixs[i].tiers[j].tenorValue == 2 && data.termDepositMatrixs[i].tiers[j].tenorUnit === 'year'){
							 
							   termDepositMatrixData2yearUSA.push(data.termDepositMatrixs[i].tiers[j].interestRate);
						   } 
						   
					  }
					 
					}
				}
		    }
           
            component.set('v.termDepositData',termDepositMatrixData);
            component.set('v.termDepositDataFor1Month',termDepositMatrixData1month);
            component.set('v.termDepositDataFor3Month',termDepositMatrixData3month);
            component.set('v.termDepositDataFor6Month',termDepositMatrixData6month);
            component.set('v.termDepositDataFor9Month',termDepositMatrixData9month);
            component.set('v.termDepositDataFor1Year',termDepositMatrixData1year);
            component.set('v.termDepositDataFor2Year',termDepositMatrixData2year);
            
            component.set('v.termDepositDataUSA',termDepositMatrixDataUSA);
            component.set('v.termDepositDataFor1MonthUSA',termDepositMatrixData1monthUSA);
            component.set('v.termDepositDataFor3MonthUSA',termDepositMatrixData3monthUSA);
            component.set('v.termDepositDataFor6MonthUSA',termDepositMatrixData6monthUSA);
            component.set('v.termDepositDataFor9MonthUSA',termDepositMatrixData9monthUSA);
            component.set('v.termDepositDataFor1YearUSA',termDepositMatrixData1yearUSA);
            component.set('v.termDepositDataFor2YearUSA',termDepositMatrixData2yearUSA);
            
            /*console.log('List Currency:'+lstCurrency);
            var uniqCurrency = [...new Set(lstCurrency)];
            console.log('Unique Currency:'+uniqCurrency);*/
            for(var i = 0; i < uniqCurrency.length; i++){
                if(uniqCurrency[i] == 'BHD'){
                    component.set('v.BHDTable',uniqCurrency[i]);
                }
                else if(uniqCurrency[i] == 'USD'){
                    component.set('v.USDTable',uniqCurrency[i]);
                }
            }
        });                                      
	},
    
})