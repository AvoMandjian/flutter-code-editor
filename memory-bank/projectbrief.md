# Project Brief - Flutter Code Editor

## Project Overview
- **Name**: Flutter Code Editor
- **Purpose**: A customizable code field supporting syntax highlighting and code folding for Flutter applications
- **Type**: Flutter Package (Library)
- **Version**: 0.3.4
- **Repository**: https://github.com/akvelon/flutter-code-editor

## Core Requirements

### Functional Requirements
- **Syntax Highlighting**: Support for over 100 programming languages
- **Code Folding**: Collapsible code blocks for better readability
- **Autocompletion**: Word suggestions based on language keywords and existing text
- **Read-only Sections**: Ability to lock specific code sections from editing
- **Named Sections**: Tag-based code section management
- **Theme Support**: Pre-defined and custom themes for syntax highlighting
- **Code Analysis**: Pluggable analyzers for error highlighting and validation
- **Multi-platform Support**: Android, iOS, Web, Linux, Windows, macOS

### Non-functional Requirements
- **Performance**: Efficient rendering for large code files
- **Extensibility**: Plugin architecture for custom analyzers and themes
- **Maintainability**: Clean, modular architecture with comprehensive testing
- **Documentation**: Complete API documentation and usage examples
- **Compatibility**: Flutter SDK >=3.0.0, Dart SDK >=2.17.0

### Technical Constraints
- **Dependencies**: Path dependencies on local highlight packages
- **Platform Support**: All Flutter-supported platforms
- **Memory Usage**: Efficient memory management for large code files
- **Build System**: Standard Flutter package structure with example app

## Success Metrics
- **Code Quality**: 95%+ test coverage, zero critical linting issues
- **Performance**: Smooth scrolling and editing for files up to 10,000 lines
- **Adoption**: Growing pub.dev download statistics
- **Maintainability**: Clear separation of concerns, comprehensive documentation
- **Extensibility**: Easy integration of new languages and analyzers

## Target Users
- **Primary**: Flutter developers building code editing applications
- **Secondary**: Educational platforms requiring code display and editing
- **Tertiary**: Documentation tools needing syntax highlighting

## Key Features
1. **CodeController**: Extends TextEditingController with code-specific functionality
2. **CodeField**: Main widget providing code editing interface
3. **Gutter System**: Line numbers, breakpoints, errors, and folding handles
4. **Modular Architecture**: 15+ feature modules for different capabilities
5. **Example App**: Comprehensive demonstration of all features

## Project Structure
```
lib/src/
├── analyzer/          # Code analysis (DartPad, local analyzer)
├── autocomplete/      # Autocomplete functionality
├── code/              # Core code manipulation classes
├── code_field/        # Main CodeField widget & controller
├── code_modifiers/    # Code formatting & modification logic
├── code_theme/        # Syntax highlighting themes
├── folding/           # Code folding implementation
├── gutter/            # Line numbers, breakpoints, errors
├── hidden_ranges/     # Section visibility management
├── highlight/         # Syntax highlighting core
├── history/           # Undo/redo functionality
├── line_numbers/      # Line number display
├── named_sections/    # Section-based code organization
├── search/            # Search & replace functionality
├── service_comment_filter/  # Comment filtering
├── single_line_comments/    # Comment parsing
├── util/              # Shared utilities
└── wip/               # Work-in-progress features
```

## Dependencies
- **Core**: Flutter SDK, highlight package (local)
- **Utilities**: autotrie, characters, collection, equatable
- **UI**: linked_scroll_controller, scrollable_positioned_list
- **Testing**: mocktail, fake_async, total_lints
- **Development**: flutter_test, flutter_lints

## Development Goals
- Maintain high code quality and test coverage
- Provide comprehensive documentation and examples
- Support community contributions and feature requests
- Ensure backward compatibility while adding new features
- Optimize performance for large code files
