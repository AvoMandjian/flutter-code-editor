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
      PatternRule(
        pattern: RegExp(r'[^;\{\}\s]\s*$'),
        message: 'Line must end with ;',
      ),
    ],
  };

  @override
  Future<AnalysisResult> analyze(Code code) async {
    final issues = code.invalidBlocks.map((e) => e.issue).toList();

    if (code.language != null) {
      final rules = _rulesByMode[code.language];
      if (rules != null) {
        for (final rule in rules) {
          issues.addAll(await rule.analyze(code));
        }
      }
    }

    issues.sort(issueLineComparator);

    return AnalysisResult(issues: issues);
  }
}
