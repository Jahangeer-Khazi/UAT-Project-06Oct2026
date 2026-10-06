@IsTest
private class Loan_DocuSignEnvelopeResponseWrapperTest {
    
    @IsTest
    static void testResponseWrapperProperties() {
      
        Loan_DocuSignEnvelopeResponseWrapper wrapper = new Loan_DocuSignEnvelopeResponseWrapper();
 
        wrapper.envelopeId = 'TEST-ENVELOPE-123456';
        wrapper.contactId = 'TEST-CONTACT-789012';
    
        System.assertEquals('TEST-ENVELOPE-123456', wrapper.envelopeId, 'EnvelopeId should match the set value');
        System.assertEquals('TEST-CONTACT-789012', wrapper.contactId, 'ContactId should match the set value');
    }
}