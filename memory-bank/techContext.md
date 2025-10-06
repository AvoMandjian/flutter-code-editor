# Tech Context - Flutter Code Editor

## Technologies Used

### Core Framework
- **Flutter SDK**: >=3.0.0
- **Dart SDK**: >=2.17.0
- **Platform Support**: Android, iOS, Web, Linux, Windows, macOS

### Key Dependencies

#### Core Dependencies
```yaml
dependencies:
  flutter: { sdk: flutter }
  autotrie: ^2.0.0                    # Efficient string searching
  characters: ^1.2.1                  # Unicode character handling
  charcode: ^1.3.1                    # Character code utilities
  collection: ^1.17.2                 # Collection utilities
  equatable: ^2.0.5                   # Value equality
  http: ^1.1.0                        # HTTP client for analyzers
  linked_scroll_controller: ^0.2.0    # Synchronized scrolling
  meta: ^1.9.1                        # Metadata annotations
  mocktail: ^1.0.1                    # Mocking for tests
  scrollable_positioned_list: ^0.3.5  # Efficient list scrolling
  tuple: ^2.0.1                       # Tuple data structures
  url_launcher: ^6.1.8                # URL launching
```

#### Development Dependencies
```yaml
dev_dependencies:
  fake_async: ^1.3.1                  # Async testing utilities
  flutter_test: { sdk: flutter }      # Flutter testing framework
  total_lints: ^3.1.1                 # Comprehensive linting rules
```

#### Local Dependencies
```yaml
dependencies:
  flutter_highlight:
    path: packages/highlight_with_jinja/flutter_highlight
  highlight:
    path: packages/highlight_with_jinja/highlight
```

### Highlight Package Integration
- **Custom Fork**: `highlight_with_jinja` package for enhanced functionality
- **Language Support**: 100+ programming languages
- **Theme Support**: Pre-defined and custom themes
- **Syntax Parsing**: Advanced syntax highlighting with tokenization

## Development Setup

### Prerequisites
- **Flutter SDK**: >=3.0.0
- **Dart SDK**: >=2.17.0
- **IDE**: VS Code or Android Studio with Flutter plugins
- **Platform Tools**: Platform-specific development tools

### Environment Configuration
```bash
# Flutter doctor check
flutter doctor -v

# Install dependencies
flutter pub get

# Run tests
flutter test

# Analyze code
flutter analyze
```

### Build Configuration
```yaml
# pubspec.yaml
environment:
  sdk: ">=2.17.0 <4.0.0"
  flutter: ">=3.0.0"

flutter:
  uses-material-design: true
```

## Technical Constraints

### Platform Limitations
- **Web**: Limited file system access, different scrolling behavior
- **Mobile**: Touch interaction limitations, memory constraints
- **Desktop**: Different keyboard shortcuts, window management
- **Performance**: Large file handling across all platforms

### Memory Constraints
- **Large Files**: Performance degradation with files >10k lines
- **Syntax Highlighting**: Memory usage scales with file size
- **Analysis**: Remote analysis requires network connectivity
- **Caching**: Limited caching for performance optimization

### Dependency Constraints
- **Path Dependencies**: Local highlight packages require careful versioning
- **Flutter Version**: Must maintain compatibility with Flutter SDK versions
- **Platform Support**: All features must work across supported platforms
- **Backward Compatibility**: Maintain API compatibility across versions

## Architecture Decisions

### 1. Controller Extension Pattern
```dart
class CodeController extends TextEditingController {
  // Extends Flutter's built-in TextEditingController
  // Provides seamless integration with Flutter's text editing system
  // Maintains compatibility with existing Flutter widgets
}
```

### 2. Modular Architecture
```
lib/src/
├── analyzer/          # Code analysis modules
├── autocomplete/      # Autocomplete functionality
├── code/              # Core code manipulation
├── code_field/        # Main widget and controller
├── code_modifiers/    # Code formatting logic
├── code_theme/        # Theme system
├── folding/           # Code folding
├── gutter/            # Line numbers and errors
├── hidden_ranges/     # Section visibility
├── highlight/         # Syntax highlighting
├── history/           # Undo/redo
├── line_numbers/      # Line number display
├── named_sections/    # Section management
├── search/            # Search functionality
├── service_comment_filter/  # Comment filtering
├── single_line_comments/    # Comment parsing
├── util/              # Utilities
└── wip/               # Work in progress
```

### 3. Plugin Architecture
```dart
// Extensible analyzer system
abstract class AbstractAnalyzer {
  Future<AnalysisResult> analyze(String code);
}

// Built-in analyzers
class DefaultLocalAnalyzer extends AbstractAnalyzer { }
class DartPadAnalyzer extends AbstractAnalyzer { }
```

## Performance Considerations

### 1. Efficient Rendering
```dart
// Use const constructors
const CodeField({Key? key, ...});

// Selective rebuilding
AnimatedBuilder(
  animation: controller,
  builder: (context, child) => UpdatedWidget(),
)
```

