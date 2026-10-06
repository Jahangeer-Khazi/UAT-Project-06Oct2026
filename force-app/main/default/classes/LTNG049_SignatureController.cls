public class LTNG049_SignatureController {
    @AuraEnabled
    public static String uploadSignature(String caseId, String b64SignData){
        try {
            Attachment n = new Attachment();
            //You will want to tie your attachment to some type of custom or standard object
            n.ParentId = caseId;
            n.Name = 'Signature_'+String.valueOf(Date.today()).substring(0,10);
            n.Body =  EncodingUtil.base64Decode(b64SignData); 
            system.debug('Body' + n.Body);
            //If we were saving a PDF as an attachment the ContentType would be 'pdf'
            n.contentType = 'image/jpeg';
            insert n;
            return '';
        }
        catch (Exception e)
        {
            String errorMessage = e.getMessage();
            Integer occurence;
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                occurence = errorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 34;
                errorMessage = errorMessage.mid(occurence, errorMessage.length());
                occurence = errorMessage.lastIndexOf(':');
                errorMessage = errorMessage.mid(0, occurence);
            }
            system.debug('Error: '+e);
            system.debug('Error: '+errorMessage);
            
            return errorMessage;
        }
    }
}