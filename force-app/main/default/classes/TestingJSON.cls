public class TestingJSON {
   public class SupplementaryCard {
        public String cardholderName;
        public String pciNumber;
        public String status;

        public SupplementaryCard(String pciNumber, String cardholderName) {
            this.pciNumber = pciNumber;
            this.cardholderName = cardholderName;
            this.status = 'Upgrade';
        }
    }
    
     public static String processCardUpgrade(Case objCase, String cardProductConfigurationIdString) {
        
         if (objCase.cc_Name_on_the_Card__c != null && objCase.cc_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01') {
            List<SupplementaryCard> upgradedSupplementaryCards = new List<SupplementaryCard>();

            // Parse the Selected_Supplementary_Cards__c field
            if (!String.isEmpty(objCase.Selected_Supplementary_Cards__c)) {
                List<String> cardDetails = objCase.Selected_Supplementary_Cards__c.split(';');
                for (String cardDetail : cardDetails) {
                    List<String> parts = cardDetail.split(' - ');
                    if (parts.size() == 2) {
                        String pciNumber = parts[0].trim();
                        String cardholderName = parts[1].trim();
                        upgradedSupplementaryCards.add(new SupplementaryCard(pciNumber, cardholderName));
                    }
                }
            }
			System.debug('Upgraded Supp Cards:'+upgradedSupplementaryCards);
            // Convert upgradedSupplementaryCards to JSON
            String upgradedSupplementaryCardsJson = JSON.serialize(upgradedSupplementaryCards);

            // Build the final JSON body
            String body = '{"cardProductConfigurationId": "' + cardProductConfigurationIdString +
                          '","crmCaseId": "' + objCase.Id +
                          '","embossName": "' + objCase.cc_Name_on_the_Card__c +
                          '", "upgradedSupplementaryCards":' + upgradedSupplementaryCardsJson +
                		  ',"targetType": "CARD_UPGRADE","status":"IN_PROGRESS"}';
                          
                

            return body; // Return the constructed JSON body
        }
        return null; // Return null if the condition is not met....
    }
}