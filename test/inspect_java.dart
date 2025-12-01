import 'package:highlight/highlight.dart';
import 'package:highlight/languages/java.dart';

void main() {
 print('Java keywords: ${java.keywords}');
  print('Java contains: ${java.contains?.length}');
}
