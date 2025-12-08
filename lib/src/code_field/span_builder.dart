import 'package:flutter/material.dart';
import 'package:highlight/highlight_core.dart';

import '../analyzer/models/issue.dart';
import '../code/code.dart';
import '../code/text_style.dart';
import '../code_theme/code_theme_data.dart';
import '../folding/foldable_block.dart';
import '../highlight/node.dart';
import '../highlight/node_classes.dart';

/// Background color for highlighting block boundary tags (start and end tags of foldable blocks).
/// Uses a darker blue with good contrast for both light and dark themes.
@visibleForTesting
const blockBoundaryBackgroundColor = Color(0x0ffaafab);

class SpanBuilder {
  final Code code;
  final CodeThemeData? theme;
  final TextStyle? rootStyle;
  final int? cursorPosition;
  final List<Issue> issues;

  var _visibleLineIndex = 0;
  late final Set<FoldableBlock> _blocksContainingCursor;

  SpanBuilder({
    required this.code,
    required this.theme,
    this.rootStyle,
    this.cursorPosition,
    required this.issues,
  }) {
    _blocksContainingCursor = _computeBlocksContainingCursor();
  }

  /// Finds all blocks that contain the cursor position.
  Set<FoldableBlock> _computeBlocksContainingCursor() {
    if (cursorPosition == null || cursorPosition! < 0) {
      return {};
    }

    // Handle empty code
    if (code.text.isEmpty || code.lines.lines.isEmpty) {
      return {};
    }

    // Convert visible cursor position to full text position
    final fullCursorPosition = code.hiddenRanges.recoverPosition(
      cursorPosition!,
      placeHiddenRanges: TextAffinity.downstream,
    );

    // Validate the recovered position is within bounds
    if (fullCursorPosition < 0 || fullCursorPosition > code.text.length) {
      return {};
    }

    // Convert character position to line index
    int cursorLine;
    try {
      cursorLine = code.lines.characterIndexToLineIndex(fullCursorPosition);
      // Ensure the line index is valid
      if (cursorLine < 0 || cursorLine >= code.lines.lines.length) {
        return {};
      }
    } catch (e) {
      // If conversion fails, return empty set (no highlighting)
      return {};
    }

    // Find all blocks that contain this line
    final containingBlocks = <FoldableBlock>{};
    for (final block in code.foldableBlocks) {
      if (block.firstLine <= cursorLine && cursorLine <= block.lastLine) {
        containingBlocks.add(block);
      }
    }

    if (containingBlocks.isEmpty) {
      return {};
    }

    return {
      containingBlocks.reduce(
        (a, b) => a.lineCount < b.lineCount ? a : b,
      ),
    };
  }

  /// Gets the set of first lines of blocks containing the cursor.
  Set<int> _getBlockFirstLines() {
    return _blocksContainingCursor.map((block) => block.firstLine).toSet();
  }

  /// Gets the set of last lines of blocks containing the cursor.
  Set<int> _getBlockLastLines() {
    return _blocksContainingCursor.map((block) => block.lastLine).toSet();
  }

  TextSpan build() {
    _visibleLineIndex = 0;
    return TextSpan(
      style: rootStyle,
      children: _buildList(
        nodes: code.visibleHighlighted?.nodes ?? [],
        theme: theme,
        ancestorStyle: rootStyle,
      ),
    );
  }

  List<TextSpan>? _buildList({
    required List<Node>? nodes,
    required CodeThemeData? theme,
    TextStyle? ancestorStyle,
  }) {
    if (nodes == null) {
      return null;
    }

    return nodes
        .map(
          (node) => _buildNode(
            node: node,
            theme: theme,
            ancestorStyle: ancestorStyle,
          ),
        )
        .toList(growable: false);
  }

  TextSpan _buildNode({
    required Node node,
    required CodeThemeData? theme,
    TextStyle? ancestorStyle,
  }) {
    final style = theme?.styles[node.className] ?? ancestorStyle;

    // Get the current full line index before updating
    final fullLineBeforeUpdate = code.hiddenLineRanges.recoverLineIndex(_visibleLineIndex);

    if (_blocksContainingCursor.isEmpty) {
      _updateLineIndex(node);
      final paleStyle = _paleIfRequired(style);
      return TextSpan(
        text: node.value,
        children: _buildList(
          nodes: node.children,
          theme: theme,
          ancestorStyle: paleStyle,
        ),
        style: paleStyle,
      );
    }

    final shouldHighlight = _shouldHighlightNode(
      node: node,
      fullLineBeforeUpdate: fullLineBeforeUpdate,
    );

    if (shouldHighlight) {
      // Optional: You can uncomment the following for debugging highlighting behavior
      // final String actualValue = node.value ?? (node.children?.map((e) => e.value ?? '').join() ?? '');
      // final valueLog = actualValue.isEmpty ? 'null (container)' : '"${actualValue.replaceAll('\n', r'\n')}"';
      // print('Highlighting node: class="${node.className}", value=$valueLog at line $fullLineBeforeUpdate');
    }

    _updateLineIndex(node);

    // Apply background color to relevant nodes on boundary lines
    var processedStyle = _applyBlockBoundaryHighlight(
      _paleIfRequired(style),
      shouldHighlight,
    );

    // Apply error underline if the line has an issue
    processedStyle = _applyErrorHighlight(
      processedStyle,
      fullLineBeforeUpdate,
    );

    return TextSpan(
      text: node.value,
      children: _buildList(
        nodes: node.children,
        theme: theme,
        ancestorStyle: style,
      ),
      style: processedStyle,
    );
  }

