import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/java.dart';

void main() {
  // Register the Java language
  highlight.registerLanguage('java', java);
  
  // Different example Java code to see if types get highlighted differently
  final examples = [
    'String myVar = "hello";',
    'List<String> myList = new ArrayList<>();',
    'public class MyClass { String value; }',
    'Integer.parseInt("123");',
  ];
  
  for (int i = 0; i < examples.length; i++) {
    print('\n=== Example $i: ${examples[i]} ===');
    final result = highlight.parse(examples[i], language: 'java');
    printNodes(result.nodes!, 0);
  }
}

void printNodes(List<Node> nodes, int depth) {
  for (final node in nodes) {
    final indent = '  ' * depth;
    final valueDisplay = (node.value != null && node.value!.isNotEmpty) 
        ? '"${node.value}"' 
        : (node.children != null && node.children!.isNotEmpty) 
            ? '(has children)' 
            : '""';
    print('${indent}Node: class="${node.className}", value=${valueDisplay}');
    if (node.children != null && node.children!.isNotEmpty) {
      printNodes(node.children!, depth + 1);
    }
  }
}