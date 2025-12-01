import 'package:flutter_code_editor/src/code_field/span_builder.dart';
import 'package:flutter_code_editor/src/code/code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Java built-in type detection works correctly', () {
    // Test the Java built-in type detection function
    // Create a minimal SpanBuilder instance to access the method
    final spanBuilder = _createTestSpanBuilder();

    // Test cases with Java built-in types
    expect(spanBuilder._containsJavaBuiltInTypes('(String arg)'), true);
    expect(spanBuilder._containsJavaBuiltInTypes('(int x, String y)'), true);
    expect(spanBuilder._containsJavaBuiltInTypes('(List<String> items)'), true);
    expect(spanBuilder._containsJavaBuiltInTypes('(MyCustomClass obj)'), false);
    expect(spanBuilder._containsJavaBuiltInTypes('(int x, double y)'), true);
    expect(spanBuilder._containsJavaBuiltInTypes('no types here'), false);
    expect(spanBuilder._containsJavaBuiltInTypes('String myVar;'), true);
    expect(spanBuilder._containsJavaBuiltInTypes('public void method(String param)'), true);
  });
}

// Helper method to create a SpanBuilder instance for testing
SpanBuilder _createTestSpanBuilder() {
  // Create a minimal Code object
  final code = Code(
    text: '',
    highlighted: null,
    language: null,
  );

  return SpanBuilder(
    code: code,
    theme: null,
  );
}