  TextStyle? _applyErrorHighlight(TextStyle? style, int lineIndex) {
    if (issues.any((issue) => issue.line == lineIndex)) {
      return style?.copyWith(
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.wavy,
            decorationColor: Colors.red,
          ) ??
          const TextStyle(
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.wavy,
            decorationColor: Colors.red,
          );
    }
    return style;
  }

  /// Checks if the given text contains built-in type names for the current language
  bool _containsLanguageBuiltInTypes(String text) {
    // Get the current language from the highlighted result
    final currentLanguage = code.highlighted?.language ?? code.visibleHighlighted?.language;

    // Define built-in types for different languages
    final builtInTypes = _getBuiltInTypes(currentLanguage);
    if (builtInTypes.isEmpty) {
      return false;
    }

    // Use word-based matching to avoid false positives (e.g. "int" in "print").
    // Tokenize by word characters and check membership in a lowercased set.
    final lowerCasedTypes = builtInTypes.map((type) => type.trim().toLowerCase()).where((type) => type.isNotEmpty).toSet();

    final wordRegExp = RegExp(r'\w+');
    for (final match in wordRegExp.allMatches(text)) {
      final token = match.group(0)?.toLowerCase();
      if (token != null && lowerCasedTypes.contains(token)) {
        return true;
      }
    }

    return false;
  }

  bool _shouldHighlightNode({
    required Node node,
    required int fullLineBeforeUpdate,
  }) {
    final blockFirstLines = _getBlockFirstLines();
    final blockLastLines = _getBlockLastLines();
    final isOnFirstLine = blockFirstLines.contains(fullLineBeforeUpdate);
    final isOnLastLine = blockLastLines.contains(fullLineBeforeUpdate);

    // Check if this should be highlighted:
    // 1. Jinja template-tag nodes on boundary lines
    // 2. Keywords on first lines of blocks (for subLanguage like Java)
    // 3. Opening braces { on first lines of blocks
    // 4. Closing braces } on last lines of blocks
    final className = node.className;
    final isTemplateTag = className == NodeClasses.templateTag;
    final isKeyword = className == NodeClasses.keyword;
    final isTitle = className == NodeClasses.title;
    final isType = className == NodeClasses.type;
    final isParams = className == NodeClasses.params;
    final isMeta = className == NodeClasses.meta;
    final nodeValue = (node.value ?? '').trim();
    final hasOpenBrace = nodeValue.contains('{');
    final hasCloseBrace = nodeValue.contains('}');

    var shouldHighlight = (isTemplateTag && (isOnFirstLine || isOnLastLine)) ||
        (isKeyword && isOnFirstLine) ||
        (isTitle && isOnFirstLine) ||
        (isType && isOnFirstLine) ||
        (isParams && isOnFirstLine) ||
        (isMeta && isOnFirstLine) ||
        (hasOpenBrace && isOnFirstLine) ||
        (_containsLanguageBuiltInTypes(nodeValue) && isOnFirstLine) ||
        (nodeValue.isEmpty && isOnFirstLine && !isTemplateTag) ||
        (hasCloseBrace && isOnLastLine);

    // Special handling for Java built-in types within parameter lists on foldable block boundaries
    // Some highlighting libraries don't assign 'type' class to built-in types like String, Integer
    // We only apply this enhancement when there are foldable blocks to highlight boundaries
    if (code.foldableBlocks.isNotEmpty && !shouldHighlight && isOnFirstLine && isParams) {
      shouldHighlight = true;
    }

    return shouldHighlight;
  }

  /// Applies background color highlighting if this is a template-tag on a block boundary.
  TextStyle? _applyBlockBoundaryHighlight(TextStyle? style, bool shouldHighlight) {
    if (!shouldHighlight) {
      return style;
    }

    return style?.copyWith(
          backgroundColor: blockBoundaryBackgroundColor,
        ) ??
        const TextStyle(
          backgroundColor: blockBoundaryBackgroundColor,
        );
  }

  void _updateLineIndex(Node node) {
    _visibleLineIndex += node.getValueNewlineCount();

    if (_visibleLineIndex >= code.lines.length) {
      _visibleLineIndex = code.lines.length - 1;
    }
  }

  TextStyle? _paleIfRequired(TextStyle? style) {
    if (code.visibleSectionNames.isNotEmpty) {
      return style;
    }

    final fullLineIndex = code.hiddenLineRanges.recoverLineIndex(_visibleLineIndex);
    if (code.lines[fullLineIndex].isReadOnly) {
      return style?.paled();
    }
    return style;
  }
}

