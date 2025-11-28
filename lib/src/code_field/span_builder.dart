import 'package:flutter/material.dart';
import 'package:highlight/highlight_core.dart';

import '../analyzer/models/issue.dart';
import '../code/code.dart';
import '../code/text_style.dart';
import '../code_theme/code_theme_data.dart';
import '../folding/foldable_block.dart';
import '../highlight/node.dart';

class SpanBuilder {
  final Code code;
  final CodeThemeData? theme;
  final TextStyle? rootStyle;
  final List<Issue> issues;
  final FoldableBlock? highlightedBlock;

  var _visibleLineIndex = 0;

  SpanBuilder({
    required this.code,
    required this.theme,
    this.rootStyle,
    this.issues = const [],
    this.highlightedBlock,
  });

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
    // Use the same node classification logic as block folding
    // Handle Jinja-specific nodes the same way as the block folding parser
    switch (node.className) {
      case 'template-tag':
      case 'template-variable':
        return _buildJinjaNode(
          node: node,
          theme: theme,
          ancestorStyle: ancestorStyle,
        );

      default:
        return _buildDefaultNode(
          node: node,
          theme: theme,
          ancestorStyle: ancestorStyle,
        );
    }
  }

  /// Builds a Jinja-specific node (template-tag or template-variable).
  /// Uses the same logic as block folding parser for consistency.
  TextSpan _buildJinjaNode({
    required Node node,
    required CodeThemeData? theme,
    TextStyle? ancestorStyle,
  }) {
    final style = theme?.styles[node.className] ?? ancestorStyle;
    final processedStyle = _paleIfRequired(style);

    // Track line index before processing this node
    final lineIndexBefore = _visibleLineIndex;
    _updateLineIndex(node);

    // Apply error and block highlighting styles
    final enhancedStyle = _applyHighlightingStyles(
      processedStyle,
      lineIndexBefore,
    );

    // Process Jinja node value and children recursively
    // This matches the logic in _JinjaSpecificFoldableBlockParser._processJinjaNodeValue
    return TextSpan(
      text: node.value,
      children: _buildJinjaChildren(
        node: node,
        theme: theme,
        ancestorStyle: style,
      ),
      style: enhancedStyle,
    );
  }

  /// Builds children of a Jinja node, processing them recursively.
  List<TextSpan>? _buildJinjaChildren({
    required Node node,
    required CodeThemeData? theme,
    TextStyle? ancestorStyle,
  }) {
    if (node.children == null || node.children!.isEmpty) {
      return null;
    }

    // Process children recursively, applying the same node classification
    return node.children!
        .map(
          (child) => _buildNode(
            node: child,
            theme: theme,
            ancestorStyle: ancestorStyle,
          ),
        )
        .toList(growable: false);
  }

  /// Builds a default (non-Jinja) node.
  /// This handles sublanguage nodes (Java, JavaScript, etc.) and other nodes.
  TextSpan _buildDefaultNode({
    required Node node,
    required CodeThemeData? theme,
    TextStyle? ancestorStyle,
  }) {
    final style = theme?.styles[node.className] ?? ancestorStyle;
    final processedStyle = _paleIfRequired(style);

    // Track line index before processing this node
    final lineIndexBefore = _visibleLineIndex;
    _updateLineIndex(node);

    // Apply error and block highlighting styles
    final enhancedStyle = _applyHighlightingStyles(
      processedStyle,
      lineIndexBefore,
    );

    return TextSpan(
      text: node.value,
      children: _buildList(
        nodes: node.children,
        theme: theme,
        ancestorStyle: style,
      ),
      style: enhancedStyle,
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

  /// Applies error and block highlighting styles to the given style.
  TextStyle? _applyHighlightingStyles(TextStyle? style, int lineIndex) {
    if (style == null) {
      return null;
    }

    // Get the full line index (accounting for hidden ranges)
    final fullLineIndex = code.hiddenLineRanges.recoverLineIndex(lineIndex);

    // Check for error highlighting
    final hasError = issues.any((issue) => issue.line == fullLineIndex);

    // Check for block highlighting
    final isBlockLine =
        highlightedBlock != null && (fullLineIndex == highlightedBlock!.firstLine || fullLineIndex == highlightedBlock!.lastLine);

    // Build the enhanced style
    TextStyle? enhancedStyle = style;

    // Apply error decoration (wavy red underline)
    if (hasError) {
      enhancedStyle = enhancedStyle.copyWith(
        decoration: TextDecoration.combine([
          enhancedStyle.decoration ?? TextDecoration.none,
          TextDecoration.underline,
        ]),
        decorationStyle: TextDecorationStyle.wavy,
        decorationColor: Colors.red,
      );
    }

    // Apply block highlighting (subtle background color)
    if (isBlockLine) {
      enhancedStyle = enhancedStyle.copyWith(
        backgroundColor: Colors.blue.withOpacity(0.1),
        fontWeight: FontWeight.w500,
      );
    }

    return enhancedStyle;
  }
}
