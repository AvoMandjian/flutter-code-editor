import 'package:flutter/material.dart';

import '../code_field/code_controller.dart';

const _breakpointRadius = 4.0;

class BreakpointWidget extends StatefulWidget {
  final int line;
  final CodeController controller;
  final Color color;
  final Map<int, ValueNotifier<bool>> valueNotifierIsHovered;

  const BreakpointWidget({
    super.key,
    required this.line,
    required this.controller,
    required this.color,
    required this.valueNotifierIsHovered,
  });

  @override
  State<BreakpointWidget> createState() => _BreakpointWidgetState();
}

class _BreakpointWidgetState extends State<BreakpointWidget> {
  @override
  Widget build(BuildContext context) {
    final isBreakpoint = widget.controller.breakpoints.contains(widget.line);
    return ValueListenableBuilder<bool>(
      valueListenable: widget.valueNotifierIsHovered[widget.line]!,
      builder: (context, value, child) {
        return MouseRegion(
          onEnter: (_) => widget.valueNotifierIsHovered[widget.line]!.value = true,
          onExit: (_) => widget.valueNotifierIsHovered[widget.line]!.value = false,
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.controller.toggleBreakpoint(widget.line),
            child: Padding(
              padding: const EdgeInsets.all(_breakpointRadius * 2),
              child: Container(
                width: _breakpointRadius * 2,
                height: _breakpointRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value || isBreakpoint ? widget.color.withOpacity(isBreakpoint ? 1.0 : 0.5) : Colors.transparent,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
