/**
 *  @author: Andrey Gavrikov (westbrook)
 *  @date: 2019-02-05 10:21:32 
 *  @description:
 *      Test methods for CifGenerator
 *  
 *  Version History :   
 *    
 */
@isTest(isParallel=true)
public class CifGeneratorTest  {

    private class TestDao extends CifGenerator {
        public Integer nextNum = 0;
        public List<CIF__c> queryResult = new List<CIF__c>();
        
        protected override List<Id> insertRecords(final List<SObject> recs) {
            super.insertRecords(new List<SObject>());
            return new List<Id>();
        }
        protected override List<SObject> queryRecords(final List<Id> recIds) {
            super.queryRecords(new List<Id>());
            return queryResult;
        }
        protected override String getCifNumber(final SObject rec) {
            super.getCifNumber(rec);
            nextNum++;
            return String.valueOf(nextNum);
        }
    }
    
    @isTest
    static void test () {
        final TestDao DAO = new TestDao();
        CifGenerator.DAO = DAO;
        DAO.nextNum = 9;
        DAO.queryResult = new List<CIF__c>{new CIF__c(), new CIF__c(), new CIF__c()};
        List<String> numbers = CifGenerator.createNewCifIds(new List<Account>{new Account(Region_Flag__pc='Bahrain'), new Account(Region_Flag__pc='Bahrain'), new Account(Region_Flag__pc='Bahrain')});
        System.assertEquals(3, numbers.size(), 'Expected 3 numbers returned');
        System.assertEquals('10', numbers[0]);
        System.assertEquals('12', numbers[2]);

        // coverage for cleanup code
        CifGenerator.cleanupIfRequired(String.valueOf(CifGenerator.CLEANUP_THRESHOLD * 10));
        // coverage for exception code
        CifGenerator.cleanupIfRequired('abc');// this is not a number and will cause an exception
        
        // coverage for real insert
        CifGenerator.DAO = new CifGenerator(); // reset to default DAO
        numbers = CifGenerator.createNewCifIds(new List<Account>{new Account(Region_Flag__pc='Bahrain'), new Account(Region_Flag__pc='Bahrain')});
        System.assertEquals(2, numbers.size(), 'Expected 2 numbers returned');
        
        // coverage for real insert (Jordan)
        CifGenerator.DAO = new CifGenerator(); // reset to default DAO
        numbers = CifGenerator.createNewCifIds(new List<Account>{new Account(Region_Flag__pc='Jordan')});
        System.assertEquals(1, numbers.size(), 'Expected 1 number returned');
    }
}