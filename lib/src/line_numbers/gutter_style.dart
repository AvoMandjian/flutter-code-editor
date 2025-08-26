import 'package:flutter/material.dart';

class GutterStyle {
  /// Width of the line number column.
  final double gutterWidthMultiplier;

  /// Width of the line number column with breakpoints.
  final double gutterWidthMultiplierWithBreakpoints;

  /// Alignment of the numbers in the column.
  final TextAlign textAlign;

  /// Style of the numbers.
  ///
  /// [TextStyle.fontSize] and [TextStyle.fontFamily] are ignored
  /// and taken from the widget style or [TextTheme.titleMedium] for consistency
  /// with lines. Everything else applies.
  ///
  /// Of omitted, the widget or theme value is used with the color of
  /// half the opacity.
  final TextStyle? textStyle;

  /// Style of the error popup.
  final TextStyle? errorPopupTextStyle;

  /// Background of the line number column.
  final Color? background;

  /// Central horizontal margin between the numbers and the code.
  final double margin;

  /// Whether to show line numbers column.
  final bool showLineNumbers;

  /// Whether to show errors column.
  final bool showErrors;

  /// Whether to show folding handles column.
  final bool showFoldingHandles;

  /// Whether to show breakpoints column.
  final bool showBreakpoints;

  /// The color of the breakpoint icon.
  final Color breakpointColor;

  /// Maximum width of the gutter.
  final double maxWidth;

  /// Whether there is any column to show in gutter.
  bool get showGutter => showLineNumbers || showErrors || showFoldingHandles || showBreakpoints;

  const GutterStyle({
    this.margin = 10.0,
    this.textAlign = TextAlign.right,
    this.showErrors = true,
    this.showFoldingHandles = true,
    this.showLineNumbers = true,
    this.showBreakpoints = false,
    this.breakpointColor = Colors.red,
    this.gutterWidthMultiplier = 32,
    this.gutterWidthMultiplierWithBreakpoints = 200,
    this.background,
    this.errorPopupTextStyle,
    this.textStyle,
    this.maxWidth = 80,
  });

  /// Hides the gutter entirely.
  ///
  /// Use this instead of all-`false` because new elements can be added
  /// to the gutter in the future versions.
  static const none = GutterStyle(
    showErrors: false,
    showFoldingHandles: false,
    showLineNumbers: false,
  );

  GutterStyle copyWith({
    TextStyle? errorPopupTextStyle,
    TextStyle? textStyle,
    double? maxWidth,
    bool? showBreakpoints,
    Color? breakpointColor,
    double? gutterWidthMultiplier,
    double? gutterWidthMultiplierWithBreakpoints,
  }) =>
      GutterStyle(
        gutterWidthMultiplier: gutterWidthMultiplier ?? this.gutterWidthMultiplier,
        gutterWidthMultiplierWithBreakpoints: gutterWidthMultiplierWithBreakpoints ?? this.gutterWidthMultiplierWithBreakpoints,
        textAlign: textAlign,
        textStyle: textStyle ?? this.textStyle,
        errorPopupTextStyle: errorPopupTextStyle,
        background: background,
        margin: margin,
        showErrors: showErrors,
        showFoldingHandles: showFoldingHandles,
        showLineNumbers: showLineNumbers,
        showBreakpoints: showBreakpoints ?? this.showBreakpoints,
        breakpointColor: breakpointColor ?? this.breakpointColor,
        maxWidth: maxWidth ?? 80,
      );
}

@Deprecated('Renamed to GutterStyle')
typedef LineNumberStyle = GutterStyle;
