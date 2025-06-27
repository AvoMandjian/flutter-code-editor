// This example expands 01.minimal.dart by using CodeField
// instead of an ordinary TextField.
// This automatically adds the gutter, code folding, and basic autocompletion.

import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/jinja.dart';

void main() {
  runApp(const CodeEditor());
}

class CodeEditor extends StatelessWidget {
  const CodeEditor({super.key});

  @override
  Widget build(BuildContext context) {
    //controller.visibleSectionNames = {'section1'};
    final controller = CodeController(
      text: '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My First HTML Page</title>
</head>
<body>
    <h1>Welcome to My Website!</h1>
    <p>This is a paragraph of text.</p>
    <a href="https://www.example.com">Visit Example.com</a>
    <ul>
        <li>Item 1</li>
        <li>Item 2</li>
    </ul>
    <img src="image.jpg" alt="An example image" width="200" height="150">
</body>
</html>
''',
      language: jinja,
      subLanguage: 'xml',
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CodeTheme(
          data: CodeThemeData(styles: monokaiSublimeTheme),
          child: SingleChildScrollView(
            child: CodeField(
              controller: controller,
              gutterStyle: const GutterStyle(
                textStyle: TextStyle(
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