### 2. Memory Management
```dart
// Proper disposal
@override
void dispose() {
  _debounce?.cancel();
  _subscription?.cancel();
  super.dispose();
}
```

### 3. Debounced Operations
```dart
// 500ms debounce for analysis
Timer? _debounce;
void _debounceAnalysis() {
  _debounce?.cancel();
  _debounce = Timer(Duration(milliseconds: 500), () {
    _performAnalysis();
  });
}
```

## Testing Strategy

### 1. Unit Tests
```dart
// Test individual components
void main() {
  group('CodeController', () {
    test('should handle language changes', () {
      final controller = CodeController();
      controller.language = langDart;
      expect(controller.language, equals(langDart));
    });
  });
}
```

### 2. Widget Tests
```dart
// Test UI components
testWidgets('CodeField renders correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CodeField(controller: CodeController()),
    ),
  );
  expect(find.byType(CodeField), findsOneWidget);
});
```

### 3. Integration Tests
```dart
// Test complete workflows
testWidgets('search functionality works', (tester) async {
  await tester.pumpWidget(app);
  await tester.enterText(find.byType(TextField), 'search term');
  await tester.tap(find.byIcon(Icons.search));
  expect(find.text('results'), findsWidgets);
});
```

## Code Quality Standards

### 1. Static Analysis
```yaml
# analysis_options.yaml
include: package:total_lints/app.yaml

analyzer:
  errors:
    lines_longer_than_80_chars: ignore
  exclude:
    - lib/src/wip

linter:
  rules:
    prefer_if_elements_to_conditional_expressions: false
```

### 2. Linting Rules
- **Naming**: UpperCamelCase for classes, lowerCamelCase for methods
- **Imports**: Organized imports (dart, flutter, packages, local)
- **Documentation**: Comprehensive dartdoc comments
- **Testing**: High test coverage for all features

### 3. Code Organization
- **Modular Structure**: Clear separation of concerns
- **Consistent Patterns**: Uniform coding patterns across modules
- **Documentation**: Comprehensive inline documentation
- **Examples**: Working examples for all features

## Deployment and Distribution

### 1. Package Publishing
```bash
# Pre-publish checks
flutter pub publish --dry-run
flutter analyze
flutter test

# Publish to pub.dev
flutter pub publish
```

### 2. Version Management
- **Semantic Versioning**: MAJOR.MINOR.PATCH
- **Changelog**: Detailed changelog for each release
- **Migration Guides**: Guides for breaking changes
- **Backward Compatibility**: Maintain API compatibility

### 3. Documentation
- **README**: Comprehensive usage examples
- **API Docs**: Generated dartdoc documentation
- **Examples**: Working example applications
- **Migration Guides**: Breaking change documentation

## Platform-Specific Considerations

### 1. Web Platform
```dart
// Web-specific workarounds
import 'src/code_field/js_workarounds/js_workarounds.dart'
  show disableBuiltInSearchIfWeb;

// Disable built-in search on web
if (kIsWeb) {
  disableBuiltInSearchIfWeb();
}
```

### 2. Mobile Platforms
```dart
// Mobile-specific optimizations
class MobileOptimizations {
  // Touch interaction improvements
  // Memory usage optimization
  // Battery life considerations
}
```

### 3. Desktop Platforms
```dart
// Desktop-specific features
class DesktopFeatures {
  // Keyboard shortcuts
  // Multi-window support
  // File system integration
}
```

## Security Considerations

### 1. Input Validation
```dart
// Validate code input
String? validateCode(String code) {
  if (code.length > MAX_CODE_LENGTH) {
    return 'Code too long';
  }
  return null;
}
```

### 2. Safe Analysis
```dart
// Sandbox analysis
class SafeAnalyzer extends AbstractAnalyzer {
  @override
  Future<AnalysisResult> analyze(String code) async {
    // Perform analysis in safe environment
    // No code execution, only parsing
  }
}
```

### 3. Resource Limits
```dart
// Limit resource usage
class ResourceLimiter {
  static const int MAX_MEMORY_USAGE = 100 * 1024 * 1024; // 100MB
  static const int MAX_ANALYSIS_TIME = 5000; // 5 seconds
}
```

## Future Technical Considerations

### 1. Performance Optimization
- **Virtual Scrolling**: For very large files
- **Lazy Loading**: Syntax highlighting on demand
- **Background Processing**: Analysis in background threads
- **Memory Optimization**: Reduced memory footprint

### 2. Advanced Features
- **Multi-cursor Editing**: Multiple cursor support
- **Advanced Refactoring**: Code transformation tools
- **Real-time Collaboration**: Multi-user editing
- **AI Integration**: Intelligent code completion

### 3. Platform Expansion
- **Embedded Systems**: Flutter embedded support
- **WebAssembly**: Web performance improvements
- **Native Integration**: Better platform integration
- **Cross-platform Consistency**: Unified behavior across platforms
