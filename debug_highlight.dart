import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/java.dart';

void main() {
  // Register the Java language
  highlight.registerLanguage('java', java);

  // Example Java code containing String type
  final code = '''
public static void agentCommunicate(String callerData, AgentProcessor receiver) {
}
''';

  // Parse the code
  final result = highlight.parse(code, language: 'java');

  // Print the nodes to see what class names are being used
  print('Parsed result:');
  printNodes(result.nodes!, 0);
}

void printNodes(List<Node> nodes, int depth) {
  for (final node in nodes) {
    final indent = '  ' * depth;
    print('${indent}Node: class="${node.className}", value="${node.value}"');
    if (node.children != null && node.children!.isNotEmpty) {
      printNodes(node.children!, depth + 1);
    }
  }
}