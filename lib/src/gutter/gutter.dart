// TODO(alexeyinkin): Remove when dropping support for Flutter < 3.10, https://github.com/akvelon/flutter-code-editor/issues/245
// ignore_for_file: unnecessary_non_null_assertion

import 'package:flutter/material.dart';

import '../code_field/code_controller.dart';
import '../line_numbers/gutter_style.dart';
import 'breakpoint.dart';
import 'error.dart';
import 'fold_toggle.dart';

const _breakpointColumn = 0;
const _lineNumberColumn = 1;
const _issueColumn = 2;
const _foldingColumn = 3;

class GutterWidget extends StatelessWidget {
  const GutterWidget({
    required this.codeController,
    required this.style,
    required this.scrollController,
  });

  final CodeController codeController;
  final GutterStyle style;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        controller: scrollController,
        child: AnimatedBuilder(
          animation: codeController,
          builder: _buildOnChange,
        ),
      ),
    );
  }

  Widget _buildOnChange(BuildContext context, Widget? child) {
    final code = codeController.code;
    final valueNotifierIsHovered = <int, ValueNotifier<bool>>{};

    final tableRows = List.generate(
      code.hiddenLineRanges.visibleLineNumbers.length,
      // ignore: prefer_const_constructors
      (i) => TableRow(
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
        ],
      ),
    );
    _fillLineNumbers(tableRows, valueNotifierIsHovered);

    if (style.showBreakpoints) {
      _fillBreakpoints(tableRows, valueNotifierIsHovered);
    }

    if (style.showErrors) {
      _fillIssues(tableRows);
    }
    if (style.showFoldingHandles) {
      _fillFoldToggles(tableRows);
    }

    return Container(
      padding: EdgeInsets.only(top: 12, bottom: 12, right: style.margin),
      alignment: Alignment.topLeft,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tableRows.map(
              (e) {
                return Row(
                  children: e.children!.map((e) {
                    return e;
                  }).toList(),
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }

  void _fillLineNumbers(List<TableRow> tableRows, Map<int, ValueNotifier<bool>> valueNotifierIsHovered) {
    final code = codeController.code;

    for (final i in code.hiddenLineRanges.visibleLineNumbers) {
      final lineIndex = _lineIndexToTableRowIndex(i);

      if (lineIndex == null) {
        continue;
      }
      valueNotifierIsHovered[lineIndex + 1] = ValueNotifier<bool>(false);
      tableRows[lineIndex].children![_lineNumberColumn] = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => valueNotifierIsHovered[lineIndex + 1]!.value = true,
        onExit: (_) => valueNotifierIsHovered[lineIndex + 1]!.value = false,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => codeController.toggleBreakpoint(lineIndex + 1),
          child: Text(
            style.showLineNumbers ? '${i + 1}' : ' ',
            style: style.textStyle,
            textAlign: style.textAlign,
          ),
        ),
      );
    }
  }

  void _fillIssues(List<TableRow> tableRows) {
    for (final issue in codeController.analysisResult.issues) {
      if (issue.line >= codeController.code.lines.length) {
        continue;
      }

      final lineIndex = _lineIndexToTableRowIndex(issue.line);
      if (lineIndex == null || lineIndex >= tableRows.length) {
        continue;
      }
      tableRows[lineIndex].children![_issueColumn] = GutterErrorWidget(
        issue,
        style.errorPopupTextStyle ?? (throw Exception('Error popup style should never be null')),
      );
    }
  }

  void _fillFoldToggles(List<TableRow> tableRows) {
    final code = codeController.code;

    for (final block in code.foldableBlocks) {
      final lineIndex = _lineIndexToTableRowIndex(block.firstLine);
      if (lineIndex == null) {
        continue;
      }

      final isFolded = code.foldedBlocks.contains(block);

      tableRows[lineIndex].children![_foldingColumn] = FoldToggle(
        color: style.textStyle?.color,
        isFolded: isFolded,
        onTap: isFolded ? () => codeController.unfoldAt(block.firstLine) : () => codeController.foldAt(block.firstLine),
      );
    }

    // Add folded blocks that are not considered as a valid foldable block,
    // but should be folded because they were folded before becoming invalid.
    for (final block in code.foldedBlocks) {
      final lineIndex = _lineIndexToTableRowIndex(block.firstLine);
      if (lineIndex == null || lineIndex >= tableRows.length) {
        continue;
      }

      tableRows[lineIndex].children![_foldingColumn] = FoldToggle(
        color: style.textStyle?.color,
        isFolded: true,
        onTap: () => codeController.unfoldAt(block.firstLine),
      );
    }
  }

  void _fillBreakpoints(List<TableRow> tableRows, Map<int, ValueNotifier<bool>> valueNotifierIsHovered) {
    final code = codeController.code;

    for (final i in code.hiddenLineRanges.visibleLineNumbers) {
      final lineIndex = _lineIndexToTableRowIndex(i);

      if (lineIndex == null) {
        continue;
      }

      tableRows[lineIndex].children![_breakpointColumn] = BreakpointWidget(
        line: i + 1,
        controller: codeController,
        color: style.breakpointColor,
        valueNotifierIsHovered: valueNotifierIsHovered,
      );
    }
  }

  int? _lineIndexToTableRowIndex(int line) {
    return codeController.code.hiddenLineRanges.cutLineIndexIfVisible(line);
  }
}
