trigger LeadTrigger on Lead (after insert, after update) {
    if (trigger.isInsert) {
        if(trigger.isAfter) {
            LeadTriggerHandler.handleAfterInsert(trigger.new);
        }
    } else if (trigger.isUpdate) {
        if (trigger.isAfter) {
            LeadTriggerHandler.handleAfterUpdate(trigger.new, trigger.oldMap);
        }
    }
}