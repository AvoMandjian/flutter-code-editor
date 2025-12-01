import '../code/code.dart';
import 'abstract.dart';
import 'models/analysis_result.dart';
import 'models/issue.dart';
import 'rules/rule.dart';

/// An analyzer that uses a list of [Rule]s to detect issues.
///
/// It also includes issues from [Code.invalidBlocks] (mismatched folding blocks).
class LocalAnalyzer extends AbstractAnalyzer {
  final List<Rule> rules;

  const LocalAnalyzer({
    this.rules = const [],
  });

  @override
  Future<AnalysisResult> analyze(Code code) async {
    final issues = <Issue>[];

    // 1. Invalid blocks (built-in folding errors)
    for (final block in code.invalidBlocks) {
      issues.add(block.issue);
    }

    // 2. Custom rules
    for (final rule in rules) {
      issues.addAll(await rule.analyze(code));
    }

    issues.sort(issueLineComparator);

    return AnalysisResult(issues: issues);
  }
}
