import 'package:flutter/material.dart';

import 'package:flutter_code_editor/src/code_field/code_controller.dart';

const _breakpointRadius = 4.0;

class BreakpointWidget extends StatefulWidget {
  final int line;
  final CodeController controller;
  final Color color;

  const BreakpointWidget({
    super.key,
    required this.line,
    required this.controller,
    required this.color,
  });

  @override
  State<BreakpointWidget> createState() => _BreakpointWidgetState();
}

class _BreakpointWidgetState extends State<BreakpointWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isBreakpoint = widget.controller.breakpoints.contains(widget.line);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.controller.toggleBreakpoint(widget.line),
        child: Container(
          width: _breakpointRadius * 2,
          height: _breakpointRadius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _hovered || isBreakpoint ? widget.color.withOpacity(isBreakpoint ? 1.0 : 0.5) : Colors.transparent,
          ),
        ),
      ),
    );
  }
}