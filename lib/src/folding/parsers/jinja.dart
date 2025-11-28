import 'package:charcode/ascii.dart';
import 'package:highlight/highlight_core.dart';

import '../../code/code_lines.dart';
import '../../highlight/node.dart';
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

    print('[JINJA_PARSER_FINAL] Jinja blocks found: ${jinjaBlocks.length}');
    print('[JINJA_PARSER_FINAL] SubLanguage blocks found: ${subLanguageBlocks.length}');
    print('[JINJA_PARSER_FINAL] Combined blocks: ${blocks.length}');
    for (var i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      print('[JINJA_PARSER_FINAL] Final Block $i: lines ${block.firstLine}-${block.lastLine}, type=${block.type}');
    }

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
    print('[JINJA_PARSER] ========== STARTING JINJA PARSING ==========');
    print('[JINJA_PARSER] Total nodes to process: ${highlighted.nodes?.length ?? 0}');
    print('[JINJA_PARSER] Total lines: ${lines.length}');

    if (highlighted.nodes != null) {
      _processNodes(highlighted.nodes!, serviceCommentsSources);
    }

    submitCurrentLine(); // In case the last one did not end with '\n'.
    finalize();

    print('[JINJA_PARSER] ========== FINISHED JINJA PARSING ==========');
    print('[JINJA_PARSER] Total blocks created: ${blocks.length}');
    print('[JINJA_PARSER] Total invalid blocks: ${invalidBlocks.length}');
    for (var i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      print('[JINJA_PARSER] Block $i: lines ${block.firstLine}-${block.lastLine}, type=${block.type}');
    }
  }

  void _processNodes(List<Node> nodes, Set<Object?> serviceCommentsSources) {
    print('[JINJA_PARSER] _processNodes: Processing ${nodes.length} nodes');
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      print('[JINJA_PARSER] _processNodes: Node $i/${nodes.length}');
      _processNode(node, serviceCommentsSources);
    }
  }

  void _processNode(Node node, Set<Object?> serviceCommentsSources) {
    final nodeValue = node.value ?? '';
    final nodeText = _getNodeText(node);
    print(
      '[JINJA_PARSER] Processing node: className="${node.className}", value="${nodeValue.substring(0, nodeValue.length > 50 ? 50 : nodeValue.length)}", fullText="${nodeText.substring(0, nodeText.length > 100 ? 100 : nodeText.length)}", lineIndex=$lineIndex',
    );

    // Handle ONLY Jinja-specific class names
    // All other nodes (comments, keywords, strings, etc.) should be handled
    // by the sublanguage parser (Java, JavaScript, etc.)
    switch (node.className) {
      case 'template-tag':
        print('[JINJA_PARSER] → Routing to _processTemplateTag');
        _processTemplateTag(node, serviceCommentsSources);
        break;

      case 'template-variable':
        print('[JINJA_PARSER] → Routing to _processTemplateVariable');
        _processTemplateVariable(node, serviceCommentsSources);
        break;

      default:
        // For all other nodes (including comments, keywords, strings, etc.),
        // just track line numbers and delegate to sublanguage parser
        print('[JINJA_PARSER] → Routing to _processDefault (className="${node.className}")');
        _processDefault(node, serviceCommentsSources);
    }
  }

  /// Processes template tags `{% ... %}`.
  /// Creates foldable blocks for:
  /// - Multi-line template tags (tags with newlines inside)
  /// - Control structures like {% for %}/{% endfor %}, {% if %}/{% endif %}, etc.
  void _processTemplateTag(Node node, Set<Object?> serviceCommentsSources) {
    final tagValue = _getNodeText(node);
    final newlineCount = node.getNewlineCount();
    print('[JINJA_PARSER] _processTemplateTag: tagValue="$tagValue", newlineCount=$newlineCount, lineIndex=$lineIndex');

    // Check if this is an opening control structure tag
    final isOpeningTag = _isOpeningControlTag(tagValue);
    final isClosingTag = _isClosingControlTag(tagValue);
    print('[JINJA_PARSER] _processTemplateTag: isOpeningTag=$isOpeningTag, isClosingTag=$isClosingTag');

    if (isOpeningTag) {
      // Start a block for control structures like {% for %}, {% if %}, etc.
      print('[JINJA_PARSER] _processTemplateTag: Starting block at lineIndex=$lineIndex (opening tag)');
      startBlock(lineIndex, FoldableBlockType.braces);
      _processJinjaNodeValue(node, serviceCommentsSources);
      // Note: The block will be closed when we encounter the matching {% endfor %}, {% endif %}, etc.
      return;
    }

    if (isClosingTag) {
      // End the block for control structures
      print('[JINJA_PARSER] _processTemplateTag: Ending block at lineIndex=$lineIndex (closing tag)');
      _processJinjaNodeValue(node, serviceCommentsSources);
      endBlock(lineIndex, FoldableBlockType.braces);
      return;
    }

    // For multi-line template tags (tags with newlines inside the tag itself)
    if (newlineCount > 0) {
      print('[JINJA_PARSER] _processTemplateTag: Multi-line tag, starting/ending block at lineIndex=$lineIndex');
      startBlock(lineIndex, FoldableBlockType.braces);
      _processJinjaNodeValue(node, serviceCommentsSources);
      endBlock(lineIndex, FoldableBlockType.braces);
      return;
    }

    // Single-line tag, process without treating delimiter braces as code structure
    print('[JINJA_PARSER] _processTemplateTag: Single-line tag, processing without block creation');
    _processJinjaNodeValue(node, serviceCommentsSources);
  }

  String _getNodeText(Node node) {
    final buffer = StringBuffer();
    if (node.value != null) {
      buffer.write(node.value);
    }
    if (node.children != null) {
      for (final child in node.children!) {
        buffer.write(_getNodeText(child));
      }
    }
    return buffer.toString();
  }

  /// Checks if a template tag is an opening control structure (for, if, while, etc.)
  bool _isOpeningControlTag(String tagValue) {
    final normalized = tagValue.trim().toLowerCase();
    // Remove the opening delimiter to check keywords at the start
    var content = normalized;
    if (content.startsWith('{%-')) {
      content = content.substring(3).trimLeft();
    } else if (content.startsWith('{%')) {
      content = content.substring(2).trimLeft();
    } else {
      return false;
    }

    // Check for start keywords.
    // We check that the keyword is followed by a space or it's the end of the content (though usually there are params)
    // or it is followed by the closing delimiter.
    final keywords = [
      'for',
      'if',
      'while',
      'with',
      'macro',
      'block',
      'call',
      'filter',
    ];

    for (final keyword in keywords) {
      if (content.startsWith(keyword)) {
        final afterKeyword = content.substring(keyword.length);
        if (afterKeyword.isEmpty || afterKeyword.startsWith(' ') || afterKeyword.startsWith('%}') || afterKeyword.startsWith('-%}')) {
          return true;
        }
      }
    }
    return false;
  }

  bool _isClosingControlTag(String tagValue) {
    final normalized = tagValue.trim().toLowerCase();
    var content = normalized;
    if (content.startsWith('{%-')) {
      content = content.substring(3).trimLeft();
    } else if (content.startsWith('{%')) {
      content = content.substring(2).trimLeft();
    } else {
      return false;
    }

    final keywords = [
      'endfor',
      'endif',
      'endwhile',
      'endwith',
      'endmacro',
      'endblock',
      'endcall',
      'endfilter',
    ];

    for (final keyword in keywords) {
      if (content.startsWith(keyword)) {
        final afterKeyword = content.substring(keyword.length);
        if (afterKeyword.isEmpty || afterKeyword.startsWith(' ') || afterKeyword.startsWith('%}') || afterKeyword.startsWith('-%}')) {
          return true;
        }
      }
    }
    return false;
  }

  /// Processes template variables `{{ ... }}` that span multiple lines.
  void _processTemplateVariable(Node node, Set<Object?> serviceCommentsSources) {
    final newlineCount = node.getNewlineCount();
    final varValue = _getNodeText(node);
    print('[JINJA_PARSER] _processTemplateVariable: varValue="$varValue", newlineCount=$newlineCount, lineIndex=$lineIndex');

    // Only create foldable blocks for multi-line template variables
    if (newlineCount == 0) {
      // Single-line variable, process without treating delimiter braces as code structure
      print('[JINJA_PARSER] _processTemplateVariable: Single-line variable, processing without block creation');
      _processJinjaNodeValue(node, serviceCommentsSources);
      return;
    }

    // Multi-line template variable - create foldable block
    print('[JINJA_PARSER] _processTemplateVariable: Multi-line variable, starting block at lineIndex=$lineIndex');
    startBlock(lineIndex, FoldableBlockType.braces);

    // Process the node's value and children (this updates lineIndex)
    _processJinjaNodeValue(node, serviceCommentsSources);

    print('[JINJA_PARSER] _processTemplateVariable: Ending block at lineIndex=$lineIndex');
    endBlock(lineIndex, FoldableBlockType.braces);
  }

  void _processDefault(Node node, Set<Object?> serviceCommentsSources) {
    final nodeValue = node.value ?? '';
    print(
      '[JINJA_PARSER] _processDefault: Processing default node, value="${nodeValue.substring(0, nodeValue.length > 100 ? 100 : nodeValue.length)}", lineIndex=$lineIndex',
    );
    _processDefaultValue(node);

    if (node.children != null) {
      print('[JINJA_PARSER] _processDefault: Processing ${node.children!.length} children');
      _processNodes(node.children!, serviceCommentsSources);
    }
  }

  /// Processes Jinja node value without treating delimiter braces as code structure.
  /// This prevents Jinja delimiters {% ... %} and {{ ... }} from creating incorrect foldable blocks.
  void _processJinjaNodeValue(Node node, Set<Object?> serviceCommentsSources) {
    final value = node.value ?? '';
    print(
      '[JINJA_PARSER] _processJinjaNodeValue: value="${value.substring(0, value.length > 100 ? 100 : value.length)}", hasChildren=${node.children != null}, childrenCount=${node.children?.length ?? 0}',
    );

    if (value.isNotEmpty) {
      _processJinjaValue(value);
    }

    if (node.children != null) {
      print('[JINJA_PARSER] _processJinjaNodeValue: Processing ${node.children!.length} children recursively');
      for (final child in node.children!) {
        _processJinjaNodeValue(child, serviceCommentsSources);
      }
    }
  }

  /// Processes a Jinja node's value, handling newlines and whitespace
  /// but NOT treating braces as code structure (since they're Jinja delimiters).
  void _processJinjaValue(String value) {
    var braceCount = 0;
    var bracketCount = 0;
    var parenCount = 0;

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

      // Track braces/brackets/parentheses to see what we're skipping
      if (code == $openBrace) {
        braceCount++;
        print('[JINJA_PARSER] _processJinjaValue: Found { (skipping, braceCount=$braceCount)');
      } else if (code == $closeBrace) {
        braceCount--;
        print('[JINJA_PARSER] _processJinjaValue: Found } (skipping, braceCount=$braceCount)');
      } else if (code == $openBracket) {
        bracketCount++;
        print('[JINJA_PARSER] _processJinjaValue: Found [ (skipping, bracketCount=$bracketCount)');
      } else if (code == $closeBracket) {
        bracketCount--;
        print('[JINJA_PARSER] _processJinjaValue: Found ] (skipping, bracketCount=$bracketCount)');
      } else if (code == $openParenthesis) {
        parenCount++;
        print('[JINJA_PARSER] _processJinjaValue: Found ( (skipping, parenCount=$parenCount)');
      } else if (code == $closeParenthesis) {
        parenCount--;
        print('[JINJA_PARSER] _processJinjaValue: Found ) (skipping, parenCount=$parenCount)');
      }

      // Only handle newlines, not braces/brackets/parentheses
      // (those are part of Jinja delimiters, not code structure)
      if (code == $lf) {
        print('[JINJA_PARSER] _processJinjaValue: Found newline, submitting line and incrementing lineIndex');
        submitCurrentLine();
        clearLineFlags();
        addToLineIndex(1);
      }
    }

    if (braceCount != 0 || bracketCount != 0 || parenCount != 0) {
      print(
        '[JINJA_PARSER] _processJinjaValue: WARNING - Unbalanced delimiters: braces=$braceCount, brackets=$bracketCount, parens=$parenCount',
      );
    }
  }

  /// Except: comment, keyword, string
  ///
  /// Note: This method ONLY handles newlines and whitespace.
  /// It does NOT create foldable blocks for braces, brackets, or parentheses
  /// because those are part of the sublanguage (Java, etc.) and should be
  /// handled by the sublanguage parser, not the Jinja parser.
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

      // Only handle newlines - let the sublanguage parser handle code structure
      if (code == $lf) {
        print('[JINJA_PARSER] _processDefaultValue: Found newline at lineIndex=$lineIndex');
        submitCurrentLine();
        clearLineFlags();
        addToLineIndex(1);
      }
    }
  }
}