const _javaTypes = {
  'string',
  'int',
  'double',
  'float',
  'long',
  'short',
  'byte',
  'boolean',
  'char',
  'Integer',
  'Double',
  'Float',
  'Long',
  'Short',
  'Byte',
  'Boolean',
  'Character',
  'Void',
  'Object',
  'Class',
  'Enum',
  'Annotation',
  'List',
  'ArrayList',
  'LinkedList',
  'Map',
  'HashMap',
  'LinkedHashMap',
  'TreeMap',
  'Set',
  'HashSet',
  'TreeSet',
  'LinkedHashSet',
  'Collection',
  'Iterable',
  'Iterator',
  'Comparator',
  'Comparable',
};

const _jsTypes = {
  'string',
  'number',
  'boolean',
  'undefined',
  'null',
  'object',
  'array',
  'function',
  'symbol',
  'bigint',
  'String',
  'Number',
  'Boolean',
  'Object',
  'Array',
  'Function',
  'Symbol',
  'BigInt',
  'Date',
  'RegExp',
  'Error',
  'Map',
  'Set',
  'WeakMap',
  'WeakSet',
  'Promise',
  'Generator',
  'AsyncFunction',
};

const _tsTypes = {
  ..._jsTypes,
  'void',
  'any',
  'unknown',
  'never',
};

const _dartTypes = {
  'string',
  'int',
  'double',
  'bool',
  'dynamic',
  'void',
  'null',
  'Object',
  'List',
  'Map',
  'Set',
  'Iterable',
  'String',
  'Int',
  'Double',
  'Bool',
  'Null',
};

const _csharpTypes = {
  'string',
  'int',
  'double',
  'float',
  'long',
  'short',
  'byte',
  'bool',
  'char',
  'decimal',
  'sbyte',
  'uint',
  'ulong',
  'ushort',
  'String',
  'Int32',
  'Double',
  'Single',
  'Int64',
  'Int16',
  'Byte',
  'Boolean',
  'Char',
  'Decimal',
  'SByte',
  'UInt32',
  'UInt64',
  'UInt16',
  'Object',
  'Void',
  'Nullable',
  'DateTime',
  'List',
  'Dictionary',
  'IEnumerable',
  'IList',
};

const _cppTypes = {
  'int',
  'double',
  'float',
  'long',
  'short',
  'byte',
  'bool',
  'char',
  'wchar_t',
  'char16_t',
  'char32_t',
  'void',
  'auto',
  'unsigned',
  'signed',
  'const',
  'volatile',
  'string',
  'String',
  'vector',
  'array',
  'map',
  'set',
  'list',
  'queue',
  'stack',
  'pair',
  'tuple',
};

const _pythonTypes = {
  'int',
  'float',
  'str',
  'bool',
  'list',
  'tuple',
  'dict',
  'set',
  'frozenset',
  'bytes',
  'bytearray',
  'complex',
  'memoryview',
  'type',
  'object',
  'None',
  'Ellipsis',
  'NotImplemented',
  'True',
  'False',
};

const _goTypes = {
  'string',
  'int',
  'int8',
  'int16',
  'int32',
  'int64',
  'uint',
  'uint8',
  'uint16',
  'uint32',
  'uint64',
  'uintptr',
  'byte',
  'rune',
  'float32',
  'float64',
  'complex64',
  'complex128',
  'bool',
  'error',
  'interface{}',
  'map',
  'slice',
  'chan',
};

const _rustTypes = {
  'i8',
  'i16',
  'i32',
  'i64',
  'i128',
  'u8',
  'u16',
  'u32',
  'u64',
  'u128',
  'f32',
  'f64',
  'bool',
  'char',
  'str',
  'String',
  'Vec',
  'Option',
  'Result',
  'Box',
  'Rc',
  'Arc',
  'Slice',
  'Array',
  'Tuple',
  'Reference',
  'RawPointer',
  'Fn',
  'FnMut',
  'FnOnce',
};

const _kotlinTypes = {
  'string',
  'int',
  'double',
  'float',
  'long',
  'short',
  'byte',
  'boolean',
  'char',
  'String',
  'Int',
  'Double',
  'Float',
  'Long',
  'Short',
  'Byte',
  'Boolean',
  'Char',
  'Unit',
  'Any',
  'Nothing',
  'Array',
  'List',
  'MutableList',
  'Set',
  'MutableSet',
  'Map',
  'MutableMap',
};

final _builtInTypesByLang = <String, Set<String>>{
  'java': _javaTypes,
  'javascript': _jsTypes,
  'js': _jsTypes,
  'ecmascript': _jsTypes,
  'typescript': _tsTypes,
  'ts': _tsTypes,
  'dart': _dartTypes,
  'csharp': _csharpTypes,
  'c#': _csharpTypes,
  'cpp': _cppTypes,
  'c++': _cppTypes,
  'python': _pythonTypes,
  'py': _pythonTypes,
  'go': _goTypes,
  'rust': _rustTypes,
  'rs': _rustTypes,
  'kotlin': _kotlinTypes,
  'kt': _kotlinTypes,
};

Set<String> _getBuiltInTypes(String? language) {
  return _builtInTypesByLang[language?.toLowerCase()] ?? _javaTypes;
}
