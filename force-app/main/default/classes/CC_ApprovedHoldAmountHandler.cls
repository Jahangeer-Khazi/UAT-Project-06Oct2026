public class CC_ApprovedHoldAmountHandler {
	private static final String[] units = new String[]{
        'Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven',
        'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen',
        'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
    };

    private static final String[] tens = new String[]{
        '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
    };

    public static void handlerBeforeCaseUpdate(List<Case> caseList) {
        Map<Id, Case> oldMap = (Map<Id, Case>) Trigger.oldMap;

        for (Case c : caseList) {
            Case oldCase = oldMap.get(c.Id);

            if (c.ccol_Approved_Hold_Amount__c != null &&
                (oldCase == null || c.ccol_Approved_Hold_Amount__c != oldCase.ccol_Approved_Hold_Amount__c)) {
                
                c.Approved_Hold_Amount_in_words__c = convertDecimalToBahrainWords(c.ccol_Approved_Hold_Amount__c);
            }
        }
    }

    public static String convertDecimalToBahrainWords(Decimal inputNumber) {
        if (inputNumber == null) return '';

        inputNumber = inputNumber.setScale(3); // Ensure 3 decimal places
        String[] parts = String.valueOf(inputNumber).split('\\.');

        String wholePart = parts[0];
        String decimalPart = (parts.size() > 1) ? parts[1] : '000';

        // Pad decimal part to 3 digits
        while (decimalPart.length() < 3) {
            decimalPart += '0';
        }

        String words = numberToWords(Long.valueOf(wholePart));
        return words + ' & fills ' + decimalPart + '/1000 only';
    }

    private static String numberToWords(Long num) {
        if (num == 0) return 'Zero';
        return convert(num).trim();
    }

    private static String convert(Long num) {
        if (num < 20) return units[num.intValue()];

        if (num < 100) {
            Long tenPart = Math.floor(num / 10).longValue();
            Long unitPart = num - (tenPart * 10);
            String result = tens[tenPart.intValue()];
            if (unitPart > 0) {
                result += ' ' + units[unitPart.intValue()];
            }
            return result;
        }

        if (num < 1000) {
            Long hundredPart = Math.floor(num / 100).longValue();
            Long remainder = num - (hundredPart * 100);
            String result = units[hundredPart.intValue()] + ' Hundred';
            if (remainder > 0) {
                result += ' ' + convert(remainder);
            }
            return result;
        }

        if (num < 1000000) {
            Long thousandPart = Math.floor(num / 1000).longValue();
            Long remainder = num - (thousandPart * 1000);
            String result = convert(thousandPart) + ' Thousand';
            if (remainder > 0) {
                result += ' ' + convert(remainder);
            }
            return result;
        }

        if (num < 1000000000) {
            Long millionPart = Math.floor(num / 1000000).longValue();
            Long remainder = num - (millionPart * 1000000);
            String result = convert(millionPart) + ' Million';
            if (remainder > 0) {
                result += ' ' + convert(remainder);
            }
            return result;
        }

        Long billionPart = Math.floor(num / 1000000000).longValue();
        Long remainder = num - (billionPart * 1000000000);
        String result = convert(billionPart) + ' Billion';
        if (remainder > 0) {
            result += ' ' + convert(remainder);
        }
        return result;
    }
}