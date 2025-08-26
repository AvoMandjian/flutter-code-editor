import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import '../jinja_service.dart';

class JinjaDebugView extends StatelessWidget {
  final Map<String, dynamic> breakpointsInfo;
  final JinjaService jinjaService;

  const JinjaDebugView({
    super.key,
    required this.breakpointsInfo,
    required this.jinjaService,
  });

  @override
  Widget build(BuildContext context) {
    if (breakpointsInfo.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: breakpointsInfo.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: HtmlWidget(
            jinjaService.renderDebugTemplate(entry.value),
          ),
        );
      }).toList(),
    );
  }
}