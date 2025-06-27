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
{
  "name": "{{ user.name }}",
  "age": {{ user.age }},
  "is_active": {% if user.active %}true{% else %}false{% endif %},
  "roles": [
    {% for role in user.roles %}
    "{{ role }}"{% if not loop.last %},{% endif %}
    {% endfor %}
  ]
}
''',
      language: jinja,
      subLanguage: 'json',
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
