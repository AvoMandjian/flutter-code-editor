# System Patterns - Flutter Code Editor

## System Architecture

### Overall Architecture
Flutter Code Editor follows a **modular, component-based architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Code Editor                      │
├─────────────────────────────────────────────────────────────┤
│  CodeField Widget (Main UI Component)                      │
├─────────────────────────────────────────────────────────────┤
│  CodeController (State Management & Business Logic)        │
├─────────────────────────────────────────────────────────────┤
│  Feature Modules (15+ Specialized Components)              │
│  ├── Analyzer (Code Analysis)                              │
│  ├── Autocomplete (Word Suggestions)                       │
│  ├── Folding (Code Block Collapsing)                       │
│  ├── Gutter (Line Numbers, Errors, Breakpoints)           │
│  ├── Highlight (Syntax Highlighting)                       │
│  ├── Search (Find & Replace)                               │
│  ├── Named Sections (Code Section Management)              │
│  └── ... (Additional Features)                             │
└─────────────────────────────────────────────────────────────┘
```

### Core Components

#### 1. CodeController Pattern
```dart
class CodeController extends TextEditingController {
  // Extends Flutter's TextEditingController
  // Adds code-specific functionality:
  // - Language detection and syntax highlighting
  // - Code analysis with debounced analysis (500ms)
  // - Named sections for selective visibility
  // - Breakpoint management
  // - History management (undo/redo)
  // - Search functionality
}
```

#### 2. CodeField Widget Pattern
```dart
class CodeField extends StatefulWidget {
  // Main UI component extending Flutter TextField
  // Features:
  // - Gutter integration (line numbers, breakpoints, folding)
  // - Keyboard shortcuts (copy, cut, paste, search)
  // - Multi-language syntax highlighting
  // - Code folding support
  // - Read-only sections
}
```

#### 3. Gutter System Pattern
```dart
class GutterWidget extends StatelessWidget {
  // 4-column layout:
  // - Breakpoints column
  // - Line numbers column  
  // - Errors column
  // - Folding handles column
  // Features: Clickable breakpoints, error indicators, fold toggles
}
```

## Key Technical Decisions

### 1. Controller Extension Pattern
**Decision**: Extend `TextEditingController` rather than composition
**Rationale**: 
- Seamless integration with Flutter's text editing system
- Inherits all TextEditingController functionality
- Maintains compatibility with existing Flutter widgets
- Provides familiar API for Flutter developers

### 2. Modular Architecture
**Decision**: Separate feature modules in dedicated directories
**Rationale**:
- Clear separation of concerns
- Easy to maintain and extend
- Independent testing of each module
- Reduced coupling between features

### 3. Debounced Analysis
**Decision**: 500ms debounce for code analysis
**Rationale**:
- Prevents excessive API calls during typing
- Balances responsiveness with performance
- Reduces server load for remote analyzers
- Maintains smooth editing experience

### 4. Path Dependencies
**Decision**: Use local path dependencies for highlight packages
**Rationale**:
- Full control over highlight package versions
- Ability to customize and extend highlight functionality
- Avoids dependency conflicts
- Enables faster development cycles

## Design Patterns in Use

### 1. Observer Pattern
```dart
// CodeController notifies listeners of changes
class CodeController extends TextEditingController {
  void notifyListeners() {
    // Notify of text changes, language changes, etc.
  }
}
```

### 2. Strategy Pattern
```dart
// Different analyzers for different languages
abstract class AbstractAnalyzer {
  Future<AnalysisResult> analyze(String code);
}

