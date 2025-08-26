import 'package:flutter/foundation.dart';

@immutable
class CodeEditorStateModel {
  final String? jinjaOutput;
  final Map<String, dynamic> breakpointsInfo;
  final Set<int> breakpoints;

  const CodeEditorStateModel({
    this.jinjaOutput,
    this.breakpointsInfo = const {},
    this.breakpoints = const {},
  });

  CodeEditorStateModel copyWith({
    String? jinjaOutput,
    Map<String, dynamic>? breakpointsInfo,
    Set<int>? breakpoints,
  }) {
    return CodeEditorStateModel(
      jinjaOutput: jinjaOutput ?? this.jinjaOutput,
      breakpointsInfo: breakpointsInfo ?? this.breakpointsInfo,
      breakpoints: breakpoints ?? this.breakpoints,
    );
  }
}