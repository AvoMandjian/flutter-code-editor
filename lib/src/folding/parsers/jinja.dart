import 'package:charcode/ascii.dart';
import 'package:collection/collection.dart';
import 'package:highlight/highlight_core.dart';

import '../../code/code_lines.dart';
import '../../highlight/keyword_semantics.dart';
import '../../highlight/node.dart';
import '../../highlight/node_classes.dart';
import '../foldable_block_type.dart';
import 'highlight.dart';

/// A parser for foldable blocks for Jinja templates.
///
/// Handles Jinja-specific syntax:
/// - Template tags: `{% ... %}`
/// - Template variables: `{{ ... }}`
/// - Comments: `{# ... #}`
/// Also preserves standard brace/bracket/parentheses folding from parent class.
class JinjaFoldableBlockParser extends HighlightFoldableBlockParser {
  @override
  void parse({
    required Result highlighted,
    required Set<Object?> serviceCommentsSources,
    CodeLines lines = CodeLines.empty,
  }) {
    if (highlighted.nodes != null) {
      _processNodes(highlighted.nodes!, serviceCommentsSources);
    }

    submitCurrentLine(); // In case the last one did not end with '\n'.
    finalize();
  }

  void _processNodes(List<Node> nodes, Set<Object?> serviceCommentsSources) {
    for (final node in nodes) {
      _processNode(node, serviceCommentsSources);
    }
  }

  void _processNode(Node node, Set<Object?> serviceCommentsSources) {
    // Handle Jinja-specific class names
    switch (node.className) {
      case 'template-tag':
        _processTemplateTag(node, serviceCommentsSources);
        break;

      case 'template-variable':
        _processTemplateVariable(node, serviceCommentsSources);
        break;

      case NodeClasses.comment:
        _processComment(node, serviceCommentsSources);
        break;

      case NodeClasses.keyword:
        _processKeyword(node);
        break;

      case NodeClasses.string:
        _processString(node);
        break;

      default:
        // For all other nodes, use default handling
        // This includes standard braces, brackets, parentheses
        _processDefault(node, serviceCommentsSources);
    }
  }

  /// Processes template tags `{% ... %}` that span multiple lines.
  void _processTemplateTag(Node node, Set<Object?> serviceCommentsSources) {
    final newlineCount = node.getNewlineCount();

    // Only create foldable blocks for multi-line template tags
    if (newlineCount == 0) {
      // Single-line tag, process like default node (value + children)
      _processDefault(node, serviceCommentsSources);
      return;
    }

    // Multi-line template tag - create foldable block
    startBlock(lineIndex, FoldableBlockType.braces);

    // Process the node's value and children (this updates lineIndex)
    _processDefault(node, serviceCommentsSources);

    endBlock(lineIndex, FoldableBlockType.braces);
  }

  /// Processes template variables `{{ ... }}` that span multiple lines.
  void _processTemplateVariable(Node node, Set<Object?> serviceCommentsSources) {
    final newlineCount = node.getNewlineCount();

    // Only create foldable blocks for multi-line template variables
    if (newlineCount == 0) {
      // Single-line variable, process like default node (value + children)
      _processDefault(node, serviceCommentsSources);
      return;
    }

    // Multi-line template variable - create foldable block
    startBlock(lineIndex, FoldableBlockType.braces);

    // Process the node's value and children (this updates lineIndex)
    _processDefault(node, serviceCommentsSources);

    endBlock(lineIndex, FoldableBlockType.braces);
  }

  // Duplicate methods from parent class to access private functionality
  void _processComment(Node node, Set<Object?> serviceCommentsSources) {
    final newlineCount = node.getNewlineCount();

    if (foundNonWhitespace && newlineCount == 0) {
      return;
    }

    if (serviceCommentsSources.contains(node)) {
      return;
    }

    if (newlineCount == 0) {
      setFoundSingleLineComment();
      return;
    }

    startBlock(lineIndex, FoldableBlockType.multilineComment);

    for (var i = 0; i < newlineCount; i++) {
      setFoundMultilineComment();
      submitCurrentLine();
      addToLineIndex(1);
    }

    endBlock(lineIndex, FoldableBlockType.multilineComment);
  }

  void _processKeyword(Node node) {
    final child = node.children?.firstOrNull;
    if (child == null) {
      return;
    }

    final semantics = node.keywordSemantics;

    switch (semantics) {
      case KeywordSemantics.import:
        setFoundImport();
        break;
      case KeywordSemantics.possibleImport:
        setFoundPossibleImport();
        break;
      case null:
        setFoundImportTerminator();
        break;
    }
  }

  void _processString(Node node) {
    final newlineCount = node.getNewlineCount();

    setFoundNonWhitespace();
    if (newlineCount > 0) {
      setFoundImportTerminator();
      submitCurrentLine();
      clearLineFlags();
    }

    addToLineIndex(newlineCount);
  }

  void _processDefault(Node node, Set<Object?> serviceCommentsSources) {
    _processDefaultValue(node);

    if (node.children != null) {
      _processNodes(node.children!, serviceCommentsSources);
    }
  }

  /// Except: comment, keyword, string
  void _processDefaultValue(Node node) {
    final value = node.value;
    if (value == null) {
      return;
    }

    for (final code in value.runes) {
      switch (code) {
        case $space:
        case $tab:
        case $cr:
        case $lf:
          break;
        default:
          setFoundNonWhitespace();
      }

      switch (code) {
        case $lf: // Newline
          submitCurrentLine();
          clearLineFlags();
          addToLineIndex(1);
          break;

        case $openParenthesis: // (
          startBlock(lineIndex, FoldableBlockType.parentheses);
          break;

        case $closeParenthesis: // )
          endBlock(lineIndex, FoldableBlockType.parentheses);
          break;

        case $openBracket: // [
          startBlock(lineIndex, FoldableBlockType.brackets);
          break;

        case $closeBracket: // ]
          endBlock(lineIndex, FoldableBlockType.brackets);
          break;

        case $openBrace: // {
          startBlock(lineIndex, FoldableBlockType.braces);
          break;

        case $closeBrace: // }
          endBlock(lineIndex, FoldableBlockType.braces);
          break;
      }
    }
  }
}
