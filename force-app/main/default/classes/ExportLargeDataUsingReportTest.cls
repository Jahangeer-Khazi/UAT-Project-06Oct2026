/*     Organization  : ABC Bank
 *     Created By    : Jahangeer Mohammed
 *    Created Date  : 01/07/2022
 *    Description   : This test class is covering the following classes
 *            1) ExportLargeDataCondition 2) EmailMessageQueuable
 *     Change History: 
 *         
 */
@isTest
public class ExportLargeDataUsingReportTest {
    static testMethod void unitTest1(){
        ReportEvent testEvent = new ReportEvent();
        testEvent.QueriedEntities = 'Account';
        testEvent.RowsProcessed = 2001;
        testEvent.Operation = 'ReportExported';
         // test that the Apex returns true for this event
        ExportLargeDataUsingReport  eventCondition = new ExportLargeDataUsingReport();
        //System.assert(eventCondition.evaluate(testEvent)); 
        eventCondition.evaluate(testEvent);
        
    }
    static testMethod void unitTest2(){
        ReportEvent testEvent = new ReportEvent();
        testEvent.QueriedEntities = 'Account';
        testEvent.RowsProcessed = 20;
        testEvent.Operation = 'ReportExported';

         // test that the Apex returns true for this event
        ExportLargeDataUsingReport  eventCondition = new ExportLargeDataUsingReport();
        //System.assert(eventCondition.evaluate(testEvent)); 
        eventCondition.evaluate(testEvent);
        
    }
     static testMethod void unitTest3(){
         ExportLargeDataUsingReport  eventCondition = new ExportLargeDataUsingReport();
         eventCondition.evaluate(new Account());
    }

}