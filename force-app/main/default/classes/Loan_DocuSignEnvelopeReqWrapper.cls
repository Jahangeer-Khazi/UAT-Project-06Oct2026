/**
 * @description       : global apex class to handle request wrapper
 * @author            : Aniss Mbarki
 * @group             : 
 * @last modified on  : 16/02/2024
 * @last modified by  : 
 * @History : 
**/
global with sharing class Loan_DocuSignEnvelopeReqWrapper {
    global String cif {get; set;}
    global String caseId {get; set;}
    global String channel {get; set;}
    global String caseModel {get; set;}
}