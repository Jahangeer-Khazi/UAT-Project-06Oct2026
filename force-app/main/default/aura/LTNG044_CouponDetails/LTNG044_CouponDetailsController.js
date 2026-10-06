({
	 init: function(component,event,helper){
        $A.get('e.force:refreshView').fire();
        component.set('v.columns',[
            {label: 'Coupon Payment Date', fieldName:'creationDate', type:'Date',sortable:true, typeAttributes:{year:'numeric',month:'2-digit',day:'2-digit',timeZone:'UTC'}},
            {label: 'Coupon Amount', fieldName:'amount', type: 'text',sortable:true},
            {label: 'Coupon Credited To', fieldName:'CouponCreditedTo', type:'text',sortable:true},
            {label: 'Coupon Credited On', fieldName:'CouponCreditedOn', type:'text',sortable:true}]);
         component.set('v.viewCouponDetails','false');
         component.set('v.viewNoCouponDetailsMsg','false');
    }, 
    
    onLoadCouponDetails: function(component, event, helper) { 
      //component.set('v.viewCouponDetails','true');
        helper.loadCouponDetails(component,helper);
    },
    load: function(component,event,helper){
        $A.get('e.force:refreshView').fire();
        component.set('v.columns',[
            {label: 'Coupon Payment Date', fieldName:'creationDate', type:'Date',sortable:true, typeAttributes:{year:'numeric',month:'2-digit',day:'2-digit',timeZone:'UTC'}},
            {label: 'Coupon Amount', fieldName:'amount', type: 'text',sortable:true},
            {label: 'Coupon Credited To', fieldName:'CouponCreditedTo', type:'text',sortable:true},
            {label: 'Coupon Credited On', fieldName:'CouponCreditedOn', type:'text',sortable:true}]);
         component.set('v.viewCouponDetails','false');
         component.set('v.viewNoCouponDetailsMsg','false');
    }
})