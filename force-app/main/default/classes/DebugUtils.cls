public without sharing class DebugUtils {
    
    public static void logSystemLimits(String context) {
        System.debug(LoggingLevel.DEBUG, '=== System Limits at ' + context + ' ===');
        System.debug(LoggingLevel.DEBUG, 'CPU Time: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
        System.debug(LoggingLevel.DEBUG, 'Heap Size: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
        System.debug(LoggingLevel.DEBUG, 'DML Statements: ' + Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements());
        System.debug(LoggingLevel.DEBUG, 'Queries: ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
        System.debug(LoggingLevel.DEBUG, 'Query Rows: ' + Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
        System.debug(LoggingLevel.DEBUG, 'Callouts: ' + Limits.getCallouts() + '/' + Limits.getLimitCallouts());
        System.debug(LoggingLevel.DEBUG, 'Future Calls: ' + Limits.getFutureCalls() + '/' + Limits.getLimitFutureCalls());
        System.debug(LoggingLevel.DEBUG, '=====================================');
    }
    
    public static void logExceptionDetails(Exception e, String context) {
        System.debug(LoggingLevel.ERROR, '=== Exception in ' + context + ' ===');
        System.debug(LoggingLevel.ERROR, 'Type: ' + e.getTypeName());
        System.debug(LoggingLevel.ERROR, 'Message: ' + e.getMessage());
        System.debug(LoggingLevel.ERROR, 'Line Number: ' + e.getLineNumber());
        System.debug(LoggingLevel.ERROR, 'Stack Trace: ' + e.getStackTraceString());
        System.debug(LoggingLevel.ERROR, 'Cause: ' + e.getCause());
        System.debug(LoggingLevel.ERROR, '===================================');
    }
}