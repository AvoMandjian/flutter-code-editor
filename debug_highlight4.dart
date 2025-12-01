import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/java.dart';

void main() {
  // Register the Java language
  highlight.registerLanguage('java', java);
  
  // Your exact example
  final code = '''
public class Test {
    public static void agentCommunicate(String callerData, AgentProcessor receiver) {
    }
}
''';
  
  final result = highlight.parse(code, language: 'java');
  print('Java highlighting result:');
  printDetailedNodes(result.nodes!, 0);
}

void printDetailedNodes(List<Node> nodes, int depth) {
  for (final node in nodes) {
    final indent = '  ' * depth;
    final valueDisplay = (node.value != null) ? '"${node.value}"' : 'null';
    print('${indent}Node: class="${node.className}", value=${valueDisplay}');
    
    if (node.children != null && node.children!.isNotEmpty) {
      printDetailedNodes(node.children!, depth + 1);
    }
  }
}