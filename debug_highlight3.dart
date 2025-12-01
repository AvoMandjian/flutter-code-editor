import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/java.dart';

void main() {
  // Register the Java language
  highlight.registerLanguage('java', java);
  
  // More comprehensive test to see all type-like constructs
  final examples = [
    'String s;',  // Simple declaration
    'int x;',     // Primitive type
    'Integer i;', // Wrapper type
    'List<Integer> l;',  // Generic type
    'Map<String, Integer> m;',  // Multi-parameter generic
    'public String getValue() { return "test"; }', // Method with return type
    'private String field;',  // Field declaration
  ];
  
  for (int i = 0; i < examples.length; i++) {
    print('\n=== Example $i: ${examples[i]} ===');
    final result = highlight.parse(examples[i], language: 'java');
    printDetailedNodes(result.nodes!, 0);
  }
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