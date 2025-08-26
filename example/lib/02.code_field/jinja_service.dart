import 'package:flutter/foundation.dart';
import 'package:jinja/debug.dart';
import 'package:jinja/jinja.dart';

import 'constants.dart';

class JinjaService {
  final _env = Environment();
  final _debugController = DebugController()..enabled = true;
  late final Template _templateOfJinja;
  late final Template _templateOfDebug;

  JinjaService() {
    _templateOfJinja = _env.fromString(templateSource);
    _templateOfDebug = _env.fromString(templateSourceDebug);
  }

  Future<String> renderJinjaTemplate({
    required Set<int> breakpoints,
    required ValueChanged<Map<String, dynamic>> onBreakpoint,
  }) {
    breakpoints.forEach(_debugController.addLineBreakpoint);

    final Map<String, dynamic> newBreakpointsInfo = {};

    _debugController.onBreakpoint = (info) async {
      final count = newBreakpointsInfo.keys.where((element) => element.contains(info.lineNumber.toString())).length;

      newBreakpointsInfo['${info.lineNumber}_$count'] = {
        'nodeType': info.nodeType,
        'variables': info.variables,
        'outputSoFar': info.outputSoFar,
        'lineNumber': count == 0 ? info.lineNumber : '${info.lineNumber}\nloop count: ${count + 1}',
        'nodeName': info.nodeName,
        'nodeData': info.nodeData.toString(),
      };

      onBreakpoint(Map.from(newBreakpointsInfo));

      return DebugAction.continueExecution;
    };

    return _templateOfJinja.renderDebug(
      data: dataToPassToJinja,
      debugController: _debugController,
    );
  }

  String renderDebugTemplate(Map<String, dynamic> data) {
    return _templateOfDebug.render(data);
  }
}
