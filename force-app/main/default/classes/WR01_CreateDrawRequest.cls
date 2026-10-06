/** 
* @author Aniss Mbarki
* @date Création 14/03/2022
* @description WR01_CreateDrawRequest is a wrapper class used to generate the request body for the "Create Draw Api"
* @History : 
    #CH01 : 29/12/2022 Aniss Mbarki changes on body request of the api
*/
public  with sharing  class WR01_CreateDrawRequest {
    
    public String drawDataId {get; set;}
    public String drawDate {get; set;}
    public String crmDrawId {get; set;}

    //#CH01
    //public WR_PrizeCurrency prizeCurrency {get; set;}
    
    public List<WR_Prize> prizes {get; set;}
    public List<WR_Customer> customers {get; set;}
    
    public WR01_CreateDrawRequest(){
    }

    public class WR_PrizeCurrency{
                        
        public String code {get; set;}
        public Integer decimalPlaces {get; set;}

        public WR_PrizeCurrency(){
        }
        public WR_PrizeCurrency(String code,Integer decimalPlaces){
            this.code = code;
            this.decimalPlaces = decimalPlaces;
        }
    }

    public class WR_Prize{                
        public Integer numberOfWinners {get; set;}
        public Decimal amount {get; set;}
        
        //#CH01 : Start Add new params
        public String type {get; set;}
        public String title {get; set;}
        public WR_PrizeCurrency prizeCurrency {get; set;}
        //#CH01 : End

        public WR_Prize(){
        }
        //#CH01 : changes on the constructor fct
        public WR_Prize(Integer numberOfWinners,Decimal amount,String type , String name){
            this.numberOfWinners = numberOfWinners;
            this.amount = amount;
            this.type = type;
            this.title = name; // change reqired by BE Name -> title
        }
    }

    public class WR_Customer{                
        public String customerId {get; set;}
        public String type {get; set;}
        public WR_CustomerDetails details {get; set;}

        public WR_Customer(){
        }
        public WR_Customer(String customerId,String type,Decimal numberOfChances,Decimal balance,Decimal totalBalance){
            this.customerId = customerId;
            this.type = type;
            if(type == 'INC'){
                this.details = new WR_CustomerDetails(numberOfChances,balance,totalBalance);
            }
        }
    }

    public class WR_CustomerDetails{                
        public Decimal numberOfChances {get; set;}
        public Decimal balance {get; set;}
        public Decimal totalBalance {get; set;}

        public WR_CustomerDetails(){
        }
        public WR_CustomerDetails(Decimal numberOfChances,Decimal balance,Decimal totalBalance){
            this.numberOfChances = numberOfChances;
            this.balance = balance;
            this.totalBalance = totalBalance;
        }
    }
}