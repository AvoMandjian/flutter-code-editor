// This example expands 01.minimal.dart by using CodeField
// instead of an ordinary TextField.
// This automatically adds the gutter, code folding, and basic autocompletion.

import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:highlight/languages/jinja.dart';

void main() {
  runApp(const CodeEditor());
}

class CodeEditor extends StatefulWidget {
  const CodeEditor({super.key});

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  CodeController? _codeController;
  Set<int> _breakpoints = {};

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
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
      onBreakpointsChanged: (breakpoints) {
        setState(() {
          _breakpoints = breakpoints;
        });
      },
    );
  }

  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> customThemes = {
      'custom_theme': {
        'root': {
          'backgroundColor': '0xffffffff',
          'color': '0xff000000',
        },
        'comment': {
          'color': '0xff008000',
        },
        'quote': {
          'color': '0xff008000',
        },
        'variable': {
          'color': '0xff008000',
        },
        'keyword': {
          'color': '0xff0000ff',
        },
        'selector-tag': {
          'color': '0xff0000ff',
        },
        'built_in': {
          'color': '0xff0000ff',
        },
        'name': {
          'color': '0xff0000ff',
        },
        'tag': {
          'color': '0xff0000ff',
        },
        'string': {
          'color': '0xffa31515',
        },
        'title': {
          'color': '0xffa31515',
        },
        'section': {
          'color': '0xffa31515',
        },
        'attribute': {
          'color': '0xffa31515',
        },
        'literal': {
          'color': '0xffa31515',
        },
        'template-tag': {
          'color': '0xffa31515',
        },
        'template-variable': {
          'color': '0xffa31515',
        },
        'type': {
          'color': '0xffa31515',
        },
        'addition': {
          'color': '0xffa31515',
        },
        'deletion': {
          'color': '0xff2b91af',
        },
        'selector-attr': {
          'color': '0xff2b91af',
        },
        'selector-pseudo': {
          'color': '0xff2b91af',
        },
        'meta': {
          'color': '0xff2b91af',
        },
        'doctag': {
          'color': '0xff808080',
        },
        'attr': {
          'color': '0xffff0000',
        },
        'symbol': {
          'color': '0xff00b0e8',
        },
        'bullet': {
          'color': '0xff00b0e8',
        },
        'link': {
          'color': '0xff00b0e8',
        },
        'emphasis': {
          'font_style': 'italic',
        },
        'strong': {
          'font_weight': 'bold',
        },
        // Added missing keys from standard themes
        'subst': {
          'color': '0xff000000',
        },
        'selector-id': {
          'color': '0xffa31515',
        },
        'selector-class': {
          'color': '0xffa31515',
        },
        'regexp': {
          'color': '0xff2b91af',
        },
        'meta-string': {
          'color': '0xff2b91af',
        },
        'meta-keyword': {
          'color': '0xff0000ff',
          'font_weight': 'bold',
        },
        'builtin-name': {
          'color': '0xff0000ff',
        },
        'params': {
          'color': '0xffa31515',
        },
        'formula': {
          'color': '0xff808080',
        },
        'code': {
          'color': '0xff008000',
        },
        'number': {
          'color': '0xffa31515',
        },
      },
    };
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CodeTheme(
          data: CodeThemeData(styles: themeMap['custom_theme_light']),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: CodeField(
                    customThemes: customThemes,
                    controller: _codeController!,
                    gutterStyle: const GutterStyle(
                      gutterWidthMultiplier: 200,
                      showBreakpoints: true,
                    ),
                  ),
                ),
              ),
              if (_breakpoints.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade200,
                  child: Text('Breakpoints: ${_breakpoints.join(', ')}'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
