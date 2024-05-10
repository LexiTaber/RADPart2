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

    

    @AuraEnabled
    public static List <Ingredient__c> scaleRecipeForServings (ID recipeId, Decimal desiredServings){
        //scale the recipe, return list of updated ingredient amounts based on new scale
        // query ingredients of the recipe
        List <Ingredient__c> oldIngredientList = [
            SELECT Id, Name, Measurement__c, Measurement_Type__c, Notes__c
            FROM Ingredient__c
            WHERE Recipe__c = :recipeId
        ];
        // create list to store ingredients from recipe
        List <Ingredient__c> newIngredientList = new List <Ingredient__c>();
        // calculate the scale amount up or down based on new servings value
            for(Ingredient__c ing :oldIngredientList){
                Decimal currentServings = ing.Recipe__r.Servings__c;
                Decimal scalingFactor = desiredServings / currentServings;
                //update the measurements based on calculated scaling factor
                ing.Measurement__c *= scalingFactor;
                // add upgraded ingredient to the list
                newIngredientList.add(ing);
            }
            return newIngredientList;
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