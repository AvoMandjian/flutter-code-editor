import 'package:charcode/ascii.dart';
import 'package:collection/collection.dart';
import 'package:highlight/highlight_core.dart';

import '../../code/code_lines.dart';
import '../../highlight/keyword_semantics.dart';
import '../../highlight/node.dart';
import '../../highlight/node_classes.dart';
import '../foldable_block.dart';
import '../foldable_block_type.dart';
import 'abstract.dart';
import 'highlight.dart';
import 'java.dart';

/// A parser for foldable blocks for Jinja templates.
///
/// Handles Jinja-specific syntax:
/// - Template tags: `{% ... %}`
/// - Template variables: `{{ ... }}`
/// - Comments: `{# ... #}`
/// Also preserves standard brace/bracket/parentheses folding from parent class.
/// When subLanguage is provided, also parses subLanguage blocks (e.g., Java classes/methods).
class JinjaFoldableBlockParser extends AbstractFoldableBlockParser {
  final String? subLanguage;

  JinjaFoldableBlockParser({this.subLanguage});

  @override
  void parse({
    required Result highlighted,
    required Set<Object?> serviceCommentsSources,
    required CodeLines lines,
  }) {
    // Parse Jinja-specific blocks
    final jinjaParser = _JinjaSpecificFoldableBlockParser();
    final jinjaBlocks = _getBlocksFromParser(
      jinjaParser,
      highlighted,
      serviceCommentsSources,
      lines,
    );

    // Parse subLanguage blocks if subLanguage is provided
    List<FoldableBlock> subLanguageBlocks = [];
    if (subLanguage != null) {
      final subLanguageParser = _getSubLanguageParser(subLanguage!);
      if (subLanguageParser != null) {
        subLanguageBlocks = _getBlocksFromParser(
          subLanguageParser,
          highlighted,
          serviceCommentsSources,
          lines,
        );
      }
    }

    if (jinjaBlocks.isEmpty && subLanguageBlocks.isEmpty) {
      return;
    }

    // Combine blocks from both parsers
    final combinedBlocks = _combineBlocks(
      jinjaBlocks: jinjaBlocks,
      subLanguageBlocks: subLanguageBlocks,
    );
    blocks.addAll(combinedBlocks);
    finalize();
  }

  List<FoldableBlock> _getBlocksFromParser(
    AbstractFoldableBlockParser parser,
    Result highlighted,
    Set<Object?> serviceCommentsSources,
    CodeLines lines,
  ) {
    parser.parse(
      highlighted: highlighted,
      serviceCommentsSources: serviceCommentsSources,
      lines: lines,
    );
    invalidBlocks.addAll(parser.invalidBlocks);
    return parser.blocks;
  }

  AbstractFoldableBlockParser? _getSubLanguageParser(String subLang) {
    switch (subLang) {
      case 'java':
        return JavaFoldableBlockParser();
      default:
        // For other subLanguages, use HighlightFoldableBlockParser
        // which handles standard braces/brackets/parentheses
        return HighlightFoldableBlockParser();
    }
  }

  /// Combines blocks from Jinja parser and subLanguage parser.
  /// Priority is given to Jinja blocks if they intersect with subLanguage blocks.
  List<FoldableBlock> _combineBlocks({
    required List<FoldableBlock> jinjaBlocks,
    required List<FoldableBlock> subLanguageBlocks,
  }) {
    var jinjaBlockIndex = 0;
    var subLanguageBlockIndex = 0;

    final result = <FoldableBlock>[];

    while (jinjaBlockIndex < jinjaBlocks.length || subLanguageBlockIndex < subLanguageBlocks.length) {
      if (jinjaBlockIndex >= jinjaBlocks.length) {
        result.addAll(subLanguageBlocks.skip(subLanguageBlockIndex));
        break;
      }

      final jinjaBlock = jinjaBlocks[jinjaBlockIndex];

      // Add subLanguage blocks that come before this Jinja block
      final subLanguageBlocksToAdd = _getAllBlocksBeforeLine(
        startIndex: subLanguageBlockIndex,
        blocks: subLanguageBlocks,
        maxFirstLine: jinjaBlock.firstLine,
      );
      result.addAll(subLanguageBlocksToAdd);
      subLanguageBlockIndex += subLanguageBlocksToAdd.length;

      // Skip subLanguage blocks that are inside this Jinja block
      while (subLanguageBlockIndex < subLanguageBlocks.length && jinjaBlock.includes(subLanguageBlocks[subLanguageBlockIndex])) {
        subLanguageBlockIndex++;
      }

      result.add(jinjaBlock);
      jinjaBlockIndex++;
    }

    return result;
  }