class DartPadAnalyzer extends AbstractAnalyzer { }
class DefaultLocalAnalyzer extends AbstractAnalyzer { }
```

### 3. Builder Pattern
```dart
// SpanBuilder for syntax highlighting
class SpanBuilder {
  // Builds styled text spans for syntax highlighting
  // Handles multiple highlight sources
  // Efficient rebuilding with change detection
}
```

### 4. Factory Pattern
```dart
// Language-specific parsers and analyzers
class LanguageFactory {
  static AbstractAnalyzer createAnalyzer(String language) {
    switch (language) {
      case 'dart': return DartPadAnalyzer();
      default: return DefaultLocalAnalyzer();
    }
  }
}
```

## Component Relationships

### 1. CodeController → Feature Modules
```
CodeController
├── Analyzer (code analysis)
├── Autocomplete (word suggestions)
├── Folding (code block management)
├── Gutter (line numbers, errors)
├── Highlight (syntax highlighting)
├── Search (find & replace)
└── Named Sections (section management)
```

### 2. CodeField → Gutter Integration
```
CodeField
├── GutterWidget
│   ├── BreakpointColumn
│   ├── LineNumberColumn
│   ├── ErrorColumn
│   └── FoldingColumn
└── TextField (actual text editing)
```

### 3. Highlight System
```
Highlight System
├── Language Parser (syntax rules)
├── Theme System (color schemes)
├── Span Builder (styled text)
└── Token Processor (syntax tokens)
```

## Data Flow Patterns

### 1. Text Editing Flow
```
User Input → CodeController → Text Processing → UI Update
                ↓
         Feature Modules (Analysis, Highlighting, etc.)
```

### 2. Analysis Flow
```
Code Change → Debounce (500ms) → Analyzer → Results → UI Update
```

### 3. Highlighting Flow
```
Text Change → Language Parser → Token Generation → Span Building → UI Render
```

## Performance Patterns

### 1. Efficient Rebuilding
```dart
// Use const constructors where possible
const CodeField({Key? key, ...});

// Selective rebuilds with custom builders
AnimatedBuilder(
  animation: controller,
  builder: (context, child) => UpdatedWidget(),
)
```

### 2. Memory Management
```dart
// Dispose subscriptions
@override
void dispose() {
  _debounce?.cancel();
  _subscription?.cancel();
  super.dispose();
}
```

### 3. Lazy Initialization
```dart
// Initialize heavy objects on demand
late final Analyzer _analyzer;

// Use lazy providers in dependency injection
BlocProvider(
  create: (_) => Cubit(),
  lazy: false, // Pre-initialize for performance
)
```

## Error Handling Patterns

### 1. Graceful Degradation
```dart
try {
  final result = await analyzer.analyze(code);
  return result;
} catch (e) {
  // Fall back to local analysis or default behavior
  return DefaultAnalysisResult();
}
```

### 2. User-Friendly Error Messages
```dart
class AnalysisError {
  final String message;
  final int line;
  final int column;
  
  String get userMessage => 'Error at line $line: $message';
}
```

### 3. Error Recovery
```dart
// Continue operation even if some features fail
try {
  await performAnalysis();
} catch (e) {
  logError(e);
  // Continue with other features
}
```

## Testing Patterns

### 1. Unit Testing
```dart
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

### 2. Widget Testing
```dart
testWidgets('CodeField renders correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CodeField(
        controller: CodeController(),
      ),
    ),
  );
  expect(find.byType(CodeField), findsOneWidget);
});
```

### 3. Integration Testing
```dart
testWidgets('search functionality works', (tester) async {
  // Setup
  await tester.pumpWidget(app);
  
  // Interact
  await tester.enterText(find.byType(TextField), 'search term');
  await tester.tap(find.byIcon(Icons.search));
  
  // Verify
  expect(find.text('results'), findsWidgets);
});
```

## Extension Points

### 1. Custom Analyzers
```dart
class CustomAnalyzer extends AbstractAnalyzer {
  @override
  Future<AnalysisResult> analyze(String code) async {
    // Custom analysis logic
  }
}
```

### 2. Custom Themes
```dart
class CustomTheme {
  static const Map<String, TextStyle> styles = {
    'keyword': TextStyle(color: Colors.blue),
    'string': TextStyle(color: Colors.green),
    // ... more styles
  };
}
```

### 3. Custom Languages
```dart
// Add support for new languages through highlight package
final customLanguage = Language(
  name: 'custom',
  keywords: ['if', 'else', 'for'],
  // ... language definition
);
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
// Sandbox analysis to prevent code execution
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

## Future Architecture Considerations

### 1. Plugin System
- More extensible plugin architecture
- Third-party analyzer support
- Custom language definitions
- Theme marketplace

### 2. Performance Optimization
- Virtual scrolling for very large files
- Lazy loading of syntax highlighting
- Background analysis processing
- Memory usage optimization

### 3. Advanced Features
- Multi-cursor editing
- Advanced refactoring tools
- Real-time collaboration
- AI-powered code completion
