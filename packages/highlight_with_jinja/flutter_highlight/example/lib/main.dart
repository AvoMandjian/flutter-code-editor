import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/theme_map.dart';

// import 'package:url_launcher/url_launcher.dart';

import 'example_map.dart';

void main() => runApp(MyApp());

const title = 'Flutter Highlight Gallery';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, title: title, home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var language = 'dart';
  var theme = 'a11y-dark';

  Widget _buildMenuContent(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: <Widget>[
          Text(text, style: const TextStyle(fontSize: 16)),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
        actions: <Widget>[
          PopupMenuButton(
            child: _buildMenuContent(language),
            itemBuilder: (context) {
              return exampleMap.keys.map((key) {
                return CheckedPopupMenuItem(value: key, checked: language == key, child: Text(key));
              }).toList();
            },
            onSelected: (selected) {
              setState(() {
                language = selected;
              });
            },
          ),
          PopupMenuButton<String>(
            child: _buildMenuContent(theme),
            itemBuilder: (context) {
              return themeMap.keys.map((key) {
                return CheckedPopupMenuItem(value: key, checked: theme == key, child: Text(key));
              }).toList();
            },
            onSelected: (selected) {
              setState(() {
                theme = selected;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Source Code',
            onPressed: () {
              // launchUrl(Uri.parse('https://github.com/pd4d10/highlight'));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            HighlightView(
              exampleMap[language]!,
              language: language,
              theme: themeMap[theme]!,
              padding: const EdgeInsets.all(12),
              textStyle: const TextStyle(fontFamily: 'SFMono-Regular,Consolas,Liberation Mono,Menlo,monospace'),
            ),
          ],
        ),
      ),
    );
  }
}
