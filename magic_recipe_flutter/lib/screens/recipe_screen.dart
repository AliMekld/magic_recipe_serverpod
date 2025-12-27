import 'package:flutter/material.dart';
import 'package:magic_recipe_client/magic_recipe_client.dart';

import '../main.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({
    super.key,
  });

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  
  /// Holds the last result or null if no result exists yet.
  String? _resultMessage;

  /// Holds the last error message that we've received from the server or null
  /// if no error exists yet.
  String? _errorMessage;
  bool _loading = false;

  final _textEditingController = TextEditingController();

  /// Calls the `hello` method of the `greeting` endpoint. Will set either the
  /// `_resultMessage` or `_errorMessage` field, depending on if the call
  /// is successful.
  void _callGenerateRecipe() async {
    try {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
      final result = await client.recipes.generateRecipe(
        _textEditingController.text,
      );
      setState(() {
        _errorMessage = null;
        _loading=false;
        _resultMessage = result.text;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
        _loading=false;
      });
    }
  }
@override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final screen=MediaQuery.sizeOf(context).height;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: screen,
        child: Row(
          spacing: 16,
          children: [
            Expanded(
              child: Column(
                children: [
                  TextField(
                    controller: _textEditingController,
                    decoration: const InputDecoration(hintText: 'Enter your name'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loading?null: _callGenerateRecipe,
                    child:  Text(_loading? "Loading...": 'Send to Server'),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ResultDisplay(
                        resultMessage: _resultMessage,
                        errorMessage: _errorMessage,
                      ),
                    ),
                  ),
                    ],
              ),
            ),
                  Container(
                    color: Colors.grey[50],
                    width: 200,
                    height:screen ,
                    child: FutureBuilder<List<Recipe>>(
                      future: client.recipes.getAllRecipes(),
                      builder: (context,sh) {
                        bool isError=sh.hasError;
                        if(sh.connectionState==ConnectionState.waiting){
                          return Center(child: CircularProgressIndicator(),);
                        }
                        final recipesList=sh.data??[];
                        return isError?Text("error ${sh.error.toString()}"): ListView.separated(
                          padding: EdgeInsets.all(8),
                          separatorBuilder: (context, index) => Divider(),
                          itemCount: recipesList.length,
                          itemBuilder: (context, index) {
                          final recipe=recipesList[index];
                          return Container(
                            // height: 200,
                            width: 200,
                            padding: EdgeInsets.all(16),
                        
                            child: Wrap(
                              runSpacing: 16,
                            spacing: 16,
                            children: [
                              Text(recipe.id?.toString()??"",),
                              Text(recipe.author),
                              Text(recipe.date.toString()),
                              Text(recipe.text,maxLines: 3,),
                              IconButton(icon: Icon(Icons.delete),onPressed: ()async{
                                if(recipe.id==null)return;
                                await client.recipes.delete(recipe.id!);
                                await client.recipes.getAllRecipes();
                                setState(() {
                                  
                                });
                              
                              },)
                            ],
                          ),);
                        } );
                      }
                    ),
                  )
            
          ],
        ),
      ),
    );
  }
}

/// ResultDisplays shows the result of the call. Either the returned result
/// from the `example.greeting` endpoint method or an error message.
class ResultDisplay extends StatelessWidget {
  final String? resultMessage;
  final String? errorMessage;

  const ResultDisplay({super.key, this.resultMessage, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    String text;
    Color backgroundColor;
    if (errorMessage != null) {
      backgroundColor = Colors.red[300]!;
      text = errorMessage!;
    } else if (resultMessage != null) {
      backgroundColor = Colors.green[300]!;
      text = resultMessage!;
    } else {
      backgroundColor = Colors.grey[300]!;
      text = 'No server response yet.';
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50),
      child: Container(
        color: backgroundColor,
        child: Center(child: SelectableText(text)),
      ),
    );
  }
}
