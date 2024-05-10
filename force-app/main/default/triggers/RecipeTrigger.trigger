trigger RecipeTrigger on Recipe__c (before insert, before update, after insert, after update) {
    RecipeTriggerHandler handler = new RecipeTriggerHandler();
    if (Trigger.isInsert){
        if (Trigger.isBefore){
            handler.handleBeforeInsert(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isAfter){
            handler.handleAfterInsert(Trigger.new);
        }

    } else if (Trigger.isUpdate){
        if(Trigger.isBefore){
            handler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isAfter){
            handler.handleAfterUpdate(Trigger.new);
        }
    }
}