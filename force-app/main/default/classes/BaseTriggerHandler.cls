/**
 *  Copyright 2011-2014 Andrey Gavrikov.
 *  https://github.com/neowit
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *	limitations under the License.
 *
 *	@description:
 *		this is a base handler which can be used for all Trigger Handler classes
 *
 *	@example:
 *	if we want to handle BeforeInsert and AfterUpdate events on Contact then:
 *	the handler code may look like so:
 *	public without sharing class ContactHandler extends BaseTriggerHandler {
 *
 *		override public void beforeInsert () {
 *			//... your code here
 *		}
 *
 *		override public void afterUpdate () {
 *			//... your code here
 *		}
 *	}
 *
 *	Trigger code will look like so:
 *	trigger Contact on Contact (before insert, before update, before delete, 
 *									after insert, after update, after delete, after undelete) {
 *		BaseTriggerHandler.process('ContactHandler');
 *	}
 */
public abstract class BaseTriggerHandler {
	
	/**
	 * by default getName() returns Class Name, but you can override it if needed
	 */
	public virtual String getName() {
		if (null == className) {
			String strVal = String.valueOf(this);
			className = strVal.split(':')[0];
		}
		return className;
	}

	/**
	 * key may be any string, but there are some conventions which have additional meaning
	 * <Before|After>.<Insert|Update|Delete|Undelete>.<handlerName>
	 * e.g.
	 * to skip Before.Update event of ContactHandler add skip reason like so
	 * addSkipReason('Before.Update.ContactHandler', 'some reason here')
	 */
	public static void addSkipReason(final String key, final String reason) {
		skipReasonMap.put(key, reason);
	}
    
	public static void removeSkipReason(final String key) {
		skipReasonMap.remove(key);
	}
    
    /**
     * use this method inside business logic code 
     * to check skip condition at runtime in a specific method
     *
     */
	public virtual Boolean hasSkipReason(final String key) {
		final String reason = skipReasonMap.get(key);
		if (!String.isBlank(reason)) {
			System.debug('SKIP ' + key + ': ' + reason);
			return true;
		}
        final Boolean isDisabledInConfig = isDisabled(key);
		return isDisabledInConfig;
	}


	public virtual Boolean skipAllEventsForCurrentUser() {
		return isDisabled(getName());
	}
    
    public virtual Boolean isDisabled(final String name) {
		final Setting__c runTriggerConfig = Setting__c.getInstance();
        return null != runTriggerConfig && true == runTriggerConfig.Bypass_Trigger__c;
    }

	public class BlankHandler extends BaseTriggerHandler {
		public override String getName() {
			return 'BlankHandler';
		}
	}

	public virtual void beforeInsert () {
		System.debug('BaseTriggerHandler beforeInsert'); //override if necessary
	}

	public virtual void beforeUpdate () {
		System.debug('BaseTriggerHandler beforeUpdate'); //override if necessary
	}

	public virtual void beforeDelete () {
		System.debug('BaseTriggerHandler beforeDelete'); //override if necessary
	}

	public virtual void afterInsert () {
		System.debug('BaseTriggerHandler afterInsert'); //override if necessary

	}

	public virtual void afterUpdate () {
		System.debug('BaseTriggerHandler afterUpdate'); //override if necessary
	}

	public virtual void afterDelete () {
		System.debug('BaseTriggerHandler afterDelete'); //override if necessary
	}

	public virtual void afterUnDelete () {
		System.debug('BaseTriggerHandler afterUnDelete'); //override if necessary
	}

    /**
     * call this method from Trigger to initiate and process handler by name
     * taking into account handler name based "Skip Trigger" configuration (if defined)
     */
	public static BaseTriggerHandler process(final String handlerName) {
		final BaseTriggerHandler handler = getHandler(handlerName);
		if (handler.skipAllEventsForCurrentUser()) {
			return handler;
		}
        	return processInternal(handler);
    }
    
    /**
     * call this method from Trigger to initiate and process handler by name
     * ignoring handler name based "Skip Trigger" configuration (even if one is defined)
     */
	public static BaseTriggerHandler processNoGlobalSkip(final String handlerName) {
		final BaseTriggerHandler handler = getHandler(handlerName);
        return processInternal(handler);
	}
    
