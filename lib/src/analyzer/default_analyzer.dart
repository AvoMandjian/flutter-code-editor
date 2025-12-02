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
      // Matches class/interface/enum declarations that don't end with {
      // Pattern: class name followed by content that doesn't end with {
      PatternRule(
        pattern: RegExp(r'^\s*(public|private|protected|static|final|abstract)?\s*(class|interface|enum)\s+\w+\s*[^{]\s*$'),
        message: 'Class/interface/enum declaration must end with {',
      ),
      // Detect method declarations missing opening brace
      // Matches: modifiers* returnType methodName(params) [not ending with {]
      // Handles multiple modifiers like "public static void main(...)"
      PatternRule(
        pattern: RegExp(r'^\s*((public|private|protected|static|final|abstract|synchronized|native)\s+)*\w+\s+\w+\s*\([^)]*\)\s*[^{]\s*$'),
        message: 'Method declaration must end with {',
      ),
      // Detect statements (assignments) missing semicolon
      // Only matches assignments (=), not method calls (which might be declarations)
      // Matches: anything with = followed by value that doesn't end with ;, {, or }
      PatternRule(
        pattern: RegExp(r'.*=\s*.*[^;\{\}\s]\s*$'),
        message: 'Line must end with ;',
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
