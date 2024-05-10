@IsTest
private class RecipeHandler_Test {
    // create recipe with all key values, should not throw an error
    static void testCheckKeyValuesPositive(){
        // tests checkKeyValues - name, active time/units, description, and servings
        Recipe__c r = new Recipe__c (
            Name = 'Test Recipe',
            Active_Time_Units__c = 'Minutes',
            Active_Time__c = 30,
            Description__c = 'test recipe',
            Servings__c = 4);
        Test.startTest();
            insert r;
        Test.stopTest();

        // query for inserted Recipe
        Recipe__c testRecipe = [
            SELECT Id, Draft__c
            FROM Recipe__c
            WHERE Name = 'Test Recipe'
            LIMIT 1];
            Assert.isFalse(testRecipe.hasErrors(), 'Recipe with all required values should not throw error');
        }

    // method will check if key values and checks draft checkbox if values are missing.
    @isTest
    static void testCheckKeyValuesNegative() {
    // create recipe missing key values (name, active time/units, description, and servings) should throw an error
        Recipe__c r = new Recipe__c (
            Name = 'Test Recipe');
        // create recipe record missing key values
        Test.startTest();
        try {
            insert r;
        } catch(Exception e){
            Assert.isTrue(e.getMessage().contains('Name, Description, Active Time, Active Time Units, and Servings are required'), 'a recipe without key values should throw error: '+ e.getMessage());
        }
        Test.stopTest();
    }

    // tests getRecipeComplexity method, which gets numerical rating from HelperFunctions.cls and assigns value to Complexity__c field
    @IsTest
    static void testRecipeComplexityPositive() {
        List <Recipe__c> testRecipes = new List <Recipe__c>();
        // test getRecipeComplexity - Difficult
        Recipe__c r1 = new Recipe__c (
            Name = 'Test Recipe 1',
            Active_Time_Units__c = 'Minutes',
            Active_Time__c = 75,
            Servings__c = 6,
            Description__c = 'test');
        testRecipes.add(r1);
        // test getRecipeComplexity - Moderate
        Recipe__c r2 = new Recipe__c (
            Name = 'Test Recipe 2',
            Active_Time_Units__c = 'Minutes',
            Active_Time__c = 45,
            Servings__c = 8,
            Description__c = 'test');
        testRecipes.add(r2);
        //test getRecipeComplexity - Simple
        Recipe__c r3 = new Recipe__c (
            Name = 'Test Recipe 3',
            Active_Time_Units__c = 'Minutes',
            Active_Time__c = 30,
            Servings__c = 4,
            Description__c = 'test');
        testRecipes.add(r3);

        Test.startTest();
            insert testRecipes;
        Test.stopTest();

        // Asserting complexity for Test Recipe 1
        Recipe__c insertedRecipe1 = [SELECT Complexity__c FROM Recipe__c WHERE Name = 'Test Recipe 1' LIMIT 1];
        System.assertEquals('Difficult', insertedRecipe1.Complexity__c, 'Incorrect complexity for Test Recipe 1');

        // Asserting complexity for Test Recipe 2
        Recipe__c insertedRecipe2 = [SELECT Complexity__c FROM Recipe__c WHERE Name = 'Test Recipe 2' LIMIT 1];
        System.assertEquals('Moderate', insertedRecipe2.Complexity__c, 'Incorrect complexity for Test Recipe 2');

        // Asserting complexity for Test Recipe 3
        Recipe__c insertedRecipe3 = [SELECT Complexity__c FROM Recipe__c WHERE Name = 'Test Recipe 3' LIMIT 1];
        System.assertEquals('Simple', insertedRecipe3.Complexity__c, 'Incorrect complexity for Test Recipe 3');
    }

    //tests getRecipeComplexityRating, assigns Difficult complexity to Moderate recipe and checks for error
    @isTest
    static void testRecipeComplexityNegative(){
        Recipe__c insertedRecipe4 = new Recipe__c (
            Name = 'Test Recipe 4',
            Active_Time_Units__c = 'Minutes',
            Active_Time__c = 20,
            Servings__c = 4,
            Description__c = 'test'); 
        //Insert Recipe
        Test.startTest();
            insert insertedRecipe4;
        Test.stopTest();

        // query for inserted recipe
        Recipe__c insertedRec4 = [
            SELECT Id, Complexity__c
            FROM Recipe__c
            WHERE Name = 'Test Recipe 4'
            LIMIT 1];

        // assert that the inserted recipe is marked as difficult instead of simple
        Assert.areNotEqual('Difficult', insertedRec4.Complexity__c, 'Recipe complexity should be marked as Simple');
    }

    // tests reviewUtilizedRecipes method, which creates a review task when recipes are added to a cookbook
    @isTest
    static void testCookbookTaskPositive(){
        // create a cookbook
        Cookbook__c testbook = new Cookbook__c(Name = 'Test Cookbook');
        insert testbook;

        // create recipe record that is used in a cookbook
        Recipe__c recipe = new Recipe__c (
            Name = 'Test Recipe',
            Active_Time__c = 30,
            Active_Time_Units__c = 'Minutes',
            Description__c = 'test',
            Servings__c = 4);
        insert recipe;

        // create Recipe Usage object to link inserted Recipe and Cookbook records
        Recipe_Usage__c usage = new Recipe_Usage__c(
            Cookbook__c = testbook.Id,
            Recipe__c = recipe.Id
        );
        insert usage;

        // update recipe record to trigger review task creation
        recipe.Season__c = 'Summer';
        Test.startTest();
            update recipe;
        Test.stopTest();

        //query for the task on the cookbook record
        List<Task> tasks = [
            SELECT Id, WhatId
            FROM Task
            WHERE Subject = 'Review Recipes in Cookbook'
            LIMIT 1
        ];
        //check that a task exists on the cookbook record
        System.assertEquals(testbook.Id, tasks[0].WhatId, 'There should be a task created on the cookbook record.');
    }

    //test checks that task is not created if the recipe is missing a key field value
    @isTest
    static void testCookbookTaskNegative(){
        // create a cookbook
        Cookbook__c testbook = new Cookbook__c(Name = 'Test Cookbook');
            insert testbook;
        
            // create recipe record that is used in a cookbook
            Recipe__c recipe = new Recipe__c (
                Name = 'Test Recipe',
                Active_Time__c = 30,
                Active_Time_Units__c = 'Minutes',
                Description__c = 'test',
                Servings__c = 4);
            insert recipe;
        
            // create Recipe Usage object to link inserted Recipe and Cookbook records
            Recipe_Usage__c usage = new Recipe_Usage__c(
                Cookbook__c = testbook.Id,
                Recipe__c = recipe.Id
            );
            insert usage;
    
            // update recipe record to trigger review task creation
            recipe.Active_Time__c = null;
            Test.startTest();
                try {
                    update recipe;
                } catch (Exception e){
                    Assert.isTrue(e.getMessage().contains('Name, Description, Active Time, Active Time Units, and Servings are required'), 'a recipe without key values cannot be added to cookbook: '+ e.getMessage());
                }
            Test.stopTest();

            //query for the task on the cookbook record
            List<Task> tasks = [
                SELECT Id, WhatId
                FROM Task
                WHERE Subject = 'Review Recipes in Cookbook'
                LIMIT 1
            ];
            //check that a task exists on the cookbook record
            Assert.isTrue(tasks.size() == 0, 'Tasks cannot be created when recipe is missing a required field');
            }
        }