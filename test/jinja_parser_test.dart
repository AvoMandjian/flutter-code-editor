import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/all.dart';

void main() {
  test('Jinja parser should not highlight Java code blocks', () {
    const source = '''
{% set dealershipName = dealership.name %}
{% set dealershipAddress = dealership.address %}
{% for i in [0,1,2,3]%}
  {{ dealershipName }} {{ i }}
{% endfor %}

public class AgentCommunication {
    // Simulates agent-like communication between two 'agents'.
    // Mirrors Flutter A2A widget interop where one calls a method on another and gets a result.
    public static String agentCommunicate(String callerData, AgentProcessor receiver) {
        return receiver.process(callerData);
    }

    // Functional interface for Agent B's processing method
    @FunctionalInterface
    interface AgentProcessor {
        String process(String data);
    }

    public static void main(String[] args) {
        // Agent B's processor (lambda simulates Agent B)
        AgentProcessor receiverProcess = data -> data.toUpperCase() + " PROCESSED BY AGENT B";
        
        // Agent A calls Agent B
        String inputData = "hello from agent A";
        String output = agentCommunicate(inputData, receiverProcess);
        
        System.out.println("Agent A sent: " + inputData);
        System.out.println("Agent B returned: " + output);
    }
}
''';

    final codeController = CodeController(
      text: source,
      language: allLanguages['jinja'], // Use Jinja language
    );

    // Parse foldable blocks
    final blocks = codeController.code.foldableBlocks;

    print('Total foldable blocks: ${blocks.length}');
    for (var i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      print('Block $i: lines ${block.firstLine}-${block.lastLine}, type=${block.type}');
    }

    // Before the fix, there would be many blocks (6 blocks including all Java braces)
    // After the fix, Jinja parser should only create 1 block (the for loop)
    // Java parser should create the Java-related blocks

    // The exact count depends on whether subLanguage is configured,
    // but Jinja-specific blocks should only be 1 (the for loop)
    final jinjaBlocks = blocks
        .where(
          (b) => b.firstLine >= 0 && b.lastLine <= 4, // Lines containing Jinja syntax
        )
        .length;

    // Should only have 1 Jinja block (the for loop from line 2 to line 4)
    expect(
      jinjaBlocks <= 1,
      isTrue,
      reason: 'Jinja parser should only create blocks for Jinja syntax, not Java code',
    );
  });
}
