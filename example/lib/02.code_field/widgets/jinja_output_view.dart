import 'package:flutter/material.dart';

class JinjaOutputView extends StatelessWidget {
  final String? jinjaOutput;

  const JinjaOutputView({super.key, this.jinjaOutput});

  @override
  Widget build(BuildContext context) {
    if (jinjaOutput == null) {
      return const SizedBox.shrink();
    }
    return Text(jinjaOutput!);
  }
}