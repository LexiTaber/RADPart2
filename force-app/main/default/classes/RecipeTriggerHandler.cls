public with sharing class RecipeTriggerHandler {
    // trigger recursion control - check for whether the trigger has already executed
    public static Boolean hasRunOnce = false;

    public void handleBeforeInsert(List<Recipe__c> newRecipes, Map<Id, Recipe__c> oldMap) {
        // recursion control, will check if hasRunOnce = true then stops, sets back to false after method is called
        if(hasRunOnce) {
            return;
        }
        hasRunOnce = true;
        checkKeyValues(newRecipes);
        getRecipeComplexity(newRecipes);
        hasRunOnce = false;
    }

    public void handleBeforeUpdate(List<Recipe__c> newRecipes, Map<Id,Recipe__c> oldMap){
        if(hasRunOnce) {
            return;
        }
        hasRunOnce = true;
        checkKeyValues(newRecipes);
        getRecipeComplexity(newRecipes);
        hasRunOnce = false;
    }
    
    public void handleAfterInsert(List<Recipe__c> newRecipes) {
        if(hasRunOnce) {
            return;
        }
        hasRunOnce = true;
        reviewUtilizedRecipes(newRecipes);
        hasRunOnce = false;
    }

    public void handleAfterUpdate(List<Recipe__c> newRecipes) {
        if(hasRunOnce) {
            return;
        }
        hasRunOnce = true;
        reviewUtilizedRecipes(newRecipes);
        hasRunOnce = false;
    }

    // method caled before recipe is inserted, checks key values and throws error if values are missing
    public void checkKeyValues(List<Recipe__c> recipes) {
        for(Recipe__c r: recipes) {
            if (String.isblank(r.Name) ||
                r.Active_Time__c == null|| //number
                String.isblank(r.Description__c) || 
                String.isblank(r.Active_Time_Units__c) ||
                r.Servings__c == null ){ //number
                //if any of these values are missing, check Draft checkbox on record
                    r.addError('Please Review Record. Name, Description, Active Time, Active Time Units, and Servings are required fields');
                }
        }
    }

    // method called before insert or update, calls out to rateRecipeComplexity method on HelperFunctions.cls
    public void getRecipeComplexity(List<Recipe__c> recipes) {
        for (Recipe__c r: recipes) {
            switch on HelperFunctions.rateRecipeComplexity(r){
            // gets numerical number rating from complexity method and assigns value to Complexity__c field.
                when 3 { r.Complexity__c = 'Difficult';
                }
                when 2 { r.Complexity__c = 'Moderate';
                }
                when 1 { r.Complexity__c = 'Simple';
                }
            }
        }
    }
        
    // method called after update, checks if recipe is not draft, has a recipe usage record (is used in cookbook)
    public void reviewUtilizedRecipes(List<Recipe__c> newRecipes) {
        // create a set to store the Ids of recipes with usage records
        Set<Id> cookbookIds = new Set<Id>();
        List<Task> tasksToInsert = new List<Task>();

        //SOQL to query usage records related to the newRecipes
        List<Recipe_Usage__c> usagerecords = [
            SELECT Id, Recipe__c, Cookbook__c, Cookbook__r.OwnerId 
            FROM Recipe_Usage__c 
            WHERE Recipe__c 
            IN :newRecipes
        ];

        //pull the Ids of recipes with usage records into the set
        for(Recipe_Usage__c usage: usageRecords){
            cookbookIds.add(usage.Cookbook__c);
        }
        //Iterate over newRecipes to check if the recipe is NOT a draft, and that they have usage record
        for (Id cookbookId : cookbookIds) {
            // Create a task for each applicable *cookbook (*edited from 'recipe')
            Task t = new Task();
            t.Subject = 'Review Recipes in Cookbook';
            t.ActivityDate = Date.today().addDays(7);
            t.OwnerId = [
                SELECT OwnerId
                FROM Cookbook__c
                WHERE Id = :cookbookId].OwnerId;
            t.WhatId = cookbookId;
            t.Status = 'Not Started';
            tasksToInsert.add(t);
        }

        // insert task
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
}