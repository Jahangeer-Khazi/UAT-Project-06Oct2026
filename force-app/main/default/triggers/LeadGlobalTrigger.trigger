trigger LeadGlobalTrigger on Lead (before insert, before Update, after update) {
    new LeadTriggerHandler().run();
}