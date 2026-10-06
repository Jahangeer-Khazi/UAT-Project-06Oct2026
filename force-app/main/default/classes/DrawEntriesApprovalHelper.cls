/**
 * @description       : Helper class adding Invocable properties to Batch DrawEntriesApprovalBatch
 * @author            : Jose Caballero
 * @group             : 
 * @last modified on  : 26/10/2021
 * @last modified by  : Jose Caballero
**/
public with sharing class DrawEntriesApprovalHelper {

    // Wrapper class to manage Flow Inputs
    public class FlowInputs {
        @InvocableVariable public String drawId;
    }

    /**
    * @description Invocable method that instanciates the batch and executes it, after retrieving draw id from a flow.
    * @author Jose Caballero | 26/10/2021 
    * @param request Draw id as a Flow Input Structure
    * @return List<String> Return the jobId just in case flow needs it
    **/
    @InvocableMethod(label='Update Draw Entries' description='Updates all Draw Entries of given Draw using Batch' category='Draw__c')
    public static List<String> updateDrawEntries(List<FlowInputs> request) {
        
        Id batchJobId = Database.executeBatch(new DrawEntriesApprovalBatch(request[0].drawId), 200);
        String [] jobIdListStructure = new List<String>();
        jobIdListStructure.add(batchJobId);
        return jobIdListStructure;
    }
}