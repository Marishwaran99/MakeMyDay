import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserScreen extends StatefulWidget {
  final url;

  BrowserScreen(this.url);
  @override
  _BrowserScreenState createState() => _BrowserScreenState(this.url);
}

class _BrowserScreenState extends State<BrowserScreen> {
  var url;

  _BrowserScreenState(url);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    ));
  }
}
