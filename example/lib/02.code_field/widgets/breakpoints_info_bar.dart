import 'package:flutter/material.dart';

class BreakpointsInfoBar extends StatelessWidget {
  final Set<int> breakpoints;

  const BreakpointsInfoBar({super.key, required this.breakpoints});

  @override
  Widget build(BuildContext context) {
    if (breakpoints.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade200,
      child: Text('Breakpoints: ${breakpoints.join(', ')}'),
    );
  }
}