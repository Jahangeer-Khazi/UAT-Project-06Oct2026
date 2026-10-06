/*      Organization : ABC Bank
 *      Created By   : Ranjith Raja
 *      Created Date : 23/09/2026
 *      Change History:
 *          #CH01# #Ranjith Raja# #23-09-2026# Added Test class for ChartDataController.
 */

@isTest
public class ChartDataControllerTest {

    // ============ HTTP MOCKS ============

    // Returns a valid portfolio response with both XAU and XAG rows
    private class PortfolioDataSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                '{' +
                '  "data": [' +
                '    {' +
                '      "weight": [{"weightUnit": "oz", "metalAmount": 14.39}],' +
                '      "changePercent": 11.85,' +
                '      "fiatBalanceDelta": 2682.447,' +
                '      "linkedAccountCurrency": "BHD",' +
                '      "fiatBalance": 23314.576,' +
                '      "accountType": "XAU"' +
                '    },' +
                '    {' +
                '      "changePercent": 5.25,' +
                '      "fiatBalanceDelta": 500.123,' +
                '      "fiatBalance": 5000.456,' +
                '      "accountType": "XAG"' +
                '    }' +
                '  ],' +
                '  "meta": {"message": "Portfolio data retrieved successfully.", "code": "MET-1012"}' +
                '}'
            );
            return res;
        }
    }

    // Returns an empty portfolio data list
    private class PortfolioDataEmptyMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"data": [], "meta": {"code": "MET-1012"}}');
            return res;
        }
    }

    // Valid overview response
    private class PortfolioOverviewSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                '{' +
                '  "data": {' +
                '    "performance": {' +
                '      "averageCost": 1637.419,' +
                '      "realizedPnLAmount": -9.685,' +
                '      "unrealizedPnLAmount": -214.989,' +
                '      "totalPnLAmount": -224.674' +
                '    },' +
                '    "overview": {"investedAmount": 6862.423, "equivalentAmount": 6647.434}' +
                '  },' +
                '  "meta": {"code": "MET-1048", "message": "Chart data"}' +
                '}'
            );
            return res;
        }
    }

    // Overview response missing the "performance" block
    private class PortfolioOverviewNoPerfMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"data": {"overview": {"investedAmount": 100}}, "meta": {"code": "MET-1048"}}');
            return res;
        }
    }

    // Non-200 response for error paths
    private class ErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error": "Internal Server Error"}');
            return res;
        }
    }

    // ============ CHART DATA TESTS ============

    @isTest
    static void testGetChartData_Gold_Success() {
        Test.setMock(HttpCalloutMock.class, new PortfolioDataSuccessMock());

        Test.startTest();
        ChartDataController.ChartData result = ChartDataController.getChartData(
            '1m', 'buy', 'XAU', 'Premium', '6206581'
        );
        Test.stopTest();
    }

    @isTest
    static void testGetChartData_Silver_Success() {
        Test.setMock(HttpCalloutMock.class, new PortfolioDataSuccessMock());

        Test.startTest();
        ChartDataController.ChartData result = ChartDataController.getChartData(
            '1m', 'buy', 'XAG', 'Regular', '6206581'
        );
        Test.stopTest();
    }

    @isTest
    static void testGetChartData_EmptyData() {
        Test.setMock(HttpCalloutMock.class, new PortfolioDataEmptyMock());

        Test.startTest();
        ChartDataController.ChartData result = ChartDataController.getChartData(
            '5d', 'buy', 'XAU', 'Premium', '6206581'
        );
        Test.stopTest();
    }

    @isTest
    static void testGetChartData_ApiError() {
        Test.setMock(HttpCalloutMock.class, new ErrorMock());

        Test.startTest();
        ChartDataController.ChartData result = ChartDataController.getChartData(
            '1m', 'buy', 'XAU', 'Premium', '6206581'
        );
        Test.stopTest();
    }

    @isTest
    static void testGetChartData_BlankParams() {
        Test.setMock(HttpCalloutMock.class, new PortfolioDataSuccessMock());

        Test.startTest();
        ChartDataController.ChartData result = ChartDataController.getChartData(
            null, null, null, null, null
        );
        Test.stopTest();
    }

    @isTest
    static void testGetChartData_NoMatchingAccountType() {
        Test.setMock(HttpCalloutMock.class, new PortfolioDataSuccessMock());

        Test.startTest();
        // No row will match 'XPT' (platinum) → covers the "break not taken" path
        ChartDataController.ChartData result = ChartDataController.getChartData(
            '1m', 'buy', 'XPT', 'Premium', '6206581'
        );
        Test.stopTest();
    }

    // ============ PORTFOLIO OVERVIEW TESTS ============

    @isTest
    static void testGetPortfolioOverview_Success() {
        Test.setMock(HttpCalloutMock.class, new PortfolioOverviewSuccessMock());

        Test.startTest();
        ChartDataController.Summary result = ChartDataController.getPortfolioOverview(
            '6206581', 'XAU', 'Premium'
        );
        Test.stopTest();
    }

    @isTest
    static void testGetPortfolioOverview_Silver() {
        Test.setMock(HttpCalloutMock.class, new PortfolioOverviewSuccessMock());

        Test.startTest();
        ChartDataController.Summary result = ChartDataController.getPortfolioOverview(
            '6206581', 'XAG', 'Regular'
        );
        Test.stopTest();
    }

    @isTest
    static void testGetPortfolioOverview_BlankCustomerId() {
        Test.startTest();
        ChartDataController.Summary result = ChartDataController.getPortfolioOverview(
            '', 'XAU', 'Premium'
        );
        Test.stopTest();
    }

    @isTest
    static void testGetPortfolioOverview_NoPerformanceBlock() {
        Test.setMock(HttpCalloutMock.class, new PortfolioOverviewNoPerfMock());

        Test.startTest();
        ChartDataController.Summary result = ChartDataController.getPortfolioOverview(
            '6206581', 'XAU', 'Premium'
        );
        Test.stopTest();
    }

    @isTest
    static void testGetPortfolioOverview_ApiError() {
        Test.setMock(HttpCalloutMock.class, new ErrorMock());

        Test.startTest();
        ChartDataController.Summary result = ChartDataController.getPortfolioOverview(
            '6206581', 'XAU', 'Premium'
        );
        Test.stopTest();
    }

    @isTest
    static void testGetPortfolioOverview_BlankMetalAndSegment() {
        Test.setMock(HttpCalloutMock.class, new PortfolioOverviewSuccessMock());

        Test.startTest();
        ChartDataController.Summary result = ChartDataController.getPortfolioOverview(
            '6206581', null, null
        );
        Test.stopTest();
    }
}