import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:highlight/languages/jinja.dart';

import 'code_editor_state.dart';
import 'constants.dart';
import 'jinja_service.dart';

void main() {
  runApp(const CodeEditorApp());
}

class CodeEditorApp extends StatelessWidget {
  const CodeEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code Editor',
      debugShowCheckedModeBanner: false,
      home: CodeEditorScreen(),
    );
  }
}

class CodeEditorScreen extends StatefulWidget {
  @override
  _CodeEditorScreenState createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  final _jinjaService = JinjaService();
  late final CodeController _codeController;
  final _state = ValueNotifier(const CodeEditorStateModel());

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: templateSource,
      language: jinja,
      subLanguage: 'xml',
      onBreakpointsChanged: (breakpoints) {
        _state.value = _state.value.copyWith(breakpoints: breakpoints);
      },
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _state.dispose();
    super.dispose();
  }

  Future<void> _runJinja() async {
    final result = await _jinjaService.renderJinjaTemplate(
      breakpoints: _state.value.breakpoints,
      onBreakpoint: (info) {
        _state.value = _state.value.copyWith(breakpointsInfo: info);
      },
    );
    _state.value = _state.value.copyWith(
      jinjaOutput: '$result\n${DateTime.now()}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.rocket),
            onPressed: _runJinja,
          ),
        ],
      ),
      body: CodeTheme(
        data: CodeThemeData(styles: themeMap['custom_theme_light']),
        child: CodeField(
          customThemes: customThemes,
          controller: _codeController,
          gutterStyle: const GutterStyle(
            showBreakpoints: true,
          ),
        ),
      ),
    );
  }
}
