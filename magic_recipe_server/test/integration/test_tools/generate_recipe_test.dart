import 'package:magic_recipe_server/src/recipes/recipes_endpoint.dart';
import 'package:test/test.dart';

import 'serverpod_test_tools.dart';

void main(){
  withServerpod('test generate recipes', (sessionBuilder,endpoints){
    test('when calling generate recipe gemeni is called with some ingredients to genrate the recipe', ()async{
String capuredPrompt="";
generateContent=(_, prompt)async{
capuredPrompt=prompt;
return Future.value("mocked recipe");
};
final recipe=await endpoints.recipes.generateRecipe(sessionBuilder, 'checken,tomato');
expect(recipe.text, "mocked recipe");
expect(capuredPrompt, contains('checken,tomato'));
    });
  });
}
