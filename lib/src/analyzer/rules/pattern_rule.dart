import '../../code/code.dart';
import '../models/issue.dart';
import '../models/issue_type.dart';
import 'rule.dart';

/// A rule that detects issues based on a regular expression.
class PatternRule extends Rule {
  /// The pattern to search for.
  ///
  /// If [checkByLine] is true, this pattern is applied to each line.
  /// If [checkByLine] is false, this pattern is applied to the entire text.
  final RegExp pattern;

  /// The message to display when the pattern matches.
  final String message;

  /// The severity of the issue.
  final IssueType type;

  /// Whether to check each line individually or the entire text.
  final bool checkByLine;

  const PatternRule({
    required this.pattern,
    required this.message,
    this.type = IssueType.error,
    this.checkByLine = true,
  });

  @override
  Future<List<Issue>> analyze(Code code) async {
    final issues = <Issue>[];
    print('PatternRule: Analyzing ${code.lines.lines.length} lines with pattern "${pattern.pattern}"');

    if (checkByLine) {
      for (var i = 0; i < code.lines.lines.length; i++) {
        final line = code.lines.lines[i];
        final hasMatch = pattern.hasMatch(line.text);

        if (i < 10) {
          // Log first 10 lines
          print('Line $i: "${line.text.replaceAll('\n', r'\n')}" -> Match: $hasMatch');
        }

        if (hasMatch) {
          issues.add(
            Issue(
              line: i,
              message: message,
              type: type,
            ),
          );
        }
      }
    } else {
      final matches = pattern.allMatches(code.text);
      for (final match in matches) {
        final lineIndex = code.lines.characterIndexToLineIndex(match.start);
        issues.add(
          Issue(
            line: lineIndex,
            message: message,
            type: type,
          ),
        );
      }
    }

    print('PatternRule: Found ${issues.length} issues');
    return issues;
  }
}
