import 'package:magic_recipe_server/src/generated/recipes/recipe.dart';
import 'package:test/test.dart';

// Import the generated test helper file, it contains everything you need.
import 'test_tools/serverpod_test_tools.dart';

void main() {
  // This is an example test that uses the `withServerpod` test helper.
  // `withServerpod` enables you to call your endpoints directly from the test like regular functions.
  // Note that after adding or modifying an endpoint, you will need to run
  // `serverpod generate` to update the test tools code.
  // Refer to the docs for more information on how to use the test helper.
  withServerpod('Given Greeting endpoint', (sessionBuilder, endpoints) {
    test(
      'when calling `hello` with name then returned greeting includes name',
      () async {
        // Call the endpoint method by using the `endpoints` parameter and
        // pass `sessionBuilder` as a first argument. Refer to the docs on
        // how to use the `sessionBuilder` to set up different test scenarios.
        final greeting = await endpoints.greeting.hello(sessionBuilder, 'Bob');
        expect(greeting.message, 'Hello Bob');
      },
    );
  });
  withServerpod("giving recipe endpoint", (sessionBuilder, endpoints)async {
    test("when calling get recipes it must return or recipes where delated at == null", ()async{
      final session= sessionBuilder.build();
      /// delte a recipe first
   await Recipe.db.deleteWhere(session, where: (r)=>r.id.notEquals(null));
         // create a recipe
      final firstRecipe = Recipe(
          author: 'Gemini',
          text: 'Mock Recipe 1',
          date: DateTime.now(),
          ingredients: 'chicken, rice, broccoli');
       await   Recipe.db.insertRow(session, firstRecipe);
            final secondRecipe = Recipe(
          author: 'Gemini',
          text: 'Mock Recipe 2',
          date: DateTime.now(),
          ingredients: 'chicken, rice, broccoli');
       await   Recipe.db.insertRow(session, secondRecipe);
       /// get recipes again to test insert 
       final recipes=await endpoints.recipes.getAllRecipes(sessionBuilder);
       /// first case 
       expect(recipes.length, 2);
       final recipeToDelete=await Recipe.db.findFirstRow(session,where: (r) => r.text.equals("Mock Recipe 1"));
       
       await endpoints.recipes.delete(sessionBuilder, recipeToDelete!.id!);
       final recipes2=await endpoints.recipes.getAllRecipes(sessionBuilder);
       expect(recipes2.length, 1);
       expect(recipes2.first.text, 'Mock Recipe 2');


    });

  });

}
