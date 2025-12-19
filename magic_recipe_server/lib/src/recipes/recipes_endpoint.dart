import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:magic_recipe_server/src/utilities/constants.dart';
import 'package:serverpod/serverpod.dart';

class RecipesEndpoint extends Endpoint {
  Future<String> generateRecipe(Session session, String ingredients) async {
    final String geminitApiKey = session.passwords['gemini'] ?? '';
    if (geminitApiKey.isEmpty) {
      throw Exception('please provide gemini api key to use this feature');
    }
    final geniniEngine = GenerativeModel(
      model: Constants.geminiModel,
      apiKey: geminitApiKey,
  
    );
    final prompt =
        'Generate a recipe using the following ingredients: $ingredients, always put the title '
        'of the recipe in the first line, and then the instructions. The recipe should be easy '
        'to follow and include all necessary steps. Please provide a detailed recipe.';
    final response = await geniniEngine.generateContent([Content.text(prompt)]);
    final String resposeText = response.text ?? "";
    if (resposeText.isEmpty) {
      throw Exception("response is null execption !!");
    }
    return resposeText;
  }
}
