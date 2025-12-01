import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_code_editor/src/code_field/span_builder.dart';
import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/java.dart';

void main() async {
  // Register the Java language
  highlight.registerLanguage('java', java);

  // Your exact example with foldable block
  const codeText = '''
public class Test {
    public static void agentCommunicate(String callerData, AgentProcessor receiver) {
        // Some implementation
    }
}
''';

  print('Parsing Java code with highlight library...');
  final result = highlight.parse(codeText, language: 'java');

  print('Creating Code object...');
  final code = Code(
    text: codeText,
    highlighted: result,
    language: java, // java mode
    namedSectionParser: const BracketsStartEndNamedSectionParser(),
  );

  print('Creating SpanBuilder with cursor position...');
  // Create a span builder with cursor on the method line
  final spanBuilder = SpanBuilder(
    code: code,
    theme: CodeThemeData(),
    rootStyle: const TextStyle(),
    cursorPosition: 50, // Position near the method
  );

  print('Building spans...');
  final textSpan = spanBuilder.build();

  print('Done. Spans created successfully.');
}
