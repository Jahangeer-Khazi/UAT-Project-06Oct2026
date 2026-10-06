public class PersonAccountHandler {
    
    public static void deletePersonAccountAndRelated(String fName, String lName){
        
        String searchquery='FIND \'' + fName + ' AND ' + lName + '\' IN NAME FIELDS RETURNING Account(Name, FirstName, LastName)';
        List<List<SObject>>searchList = search.query(searchquery);
        
        if(!searchList.get(0).isEmpty()){
            
           	//filter only account that firstname = fName and LastName = lName
            Map<Id, Account> mAcc = new Map<Id, Account>();
            for(Account acc : (List<Account>)searchList.get(0)){
                if(acc.FirstName == fName && acc.LastName == lName){
                    mAcc.put(acc.Id, acc);
                }
            }
            
            //delete case
        	delete [select Id from Case where AccountId in :mAcc.keySet()];

            //delete Entitlement to avoid error DELETE_FAILED, Your attempt to delete Mr. Test Account(Account Name) could not be completed because it is associated with the following entitlements.
            delete [select id from Entitlement where AccountId in :mAcc.keySet()]; 
            
            //delete account
            delete mAcc.values();
        }
    }
}