  /// Returns [blocks] from [startIndex]
  /// while their first lines are less than [maxFirstLine].
  List<FoldableBlock> _getAllBlocksBeforeLine({
    required int startIndex,
    required List<FoldableBlock> blocks,
    required int maxFirstLine,
  }) {
    final blockCount = _getBlocksCountBeforeLineFrom(
      startIndex: startIndex,
      line: maxFirstLine,
      blocks: blocks,
    );
    return blocks.sublist(
      startIndex,
      startIndex + blockCount,
    );
  }

  int _getBlocksCountBeforeLineFrom({
    required int startIndex,
    required int line,
    required List<FoldableBlock> blocks,
  }) {
    var result = 0;
    for (var i = startIndex; i < blocks.length; i++) {
      final block = blocks[i];
      if (block.firstLine < line) {
        result++;
      } else {
        break;
      }
    }
    return result;
  }
}

/// Internal parser that handles only Jinja-specific syntax.
class _JinjaSpecificFoldableBlockParser extends HighlightFoldableBlockParser {
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

  /// Processes template tags `{% ... %}`.
  /// Creates foldable blocks for:
  /// - Multi-line template tags (tags with newlines inside)
  /// - Control structures like {% for %}/{% endfor %}, {% if %}/{% endif %}, etc.
  void _processTemplateTag(Node node, Set<Object?> serviceCommentsSources) {
    final tagValue = node.value ?? '';
    final newlineCount = node.getNewlineCount();

    // Check if this is an opening control structure tag
    final isOpeningTag = _isOpeningControlTag(tagValue);
    final isClosingTag = _isClosingControlTag(tagValue);

    if (isOpeningTag) {
      // Start a block for control structures like {% for %}, {% if %}, etc.
      startBlock(lineIndex, FoldableBlockType.braces);
      _processDefault(node, serviceCommentsSources);
      // Note: The block will be closed when we encounter the matching {% endfor %}, {% endif %}, etc.
      return;
    }

    if (isClosingTag) {
      // End the block for control structures
      _processDefault(node, serviceCommentsSources);
      endBlock(lineIndex, FoldableBlockType.braces);
      return;
    }

    // For multi-line template tags (tags with newlines inside the tag itself)
    if (newlineCount > 0) {
      startBlock(lineIndex, FoldableBlockType.braces);
      _processDefault(node, serviceCommentsSources);
      endBlock(lineIndex, FoldableBlockType.braces);
      return;
    }

    // Single-line tag, process like default node (value + children)
    _processDefault(node, serviceCommentsSources);
  }

  /// Checks if a template tag is an opening control structure (for, if, while, etc.)
  bool _isOpeningControlTag(String tagValue) {
    final normalized = tagValue.trim().toLowerCase();
    return normalized.startsWith('{%') &&
        (normalized.contains('for ') ||
            normalized.contains('if ') ||
            normalized.contains('while ') ||
            normalized.contains('with ') ||
            normalized.contains('macro ') ||
            normalized.contains('block ') ||
            normalized.contains('call ') ||
            normalized.contains('filter '));
  }

  /// Checks if a template tag is a closing control structure (endfor, endif, etc.)
  bool _isClosingControlTag(String tagValue) {
    final normalized = tagValue.trim().toLowerCase();
    return normalized.startsWith('{%') &&
        (normalized.contains('endfor') ||
            normalized.contains('endif') ||
            normalized.contains('endwhile') ||
            normalized.contains('endwith') ||
            normalized.contains('endmacro') ||
            normalized.contains('endblock') ||
            normalized.contains('endcall') ||
            normalized.contains('endfilter'));
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
