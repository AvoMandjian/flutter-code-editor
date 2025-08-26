// This example expands 01.minimal.dart by using CodeField
// instead of an ordinary TextField.
// This automatically adds the gutter, code folding, and basic autocompletion.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:highlight/languages/jinja.dart';
import 'package:intl/intl.dart';
import 'package:jinja/debug.dart';
import 'package:jinja/jinja.dart';

void main() {
  runApp(const CodeEditor());
}

class CodeEditor extends StatefulWidget {
  const CodeEditor({super.key});

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  CodeController? _codeController;
  Set<int> _breakpoints = {};
  final ValueNotifier<Map<String, dynamic>> breakpointsInfo = ValueNotifier({});
  Map<String, dynamic> dataToPassToJinja = {
    'subcategory_title': 'Su',
    'subcategory_title_2': 'Su 2',
    'subcategory_title_3': 'Su 3',
    'subcategory_title_4': 'Su 4',
  };
  final env = Environment();
  var templateSource = '''
<p>First Script</p><p>{{subcategory_title}}</p>
<p>Second Script</p><p>{{subcategory_title_2}}</p>
<p>Third Script</p><p>{{subcategory_title_3}}</p>
<p>Fourth Script</p><p>{{subcategory_title_4}}</p>
''';
  late final Template templateOfJinja = env.fromString(templateSource);
  final Map<String, dynamic> customThemes = {
    'custom_theme': {
      'root': {
        'backgroundColor': '0xffffffff',
        'color': '0xff000000',
      },
      'comment': {
        'color': '0xff008000',
      },
      'quote': {
        'color': '0xff008000',
      },
      'variable': {
        'color': '0xff008000',
      },
      'keyword': {
        'color': '0xff0000ff',
      },
      'selector-tag': {
        'color': '0xff0000ff',
      },
      'built_in': {
        'color': '0xff0000ff',
      },
      'name': {
        'color': '0xff0000ff',
      },
      'tag': {
        'color': '0xff0000ff',
      },
      'string': {
        'color': '0xffa31515',
      },
      'title': {
        'color': '0xffa31515',
      },
      'section': {
        'color': '0xffa31515',
      },
      'attribute': {
        'color': '0xffa31515',
      },
      'literal': {
        'color': '0xffa31515',
      },
      'template-tag': {
        'color': '0xffa31515',
      },
      'template-variable': {
        'color': '0xffa31515',
      },
      'type': {
        'color': '0xffa31515',
      },
      'addition': {
        'color': '0xffa31515',
      },
      'deletion': {
        'color': '0xff2b91af',
      },
      'selector-attr': {
        'color': '0xff2b91af',
      },
      'selector-pseudo': {
        'color': '0xff2b91af',
      },
      'meta': {
        'color': '0xff2b91af',
      },
      'doctag': {
        'color': '0xff808080',
      },
      'attr': {
        'color': '0xffff0000',
      },
      'symbol': {
        'color': '0xff00b0e8',
      },
      'bullet': {
        'color': '0xff00b0e8',
      },
      'link': {
        'color': '0xff00b0e8',
      },
      'emphasis': {
        'font_style': 'italic',
      },
      'strong': {
        'font_weight': 'bold',
      },
      // Added missing keys from standard themes
      'subst': {
        'color': '0xff000000',
      },
      'selector-id': {
        'color': '0xffa31515',
      },
      'selector-class': {
        'color': '0xffa31515',
      },
      'regexp': {
        'color': '0xff2b91af',
      },
      'meta-string': {
        'color': '0xff2b91af',
      },
      'meta-keyword': {
        'color': '0xff0000ff',
        'font_weight': 'bold',
      },
      'builtin-name': {
        'color': '0xff0000ff',
      },
      'params': {
        'color': '0xffa31515',
      },
      'formula': {
        'color': '0xff808080',
      },
      'code': {
        'color': '0xff008000',
      },
      'number': {
        'color': '0xffa31515',
      },
    },
  };
  final ValueNotifier<String?> valueNotifierResult = ValueNotifier(null);
  final debugController = DebugController()..enabled = true;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: templateSource,
      language: jinja,
      subLanguage: 'xml',
      onBreakpointsChanged: (breakpoints) {
        setState(() {
          _breakpoints = breakpoints;
        });
      },
    );
  }

  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Code Editor'),
          actions: [
            IconButton(
              icon: const Icon(Icons.rocket),
              onPressed: () async {
                _breakpoints.forEach(debugController.addLineBreakpoint);

                debugController.onBreakpoint = (info) async {
                  breakpointsInfo.value[info.lineNumber.toString()] = {
                    'nodeType': info.nodeType,
                    'variables': info.variables,
                    'outputSoFar': info.outputSoFar,
                    'lineNumber': info.lineNumber,
                    'nodeName': info.nodeName,
                    'nodeData': info.nodeData.toString(),
                  };
                  breakpointsInfo.value = Map.from(breakpointsInfo.value);
                  return DebugAction.continueExecution;
                };

                // run jinja script here
                valueNotifierResult.value = await templateOfJinja.renderDebug(
                  data: dataToPassToJinja,
                  debugController: debugController,
                );
                valueNotifierResult.value = '${valueNotifierResult.value}\n${DateTime.now()}';
              },
            ),
          ],
        ),
        body: CodeTheme(
          data: CodeThemeData(styles: themeMap['custom_theme_light']),
          child: Column(
            children: [
              ValueListenableBuilder<String?>(
                valueListenable: valueNotifierResult,
                builder: (context, value, child) {
                  if (value == null) {
                    return const SizedBox.shrink();
                  }
                  return Text(value);
                },
              ),
              ValueListenableBuilder<Map<String, dynamic>>(
                valueListenable: breakpointsInfo,
                builder: (context, value, child) {
                  if (value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return SingleChildScrollView(
                    child: Column(
                      children: value.entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: HtmlWidget(
                            '''<div style="
  font-family: 'SF Mono', 'Roboto Mono', monospace;
  background: #1e1e1e;
  color: #dcdcdc;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 6px 12px rgba(0,0,0,0.3);
  overflow-x: auto;
  border: 1px solid #2d2d2d;
  margin: auto;
">
  <style>
    .debug-title {
      font-size: 16px;
      font-weight: 600;
      color: #9cdcfe;
      margin-bottom: 16px;
      padding-bottom: 8px;
      border-bottom: 1px solid #333;
    }
    .debug-panel {
      border-collapse: collapse;
      font-size: 14px;
    }
    .debug-panel th, .debug-panel td {
      text-align: left;
      padding: 10px 14px;
      border-bottom: 1px solid #333;
      vertical-align: top;
      word-break: break-word;
    }
    .debug-panel th {
      color: #9cdcfe;
      font-weight: 600;
      background: #252526;
      border-right: 1px solid #333;
    }
    .debug-panel tr:hover {
      background: #2a2d2e;
    }
    .debug-panel tr:last-child td {
      border-bottom: none;
    }
    .debug-panel pre {
      margin: 0;
      padding: 8px 10px;
      background: #252526;
      border-radius: 6px;
      white-space: pre-wrap;
      font-family: inherit;
      font-size: 13px;
      line-height: 1.4;
      overflow-x: auto;
    }
    .debug-panel .json-value {
      color: #ce9178;
    }
    .debug-panel .json-key {
      color: #9cdcfe;
    }
  </style>

  <!-- Title -->
  <div class="debug-title">
    Debug – Line ${e.value['lineNumber']}
  </div>

  <table class="debug-panel">
    <tr>
      <th>Node Type:</th>
      <td><span class="json-value">${e.value['nodeType']}</span></td>
    </tr>
    <tr>
      <th>Node Name:</th>
      <td><span class="json-value">${e.value['nodeName']}</span></td>
    </tr>
    <tr>
      <th>Line Number:</th>
      <td><span class="json-value">${e.value['lineNumber']}</span></td>
    </tr>
    <tr>
      <th>Output So Far:</th>
      <td>${e.value['outputSoFar']}</td>
    </tr>
    <tr>
      <th>Node Data:</th>
      <td>${e.value['nodeData']}</td>
    </tr>
    <tr>
      <th>Variables:</th>
      <td>${e.value['variables']}</td>
    </tr>
  </table>
</div>''',
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: CodeField(
                    customThemes: customThemes,
                    controller: _codeController!,
                    gutterStyle: const GutterStyle(
                      showBreakpoints: true,
                    ),
                  ),
                ),
              ),
              if (_breakpoints.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade200,
                  child: Text('Breakpoints: ${_breakpoints.join(', ')}'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
