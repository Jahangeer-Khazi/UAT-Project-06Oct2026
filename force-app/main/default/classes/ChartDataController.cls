public with sharing class ChartDataController {
    @TestVisible
    private static ApiConnection con = new ApiConnection();

    // ============ Wrapper Classes ============
    public class ChartData {
        @AuraEnabled public Decimal currentPrice;
        @AuraEnabled public Decimal change;
        @AuraEnabled public Decimal changePercent;
        public ChartData() {}
    }

    public class Summary {
        @AuraEnabled public Decimal totalPL;
        @AuraEnabled public Decimal unrealizedPL;
        @AuraEnabled public Decimal realizedPL;
        @AuraEnabled public Decimal averageCost;
        public Summary() {}
        public Summary(Decimal t, Decimal u, Decimal r, Decimal a) {
            this.totalPL      = t;
            this.unrealizedPL = u;
            this.realizedPL   = r;
            this.averageCost  = a;
        }
    }

    // ==================================================
    // API #1 — Chart / Hero data
    // ==================================================
    @AuraEnabled
    public static ChartData getChartData(
        String selectedDuration,
        String transferType,
        String metalCurrency,
        String segment,
        String customerId
    ) {
        if (String.isBlank(selectedDuration)) selectedDuration = '1m';
        if (String.isBlank(metalCurrency))    metalCurrency    = 'XAU';
        if (String.isBlank(segment))          segment          = 'Premium';

        return fetchPortfolioData(selectedDuration, metalCurrency, segment, customerId);
    }

    // ==================================================
    // API #2 — Portfolio Overview (P&L)
    // ==================================================
    @AuraEnabled
    public static Summary getPortfolioOverview(
        String customerId,
        String metalCurrency,
        String segment
    ) {
        if (String.isBlank(metalCurrency)) metalCurrency = 'XAU';
        if (String.isBlank(segment))       segment       = 'Premium';

        if (String.isBlank(customerId)) {
            System.debug(LoggingLevel.WARN, 'Portfolio overview skipped: customerId is blank');
            return new Summary(0, 0, 0, 0);
        }

        String path = '/api/v1/precious-metals/portfolio/overview'
            + '?metal='    + EncodingUtil.urlEncode(metalCurrency, 'UTF-8')
            + '&language=' + EncodingUtil.urlEncode('en',          'UTF-8')
            + '&unit='     + EncodingUtil.urlEncode('neo',         'UTF-8')
            + '&segment='  + EncodingUtil.urlEncode(segment,       'UTF-8');

        HttpRequest req = con.createRequest('GET', path, 'Bahrain');
        req.setHeader('customerId', customerId);
        req.setHeader('Accept',     'application/json');
        req.setTimeout(120000);

        try {
            HttpResponse response = new Http().send(req);

            if (response.getStatusCode() != 200 || String.isBlank(response.getBody())) {
                System.debug(LoggingLevel.ERROR,
                    'Portfolio overview API failed. Status=' + response.getStatusCode()
                    + ' Body=' + response.getBody());
                return new Summary(0, 0, 0, 0);
            }

            Map<String, Object> root =
                (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            Map<String, Object> dataObj = (Map<String, Object>) root.get('data');
            if (dataObj == null) return new Summary(0, 0, 0, 0);

            Map<String, Object> perf = (Map<String, Object>) dataObj.get('performance');
            if (perf == null) {
                System.debug(LoggingLevel.WARN, 'Portfolio overview: performance block missing');
                return new Summary(0, 0, 0, 0);
            }

            Decimal averageCost  = truncate(toDecimal(perf.get('averageCost')),        3);
            Decimal realizedPL   = truncate(toDecimal(perf.get('realizedPnLAmount')),  3);
            Decimal unrealizedPL = truncate(toDecimal(perf.get('unrealizedPnLAmount')),3);
            Decimal totalPL      = truncate(toDecimal(perf.get('totalPnLAmount')),     3);

            return new Summary(totalPL, unrealizedPL, realizedPL, averageCost);

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,
                'Portfolio overview callout exception: ' + e.getMessage());
            return new Summary(0, 0, 0, 0);
        }
    }

    private static Decimal toDecimal(Object val) {
        if (val == null) return 0;
        try {
            return Decimal.valueOf(String.valueOf(val));
        } catch (Exception e) {
            return 0;
        }
    }

    private static Decimal truncate(Decimal val, Integer places) {
        if (val == null) return Decimal.valueOf('0.' + '0'.repeat(places));
        Decimal result = val.setScale(places, RoundingMode.DOWN);
        if (result == 0) {
            return Decimal.valueOf('0.' + '0'.repeat(places));
        }
        return result;
    }

    // ============ Portfolio Data Callout (GET) ============
    private static ChartData fetchPortfolioData(
        String apiPeriod,
        String metalCurrency,
        String segment,
        String customerId
    ) {
        ChartData chartData = new ChartData();
        chartData.currentPrice  = null;
        chartData.change        = null;
        chartData.changePercent = null;

        String rangeUpper = apiPeriod != null ? apiPeriod.toUpperCase() : '1M';

        String path = '/api/v1/precious-metals/portfolio'
            + '?metal='    + EncodingUtil.urlEncode(metalCurrency, 'UTF-8')
            + '&segment='  + EncodingUtil.urlEncode(segment,       'UTF-8')
            + '&period='   + EncodingUtil.urlEncode(rangeUpper,    'UTF-8')
            + '&unit='     + EncodingUtil.urlEncode('neo',         'UTF-8')
            + '&language=' + EncodingUtil.urlEncode('en',          'UTF-8');

        HttpRequest req = con.createRequest('GET', path, 'Bahrain');
        req.setHeader('Accept', 'application/json');
        if (String.isNotBlank(customerId)) {
            req.setHeader('customerId', customerId);
        }
        req.setTimeout(120000);

        try {
            HttpResponse response = new Http().send(req);

            if (response.getStatusCode() != 200 || String.isBlank(response.getBody())) {
                System.debug(LoggingLevel.ERROR,
                    'Portfolio data API failed. Status=' + response.getStatusCode()
                    + ' Body=' + response.getBody());
                return chartData;
            }

            Map<String, Object> root =
                (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            System.debug('Response Details -->'+JSON.serialize(root));

            List<Object> dataList = (List<Object>) root.get('data');
            if (dataList == null || dataList.isEmpty()) return chartData;

            for (Object item : dataList) {
                Map<String, Object> row = (Map<String, Object>) item;
                String accountType = (String) row.get('accountType');

                if (accountType != null && accountType.equalsIgnoreCase(metalCurrency)) {
                    chartData.change        = truncate(toDecimal(row.get('fiatBalanceDelta')), 3);
                    chartData.changePercent = truncate(toDecimal(row.get('changePercent')),    3);
                    chartData.currentPrice  = truncate(toDecimal(row.get('fiatBalance')),      3);
                    break;
                }
            }
            return chartData;

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,
                'Portfolio data callout exception: ' + e.getMessage());
            return chartData;
        }
    }
}