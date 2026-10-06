public class Scheduled_ValidInvestment {
    
    @InvocableMethod(label='get BID Valid Investments' description='The purpose of this service is to get the account balance' callout=true)
    public static List<InstrumentDetails> getInstrumentListbiddueDate() {
        List<InstrumentDetails> InsDetail = new List<InstrumentDetails>();
        String regionName = 'Bahrain';
        ApiConnection con = new ApiConnection();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request = con.createRequest('GET','/api/v1/bond/instruments/due?bidDueDate=2024-04-30',regionName);
   //     System.debug('request==>'+request.getEndpoint());
        HttpResponse response = http.send(request);
       if (response.getStatusCode() != 200 ) {
        }else {
             System.debug('response##==>'+JSON.serializePretty(response.getBody()));
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            List<Object> InstrumentList = (List<Object>)m1.get('instruments'); 
            for(Object InstDetails : InstrumentList){
                Map<String,Object> mapInstConfig = (Map<String, Object>)InstDetails;  
                InstrumentDetails InD= New InstrumentDetails();
                    InD.bs_ISIN_Type=String.valueOf(mapInstConfig.get('isInTypeCBB'));
                    InD.bs_ISIN_Code=String.valueOf(mapInstConfig.get('isInCodeCBB'));
                    InsDetail.add(InD);					
            }
        }
        
       return InsDetail;
    }
    
      public class InstrumentDetails {
        @InvocableVariable
        public String bs_ISIN_Type; 
        @InvocableVariable
        public String bs_ISIN_Code;   
        
    }
    
}