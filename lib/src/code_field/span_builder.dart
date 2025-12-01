import 'package:flutter/material.dart';
import 'package:highlight/highlight_core.dart';

import '../code/code.dart';
import '../code/text_style.dart';
import '../code_theme/code_theme_data.dart';
import '../folding/foldable_block.dart';
import '../highlight/node.dart';
import '../highlight/node_classes.dart';

/// Background color for highlighting block boundary tags (start and end tags of foldable blocks).
/// Uses a darker blue with good contrast for both light and dark themes.
@visibleForTesting
const blockBoundaryBackgroundColor = Color.fromARGB(255, 30, 60, 100);

class SpanBuilder {
  final Code code;
  final CodeThemeData? theme;
  final TextStyle? rootStyle;
  final int? cursorPosition;

  var _visibleLineIndex = 0;
  late final Set<FoldableBlock> _blocksContainingCursor;

  SpanBuilder({
    required this.code,
    required this.theme,
    this.rootStyle,
    this.cursorPosition,
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
      return TextSpan(
        text: node.value,
        children: _buildList(
          nodes: node.children,
          theme: theme,
          ancestorStyle: _paleIfRequired(style),
        ),
        style: _paleIfRequired(style),
      );
    }

    final blockFirstLines = _getBlockFirstLines();
    final blockLastLines = _getBlockLastLines();
    final isOnFirstLine = blockFirstLines.contains(fullLineBeforeUpdate);
    final isOnLastLine = blockLastLines.contains(fullLineBeforeUpdate);

    // Check if this should be highlighted:
    // 1. Jinja template-tag nodes on boundary lines
    // 2. Keywords on first lines of blocks (for subLanguage like Java)
    // 3. Opening braces { on first lines of blocks
    // 4. Closing braces } on last lines of blocks
    final isTemplateTag = node.className == 'template-tag';
    final isKeyword = node.className == NodeClasses.keyword;
    final isTitle = node.className == NodeClasses.title;
    final isType = node.className == NodeClasses.type;
    final isParams = node.className == NodeClasses.params;
    final isMeta = node.className == NodeClasses.meta;
    final nodeValue = node.value ?? '';
    final hasOpenBrace = nodeValue.contains('{');
    final hasCloseBrace = nodeValue.contains('}');

    bool shouldHighlight = (isTemplateTag && (isOnFirstLine || isOnLastLine)) ||
        (isKeyword && isOnFirstLine) ||
        (isTitle && isOnFirstLine) ||
        (isType && isOnFirstLine) ||
        (isParams && isOnFirstLine) ||
        (isMeta && isOnFirstLine) ||
        (hasOpenBrace && isOnFirstLine) ||
        (_containsLanguageBuiltInTypes(nodeValue) && isOnFirstLine) ||
        (nodeValue.trim().isEmpty && isOnFirstLine) ||
        (hasCloseBrace && isOnLastLine);

    // Special handling for Java built-in types within parameter lists on foldable block boundaries
    // Some highlighting libraries don't assign 'type' class to built-in types like String, Integer
    // We only apply this enhancement when there are foldable blocks to highlight boundaries
    if (code.foldableBlocks.isNotEmpty && !shouldHighlight && isOnFirstLine && isParams) {
      shouldHighlight = true;
    }

    if (shouldHighlight) {
      // Optional: You can uncomment the following for debugging highlighting behavior
      // final String actualValue = node.value ?? (node.children?.map((e) => e.value ?? '').join() ?? '');
      // final valueLog = actualValue.isEmpty ? 'null (container)' : '"${actualValue.replaceAll('\n', r'\n')}"';
      // print('Highlighting node: class="${node.className}", value=$valueLog at line $fullLineBeforeUpdate');
    }

    _updateLineIndex(node);

    // Apply background color to relevant nodes on boundary lines
    final processedStyle = _applyBlockBoundaryHighlight(
      _paleIfRequired(style),
      shouldHighlight,
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

  /// Checks if the given text contains common Java built-in type names
  bool _containsLanguageBuiltInTypes(String text) {
    // Common Java built-in types and wrapper classes
    const javaBuiltInTypes = {
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

    // Check if the text contains any of the built-in type names
    for (final type in javaBuiltInTypes) {
      if (text.trim().toLowerCase().contains(type.trim().toLowerCase())) {
        return true;
      }
    }
    return false;
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
