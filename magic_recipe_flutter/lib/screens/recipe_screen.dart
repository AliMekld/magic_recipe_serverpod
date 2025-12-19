import 'package:flutter/material.dart';

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
        _resultMessage = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
        _loading=false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
