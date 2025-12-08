import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/java.dart';

void main() {
  runApp(const ErrorTrackingExample());
}

class ErrorTrackingExample extends StatefulWidget {
  const ErrorTrackingExample({super.key});

  @override
  State<ErrorTrackingExample> createState() => _ErrorTrackingExampleState();
}

class _ErrorTrackingExampleState extends State<ErrorTrackingExample> {
  late final CodeController controller;

  @override
  void initState() {
    super.initState();
    controller = CodeController(
      text: '''
// Clean and valid Java example matching the same structure as the malformed one
import java.util.ArrayList;
import java.util.List;

public class CleanExample implements Runnable {

    @Override
    public void run() {
        System.out.println("Running...");
    }

    public static void main(String[] args) {
        System.out.println("Start");

        int x = 10;
        if (x == 5) {
            doSomething();
        }

        for (int i = 0; i < 10; i++) {
            System.out.println(i);
        }

        String text = "hello";

        CleanExample example = new CleanExample();
        example.run();

        try {
            example.safeCall();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            System.out.println("Cleanup completed");
        }
    }

    public static void doSomething() {
        System.out.println("Doing something");
    }

    public void safeCall() {
        System.out.println("Safe call");
    }
}''',
      language: java,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CodeTheme(
          data: CodeThemeData(styles: monokaiSublimeTheme),
          child: Center(
            child: SingleChildScrollView(
              child: CodeField(
                controller: controller,
                gutterStyle: const GutterStyle(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
