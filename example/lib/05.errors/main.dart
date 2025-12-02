import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/java.dart';

void main() {
  runApp(const ErrorTrackingExample());
}

class ErrorTrackingExample extends StatefulWidget {
  const ErrorTrackingExample({super.key});

  @override
  State<ErrorTrackingExample> createState() => _ErrorTrackingExampleState();
}

class _ErrorTrackingExampleState extends State<ErrorTrackingExample> {
  late final CodeController controller;

  @override
  void initState() {
    super.initState();
    controller = CodeController(
      text: '''
public class Main {
  public static void main(String[] args) 
    int a = 5
    int b = 10
  }
}
''',
      language: java,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CodeTheme(
          data: CodeThemeData(styles: monokaiSublimeTheme),
          child: Center(
            child: SingleChildScrollView(
              child: CodeField(
                controller: controller,
                gutterStyle: const GutterStyle(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
