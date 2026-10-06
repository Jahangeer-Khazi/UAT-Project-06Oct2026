/**
 *	@author: Andrey Gavrikov (westbrook)
 *	@date: 2019-03-08 12:02:31 
 *	@description:
 *	    Test methods for VisitResultController
 *	
 *	Version History :   
 *		
 */
@isTest(isParallel=true)
public class VisitResultControllerTest  {
    class MyDao extends VisitResultController {
        protected override List<String> updateRecords(final List<SObject> recs) {
            super.updateRecords(recs);
            return new List<String>();
        }
    }
    /**
     * 
     */
    @isTest
    static void test () {
        final VisitResultController con = new VisitResultController();

        PageReference page = Page.VisitResult;
        page.getParameters().put('id', 'testId');
        Test.setCurrentPage(page);
        System.assertEquals('testId', con.getCaseUuid(), 'Expected not empty Id');

        System.assertEquals(false, con.getCaseData().getHasData(), 'Expected no data because there is not such case');
        
        con.loadedCase = new Case(Account = new Account());
        System.assertNotEquals(null, con.getCaseData(), 'Expected not null data');

        //failed save
        con.onYesClick();
        System.assertEquals(false, con.isSaveComplete, 'Did not expect save to complete because case could not have been saved');
        con.onNoClick();
        System.assertEquals(false, con.isSaveComplete, 'Did not expect save to complete because case could not have been saved');

        // successful save
        VisitResultController.DAO = new MyDao();
        con.onYesClick();
        System.assertEquals(true, con.isSaveComplete, 'Expected save to complete OK');

    }
}