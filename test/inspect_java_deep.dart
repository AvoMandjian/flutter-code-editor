import 'package:highlight/highlight.dart';
import 'package:highlight/languages/java.dart';

void main() {
  print('Top level keywords: ${java.keywords.runtimeType}');

  // Find function mode
  // It usually starts with keywords like public/protected/void etc.
  final functionMode = java.contains?.firstWhere((mode) => mode?.className == 'function', orElse: Mode.new);

  if (functionMode?.className == 'function') {
    print('Found function mode.');
    print('Function mode keywords: ${functionMode?.keywords}');
  } else {
    print('Function mode not found by className="function". Searching by heuristic...');
    // Maybe className is not set but it is there.
    for (var i = 0; i < (java.contains?.length ?? 0); i++) {
      final m = java.contains![i];
      print('Mode $i: className=${m?.className}, beginKeywords=${m?.beginKeywords}');
      if (m?.keywords != null) {
        print('  keywords: ${m?.keywords}');
      }
    }
  }
}
