public with sharing class AWSS3Service {
    private static Http http;
    @auraEnabled
    public static  void uploadToAWSS3( String fileToUpload , String filenm , String doctype){

        fileToUpload = EncodingUtil.urlDecode(fileToUpload, 'UTF-8');
        filenm = EncodingUtil.urlEncode(filenm , 'UTF-8'); // encode the filename in case there are special characters in the name 
        String filename = 'Storage' + '/' + filenm ;
        String attachmentBody = fileToUpload;
        String formattedDateString = DateTime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');


        // s3 bucket!
        String key = '**********' ;
        String secret = '********' ;
        String bucketname = 'testbucket' ;
        String region = 's3-us-west-2' ;

        String host = region + '.' + 'amazonaws.com' ; //aws server base url


    try{
        HttpRequest req = new HttpRequest();
        http = new Http() ;
        req.setMethod('PUT');
        req.setEndpoint('https://' + bucketname + '.' + host +  '/' +  filename );
        req.setHeader('Host', bucketname + '.' + host);
        req.setHeader('Content-Encoding', 'UTF-8');
        req.setHeader('Content-Type' , doctype);
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Date', formattedDateString);
        req.setHeader('ACL', 'public-read-write');

        String stringToSign = 'PUT\n\n' +
                doctype + '\n' +
                formattedDateString + '\n' +
                '/' + bucketname +  '/' + filename;

        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));
        String signed = EncodingUtil.base64Encode(mac);
        String authHeader = 'AWS' + ' ' + key + ':' + signed;
        req.setHeader('Authorization',authHeader);
        req.setBodyAsBlob(EncodingUtil.base64Decode(fileToUpload)) ;

        HttpResponse response = http.send(req);
        System.debug('response from aws s3 is ' + response.getStatusCode() + ' and ' + response.getBody());

    }catch(Exception e){
            System.debug('error in connecting to s3 ' + e.getMessage());
            throw e ;
        }
    }
}