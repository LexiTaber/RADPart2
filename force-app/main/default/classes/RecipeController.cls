public inherited sharing class RecipeController {
    @AuraEnabled
    public static void addIngredient (String ingredientName, Decimal measurementAmount, String measurementType, ID recipeId){
        Ingredient__c newIngredient = new Ingredient__c();
        newIngredient.Name = ingredientName;
        newIngredient.Measurement__c = measurementAmount;
        newIngredient.Measurement_Type__c = measurementType;
        newIngredient.Recipe__c = recipeId;
        insert newIngredient;
    }
    
    @AuraEnabled
    public static List <Ingredient__c> generateGroceryList (ID recipeId){
        List <Ingredient__c> groceryList = [
            SELECT Id, Name, Measurement__c, Measurement_Type__c, Notes__c
            FROM Ingredient__c
            WHERE Recipe__c = :recipeId
        ];
        return groceryList;
    }

    // scales the recipe, returns list of updated ingredient amounts based on new scale
    @AuraEnabled
    public static List <Ingredient__c> scaleRecipeForServings (ID recipeId, Decimal desiredServings) {
        // query for original servings value from recipe
        Recipe__c r = [SELECT ID, Servings__c FROM Recipe__c WHERE ID = :recipeId];
        // declare variable to hold original servings amount
        Decimal currentServings = r.Servings__c;
        // set scaling factor
        Decimal scalingFactor = desiredServings/currentServings;
        // get list of ingredients
        List <Ingredient__c> ingredients = [SELECT ID, Name, Measurement__c, Measurement_Type__c, Notes__c FROM Ingredient__c WHERE Recipe__c = :recipeId];
        // apply scaling based on new servings value
        for (Ingredient__c i : ingredients) {
            i.Measurement__c = i.Measurement__c*scalingFactor;   
        }
        return ingredients;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Recipe__c> getAllRecipes() {
        return [
            SELECT
                Id,
                Name,
                Draft__c,
                Active_Time__c,
                Active_Time_Units__c,
                Complexity__c,
                Needs_Review__c,
                Possible_Duplicate__c,
                Season__c
            FROM Recipe__c
            ORDER BY Name
            LIMIT 50
        ];
    }

    @AuraEnabled(Cacheable=true)
    public static List<Recipe__c> searchRecipes(String searchTerm) {
        List<Recipe__c> recipes = new List<Recipe__c>();

        // Return all recipes when no search term
        searchTerm = searchTerm.trim();
        if (searchTerm == '') {
            recipes = getAllRecipes();
        } else {
            // Prepare query parameters
            searchTerm = '%' + searchTerm + '%';

            // Execute search query
            recipes = [
                SELECT
                    Id,
                    Name,
                    Draft__c,
                    Active_Time__c,
                    Active_Time_Units__c,
                    Complexity__c,
                    Needs_Review__c,
                    Possible_Duplicate__c,
                    Season__c
                FROM Recipe__c
                WHERE Name LIKE :searchTerm
                ORDER BY Name
                LIMIT 50
            ];
        }

        System.debug('returning: ' + recipes);
        return recipes;
    }
}