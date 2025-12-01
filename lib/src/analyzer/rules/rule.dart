import '../../code/code.dart';
import '../models/issue.dart';

/// A rule to detect issues in the code.
abstract class Rule {
  const Rule();

  /// Analyzes the code and returns a list of detected issues.
  Future<List<Issue>> analyze(Code code);
}
