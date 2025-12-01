import 'package:highlight/highlight.dart';
import 'package:highlight/languages/java.dart';

void main() {
  // Patching Java mode
  // Current keywords is a String. We can convert it to a Map or just append if we just want 'keyword' class.
  // But user said 'String' is the TYPE. So we probably want it to be 'type' or 'built_in'.
  // Let's try to make it a Map.

  var currentKeywords = java.keywords as String;
  
  // NOTE: The 'highlight' package might be expecting a specific structure.
  // Usually it accepts Map<String, dynamic> where keys are class names.
  
  java.keywords = {
    'keyword': currentKeywords,
    'type': 'String AgentProcessor' // Adding AgentProcessor for testing too
  };

  final code = '''
    public static String agentCommunicate(String callerData, AgentProcessor receiver) {
        return receiver.process(callerData);
    }
  ''';

  final result = highlight.parse(code, language: 'java');
  
  // print the recursive structure
  printNodes(result.nodes!);
}

void printNodes(List<Node> nodes, [int indent = 0]) {
  for (var node in nodes) {
    var prefix = ' ' * indent;
    var info = '{className: ${node.className}, value: "${node.value?.replaceAll('\n', '\\n')}"}';
    print('$prefix$info');
    if (node.children != null) {
      printNodes(node.children!, indent + 2);
    }
  }
}
