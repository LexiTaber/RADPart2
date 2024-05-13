public with sharing class RecipeTestDataFactory {
    // creates and returns list of Ingredient sObject records with dummy data
    public static List <Ingredient__c> generateIngredients(Integer num) {
        List <Ingredient__c> listIngredients = new List <Ingredient__c>();
        for (Integer i = 0; i < num; i++){
            Ingredient__c newIngredient = new Ingredient__c(
                Name = 'Test Ingredient' + i,
                Measurement__c = 1,
                Measurement__Type__c = 'Whole'
                );
            listIngredients.add(newIngredient);
        }
        return testIngredients;
    }
    
    // creates, inserts, and returns Ingredient SObjects
    public static List <Ingredient__c> createIngredients(Integer num, ID recipeId) {
        List<Ingredient__c> listIngredients = new List <Ingredient__c>();
        // get recipe ID to associate ingredient with recipe and satisfy required field
        Recipe__c rec = [
            SELECT Id
            FROM Recipe__c
            WHERE Id = :recipeId];
        // for recipes with the specified Id, loop through and add a record with a unique name 
        for (Integer i = 0; i < num; i++){
            Ingredient__c newIngredient = new Ingredient__c(
                    Name = 'Test Ingredient' + i,
                    Recipe__c = recipeId,
                    Measurement__c = 1,
                    Measurement__Type__c = 'Whole'
                    );
            listIngredients.add(newIngredient);
        }
        insert listIngredients;
        return listIngredients;
    }

    // creates, inserts, and returns a list of Recipe sObject records with dummy data
    public createRecipes(){

    }
}