@isTest
public class PAD_Test {

    @isTest static void allTest() {
        PAD.debugLogBegin('className','methodName','message');
        PAD.debugLogEnd('className','methodName','message');
        PAD.debugLogInfo('className','methodName','message');
    }

}