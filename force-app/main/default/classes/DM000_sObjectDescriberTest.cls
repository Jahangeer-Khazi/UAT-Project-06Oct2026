@isTest
public class DM000_sObjectDescriberTest {

    @isTest
    public static void getFieldsListForTest(){   
        String sObjectName = 'Case';
        Test.startTest();
            List<String> caseFields = DM000_sObjectDescriber.getFieldsListFor(sObjectName);
        Test.stopTest();
        
        System.assert(caseFields.size()>0);
    }

    @isTest
    public static void constructFieldListForQueryFromTest(){   
        String sObjectName = 'Case';
        Test.startTest();
            String caseFieldsquery = DM000_sObjectDescriber.constructFieldListForQueryFrom(sObjectName);
        Test.stopTest();
        
        System.assert(caseFieldsquery != null);
    }
}