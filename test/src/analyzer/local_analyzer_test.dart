import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/java.dart';

void main() {
  group('LocalAnalyzer', () {
    test('detects issues using PatternRule (checkByLine: true)', () async {
      final analyzer = LocalAnalyzer(
        rules: [
          PatternRule(
            pattern: RegExp(r'[^;]$'),
            checkByLine: true,
            message: 'Missing semicolon',
          ),
        ],
      );

      final code = Code(
        text: 'int a = 5\nint b = 10;',
        language: java,
      );

      final result = await analyzer.analyze(code);

      expect(result.issues.length, 1);
      expect(result.issues.first.line, 0);
      expect(result.issues.first.message, 'Missing semicolon');
    });

    test('detects issues using PatternRule (checkByLine: false)', () async {
      final analyzer = LocalAnalyzer(
        rules: [
          PatternRule(
            pattern: RegExp(r'TODO'),
            checkByLine: false,
            message: 'Found TODO',
            type: IssueType.info,
          ),
        ],
      );

      final code = Code(
        text: '// TODO: Fix this\nint a = 5;',
        language: java,
      );

      final result = await analyzer.analyze(code);

      expect(result.issues.length, 1);
      expect(result.issues.first.line, 0);
      expect(result.issues.first.message, 'Found TODO');
      expect(result.issues.first.type, IssueType.info);
    });
  });
}
