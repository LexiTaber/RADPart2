public with sharing class LeadTriggerHandler {
    // trigger Recursion Control - checks for whether the trigger has already executed
    static Boolean hasRunOnce = false;

    // method to create tasks for Lead when product interest changes
    public static void handleAfterInsert(List<Lead> newLeads) {
        // recursion control, will check if hasRunOnce = true then stops, sets back to false after method is called
        if(hasRunOnce){
            return;
        }
        hasRunOnce = true;
        handleTasks(newLeads);
        hasRunOnce = false;
    }

    public static void handleAfterUpdate(List<Lead> newLeads, Map<Id,Lead> oldLeadMap) {
        // recursion control, will check if hasRunOnce = true then stops, sets back to false after method is called
        if(hasRunOnce){
            return;
        }
        hasRunOnce = true;
        confirmProductInterestChange(newLeads, oldLeadMap);
        handleTasks(newLeads);
        hasRunOnce = false;
    }
    
    // method to check newLeads list for changes to ProductInterest__c field
    private static void confirmProductInterestChange(List<Lead> newLeads, Map<Id, Lead> oldLeadMap) {
        List<Lead> leadsWithInterestChange = new List<Lead>();
        for (Lead newLead : newLeads) {
            if (oldLeadMap != null) {
                Lead oldLead = oldLeadMap.get(newLead.Id);
                if (oldLead != null && newLead.ProductInterest__c != null &&
                    newLead.ProductInterest__c != oldLead.ProductInterest__c) {
                    leadsWithInterestChange.add(newLead);
                }
            }
        }
    }

    // method to create tasks for new Leads or Leads where ProductInterest__c field changed
    private static void handleTasks(List<Lead> newLeads){
        Id runningUserId = UserInfo.getUserId();
        List<Task> tasksToInsert = new List<Task>();
        // add task to leads
        for (Lead lead: newLeads) {
            Task newTask = new Task();
            newTask.Subject = 'New Task: Product Interest Follow Up';
            newTask.ActivityDate = Date.today().addDays(5);
            newTask.WhoId = lead.Id;
            newTask.OwnerId = lead.OwnerId;
            newTask.Status = 'Not Started';
            newTask.Description = 'Follow up with Client regarding interest in: ' + lead.ProductInterest__c;
            tasksToInsert.add(newTask);
        }
        // insert tasks
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
}