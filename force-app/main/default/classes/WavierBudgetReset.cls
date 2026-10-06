/********************************************************************************************
* @name                 WavierBudgetReset
* @description          This class would responsible to reset the budget. this would run once a year
* @date                 28/07/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           28/07/2025     Initial Version
*********************************************************************************************
*/

global class WavierBudgetReset implements Schedulable {

    global void execute(SchedulableContext sc) {
    	List<Budget_Matrix__c> listOfBudgetMatrix = new List<Budget_Matrix__c>();
        try {
        	for(Budget_Matrix__c matrix : [SELECT Id,Utilization__c FROM Budget_Matrix__c]){
                matrix.Utilization__c = 0;
                listOfBudgetMatrix.add(matrix);
            }
            
            update listOfBudgetMatrix;    
        }
        catch(Exception ex){ 
        	
        }
        
    }
}