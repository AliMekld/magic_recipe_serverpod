import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:magic_recipe_server/src/generated/protocol.dart';
import 'package:magic_recipe_server/src/utilities/constants.dart';
import 'package:serverpod/serverpod.dart';
import 'package:meta/meta.dart';

@visibleForTesting
var generateContent = (String apiKey, String prompt) async =>
    (await GenerativeModel(
          model: Constants.geminiModel,
          apiKey: apiKey,
        ).generateContent(
          [Content.text(prompt)],
        ))
        .text;

class RecipesEndpoint extends Endpoint {
  Future<List<Recipe>> getAllRecipes(Session session) async {
    try {
      final recipes = await Recipe.db.find(
        session,
        where: (r) => r.deletedAt.equals(null),
        orderBy: (p) => p.date,
        orderDescending: true,
      );
      return recipes;
    } catch (e) {
      throw Exception(e);
    }
  }
    Future<List<Recipe>> getAllDeleted(Session session) async {
    try {
      final recipes = await Recipe.db.find(
        session,
        where: (r) => r.deletedAt.notEquals(null),
        orderBy: (p) => p.date,
        orderDescending: true,
      );
      return recipes;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Recipe> getById(Session session, int id) async {
    try {
      final recipe = await Recipe.db.findById(session, id);
      if (recipe == null) {
        throw Exception("this id $id not foudded");
      }
      return recipe;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Recipe> delete(Session session, int id) async {
    try {
      final recipe = await Recipe.db.findById(session, id);
      if (recipe == null) {
        throw Exception(
          "cant delete this recipe ${recipe?.id} because it not found",
        );
      }
      final deletedRecipe = await Recipe.db.updateRow(
        session,
        recipe.copyWith(deletedAt: DateTime.now()),
      );
      return deletedRecipe;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Recipe> generateRecipe(Session session, String ingredients) async {
    final String geminitApiKey = session.passwords['gemini'] ?? '';
    if (geminitApiKey.isEmpty) {
      throw Exception('please provide gemini api key to use this feature');
    }

  
    final prompt =
        'Generate a recipe using the following ingredients: $ingredients, always put the title '
        'of the recipe in the first line, and then the instructions. The recipe should be easy '
        'to follow and include all necessary steps. Please provide a detailed recipe.';
    final response = await generateContent(geminitApiKey, prompt);
    final String resposeText = response ?? "";
    if (resposeText.isEmpty) {
      throw Exception("response is null execption !!");
    }
    Recipe recipe = Recipe(
      author: Constants.geminiModel,
      text: resposeText,
      date: DateTime.now(),
      ingredients: ingredients,
    );
    final dbRecipe = await Recipe.db.insertRow(session, recipe);
    return dbRecipe;
  }
}