	private static BaseTriggerHandler processInternal(final BaseTriggerHandler handler) {
		if (Trigger.isBefore) {
			if (Trigger.isInsert && !handler.hasSkipReason('Before.Insert.' + handler.getName())) {
				handler.beforeInsert();
			} else if (Trigger.isUpdate && !handler.hasSkipReason('Before.Update.' + handler.getName())) {
				handler.beforeUpdate();
			} else if (Trigger.isDelete && !handler.hasSkipReason('Before.Delete.' + handler.getName())) {
				handler.beforeDelete();
			}
		} else {
			if (Trigger.isInsert && !handler.hasSkipReason('After.Insert.' + handler.getName())) {
				handler.afterInsert();
			} else if (Trigger.isUpdate && !handler.hasSkipReason('After.Update.' + handler.getName())) {
				handler.afterUpdate();
			} else if (Trigger.isUnDelete && !handler.hasSkipReason('After.Undelete.' + handler.getName())) {
				handler.afterUnDelete();
			} else if (Trigger.isDelete && !handler.hasSkipReason('After.Delete.' + handler.getName())) {
				handler.afterDelete();
			}
		}
		return handler;
	}

	//////////////// Utility Methods ///////////////////
	/**
	 * helper method, useful to get Ids of records involved in a list
	 */
	public static Set<Id> toIdSet(List<SObject> recs) {
		return toIdSet(recs, 'id');
	}

	/**
	 * same as toIds(recs) but we can also specify what field to use, as opposed to it just be 'id' 
	 */
	public static Set<Id> toIdSet(List<SObject> recs, final String fName) {
		final Set<Id> ids = new Set<Id>();
		for (SObject rec : recs) {
			Id idVal = (Id)rec.get(fName);
			if (null != idVal) {
				ids.add(idVal);
			}
		}
		return ids;
	}

	//////////////// Private Methods ///////////////////
	private static BaseTriggerHandler getHandler(final String handlerName) {
		//check if provided instance is assigned (useful for unit tests)
		BaseTriggerHandler h = instanceByName.get(handlerName);
		if (null == h) {
			Type t = Type.forName(handlerName);
			if (null != t) {
				h = (BaseTriggerHandler)t.newInstance();
			} else {
				System.assert(false, 'Handler class ' + handlerName + ' not found');
			}
		}
		return h;
	}

	private static Map<String, String> skipReasonMap = new Map<String, String>();

	//in unit tests it is sometimes useful to substitute handler implementation
	@TestVisible private static Map<String, BaseTriggerHandler> instanceByName = new Map<String, BaseTriggerHandler>();

	private String className = null;

	//////////////////////////// Unit Tests ////////////////////////////////////////////////

	public class UnitTestHandler extends BaseTriggerHandler {
	}

	static testMethod void testProvidedHandler () {
		BaseTriggerHandler.instanceByName.put('#TEST_HANDLER#', new BlankHandler());
		BaseTriggerHandler h = BaseTriggerHandler.getHandler('#TEST_HANDLER#');
		System.assert(h instanceof BlankHandler, 'Incorect handler returned');
		
	}

	static testMethod void testDynamicHandler () {
		BaseTriggerHandler h = BaseTriggerHandler.getHandler('BaseTriggerHandler.UnitTestHandler');
		System.assert(h instanceof BaseTriggerHandler.UnitTestHandler, 'Incorect handler returned');
		
	}

    static testMethod void testUtilityMethods () {
        BaseTriggerHandler.addSkipReason('key 1', 'reason 1');
		BaseTriggerHandler h = BaseTriggerHandler.getHandler('BaseTriggerHandler.UnitTestHandler');
        System.assertEquals(true, h.hasSkipReason('key 1'));
        BaseTriggerHandler.removeSkipReason('key 1');
        System.assertEquals(false, h.hasSkipReason('key 1'));

        final Account acc1 = new Account(Id = '001000000000001', Name = 'Acc1');
        final Account acc2 = new Account(Id = '001000000000002', Name = 'Acc2');
        final List<Account> accounts = new List<Account> {acc1, acc2};
        final Set<Id> ids = BaseTriggerHandler.toIdSet(accounts);
        System.assert(ids.contains('001000000000001'));
        System.assert(ids.contains('001000000000002'));
        System.assert(!ids.contains('001000000000003'));

    }

    /**
	 * it is impossible to generate trigger code from Apex test, thus real testing of BaseTriggerHandler.process('name') is not done 
     * this method only provides code coverage
     */
    static testMethod void testCodeCoverage () {
        //just code coverage
        BlankHandler bh = new BlankHandler();
        System.assertEquals('BlankHandler', bh.getName());
        try {
            BaseTriggerHandler.processNoGlobalSkip('BaseTriggerHandler.BlankHandler');
        } catch (Exception ignore){System.debug('The following exception has occurred: ' + ignore.getMessage());}    
        try {
            BaseTriggerHandler.process('BaseTriggerHandler.BlankHandler');
        } catch (Exception ignore){System.debug('The following exception has occurred: ' + ignore.getMessage());}    
        bh.afterDelete();
        bh.afterInsert();
        bh.afterUnDelete();
        bh.afterUpdate();
        bh.beforeDelete();
        bh.beforeInsert();
        bh.beforeUpdate();
    }

}