import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/java.dart' as java_lang;

import '../code/code.dart';
import 'abstract.dart';
import 'models/analysis_result.dart';
import 'models/issue.dart';
import 'rules/pattern_rule.dart';
import 'rules/rule.dart';

class DefaultLocalAnalyzer extends AbstractAnalyzer {
  const DefaultLocalAnalyzer();

  static final _rulesByMode = <Mode, List<Rule>>{
    java_lang.java: [
      // Detect class/interface/enum declarations missing opening brace
      PatternRule(
        pattern: RegExp(
          r'^\s*(public|private|protected|static|final|abstract)?\s*(class|interface|enum)\s+\w+.*[^{\s]$',
        ),
        message: 'Class/interface/enum declaration must end with {',
      ),

      // Detect method declarations missing opening brace
      PatternRule(
        pattern: RegExp(
          r'^\s*((public|private|protected|static|final|abstract|synchronized|native)\s+)*\w+\s+\w+\s*\([^)]*\)\s*$',
        ),
        message: 'Method declaration must end with {',
      ),

      // Detect statements missing semicolon
      PatternRule(
        pattern: RegExp(
          r'.*=\s*.+[^;\{\}\s]$',
        ),
        message: 'Line must end with ;',
      ),

      // Detect unclosed string literal
      PatternRule(
        pattern: RegExp(
          r'".*$',
        ),
        message: 'Unclosed string literal',
      ),

      // Detect import without semicolon
      PatternRule(
        pattern: RegExp(
          r'^\s*import\s+[^;]+$',
        ),
        message: 'Import statement must end with ;',
      ),

      // Detect duplicate modifiers in declarations
      PatternRule(
        pattern: RegExp(
          r'\b(public|private|protected|static|final|abstract)\b.*\b\1\b',
        ),
        message: 'Duplicate modifier in declaration',
      ),

      // Detect illegal/non-Java symbols or corrupted tokens
      PatternRule(
        pattern: RegExp(
          '[^\\w\\s\\(\\)\\{\\}\\[\\]\\.;,:<>\\+\\-\\*/="\',\\s]+',
        ),
        message: 'Invalid or non-Java tokens detected',
      ),

      // Detect malformed generics (<<<<, >, stray <, etc.)
      PatternRule(
        pattern: RegExp(
          r'<\s*([>\s]|<?\s*<|,\s*(>|<))',
        ),
        message: 'Malformed generic type',
      ),

      // Detect unmatched opening parenthesis
      PatternRule(
        pattern: RegExp(
          r'\([^)]*$',
        ),
        message: 'Unmatched opening parenthesis',
      ),

      // Detect unmatched closing parenthesis
      PatternRule(
        pattern: RegExp(
          r'^[^(\n]*\)[^)]*$',
        ),
        message: 'Unmatched closing parenthesis',
      ),

      // Detect missing return type before method name
      PatternRule(
        pattern: RegExp(
          r'^\s*(public|private|protected|static|final|abstract)\s+[A-Za-z_]\w*\s*\([^)]*\)\s*\{',
        ),
        message: 'Method is missing a return type',
      ),

      // Detect invalid catch block (missing parentheses)
      PatternRule(
        pattern: RegExp(
          r'^\s*catch\s+[A-Za-z_]\w*(\s+\w+)?\s*$',
        ),
        message: 'Invalid catch block syntax',
      ),

      // Detect broken try/catch/finally sequences
      PatternRule(
        pattern: RegExp(
          r'^\s*(finally|else)\s+(finally|else)',
        ),
        message: 'Invalid control block sequence',
      ),

      // Detect stray commas in argument list
      PatternRule(
        pattern: RegExp(
          r'\([^)]*,\s*\)',
        ),
        message: 'Malformed argument list',
      ),

      // Detect illegal keyword sequences
      PatternRule(
        pattern: RegExp(
          r'\b(for\s+return|return\s+return|break\s+continue|while\s+for)\b',
        ),
        message: 'Illegal keyword combination',
      ),

      // Detect too many closing braces
      PatternRule(
        pattern: RegExp(
          r'^\s*}+\s*}+\s*}+',
        ),
        message: 'Too many closing braces',
      ),

      // Detect malformed annotations
      PatternRule(
        pattern: RegExp(
          r'^\s*@[^A-Za-z_]',
        ),
        message: 'Malformed annotation',
      ),

      // Detect incomplete method signature
      PatternRule(
        pattern: RegExp(
          r'^\s*[A-Za-z_]\w*\s+[A-Za-z_]\w*\s*\([^)]*$',
        ),
        message: 'Incomplete method declaration',
      ),
    ],
  };

  @override
  Future<AnalysisResult> analyze(Code code) async {
    final issues = <Issue>[];
    final linesWithIssues = <int>{};

    // 1. Invalid blocks (built-in folding errors) - add first
    for (final block in code.invalidBlocks) {
      if (!linesWithIssues.contains(block.issue.line)) {
        issues.add(block.issue);
        linesWithIssues.add(block.issue.line);
      }
    }

    // 2. Language-specific rules - process in order, only keep first issue per line
    if (code.language != null) {
      final rules = _rulesByMode[code.language];
      if (rules != null) {
        for (final rule in rules) {
          final ruleIssues = await rule.analyze(code);
          for (final issue in ruleIssues) {
            if (!linesWithIssues.contains(issue.line)) {
              issues.add(issue);
              linesWithIssues.add(issue.line);
            }
          }
        }
      } else {
        print('DefaultLocalAnalyzer: No rules found for language mode: ${code.language}');
      }
    } else {
      print('DefaultLocalAnalyzer: Code has no language set');
    }

    issues.sort(issueLineComparator);

    return AnalysisResult(issues: issues);
  }
}
