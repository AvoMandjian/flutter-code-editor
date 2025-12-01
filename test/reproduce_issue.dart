import 'package:flutter_code_editor/src/highlight/node.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/java.dart';

void main() {
  test('Reproduce highlighting issue', () {
    const code = '''
public static String
  agentCommunicate(String callerData, AgentProcessor receiver) {
          return receiver.process(callerData);
      }
''';

    highlight.registerLanguage('java', java);
    final result = highlight.parse(code, language: 'java');

    // This will print the nodes. We expect 'String' to be a 'type' node.
    // In the failing case, it will likely not be recognized correctly.
    print(result.nodes?.map((n) => n.toStringRecursive()).join('\n'));
  });
}
